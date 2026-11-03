import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global look and behaviour of [EasyLoading] overlays.
abstract final class EasyLoadingConfig {
  static const double _indicatorSize = 45;
  static const double _cornerRadius = 10;
  static const double _fontSize = 14;
  static const double _statusIconSize = 40;
  static const double _maskOpacity = 0.2;

  /// Must run once before the first overlay is shown.
  static void apply() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..animationStyle = EasyLoadingAnimationStyle.scale
      ..loadingStyle = EasyLoadingStyle.light
      ..maskType = EasyLoadingMaskType.custom
      ..maskColor = Colors.black.withValues(alpha: _maskOpacity)
      ..backgroundColor = Colors.black
      ..indicatorColor = Colors.white
      ..indicatorSize = _indicatorSize
      ..progressColor = Colors.black
      ..radius = _cornerRadius
      ..contentPadding = const EdgeInsets.all(16)
      ..textColor = Colors.black
      ..fontSize = _fontSize
      ..textStyle = GoogleFonts.mukta(fontSize: _fontSize, color: Colors.black)
      ..userInteractions = true
      ..dismissOnTap = true
      ..successWidget = const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: _statusIconSize,
      )
      ..errorWidget = const Icon(
        Icons.error,
        color: Colors.red,
        size: _statusIconSize,
      )
      ..infoWidget = const Icon(
        Icons.info,
        color: Colors.blue,
        size: _statusIconSize,
      );
  }
}
