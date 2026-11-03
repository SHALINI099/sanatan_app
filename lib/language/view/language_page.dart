import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posterapp/core/database/BharatStorage.dart';

import '../../core/storage/app_dimensions.dart';
import '../../core/storage/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../resource/values/Status.dart';
import '../data/model/LanguageModel.dart';
import '../viewmodel/language_view_model.dart';

class LanguagePage extends StatelessWidget {
  LanguagePage({super.key});

  final langCtr = Get.put(LanguageViewModel());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Language',
                  style: AppDimensions.inter(
                    fontSize: AppDimensions.fontSize18,
                    fontWeight: AppDimensions.fontWeight600,
                    color: AppColors.black,
                  ),
                ),
                AppSpacing.height(2),
                Text(
                  'Choose your preferred language',
                  style: AppDimensions.inter(
                    fontSize: AppDimensions.fontSize13,
                    fontWeight: AppDimensions.fontWeight400,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      final status = langCtr.rxLangListRequestStatus.value;
      final model = langCtr.languageModel.value;

      if (status == Status.loading || status == Status.initial) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }

      if (status == Status.error) {
        return _buildError();
      }

      final items = model?.data ?? const <Datums>[];

      if (items.isEmpty) {
        return Center(
          child: Text(
            'No languages available',
            style: AppDimensions.inter(
              fontSize: AppDimensions.fontSize14,
              color: AppColors.grey,
            ),
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
        ),
        itemBuilder: (_, index) => _LanguageTile(
          lang: items[index],
          controller: langCtr,
        ),
      );
    });
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: AppColors.grey, size: 40),
          AppSpacing.height(8),
          Text(
            'Something went wrong',
            style: AppDimensions.inter(
              fontSize: AppDimensions.fontSize14,
              color: AppColors.grey,
            ),
          ),
          AppSpacing.height(12),
          OutlinedButton(
            onPressed: langCtr.getLangList,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.lang, required this.controller});

  final Datums lang;
  final LanguageViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected =
          controller.selectedLanguageId.value == lang.id.toString();

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            controller.selectedLanguageId.value = lang.id.toString();
            BharatStorage.setLanguage(lang.languageCode);
            controller.updateLang();
            Future.delayed(
              const Duration(milliseconds: 120),
              Get.back,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.grey.shade300,
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.language,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppDimensions.inter(
                          fontSize: AppDimensions.fontSize15,
                          fontWeight: AppDimensions.fontWeight600,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                      Text(
                        lang.languageCode.toUpperCase(),
                        style: AppDimensions.inter(
                          fontSize: AppDimensions.fontSize12,
                          fontWeight: AppDimensions.fontWeight400,
                          color: isSelected
                              ? AppColors.white.withValues(alpha: 0.85)
                              : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}