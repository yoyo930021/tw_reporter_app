import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tw_reporter_app/core/cache/cache_file_system.dart';
import 'package:tw_reporter_app/core/cache/dio_http_file_service.dart';

/// 統一快取管理器
///
/// 管理圖片快取（flutter_cache_manager）和 HTTP 回應快取（dio_cache_interceptor）。
/// 影片快取由 `http_cache_stream` 的本地代理伺服器自動管理。
/// 使用 [AppCacheManager.instance] 取得單例。
class AppCacheManager {
  AppCacheManager._();

  static final AppCacheManager instance = AppCacheManager._();

  static const Duration _imageCacheStalePeriod = Duration(days: 14);

  /// HTTP 回應快取子目錄名稱
  static const String _httpCacheDirName = 'http_cache';

  /// 影片快取子目錄名稱
  static const String _videoCacheDirName = 'video_cache';

  /// flutter_cache_manager 使用的 cacheKey（同時也是 tempDir 下的子目錄名）
  static const String _imageCacheKey = 'tw_reporter_images';

  BaseCacheManager? _imageCacheManager;
  late String _baseCacheDir;
  late CacheOptions _httpCacheOptions;

  bool _initialized = false;

  /// 圖片快取管理器（供 CachedImage 使用）
  ///
  /// 未初始化時返回 [DefaultCacheManager]。
  BaseCacheManager get imageCacheManager =>
      _imageCacheManager ?? DefaultCacheManager();

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// HTTP 回應快取選項（供 DioCacheInterceptor 使用）
  CacheOptions get httpCacheOptions => _httpCacheOptions;

  /// 影片快取目錄路徑
  String get videoCachePath => '$_baseCacheDir/$_videoCacheDirName';

  /// 初始化所有快取（需在 app 啟動時呼叫）
  Future<void> init({required Dio imageDio, String? basePath}) async {
    if (_initialized) return;

    final resolvedBase =
        basePath ?? (await getApplicationCacheDirectory()).path;
    _baseCacheDir = resolvedBase;

    // HTTP 回應快取（FileCacheStore）
    final httpCacheDir = Directory('$resolvedBase/$_httpCacheDirName');
    await httpCacheDir.create(recursive: true);
    _httpCacheOptions = CacheOptions(
      store: FileCacheStore(httpCacheDir.path),
      hitCacheOnNetworkFailure: true,
      maxStale: const Duration(days: 7),
    );

    // 圖片快取（flutter_cache_manager + Dio FileService + 自訂 FileSystem）
    _imageCacheManager = CacheManager(
      Config(
        _imageCacheKey,
        stalePeriod: _imageCacheStalePeriod,
        maxNrOfCacheObjects: 500,
        fileSystem: CacheFileSystem(_imageCacheKey),
        fileService: DioHttpFileService(imageDio),
      ),
    );

    _initialized = true;
  }

  /// 計算所有快取的總大小（bytes）
  ///
  /// 包含圖片快取、HTTP 回應快取和影片快取目錄。
  Future<int> getTotalCacheSize() async {
    if (!_initialized) return 0;

    var total = 0;

    // 圖片快取（透過 flutter_cache_manager store）
    final imgMgr = _imageCacheManager;
    if (imgMgr is CacheManager) {
      total += await imgMgr.store.getCacheSize();
    }

    // HTTP 回應快取目錄
    final httpDir = Directory('$_baseCacheDir/$_httpCacheDirName');
    if (httpDir.existsSync()) {
      total += await _dirSize(httpDir);
    }
    // 影片快取目錄
    final videoDir = Directory('$_baseCacheDir/$_videoCacheDirName');
    if (videoDir.existsSync()) {
      total += await _dirSize(videoDir);
    }

    return total;
  }

  /// 清除所有快取
  Future<void> clearAll() async {
    if (!_initialized) return;
    await _imageCacheManager?.emptyCache();
    await _clearDir(Directory('$_baseCacheDir/$_httpCacheDirName'));
    await _clearDir(Directory('$_baseCacheDir/$_videoCacheDirName'));
  }

  /// 清理過期快取
  ///
  /// flutter_cache_manager 自動管理圖片過期，
  /// HTTP 快取遵循 HTTP headers 自動管理過期。
  /// 此方法為預留介面，目前無需額外處理。
  Future<void> cleanExpired() async {
    // flutter_cache_manager 內部自動清理過期快取，無需手動處理
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
