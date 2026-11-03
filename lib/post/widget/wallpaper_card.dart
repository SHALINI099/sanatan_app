import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posterapp/core/theme/app_colors.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import '../../core/database/BharatStorage.dart';
import '../../payment/view/payment_screen.dart';
import '../../wallpaper/view/wallpaper_screen.dart';
import '../../wallpaper/viewmodel/wallpaper_view_model.dart';
import '../data/model/AllPostModel.dart';
import 'card_section_cta.dart';

class WallpaperCard extends StatelessWidget {
  final Datum post;

  WallpaperCard({super.key, required this.post});

  final WallpaperViewModel wallpaperCtr = Get.put(WallpaperViewModel());

  @override
  Widget build(BuildContext context) {
    final url = post.data.wallpaperUrl ?? '';
    final title =
    post.data.title.isNotEmpty ? post.data.title : 'Wallpaper';
    final shareContent = post.data.sharingContent ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardSectionCta(
          title: 'Wallpapers',
          subtitle: 'Browse the Wallpapers',
          icon: Icons.wallpaper_rounded,
          accent: AppColors.primaryColor,
          onTap: () => Get.to(() => WallpaperScreen()),
        ),
        _buildHeroCard(context, url, title, shareContent),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, String url, String title,
      String shareContent) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 6, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            _buildBackdrop(url),
            _buildGradientVeil(),
            _buildContent(context, url, title, shareContent),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdrop(String url) {
    return Positioned.fill(
      child: url.isEmpty
          ? Container(color: AppColors.primaryColor)
          : Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.primaryColor),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientVeil() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.75),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String url, String title,
      String shareContent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPreview(context, url),
          const SizedBox(height: 18),

          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          _buildActions(context, url, shareContent),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, String url) {
    return Center(
      child: GestureDetector(
        onTap: () => _openPreview(context, url),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 9 / 14,
              child: url.isEmpty
                  ? _previewFallback()
                  : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _previewFallback(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewFallback() {
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.25),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_rounded,
        size: 80,
        color: Colors.white,
      ),
    );
  }

  Widget _buildActions(BuildContext context, String url, String shareContent) {
    return Row(
      children: [
        // _iconAction(
        //   icon: Icons.download_rounded,
        //   onTap:
        //       disabled ? null : () => DownloadShare.downloadWallpaper(url),
        // ),
        // const SizedBox(width: 10),
        // _iconAction(
        //   icon: Icons.share_rounded,
        //   onTap: disabled
        //       ? null
        //       : () => DownloadShare.shareWallpaper(url, shareContent),
        // ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                if(BharatStorage.getSubscription()==true){
                  Get.to(()=>WallpaperScreen());
                }else{
                  Get.to(()=>PaymentScreen());
                }
              },
              icon: const Icon(Icons.wallpaper_rounded, size: 20),
              label: const Text(
                'Set Wallpaper',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryColor,
                elevation: 8,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _openPreview(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) =>
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                Hero(
                  tag: imageUrl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      height: Get.height * 0.9,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _wallpaperOption(
                          icon: Icons.home_rounded,
                          label: 'Home Screen',
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlue],
                          ),
                          onTap: () =>
                              _applyWallpaper(
                                  WallpaperManagerPlus.homeScreen, imageUrl),
                        ),
                        const SizedBox(height: 10),
                        _wallpaperOption(
                          icon: Icons.lock_rounded,
                          label: 'Lock Screen',
                          gradient: const LinearGradient(
                            colors: [Colors.green, Colors.lightGreen],
                          ),
                          onTap: () =>
                              _applyWallpaper(
                                  WallpaperManagerPlus.lockScreen, imageUrl),
                        ),
                        const SizedBox(height: 10),
                        _wallpaperOption(
                          icon: Icons.smartphone_rounded,
                          label: 'Both Screens',
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrangeAccent],
                          ),
                          onTap: () =>
                              _applyWallpaper(
                                  WallpaperManagerPlus.bothScreens, imageUrl),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _applyWallpaper(int location, String imageUrl) {
    if (BharatStorage.getSubscription() == true) {
      wallpaperCtr.setWallpaper(location, imageUrl);
    } else {
      Get.to(() => const PaymentScreen());
    }
  }

  Widget _wallpaperOption({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}