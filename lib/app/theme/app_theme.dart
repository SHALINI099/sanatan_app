import 'package:flutter/material.dart';

/// Central place for the app's [ThemeData] so screens never build their own.
abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    primarySwatch: Colors.orange,
    useMaterial3: false,
  );
}
