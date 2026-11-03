import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../dashboard/viewmodel/dashboard_view_model.dart';
import '../../values/BharatDimension.dart';
import 'DynamicButton.dart';

class ErrorVertical extends StatelessWidget {
  final DashboardViewModel dashCtr;

  const ErrorVertical({super.key, required this.dashCtr});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 100.0,
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade700,
                  size: 80,
                ),
                const SizedBox(height: 10),
                Text(
                  '${dashCtr.errorStatusCode} \n ${dashCtr.errorStatusMessage}',
                  textAlign: TextAlign.center,
                  style:BharatDimension.fontFamily(
                    color: Colors.red.shade700,

                  ),
                ),
                const SizedBox(height: 16),
                DynamicButton(
                  text: "Retry".tr,
                  leadingIcon: Icons.refresh,
                  showLeading: true,
                  width: Get.width * 0.38,
                  height: Get.width * BharatDimension.buttonBDayHieght,
                  onTap: () {
                    dashCtr.fetchCards(dashCtr
                        .tags[dashCtr.selectedIndex.value].id
                        .toString(),
                        '0');
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
