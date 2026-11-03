import 'dart:developer';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:posterapp/wallpaper/data/api/WallpaperApi.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import '../../core/database/BharatStorage.dart';
import '../../resource/functions/LogOut.dart';
import '../../resource/values/Status.dart';
import '../data/model/WallpaperModel.dart';
import 'package:posterapp/core/network/dio_client.dart';

class WallpaperViewModel extends GetxController {
  final api = WallpaperApi(buildDio());
  final WallpaperManagerPlus wallpaperManagerPlus = WallpaperManagerPlus();

  @override
  void onInit() {
    super.onInit();
    getWallpaperList();
  }

  final rxWallpaperRequestStatus = Status.initial.obs;

  /// Why the last load failed, shown on the error state.
  final errorMessage = ''.obs;

  Rxn<WallpaperModel> wallpaperModel = Rxn<WallpaperModel>();

  /// Guards against overlapping fetches.
  bool _inFlight = false;

  void setWallpapeRxRequestStatus(Status value) {
    if (isClosed) return;
    rxWallpaperRequestStatus(value);
  }

  void handleError(String code, String message,
      {Object? error, StackTrace? stack}) {
    log('[WallpaperViewModel] $code: $message', error: error, stackTrace: stack);
    if (isClosed) return;
    errorMessage.value = message;
    setWallpapeRxRequestStatus(Status.error);
  }

  Future<void> getWallpaperList() async {
    if (_inFlight) return;
    _inFlight = true;

    setWallpapeRxRequestStatus(Status.loading);
    errorMessage.value = '';

    try {
      final token = BharatStorage.getAuthKey();

      if (token == null || token.isEmpty) {
        logOutUser(false);
        return;
      }

      final language = BharatStorage.getLanguage() ?? 'en';
      final res = await api.getWallpaper("Bearer $token", language, "0");

      if (res.response.statusCode == 200) {
        final body = res.response.data;
        if (body is! Map<String, dynamic>) {
          handleError('ParseError', 'Unexpected response: ${body.runtimeType}');
          return;
        }

        if (isClosed) return;
        wallpaperModel.value = WallpaperModel.fromJson(body);
        setWallpapeRxRequestStatus(Status.completed);
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

  Future<void> setWallpaper(int location, String imageurl) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(imageurl);
      await wallpaperManagerPlus.setWallpaper(file, location);
      Get.snackbar("Success", "Wallpaper Set Successfully!");
    } catch (e, stack) {
      log('[WallpaperViewModel] setWallpaper failed',
          error: e, stackTrace: stack);
      Get.snackbar("Error", "Failed to set wallpaper");
    }
  }
}