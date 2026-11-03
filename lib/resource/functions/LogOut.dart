import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:posterapp/resource/values/image_controller.dart';

import '../../dashboard/viewmodel/dashboard_view_model.dart';
import '../../login/view/login_screen/login_screen.dart';
import '../../core/database/BharatStorage.dart';

Future<void> logOutUser(bool isLogout) async {
  final DashboardViewModel dashCtr = Get.put(DashboardViewModel());
  if (!isLogout) {
    await EasyLoading.showError("unauthorizedUser".tr);
  }
  imgCtr.downloadURL.value = "";
  imgCtr.refresh();
  dashCtr.updateIndex(0);
  dashCtr.selectedIndex.value = 0;
  await BharatStorage.eraseAllData();

  Get.offAll(const LoginScreen());
}
