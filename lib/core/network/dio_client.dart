import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../resource/values/BharatStrings.dart';

/// Single place the app's Dio clients are built.
///
/// Every view model used to construct this same client inline. Without timeouts
/// a flaky network left a request hanging forever, which showed up as a screen
/// stuck on its loading spinner with no way to recover.
Dio buildDio() => Dio(
      BaseOptions(
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) => true,
      ),
    )..interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
          enabled: BharatStrings.isdebugEnable,
        ),
      );
