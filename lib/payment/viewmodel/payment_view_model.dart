import 'dart:async';
import 'dart:developer';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:posterapp/dashboard/view/dashboard_screen.dart';
import 'package:video_player/video_player.dart';
import '../../core/database/BharatStorage.dart';
import '../../resource/functions/LogOut.dart';
import '../../resource/values/DownloadShare.dart';
import '../../resource/values/Status.dart';
import '../config/upi_config.dart';
import '../data/api/PaymentApi.dart';
import '../data/model/FetchPayDetailModel.dart';
import '../data/model/PaymentDetailModel.dart';
import '../data/model/UpiAppModel.dart';
import 'package:posterapp/core/network/dio_client.dart';

final PaymentViewModel paymentCtr = Get.put(PaymentViewModel());

class PaymentViewModel extends GetxController {
  RxBool isYearlySelected = true.obs;
  RxBool isSubscription = true.obs;
  RxBool isProgressLoad = false.obs;
  RxInt isYearlyIndex = 0.obs;
final facebookAppEvents=FacebookAppEvents();
  RxBool paymentSucess = false.obs;
  RxBool hasTrial = true.obs;
  RxString planId = "".obs;
  RxString trialDisplayAmount = "".obs;
  RxInt totalCount = 0.obs;
  RxInt amount = 0.obs;
  RxInt trialAmount = 0.obs;
  RxString subScriptionId = ''.obs;
  RxBool loadPayment = true.obs;
  RxString getApiError = "".obs;
  final rxgetRequestStatus = Status.initial.obs;

  void setgetRxRequestStatus(Status value) => rxgetRequestStatus.value = value;

  final api = PaymentApi(buildDio());
  Rxn<PaymentDetailModel> paymentDetailsModelRx = Rxn<PaymentDetailModel>();
  RxList<Datum> paymentData = <Datum>[].obs;
  RxBool isRazorPay=false.obs;


  RxBool isOldGateway = false.obs;
  RxInt recurringCount = 0.obs;
  RxInt trialDays = 0.obs;
  RxString videoUrl = ''.obs;

  VideoPlayerController? videoController;
  RxBool isVideoReady = false.obs;
  RxnString videoError = RxnString();
  String? _activeVideoUrl;
  Future<void>? _videoSetupInFlight;

  Timer? _verifySecondCheckTimer;
  Timer? _verifyRedirectTimer;

  /// Last error surfaced to the user, so the confirmation poll — which calls the same
  /// endpoint more than once per payment — cannot stack the identical toast twice and make
  /// one failure look like two. Cleared on any successful response.
  String? _lastApiError;


  void _showApiError(dynamic body, {required String fallback}) {
    final msg = _messageFrom(body) ?? fallback;
    if (msg == _lastApiError) return;
    _lastApiError = msg;
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.CENTER);
  }

  static String? _messageFrom(dynamic body) {
    if (body is! Map) return null;
    for (final key in const ['msg', 'message', 'error']) {
      final v = body[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  void startVerifyPaymentPolling() {
    cancelVerifyPaymentPolling();
    getSubscriptionData();
    _verifySecondCheckTimer =
        Timer(const Duration(seconds: 15), getSubscriptionData);
    // This is the TIMEOUT, not the success path — a confirmed subscription is navigated by
    // getSubscriptionData itself the moment it sees one. Redirecting unconditionally sent an
    // unpaid user to the dashboard as though the payment had gone through, which matters now
    // that a return-with-no-verdict lands on this page.
    _verifyRedirectTimer = Timer(const Duration(seconds: 30), () {
      if (dashCtr.isSubsribed.value == true) {
        BharatStorage.setSubscriptionId("");
        Get.offAll(() => DashboardScreen());
        return;
      }

      // Unconfirmed. KEEP the subscription id — it is what any later re-check polls — and
      // hand the user back where they came from instead of leaving them on a spinner that
      // never resolves.
      Fluttertoast.showToast(
          msg: "We couldn't confirm your payment yet.",
          gravity: ToastGravity.CENTER);
      Get.back();
    });
  }

  void cancelVerifyPaymentPolling() {
    _verifySecondCheckTimer?.cancel();
    _verifyRedirectTimer?.cancel();
    _verifySecondCheckTimer = null;
    _verifyRedirectTimer = null;
  }
  Future<void> getPaymentDetails() async {
    setgetRxRequestStatus(Status.loading);
    try {
      String token = BharatStorage.getAuthKey() ?? '';
      final res = await api.getPaymentDetails('Bearer $token');
log("dkfjhg");
      if (res.response.statusCode == 200) {
        // Direct UPI tunables ride along on this response when the backend supplies them.
        // Absent or malformed, every value falls back to its compiled-in default, so this
        // is safe to call unconditionally and can never fail the plans load.
        UpiConfig.applyOverrides(
            (res.data is Map) ? (res.data as Map)['upi_config'] : null);

        paymentDetailsModelRx.value = PaymentDetailModel.fromJson(res.data);

        paymentData.assignAll(paymentDetailsModelRx.value!.data);
        videoUrl.value = paymentDetailsModelRx.value!.videoUrl ?? '';
        if (videoUrl.value.isNotEmpty) {
          setupVideo(videoUrl.value);
        }
        isOldGateway.value = paymentDetailsModelRx.value!.is_oldgatway;
        hasTrial.value=paymentDetailsModelRx.value!.hasTrial;
        BharatStorage.setTrial(hasTrial.value);

        trialDays.value = paymentData[isYearlyIndex.value].trialDays ?? 0;
        trialAmount.value = paymentData[isYearlyIndex.value].trialAmount ?? 0;
        trialDisplayAmount.value = paymentData[isYearlyIndex.value].trialDisplayAmount??'';
        totalCount.value = paymentData[isYearlyIndex.value].recurringCount;
        amount.value = paymentData[isYearlyIndex.value].mainAmount;
        planId.value = paymentData[isYearlyIndex.value].planId;
        _lastApiError = null;
        setgetRxRequestStatus(Status.completed);
      } else if (res.response.statusCode == 401) {
        setgetRxRequestStatus(Status.error);
      } else {
        // 400 / 502 / anything else. The plans call failing means an empty paywall, so the
        // reason has to reach the user rather than only the status enum.
        setgetRxRequestStatus(Status.error);
        _showApiError(res.data, fallback: 'Could not load plans.');
      }
    } catch (e) {
      log("getSubscriptionPlans failed: ${e.toString()}");
      setgetRxRequestStatus(Status.error);
      _showApiError(null, fallback: 'Could not load plans.');
    }
  }



  /// The single create-subscription call. Returns its result instead of only mutating Rx
  /// state, so the Direct UPI warmer (playbook 3.3) can mint a subscription ahead of the tap
  /// through the SAME request rather than forking it.
  ///
  /// Deliberately writes NOTHING to storage: a warm create for a plan the user never buys
  /// must not leave a stale subscription id behind for the verify page to poll. The caller
  /// that actually launches a payment does that write — see [createSubscription].
  Future<CreatedSubscription> createSubscriptionRequest(
      {required String planId,
      required int totalCount,
      required int trialDays,
      required int amount}) async {
    try {
      String token = BharatStorage.getAuthKey() ?? '';
      var mobile = BharatStorage.getnumber() ?? 0;
      final res = await api.createSub('Bearer $token', {
        'mobile_number': mobile,
        'planId': planId,
        'total_count': totalCount,
        'trialDays': trialDays,
        'amount': amount,
        'app_name': 'com.alnico.sanatanapp'
      });

      if (res.response.statusCode == 200) {
        return CreatedSubscription(
          subscriptionId: res.response.data['subscriptiondata'] as String?,
          keyId: res.response.data['key'] as String?,
        );
      } else if (res.response.statusCode == 401) {
        logOutUser(true);
        return const CreatedSubscription(error: 'Session expired');
      }
      return const CreatedSubscription(error: 'Could not create subscription');
    } catch (error) {
      return const CreatedSubscription(error: 'Could not create subscription');
    }
  }

  /// Commits a created subscription to Rx state + storage. This is the point at which the
  /// app is committed to paying for [created], so it is the point at which the verify page
  /// is allowed to see its id.
  void adoptSubscription(CreatedSubscription created) {
    if (!created.isUsable) return;
    subScriptionId.value = created.subscriptionId!;
    BharatStorage.setSubscriptionId(created.subscriptionId!);
    BharatStorage.setApi(created.keyId!);
  }

  Future<void> createSubscription(
      {required String planId,
        required int totalCount,
        required int trialDays,
        required int amount}) async {
    final created = await createSubscriptionRequest(
      planId: planId,
      totalCount: totalCount,
      trialDays: trialDays,
      amount: amount,
    );
    adoptSubscription(created);
  }


  Future<void> setupVideo(String url) async {
    if (url.isEmpty) return;
    if (_activeVideoUrl == url && videoController != null) return;
    if (_videoSetupInFlight != null) return _videoSetupInFlight;

    final future = _doSetupVideo(url);
    _videoSetupInFlight = future;
    try {
      await future;
    } finally {
      _videoSetupInFlight = null;
    }
  }

  Future<void> _doSetupVideo(String url) async {
    final old = videoController;
    videoController = null;
    isVideoReady.value = false;
    videoError.value = null;
    await old?.dispose();

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(1.0);
      await controller.play();
      videoController = controller;
      _activeVideoUrl = url;
      isVideoReady.value = true;
    } catch (e) {
      await controller.dispose();
      videoError.value = e.toString();
    }
  }

  @override
  void onClose() {
    videoController?.dispose();
    videoController = null;
    super.onClose();
  }

  Future<void> getSubscriptionData() async {
    try {
      String token = BharatStorage.getAuthKey() ?? '';
      String mobile = BharatStorage.getnumber() ?? '';
      String subScription = BharatStorage.getSubscriptionId() ?? '';
      final res = await api.getSubscriptionData(
        'Bearer $token',
        subScription,
        mobile,
          'com.alnico.sanatanapp'

      );

      if (res.response.statusCode == 200) {
        final body = res.response.data;
        // A rejected lookup ("Subscription not found", an expired id) also comes back 200,
        // with `status` as a BOOLEAN false rather than a status string. FetchPayDetailModel
        // declares status as String, so parsing that body throws a TypeError straight into
        // the catch below — which is why this case was silent too. Read the status defensively
        // and let the message speak for itself.
        final rawStatus = (body is Map) ? body['status'] : null;
        if (rawStatus is! String) {
          _showApiError(body, fallback: 'Could not check payment status.');
          return;
        }

        FetchPayDetailModel model = FetchPayDetailModel.fromJson(body);
        _lastApiError = null;
        if (model.status == 'Active' ||
            model.status == 'captured' ||
            model.status == 'authenticated') {
          dashCtr.isSubsribed.value = true;
          dashCtr.isSubsribed.refresh();
          BharatStorage.setSubscription(true);
          Fluttertoast.showToast(
              msg: "Your trial period has been started. ",
              gravity: ToastGravity.CENTER);
          Get.offAll(()=>DashboardScreen());
          try {
            facebookAppEvents
                .logPurchase(amount: 99.0, currency: 'INR');



          } catch (e) {}
        }
        else {
          dashCtr.isSubsribed.value = false;
          dashCtr.isSubsribed.refresh();
          BharatStorage.setSubscription(false);
        }

      } else if (res.response.statusCode == 401) {
        logOutUser(true);
      } else {
        _showApiError(res.response.data,
            fallback: 'Could not check payment status.');
      }
    } catch (error) {
      log('checkSubscriptionStatus failed: $error');
      _showApiError(null, fallback: 'Could not check payment status.');
    }
  }
}
