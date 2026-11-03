import 'dart:developer';

import 'package:get/get.dart';
import 'package:posterapp/core/network/dio_client.dart';

import '../../core/database/BharatStorage.dart';
import '../../resource/functions/LogOut.dart';
import '../../resource/values/Status.dart';
import '../data/api/alarm_api.dart';
import '../data/model/AlarmListModel.dart';

class AlarmViewModel extends GetxController {
  final api = AlarmApi(buildDio());

  /// API status
  final rxAlarmRequestStatus = Status.initial.obs;

  /// Why the last load failed, shown on the error state.
  final errorMessage = ''.obs;

  /// Reactive model (nullable)
  var alarmListModel = Rxn<AlarmListModel>();

  /// Guards against overlapping fetches.
  bool _inFlight = false;

  @override
  void onInit() {
    super.onInit();
    getAlarmList();
  }

  void setAlarmList(Status value) {
    if (isClosed) return;
    rxAlarmRequestStatus.value = value;
  }

  void handleError(String code, String message,
      {Object? error, StackTrace? stack}) {
    log('[AlarmViewModel] $code: $message', error: error, stackTrace: stack);
    if (isClosed) return;
    errorMessage.value = message;
    setAlarmList(Status.error);
  }

  Future<void> getAlarmList() async {
    if (_inFlight) return;
    _inFlight = true;

    setAlarmList(Status.loading);
    errorMessage.value = '';

    try {
      String? token = BharatStorage.getAuthKey();

      if (token == null || token.isEmpty) {
        logOutUser(false);
        return;
      }

      final language = BharatStorage.getLanguage() ?? 'en';

      final res = await api.getAlarm('Bearer $token', language, '0');

      if (res.response.statusCode == 200) {
        final body = res.data;
        if (body is! Map<String, dynamic>) {
          handleError('ParseError', 'Unexpected response: ${body.runtimeType}');
          return;
        }

        if (isClosed) return;
        alarmListModel.value = AlarmListModel.fromJson(body);
        setAlarmList(Status.completed);
      } else if (res.response.statusCode == 401) {
        handleError('401', 'unauthorizedUser'.tr);
        logOutUser(false);
      } else {
        handleError(
          '${res.response.statusCode}',
          res.response.statusMessage ?? 'Request failed',
        );
      }
    } catch (error, stack) {
      handleError('Exception', error.toString(), error: error, stack: stack);
    } finally {
      _inFlight = false;
    }
  }
}
