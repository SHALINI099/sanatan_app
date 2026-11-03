import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../config/upi_config.dart';
import '../data/model/UpiAppModel.dart';
import '../viewmodel/payment_view_model.dart';

/// Direct UPI client half (playbook Phase 3).
///
/// Hands an AutoPay mandate straight to the UPI app the user picked. The standard checkout
/// sheet is never removed — this is an additional surface on top of a working checkout, and
/// every failure path here falls back to it.
class UpiDirectService {
  UpiDirectService._();

  static const MethodChannel _channel = MethodChannel('com.alnico.sanatanapp/upi');

  /// Claimed SYNCHRONOUSLY, before any await, so a double-tap cannot mint two mandates
  /// (D14).
  static bool _isProcessing = false;
  static bool get isProcessing => _isProcessing;

  /// Releases a guard whose attempt was stranded — the app came back from a UPI app with no
  /// SDK callback because the Activity was destroyed while it was away (D15). Without this
  /// the CTA stays disabled forever, which is worse for the user than a spurious error.
  static void releaseStrandedAttempt() {
    _isProcessing = false;
  }

  // ------------------------------------------------------------------ warm-up

  /// Builds the native SDK + off-screen WebView while the paywall is idle, so the tap path
  /// does not pay the construction cost. An optimisation, never a precondition — a failure
  /// here is swallowed and the SDK is built lazily on the tap instead.
  static Future<void> initNative(String keyId) async {
    if (!Platform.isAndroid || keyId.isEmpty) return;
    try {
      await _channel.invokeMethod<bool>('init', {'keyId': keyId});
    } catch (e) {
      debugPrint('=== UPI: native init skipped ($e) ===');
    }
  }

  // ------------------------------------------------------------------ detection

  /// UPI apps that can sign an AutoPay mandate.
  ///
  /// AN EMPTY LIST IS A CORRECT ANSWER (D6/C15). An unregistered UPI app disables its own
  /// intent handler and is invisible to every app on the phone by design, so empty is the
  /// common case on a device with no bank account linked. Fall back to the sheet; never gate
  /// the only payment path on detection succeeding.
  static Future<List<UpiApp>> listUpiApps() async {
    if (!Platform.isAndroid) return const [];
    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'listUpiApps',
        {
          'priority': UpiConfig.priorityPackages,
          'maxApps': UpiConfig.maxApps,
          'preferAutoPay': UpiConfig.preferAutoPay,
          'autoPayWaitMs': UpiConfig.autoPayWaitMs,
          'hardDeadlineMs': UpiConfig.detectionHardDeadlineMs,
        },
      ).timeout(Duration(milliseconds: UpiConfig.detectionInvokeTimeoutMs));
      if (res == null) return const [];

      // KEEP THIS LOG. Without it, "no icons" on a user's phone is indistinguishable
      // between "no wallets installed" and "our detection call returned nothing" — and
      // those need opposite fixes.
      debugPrint('=== UPI: detect source=${res['source']} '
          'plain=${res['plainCount']} autopay=${res['autoPayCount']} ===');

      final raw = res['apps'];
      if (raw is! List) return const [];
      final apps = raw
          .whereType<Map<dynamic, dynamic>>()
          .map(UpiApp.fromMap)
          .whereType<UpiApp>()
          .toList(growable: false);
      debugPrint('=== UPI: ${apps.length} app(s): '
          '${apps.map((a) => a.packageName).join(", ")} ===');
      return apps;
    } catch (e) {
      debugPrint('=== UPI: detection failed ($e) — falling back to sheet ===');
      return const [];
    }
  }

  // ------------------------------------------------------------------ warming (D8)

  /// Subscription created AHEAD of the tap. Keyed by plan so switching plans never reuses
  /// the wrong one, and read SYNCHRONOUSLY on the tap — a Future or setState read would
  /// reintroduce the wait this exists to remove.
  static CreatedSubscription? _warmSub;
  static String? _warmSubPlan;
  static bool _warming = false;

  /// SILENT and best-effort. A failure leaves create-on-tap in place and shows nothing —
  /// the user has not asked to pay yet, so an error would be confusing and unactionable.
  ///
  /// Call from the pre-tap triggers: plans loaded · detection finished · plan tile tapped ·
  /// UPI card tapped.
  static Future<void> warmSubscription({
    required String planId,
    required int totalCount,
    required int trialDays,
    required int amount,
  }) async {
    if (planId.isEmpty) return;
    if (_warming) return;
    if (_warmSubPlan == planId && _warmSub?.isUsable == true) return;
    _warming = true;
    try {
      final created = await paymentCtr.createSubscriptionRequest(
        planId: planId,
        totalCount: totalCount,
        trialDays: trialDays,
        amount: amount,
      );
      if (created.isUsable) {
        _warmSub = created;
        _warmSubPlan = planId;
        debugPrint('=== UPI: warmed subscription for plan $planId ===');
        // The warm response is the FIRST place a gateway key exists on a fresh install —
        // storage is empty until a subscription has been created. Building the SDK here is
        // what keeps the cold-start cost off the tap path, and off detection's budget.
        await initNative(created.keyId!);
      }
    } catch (_) {
      // Deliberately swallowed.
    } finally {
      _warming = false;
    }
  }

  /// Call ONLY after a HARD failure. A hard failure can leave the first invoice in a state
  /// the gateway will not accept a second payment on, so the retry must mint a fresh one.
  ///
  /// DO NOT call after a user cancellation: a cancelled attempt leaves the subscription
  /// `created`, which is still payable, so keeping it makes the retry as fast as the first
  /// tap.
  static void discardWarmSubscription() {
    _warmSub = null;
    _warmSubPlan = null;
  }

  /// Warm hit, or a fresh create. The warm read is synchronous and happens before any
  /// await, which is the whole point of warming.
  static Future<CreatedSubscription> _obtainSubscription({
    required String planId,
    required int totalCount,
    required int trialDays,
    required int amount,
  }) async {
    if (_warmSubPlan == planId && _warmSub?.isUsable == true) {
      return _warmSub!; // warm hit — no network on the tap
    }
    final created = await paymentCtr.createSubscriptionRequest(
      planId: planId,
      totalCount: totalCount,
      trialDays: trialDays,
      amount: amount,
    );
    if (created.isUsable) {
      // Cache it back so a retry after a cancellation is warm too.
      _warmSub = created;
      _warmSubPlan = planId;
    }
    return created;
  }

  /// The subscription for the standard checkout sheet — including the "Other UPI" tile.
  ///
  /// Same plan, same mandate, different surface: this deliberately returns the SAME warmed
  /// subscription the direct path would have used. Minting a second one here would leave an
  /// orphan `created` subscription behind on every fallback.
  static Future<CreatedSubscription> obtainSubscriptionForSheet({
    required String planId,
    required int totalCount,
    required int trialDays,
    required int amount,
  }) {
    return _obtainSubscription(
      planId: planId,
      totalCount: totalCount,
      trialDays: trialDays,
      amount: amount,
    );
  }

  // ------------------------------------------------------------------ launch

  /// Hands the mandate to [packageName]. Returns once the UPI app has reported back, or
  /// immediately with an error if the hand-off could not be made at all — in which case the
  /// caller must fall back to the standard sheet.
  static Future<UpiLaunchResult> startDirectUpi({
    required String packageName,
    required String planId,
    required int totalCount,
    required int trialDays,
    required int amount,
    required String email,
    required String contact,

    /// Fired the instant a subscription id exists and BEFORE the hand-off, so the caller can
    /// record what to confirm. Load-bearing: the Activity can be destroyed the moment the
    /// UPI app takes the foreground, and a caller that only learns the id from the return
    /// value would have nothing to poll for when it comes back.
    void Function(String subscriptionId)? onSubscriptionReady,
  }) async {
    // Claimed SYNCHRONOUSLY, before any await (D14).
    if (_isProcessing) {
      return const UpiLaunchResult(success: false, error: 'Already in progress');
    }
    _isProcessing = true;

    // Measure OUR overhead: tap -> intent fired. Everything after is the UPI app's own
    // cold start and is not ours to fix.
    final tapAt = DateTime.now();

    try {
      final created = await _obtainSubscription(
        planId: planId,
        totalCount: totalCount,
        trialDays: trialDays,
        amount: amount,
      );
      if (!created.isUsable) {
        _isProcessing = false;
        return UpiLaunchResult(
            success: false, error: created.error ?? UpiConfig.errorDefault);
      }

      // Committed to paying for this subscription — only now does it reach storage, where
      // the verify page will pick it up.
      paymentCtr.adoptSubscription(created);
      onSubscriptionReady?.call(created.subscriptionId!);

      // D9/D11: EVERY value a String. D10: today's charge only — the trial fee on a trial,
      // never the recurring price the mandate is signed for.
      final options = <String, String>{
        'key_id': created.keyId!,
        'subscription_id': created.subscriptionId!,
        'amount': amount.toString(),
        'currency': 'INR',
        'description': UpiConfig.checkoutDescription,
        'email': email,
        'contact': contact,
        'method': 'upi',
        '_[flow]': 'intent',
        'recurring': '1',
        'display_logo': 'false',
        'upi_app_package_name': packageName,
        // NEVER 'customer_id' (C5) — the subscription already carries one and the gateway
        // rejects it: "customer_id is not required and should not be sent".
      };

      debugPrint('=== UPI: submitDirect pkg=$packageName '
          'OUR OVERHEAD ${DateTime.now().difference(tapAt).inMilliseconds}ms ===');

      // No timeout on purpose: this call spans the user's entire time inside the UPI app,
      // which has no upper bound worth guessing at. A wedged SDK is handled by the resume
      // path instead — see releaseStrandedAttempt — and a late result is made harmless by
      // the caller's _unlocked guard.
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'submitDirect', {'keyId': created.keyId, 'options': options});

      final status = res?['status'] as String?;

      if (status == 'cancelled') {
        // KEEP the warm subscription — still payable, so the retry is instant.
        _isProcessing = false;
        return UpiLaunchResult(
          success: false,
          cancelled: true,
          subscriptionId: created.subscriptionId,
          error: UpiConfig.errorCancelled,
        );
      }
      if (status != 'success') {
        discardWarmSubscription(); // possibly poisoned invoice
        _isProcessing = false;
        return UpiLaunchResult(
          success: false,
          subscriptionId: created.subscriptionId,
          error: (res?['message'] as String?) ?? UpiConfig.errorDefault,
        );
      }

      _isProcessing = false;
      return UpiLaunchResult(
        success: true,
        subscriptionId: created.subscriptionId,
        paymentId: res?['paymentId'] as String?,
        signature: res?['signature'] as String?,
      );
    } catch (e) {
      debugPrint('=== UPI: submitDirect threw ($e) ===');
      discardWarmSubscription();
      _isProcessing = false;
      return UpiLaunchResult(
          success: false, error: UpiConfig.errorLaunchFailed);
    }
  }
}