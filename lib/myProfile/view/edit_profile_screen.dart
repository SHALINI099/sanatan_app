import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:posterapp/core/storage/app_spacing.dart';
import 'package:posterapp/resource/values/select_Image.dart';
import 'package:posterapp/resource/widgets/helper/DynamicButton.dart';

import '../../core/storage/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../dashboard/viewmodel/dashboard_view_model.dart';
import '../../resource/functions/InternetHandler/ConnectivityController.dart';
import '../../resource/functions/InternetHandler/ConnectivityWidget.dart';
import '../../resource/values/image_controller.dart';
import '../../resource/values/Status.dart';
import '../../resource/widgets/helper/DynamicTextfield.dart';
import '../viewmodel/my_profile_view_model.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final MyProfileViewModel profileCtr = Get.put(MyProfileViewModel());
  final DashboardViewModel dashCtr = Get.put(DashboardViewModel());
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await profileCtr.userData();
    final data = profileCtr.profileModel.value?.data;
    if (data != null) {
      profileCtr.nameCtr.value.text = data.name;
      profileCtr.mobileCtr.value.text = data.mobileNumber;
      profileCtr.addCtr.value.text = data.address ?? '';
      profileCtr.descCtr.value.text = data.description ?? '';
      profileCtr.fbCtr.value.text = data.fbId ?? '';
      profileCtr.instaCtr.value.text = data.instaId ?? '';
      profileCtr.twitterCtr.value.text = data.twiterId ?? '';
      profileCtr.avatar.value = data.avatar ?? '';
      profileCtr.nameCtr.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionController = Get.find<ConnectivityController>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Obx(() {
          final online = connectionController.connectionType ==
                  MConnectivityResult.wifi ||
              connectionController.connectionType == MConnectivityResult.mobile;

          if (!online) return const ConnectivityWidget();

          return Form(
            key: formKey,
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      InkWell(
                          onTap: () {
                            selectImage(context, imgCtr);
                          },
                          child: _buildAvatar()),
                      AppSpacing.height(20),
                      Obx(() => dashCtr.isSubsribed.isTrue
                          ? _buildPremiumBadge()
                          : const SizedBox.shrink()),
                      if (dashCtr.isSubsribed.isTrue) AppSpacing.height(16),
                      _buildSectionTitle("personalInfo".tr),
                      AppSpacing.height(10),
                      _buildFormCard(),
                      AppSpacing.height(28),
                      _buildSubmit(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          _circleIcon(
            icon: Icons.arrow_back_rounded,
            onTap: Get.back,
          ),
          Expanded(
            child: Center(
              child: Text(
                "myProfile".tr,
                style: AppDimensions.inter(
                  fontSize: AppDimensions.fontSize16,
                  fontWeight: AppDimensions.fontWeight600,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _circleIcon({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AppColors.black, size: 20),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Obx(() {
        final url = profileCtr.avatar.value;
        return Container(
          height: 112,
          width: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.7),
                AppColors.continueButton,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            padding: const EdgeInsets.all(3),
            child: ClipOval(
              child: url.isEmpty
                  ? Container(
                      color: Colors.orange.shade100,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                        size: 50,
                      ),
                    )
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.orange.shade100,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primaryColor,
                          size: 50,
                        ),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.yellow.shade100, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.yellow.shade700.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/king.png", height: 28),
          AppSpacing.width(10),
          Expanded(
            child: Text(
              "Congratulations, you are a Premium Member.",
              style: AppDimensions.inter(
                color: Colors.orange.shade800,
                fontSize: AppDimensions.fontSize13,
                fontWeight: AppDimensions.fontWeight600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: AppDimensions.inter(
          fontSize: AppDimensions.fontSize16,
          fontWeight: AppDimensions.fontWeight600,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Obx(
        () => DynamicTextfield(
          controller: profileCtr.nameCtr.value,
          fillColor: AppColors.bgColor.withValues(alpha: 0.5),
          filled: true,
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.primaryColor,
          ),
          labelStyle: AppDimensions.inter(
            fontSize: AppDimensions.fontSize14,
            color: AppColors.grey,
          ),
          labelText: "fname".tr,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          validator: (value) {
            if (value == null || value.isEmpty) return "Enter Name";
            if (value.trim().isEmpty) return 'Enter valid name';
            return null;
          },
          onChanged: (_) => profileCtr.nameCtr.refresh(),
          isGreyBorder: true,
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return Obx(() {
      switch (profileCtr.rxpostRequestStatus.value) {
        case Status.initial:
          return Center(
            child: DynamicButton(
              text: 'update'.tr,
              width: double.infinity,
              height: 50,
              radius: true,
              color: AppColors.white,
              fontSize: AppDimensions.fontSize16,
              backgroundColor: AppColors.primaryColor,
              onTap: _onUpdateTap,
            ),
          );
        case Status.loading:
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        case Status.completed:
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Get.back();
            EasyLoading.dismiss();
          });
          profileCtr.setpostRxRequestStatus(Status.initial);
          return const SizedBox();
        case Status.error:
          EasyLoading.showError(profileCtr.postApiError.value)
              .then((_) => profileCtr.setpostRxRequestStatus(Status.initial));
          return const SizedBox();
      }
    });
  }

  void _onUpdateTap() {
    if (!formKey.currentState!.validate()) return;
    final hasName = profileCtr.nameCtr.value.text.isNotEmpty;
    final hasImage = imgCtr.downloadURL.value.isNotEmpty;
    if (hasName || hasImage) {
      profileCtr.updateUser();
    }
  }
}
