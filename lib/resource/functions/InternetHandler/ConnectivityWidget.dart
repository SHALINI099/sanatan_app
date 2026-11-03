import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:posterapp/resource/values/BharatDimension.dart';
import '../../../core/theme/app_colors.dart';
import 'ConnectivityController.dart';

class ConnectivityWidget extends StatelessWidget {
  const ConnectivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final netCheck = Get.find<ConnectivityController>();

    return AlertDialog(
      content:  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   "assets/images/nonet2.png",
              //   width: Get.width * 0.5,
              //   height: Get.width * 0.5,
              // ),
              const SizedBox(height: 20),
              Text(
                "noNetMessage".tr,
                style: BharatDimension.fontFamily(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: Get.width * 0.8,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await netCheck.getConnectivityType();
                    if (netCheck.connectionType == MConnectivityResult.wifi ||
                        netCheck.connectionType == MConnectivityResult.mobile) {
                      EasyLoading.showSuccess('netOn'.tr);
                    } else {
                      EasyLoading.showError('netOff'.tr);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    "retry".tr,
                    style: BharatDimension.fontFamily(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xfff14c4b),
                    elevation: 3,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

    );
  }
}
