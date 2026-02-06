import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';

/// A before/after image comparison widget with a draggable divider.
class ImageDiffViewer extends StatefulWidget {
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
  State<ImageDiffViewer> createState() => _ImageDiffViewerState();
}

class _ImageDiffViewerState extends State<ImageDiffViewer> {
  double _dividerPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            return GestureDetector(
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                setState(() {
                  _dividerPosition =
                      (details.localPosition.dx / width).clamp(0.0, 1.0);
                });
              },
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  children: <Widget>[
                    // After image (full width, behind)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: widget.afterUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const ColoredBox(
                          color: AppColors.grey200,
                        ),
                        errorWidget: (_, __, ___) => const ColoredBox(
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
                        clipper: _LeftClipper(_dividerPosition),
                        child: CachedNetworkImage(
                          imageUrl: widget.beforeUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const ColoredBox(
                            color: AppColors.grey200,
                          ),
                          errorWidget: (_, __, ___) => const ColoredBox(
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
                      left: width * _dividerPosition - 1,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: Colors.white,
                      ),
                    ),
                    // Drag handle
                    Positioned(
                      left: width * _dividerPosition - 18,
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
                                color: Colors.black.withValues(alpha: 0.3),
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
        // Descriptions
        if (_hasDescriptions) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              if (widget.beforeDesc != null &&
                  widget.beforeDesc!.isNotEmpty)
                Expanded(
                  child: Text(
                    widget.beforeDesc!,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              if (widget.afterDesc != null &&
                  widget.afterDesc!.isNotEmpty)
                Expanded(
                  child: Text(
                    widget.afterDesc!,
                    textAlign: TextAlign.end,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  bool get _hasDescriptions =>
      (widget.beforeDesc != null && widget.beforeDesc!.isNotEmpty) ||
      (widget.afterDesc != null && widget.afterDesc!.isNotEmpty);
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
