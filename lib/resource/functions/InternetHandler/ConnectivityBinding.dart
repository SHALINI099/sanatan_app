import 'package:get/get.dart';

import 'ConnectivityController.dart';

/// Registers app-wide controllers when the root [GetMaterialApp] is created.
class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    // Registered eagerly so connectivity monitoring starts at launch rather
    // than on the first screen that happens to look it up.
    Get.put<ConnectivityController>(ConnectivityController(), permanent: true);
  }
}
