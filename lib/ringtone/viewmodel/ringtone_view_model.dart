import 'dart:developer';

import 'package:get/get.dart';
import 'package:posterapp/core/network/dio_client.dart';

import '../../core/database/BharatStorage.dart';
import '../../resource/functions/LogOut.dart';
import '../../resource/values/Status.dart';
import '../data/api/RingtoneApi.dart';
import '../data/model/RingtoneModel.dart';

class RingtoneViewModel extends GetxController {
  final api = RingtoneApi(buildDio());

  final rxringtoneRequestStatus = Status.initial.obs;

  /// Why the last load failed, shown on the error state.
  final errorMessage = ''.obs;

  Rxn<RingtoneModel> ringtoneModel = Rxn<RingtoneModel>();

  /// Guards against overlapping fetches.
  bool _inFlight = false;

  @override
  void onInit() {
    super.onInit();
    getRingtoneList();
  }

  void setRingtoneRxRequestStatus(Status value) {
    if (isClosed) return;
    rxringtoneRequestStatus(value);
  }

  void handleError(String code, String message,
      {Object? error, StackTrace? stack}) {
    log('[RingtoneViewModel] $code: $message', error: error, stackTrace: stack);
    if (isClosed) return;
    errorMessage.value = message;
    setRingtoneRxRequestStatus(Status.error);
  }

  Future<void> getRingtoneList() async {
    if (_inFlight) return;
    _inFlight = true;

    setRingtoneRxRequestStatus(Status.loading);
    errorMessage.value = '';

    try {
      final language = BharatStorage.getLanguage() ?? 'en';
      final token = BharatStorage.getAuthKey();

      if (token == null || token.isEmpty) {
        handleError('NoToken', 'Session expired, please log in again');
        logOutUser(false);
        return;
      }

      final res = await api.getRingtone("Bearer $token", language, '0');

      if (res.response.statusCode == 200) {
        final body = res.response.data;
        if (body is! Map<String, dynamic>) {
          handleError('ParseError', 'Unexpected response: ${body.runtimeType}');
          return;
        }

        if (isClosed) return;
        ringtoneModel.value = RingtoneModel.fromJson(body);
        setRingtoneRxRequestStatus(Status.completed);
      } else if (res.response.statusCode == 401) {
        handleError('401', 'unauthorizedUser'.tr);
        logOutUser(false);
      } else {
        handleError(
          '${res.response.statusCode}',
          res.response.statusMessage ?? 'Request failed',
        );
      }
    } catch (e, stack) {
      handleError('Exception', e.toString(), error: e, stack: stack);
    } finally {
      _inFlight = false;
    }
  }
}
