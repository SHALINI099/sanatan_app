import 'package:get/get.dart';

import 'ConnectivityController.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectivityController>(() => ConnectivityController());
  }
}
