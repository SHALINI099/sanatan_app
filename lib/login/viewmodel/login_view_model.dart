import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:posterapp/dashboard/viewmodel/dashboard_view_model.dart';

import '../../core/theme/app_colors.dart';
import '../../core/database/BharatStorage.dart';
import '../../resource/values/Status.dart';
import '../data/api/LoginEndPoint.dart';
import '../data/model/LoginModel.dart';
import '../data/model/OnboardingModel.dart';
import '../data/model/OtpModel.dart';
import 'package:posterapp/core/network/dio_client.dart';

final dashCtr = Get.put(DashboardViewModel());

class LoginViewModel extends GetxController {
  final api = LoginEndPoint(buildDio());
  final fcm_token = TextEditingController().obs;

  // Controllers
  final mobileCtr = TextEditingController().obs;
  final otpCtr = TextEditingController().obs;
  final nameCtr = TextEditingController().obs;

  // Observables
  final loginApiError = "".obs;
  final otpApiError = "".obs;
  final onboardApiError = "".obs;

  final rxLoginRequestStatus = Status.initial.obs;
  final rxOtpRequestStatus = Status.initial.obs;
  final rxOnboardRequestStatus = Status.initial.obs;

  RxBool isAccepted = true.obs;

  void setLoginRxRequestStatus(Status value) =>
      rxLoginRequestStatus.value = value;

  void setOtpRxRequestStatus(Status value) => rxOtpRequestStatus.value = value;

  void setOnboardRxRequestStatus(Status value) =>
      rxOnboardRequestStatus.value = value;

  // Models
  LoginModel? loginModel;
  OtpModel? otpModel;
  OnboardingModel? onboardingModel;

  // -------------------------------
  // COMMON HANDLER
  // -------------------------------
  void _handleError(RxString errorRx, dynamic error, Rx<Status> statusRx) {
    errorRx.value = error.toString();
    statusRx.value = Status.error;
  }

  // -------------------------------
  // LOGIN API
  // -------------------------------
  Future<void> login({required String mobileNumber}) async {
    setLoginRxRequestStatus(Status.loading);

    try {
      final res = await api.loginPhone({'mobile_number': mobileNumber});

      if (res.response.statusCode == 200) {
        loginModel = LoginModel.fromJson(res.data);

        await BharatStorage.setUserInfoKey(
            loginModel?.identificationToken ?? "");

        await BharatStorage.setnumber(mobileNumber);

        setLoginRxRequestStatus(Status.completed);
      } else {
        loginApiError.value =
            "${res.response.statusCode}\n${res.response.statusMessage}";
        setLoginRxRequestStatus(Status.error);
      }
    } catch (e) {
      setLoginRxRequestStatus(Status.error);

      _handleError(loginApiError, e, rxLoginRequestStatus);
    }
  }

  // -------------------------------
  // OTP VERIFY
  // -------------------------------
  Future<void> otp() async {
    try {
      setOtpRxRequestStatus(Status.loading);
      String token = BharatStorage.getUserInfoKey() ?? "";
      String? fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      mobileCtr.value.text = BharatStorage.getnumber() ?? '';

      fcm_token.value.text = fcmToken;
      final res = await api.otpVerify({
        'mobile_number': mobileCtr.value.text,
        'identification_token': token,
        'otp': otpCtr.value.text,
        'fcm_token': fcm_token.value.text
      });

      if (res.response.statusCode == 200) {
        otpModel = OtpModel.fromJson(res.response.data);

        BharatStorage.setAuthKey(otpModel?.authToken ?? "");
        BharatStorage.setOnboarded(otpModel?.isOnboarded ?? false);
        try {
          if (otpModel!.data.subscriptionType!.toLowerCase() == "success") {
            BharatStorage.setSubscription(true);
            dashCtr.isSubsribed.value = true;
            dashCtr.isSubsribed.refresh();
          } else {
            BharatStorage.setSubscription(false);
            dashCtr.isSubsribed.value = false;
            dashCtr.isSubsribed.refresh();
          }
        } catch (e) {
          BharatStorage.setSubscription(false);
          dashCtr.isSubsribed.value = false;
          dashCtr.isSubsribed.refresh();
        }
        setOtpRxRequestStatus(Status.completed);
      } else if (res.response.statusCode == 400) {
        Fluttertoast.showToast(
          msg: "Invalid Otp",
          textColor: AppColors.primaryColor,
          backgroundColor: AppColors.white,
        ).then((value) => setOtpRxRequestStatus(Status.initial));
      } else {
        otpApiError.value =
            "${res.response.statusCode.toString()}\n${res.response.statusMessage}";
        otpApiError.refresh();
        setOtpRxRequestStatus(Status.error);
      }
    } on Exception catch (error) {
      otpApiError.value = "$error";
      otpApiError.refresh();
      setOtpRxRequestStatus(Status.error);
    }
  }

  // -------------------------------
  // ONBOARDING
  // -------------------------------
  Future<void> verifyUser() async {
    rxOnboardRequestStatus.value = Status.loading;

    try {
      final token = BharatStorage.getAuthKey() ?? '';

      final res = await api.onboardUser(
        'Bearer $token',
        {'name': nameCtr.value.text, "avatar": 'sss'},
      );

      if (res.response.statusCode == 200) {
        onboardingModel = OnboardingModel.fromJson(res.data);

        await BharatStorage.setUserName(nameCtr.value.text);
        // await BharatStorage.setUserImage(avatar);
        await BharatStorage.setOnboarded(onboardingModel?.onboarding ?? false);

        rxOnboardRequestStatus.value = Status.completed;
      } else {
        onboardApiError.value =
            "${res.response.statusCode}\n${res.response.statusMessage}";
        rxOnboardRequestStatus.value = Status.error;
      }
    } catch (e) {
      _handleError(onboardApiError, e, rxOnboardRequestStatus);
    }
  }

  // -------------------------------
  // LOCAL DATA SET
  // -------------------------------
  // Future<void> setLocalData() async {
  //   final data = otpModel?.data;
  //
  //   if (data == null) {
  //     log("setLocalData: otpModel data is null");
  //     return;
  //   }
  //
  //   try {
  //     await Future.wait([
  //       BharatStorage.setAddress(data.address ?? ""),
  //       BharatStorage.setFacebookId(data.fbId ?? ""),
  //       BharatStorage.setInstaId(data.instaId ?? ""),
  //       BharatStorage.setTwitterId(data.twiterId ?? ""),
  //       BharatStorage.setUserImage(data.avatar ?? ""),
  //       BharatStorage.setUserName(data.name ?? ""),
  //     ] as Iterable<Future>);
  //   } catch (e, stackTrace) {
  //     log("Error in setLocalData: $e", stackTrace: stackTrace);
  //   }
  // }
}
