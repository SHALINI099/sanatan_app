import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posterapp/content/privacy_policy.dart';
import 'package:posterapp/core/storage/app_spacing.dart';
import 'package:posterapp/myProfile/view/subscription_cancel.dart';
import 'package:posterapp/core/database/BharatStorage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../content/refund_screen.dart';
import '../../content/terms_condition.dart';
import '../../core/storage/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../dashboard/viewmodel/dashboard_view_model.dart';
import '../../language/view/language_page.dart';
import '../../login/view/login_screen/login_screen.dart';
import '../../resource/values/DownloadShare.dart';
import '../viewmodel/invoice_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final InvoiceController invoiceViewModel = Get.put(InvoiceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
        ),
        title: Text(
          'Settings'.tr,
          style: AppDimensions.inter(
            fontSize: AppDimensions.fontSize18,
            fontWeight: AppDimensions.fontWeight600,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          _sectionLabel('Support'.tr),
          _card([
            _settingsTile(
              icon: Icons.headset_mic_outlined,
              title: 'contacts'.tr,
              subtitle: 'decontact'.tr,
              onTap: _openSupportMail,
            ),
          ]),
          AppSpacing.height(18),
          _sectionLabel('Preferences'.tr),
          _card([
            _settingsTile(
              icon: Icons.g_translate_rounded,
              title: 'languageChange'.tr,
              subtitle: 'deLanguage'.tr,
              onTap: _openLanguageSheet,
            ),
          ]),
          AppSpacing.height(18),
          _sectionLabel('Account'.tr),
          _card([
            _settingsTile(
              icon: Icons.cancel_schedule_send_outlined,
              title: 'Membership Cancellation'.tr,
              subtitle: 'Manage or cancel your active plan anytime.'.tr,
              onTap: () => Get.to(() => const SubscriptionCancel()),
            ),
            const _TileDivider(),
            _settingsTile(
              icon: Icons.logout_rounded,
              title: 'logout'.tr,
              subtitle: 'deLogout'.tr,
              iconBg: Colors.red.shade50,
              iconColor: Colors.red.shade400,
              onTap: () => showAlertDialog(context),
            ),
          ]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legalLink('Privacy Policy', () => Get.to(() => const PrivacyAndPolicy())),
              _legalDot(),
              _legalLink('Refund', () => Get.to(() => const RefundPolicy())),
              _legalDot(),
              _legalLink('Terms', () => Get.to(() => const TermsAndCondition())),
            ],
          ),
        ),
      ),
    );
  }

  void _openSupportMail() {
    const message = 'If you have made the payment and your subscription is not active please share the following details in the mail -\n'
        '1. Your Registered mobile number.\n'
        '2. SMS details of the amount deducted from your bank.\n'
        '3. Screenshot of the transaction made through your UPI application.\n'
        '4. Transaction ID / Number.';
    final url = Uri(
      scheme: 'mailto',
      path: 'help.postersapp@gmail.com',
      query: 'subject={Om shanti  ${BharatStorage.getnumber()}&body=$message',
    );
    launchUrl(url);
  }

  void _openLanguageSheet() {
    Get.bottomSheet(
      FractionallySizedBox(
        heightFactor: 0.8,
        child: LanguagePage(),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
      child: Text(
        text,
        style: AppDimensions.inter(
          fontSize: AppDimensions.fontSize12,
          fontWeight: AppDimensions.fontWeight600,
          color: AppColors.grey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconBg,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: iconBg ?? AppColors.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryColor,
                  size: 20,
                ),
              ),
              AppSpacing.width(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppDimensions.inter(
                        fontSize: AppDimensions.fontSize15,
                        fontWeight: AppDimensions.fontWeight600,
                        color: AppColors.black,
                      ),
                    ),
                    AppSpacing.height(2),
                    Text(
                      subtitle,
                      style: AppDimensions.inter(
                        fontSize: AppDimensions.fontSize12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legalLink(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          text,
          style: AppDimensions.inter(
            fontSize: AppDimensions.fontSize12,
            fontWeight: AppDimensions.fontWeight500,
            color: AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _legalDot() {
    return Container(
      height: 3,
      width: 3,
      decoration: const BoxDecoration(
        color: AppColors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("logout".tr),
          content: Text("logoutApp".tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("cancel".tr),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final DashboardViewModel dashCtr =
                    Get.put(DashboardViewModel());
                dashCtr.updateIndex(0);
                dashCtr.selectedIndex.value = 0;
                await BharatStorage.eraseAllData();
                Get.offAll(const LoginScreen());
              },
              child: Text("ok".tr),
            ),
          ],
        );
      },
    );
  }

  void languageShowDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text('language'.tr),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dashCtr.laguageList.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        var langCode =
                            dashCtr.laguageList[index].languageCode;
                        Get.updateLocale(Locale(langCode, ''));
                        BharatStorage.setLanguage(langCode);
                        dashCtr.getTag();
                        dashCtr.fetchCards('', '');
                        Get.back();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: SizedBox(
                          height: 35,
                          width: Get.width,
                          child: Text(dashCtr.laguageList[index].language),
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                      height: 15,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 68, right: 14),
      child: Container(height: 1, color: Colors.grey.shade200),
    );
  }
}