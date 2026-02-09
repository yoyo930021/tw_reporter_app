import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:tw_reporter_app/core/api/interceptors/logging_interceptor.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';

/// API 客戶端工廠類別
/// 提供預配置的 Dio 實例
class ApiClient {
  /// 建立並配置 Dio 實例（含 HTTP/2+3 + 快取）
  ///
  /// 需在 [AppCacheManager.instance.init()] 後呼叫。
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://www.twreporter.org',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )
      // HTTP/2+3 via platform native stack (Cronet / URLSession)
      ..httpClientAdapter = NativeAdapter();

    // API 快取攔截器
    if (AppCacheManager.instance.isInitialized) {
      dio.interceptors.add(
        DioCacheInterceptor(
          options: CacheOptions(
            store: AppCacheManager.instance.apiStore,
            policy: CachePolicy.forceCache,
            maxStale: const Duration(days: 7),
            hitCacheOnErrorExcept: <int>[],
          ),
        ),
      );
    }

    // 日誌攔截器（debug 模式）
    dio.interceptors.add(LoggingInterceptor());

    return dio;
  }

  /// 建立圖片下載用的 Dio（無 baseUrl、無快取攔截器）
  static Dio createImageDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    )..httpClientAdapter = NativeAdapter();
  }
}
