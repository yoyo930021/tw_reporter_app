import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/composables.dart';
import 'package:tw_reporter_app/core/settings/media_load_mode.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';

/// 媒體類型（用於顯示對應圖示）
enum MediaType {
  video,
  webview,
  image,
  youtube,
  imagediff,
  slideshow,
}

/// 根據 [MediaLoadMode] 決定是否延遲載入媒體內容。
///
/// - [MediaLoadMode.normal]：直接渲染 [child]
/// - [MediaLoadMode.dataSaving]：顯示佔位符（對應圖示 + 「點擊載入」），
///   tap 後渲染 [child]
class TapToLoadWrapper extends StatelessWidget {
  const TapToLoadWrapper({
    required this.mediaType,
    required this.child,
    this.aspectRatio = 16 / 9,
    super.key,
  });

  final MediaType mediaType;
  final Widget child;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return _TapToLoadWrapperContent(
      mediaType: mediaType,
      aspectRatio: aspectRatio,
      child: child,
    );
  }
}

class _TapToLoadWrapperContent extends CompositionWidget {
  const _TapToLoadWrapperContent({
    required this.mediaType,
    required this.child,
    required this.aspectRatio,
  });

  final MediaType mediaType;
  final Widget child;
  final double aspectRatio;

  @override
  Widget Function(BuildContext) setup() {
    final mediaLoadModeRef = useMediaLoadMode();
    final isLoaded = ref(false);

    return (BuildContext context) =>
        (mediaLoadModeRef.value != MediaLoadMode.dataSaving ||
                isLoaded.value)
            ? child
            : _TapToLoadPlaceholder(
                mediaType: mediaType,
                aspectRatio: aspectRatio,
                onTap: () => isLoaded.value = true,
              );
  }
}

class _TapToLoadPlaceholder extends StatelessWidget {
  const _TapToLoadPlaceholder({
    required this.mediaType,
    required this.aspectRatio,
    required this.onTap,
  });

  final MediaType mediaType;
  final double aspectRatio;
  final VoidCallback onTap;

  IconData get _icon => switch (mediaType) {
        MediaType.video => Icons.play_circle_outline,
        MediaType.youtube => Icons.play_circle_outline,
        MediaType.webview => Icons.web,
        MediaType.image => Icons.image_outlined,
        MediaType.imagediff => Icons.compare,
        MediaType.slideshow => Icons.collections_outlined,
      };

  String get _label => switch (mediaType) {
        MediaType.video => '點擊載入影片',
        MediaType.youtube => '點擊載入 YouTube 影片',
        MediaType.webview => '點擊載入嵌入內容',
        MediaType.image => '點擊載入圖片',
        MediaType.imagediff => '點擊載入圖片比較',
        MediaType.slideshow => '點擊載入相簿',
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(_icon, size: 48, color: AppColors.grey400),
                const SizedBox(height: 8),
                Text(
                  _label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey400,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
