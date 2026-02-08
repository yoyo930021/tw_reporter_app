import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/shared/composables/use_scroll_visibility.dart';
import 'package:video_player/video_player.dart';

/// Widget that plays embedded videos using the video_player package.
/// Lazily initializes the player when first visible and pauses when off-screen.
class EmbeddedVideoPlayer extends StatelessWidget {
  /// Creates an [EmbeddedVideoPlayer].
  const EmbeddedVideoPlayer({
    required this.url,
    this.autoplay = false,
    this.muted = false,
    this.loop = false,
    this.caption,
    super.key,
  });

  /// The URL of the video to play.
  final String url;

  /// Whether the video should autoplay.
  final bool autoplay;

  /// Whether the video should be muted.
  final bool muted;

  /// Whether the video should loop.
  final bool loop;

  /// Optional caption displayed below the video.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return _EmbeddedVideoPlayerContent(
      url: url,
      autoplay: autoplay,
      muted: muted,
      loop: loop,
      caption: caption,
    );
  }
}

class _EmbeddedVideoPlayerContent extends CompositionWidget {
  const _EmbeddedVideoPlayerContent({
    required this.url,
    this.autoplay = false,
    this.muted = false,
    this.loop = false,
    this.caption,
  });

  final String url;
  final bool autoplay;
  final bool muted;
  final bool loop;
  final String? caption;

  @override
  Widget Function(BuildContext context) setup() {
    final controllerRef = ref<VideoPlayerController?>(null);
    final isInitialized = ref<bool>(false);
    final hasError = ref<bool>(false);
    final hasStartedInit = ref<bool>(false);
    final wasPlaying = ref<bool>(false);
    final disposed = ref<bool>(false);
    final lastAspectRatio = ref<double>(16.0 / 9.0);
    var isDisposing = false;

    // Forward-declare functions that have circular dependencies with
    // useScrollVisibility: the onChanged closure references both
    // initializePlayer and disposeController, while initializePlayer
    // references isVisible from useScrollVisibility.
    late final Future<void> Function() initializePlayer;
    late final void Function() disposeController;

    final (visibilityKey, isVisible) = useScrollVisibility(
      onChanged: ({required visible}) {
        if (visible) {
          if (!hasStartedInit.value || disposed.value) {
            unawaited(initializePlayer());
          } else if (isInitialized.value && controllerRef.value != null) {
            unawaited(controllerRef.value!.play());
          }
        } else {
          if (controllerRef.value != null && isInitialized.value) {
            disposeController();
          }
        }
      },
    );

    void onControllerUpdate() {
      if (controllerRef.value == null || isDisposing) return;
      final isPlaying = controllerRef.value!.value.isPlaying;
      if (isPlaying != wasPlaying.value) {
        wasPlaying.value = isPlaying;
      }
    }

    disposeController = () {
      controllerRef.value?.removeListener(onControllerUpdate);
      unawaited(controllerRef.value?.dispose());
      controllerRef.value = null;
      isInitialized.value = false;
      wasPlaying.value = false;
      disposed.value = true;
    };

    initializePlayer = () async {
      if (isInitialized.value && !disposed.value) return;
      hasStartedInit.value = true;
      disposed.value = false;
      hasError.value = false;

      controllerRef.value = VideoPlayerController.networkUrl(
        Uri.parse(url),
      );
      controllerRef.value!.addListener(onControllerUpdate);

      await controllerRef.value!.setLooping(loop);
      if (muted) {
        await controllerRef.value!.setVolume(0);
      }
      try {
        await controllerRef.value!.initialize();
        if (disposed.value) return;
        lastAspectRatio.value = controllerRef.value!.value.aspectRatio;
        isInitialized.value = true;
        if (isVisible.value) {
          await controllerRef.value!.play();
        }
      } on Exception catch (_) {
        if (disposed.value) return;
        hasError.value = true;
      }
    };

    onUnmounted(() {
      isDisposing = true;
      disposeController();
    });

    Future<void> togglePlayPause() async {
      if (controllerRef.value == null || !isInitialized.value) return;
      if (controllerRef.value!.value.isPlaying) {
        await controllerRef.value!.pause();
      } else {
        await controllerRef.value!.play();
      }
    }

    Widget buildVideoContent() {
      if (hasError.value) {
        return const ColoredBox(
          color: AppColors.grey200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.error_outline,
                  color: AppColors.grey400,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  '影片載入失敗',
                  style: TextStyle(color: AppColors.grey400),
                ),
              ],
            ),
          ),
        );
      }

      if (!isInitialized.value) {
        return const ColoredBox(
          color: AppColors.grey200,
          child: Center(
            child: Icon(
              Icons.play_circle_outline,
              color: AppColors.grey400,
              size: 48,
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: togglePlayPause,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(controllerRef.value!),
            if (!controllerRef.value!.value.isPlaying)
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white70,
                ),
              ),
            VideoProgressIndicator(
              controllerRef.value!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.secondary,
                bufferedColor: AppColors.grey300,
                backgroundColor: AppColors.grey200,
              ),
            ),
          ],
        ),
      );
    }

    return (BuildContext context) {
      final colors = Theme.of(context).colorScheme;

      return Column(
        key: visibilityKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppSpacing.radiusSm,
            ),
            child: AspectRatio(
              aspectRatio: lastAspectRatio.value,
              child: buildVideoContent(),
            ),
          ),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
              ),
              child: Text(
                caption!,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      );
    };
  }
}
