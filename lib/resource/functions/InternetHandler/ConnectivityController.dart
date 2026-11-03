import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Coarse connectivity state the UI cares about.
enum MConnectivityResult { none, wifi, mobile }

class ConnectivityController extends GetxController {
  final Rx<MConnectivityResult> _connectionType = MConnectivityResult.none.obs;
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _streamSubscription;

  MConnectivityResult get connectionType => _connectionType.value;

  set connectionType(MConnectivityResult value) {
    _connectionType.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    getConnectivityType();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateState);
  }

  Future<void> getConnectivityType() async {
    List<ConnectivityResult> connectivityResult;
    try {
      connectivityResult = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      connectivityResult = [ConnectivityResult.none];
      debugPrint('ConnectivityController: checkConnectivity failed: $e');
    }
    _updateState(connectivityResult);
  }

  void _updateState(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.mobile)) {
      connectionType = MConnectivityResult.mobile;
    } else if (result.contains(ConnectivityResult.wifi)) {
      connectionType = MConnectivityResult.wifi;
    } else if (result.contains(ConnectivityResult.none)) {
      connectionType = MConnectivityResult.none;
    }
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
    super.onClose();
  }
}
