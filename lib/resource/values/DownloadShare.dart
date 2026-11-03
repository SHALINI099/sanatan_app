import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

import '../../dashboard/viewmodel/dashboard_view_model.dart';

DashboardViewModel dashCtr = Get.put(DashboardViewModel());

class DownloadShare {
  static shareScreenShot(Uint8List img, String content) async {
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    File imagePath = File('${directory!.path}/greeting.png');
    await imagePath.writeAsBytes(img);

    List<XFile> files = [XFile(imagePath.path)];

    if (Platform.isAndroid) {
      SharePlus.instance.share( ShareParams(files: files, text: "${"downloadKare".tr} $content",));
    } else {
      SharePlus.instance.share( ShareParams(files: files,));
    }
  }


  static Future<bool> saveImage(BuildContext context,
      Uint8List imageFromPhone) async {
    try {
      EasyLoading.showToast("Downloading...", duration: const Duration(seconds: 1),);

      String picturesPath = "${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg";

       await SaverGallery.saveImage(imageFromPhone,
          fileName: picturesPath, skipIfExists: false);
      EasyLoading.showToast(
          "Downloaded", duration: const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Uint8List?> captureBoundary(GlobalKey key,
      {double pixelRatio = 3.0}) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  static Future<String?> _downloadToTemp(String url, String filename) async {
    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$filename';
      await Dio().download(url, savePath);
      return savePath;
    } catch (_) {
      return null;
    }
  }

  // ---------- POST (greeting image) ----------

  static Future<void> sharePost(GlobalKey boundaryKey, String content) async {
    EasyLoading.show(status: 'Preparing...');
    try {
      final bytes = await captureBoundary(boundaryKey);
      if (bytes == null) return;
      await shareScreenShot(bytes, content);
    } finally {
      EasyLoading.dismiss();
    }
  }

  static Future<bool> downloadPost(
      BuildContext context, GlobalKey boundaryKey) async {
    final bytes = await captureBoundary(boundaryKey);
    if (bytes == null) return false;
    return saveImage(context, bytes);
  }

  // ---------- VIDEO ----------

  static Future<void> shareVideo(String url, String content) async {
    if (url.isEmpty) return;
    EasyLoading.show(status: 'Preparing...');
    try {
      final filename = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final path = await _downloadToTemp(url, filename);
      if (path == null) return;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(path)],
        text: content.isEmpty ? null : content,
      ));
    } finally {
      EasyLoading.dismiss();
    }
  }

  static Future<bool> downloadVideo(String url) async {
    if (url.isEmpty) return false;
    try {
      EasyLoading.showToast("Downloading...",
          duration: const Duration(seconds: 1));
      final filename = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final tempPath = await _downloadToTemp(url, filename);
      if (tempPath == null) return false;
      await SaverGallery.saveFile(
        filePath: tempPath,
        fileName: filename,
        skipIfExists: false,
        androidRelativePath: 'Movies',
      );
      EasyLoading.showToast("Downloaded",
          duration: const Duration(milliseconds: 800));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------- WALLPAPER (image url) ----------

  static Future<void> shareWallpaper(String url, String content) async {
    if (url.isEmpty) return;
    EasyLoading.show(status: 'Preparing...');
    try {
      final filename = 'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = await _downloadToTemp(url, filename);


      if (path == null) return;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(path)],
        text: content.isEmpty ? null : content,
      ));
    } finally {
      EasyLoading.dismiss();
    }
  }

  static Future<bool> downloadWallpaper(String url) async {
    if (url.isEmpty) return false;
    try {
      EasyLoading.showToast("Downloading...",
          duration: const Duration(seconds: 1));
      final filename = 'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempPath = await _downloadToTemp(url, filename);
      if (tempPath == null) return false;
      await SaverGallery.saveFile(
        filePath: tempPath,
        fileName: filename,
        skipIfExists: false,
        androidRelativePath: 'Pictures',
      );
      EasyLoading.showToast("Downloaded",
          duration: const Duration(milliseconds: 800));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------- RINGTONE (audio) ----------

  static Future<void> shareRingtone(String url, String content) async {
    if (url.isEmpty) return;
    EasyLoading.show(status: 'Preparing...');
    try {
      final filename = 'ringtone_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final path = await _downloadToTemp(url, filename);
      if (path == null) return;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(path)],
        text: content.isEmpty ? null : content,
      ));
    } finally {
      EasyLoading.dismiss();
    }
  }

  static Future<bool> downloadRingtone(String url) async {
    if (url.isEmpty) return false;
    try {
      EasyLoading.showToast("Downloading...",
          duration: const Duration(seconds: 1));
      final filename = 'ringtone_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      if (dir == null) return false;
      final savePath = '${dir.path}/$filename';
      await Dio().download(url, savePath);
      EasyLoading.showToast("Downloaded",
          duration: const Duration(milliseconds: 800));
      return true;
    } catch (_) {
      return false;
    }
  }
}