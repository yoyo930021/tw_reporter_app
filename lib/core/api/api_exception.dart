import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_exception.freezed.dart';

/// 統一的 API 異常處理類別
/// 使用 Freezed 實現聯合類型來表示不同的錯誤情況
@freezed
sealed class ApiException with _$ApiException implements Exception {
  /// 網路連線錯誤（超時、連線失敗等）
  const factory ApiException.networkError() = NetworkError;

  /// 伺服器錯誤（5xx 狀態碼）
  const factory ApiException.serverError(int statusCode) = ServerError;

  /// 資源未找到（404）
  const factory ApiException.notFound() = NotFound;

  /// 未授權（401）
  const factory ApiException.unauthorized() = Unauthorized;

  /// 未知錯誤
  const factory ApiException.unknown(String message) = Unknown;

  /// 從 DioException 轉換為 ApiException
  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const ApiException.networkError();

      case DioExceptionType.badResponse:
        final int? statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return const ApiException.notFound();
        } else if (statusCode == 401) {
          return const ApiException.unauthorized();
        } else {
          return ApiException.serverError(statusCode ?? 500);
        }

      default:
        return ApiException.unknown(error.message ?? 'Unknown error');
    }
  }
}
