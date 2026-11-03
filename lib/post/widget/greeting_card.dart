import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/database/BharatStorage.dart';
import '../../core/theme/app_colors.dart';
import '../../myProfile/viewmodel/my_profile_view_model.dart';
import '../../payment/view/payment_screen.dart';
import '../../resource/values/DownloadShare.dart';
import '../data/model/AllPostModel.dart';
import '../data/model/PostModel.dart';
import '../view/post_screen.dart';
import 'card_section_cta.dart';

class GreetingCard extends StatefulWidget {
  final String imageUrl;
  final String position;
  final String shape;
  final String sharingContent;
  final String title;
  final GlobalKey? boundaryKey;
  final bool showHeader;
  final bool showActions;

  const GreetingCard({
    super.key,
    required this.imageUrl,
    required this.position,
    required this.shape,
    this.sharingContent = '',
    this.title = '',
    this.boundaryKey,
    this.showHeader = true,
    this.showActions = true,
  });

  factory GreetingCard.fromPostDatum(
    PostDatum d, {
    Key? key,
    GlobalKey? boundaryKey,
    bool showHeader = false,
    bool showActions = true,
  }) =>
      GreetingCard(
        key: key,
        imageUrl: d.postUrl,
        position: d.avatarPostion,
        shape: d.avatarShape,
        sharingContent: d.sharingContent,
        title: d.title,
        boundaryKey: boundaryKey,
        showHeader: showHeader,
        showActions: showActions,
      );

  factory GreetingCard.fromDatum(
    Datum d, {
    Key? key,
    GlobalKey? boundaryKey,
    bool showHeader = true,
    bool showActions = true,
  }) =>
      GreetingCard(
        key: key,
        imageUrl: d.data.postUrl ?? '',
        position: d.data.avatarPostion ?? 'bottom_right',
        shape: d.data.avatarShape ?? 'circle',
        sharingContent: d.data.sharingContent ?? '',
        title: d.data.title,
        boundaryKey: boundaryKey,
        showHeader: showHeader,
        showActions: showActions,
      );

  @override
  State<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<GreetingCard> {
  final MyProfileViewModel profileCtr = Get.put(MyProfileViewModel());
  final GlobalKey _internalKey = GlobalKey();

  GlobalKey get _boundaryKey => widget.boundaryKey ?? _internalKey;

  @override
  Widget build(BuildContext context) {
    try{
      profileCtr.nameCtr.value.text = BharatStorage.getUserName() ?? '';
    }catch(e){

    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHeader)
          CardSectionCta(
            title: 'Greeting Posts',
            subtitle: 'Personalize and share with one tap',
            icon: Icons.favorite_rounded,
            accent: AppColors.primaryColor,
            onTap: () => Get.to(() => const PostScreen()),
          ),
        _buildHeroCard(context),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 8, 4, 12),
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
            _buildBackdrop(),
            _buildGradientVeil(),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdrop() {
    final url = widget.imageUrl;
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
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
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
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          const SizedBox(height: 14),
          _buildCapturable(),
          if (widget.showActions) ...[
            const SizedBox(height: 14),
            _buildActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCapturable() {
    return Center(
      child: RepaintBoundary(
        key: _boundaryKey,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 5),
                  placeholder: (context, url) => const SizedBox(
                    height: 280,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 280,
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_rounded,
                      size: 64,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                _buildAvatarStrip(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarStrip() {

    return Obx(() {
      final avatar = profileCtr.avatar.value;
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primaryColor,
              Color(0xFFB74E2C),
            ],
          ),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: avatar.isEmpty
                    ? Container(
                        width: 52,
                        height: 52,
                        color: AppColors.white,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: avatar,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 52,
                          height: 52,
                          color: AppColors.white,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    BharatStorage.getUserName().toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                if (BharatStorage.getSubscription() == true) {
                  DownloadShare.sharePost(
                      _boundaryKey, widget.sharingContent);
                } else {
                  Get.to(() => const PaymentScreen());
                }
              },
              icon: const Icon(Icons.share_rounded, size: 20),
              label: const Text(
                'Share Greeting',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
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

}