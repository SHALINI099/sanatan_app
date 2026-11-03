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
import '../../myProfile/viewmodel/my_profile_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Minimum time the logo stays on screen before routing.
  static const Duration _splashHold = Duration(seconds: 1);

  static const String _defaultLanguage = 'en';

  /// Registered here so later `Get.find<MyProfileViewModel>()` calls resolve.
  final MyProfileViewModel profileCtr = Get.put(MyProfileViewModel());

  @override
  void initState() {
    super.initState();
    Get.updateLocale(
      Locale(BharatStorage.getLanguage() ?? _defaultLanguage, ''),
    );
    BharatStorage.setLanguage(_defaultLanguage);
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
    } catch (error) {
      // Push is optional; a denied permission or offline device must not
      // affect start-up.
      debugPrint('SplashScreen: messaging setup failed: $error');
    }
  }

  Future<void> _loadData() async {
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupMessaging());

    final DashboardViewModel dashCtr = Get.put(DashboardViewModel());

    try {
      final String? authToken = BharatStorage.getAuthKey();
      final bool isOnboarded = BharatStorage.getOnboarded() ?? false;
      final String? language = BharatStorage.getLanguage();

      if (language == null || language.isEmpty) {
        BharatStorage.setLanguage(_defaultLanguage);
      }

      final bool hasSession = authToken != null && authToken.isNotEmpty;
      if (hasSession && isOnboarded) {
        dashCtr.isSubsribed.value = BharatStorage.getSubscription() == true;
      }

      await Future.delayed(_splashHold);
      if (!mounted) return;

      Get.off(
        () => isOnboarded ? const DashboardScreen() : const LoginScreen(),
      );
    } catch (error) {
      // Storage reads are synchronous and local; a failure here means a
      // corrupt store. Fall through to the login screen rather than hang.
      debugPrint('SplashScreen: failed to resolve start route: $error');
      Get.off(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: Image.asset(AppImages.appLogo, height: 90),
      ),
    );
  }
}
