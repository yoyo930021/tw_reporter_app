import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';

/// A slide in the slideshow.
typedef SlideItem = ({String url, String description});

/// A slideshow viewer with prev/next buttons and page indicator.
class SlideshowViewer extends StatefulWidget {
  /// Creates a [SlideshowViewer].
  const SlideshowViewer({
    required this.slides,
    super.key,
  });

  /// The list of slides to display.
  final List<SlideItem> slides;

  @override
  State<SlideshowViewer> createState() => _SlideshowViewerState();
}

class _SlideshowViewerState extends State<SlideshowViewer> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    unawaited(_pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;
    final int total = widget.slides.length;

    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 16 / 10,
          child: PageView.builder(
            controller: _pageController,
            itemCount: total,
            onPageChanged: (int index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (_, int index) {
              final SlideItem slide = widget.slides[index];
              return CachedNetworkImage(
                imageUrl: slide.url,
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
        if (widget.slides[_currentPage].description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
            ),
            child: Text(
              widget.slides[_currentPage].description,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
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
                onPressed:
                    _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
              ),
              Text(
                '${_currentPage + 1} / $total',
                style: AppTextStyles.body2,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < total - 1
                    ? () => _goToPage(_currentPage + 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
