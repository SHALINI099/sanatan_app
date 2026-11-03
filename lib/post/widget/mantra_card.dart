import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posterapp/core/storage/app_spacing.dart';
import 'package:posterapp/mantra/view/mantra_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/database/BharatStorage.dart';
import '../../core/theme/app_colors.dart';
import '../../payment/view/payment_screen.dart';
import '../data/model/AllPostModel.dart';
import '../viewmodel/audio_view_model.dart';
import 'card_section_cta.dart';

class MantraCard extends StatefulWidget {
  final Datum post;

  const MantraCard({super.key, required this.post});

  @override
  State<MantraCard> createState() => _MantraCardState();
}

class _MantraCardState extends State<MantraCard>
    with SingleTickerProviderStateMixin {
  final AudioViewModel audioCtr = Get.put(AudioViewModel());

  late final AnimationController _pulseCtrl;

  bool _userPaused = false;

  int get _index => widget.post.id;

  String get _key => 'mantra_${widget.post.id}';

  String get _url => widget.post.data.mantraUrl ?? '';

  bool get _isThis => audioCtr.playingKey.value == _key;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  void _stopIfMine() {
    if (_isThis) {
      audioCtr.pauseAudio();
    }
  }

  /// PLAY / PAUSE BUTTON
  void _onTapPlayPause() {
    if (_url.isEmpty) return;

    final isThis = _isThis;
    final isPlaying = audioCtr.isPlaying.value;

    if (isThis && isPlaying) {
      _userPaused = true;
      audioCtr.pauseAudio();
    } else {
      _userPaused = false;

      audioCtr.playAudio(
        key: _key,
        index: _index,
        url: _url,
      );
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _stopIfMine();
    super.dispose();
  }

  /// AUTO PLAY WHEN VISIBLE
  void _onVisibility(VisibilityInfo info) {
    if (_url.isEmpty) return;

    if (audioCtr.loading.value) return;

    if (info.visibleFraction > 0.85) {
      if (_userPaused) return;

      final alreadyPlaying =
          _isThis &&
              audioCtr.isPlaying.value;

      if (alreadyPlaying) return;

      audioCtr.playAudio(
        key: _key,
        index: _index,
        url: _url,
      );
    } else {
      if (_isThis) {
        audioCtr.pauseAudio();
      }
    }
  }
  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final url = _url;
    final index = _index;
    final title = widget.post.data.title;
    final thumbnail = widget.post.data.thumbnail ?? '';

    return VisibilityDetector(
      key: ValueKey('mantra_${widget.post.id}'),
      onVisibilityChanged: _onVisibility,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardSectionCta(
            title: 'Jap Mantra',
            subtitle: 'Browse and set your favourite Mantra',
            icon: Icons.alarm_rounded,
            accent: Colors.deepOrange.shade600,
            onTap: () => Get.to(() => MantraScreen()),
          ),
          _buildHeroCard(url, index, title, thumbnail),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
      String url,
      int index,
      String title,
      String thumbnail,
      ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            _buildBackdrop(thumbnail),
            _buildGradientVeil(),
            _buildContent(url, index, title, thumbnail),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdrop(String thumbnail) {
    return Positioned.fill(
      child: thumbnail.isEmpty
          ? Container(color: Colors.deepOrange.shade700)
          : Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            thumbnail,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.deepOrange.shade700),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: AppColors.black.withValues(alpha: 0.2),
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
              Colors.deepOrange.withValues(alpha: 0.45),
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      String url,
      int index,
      String title,
      String thumbnail,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHero(index, thumbnail),

          AppSpacing.height(18),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.alarm_rounded,
                      color: AppColors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'MANTRA',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.height(8),

          if (title.isNotEmpty)
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),

          _buildProgress(index),

          AppSpacing.height(14),

          _buildControls(url, index),
        ],
      ),
    );
  }

  Widget _buildHero(int index, String thumbnail) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: thumbnail.isEmpty
                    ? _heroFallback()
                    : Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _heroFallback(),
                ),
              ),

              Obx(() {
                final isThis = audioCtr.playingKey.value == _key;
                final isPlaying = isThis && audioCtr.isPlaying.value;

                if (!isPlaying) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  bottom: 10,
                  child: _Equalizer(controller: _pulseCtrl),
                );
              }),

              Obx(() {
                final isThis = audioCtr.playingKey.value == _key;
                final isPlaying = isThis && audioCtr.isPlaying.value;

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isPlaying ? 1 : 0.6,
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      final scale =
                      isPlaying ? 1 + (_pulseCtrl.value * 0.08) : 1.0;

                      return Transform.scale(
                        scale: scale,
                        child: Icon(
                          Icons.alarm_rounded,
                          size: 88,
                          color: AppColors.white.withValues(alpha: 0.18),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroFallback() {
    return Container(
      color: Colors.deepOrange.withValues(alpha: 0.3),
      alignment: Alignment.center,
      child: const Icon(
        Icons.alarm_rounded,
        size: 80,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildProgress(int index) {
    return Obx(() {
      final isThis = audioCtr.playingKey.value == _key;

      if (!isThis) {
        return  AppSpacing.height(12);
      }

      final dur = audioCtr.duration.value.inSeconds.toDouble();
      final pos = audioCtr.position.value.inSeconds.toDouble();

      final maxV = dur <= 0 ? 1.0 : dur;
      final val = pos.clamp(0, maxV).toDouble();

      return Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 12,
              ),
              activeTrackColor: AppColors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: AppColors.white,
            ),
            child: Slider(
              min: 0,
              max: maxV,
              value: val,
              onChanged: (v) => audioCtr.seek(v),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _format(audioCtr.position.value),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _format(audioCtr.duration.value),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildControls(String url, int index) {
    return Row(
      children: [
        Obx(() {
          final isThis = audioCtr.playingKey.value == _key;
          final isPlaying = isThis && audioCtr.isPlaying.value;

          return Material(
            shape: const CircleBorder(),
            color: AppColors.white,
            elevation: 10,
            shadowColor: Colors.black54,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: url.isEmpty ? null : _onTapPlayPause,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Center(
                  child: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 34,
                    color: Colors.deepOrange.shade700,
                  ),
                ),
              ),
            ),
          );
        }),

        AppSpacing.width(12),

        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                if (BharatStorage.getSubscription() == true) {
                  Get.to(() => MantraScreen());
                } else {
                  Get.to(() => PaymentScreen());
                }
              },
              icon: const Icon(Icons.alarm_add_rounded, size: 20),
              label: const Text(
                'Mantra',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white.withValues(alpha: 0.18),
                foregroundColor: AppColors.white,
                elevation: 0,
                side: BorderSide(
                  color: AppColors.white.withValues(alpha: 0.4),
                ),
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

class _Equalizer extends StatelessWidget {
  final AnimationController controller;

  const _Equalizer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                final t = ((controller.value + i * 0.22) % 1.0);
                final wave = (t < 0.5 ? t * 2 : (1 - t) * 2);
                final h = 6 + wave * 14;

                return Container(
                  width: 3,
                  height: h,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}