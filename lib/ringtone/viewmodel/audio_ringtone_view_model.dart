import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioRingtoneViewModel extends GetxController with WidgetsBindingObserver {

  late AudioPlayer audioPlayer;

  /// currently playing ringtone index (kept for legacy list screens)
  RxInt playingIndex = (-1).obs;

  /// unique key of the card that's currently playing (e.g. "ringtone_5").
  /// Use this when multiple card types share id space.
  RxString playingKey = ''.obs;

  /// play/pause state
  RxBool isPlaying = false.obs;

  /// audio duration
  Rx<Duration> duration = Duration.zero.obs;

  /// current audio position
  Rx<Duration> position = Duration.zero.obs;

  /// loading indicator
  RxBool loading = false.obs;

  int _playRequestId = 0;

  /// false while the app is minimized / not the active window
  bool appInForeground = true;

  /// set when the lifecycle handler pauses playback, so we know to resume it
  /// when the app comes back to the foreground.
  bool _resumeOnForeground = false;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    audioPlayer = AudioPlayer();

    /// listen duration
    audioPlayer.durationStream.listen((d) {
      if (d != null) {
        duration.value = d;
      }
    });

    /// listen position
    audioPlayer.positionStream.listen((p) {
      position.value = p;
    });

    /// listen player state
    audioPlayer.playerStateStream.listen((state) {

      loading.value =
          state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;

      /// keep isPlaying in sync with the player itself — play() returns a
      /// Future that completes when playback stops, not when it starts, so
      /// we can't rely on awaiting it to flip this flag.
      isPlaying.value = state.playing &&
          state.processingState != ProcessingState.completed;

      if (state.processingState == ProcessingState.completed) {
        stopAudio();
      }
    });
  }

  /// ExoPlayer keeps running once the app is backgrounded, so the app
  /// lifecycle has to pause it by hand and resume it on the way back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      appInForeground = true;

      if (_resumeOnForeground && playingKey.value.isNotEmpty) {
        _resumeOnForeground = false;

        audioPlayer.play().catchError((_) {});
      }

      return;
    }

    /// inactive / paused / hidden / detached — the app is not in front.
    appInForeground = false;

    if (audioPlayer.playing) {
      /// nothing to come back to once the engine is detaching
      _resumeOnForeground = state != AppLifecycleState.detached;

      audioPlayer.pause().catchError((_) {});
    }
  }

  /// play / pause ringtone (legacy int-index API, used by list screens)
  Future<void> playPause(int index, String url) =>
      playPauseKey('legacy_$index', index, url);

  /// play / pause by unique string key. Cards should pass a namespaced key
  /// like "ringtone_$id" / "alarm_$id" so different card types never collide.
  Future<void> playPauseKey(String key, int legacyIndex, String url) async {
    /// never start audio while minimized
    if (!appInForeground) return;

    /// same card → toggle pause / resume (don't reset state)
    if (playingKey.value == key) {
      if (loading.value) {
        await stopAudio();
        return;
      }
      try {
        if (isPlaying.value) {
          await audioPlayer.pause();
          isPlaying.value = false;
          _resumeOnForeground = false;
        } else {
          await audioPlayer.play();
          isPlaying.value = true;
        }
      } catch (e) {
        log("Audio toggle error: $e");
      }
      return;
    }

    final requestId = ++_playRequestId;

    /// reflect the tap immediately so UI is responsive
    playingKey.value = key;
    playingIndex.value = legacyIndex;
    isPlaying.value = false;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    loading.value = true;

    try {
      /// stop previous ringtone
      await audioPlayer.stop();
      if (requestId != _playRequestId) return;

      /// load url
      await audioPlayer.setUrl(url);
      if (requestId != _playRequestId) return;

      /// the app was minimized while the url was loading — the source is
      /// attached now, so park it and let the lifecycle resume handle it.
      if (!appInForeground) {
        _resumeOnForeground = true;
        loading.value = false;
        return;
      }

      /// play
      await audioPlayer.play();
      if (requestId != _playRequestId) return;

      isPlaying.value = true;
    } catch (e) {
      log("Audio play error: $e");
      if (requestId == _playRequestId) {
        loading.value = false;
      }
    }
  }

  /// seek audio
  Future<void> seek(double value) async {
    try {
      final newPosition = Duration(seconds: value.toInt());
      await audioPlayer.seek(newPosition);
    } catch (e) {
      log("Seek error: $e");
    }
  }

  /// stop audio
  Future<void> stopAudio() async {
    _playRequestId++;
    _resumeOnForeground = false;
    try {
      await audioPlayer.stop();
    } catch (e) {
      log("Stop error: $e");
    }

    isPlaying.value = false;
    playingIndex.value = -1;
    playingKey.value = '';
    position.value = Duration.zero;
    loading.value = false;
  }

  /// format duration mm:ss
  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));

    return "$minutes:$seconds";
  }

  /// set ringtone (platform specific)
  void setRingtone() {
    if (playingIndex.value == -1) {
      Get.snackbar("Error", "Please select a ringtone first");
      return;
    }

    /// TODO: Implement Android native ringtone setting
    Get.snackbar("Success", "Ringtone set successfully");
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    audioPlayer.dispose();
    super.onClose();
  }
}