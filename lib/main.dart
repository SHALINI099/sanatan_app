//Har Har Mahadev
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:posterapp/resource/functions/InternetHandler/ConnectivityBinding.dart';
import 'package:posterapp/resource/functions/InternetHandler/ConnectivityController.dart';
import 'package:posterapp/resource/values/languages/Languages.dart';
import 'package:posterapp/splash/view/splash_screen.dart';
import 'my_http_overrides.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {

  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.grey,
      systemNavigationBarColor: Colors.black,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  HttpOverrides.global = MyHttpOverrides();

  // Nothing that can show a system dialog or wait on the network runs before
  // runApp. Until Flutter draws its first frame the Activity has no focusable
  // window, and every tap during that gap is reported as
  // "Input dispatching timed out (No focused window)". The notification
  // permission prompt and the FCM topic subscription live in the splash and
  // are started after the first frame has painted.
  runApp(const MyApp());

  configLoading();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..animationStyle = EasyLoadingAnimationStyle.scale
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..indicatorColor = Colors.white
    ..radius = 10.0
    ..progressColor = Colors.black
    ..backgroundColor = Colors.black // Set background color to black
    ..textColor = Colors.black
    ..fontSize = 14
    ..userInteractions = true
    ..dismissOnTap = true
    ..textStyle = GoogleFonts.mukta(
      fontSize: 14.0,
      color: Colors.black,
    )
    ..maskType = EasyLoadingMaskType.custom // Use custom mask type
    ..maskColor = Colors.black.withValues(alpha: 0.2)
    ..contentPadding = const EdgeInsets.all(16.0) // Add padding
    ..successWidget =
        const Icon(Icons.check_circle, color: Colors.green, size: 40.0)
    ..errorWidget = const Icon(Icons.error, color: Colors.red, size: 40.0)
    ..infoWidget = const Icon(Icons.info, color: Colors.blue, size: 40.0);
}

String appLocale = 'hi';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _noScreenshot = NoScreenshot.instance;

  void disableScreenshot() async {
    bool result = await _noScreenshot.screenshotOff();
    debugPrint('Screenshot Off: $result');
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    disableScreenshot();
    SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  final ConnectivityController controller = Get.put(ConnectivityController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Om Shanti',
        initialBinding: ControllerBinding(),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        builder: EasyLoading.init(),
        locale: const Locale('en', 'US'),
        translations: Languages(),
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: false,
        ),
        home: const SplashScreen()

        );
  }
}
