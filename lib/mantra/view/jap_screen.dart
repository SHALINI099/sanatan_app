import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/storage/app_dimensions.dart';
import '../../core/storage/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../data/model/MantraListModel.dart';

class JapScreen extends StatefulWidget {
  final PostDatum mantra;

  const JapScreen({super.key, required this.mantra});

  @override
  State<JapScreen> createState() => _JapScreenState();
}

class _JapScreenState extends State<JapScreen>
    with WidgetsBindingObserver {
  static const int _roundSize = 108;

  final RxInt _count = 0.obs;
  final RxBool _isPlaying = false.obs;
  final RxBool _isPaused = false.obs;

  /// ExoPlayer-backed (just_audio); see AudioViewModel for why audioplayers'
  /// MediaPlayer backend was dropped (main-thread binder ANRs).
  final AudioPlayer _player = AudioPlayer();

  /// false while the app is minimized / not the active window
  bool _inForeground = true;

  /// set when the lifecycle handler pauses playback, so we know to resume it
  /// when the app comes back to the foreground.
  bool _resumeOnForeground = false;

  int get _rounds => _count.value ~/ _roundSize;

  int get _inRound => _count.value % _roundSize;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    /// When audio completes → count + replay
    _player.playerStateStream.listen((state) {
      if (state.processingState != ProcessingState.completed) return;

      _isPlaying.value = false;

      /// don't let the replay loop restart audio while minimized
      if (!_inForeground) return;

      _increment();
      _replay();
    });

    _playAudio();
  }

  /// The source is already attached, so a replay is a seek to the start.
  /// ExoPlayer stays "playing" at the end of a track and does nothing on a
  /// bare play(), which is why this does not go through _playAudio().
  Future<void> _replay() async {
    try {
      _isPlaying.value = true;
      await _player.seek(Duration.zero);
      _play();
    } catch (e) {
      debugPrint("Audio replay error: $e");
      _isPlaying.value = false;
    }
  }

  /// just_audio's play() completes when playback STOPS, not when it starts,
  /// so it is never awaited on a control path.
  void _play() {
    _player.play().catchError((_) {});
  }

  /// audioplayers keeps a bare MediaPlayer alive across backgrounding, so the
  /// app lifecycle has to pause it by hand and resume it on the way back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _inForeground = true;

      /// a manual pause (_isPaused) outranks this — leave it alone
      if (_resumeOnForeground && !_isPaused.value) {
        _resumeOnForeground = false;

        _play();
      }

      return;
    }

    /// inactive / paused / hidden / detached — the app is not in front.
    _inForeground = false;

    if (_isPlaying.value && !_isPaused.value) {
      /// nothing to come back to once the engine is detaching
      _resumeOnForeground = state != AppLifecycleState.detached;

      _player.pause().catchError((_) {});
    }
  }

  Future<void> _playAudio() async {
    /// never start audio while minimized
    if (!_inForeground) return;

    final url = widget.mantra.mantraUrl;

    if (url.isEmpty) return;

    if (_isPlaying.value) return;

    if (Uri.tryParse(url)?.hasAbsolutePath != true) {
      debugPrint("Invalid URL");
      return;
    }

    try {
      _isPlaying.value = true;
      await _player.setUrl(url);

      /// the app was minimized while the source was loading — the source is
      /// attached now, so park it and let the lifecycle resume handle it.
      if (!_inForeground) {
        _resumeOnForeground = true;
        return;
      }

      _play();
    } catch (e) {
      debugPrint("Audio play error: $e");
      _isPlaying.value = false;
    }
  }

  void _increment() {
    HapticFeedback.lightImpact();
    _count.value++;
  }

  void _reset() {
    _count.value = 0;
  }

  Future<void> _togglePlayPause() async {
    if (_isPaused.value) {
      _play();
    } else {
      await _player.pause();

      /// a deliberate pause outranks a pending lifecycle resume
      _resumeOnForeground = false;
    }
    _isPaused.value = !_isPaused.value;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("tests ${widget.mantra.thumbnail}");
    final m = widget.mantra;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.black,
        ),
        title: Text(
          "Jap",
          style: TextStyle(
            fontSize: AppDimensions.fontSize20,
            fontWeight: AppDimensions.fontWeight600,
            color: AppColors.black,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// HERO HEADER
            _buildHero(m),

            /// JAAP COUNTER AREA
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _increment,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoundsChip(),
                      AppSpacing.height(24),
                      _buildCounterRing(),
                      AppSpacing.height(20),
                      Text(
                        "Tap anywhere to count",
                        style: TextStyle(
                          fontSize: AppDimensions.fontSize13,
                          color: AppColors.grey,
                          fontWeight: AppDimensions.fontWeight500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// BOTTOM ACTIONS
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(PostDatum m) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.18),
            AppColors.primaryColor.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 72,
              height: 72,
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              child: m.thumbnail.isEmpty
                  ? Icon(
                      Icons.self_improvement_rounded,
                      color: AppColors.primaryColor,
                      size: 36,
                    )
                  : Image.network(
                      m.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.self_improvement_rounded,
                        color: AppColors.primaryColor,
                        size: 36,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  m.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppDimensions.fontSize16,
                    fontWeight: AppDimensions.fontWeight700,
                    color: AppColors.black,
                    letterSpacing: 0.2,
                  ),
                ),
                if (m.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    m.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppDimensions.fontSize12,
                      color: AppColors.grey,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundsChip() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.loop_rounded,
              size: 14,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              "Round $_rounds",
              style: TextStyle(
                fontSize: AppDimensions.fontSize13,
                color: AppColors.primaryColor,
                fontWeight: AppDimensions.fontWeight600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRing() {
    return Obx(() {
      final progress = _inRound / _roundSize;
      return SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                backgroundColor:
                    AppColors.primaryColor.withValues(alpha: 0.12),
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${_count.value}",
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: AppDimensions.fontWeight700,
                    color: AppColors.primaryColor,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$_inRound / $_roundSize",
                    style: TextStyle(
                      fontSize: AppDimensions.fontSize13,
                      color: AppColors.primaryColor,
                      fontWeight: AppDimensions.fontWeight600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _circleAction(
                icon: Icons.restart_alt_rounded,
                onTap: _reset,
                tooltip: "Reset",
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: _increment,
                    icon: const Icon(Icons.touch_app_rounded, size: 22),
                    label: Text(
                      "Count",
                      style: TextStyle(
                        fontSize: AppDimensions.fontSize18,
                        fontWeight: AppDimensions.fontWeight700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.white,
                      elevation: 6,
                      shadowColor:
                          AppColors.primaryColor.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => _circleAction(
                  icon: _isPaused.value
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  onTap: _togglePlayPause,
                  tooltip: _isPaused.value ? "Resume" : "Pause",
                  filled: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool filled = false,
  }) {
    final bg = filled
        ? AppColors.primaryColor
        : AppColors.primaryColor.withValues(alpha: 0.12);
    final fg = filled ? AppColors.white : AppColors.primaryColor;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        elevation: filled ? 6 : 0,
        shadowColor: AppColors.primaryColor.withValues(alpha: 0.4),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 58,
            height: 58,
            child: Icon(icon, size: 26, color: fg),
          ),
        ),
      ),
    );
  }
}
