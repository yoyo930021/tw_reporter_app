import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tw_reporter_app/core/cache/dio_http_file_service.dart';

/// 統一快取管理器
///
/// 管理 API、圖片、影片三種快取，共用 200MB 上限。
/// 使用 [AppCacheManager.instance] 取得單例。
class AppCacheManager {
  AppCacheManager._();

  static final AppCacheManager instance = AppCacheManager._();

  /// 所有快取共用上限 200MB
  static const int maxTotalCacheSize = 200 * 1024 * 1024;

  static const Duration _imageCacheStalePeriod = Duration(days: 14);
  static const Duration _videoCacheMaxAge = Duration(days: 7);

  late CacheStore _apiStore;
  BaseCacheManager? _imageCacheManager;
  late String _videoCacheDir;
  late String _baseCacheDir;

  bool _initialized = false;

  /// API 快取儲存
  CacheStore get apiStore => _apiStore;

  /// 圖片快取管理器（供 CachedNetworkImage 使用）
  ///
  /// 未初始化時返回 [DefaultCacheManager]。
  BaseCacheManager get imageCacheManager =>
      _imageCacheManager ?? DefaultCacheManager();

  /// 影片快取目錄路徑
  String get videoCacheDir => _videoCacheDir;

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// 初始化所有快取（需在 app 啟動時呼叫）
  Future<void> init({String? basePath}) async {
    if (_initialized) return;

    _baseCacheDir =
        basePath ?? (await getApplicationCacheDirectory()).path;

    // API 快取（Hive）
    final apiCacheDir = '$_baseCacheDir/api_cache';
    await Directory(apiCacheDir).create(recursive: true);
    _apiStore = HiveCacheStore(apiCacheDir);

    // 影片快取
    _videoCacheDir = '$_baseCacheDir/video_cache';
    await Directory(_videoCacheDir).create(recursive: true);

    // 圖片快取（flutter_cache_manager + Dio FileService）
    _imageCacheManager = CacheManager(
      Config(
        'tw_reporter_images',
        stalePeriod: _imageCacheStalePeriod,
        maxNrOfCacheObjects: 500,
        fileService: DioHttpFileService(),
      ),
    );

    _initialized = true;
  }

  /// 計算所有快取的總大小（bytes）
  Future<int> getTotalCacheSize() async {
    var total = 0;

    // 圖片快取目錄
    final imageDir =
        Directory('$_baseCacheDir/libCachedImageData');
    if (imageDir.existsSync()) {
      total += await _dirSize(imageDir);
    }

    // API 快取目錄
    final apiDir = Directory('$_baseCacheDir/api_cache');
    if (apiDir.existsSync()) {
      total += await _dirSize(apiDir);
    }

    // 影片快取目錄
    final videoDir = Directory(_videoCacheDir);
    if (videoDir.existsSync()) {
      total += await _dirSize(videoDir);
    }

    return total;
  }

  /// 清除所有快取
  Future<void> clearAll() async {
    await _apiStore.clean();
    await _imageCacheManager?.emptyCache();
    await _clearDir(Directory(_videoCacheDir));
  }

  /// 超過上限時按 LRU 清理最舊檔案
  Future<void> enforceLimit() async {
    final totalSize = await getTotalCacheSize();
    if (totalSize <= maxTotalCacheSize) return;

    // 收集所有可清理的快取檔案
    final files = <File>[];
    for (final dirPath in [
      '$_baseCacheDir/api_cache',
      _videoCacheDir,
    ]) {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        await for (final entity
            in dir.list(recursive: true)) {
          if (entity is File) {
            files.add(entity);
          }
        }
      }
    }

    // 按最後存取時間排序（最舊的先刪）
    final fileTimes = <File, DateTime>{};
    for (final file in files) {
      try {
        fileTimes[file] = file.lastModifiedSync();
      } on FileSystemException catch (_) {
        // 忽略無法讀取的檔案
      }
    }
    files.sort((a, b) =>
        (fileTimes[a] ?? DateTime.now())
            .compareTo(fileTimes[b] ?? DateTime.now()));

    var currentSize = totalSize;
    for (final file in files) {
      if (currentSize <= maxTotalCacheSize) break;
      try {
        final fileSize = await file.length();
        await file.delete();
        currentSize -= fileSize;
      } on FileSystemException catch (_) {
        // 忽略刪除失敗
      }
    }
  }

  /// 清理過期快取
  Future<void> cleanExpired() async {
    // API 快取由 dio_cache_interceptor 的 maxStale 自動管理
    // 清理過期影片
    final videoDir = Directory(_videoCacheDir);
    if (videoDir.existsSync()) {
      final now = DateTime.now();
      await for (final entity in videoDir.list()) {
        if (entity is File) {
          try {
            final modified = entity.lastModifiedSync();
            if (now.difference(modified) > _videoCacheMaxAge) {
              await entity.delete();
            }
          } on FileSystemException catch (_) {
            // 忽略
          }
        }
      }
    }
  }

  Future<int> _dirSize(Directory dir) async {
    var size = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          try {
            size += await entity.length();
          } on FileSystemException catch (_) {
            // 忽略無法讀取的檔案
          }
        }
      }
    } on FileSystemException catch (_) {
      // 忽略無法列出的目錄
    }
    return size;
  }

  Future<void> _clearDir(Directory dir) async {
    if (!dir.existsSync()) return;
    await for (final entity in dir.list()) {
      try {
        await entity.delete(recursive: true);
      } on FileSystemException catch (_) {
        // 忽略刪除失敗
      }
    }
  }
}
