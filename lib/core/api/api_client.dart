import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_compatibility_layer/dio_compatibility_layer.dart';
import 'package:rhttp/rhttp.dart';
import 'package:tw_reporter_app/core/api/interceptors/logging_interceptor.dart';

/// API 客戶端工廠類別
/// 提供預配置的 Dio 實例
class ApiClient {
  /// 建立並配置 Dio 實例（含 rhttp + HTTP cache）
  static Dio createDio({
    required RhttpCompatibleClient rhttpClient,
    required CacheOptions cacheOptions,
  }) {
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
    )..httpClientAdapter = ConversionLayerAdapter(rhttpClient);

    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    dio.interceptors.add(LoggingInterceptor());

    return dio;
  }

  /// 建立圖片下載用的 Dio（無 baseUrl、無快取攔截器）
  ///
  /// 圖片快取由 flutter_cache_manager 管理，此處只需 rhttp 傳輸層。
  static Dio createImageDio(RhttpCompatibleClient rhttpClient) {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    )..httpClientAdapter = ConversionLayerAdapter(rhttpClient);
  }
}
