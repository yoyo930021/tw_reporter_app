import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/shared/utils/scroll_visibility_mixin.dart';
import 'package:video_player/video_player.dart';

/// Widget that plays embedded videos using the video_player package.
/// Lazily initializes the player when first visible and pauses when off-screen.
class EmbeddedVideoPlayer extends StatefulWidget {
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
  State<EmbeddedVideoPlayer> createState() =>
      _EmbeddedVideoPlayerState();
}

class _EmbeddedVideoPlayerState extends State<EmbeddedVideoPlayer>
    with ScrollVisibilityMixin<EmbeddedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _hasStartedInit = false;
  bool _wasPlaying = false;
  bool _disposed = false;
  double _lastAspectRatio = 16 / 9;

  @override
  void onVisibilityChanged({required bool visible}) {
    if (visible) {
      if (!_hasStartedInit || _disposed) {
        unawaited(_initializePlayer());
      } else if (_isInitialized &&
          !_controller!.value.isPlaying) {
        unawaited(_controller!.play());
      }
    } else {
      // Off-screen: dispose controller to free memory
      if (_controller != null && _isInitialized) {
        _disposeController();
      }
    }
  }

  Future<void> _initializePlayer() async {
    if (_isInitialized && !_disposed) return;
    _hasStartedInit = true;
    _disposed = false;
    _hasError = false;

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );
    _controller!.addListener(_onControllerUpdate);

    await _controller!.setLooping(widget.loop);
    if (widget.muted) {
      await _controller!.setVolume(0);
    }
    try {
      await _controller!.initialize();
      if (!mounted || _disposed) return;
      _lastAspectRatio = _controller!.value.aspectRatio;
      setState(() => _isInitialized = true);
      if (isVisibleInViewport) {
        await _controller!.play();
      }
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  void _disposeController() {
    _controller?.removeListener(_onControllerUpdate);
    unawaited(_controller?.dispose());
    _controller = null;
    _isInitialized = false;
    _wasPlaying = false;
    _disposed = true;
    if (mounted) setState(() {});
  }

  /// Listen to play state changes to show/hide the play button overlay.
  void _onControllerUpdate() {
    if (_controller == null) return;
    final bool isPlaying = _controller!.value.isPlaying;
    if (isPlaying != _wasPlaying) {
      _wasPlaying = isPlaying;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusSm,
          ),
          child: AspectRatio(
            aspectRatio: _lastAspectRatio,
            child: _buildVideoContent(),
          ),
        ),
        if (widget.caption != null &&
            widget.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
            ),
            child: Text(
              widget.caption!,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
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

    if (!_isInitialized) {
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
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayer(_controller!),
          if (!_controller!.value.isPlaying)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 64,
                color: Colors.white70,
              ),
            ),
          VideoProgressIndicator(
            _controller!,
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
}
