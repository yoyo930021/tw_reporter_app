import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';

/// 小影片快取服務
///
/// 透過 Dio 下載 ≤ 3MB 的影片到本地快取目錄。
/// 超過大小限制的影片直接返回原始 URL。
class VideoCacheService {
  VideoCacheService(this._dio, {String? cacheDir}) : _cacheDir = cacheDir;

  final Dio _dio;
  final String? _cacheDir;

  /// 單個影片的最大快取大小（3MB）
  static const int maxFileCacheSize = 3 * 1024 * 1024;

  /// 取得影片的本地路徑（如已快取）或原始 URL
  ///
  /// - 若已快取 → 返回本地檔案路徑
  /// - 若 ≤ 3MB → 下載到快取後返回本地路徑
  /// - 若 > 3MB 或下載失敗 → 返回原始 URL
  Future<String> getVideoPath(String url) async {
    final cachedPath = getCachedFilePath(url);
    if (File(cachedPath).existsSync()) return cachedPath;

    try {
      // HEAD 請求取得檔案大小
      final head = await _dio.head<void>(url);
      final sizeStr =
          head.headers.value(HttpHeaders.contentLengthHeader);
      final size = int.tryParse(sizeStr ?? '');
      if (size == null || size > maxFileCacheSize) return url;

      // 下載到快取
      await _dio.download(url, cachedPath);

      // 驗證下載後的檔案大小
      final file = File(cachedPath);
      if (file.existsSync() &&
          file.lengthSync() <= maxFileCacheSize) {
        return cachedPath;
      }

      // 檔案過大，刪除並返回 URL
      if (file.existsSync()) await file.delete();
      return url;
    } on Exception catch (_) {
      return url;
    }
  }

  /// 根據 URL 產生快取檔案路徑
  String getCachedFilePath(String url) {
    final hash = url.hashCode.toRadixString(16);
    final ext = _extractExtension(url);
    final dir = _cacheDir ?? AppCacheManager.instance.videoCacheDir;
    return '$dir/$hash$ext';
  }

  String _extractExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final dotIndex = path.lastIndexOf('.');
      if (dotIndex >= 0 && dotIndex < path.length - 1) {
        final ext = path.substring(dotIndex);
        if (ext.length <= 5) return ext;
      }
    } on FormatException catch (_) {
      // 忽略
    }
    return '.mp4';
  }
}
