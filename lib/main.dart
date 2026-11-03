import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:posterapp/my_http_overrides.dart';
import 'package:posterapp/resource/functions/InternetHandler/ConnectivityBinding.dart';
import 'package:posterapp/resource/values/languages/Languages.dart';
import 'package:posterapp/splash/view/splash_screen.dart';

/// Language code sent with localised API requests.
///
/// Defaults to Hindi and is overwritten by the dashboard once the persisted
/// language preference has been read.
String appLocale = 'hi';

/// Shared navigator observer for widgets that implement [RouteAware].
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

/// Handles FCM messages that arrive while the app is backgrounded or killed.
///
/// Runs in a separate isolate, so it must remain a top-level function and be
/// marked as a VM entry point or tree shaking will drop it in release builds.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Background notifications are display-only; nothing to process yet.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initialiseServices();
  await _configureSystemChrome();
  _configureEasyLoading();

  // Keep anything that can show a system dialog or wait on the network out of
  // this path. Until the first frame is drawn the Activity has no focusable
  // window, and every tap during that gap is reported as "Input dispatching
  // timed out (No focused window)". The notification permission prompt and the
  // FCM topic subscription therefore live in the splash screen, after the
  // first frame has painted.
  runApp(const SanatanApp());
}

/// Boots the platform services the app depends on before the first frame.
Future<void> _initialiseServices() async {
  // Local storage and Firebase are independent, so initialise them together.
  await Future.wait<void>([
    GetStorage.init(),
    Firebase.initializeApp(),
  ]);

  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  HttpOverrides.global = PermissiveHttpOverrides();
}

/// Applies the app-wide system bars style and locks the app to portrait.
Future<void> _configureSystemChrome() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.grey,
      systemNavigationBarColor: Colors.black,
    ),
  );

  await Future.wait<void>([
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  ]);
}

/// Configures the global look and behaviour of [EasyLoading] overlays.
void _configureEasyLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..animationStyle = EasyLoadingAnimationStyle.scale
    ..loadingStyle = EasyLoadingStyle.light
    ..maskType = EasyLoadingMaskType.custom
    ..maskColor = Colors.black.withValues(alpha: 0.2)
    ..backgroundColor = Colors.black
    ..indicatorColor = Colors.white
    ..indicatorSize = 45
    ..progressColor = Colors.black
    ..radius = 10
    ..contentPadding = const EdgeInsets.all(16)
    ..textColor = Colors.black
    ..fontSize = 14
    ..textStyle = GoogleFonts.mukta(fontSize: 14, color: Colors.black)
    ..userInteractions = true
    ..dismissOnTap = true
    ..successWidget = const Icon(Icons.check_circle, color: Colors.green, size: 40)
    ..errorWidget = const Icon(Icons.error, color: Colors.red, size: 40)
    ..infoWidget = const Icon(Icons.info, color: Colors.blue, size: 40);
}

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
    _disableScreenshots();
  }

  /// Blocks screenshots and screen recording of the app's content.
  ///
  /// Requires an attached Activity, which is why it runs from the widget tree
  /// rather than from [main].
  Future<void> _disableScreenshots() async {
    try {
      final disabled = await NoScreenshot.instance.screenshotOff();
      debugPrint('Screenshot capture disabled: $disabled');
    } on PlatformException catch (error) {
      debugPrint('Failed to disable screenshot capture: ${error.message}');
    }
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
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: false,
      ),
      home: const SplashScreen(),
    );
  }
}
