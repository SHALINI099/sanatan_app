import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../dashboard/viewmodel/dashboard_view_model.dart';
import '../../../myProfile/viewmodel/my_profile_view_model.dart';

class DynamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final MyProfileViewModel profileCtr;
  final bool isSubscribed;

  DynamicAppBar({
    super.key,
    required this.isSubscribed,
    required this.profileCtr,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);
  final DashboardViewModel dashCtr = Get.put(DashboardViewModel());

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.9),
        ),
      ),
      titleSpacing: 0,
      leadingWidth: 40,
      leading: isSubscribed
          ? Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15, left: 0),
              child: Icon(
                Icons.workspace_premium,
                color: Colors.yellow.shade600,
                size: 30,
              ),
            )
          : const SizedBox.shrink(),
      title: const Text("Islamic Posters",
          style: TextStyle(fontSize: 25, color: Colors.white)),
    );
  }
}
