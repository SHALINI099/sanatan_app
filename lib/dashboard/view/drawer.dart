import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posterapp/myProfile/viewmodel/my_profile_view_model.dart';

import '../../core/storage/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../myProfile/view/edit_profile_screen.dart';
import '../../myProfile/view/settings_screen.dart';
import '../../resource/functions/LogOut.dart';

class BuildDrawer extends StatelessWidget {
  final MyProfileViewModel profileCtr;

  const BuildDrawer({super.key, required this.profileCtr});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bgColor,
      child: SafeArea(
        child: Column(
          children: [
            AppSpacing.height(20),

            /// USER PROFILE HEADER
            Obx(() {
              final imgUrl = profileCtr.avatar.value;
              return Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orange.shade100,
                    backgroundImage:
                        imgUrl.isNotEmpty ? NetworkImage(imgUrl) : null,
                    child: imgUrl.isEmpty
                        ? const Icon(Icons.person,
                            size: 40, color: Colors.orange)
                        : null,
                  ),
                  AppSpacing.height(12),
                  Text(
                    profileCtr.nameCtr.value.text.isEmpty
                        ? "User"
                        : profileCtr.nameCtr.value.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ).paddingSymmetric(horizontal: 10),
                ],
              );
            }),

            AppSpacing.height(20),
            const Divider(),

            /// MENU ITEMS

            ListTile(
              leading: const Icon(Icons.edit, color: Colors.teal),
              title: const Text("Edit Profile"),
              onTap: () {
                Get.back();
                Get.to(() => const EditProfile());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text("Settings"),
              onTap: () {
                Get.back();
                Get.to(() => const SettingsScreen());
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                logOutUser(true);
              },
            ),
            AppSpacing.height(16),
          ],
        ),
      ),
    );
  }
}
