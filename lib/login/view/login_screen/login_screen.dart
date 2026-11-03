import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:posterapp/content/privacy_policy.dart';
import 'package:posterapp/content/terms_condition.dart';
import 'package:posterapp/core/storage/app_images.dart';
import 'package:posterapp/core/theme/app_colors.dart';
import 'package:posterapp/login/view/otp_screen/otp_screen.dart';
import 'package:posterapp/login/viewmodel/login_view_model.dart';
import 'package:posterapp/resource/widgets/helper/DynamicButton.dart';

import '../../../core/storage/app_dimensions.dart';
import '../../../core/storage/app_spacing.dart';
import '../../../core/database/BharatStorage.dart';
import '../../../resource/values/Status.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginCtr = Get.put(LoginViewModel());
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// Logo + Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag, color: AppColors.primaryColor, size: 20),
                  AppSpacing.width(6),
                  Text(
                    "Om Shanti",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor),
                  ),
                ],
              ),

              AppSpacing.height(20),

              /// Center Image (Om Mandala)
              Expanded(
                child: Column(
                  children: [
                    Image.asset(
                      AppImages.appLogo,
                      height: 90,
                    ),

                    AppSpacing.height(10),

                    /// Dots Indicator

                    AppSpacing.height(20),

                    /// Tagline
                    Text(
                      "Chant with Faith,\nBegin with Peace.",
                      textAlign: TextAlign.center,
                      style: AppDimensions.inter(
                          fontSize: AppDimensions.fontSize20,
                          fontWeight: AppDimensions.fontWeight600,
                          color: AppColors.black),
                    ),

                    AppSpacing.height(20),

                    Text(
                      "Login",
                      style: TextStyle(
                          fontSize: AppDimensions.fontSize16,
                          fontWeight: AppDimensions.fontWeight500,
                          color: AppColors.black),
                    ),

                    AppSpacing.height(20),

                    /// Phone Input
                    Form(key: formKey, child: _phoneField()),

                    AppSpacing.height(20),

                    /// Terms Checkbox
                    ///
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "By proceeding, I agree to the  ",
                          style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.5),
                              fontSize: 12),
                        ),
                        InkWell(
                            child: Text(
                              "Terms",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: AppDimensions.fontWeight400,
                                color: AppColors.primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            onTap: () async {
                              Get.to(() => const TermsAndCondition());
                            }),
                        const Text(" & "),
                        InkWell(
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: AppDimensions.fontWeight400,
                              color: AppColors.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: () async {
                            Get.to(() => const PrivacyAndPolicy());
                          },
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 10),

                    const Spacer(),

                    Obx(
                      () {
                        switch (loginCtr.rxLoginRequestStatus.value) {
                          case Status.initial:
                            return DynamicButton(
                              onTap: loginCtr.isAccepted.isTrue
                                  ? () async {
                                      if (formKey.currentState!.validate() &&
                                          loginCtr.mobileCtr.value.text
                                                  .length ==
                                              10) {
                                        await loginCtr.login(
                                          mobileNumber:
                                              loginCtr.mobileCtr.value.text,
                                        );
                                        await BharatStorage.setnumber(
                                            loginCtr.mobileCtr.value.text);
                                      } else if (loginCtr
                                          .mobileCtr.value.text.isEmpty) {
                                        Fluttertoast.showToast(
                                            msg: "Enter mobile Number",
                                            backgroundColor: AppColors.white,
                                            textColor: AppColors.primaryColor,
                                            gravity: ToastGravity.CENTER);
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Enter mobile Number",
                                            backgroundColor: AppColors.white,
                                            textColor: AppColors.primaryColor,
                                            gravity: ToastGravity.CENTER);
                                      }
                                    }
                                  : null,
                              text: "Login",
                              height: 50,
                              backgroundColor: AppColors.primaryColor
                                  .withValues(alpha: 0.4),
                              color: AppColors.black,
                              radius: true,
                            );
                          case Status.loading:
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            );

                          case Status.completed:
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              Get.to(() => OtpPage(
                                otp: loginCtr.loginModel?.otp
                                    .toString() ??
                                    '',
                              ))
                                  ?.then((value) => loginCtr
                                  .setLoginRxRequestStatus(Status.initial));
                            });
                            break;
                          case Status.error:
                            Get.snackbar(
                              'Login Failed',
                              loginCtr.loginApiError.value,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            loginCtr.setLoginRxRequestStatus(Status.initial);
                            break;
                        }
                        return Container();
                      },
                    ),

                    /// Login Button

                    AppSpacing.height(20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dot indicator widget
  // Widget _dot(bool active) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 4),
  //     width: active ? 8 : 6,
  //     height: active ? 8 : 6,
  //     decoration: BoxDecoration(
  //       color: active ? AppColors.grey : AppColors.grey.withValues(alpha: 0.2),
  //       shape: BoxShape.circle,
  //     ),
  //   );
  // }

  /// Phone Input Field
  Widget _phoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3EA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text(
            "🇮🇳 +91",
            style: TextStyle(fontSize: 14),
          ),
          AppSpacing.width(10),
          Expanded(
            child: TextField(
              controller: loginCtr.mobileCtr.value,
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.allow(RegExp(r'^[5-9][0-9]{0,9}$')),
              ],
              decoration: const InputDecoration(
                hintText: "Enter your number",
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (value.length == 10) {
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
