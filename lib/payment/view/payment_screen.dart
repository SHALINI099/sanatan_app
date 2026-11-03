import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:posterapp/core/storage/app_dimensions.dart';
import 'package:posterapp/core/storage/app_spacing.dart';
import 'package:posterapp/payment/viewmodel/razorpay_view_model.dart';
import 'package:posterapp/core/database/BharatStorage.dart';
import 'package:posterapp/resource/widgets/helper/DynamicButton.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_colors.dart';
import '../../resource/values/DownloadShare.dart';
import '../../resource/values/Status.dart';
import '../config/upi_config.dart';
import '../data/model/UpiAppModel.dart';
import '../service/upi_direct_service.dart';
import '../viewmodel/payment_view_model.dart';
import 'verify_payment_page.dart';
import 'widgets/upi_app_selector.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  final RazorPayViewModel razorPayViewModel = Get.put(RazorPayViewModel());

  // ------------------------------------------------------------ Direct UPI state

  List<UpiApp> _upiApps = const [];

  /// The CTA gates on detection having FINISHED, not on an app having been found (D7).
  /// The selection is null during detection, so a fast tap would otherwise read as "no UPI
  /// app" and wrongly open the sheet.
  bool _detectionFinished = false;

  String? _selectedUpiPackage;

  /// "Other UPI" is a peer selection, mutually exclusive with a package selection.
  bool _otherSelected = false;

  bool _isProcessing = false;

  bool _upiHandoffInFlight = false;
  String? _pendingSubscriptionId;
  bool _confirming = false;

  bool _unlocked = false;

  bool _offerRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await paymentCtr.getPaymentDetails();
      if (!mounted) return;
      await _startUpiDetection();
    });

    if (paymentCtr.videoUrl.value.isNotEmpty) {
      paymentCtr.setupVideo(paymentCtr.videoUrl.value);
    }
    razorPayViewModel.razorPay = Razorpay();
    razorPayViewModel.razorPay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS, razorPayViewModel.handlePaymentSuccess);
    razorPayViewModel.razorPay
        .on(Razorpay.EVENT_PAYMENT_ERROR, razorPayViewModel.handlePaymentError);
    razorPayViewModel.razorPay.on(
        Razorpay.EVENT_EXTERNAL_WALLET, razorPayViewModel.handleExternalWallet);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _animation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: const Offset(-1, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // BEFORE any other work, and outside any null-guard: a stranded payment must not depend
    // on e.g. the video controller having initialised.
    if (state == AppLifecycleState.resumed && _upiHandoffInFlight) {
      _onResumeFromUpi();
    }

    if (state == AppLifecycleState.resumed) {
      final isOnTop = ModalRoute.of(context)?.isCurrent ?? false;
      if (!isOnTop) return;
      final c = paymentCtr.videoController;
      if (c != null && c.value.isInitialized) {
        c.play();
      } else if (paymentCtr.videoUrl.value.isNotEmpty) {
        paymentCtr.setupVideo(paymentCtr.videoUrl.value);
      }
    }
  }

  // ------------------------------------------------------------ Direct UPI: detection

  /// Runs once at paywall open, off the tap path. Always sets [_detectionFinished], even on
  /// failure — the CTA waits for detection to finish, not to succeed.
  Future<void> _startUpiDetection() async {
    if (!UpiConfig.directEnabled) {
      if (mounted) setState(() => _detectionFinished = true);
      return;
    }

    // Build the native SDK + off-screen WebView while the paywall is idle. Best-effort: a
    // stored key from a previous session is enough, and if there is none the SDK is built
    // lazily on the tap instead.
    final storedKey = BharatStorage.getApi()?.toString() ?? '';
    if (storedKey.isNotEmpty) {
      UpiDirectService.initNative(storedKey);
    }

    // Warming is kicked off FIRST and deliberately not awaited: it is what supplies the
    // gateway key that builds the native SDK, so starting it here overlaps that work with
    // the detection call instead of serialising behind it.
    _warmCurrentPlan();

    var apps = await UpiDirectService.listUpiApps();

    // A cold SDK can lose the first pass. Detection is local, cheap and idempotent, and by
    // now warming has had a chance to build the SDK — so an empty first answer earns
    // exactly one retry rather than becoming the permanent verdict.
    if (apps.isEmpty && mounted) {
      await Future.delayed(
          Duration(milliseconds: UpiConfig.detectionRetryDelayMs));
      if (!mounted) return;
      debugPrint('=== UPI: first detection empty — retrying once ===');
      apps = await UpiDirectService.listUpiApps();
    }
    if (!mounted) return;

    setState(() {
      _upiApps = apps;
      _detectionFinished = true;
      if (apps.isEmpty) {
        // Zero apps detected -> auto-select Other at detection time, so the CTA never has
        // to decide mid-tap.
        _otherSelected = true;
        _selectedUpiPackage = null;
      } else {
        final preselect = UpiConfig.preselectPackage;
        final match = apps.where((a) => a.packageName == preselect).firstOrNull;
        _selectedUpiPackage = (match ?? apps.first).packageName;
        _otherSelected = false;
      }
    });

    // Detection finished is one of the pre-tap warm triggers.
    _warmCurrentPlan();
  }

  /// Waits for detection to finish, bounded. A wedged native callback must never hang the
  /// tap.
  Future<void> _awaitDetection() async {
    if (_detectionFinished) return;
    final deadline = DateTime.now()
        .add(Duration(milliseconds: UpiConfig.detectionTimeoutMs));
    while (
        mounted && !_detectionFinished && DateTime.now().isBefore(deadline)) {
      await Future.delayed(Duration(milliseconds: UpiConfig.detectionPollMs));
    }
  }

  // ------------------------------------------------------------ Direct UPI: warming

  /// Silent and best-effort (D8). Called from every pre-tap trigger: plans loaded, detection
  /// finished, plan tile tapped, UPI card tapped.
  ///
  /// Gated on [UpiConfig.warmSubscription], which is OFF by default — createSubscription is
  /// meant to fire when the user commits (a UPI app chosen, then Continue), not when they
  /// merely look at the paywall. The trigger call sites are left in place so flipping the
  /// flag back on restores warming without touching this file.
  void _warmCurrentPlan() {
    if (!UpiConfig.warmSubscription) return;
    if (!UpiConfig.directEnabled) return;
    // Nothing to warm for a flow that will never hand off to a UPI app.
    if (paymentCtr.isOldGateway.value) return;
    final planId = paymentCtr.planId.value;
    if (planId.isEmpty) return;
    UpiDirectService.warmSubscription(
      planId: planId,
      totalCount: paymentCtr.totalCount.value,
      trialDays: paymentCtr.trialDays.value,
      amount: _chargeMinorUnits,
    );
  }

  /// D10: today's charge only — the trial fee on a trial, never the recurring price the
  /// mandate is signed for. Same expression the pre-existing checkout path used.
  int get _chargeMinorUnits => paymentCtr.trialDays.value == 0
      ? paymentCtr.amount.value
      : paymentCtr.trialAmount.value;

  // ------------------------------------------------------------ Direct UPI: CTA

  Future<void> _onContinue() async {
    if (_isProcessing) return;

    if (_offerRefresh) {
      // Explicit re-check. Never auto-grants; it just asks the server again.
      setState(() {
        _offerRefresh = false;
      });
      await _pollForConfirmation();
      return;
    }

    if (paymentCtr.planId.value.isEmpty) {
      Fluttertoast.showToast(msg: "No data", gravity: ToastGravity.TOP);
      return;
    }

    // is_oldgatway from the plans response is the outer switch: true means this build talks
    // to the old gateway, so Continue goes straight to the Razorpay sheet and the direct-UPI
    // path (including its detection wait) is skipped entirely.
    if (paymentCtr.isOldGateway.value) {
      await _payWithSheet();
      return;
    }

    // Gate on detection FINISHED, not on an app having been found (D7).
    if (UpiConfig.directEnabled) {
      setState(() => _isProcessing = true);
      await _awaitDetection();
      if (!mounted) return;
    }

    final direct = UpiConfig.directEnabled &&
        !_otherSelected &&
        _selectedUpiPackage != null;

    if (direct) {
      await _payDirectUpi(_selectedUpiPackage!);
    } else {
      await _payWithSheet();
    }
  }

  Future<void> _payDirectUpi(String packageName) async {
    setState(() {
      _isProcessing = true;
      _upiHandoffInFlight = true;
      _offerRefresh = false;
    });

    await paymentCtr.videoController?.pause();

    final res = await UpiDirectService.startDirectUpi(
      packageName: packageName,
      planId: paymentCtr.planId.value,
      totalCount: paymentCtr.totalCount.value,
      trialDays: paymentCtr.trialDays.value,
      amount: _chargeMinorUnits,
      email: '${BharatStorage.getnumber() ?? ""}@OmShanti.app',
      contact: BharatStorage.getnumber() ?? '',
      // Recorded BEFORE the hand-off. By the time this call returns the Activity may have
      // been destroyed and recreated, and the resume path needs to know what to confirm.
      onSubscriptionReady: (id) => _pendingSubscriptionId = id,
    );

    _pendingSubscriptionId ??= res.subscriptionId;
    if (!mounted) return;

    if (res.success) {
      _upiHandoffInFlight = false;
      if (_unlocked) return;
      _unlocked = true;
      setState(() {
        _isProcessing = false;
      });
      // Existing confirmation surface — it polls the server for the real verdict. A client
      // "success" carries no authority on its own.
      Get.to(() => const VerifyPaymentPage());
      return;
    }

    if (res.cancelled) {
      // A cancel verdict carries no authority on its own. When the Activity is destroyed
      // mid-payment the SDK reports that failure IDENTICALLY to a real user cancellation
      // — see the ownerRef note in UpiBridge.kt — so trusting it drops a user who actually
      // signed the mandate back onto the paywall with no entitlement. Ask the server first
      // whenever a subscription got as far as existing.
      //
      // The subscription stays payable either way, so a genuine cancel still retries
      // instantly once this resolves.
      final pending = _pendingSubscriptionId;
      if (pending != null && pending.isNotEmpty && !_unlocked && !_confirming) {
        // Releases the guards and settles the terminal state itself.
        await _pollForConfirmation(afterCancel: true);
        return;
      }

      _upiHandoffInFlight = false;
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    // Hard failure. Never dead-end: offer the sheet, which is the path that always works.
    _upiHandoffInFlight = false;
    setState(() {
      _isProcessing = false;
    });
    Fluttertoast.showToast(
        msg: res.error ?? UpiConfig.errorLaunchFailed,
        gravity: ToastGravity.TOP);
  }

  /// The standard checkout sheet — the fallback that is never removed. Reuses the SAME
  /// warmed subscription: same plan, same mandate, different surface.
  Future<void> _payWithSheet() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final created = await UpiDirectService.obtainSubscriptionForSheet(
        planId: paymentCtr.planId.value,
        totalCount: paymentCtr.totalCount.value,
        trialDays: paymentCtr.trialDays.value,
        amount: _chargeMinorUnits,
      );

      if (!created.isUsable) {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });
        Fluttertoast.showToast(
            msg: created.error ?? "Subscription ID not available",
            gravity: ToastGravity.TOP);
        return;
      }

      paymentCtr.adoptSubscription(created);
      await paymentCtr.videoController?.pause();
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      razorPayViewModel.openCheckout(
        created.subscriptionId!,
        created.keyId!,
        paymentCtr.planId.value,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      Fluttertoast.showToast(
          msg: "Error creating subscription", gravity: ToastGravity.TOP);
    }
  }

  // ------------------------------------------------------------ Phase 7: recovery

  /// A direct hand-off has no in-process callback once the Activity is destroyed. This is
  /// what stops a paying user being stranded.
  Future<void> _onResumeFromUpi() async {
    // Give a real SDK callback a short grace. If the Activity was destroyed while
    // backgrounded (common with 'Don't keep activities', and on low-memory devices) that
    // callback is gone forever — and without this the CTA stays disabled permanently, which
    // is worse for the user than a spurious error (D15).
    await Future.delayed(Duration(milliseconds: UpiConfig.strandedGraceMs));
    if (!mounted) return;
    if (!_upiHandoffInFlight || _unlocked || _confirming) {
      return; // a real result arrived
    }

    if (_pendingSubscriptionId == null || _pendingSubscriptionId!.isEmpty) {
      // Never got as far as a subscription — nothing to confirm, just release the guard.
      UpiDirectService.releaseStrandedAttempt();
      _upiHandoffInFlight = false;
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    // Came back from the UPI app with no verdict at all. The subscription exists and may
    // well have been paid, so this goes to the dedicated confirmation surface rather than
    // confirming inline behind the paywall — VerifyPaymentPage runs its own polling and
    // owns where the user ends up.
    //
    // _unlocked is claimed BEFORE navigating, mirroring the success path: a late SDK
    // callback arriving after this must not push a second page.
    _upiHandoffInFlight = false;
    _unlocked = true;
    UpiDirectService.releaseStrandedAttempt();
    setState(() {
      _isProcessing = false;
    });
    Get.to(() => const VerifyPaymentPage());
  }

  /// WALL-CLOCK budget, never an attempt count (D18). A count-based ladder creates a cliff
  /// that dumps PAYING users onto a manual-refresh state whenever the network or NPCI is
  /// slow.
  ///
  /// Reuses the app's existing server-side status check — a client "success" carries no
  /// authority, and that call is the one place the server is asked for the truth. It is
  /// idempotent and safe to call repeatedly, and navigates away itself once the
  /// subscription is confirmed.
  ///
  /// [afterCancel] only changes the copy shown when nothing is confirmed: the client claimed
  /// a cancellation, so "Taking longer than usual…" would be a lie in the common case. The
  /// re-check affordance stays either way — the whole reason we polled is that the cancel
  /// claim might be wrong, and offering a re-check is safer than a CTA that would charge a
  /// user who has already paid.
  Future<void> _pollForConfirmation({bool afterCancel = false}) async {
    if (_confirming) return;
    _confirming = true;
    final deadline =
        DateTime.now().add(Duration(seconds: UpiConfig.confirmBudgetSeconds));
    final maxAttempts = UpiConfig.confirmMaxAttempts;
    var attempts = 0;

    while (mounted && DateTime.now().isBefore(deadline) && !_unlocked) {
      await paymentCtr.getSubscriptionData();
      attempts++;
      if (!mounted) return;
      if (dashCtr.isSubsribed.value == true) {
        if (_unlocked) return;
        _unlocked = true;
        _confirming = false;
        _upiHandoffInFlight = false;
        UpiDirectService.releaseStrandedAttempt();
        return;
      }
      // Break BEFORE sleeping: on the final attempt the retry interval buys nothing and
      // would just delay the manual-recheck state by a full interval.
      if (maxAttempts > 0 && attempts >= maxAttempts) break;
      await Future.delayed(Duration(seconds: UpiConfig.retryIntervalSeconds));
    }

    // Budget spent with no verdict. NEVER auto-grant, never claim failure — offer an
    // explicit re-check instead.
    if (!mounted) return;
    _confirming = false;
    _upiHandoffInFlight = false;
    UpiDirectService.releaseStrandedAttempt();
    setState(() {
      _isProcessing = false;
      _offerRefresh = true;
    });
  }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFFfffaea),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppSpacing.height(16),

                      /// 🎥 VIDEO CARD
                      Container(
                        height: 380,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Obx(() {
                          final err = paymentCtr.videoError.value;
                          if (err != null) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  'Video error: $err',
                                  style:
                                      const TextStyle(color: AppColors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          final c = paymentCtr.videoController;
                          if (!paymentCtr.isVideoReady.value ||
                              c == null ||
                              !c.value.isInitialized) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            );
                          }

                          return FittedBox(
                            fit: BoxFit.fill,
                            child: SizedBox(
                              width: Get.width,
                              height: 400,
                              child: VideoPlayer(c),
                            ),
                          );
                        }),
                      ),
                      AppSpacing.height(15),
                      Obx(() {
                        switch (paymentCtr.rxgetRequestStatus.value) {
                          case Status.initial:
                            return SizedBox();
                          case Status.loading:
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          case Status.completed:
                            return SizedBox(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: paymentCtr.paymentData.length,
                                itemBuilder: (context, index) {
                                  final payment = paymentCtr.paymentData[index];
                                  return BharatStorage.getTrial() != true
                                      ? Obx(
                                          () => Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 15,
                                                        right: 20,
                                                        top: 30),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                12),
                                                        border: Border.all(
                                                            color: paymentCtr
                                                                        .isYearlyIndex
                                                                        .value ==
                                                                    index
                                                                ? AppColors
                                                                    .primaryColor
                                                                : AppColors
                                                                    .grey,
                                                            width: paymentCtr
                                                                        .isYearlyIndex
                                                                        .value ==
                                                                    index
                                                                ? 2
                                                                : 1)),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      child: ListTile(
                                                        onTap: () {
                                                          paymentCtr
                                                              .isYearlyIndex
                                                              .value = index;
                                                          paymentCtr
                                                                  .recurringCount
                                                                  .value =
                                                              payment
                                                                  .recurringCount;
                                                          paymentCtr.amount
                                                                  .value =
                                                              payment
                                                                  .mainAmount;
                                                          paymentCtr.planId
                                                                  .value =
                                                              payment.planId;
                                                          // Pre-tap warm trigger: the plan
                                                          // just changed, so the warmed
                                                          // subscription must follow it.
                                                          _warmCurrentPlan();
                                                        },
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left: 15,
                                                                right: 20),
                                                        selectedColor: AppColors
                                                            .continueButton,
                                                        focusColor: AppColors
                                                            .continueButton,
                                                        title: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                payment
                                                                    .planTitle,
                                                                style: AppDimensions.inter(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        AppDimensions
                                                                            .fontWeight600)),
                                                            AppSpacing.height(
                                                                8),
                                                            Text(
                                                                payment
                                                                    .discount,
                                                                style: AppDimensions.inter(
                                                                    fontSize:
                                                                        18,
                                                                    color:
                                                                        AppColors
                                                                            .red,
                                                                    fontWeight:
                                                                        AppDimensions
                                                                            .fontWeight600)),
                                                          ],
                                                        ),
                                                        trailing: Column(
                                                          children: [
                                                            Text(
                                                                payment
                                                                    .displayMainAmount
                                                                    .toString(),
                                                                style: AppDimensions.inter(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        AppDimensions
                                                                            .fontWeight600)),
                                                            AppSpacing.height(
                                                                8),
                                                            Text(
                                                                payment.mrp
                                                                    .toString(),
                                                                style: AppDimensions.inter(
                                                                    fontSize:
                                                                        15,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                    color: AppColors
                                                                        .grey
                                                                        .withValues(
                                                                            alpha:
                                                                                0.7),
                                                                    fontWeight:
                                                                        AppDimensions
                                                                            .fontWeight400)),
                                                          ],
                                                        ),
                                                      ).paddingSymmetric(
                                                          horizontal: 13,
                                                          vertical: 10),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 40,
                                                    top: 12,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12),
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                          color: AppColors
                                                              .primaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      22)),
                                                      child: Center(
                                                          child: Text(
                                                        "Most Popular",
                                                        style: AppDimensions.inter(
                                                            color:
                                                                AppColors.white,
                                                            fontSize:
                                                                AppDimensions
                                                                    .fontSize13,
                                                            fontWeight:
                                                                AppDimensions
                                                                    .fontWeight400),
                                                      )),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Text(
                                                "🙏 Unlock Sadhna",
                                                style: AppDimensions.inter(
                                                  fontSize:
                                                      AppDimensions.fontSize16,
                                                  fontWeight: AppDimensions
                                                      .fontWeight500,
                                                ),
                                              ).paddingOnly(top: 25),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            Text(
                                              "Start Trial Now",
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.black
                                                    .withValues(alpha: 0.4),
                                              ),
                                            ),
                                            AppSpacing.height(5),
                                            Divider(
                                              color: AppColors.grey,
                                              thickness: 1,
                                              indent: 80,
                                              endIndent: 80,
                                            ),
                                            AppSpacing.height(10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  payment.displayMainAmount,
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.grey,
                                                      fontWeight: AppDimensions
                                                          .fontWeight600),
                                                ),
                                                AppSpacing.width(15),
                                                Text(
                                                  "₹${(payment.trialAmount! / 100).toStringAsFixed(0)}",
                                                  style: TextStyle(
                                                    fontSize: 35,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            AppSpacing.height(10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.info_outline,
                                                    size: 20,
                                                    color: AppColors.black
                                                        .withValues(
                                                            alpha: 0.3)),
                                                Text(
                                                  "${payment.trialDisplayAmount} for ${payment.trialDays} days, then ${payment.displayMainAmount}/month",
                                                  style: AppDimensions.inter(
                                                      fontSize: AppDimensions
                                                          .fontSize13,
                                                      fontWeight: AppDimensions
                                                          .fontWeight400,
                                                      color: AppColors.black
                                                          .withValues(
                                                              alpha: 0.3)),
                                                ),
                                              ],
                                            ),
                                            AppSpacing.height(15),

                                            ClipRect(
                                              child: SlideTransition(
                                                position: _animation,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text(
                                                      "• Alarm",
                                                      style: AppDimensions.inter(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              AppDimensions
                                                                  .fontWeight600),
                                                    ),
                                                    SizedBox(width: 20),
                                                    Text("• Ringtone",
                                                        style: AppDimensions.inter(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                AppDimensions
                                                                    .fontWeight600)),
                                                    SizedBox(width: 20),
                                                    Text("• Mantra",
                                                        style: AppDimensions.inter(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                AppDimensions
                                                                    .fontWeight600)),
                                                    SizedBox(width: 20),
                                                    Text("• Wallpaper",
                                                        style: AppDimensions.inter(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                AppDimensions
                                                                    .fontWeight600)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Obx(() {
                                            //   if (!paymentCtr.hasTrial.isTrue ||
                                            //       paymentCtr.paymentData.isEmpty)
                                            //     return const SizedBox();
                                            //   final plan = paymentCtr
                                            //       .paymentData[paymentCtr.isYearlyIndex.value];
                                            //   return Row(
                                            //     mainAxisAlignment: MainAxisAlignment.center,
                                            //     crossAxisAlignment: CrossAxisAlignment.center,
                                            //     children: [
                                            //       Icon(Icons.info_outline,
                                            //           size: 20,
                                            //           color:
                                            //           AppColors.black.withValues(alpha: 0.3)),
                                            //       Text(
                                            //         "${paymentCtr.trialDisplayAmount.value} for ${paymentCtr.trialDays.value} days, then ${plan.displayMainAmount}/month",
                                            //         style: AppDimensions.inter(
                                            //             fontSize: AppDimensions.fontSize13,
                                            //             fontWeight: AppDimensions.fontWeight400,
                                            //             color:
                                            //             AppColors.black.withValues(alpha: 0.3)),
                                            //       ),
                                            //     ],
                                            //   );
                                            // }),
                                          ],
                                        );
                                },
                              ),
                            );
                          case Status.error:
                            return SizedBox();
                        }
                      }),
                      AppSpacing.height(10),
                      // Old gateway => no app row at all; Continue is the only control and it
                      // opens the sheet.
                      Obx(() => paymentCtr.isOldGateway.value
                          ? const SizedBox.shrink()
                          : UpiAppSelector(
                              apps: _upiApps,
                              selectedPackage: _selectedUpiPackage,
                              otherSelected: _otherSelected,
                              enabled: !_isProcessing,
                              onSelectApp: (pkg) {
                                setState(() {
                                  _selectedUpiPackage = pkg;
                                  _otherSelected = false;
                                });
                                _warmCurrentPlan();
                              },
                              onSelectOther: () {
                                setState(() {
                                  _otherSelected = true;
                                  _selectedUpiPackage = null;
                                });
                                _warmCurrentPlan();
                              },
                              // The paywall cannot be popped, so the arrow cannot mean "go back".
                              // It backs out of APP selection instead: the next tap opens the
                              // standard checkout sheet on the same warmed subscription.
                              // onBack: () {
                              //   setState(() {
                              //     _otherSelected = true;
                              //     _selectedUpiPackage = null;
                              //   });
                              // },
                            )),
                      if (_upiApps.isNotEmpty && !paymentCtr.isOldGateway.value)
                        AppSpacing.height(5),
                    ],
                  ),
                ),
              ),

              /// 💳 BOTTOM PAYMENT SHEET
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 100,
            color: Color(0xFFfff5dc),
            shadowColor: Colors.grey,
            surfaceTintColor: Colors.grey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EEDB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DynamicButton(
                    color: AppColors.black,
                    height: 50,
                    radius: true,
                    onTap: _onContinue,
                    // Spins from the tap until the flow reaches a terminal state, so the
                    // user can see the tap registered instead of tapping again.
                    isLoading: _isProcessing || _confirming,
                    text: "Continue",
                    backgroundColor: AppColors.primaryColor,
                    fontWeight: AppDimensions.fontWeight700,
                    fontSize: AppDimensions.fontSize20,
                  ),
                  AppSpacing.height(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("🇮🇳", style: TextStyle(fontSize: 16)),
                      AppSpacing.width(6),
                      Text(
                        "India's no. 1 Devotional App",
                        textAlign: TextAlign.center,
                        style: AppDimensions.inter(
                            fontSize: AppDimensions.fontSize13,
                            fontWeight: AppDimensions.fontWeight500,
                            color: AppColors.black),
                      ),
                    ],
                  ),
                  AppSpacing.height(8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
