import 'package:flutter/material.dart';

import '../core/storage/app_spacing.dart';
import '../core/theme/app_colors.dart';
import 'widgets/policy_widgets.dart';

class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({super.key});

  static const _intro =
      'Welcome to Om Shanti! These Terms of Use ("Terms") outline the rules and guidelines for your usage of our website and the Political Posters App mobile application ("Platform"), provided by Bharat Creatives & registered as Alnico Tech Private Limited ("Political Posters App," "Company," "we," "us," and "our"). By accessing and using the Platform, you agree to abide by these Terms. These Terms should be read alongside our Privacy Policy.';

  static const _sections = <PolicySection>[
    PolicySection(
      title: 'Modifications to Terms and Services',
      content:
          'Our Platform is dynamic and subject to rapid change. We may modify, discontinue, or add features at any time without prior notice. If any change requires your consent, we will request it. We encourage you to revisit this page often to stay updated.',
    ),
    PolicySection(
      title: 'Eligibility to Use Our Services',
      content:
          'You may use our Services only if you can form a binding contract and are legally permitted to do so. If acting on behalf of an organization, you confirm you have authority to bind it. You must ensure compliance with applicable laws.',
    ),
    PolicySection(
      title: 'Utilizing Our Services',
      content:
          'Our Platform is available in regional languages to create a community-based experience. You may share images, videos, and updates. To access our Services, you must register using your phone number and OTP. We do not access your device data without permission.',
    ),
    PolicySection(
      title: 'Cancellation and Refund Policy',
      content: 'Premium Plan: We offer monthly and annual plans.\n'
          'Recurring Subscription Fee: Access premium resources by subscribing.\n'
          '1.1 Cancellation Request: Email help.postersapp@gmail.com with your registered number.\n'
          '1.2 Membership Cancellation: Processed within 24 hours. Refunds will be issued within 7 working days.\n'
          '1.3 Non-refundable Payments: Prior payments cannot be refunded.\n'
          '1.4 Continuation of Benefits: Premium access continues till the end of the active period.\n'
          'Interpretation Clause: The company reserves final interpretation rights.\n'
          'Dispute Resolution: Governed by Indian law; Mumbai courts have jurisdiction.',
    ),
    PolicySection(
      title: 'Privacy Policy',
      content:
          'We collect data such as your phone number and name to provide Services. Additional data may be collected based on usage. Your information is securely stored on AWS, Google Cloud, and Digital Ocean. Our Privacy Policy explains data collection, usage, storage, and your rights.',
    ),
    PolicySection(
      title: 'Your Commitments',
      content: '• Use your real name and provide accurate information.\n'
          '• Keep your device secure.\n'
          '• You are responsible for all content you post.\n'
          '• Follow all applicable laws and refrain from harmful content.',
    ),
    PolicySection(
      title: 'Content Rights and Liabilities',
      content:
          'You retain ownership of the content you post. By posting, you grant us a license to use it within our Services. We do not claim ownership but may use it according to our Terms and Privacy Policy.',
    ),
    PolicySection(
      title: 'Intermediary Status and No Liability',
      content:
          'We act as an intermediary under Indian law. We do not control user content and are not liable for users\' actions. Our responsibility is limited as per applicable laws.',
    ),
    PolicySection(
      title: 'Dispute Resolution',
      content:
          'All disputes are governed by Indian law and fall under the exclusive jurisdiction of the courts of Mumbai.',
    ),
    PolicySection(
      title: 'Grievance Officer',
      content:
          'We have appointed a Grievance Officer to address safety, privacy, and platform usage concerns promptly.',
    ),
    PolicySection(
      title: 'Limitation of Liability',
      content:
          'We are not liable for losses arising from inaccuracies, service interruptions, or incompleteness of information. Services are provided "as is" without warranties.',
    ),
    PolicySection(
      title: 'Indemnification',
      content:
          'You agree to indemnify us against any claims or damages arising from your use of the Platform.',
    ),
    PolicySection(
      title: 'Unsolicited Material',
      content:
          'We welcome suggestions, but cannot guarantee confidentiality or compensation for submitted ideas.',
    ),
    PolicySection(
      title: 'General',
      content:
          'If any part of these Terms is unenforceable, the remaining sections remain valid. Amendments require written approval. Failure to enforce rights does not constitute a waiver.',
    ),
    PolicySection(
      title: 'Need Help?',
      content:
          'For further assistance or clarification, contact us at help.postersapp@gmail.com.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: policyAppBar('Terms & Conditions'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const PolicyHero(
            icon: Icons.gavel_rounded,
            title: 'Om shanti App Terms of Use',
            intro: _intro,
          ),
          AppSpacing.height(16),
          ..._sections.map((s) => PolicyCard(section: s)),
        ],
      ),
    );
  }
}