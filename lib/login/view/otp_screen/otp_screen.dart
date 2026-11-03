import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:posterapp/core/database/BharatStorage.dart';
import 'package:posterapp/core/storage/app_dimensions.dart';
import 'package:posterapp/core/storage/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../dashboard/view/dashboard_screen.dart';
import '../../../resource/values/BharatStrings.dart';
import '../../../resource/values/Status.dart';
import '../../../resource/widgets/helper/DynamicButton.dart';
import '../../viewmodel/login_view_model.dart';
import '../onboarding_screen/onboarding_page.dart';

class  OtpPage extends StatelessWidget  {
  final String otp;
  final LoginViewModel loginCtr = Get.put(LoginViewModel());

  OtpPage({Key? key, required this.otp});

  final activePinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(fontSize: 22, color: Colors.black),
      decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor,
            width: 2,
          )));
  final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ));
  @override
  Widget build(BuildContext context) {
    loginCtr.otpCtr.value.text = otp;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpacing.height(10),

              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                ],
              ),

              AppSpacing.height(10),

              Text(
                "OTP Verification",
                style: TextStyle(
                    fontSize: AppDimensions.fontSize24,
                    fontWeight: AppDimensions.fontWeight600),
              ),

              AppSpacing.height(20),

              Text(
                "We have sent a verification code\nto +91 ${BharatStorage.getnumber().toString()}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppDimensions.fontSize14,
                  color: AppColors.black.withValues(alpha: 0.3),
                ),
              ),

              AppSpacing.height(40),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Pinput(
                  controller: loginCtr.otpCtr.value,
                  length: 6,
                  defaultPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Otp";
                    } else if (value.length < 6) {
                      return "Enter Valid Otp";
                    }
                    return null;
                  },
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                  ],
                  focusedPinTheme: activePinTheme.copyWith(
                    decoration: activePinTheme.decoration!.copyWith(
                      border: Border.all(
                        width: 1,
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  onCompleted: (pin) => debugPrint(pin),
                ),
              ),

              const Spacer(),
              Obx(
                    () {
                  switch (loginCtr.rxOtpRequestStatus.value) {
                    case Status.initial:
                      return Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: DynamicButton(
                          backgroundColor: AppColors.primaryColor,
                          text: "otp".tr,
                          height: 45,
                          onTap: () {
                            if (loginCtr.otpCtr.value.text.isNotEmpty &&
                                loginCtr.otpCtr.value.text.length == 6 ) {
                              loginCtr.otp();
                            }
                            else {
                              Fluttertoast.showToast(
                                msg: 'Invalid Otp',textColor: AppColors.primaryColor,
                                backgroundColor: Colors.white,
                              ).then((value) => loginCtr.setOtpRxRequestStatus(Status.initial));
                            }

                            BharatStrings.facebookAppEvents.logEvent(
                              name: 'OTP_button_clicked',
                              parameters: {
                                'button_id': loginCtr.mobileCtr.value.text,
                              },
                            );
                          },
                        ),
                      );
                    case Status.loading:
                      return  Center(
                        child: CircularProgressIndicator(color: AppColors.primaryColor,),
                      );
                    case Status.completed:
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (loginCtr.otpModel!.isOnboarded == true) {
                          Get.offAll(()=>const DashboardScreen());
                        } else {
                          Get.offAll(()=>const OnboardingPage());
                        }

                        BharatStrings.facebookAppEvents.logEvent(
                          name: 'OTP_Verify_Successfully',
                          parameters: {
                            'button_id': loginCtr.mobileCtr.value.text,
                          },
                        );
                      });

                      break;
                    case Status.error:
                      Fluttertoast.showToast(
                        msg: 'Invalid Otp',
                        backgroundColor: Colors.white,
                      ).then((value) => loginCtr.setOtpRxRequestStatus(Status.initial));
                      break;
                  }
                  return const SizedBox();
                },
              ),

              AppSpacing.height(30),

              // Text(
              //   "Didn't receive OTP?",
              //   style: TextStyle(
              //     fontSize: AppDimensions.fontSize24,
              //   ),
              // ),
              AppSpacing.height(20),
            ],
          ),
        ),
      ),
    );
  }
}

