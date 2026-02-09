import 'dart:async';
import 'dart:io';

import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/cache/video_cache_service.dart';
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
/// The controller is created eagerly and managed by `manageChangeNotifier`,
/// which handles both listener tracking and disposal on unmount — the same
/// pattern used by `useScrollController`.
///
/// If [videoCacheService] is provided and the video is already cached locally,
/// the controller is created from the local file. Otherwise it uses the
/// network URL. Background caching is triggered during `initialize` so that
/// subsequent plays use the local file.
///
/// The returned `isPlaying` is a `computed` derived from the controller's
/// change notifications — it re-evaluates on every notification but only
/// triggers a widget rebuild when the playing state actually changes.
VideoPlayerState useVideoPlayerController({
  required String url,
  bool loop = false,
  bool muted = false,
  VideoCacheService? videoCacheService,
}) {
  // Create controller eagerly — check local cache synchronously.
  VideoPlayerController createController() {
    if (videoCacheService != null) {
      final cachedPath = videoCacheService.getCachedFilePath(url);
      if (File(cachedPath).existsSync()) {
        return VideoPlayerController.file(File(cachedPath));
      }
    }
    return VideoPlayerController.networkUrl(Uri.parse(url));
  }

  final controllerRef = manageChangeNotifier(createController());

  final isInitialized = ref(false);
  final hasError = ref(false);
  final aspectRatio = ref(16.0 / 9.0);
  var isInitializing = false;

  // Derived from controller notifications via manageChangeNotifier.
  final isPlaying = computed(() {
    controllerRef.value; // Establish reactive dependency
    return controllerRef.value.value.isPlaying;
  });

  Future<void> initialize() async {
    if (isInitialized.value || isInitializing) return;
    isInitializing = true;
    hasError.value = false;
    try {
      final controller = controllerRef.value;
      await controller.setLooping(loop);
      if (muted) await controller.setVolume(0);
      await controller.initialize();
      aspectRatio.value = controller.value.aspectRatio;
      isInitialized.value = true;

      // Trigger background caching for next time
      if (videoCacheService != null) {
        unawaited(videoCacheService.getVideoPath(url));
      }
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
    final controller = controllerRef.value;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
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
