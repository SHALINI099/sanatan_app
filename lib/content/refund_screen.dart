import 'package:flutter/material.dart';

import '../core/storage/app_spacing.dart';
import '../core/theme/app_colors.dart';
import 'widgets/policy_widgets.dart';

class RefundPolicy extends StatelessWidget {
  const RefundPolicy({super.key});

  static const _intro =
      'Everything you need to know about our premium plans, cancellations and refunds at Om Shanti App.';

  static const _sections = <PolicySection>[
    PolicySection(
      title: 'Insights on Cancellation and Refund',
      content:
          'At Om Shanti App, we offer a premium plan for accessing our latest templates, with options for monthly or annual payment. By selecting a plan and agreeing to pay the premium fee, you gain access to these exclusive templates.',
    ),
    PolicySection(
      title: 'Cancellation Process',
      content:
          'To cancel your subscription, email help.postersapp@gmail.com with your registered mobile number or email ID. We process cancellation requests within 24 hours. Refund will be credited within 7 working days after processing.',
    ),
    PolicySection(
      title: 'Refund Policy',
      content:
          'Payments made before cancellation are non-refundable. Subscriptions renew automatically unless canceled at least 24 hours before the current period ends.',
    ),
    PolicySection(
      title: 'Continued Benefits',
      content:
          'Even after cancellation, you will retain premium access until the end of the billing period already paid for.',
    ),
    PolicySection(
      title: 'Dispute Resolution',
      content:
          'All disputes are governed by the laws of the Republic of India. The courts of Mumbai will have exclusive jurisdiction.',
    ),
    PolicySection(
      title: 'Final Interpretation',
      content:
          'Where multiple interpretations of the terms exist, the company reserves the right to provide the final binding interpretation.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: policyAppBar('Refund Policy'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const PolicyHero(
            icon: Icons.receipt_long_rounded,
            title: 'Pricing, Cancellations & Refunds',
            intro: _intro,
          ),
          AppSpacing.height(16),
          ..._sections.map((s) => PolicyCard(section: s)),
        ],
      ),
    );
  }
}