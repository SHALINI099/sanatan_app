import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/storage/app_dimensions.dart';
import '../../core/storage/app_spacing.dart';
import '../../core/theme/app_colors.dart';

class SubscriptionCancel extends StatelessWidget {
  const SubscriptionCancel({super.key});

  static const _guides = <_AppGuide>[
    _AppGuide(
      name: 'Amazon Pay',
      color: Color(0xFFFF9900),
      icon: Icons.shopping_bag_rounded,
      steps: [
        'Open the Amazon app or go to https://www.amazon.in.',
        'Tap on the ☰ Menu (top left) → Your Account.',
        'Scroll to Amazon Pay → tap Amazon Pay UPI.',
        'Tap Manage Autopay or Manage Mandates.',
        'You’ll see all your active mandates.',
        'Select the one you wish to cancel.',
        'Tap Cancel Autopay or Revoke Authorization.',
        'Confirm the cancellation.',
        'You’ll get a confirmation message or email from Amazon Pay/Bank.',
      ],
    ),
    _AppGuide(
      name: 'Paytm',
      color: Color(0xFF00BAF2),
      icon: Icons.account_balance_wallet_rounded,
      steps: [
        'Open the Paytm app.',
        'Tap on your profile icon (top left corner).',
        'Go to Payment Settings → Automatic Payments & Subscriptions.',
        'You’ll see all active autopay subscriptions (like OTT, bills, etc.).',
        'Tap on the service you want to stop.',
        'Select Cancel Autopay or Deactivate Mandate.',
        'Confirm the cancellation.',
        'You’ll receive an SMS/email confirmation from Paytm and your bank.',
      ],
    ),
    _AppGuide(
      name: 'Google Pay (GPay)',
      color: Color(0xFF34A853),
      icon: Icons.payments_rounded,
      steps: [
        'Open the Google Pay app.',
        'Tap on your profile picture (top right).',
        'Go to Autopay / Mandates (under UPI options).',
        'Tap on the specific autopay you want to cancel.',
        'Select Cancel Autopay or Revoke Mandate.',
        'Confirm the cancellation.',
        'A confirmation will appear and you’ll receive a notification/email from your bank.',
      ],
    ),
    _AppGuide(
      name: 'PhonePe',
      color: Color(0xFF5F259F),
      icon: Icons.phone_android_rounded,
      steps: [
        'Open the PhonePe app.',
        'Tap on the Profile icon (top right).',
        'Select AutoPay or Mandates.',
        'You’ll see a list of all your active autopay authorizations.',
        'Choose the one you want to cancel.',
        'Tap Cancel Autopay or Revoke Mandate.',
        'Confirm when prompted.',
        'You’ll get a success message — the mandate will be disabled.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
        ),
        title: Text(
          'Subscription Cancel'.tr,
          style: AppDimensions.inter(
            fontSize: AppDimensions.fontSize18,
            fontWeight: AppDimensions.fontWeight600,
            color: AppColors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildIntro(),
          AppSpacing.height(18),
          ..._guides.map(_buildGuideCard),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryColor,
          ),
          AppSpacing.width(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to cancel Autopay / Auto-Debit',
                  style: AppDimensions.inter(
                    fontSize: AppDimensions.fontSize15,
                    fontWeight: AppDimensions.fontWeight600,
                    color: AppColors.black,
                  ),
                ),
                AppSpacing.height(4),
                Text(
                  'Follow the steps for the payment app you used to subscribe.',
                  style: AppDimensions.inter(
                    fontSize: AppDimensions.fontSize12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(_AppGuide guide) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: guide.color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: guide.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      guide.icon,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  AppSpacing.width(12),
                  Expanded(
                    child: Text(
                      guide.name,
                      style: AppDimensions.inter(
                        fontSize: AppDimensions.fontSize16,
                        fontWeight: AppDimensions.fontWeight600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(guide.steps.length, (i) {
                  return _buildStep(i + 1, guide.steps[i], guide.color);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index, String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 22,
            width: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$index',
              style: AppDimensions.inter(
                fontSize: AppDimensions.fontSize12,
                fontWeight: AppDimensions.fontWeight600,
                color: accent,
              ),
            ),
          ),
          AppSpacing.width(10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: AppDimensions.inter(
                  fontSize: AppDimensions.fontSize13,
                  fontWeight: AppDimensions.fontWeight400,
                  color: AppColors.black,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppGuide {
  final String name;
  final Color color;
  final IconData icon;
  final List<String> steps;

  const _AppGuide({
    required this.name,
    required this.color,
    required this.icon,
    required this.steps,
  });
}