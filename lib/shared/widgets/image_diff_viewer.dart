import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';

/// A before/after image comparison widget with a draggable divider.
class ImageDiffViewer extends CompositionWidget {
  /// Creates an [ImageDiffViewer].
  const ImageDiffViewer({
    required this.beforeUrl,
    required this.afterUrl,
    this.beforeDesc,
    this.afterDesc,
    super.key,
  });

  /// URL of the "before" image (shown on left side).
  final String beforeUrl;

  /// URL of the "after" image (shown on right side).
  final String afterUrl;

  /// Optional description for the before image.
  final String? beforeDesc;

  /// Optional description for the after image.
  final String? afterDesc;

  @override
  Widget Function(BuildContext) setup() {
    final dividerPosition = ref(0.5);
    final props = widget();
    final theme = useTheme();

    final hasDescriptions = computed(() {
      final p = props.value;
      return (p.beforeDesc != null && p.beforeDesc!.isNotEmpty) ||
          (p.afterDesc != null && p.afterDesc!.isNotEmpty);
    });

    return (BuildContext context) {
      final colors = theme.value.colorScheme;
      final textTheme = theme.value.textTheme;

      // Read reactive value HERE (in the render function) so that
      // changes trigger a rebuild. LayoutBuilder.builder is NOT
      // tracked by the reactive system.
      final position = dividerPosition.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SelectionContainer.disabled(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    dividerPosition.value =
                        (details.localPosition.dx / width)
                            .clamp(0.0, 1.0);
                  },
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Stack(
                      children: <Widget>[
                        // After image (full width, behind)
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: props.value.afterUrl,
                            cacheManager:
                                AppCacheManager.instance.imageCacheManager,
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
                          ),
                        ),
                        // Before image (clipped from left)
                        Positioned.fill(
                          child: ClipRect(
                            clipper: _LeftClipper(position),
                            child: CachedNetworkImage(
                              imageUrl: props.value.beforeUrl,
                              cacheManager:
                                  AppCacheManager.instance.imageCacheManager,
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
                            ),
                          ),
                        ),
                        // Divider line
                        Positioned(
                          left: width * position - 1,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 2,
                            color: Colors.white,
                          ),
                        ),
                        // Drag handle
                        Positioned(
                          left: width * position - 18,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.drag_handle,
                                size: 20,
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Descriptions
          if (hasDescriptions.value) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                if (props.value.beforeDesc != null &&
                    props.value.beforeDesc!.isNotEmpty)
                  Expanded(
                    child: Text(
                      props.value.beforeDesc!,
                      style: textTheme.bodySmall!.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (props.value.afterDesc != null &&
                    props.value.afterDesc!.isNotEmpty)
                  Expanded(
                    child: Text(
                      props.value.afterDesc!,
                      textAlign: TextAlign.end,
                      style: textTheme.bodySmall!.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      );
    };
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  _LeftClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(_LeftClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}
