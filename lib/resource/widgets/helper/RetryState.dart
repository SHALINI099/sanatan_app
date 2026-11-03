import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../values/BharatDimension.dart';
import 'DynamicButton.dart';

/// Error / empty placeholder with a Retry action.
///
/// Mirrors [ErrorVertical], but takes a plain message and callback instead of
/// being hard-coupled to DashboardViewModel, so any screen can use it.
class RetryState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;
  final Color? iconColor;

  const RetryState({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final tint = iconColor ?? Colors.red.shade700;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: tint, size: 72),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: BharatDimension.fontFamily(color: tint),
            ),
            const SizedBox(height: 16),
            DynamicButton(
              text: "Retry".tr,
              leadingIcon: Icons.refresh,
              showLeading: true,
              width: Get.width * 0.38,
              height: Get.width * BharatDimension.buttonBDayHieght,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
