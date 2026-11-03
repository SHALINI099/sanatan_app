import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:posterapp/core/database/BharatStorage.dart';
import 'package:posterapp/core/theme/app_colors.dart';
import 'package:posterapp/payment/view/payment_screen.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../ringtone/view/ringtone_screen.dart';
import '../data/model/AllPostModel.dart';
import '../viewmodel/audio_view_model.dart';
import 'card_section_cta.dart';


class RingtoneCard extends StatefulWidget {
  final Datum post;

  const RingtoneCard({
    super.key,
    required this.post,
  });

  @override
  State<RingtoneCard> createState() => _RingtoneCardState();
}

class _RingtoneCardState extends State<RingtoneCard>
    with SingleTickerProviderStateMixin {
  final AudioViewModel audioCtr =
  Get.put(AudioViewModel());

  late final AnimationController _pulseCtrl;

  bool _userPaused = false;

  int get _index => widget.post.id;

  String get _key => 'ringtone_${widget.post.id}';

  String get _url => widget.post.data.ringtoneUrl ?? '';

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

  /// PLAY / PAUSE
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

  /// AUTO PLAY ON VISIBILITY
  void _onVisibility(VisibilityInfo info) {
    if (_url.isEmpty) return;

    if (audioCtr.loading.value) return;

    if (info.visibleFraction > 0.85) {
      /// don't autoplay after manual pause
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
      key: ValueKey('ringtone_${widget.post.id}'),
      onVisibilityChanged: _onVisibility,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardSectionCta(
            title: 'Trending Ringtones',
            subtitle: 'Tap to explore the full collection',
            icon: Icons.music_note_rounded,
            accent: AppColors.primaryColor,
            onTap: () => Get.to(() => RingtoneScreen()),
          ),

          _buildHeroCard(
            url,
            index,
            title,
            thumbnail,
          ),
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
            _buildBackdrop(thumbnail),

            _buildGradientVeil(),

            _buildContent(
              url,
              index,
              title,
              thumbnail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdrop(String thumbnail) {
    return Positioned.fill(
      child: thumbnail.isEmpty
          ? Container(
        color: AppColors.primaryColor,
      )
          : Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            thumbnail,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: AppColors.primaryColor,
              );
            },
          ),

          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 30,
              sigmaY: 30,
            ),
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
              AppColors.primaryColor.withValues(alpha: 0.35),

              Colors.black.withValues(alpha: 0.65),
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
          _buildAlbumArt(
            index,
            thumbnail,
          ),

          const SizedBox(height: 18),

          if (title.isNotEmpty)
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

          const SizedBox(height: 4),

          const Text(
            'Ringtone',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),

          _buildProgress(index),

          const SizedBox(height: 14),

          _buildControls(url, index),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(
      int index,
      String thumbnail,
      ) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
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
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: thumbnail.isEmpty
                    ? Container(
                  color: AppColors.primaryColor.withValues(alpha: 0.25),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.music_note_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                )
                    : Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: AppColors.primaryColor.withValues(
                        alpha: 0.25,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.music_note_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),

              Obx(() {
                final isThis =
                    audioCtr.playingKey.value == _key;

                final isPlaying =
                    isThis &&
                        audioCtr.isPlaying.value;

                if (!isPlaying) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _Equalizer(
                    controller: _pulseCtrl,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(int index) {
    return Obx(() {
      final isThis =
          audioCtr.playingKey.value == _key;

      if (!isThis) {
        return const SizedBox(height: 12);
      }

      final dur =
      audioCtr.duration.value.inSeconds.toDouble();

      final pos =
      audioCtr.position.value.inSeconds.toDouble();

      final maxV = dur <= 0 ? 1.0 : dur;

      final val = pos.clamp(0, maxV).toDouble();

      return Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape:
              const RoundSliderThumbShape(
                enabledThumbRadius: 6,
              ),
              overlayShape:
              const RoundSliderOverlayShape(
                overlayRadius: 12,
              ),
              activeTrackColor: Colors.white,
              inactiveTrackColor:
              Colors.white.withValues(alpha: 0.25),
              thumbColor: Colors.white,
            ),
            child: Slider(
              min: 0,
              max: maxV,
              value: val,
              onChanged: (v) => audioCtr.seek(v),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
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

  Widget _buildControls(
      String url,
      int index,
      ) {
    return Row(
      children: [
        Obx(() {
          final isThis =
              audioCtr.playingKey.value == _key;

          final isPlaying =
              isThis &&
                  audioCtr.isPlaying.value;

          final loading =
              isThis &&
                  audioCtr.loading.value;

          return Material(
            shape: const CircleBorder(),
            color: Colors.white,
            elevation: 10,
            shadowColor: Colors.black54,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap:
              url.isEmpty
                  ? null
                  : _onTapPlayPause,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Center(
                  child: loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color:
                      AppColors.primaryColor,
                    ),
                  )
                      : Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 34,
                    color:
                    AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(width: 12),

        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                if (BharatStorage.getSubscription() ==
                    true) {
                  _setRingtone(url);
                } else {
                  Get.to(() => PaymentScreen());
                }
              },
              icon: const Icon(
                Icons.notifications_active_rounded,
                size: 20,
              ),
              label: const Text(
                'Set as Ringtone',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Colors.white.withValues(alpha: 0.18),
                foregroundColor: Colors.white,
                elevation: 0,
                side: BorderSide(
                  color:
                  Colors.white.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _setRingtone(String url) async {
    try {
      final success =
      await RingtoneSet.setRingtoneFromNetwork(url);

      if (success) {
        Fluttertoast.showToast(
          msg: 'Ringtone set successfully',
        );

        audioCtr.stopAudio();
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to set ringtone',
        );
      }
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Failed to set ringtone',
      );
    }
  }
}

class _Equalizer extends StatelessWidget {
  final AnimationController controller;

  const _Equalizer({
    required this.controller,
  });

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
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: List.generate(4, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 2,
            ),
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                final t =
                ((controller.value + i * 0.22) % 1.0);

                final wave =
                (t < 0.5 ? t * 2 : (1 - t) * 2);

                final h = 6 + wave * 14;

                return Container(
                  width: 3,
                  height: h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(2),
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