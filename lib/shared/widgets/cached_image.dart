import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:tw_reporter_app/shared/widgets/cached_image_provider.dart';
import 'package:tw_reporter_app/shared/widgets/shimmer_placeholder.dart';

/// Minimal 1x1 transparent PNG used as the default placeholder.
final Uint8List _kTransparentImage = Uint8List.fromList(const <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x62, 0x00, 0x00, 0x00, 0x02,
  0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

/// A cached network image widget backed by [CachedImageProvider].
///
/// When [placeholderUrl] is provided, uses [Image] with a `frameBuilder` to
/// show the low-res preview while the main image downloads, then instantly
/// swaps to the full image (no cross-fade for same-content transitions).
///
/// Without [placeholderUrl], uses [FadeInImage] with a transparent
/// placeholder for a smooth 300 ms fade-in.
class CachedImage extends StatelessWidget {
  /// Creates a [CachedImage].
  const CachedImage({
    required this.imageUrl,
    this.placeholderUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.cacheManager,
    super.key,
  });

  /// The URL of the main image to display.
  final String imageUrl;

  /// Optional low-res placeholder URL (e.g. tiny/w400 variant).
  final String? placeholderUrl;

  /// Optional fixed height.
  final double? height;

  /// Optional fixed width.
  final double? width;

  /// How the image should be inscribed into the space.
  final BoxFit fit;

  /// Widget shown when the image fails to load.
  final Widget? errorWidget;

  /// Optional cache manager override (for testing).
  final BaseCacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    final mainImage = CachedImageProvider(
      imageUrl,
      cacheManager: cacheManager,
    );

    // With placeholderUrl: show low-res preview while main loads, then swap
    // instantly (no cross-fade) to avoid the "loaded then reloaded" feeling.
    if (placeholderUrl != null) {
      return Image(
        image: mainImage,
        height: height,
        width: width,
        fit: fit,
        gaplessPlayback: true,
        frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          // Main image still loading – show the low-res placeholder.
          return Image(
            image: CachedImageProvider(
              placeholderUrl!,
              cacheManager: cacheManager,
            ),
            height: height,
            width: width,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => ShimmerPlaceholder(
              height: height,
              width: width,
            ),
          );
        },
        errorBuilder: (_, _, _) => _buildErrorWidget(context),
      );
    }

    // Without placeholderUrl: fade in from transparent.
    return FadeInImage(
      placeholder: MemoryImage(_kTransparentImage),
      image: mainImage,
      height: height,
      width: width,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholderFit: fit,
      imageErrorBuilder: (_, _, _) => _buildErrorWidget(context),
      placeholderErrorBuilder: (_, _, _) => ShimmerPlaceholder(
        height: height,
        width: width,
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) return errorWidget!;
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: width,
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.image_not_supported, color: colors.outline),
    );
  }
}
