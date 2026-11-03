import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/database/BharatStorage.dart';
import '../../core/storage/app_images.dart';
import '../../core/theme/app_colors.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../dashboard/viewmodel/dashboard_view_model.dart';
import '../../login/view/login_screen/login_screen.dart';
import '../../login/view/onboarding_screen/onboarding_page.dart';
import '../../myProfile/viewmodel/my_profile_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override


   _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  MyProfileViewModel profileCtr = Get.put(MyProfileViewModel());

  @override
  void initState() {
    Get.updateLocale(Locale(BharatStorage.getLanguage() ?? 'en', ''));
    BharatStorage.setLanguage('en' ?? 'hi');
    super.initState();
    _loadData();
  }

  /// Push setup is fire-and-forget. The permission prompt and the topic
  /// subscription (a network round trip) must never gate the first frame or
  /// navigation, so this is scheduled once the splash has painted and the
  /// window already has focus.
  Future<void> _setupMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      await messaging.subscribeToTopic('all');
    } catch (e) {}
  }

  Future<void> _loadData() async {
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMessaging();
    });

    final DashboardViewModel dashCtr = Get.put(DashboardViewModel());

    await Future.delayed(const Duration(seconds: 0));
    try {
      String? authToken = BharatStorage.getAuthKey();

      bool? isOnboarded = BharatStorage.getOnboarded();
      String? language = BharatStorage.getLanguage();
      if (language.isNull || language!.isEmpty) {
        BharatStorage.setLanguage('en');
      }

      if (authToken != null &&
          authToken.isNotEmpty &&
          isOnboarded != null &&
          isOnboarded == true) {
        if (BharatStorage.getSubscription() == true) {
          dashCtr.isSubsribed.value = true;
        } else {
          dashCtr.isSubsribed.value = false;
        }
        await Future.delayed(const Duration(seconds: 1))
            .then((value) => Get.off(() => const DashboardScreen()));
      } else if (authToken != null &&
          authToken.isNotEmpty &&
          isOnboarded == null &&
          isOnboarded == false) {
        await Future.delayed(const Duration(seconds: 1))
            .then((value) => Get.off(() => const OnboardingPage()));
      } else {
        if (isOnboarded == true) {
          await Future.delayed(const Duration(seconds: 1))
              .then((value) => Get.off(() => const DashboardScreen()));
        } else {
          await Future.delayed(const Duration(seconds: 1))
              .then((value) => Get.off(() => const LoginScreen()));
        }
      }
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bgColor,
      body: Center(
        child: Image.asset(AppImages.appLogo,height: 90,)
      )
    );
  }
}
