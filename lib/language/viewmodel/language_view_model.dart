import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:posterapp/core/database/BharatStorage.dart';
import 'package:posterapp/core/network/dio_client.dart';
import 'package:posterapp/language/data/api/language_api.dart';
import 'package:posterapp/language/data/model/LanguageModel.dart';
import 'package:posterapp/resource/values/Status.dart';

class LanguageViewModel extends GetxController {
  final api = LanguageApi(buildDio());

  final selectedLanguageId = ''.obs;
  final rxLangListRequestStatus = Status.initial.obs;

  void setLangRxRequestStatus(Status value) =>
      rxLangListRequestStatus.value = value;
  Rxn<LanguageModel> languageModel = Rxn<LanguageModel>();

  Future<void> getLangList() async {
    setLangRxRequestStatus(Status.loading);

    try {
      String token = BharatStorage.getAuthKey() ?? '';

      final res = await api.getLanguage('Bearer $token');

      if (res.response.statusCode == 200) {
        languageModel.value = LanguageModel.fromJson(res.data);
        // LanguageModel model = LanguageModel.fromJson(res.data);

        setLangRxRequestStatus(Status.completed);
      } else if (res.response.statusCode == 401) {
      } else {
        setLangRxRequestStatus(Status.error);
      }
    } catch (error) {
      setLangRxRequestStatus(Status.error);
    }
  }

  /// Best-effort sync of the chosen language to the server. The local
  /// preference is already saved, so a failure here is only logged.
  Future<void> updateLang() async {
    try {
      final String token = BharatStorage.getAuthKey() ?? '';

      final res = await api.updateLang('Bearer $token', {
        "language": BharatStorage.getLanguage().toString(),
      });

      if (res.response.statusCode != 200) {
        debugPrint(
          'LanguageViewModel.updateLang: HTTP ${res.response.statusCode}',
        );
      }
    } catch (error) {
      debugPrint('LanguageViewModel.updateLang: $error');
    }
  }

  @override
  void onInit() {
    getLangList();
    super.onInit();
  }
}
