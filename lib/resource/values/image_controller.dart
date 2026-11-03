import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_rembg/local_rembg.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_colors.dart';
import '../../myProfile/viewmodel/my_profile_view_model.dart';
import '../widgets/helper/DynamicButton.dart';

final imgCtr = Get.put(ImageController());

class ImageController extends GetxController {
  final RxString downloadURL = ''.obs;

  Future<void> pickFromGallery() => _pickAndUpload(ImageSource.gallery);

  Future<void> pickFromCamera() => _pickAndUpload(ImageSource.camera);

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source);
      if (picked == null) return;

      final croppedPath = await _crop(picked.path);
      if (croppedPath.isEmpty) return;

      final removeBg = await _askBgRemoval(croppedPath);

      File finalFile = File(croppedPath);
      if (removeBg) {
        final stripped = await _removeBg(croppedPath);
        if (stripped != null) finalFile = stripped;
      }

      final url = await _uploadToFirebase(finalFile);
      if (url.isEmpty) return;

      downloadURL.value = url;

      final profileCtr = Get.find<MyProfileViewModel>();
      profileCtr.avatar.value = url;
      await profileCtr.updateAvatar(url);
    } on PlatformException catch (e) {
      EasyLoading.showError(e.toString());
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  Future<String> _crop(String path) async {
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            // aspectRatioPresets: const [CropAspectRatioPreset.square],
          ),

        ],
      );
      return cropped?.path ?? path;
    } on MissingPluginException {
      EasyLoading.showError('Cropper unavailable, using original image.');
      return path;
    } catch (_) {
      return path;
    }
  }

  Future<File?> _removeBg(String path) async {
    try {
      final result = await LocalRembg.removeBackground(
        cropTheImage: false,
        imagePath: path,
      );
      if (result.imageBytes == null) {
        EasyLoading.showError('Background removal failed.');
        return null;
      }
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(result.imageBytes!);
      return file;
    } on MissingPluginException {
      EasyLoading.showError(
        'Background removal not available on this device. Uploading original.',
      );
      return null;
    } catch (_) {
      EasyLoading.showError(
        'Background removal failed. Uploading original.',
      );
      return null;
    }
  }

  Future<String> _uploadToFirebase(File file) async {
    try {
      EasyLoading.show(
        status: 'Uploading Profile Photo...',
        dismissOnTap: false,
      );
      final fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final storage = FirebaseStorage.instanceFor(
        bucket: 'islamic-2ea5d.firebasestorage.app',
      );
      final ref = storage.ref().child('myProfile/$fileName.jpeg');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await ref.putFile(file, metadata);
      final url = await ref.getDownloadURL();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Profile photo updated');
      return url;
    } catch (e) {
      EasyLoading.dismiss();
      Fluttertoast.showToast(msg: 'Upload failed: $e');
      return '';
    }
  }

  Future<bool> _askBgRemoval(String path) {
    final completer = Completer<bool>();
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Image Background'),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(path), fit: BoxFit.contain),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DynamicButton(
                  text: 'No',
                  backgroundColor: AppColors.primaryColor,
                  height: 40,
                  onTap: () {
                    completer.complete(false);
                    Get.back();
                  },
                ),
                const SizedBox(width: 15),
                DynamicButton(
                  text: 'Yes',
                  backgroundColor: AppColors.primaryColor,
                  height: 40,
                  onTap: () {
                    completer.complete(true);
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return completer.future;
  }
}