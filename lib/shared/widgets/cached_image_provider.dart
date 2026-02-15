import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';
import 'package:tw_reporter_app/shared/widgets/multi_image_stream_completer.dart';

/// An [ImageProvider] that loads images through [BaseCacheManager] using
/// `getFileStream` for download progress and cache-then-network support.
@immutable
class CachedImageProvider extends ImageProvider<CachedImageProvider> {
  /// Creates a [CachedImageProvider].
  const CachedImageProvider(this.url, {this.cacheManager, this.scale = 1.0});

  /// The image URL to load and cache.
  final String url;

  /// Optional cache manager override (for testing).
  final BaseCacheManager? cacheManager;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  BaseCacheManager get _cacheManager =>
      cacheManager ?? AppCacheManager.instance.imageCacheManager;

  @override
  Future<CachedImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<CachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    CachedImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final chunkEvents = StreamController<ImageChunkEvent>();
    return MultiImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
    );
  }

  Stream<ui.Codec> _loadAsync(
    CachedImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async* {
    final stream = _cacheManager.getFileStream(
      key.url,
      withProgress: true,
    );
    await for (final result in stream) {
      if (result is DownloadProgress) {
        chunkEvents.add(
          ImageChunkEvent(
            cumulativeBytesLoaded: result.downloaded,
            expectedTotalBytes: result.totalSize,
          ),
        );
      }
      if (result is FileInfo) {
        final bytes = await result.file.readAsBytes();
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        yield await decode(buffer);
        // Only use the first resolved file. getFileStream may emit a
        // second FileInfo (fresh download after cache hit) which would
        // cause a visible flash as the image re-renders.
        break;
      }
    }
    await chunkEvents.close();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CachedImageProvider &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => 'CachedImageProvider("$url", scale: $scale)';
}
