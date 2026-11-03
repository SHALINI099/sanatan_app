import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posterapp/core/storage/app_dimensions.dart';

import '../../core/database/BharatStorage.dart';
import '../../core/storage/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../payment/view/payment_screen.dart';
import '../../resource/values/Status.dart';
import '../../resource/widgets/helper/RetryState.dart';
import '../data/model/MantraListModel.dart';
import '../view_model/mantra_view_model.dart';
import 'jap_screen.dart';
import 'mantra_tile.dart';

class MantraScreen extends StatefulWidget {
  const MantraScreen({super.key});

  @override
  State<MantraScreen> createState() => _MantraScreenState();
}

class _MantraScreenState extends State<MantraScreen> {
  late final MantraViewModel mantraCtr;

  @override
  void initState() {
    super.initState();
    mantraCtr = Get.put(MantraViewModel());
  }

  @override
  void dispose() {
    Get.delete<MantraViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(child: Obx(_buildBody)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final status = mantraCtr.rxMantraRequestStatus.value;

    if (status == Status.initial || status == Status.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (status == Status.error) {
      return RetryState(
        message: mantraCtr.errorMessage.value.isEmpty
            ? "Something went wrong"
            : mantraCtr.errorMessage.value,
        onRetry: mantraCtr.getMantraList,
      );
    }

    final data = mantraCtr.mantraListModel.value;
    if (data == null || data.postData.isEmpty) {
      return RetryState(
        message: "No Mantras Found",
        icon: Icons.self_improvement_outlined,
        iconColor: AppColors.grey,
        onRetry: mantraCtr.getMantraList,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.postData.length,
      itemBuilder: (context, index) {
        final item = data.postData[index];
        return MantraTile(
          title: item.title,
          desc: item.description,
          thumbnail: item.thumbnail,
          onTap: () => _openMantra(item),
        );
      },
    );
  }

  void _openMantra(PostDatum item) {
    if (BharatStorage.getSubscription() == true) {
      Get.to(() => JapScreen(mantra: item));
    } else {
      Get.to(() => const PaymentScreen());
    }
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
          ),
          AppSpacing.width(10),
          Text(
            "Mantra List",
            style: TextStyle(
              fontSize: AppDimensions.fontSize20,
              fontWeight: AppDimensions.fontWeight600,
            ),
          ),
        ],
      ),
    );
  }
}