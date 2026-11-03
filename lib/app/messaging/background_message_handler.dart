import 'package:firebase_messaging/firebase_messaging.dart';

/// Handles FCM messages that arrive while the app is backgrounded or killed.
///
/// Runs in a separate isolate, so it must remain a top-level function and be
/// marked as a VM entry point or tree shaking will drop it in release builds.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Background notifications are display-only; nothing to process yet.
}

/// Registers the background handler. Must be called before `runApp`.
void registerBackgroundMessageHandler() {
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
}
