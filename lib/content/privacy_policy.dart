import 'package:flutter/material.dart';

import '../core/storage/app_spacing.dart';
import '../core/theme/app_colors.dart';
import 'widgets/policy_widgets.dart';

class PrivacyAndPolicy extends StatelessWidget {
  const PrivacyAndPolicy({super.key});

  static const _intro =
      "Om Shanti values your privacy and understands its significance to you. Your trust is paramount, and we're committed to safeguarding your privacy both online and offline. This Policy applies to all current and former users of our app and platform. By using our website and app, you consent to this Privacy Policy.";

  static const _sections = <PolicySection>[
    PolicySection(
      title: 'Protecting Your Data',
      content:
          "Rest assured, we do not disclose any of your personal information to third parties or individuals. Your data is rigorously safeguarded under the legal framework of data protection. Only under exceptional circumstances would we consider sharing information, such as in response to a court order or subpoena. And even then, your consent will always be sought beforehand.",
    ),
    PolicySection(
      title: 'Information Collection and Purpose',
      content:
          "When you engage with Om Shanti App, we may collect details like your name, email, phone number, and photograph to establish your profile. We may also request permission to upload various media formats for posting and messaging. Tracking tools like Google Analytics and Amplitude help us gather insights into app usage. You may also receive updates on promotions or new features. As a user, you have the right to access, rectify, and request deletion of your personal data.",
    ),
    PolicySection(
      title: 'Jurisdiction',
      content:
          "By visiting our website, you agree to abide by this Policy and the website's terms of use. Any privacy-related disputes are governed by the laws of India.",
    ),
    PolicySection(
      title: 'Get in Touch',
      content:
          "For inquiries regarding this Policy or other privacy matters, feel free to contact us at help.postersapp@gmail.com. We are here to assist you.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: policyAppBar('Privacy Policy'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          PolicyHero(
            icon: Icons.privacy_tip_rounded,
            title: 'Om shanti App Privacy Policy',
            intro: _intro,
          ),
          AppSpacing.height(16),
          ..._sections.map((s) => PolicyCard(section: s)),
        ],
      ),
    );
  }
}