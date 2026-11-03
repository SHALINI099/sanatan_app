import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioViewModel extends GetxController with WidgetsBindingObserver {
  /// ExoPlayer-backed (just_audio). The previous audioplayers/MediaPlayer
  /// backend drove every start/resume through MediaPlayer.setPlaybackParams
  /// on the Android main thread — a binder call into mediaserver that stalls
  /// while a network source is still buffering. That was the
  /// "MediaPlayerWrapper.setRate / Slow Binder call" ANR cluster in Play
  /// Console. ExoPlayer does its playback work on its own thread.
  final AudioPlayer player = AudioPlayer();

  RxBool isPlaying = false.obs;
  RxBool loading = false.obs;

  RxString playingKey = ''.obs;

  RxInt currentIndex = (-1).obs;

  Rx<Duration> duration = Duration.zero.obs;
  Rx<Duration> position = Duration.zero.obs;

  /// Prevent multiple simultaneous play/pause calls
  bool _busy = false;

  /// false while the app is minimized / not the active window. Cards read this
  /// so the VisibilityDetector autoplay can't start audio in the background.
  bool appInForeground = true;

  /// set when the lifecycle handler pauses playback, so we know to resume it
  /// (and only it) when the app comes back to the foreground.
  bool _resumeOnForeground = false;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    player.durationStream.listen((d) {
      if (d != null) duration.value = d;
    });

    player.positionStream.listen((p) {
      position.value = p;
    });

    player.playerStateStream.listen((state) {
      final completed = state.processingState == ProcessingState.completed;

      isPlaying.value = state.playing && !completed;

      if (completed) {
        position.value = Duration.zero;

        /// ExoPlayer stays "playing" at the end of the track. Park it at the
        /// start so the card's play button (and a lifecycle resume) restarts
        /// it instead of silently doing nothing.
        player.pause().catchError((_) {});
        player.seek(Duration.zero).catchError((_) {});
      }
    });
  }

  /// ExoPlayer keeps running once the app is backgrounded, so the app
  /// lifecycle has to drive it by hand. Deliberately does NOT go through
  /// pauseAudio()/_busy — a card call in flight would make this a silent no-op.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      appInForeground = true;

      if (_resumeOnForeground && playingKey.value.isNotEmpty) {
        _resumeOnForeground = false;

        _play();
        isPlaying.value = true;
      }

      return;
    }

    /// inactive / paused / hidden / detached — the app is not in front.
    appInForeground = false;

    if (player.playing) {
      /// nothing to come back to once the engine is detaching
      _resumeOnForeground = state != AppLifecycleState.detached;

      player.pause().then((_) {
        isPlaying.value = false;
      }).catchError((_) {});
    }
  }

  /// just_audio's play() completes when playback STOPS, not when it starts,
  /// so it is never awaited on a control path.
  void _play() {
    player.play().catchError((_) {});
  }

  /// PLAY AUDIO
  Future<void> playAudio({
    required String key,
    required int index,
    required String url,
  }) async {
    /// never start audio while minimized (feed autoplay fires from
    /// VisibilityDetector, which doesn't know about the app lifecycle)
    if (!appInForeground) return;

    try {
      /// avoid duplicate calls
      if (_busy) return;

      _busy = true;

      loading.value = true;

      /// SAME AUDIO -> RESUME
      if (playingKey.value == key) {
        final state = player.playerState;

        /// already running — don't restart it from 0:00
        if (state.playing &&
            state.processingState != ProcessingState.completed) {
          isPlaying.value = true;
          return;
        }

        /// finished — restart from the top
        if (state.processingState == ProcessingState.completed) {
          await player.seek(Duration.zero);
          _play();
          isPlaying.value = true;
          return;
        }

        /// paused with the source still attached
        if (state.processingState != ProcessingState.idle) {
          _play();
          isPlaying.value = true;
          return;
        }
      }

      /// STOP OLD AUDIO
      await player.stop();

      playingKey.value = key;
      currentIndex.value = index;

      position.value = Duration.zero;
      duration.value = Duration.zero;

      await player.setUrl(url);

      /// the app was minimized while the source was loading — the source is
      /// attached now, so park it and let the lifecycle resume handle it.
      if (!appInForeground) {
        _resumeOnForeground = true;

        isPlaying.value = false;

        return;
      }

      _play();

      isPlaying.value = true;
    } catch (e) {
      debugPrint('AudioViewModel.playAudio: $e');
    } finally {
      loading.value = false;
      _busy = false;
    }
  }

  /// PAUSE AUDIO
  Future<void> pauseAudio() async {
    try {
      if (_busy) return;

      _busy = true;

      if (player.playing) {
        await player.pause();
      }

      isPlaying.value = false;

      /// a deliberate pause outranks a pending lifecycle resume
      _resumeOnForeground = false;
    } catch (e) {
      debugPrint('AudioViewModel.pauseAudio: $e');
    } finally {
      _busy = false;
    }
  }

  /// STOP AUDIO
  Future<void> stopAudio() async {
    try {
      if (_busy) return;

      _busy = true;

      await player.stop();

      isPlaying.value = false;

      playingKey.value = '';

      currentIndex.value = -1;

      position.value = Duration.zero;
      duration.value = Duration.zero;

      _resumeOnForeground = false;
    } catch (e) {
      debugPrint('AudioViewModel.stopAudio: $e');
    } finally {
      _busy = false;
    }
  }

  /// SEEK
  Future<void> seek(double value) async {
    try {
      await player.seek(
        Duration(seconds: value.toInt()),
      );
    } catch (e) {
      debugPrint('AudioViewModel.seek: $e');
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    player.dispose();
    super.onClose();
  }
}
