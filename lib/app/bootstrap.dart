import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:posterapp/app/config/easy_loading_config.dart';
import 'package:posterapp/app/config/system_chrome_config.dart';
import 'package:posterapp/app/messaging/background_message_handler.dart';
import 'package:posterapp/core/network/permissive_http_overrides.dart';

/// Builds the root widget once the platform is ready.
typedef AppBuilder = Widget Function();

/// Initialises platform services, installs global error handling and launches
/// the app built by [builder].
///
/// Everything here runs before the first frame, so it must be fast and must
/// never show a system dialog or wait on the network. Until Flutter paints,
/// the Android Activity has no focusable window and every tap in that gap is
/// reported as "Input dispatching timed out (No focused window)". Work that
/// needs user interaction, such as the notification permission prompt and the
/// FCM topic subscription, belongs in the splash screen after first paint.
Future<void> bootstrap(AppBuilder builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers();

  await _initialiseServices();
  await SystemChromeConfig.apply();
  EasyLoadingConfig.apply();

  runApp(builder());
}

/// Boots the platform services the app depends on before the first frame.
Future<void> _initialiseServices() async {
  // Local storage and Firebase do not depend on each other, so start both at
  // once instead of paying for them back to back.
  await Future.wait<void>([
    GetStorage.init(),
    Firebase.initializeApp(),
  ]);

  registerBackgroundMessageHandler();
  HttpOverrides.global = PermissiveHttpOverrides();
}

/// Routes every category of unhandled error through one reporting path.
///
/// [PlatformDispatcher.onError] catches asynchronous errors from the root
/// isolate, so no custom zone is needed. Framework errors are still surfaced
/// in debug builds via [FlutterError.presentError] so the red screen keeps
/// working during development.
void _installErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _reportUncaughtError(details.exception, details.stack ?? StackTrace.empty);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _reportUncaughtError(error, stack);
    return true;
  };
}

/// Single sink for uncaught errors. Swap the body for a crash reporter
/// (for example Crashlytics) without touching any call site.
void _reportUncaughtError(Object error, StackTrace stack) {
  developer.log(
    'Uncaught error',
    name: 'bootstrap',
    error: error,
    stackTrace: stack,
    level: 1000,
  );
}
