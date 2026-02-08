import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// HTTP 請求/回應日誌攔截器
/// 用於開發階段除錯 API 呼叫
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    debugPrint('REQUEST DATA: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      'RESPONSE[${response.statusCode}] => '
      'PATH: ${response.requestOptions.path}',
    );
    debugPrint('RESPONSE DATA: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    debugPrint('ERROR MESSAGE: ${err.message}');
    super.onError(err, handler);
  }
}
