import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';

/// A slide in the slideshow.
typedef SlideItem = ({String url, String description});

/// A slideshow viewer with prev/next buttons and page indicator.
class SlideshowViewer extends CompositionWidget {
  /// Creates a [SlideshowViewer].
  const SlideshowViewer({
    required this.slides,
    super.key,
  });

  /// The list of slides to display.
  final List<SlideItem> slides;

  @override
  Widget Function(BuildContext) setup() {
    final currentPage = ref(0);
    final pageControllerRef = usePageController();
    final props = widget();
    final theme = useTheme();

    void goToPage(int page) {
      unawaited(
        pageControllerRef.value.animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    }

    return (BuildContext context) {
      return Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 10,
            child: PageView.builder(
              controller: pageControllerRef.raw,
              itemCount: props.value.slides.length,
              onPageChanged: (index) {
                currentPage.value = index;
              },
              itemBuilder: (_, index) {
                final slide = props.value.slides[index];
                return CachedNetworkImage(
                  imageUrl: slide.url,
                  cacheManager: AppCacheManager.instance.imageCacheManager,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const ColoredBox(
                    color: AppColors.grey200,
                  ),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: AppColors.grey200,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Description
          if (props.value.slides[currentPage.value].description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
                left: AppSpacing.sm,
                right: AppSpacing.sm,
              ),
              child: Text(
                props.value.slides[currentPage.value].description,
                style: theme.value.textTheme.bodySmall!.copyWith(
                  color: theme.value.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage.value > 0
                      ? () => goToPage(currentPage.value - 1)
                      : null,
                ),
                Text(
                  '${currentPage.value + 1} / ${props.value.slides.length}',
                  style: theme.value.textTheme.bodyMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage.value < props.value.slides.length - 1
                      ? () => goToPage(currentPage.value + 1)
                      : null,
                ),
              ],
            ),
          ),
        ],
      );
    };
  }
}
