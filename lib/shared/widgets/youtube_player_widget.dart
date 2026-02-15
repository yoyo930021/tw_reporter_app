import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/shared/widgets/cached_image.dart';
import 'package:tw_reporter_app/shared/widgets/embedded_webview.dart';

/// Builds an HTML page with a YouTube embed iframe.
String _buildYoutubeIframeHtml(String videoId) {
  const style = 'position:absolute;top:0;left:0;'
      'width:100%;height:100%;border:none';
  final src = 'https://www.youtube.com/embed/$videoId'
      '?playsinline=1&rel=0&modestbranding=1&autoplay=1';
  const allow = 'accelerometer; autoplay; clipboard-write;'
      ' encrypted-media; gyroscope; picture-in-picture';
  return '<iframe style="$style" src="$src"'
      ' allow="$allow" allowfullscreen></iframe>';
}

/// Fetches the video title from YouTube oEmbed API.
Future<String?> _fetchYoutubeTitle(String videoId) async {
  try {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.parse(
          'https://www.youtube.com/oembed'
          '?url=https://www.youtube.com/watch?v=$videoId'
          '&format=json',
        ),
      );
      final response = await request.close();
      if (response.statusCode == 200) {
        final body =
            await response.transform(utf8.decoder).join();
        final data =
            jsonDecode(body) as Map<String, dynamic>;
        return data['title'] as String?;
      }
    } finally {
      client.close();
    }
  } on Exception {
    // Title is optional — fail silently.
  }
  return null;
}

/// Widget that plays YouTube videos.
///
/// Shows a thumbnail preview by default. Tapping the preview loads the
/// actual YouTube embed inside [EmbeddedWebView] with `baseUrl` set to
/// `https://www.twreporter.org` for a valid origin.
class YoutubePlayerWidget extends CompositionWidget {
  const YoutubePlayerWidget({
    required this.videoId,
    this.caption,
    super.key,
  });

  final String videoId;
  final String? caption;

  @override
  Widget Function(BuildContext) setup() {
    final isPlaying = ref(false);
    final videoTitle = ref<String?>(null);
    final theme = useTheme();

    onMounted(() async {
      videoTitle.value = await _fetchYoutubeTitle(videoId);
    });

    return (BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isPlaying.value)
            LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxWidth * 9 / 16;
                return EmbeddedWebView(
                  htmlData:
                      _buildYoutubeIframeHtml(videoId),
                  height: height,
                  baseUrl: 'https://www.twreporter.org',
                );
              },
            )
          else
            _YoutubePreview(
              videoId: videoId,
              title: videoTitle.value,
              colors: theme.value.colorScheme,
              textTheme: theme.value.textTheme,
              onPlay: () => isPlaying.value = true,
            ),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                caption!,
                style:
                    theme.value.textTheme.bodySmall!.copyWith(
                  color: theme
                      .value.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      );
    };
  }
}

class _YoutubePreview extends StatelessWidget {
  const _YoutubePreview({
    required this.videoId,
    required this.title,
    required this.colors,
    required this.textTheme,
    required this.onPlay,
  });

  final String videoId;
  final String? title;
  final ColorScheme colors;
  final TextTheme textTheme;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl =
        'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return GestureDetector(
      onTap: onPlay,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Thumbnail
            CachedImage(
              imageUrl: thumbnailUrl,
              errorWidget: ColoredBox(
                color: colors.surfaceContainer,
                child: Icon(
                  Icons.image_not_supported,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            // Dark gradient overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      if (title != null)
                        Text(
                          title!,
                          style:
                              textTheme.bodyMedium!.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '來自 YouTube',
                        style:
                            textTheme.bodySmall!.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Play button
            const Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
