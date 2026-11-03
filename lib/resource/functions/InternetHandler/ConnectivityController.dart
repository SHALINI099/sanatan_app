import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  final _connectionType = MConnectivityResult.none.obs;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;

  MConnectivityResult get connectionType => _connectionType.value;

  set connectionType(value) {
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
      connectivityResult = await (_connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      connectivityResult = [ConnectivityResult.none];
      if (kDebugMode) {
        print(e);
      }
    }
    return _updateState(connectivityResult);
  }

  _updateState(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.mobile)) {
      connectionType = MConnectivityResult.mobile;
    } else if (result.contains(ConnectivityResult.wifi)) {
      connectionType = MConnectivityResult.wifi;
    }

    // else if (result.contains(ConnectivityResult.ethernet)) {
    //   print('Ethernet');
    //   connectionType = MConnectivityResult.ethernet;
    // }

    else if (result.contains(ConnectivityResult.none)) {
      connectionType = MConnectivityResult.none;
    }
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
  }
}

enum MConnectivityResult { none, wifi, mobile }