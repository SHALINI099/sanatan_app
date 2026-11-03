import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:posterapp/core/storage/app_dimensions.dart';
import 'package:posterapp/core/storage/app_spacing.dart';
import 'package:posterapp/core/theme/app_colors.dart';

import 'package:posterapp/resource/widgets/helper/DynamicButton.dart';
import 'package:posterapp/resource/widgets/helper/DynamicTextfield.dart';
import '../../../dashboard/view/dashboard_screen.dart';
import '../../../resource/values/BharatDimension.dart';

import '../../../resource/values/Status.dart';
import '../../viewmodel/login_view_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final formKey = GlobalKey<FormState>();
  final LoginViewModel loginCtr = Get.put(LoginViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your full Name",
              style: TextStyle(
                  fontSize: AppDimensions.fontSize16,
                  fontWeight: AppDimensions.fontWeight600,
                  color: AppColors.grey.withValues(alpha: 0.8)),
            ).paddingSymmetric(vertical: 20, horizontal: 20),
            Form(
              key: formKey,
              child: DynamicTextfield(
                labelText: 'name'.tr,
                labelStyle: BharatDimension.fontFamily(
                    color: AppColors.black, fontSize: AppDimensions.fontSize12),
                filled: true,
                isDense: true,
                fillColor: const Color(0xFFF4F5F8),
                controller: loginCtr.nameCtr.value,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Name";
                  }
                },
                isGreyBorder: true,
              ).paddingSymmetric(
                horizontal: 20,
              ),
            ),
            Spacer(),
            Obx(
              () {
                switch (loginCtr.rxOnboardRequestStatus.value) {
                  case Status.initial:
                    return DynamicButton(
                      text: 'save'.tr,
                      height: 50,
                      radius: true,
                      backgroundColor: AppColors.primaryColor,
                      onTap: () {

                        if (formKey.currentState!.validate() &&
                            loginCtr.nameCtr.value.text.isNotEmpty) {


                          loginCtr.verifyUser();
                          Future.delayed(const Duration(milliseconds: 100));
                        }  else {
                          Fluttertoast.showToast(
                              msg: "Enter Name here",
                              backgroundColor: AppColors.primaryColor,
                              gravity: ToastGravity.TOP);
                        }
                      },
                    ).paddingSymmetric(horizontal: 15);
                  case Status.loading:
                    return Center(
                        child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ));
                  case Status.completed:
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (loginCtr.onboardingModel!.onboarding == true) {

                        Get.offAll(() => const DashboardScreen());
                      } else {
                        Get.offAll(() => const OnboardingPage());
                      }
                    });
                    break;
                  case Status.error:
                    EasyLoading.showError(loginCtr.onboardApiError.value).then(
                        (value) =>
                        loginCtr.rxLoginRequestStatus.value = Status.loading);
                    break;
                }
                return const SizedBox();
              },
            ),
            AppSpacing.height(30,)
          ],
        ),
      ),
    );
  }
}
