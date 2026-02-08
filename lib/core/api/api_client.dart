import 'package:dio/dio.dart';
import 'package:tw_reporter_app/core/api/interceptors/logging_interceptor.dart';

/// API 客戶端工廠類別
/// 提供預配置的 Dio 實例
class ApiClient {
  /// 建立並配置 Dio 實例
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
    );

    // 添加日誌攔截器（僅在 debug 模式）
    dio.interceptors.add(LoggingInterceptor());

    return dio;
  }
}
