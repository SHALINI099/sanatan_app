import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/storage/app_dimensions.dart';
import '../../core/storage/app_spacing.dart';
import '../../core/theme/app_colors.dart';

class PolicySection {
  final String title;
  final String content;

  const PolicySection({required this.title, required this.content});
}

PreferredSizeWidget policyAppBar(String title) {
  return AppBar(
    backgroundColor: AppColors.bgColor,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      onPressed: Get.back,
      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
    ),
    title: Text(
      title,
      style: AppDimensions.inter(
        fontSize: AppDimensions.fontSize18,
        fontWeight: AppDimensions.fontWeight600,
        color: AppColors.black,
      ),
    ),
  );
}

class PolicyHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String intro;

  const PolicyHero({
    super.key,
    required this.icon,
    required this.title,
    required this.intro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.9),
            AppColors.continueButton,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.white, size: 24),
              ),
              AppSpacing.width(12),
              Expanded(
                child: Text(
                  title,
                  style: AppDimensions.inter(
                    fontSize: AppDimensions.fontSize20,
                    fontWeight: AppDimensions.fontWeight700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.height(14),
          Text(
            intro,
            style: AppDimensions.inter(
              fontSize: AppDimensions.fontSize13,
              fontWeight: AppDimensions.fontWeight400,
              color: AppColors.white.withValues(alpha: 0.95),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class PolicyCard extends StatelessWidget {
  final PolicySection section;

  const PolicyCard({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                AppSpacing.width(10),
                Expanded(
                  child: Text(
                    section.title,
                    style: AppDimensions.inter(
                      fontSize: AppDimensions.fontSize16,
                      fontWeight: AppDimensions.fontWeight600,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.height(8),
          ],
          Text(
            section.content,
            style: AppDimensions.inter(
              fontSize: AppDimensions.fontSize13,
              fontWeight: AppDimensions.fontWeight400,
              color: AppColors.black,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}