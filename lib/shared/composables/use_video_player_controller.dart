import 'dart:async';

import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:http_cache_stream/http_cache_stream.dart';
import 'package:video_player/video_player.dart';

/// Result returned by [useVideoPlayerController].
typedef VideoPlayerState = ({
  /// Reactive ref to the underlying controller.
  /// Reading `.value` in the render function establishes a reactive dependency
  /// that re-triggers on every controller notification (play/pause/seek/etc.).
  ReadonlyRef<VideoPlayerController> controllerRef,

  /// Whether the controller has been successfully initialised.
  Ref<bool> isInitialized,

  /// Reactive playing state derived via `computed` from controller
  /// notifications — only triggers rebuilds when playing/paused changes.
  ReadonlyRef<bool> isPlaying,

  /// Whether initialisation failed.
  Ref<bool> hasError,

  /// Detected aspect ratio (defaults to 16:9 before init).
  Ref<double> aspectRatio,

  /// Initialise the controller (call once when first visible).
  Future<void> Function() initialize,

  /// Start playback.
  Future<void> Function() play,

  /// Pause playback.
  Future<void> Function() pause,

  /// Toggle between play and pause.
  Future<void> Function() togglePlayPause,
});

/// Creates a [VideoPlayerController] with automatic lifecycle management.
///
/// Video caching is handled by `http_cache_stream`'s local proxy server.
/// The URL is routed through the proxy via
/// `HttpCacheManager.instance.createStream()`,
/// which enables play-while-caching and supports m3u8/mp4.
VideoPlayerState useVideoPlayerController({
  required String url,
  bool loop = false,
  bool muted = false,
}) {
  final cacheStream =
      HttpCacheManager.instance.createStream(Uri.parse(url));

  // useController handles reactive tracking + automatic disposal.
  final controllerRef = useController(
    () => VideoPlayerController.networkUrl(cacheStream.cacheUrl),
  );

  final isInitialized = ref(false);
  final hasError = ref(false);
  final aspectRatio = ref(16.0 / 9.0);
  var isInitializing = false;

  // Cache stream is not a ChangeNotifier — clean up manually.
  onUnmounted(() {
    unawaited(cacheStream.dispose());
  });

  // Derived playing state — re-evaluates on controller notifications
  // but only triggers rebuilds when actual playing state changes.
  final isPlaying = computed(() {
    final ctrl = controllerRef.value;
    return ctrl.value.isPlaying;
  });

  Future<void> initialize() async {
    if (isInitialized.value || isInitializing) return;
    isInitializing = true;
    hasError.value = false;
    try {
      final ctrl = controllerRef.value;
      await ctrl.setLooping(loop);
      if (muted) await ctrl.setVolume(0);
      await ctrl.initialize();
      aspectRatio.value = ctrl.value.aspectRatio;
      isInitialized.value = true;
    } on Exception catch (_) {
      hasError.value = true;
    } finally {
      isInitializing = false;
    }
  }

  Future<void> play() async {
    if (!isInitialized.value) return;
    await controllerRef.value.play();
  }

  Future<void> pause() async {
    if (!isInitialized.value) return;
    await controllerRef.value.pause();
  }

  Future<void> togglePlayPause() async {
    if (!isInitialized.value) return;
    final ctrl = controllerRef.value;
    if (ctrl.value.isPlaying) {
      await ctrl.pause();
    } else {
      await ctrl.play();
    }
  }

  return (
    controllerRef: controllerRef,
    isInitialized: isInitialized,
    isPlaying: isPlaying,
    hasError: hasError,
    aspectRatio: aspectRatio,
    initialize: initialize,
    play: play,
    pause: pause,
    togglePlayPause: togglePlayPause,
  );
}
