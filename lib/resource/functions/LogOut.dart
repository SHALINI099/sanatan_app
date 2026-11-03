import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:posterapp/resource/values/image_controller.dart';

import '../../core/database/BharatStorage.dart';
import '../../dashboard/viewmodel/dashboard_view_model.dart';
import '../../login/view/login_screen/login_screen.dart';

/// Clears session state and returns to the login screen.
///
/// Pass [isLogout] as `false` when the server rejected the session (401) so
/// the user is told why they were signed out.
Future<void> logOutUser(bool isLogout) async {
  final DashboardViewModel dashCtr = Get.put(DashboardViewModel());
  if (!isLogout) {
    await EasyLoading.showError('unauthorizedUser'.tr);
  }
  imgCtr.downloadURL.value = '';
  dashCtr.updateIndex(0);
  await BharatStorage.eraseAllData();

  Get.offAll(const LoginScreen());
}
