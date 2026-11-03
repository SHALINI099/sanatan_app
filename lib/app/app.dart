import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:posterapp/app/app_globals.dart';
import 'package:posterapp/app/security/screenshot_guard.dart';
import 'package:posterapp/app/theme/app_theme.dart';
import 'package:posterapp/resource/functions/InternetHandler/ConnectivityBinding.dart';
import 'package:posterapp/resource/values/languages/Languages.dart';
import 'package:posterapp/splash/view/splash_screen.dart';

/// Root widget: owns the navigator, theme, translations and global overlays.
class SanatanApp extends StatefulWidget {
  const SanatanApp({super.key});

  @override
  State<SanatanApp> createState() => _SanatanAppState();
}

class _SanatanAppState extends State<SanatanApp> {
  @override
  void initState() {
    super.initState();
    // Needs an attached Activity, which is why it runs from the widget tree
    // rather than from bootstrap.
    ScreenshotGuard.disable();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Om Shanti',
      debugShowCheckedModeBanner: false,
      initialBinding: ControllerBinding(),
      navigatorObservers: [routeObserver],
      builder: EasyLoading.init(),
      locale: const Locale('en', 'US'),
      translations: Languages(),
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
