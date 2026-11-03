import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// System bars styling and orientation policy for the whole app.
abstract final class SystemChromeConfig {
  static const SystemUiOverlayStyle _overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.grey,
    systemNavigationBarColor: Colors.black,
  );

  static const List<DeviceOrientation> _orientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  /// Applies the overlay style, enables edge-to-edge and locks to portrait.
  static Future<void> apply() async {
    SystemChrome.setSystemUIOverlayStyle(_overlayStyle);

    await Future.wait<void>([
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
      SystemChrome.setPreferredOrientations(_orientations),
    ]);
  }
}
