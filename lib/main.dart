import 'package:posterapp/app/app.dart';
import 'package:posterapp/app/bootstrap.dart';

/// Process entry point. All start-up work lives in [bootstrap] so this file
/// stays a one-liner and the launch sequence is testable in isolation.
Future<void> main() => bootstrap(() => const SanatanApp());
