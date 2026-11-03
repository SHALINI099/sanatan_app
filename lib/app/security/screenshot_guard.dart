import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';

/// Blocks screenshots and screen recording of the app's content.
abstract final class ScreenshotGuard {
  /// Disables capture. Failures are logged, never thrown, because a missing
  /// platform implementation must not take the whole app down.
  static Future<void> disable() async {
    try {
      final disabled = await NoScreenshot.instance.screenshotOff();
      debugPrint('ScreenshotGuard: capture disabled = $disabled');
    } on PlatformException catch (error) {
      debugPrint(
          'ScreenshotGuard: failed to disable capture: ${error.message}');
    }
  }
}
