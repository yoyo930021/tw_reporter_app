import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/shared/composables/use_scroll_visibility.dart';
import 'package:tw_reporter_app/shared/composables/use_video_player_controller.dart';
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
    final player = useVideoPlayerController(
      url: url,
      loop: loop,
      muted: muted,
    );

    // Track whether we should auto-resume when scrolling back into view.
    var shouldAutoResume = autoplay;
    // Track whether play has ever started — suppresses the center play
    // button during the brief gap between init and autoplay start.
    final hasEverPlayed = ref(false);

    final isVisible = useScrollVisibility();

    watch(() => isVisible.value, (visible, _) {
      if (visible) {
        if (!player.isInitialized.value) {
          // Not yet initialized — start init and autoplay when ready.
          unawaited(
            player.initialize().then((_) {
              if (player.isInitialized.value && shouldAutoResume) {
                unawaited(player.play());
                hasEverPlayed.value = true;
              }
            }),
          );
        } else if (shouldAutoResume) {
          // Already initialized — start playback now.
          unawaited(player.play());
          hasEverPlayed.value = true;
        }
      } else {
        if (player.isInitialized.value) {
          shouldAutoResume = player.isPlaying.value || autoplay;
          unawaited(player.pause());
        }
      }
    });

    return (BuildContext context) {
      final colors = Theme.of(context).colorScheme;

      Widget content;
      if (player.hasError.value) {
        content = const ColoredBox(
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
      } else if (!player.isInitialized.value) {
        content = GestureDetector(
          onTap: () {
            hasEverPlayed.value = true;
            unawaited(
              player.initialize().then((_) {
                if (player.isInitialized.value) {
                  unawaited(player.play());
                }
              }),
            );
          },
          child: const ColoredBox(
            color: AppColors.grey200,
            child: Center(
              child: Icon(
                Icons.play_circle_outline,
                color: AppColors.grey400,
                size: 48,
              ),
            ),
          ),
        );
      } else {
        final isPlaying = player.isPlaying.value;
        final showPlayOverlay = !isPlaying && hasEverPlayed.value;
        content = GestureDetector(
          onTap: () {
            hasEverPlayed.value = true;
            unawaited(player.togglePlayPause());
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              VideoPlayer(player.controllerRef.raw),
              if (showPlayOverlay)
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white70,
                  ),
                ),
              VideoProgressIndicator(
                player.controllerRef.raw,
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppSpacing.radiusSm,
            ),
            child: AspectRatio(
              aspectRatio: player.aspectRatio.value,
              child: content,
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
