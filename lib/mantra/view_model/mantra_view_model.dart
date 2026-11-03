import 'dart:developer';

import 'package:get/get.dart';
import 'package:posterapp/core/network/dio_client.dart';
import 'package:posterapp/mantra/data/model/MantraListModel.dart';
import '../../core/database/BharatStorage.dart';
import '../../resource/functions/LogOut.dart';
import '../../resource/values/Status.dart';
import '../data/api/MantraApi.dart';

class MantraViewModel extends GetxController {
  final api = MantraApi(buildDio());

  /// API status
  final rxMantraRequestStatus = Status.initial.obs;

  /// Why the last load failed, shown on the error state.
  final errorMessage = ''.obs;

  /// Reactive model (nullable)
  var mantraListModel = Rxn<MantraListModel>();

  /// Guards against overlapping fetches — the retry button and onInit can
  /// otherwise stack requests that race to write the status.
  bool _inFlight = false;

  void setMantraList(Status value) {
    if (isClosed) return;
    rxMantraRequestStatus.value = value;
  }

  /// Records the reason a load failed instead of discarding it. A swallowed
  /// exception here is what hid the Language-enum parse crash for so long.
  void handleError(String code, String message,
      {Object? error, StackTrace? stack}) {
    log('[MantraViewModel] $code: $message', error: error, stackTrace: stack);
    if (isClosed) return;
    errorMessage.value = message;
    setMantraList(Status.error);
  }

  @override
  void onInit() {
    super.onInit();
    getMantraList();
  }

  Future<void> getMantraList() async {
    if (_inFlight) return;
    _inFlight = true;

    setMantraList(Status.loading);
    errorMessage.value = '';

    try {
      String? token = BharatStorage.getAuthKey();

      if (token == null || token.isEmpty) {
        logOutUser(false);
        return;
      }

      final language = BharatStorage.getLanguage() ?? 'en';

      final res = await api.getMantra('Bearer $token', language, '0');

      if (res.response.statusCode == 200) {
        final body = res.data;
        if (body is! Map<String, dynamic>) {
          handleError('ParseError', 'Unexpected response: ${body.runtimeType}');
          return;
        }

        if (isClosed) return;
        mantraListModel.value = MantraListModel.fromJson(body);
        setMantraList(Status.completed);
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
