import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import '../../core/database/BharatStorage.dart';
import '../../core/theme/app_colors.dart';
import '../../payment/view/payment_screen.dart';
import '../../resource/values/Status.dart';
import '../../resource/widgets/helper/RetryState.dart';
import '../viewmodel/wallpaper_view_model.dart';

class WallpaperScreen extends StatelessWidget {
  WallpaperScreen({
    super.key,
  });

  final WallpaperViewModel wallpaperCtrl = Get.put(WallpaperViewModel());
  final WallpaperManagerPlus wallpaperManagerPlus = WallpaperManagerPlus();

  static const _accent = Color(0xFFE67E22);
  static const _accentDeep = Color(0xFFC0392B);
  static const _gold = Color(0xFFD4A017);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: AppColors.bgColor,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(Icons.arrow_back)),
          title: Text("Wallpaper List"),
        ),
        body: SafeArea(child: Obx(
          () {
            final status = wallpaperCtrl.rxWallpaperRequestStatus.value;

            if (status == Status.initial || status == Status.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (status == Status.error) {
              return RetryState(
                message: wallpaperCtrl.errorMessage.value.isEmpty
                    ? "Something went wrong"
                    : wallpaperCtrl.errorMessage.value,
                onRetry: wallpaperCtrl.getWallpaperList,
              );
            }

            final data = wallpaperCtrl.wallpaperModel.value;

            if (data == null || data.postData.isEmpty) {
              return RetryState(
                message: "No Wallpapers Found",
                icon: Icons.image_not_supported_outlined,
                iconColor: AppColors.grey,
                onRetry: wallpaperCtrl.getWallpaperList,
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.postData.length,
              cacheExtent: 200,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final item = data.postData[index];
                return _WallpaperTile(
                  key: ValueKey(item.wallpaperUrl),
                  imageUrl: item.wallpaperUrl,
                  title: item.title,
                  index: index,
                  heroTag: item,
                  onTap: () => _openPreview(context, item.wallpaperUrl),
                );
              },
            );
          },
        )));
  }

  void _openPreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
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

            // Close Button
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: _accent,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: _accent.withValues(alpha: 0.5),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),

            // Buttons Container
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _accent.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildWallpaperButton(
                          icon: Icons.home_rounded,
                          text: "Home Screen",
                          gradient: const LinearGradient(
                            colors: [_accent, Color(0xFFFFB366)],
                          ),
                          onTap: () {
                            if (BharatStorage.getSubscription() == true) {
                              wallpaperCtrl.setWallpaper(
                                WallpaperManagerPlus.homeScreen,
                                imageUrl,
                              );
                            } else {
                              Get.to(() => const PaymentScreen());
                            }
                          }),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildWallpaperButton(
                          icon: Icons.lock_rounded,
                          text: "Lock Screen",
                          gradient: const LinearGradient(
                            colors: [_gold, Color(0xFFFFD27D)],
                          ),
                          onTap: () {
                            if (BharatStorage.getSubscription() == true) {
                              wallpaperCtrl.setWallpaper(
                                WallpaperManagerPlus.lockScreen,
                                imageUrl,
                              );
                            } else {
                              Get.to(() => const PaymentScreen());
                            }
                          }),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildWallpaperButton(
                          icon: Icons.smartphone_rounded,
                          text: "Both Screens",
                          gradient: const LinearGradient(
                            colors: [_accentDeep, _accent],
                          ),
                          onTap: () {
                            if (BharatStorage.getSubscription() == true) {
                              wallpaperCtrl.setWallpaper(
                                WallpaperManagerPlus.bothScreens,
                                imageUrl,
                              );
                            } else {
                              Get.to(() => const PaymentScreen());
                            }
                          }),
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

  Widget _buildWallpaperButton({
    required IconData icon,
    required String text,
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
              color: AppColors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WallpaperTile extends StatefulWidget {
  final String imageUrl;
  final String title;
  final int index;
  final Object heroTag;
  final VoidCallback onTap;

  const _WallpaperTile({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.index,
    required this.heroTag,
    required this.onTap,
  });

  @override
  State<_WallpaperTile> createState() => _WallpaperTileState();
}

class _WallpaperTileState extends State<_WallpaperTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _isReady = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    // precacheImage needs a valid BuildContext; defer to first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _SequentialPrecache.enqueue(
        url: widget.imageUrl,
        context: context,
        isAlive: () => mounted,
        onDone: (ok) {
          if (!mounted) return;
          setState(() {
            _isReady = true;
            _isError = !ok;
          });
          _entryController.forward();
        },
      );
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = WallpaperScreen._accent;

    return GestureDetector(
      onTap: _isReady && !_isError ? widget.onTap : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _isReady
              ? FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: _isError
                        ? _buildError()
                        : Hero(
                            tag: widget.heroTag,
                            child: _buildLoaded(accent),
                          ),
                  ),
                )
              : _buildShimmer(),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFFFE0B3),
      highlightColor: const Color(0xFFFFF4E0),
      period: const Duration(milliseconds: 1200),
      child: Container(color: Colors.white),
    );
  }

  Widget _buildError() {
    return Container(
      color: const Color(0xFFFFF4E0),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: WallpaperScreen._accent,
      ),
    );
  }

  Widget _buildLoaded(Color accent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.imageUrl,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [
                AppColors.black.withValues(alpha: 0.55),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          right: 12,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.image_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${widget.title} ${widget.index + 1}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Static FIFO queue that precaches one network image at a time.
/// Used so wallpapers reveal in list order rather than racing in parallel.
class _SequentialPrecache {
  static final List<_PrecacheJob> _queue = [];
  static bool _busy = false;

  static void enqueue({
    required String url,
    required BuildContext context,
    required bool Function() isAlive,
    required void Function(bool ok) onDone,
  }) {
    _queue.add(_PrecacheJob(url, context, isAlive, onDone));
    _drain();
  }

  static Future<void> _drain() async {
    if (_busy) return;
    _busy = true;
    while (_queue.isNotEmpty) {
      final job = _queue.removeAt(0);
      if (!job.isAlive()) continue;
      bool ok = true;
      try {
        await precacheImage(
          CachedNetworkImageProvider(job.url),
          job.context,
        );
      } catch (_) {
        ok = false;
      }
      if (job.isAlive()) job.onDone(ok);
    }
    _busy = false;
  }
}

class _PrecacheJob {
  final String url;
  final BuildContext context;
  final bool Function() isAlive;
  final void Function(bool ok) onDone;
  _PrecacheJob(this.url, this.context, this.isAlive, this.onDone);
}
