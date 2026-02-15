import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 使用 Dio 下載圖片的 [FileService] 實作
///
/// 讓圖片快取請求走統一的 Dio 客戶端，
/// 享有 rhttp (Rust HTTP) 傳輸層的優勢。
class DioHttpFileService extends FileService {
  DioHttpFileService(Dio dio) : _dio = dio;

  final Dio _dio;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _dio.get<ResponseBody>(
      url,
      options: Options(
        headers: headers,
        responseType: ResponseType.stream,
      ),
    );

    final contentLength = int.tryParse(
      response.headers.value(HttpHeaders.contentLengthHeader) ??
          '',
    );

    return DioGetResponse(response, contentLength);
  }
}

/// 將 Dio 流式回應轉換為 [FileServiceResponse]
class DioGetResponse implements FileServiceResponse {
  DioGetResponse(this._response, this._contentLength)
      : _receivedTime = DateTime.now();

  final Response<ResponseBody> _response;
  final int? _contentLength;
  final DateTime _receivedTime;

  @override
  Stream<List<int>> get content =>
      _response.data?.stream ?? const Stream.empty();

  @override
  int? get contentLength => _contentLength;

  @override
  int get statusCode => _response.statusCode ?? 200;

  @override
  DateTime get validTill {
    var ageDuration = const Duration(days: 7);
    final controlHeader = _response.headers
        .value(HttpHeaders.cacheControlHeader);
    if (controlHeader != null) {
      final parts = controlHeader.split(',');
      for (final part in parts) {
        final trimmed = part.trim().toLowerCase();
        if (trimmed == 'no-cache') {
          ageDuration = Duration.zero;
        }
        if (trimmed.startsWith('max-age=')) {
          final seconds =
              int.tryParse(trimmed.split('=')[1]) ?? 0;
          if (seconds > 0) {
            ageDuration = Duration(seconds: seconds);
          }
        }
      }
    }
    return _receivedTime.add(ageDuration);
  }

  @override
  String? get eTag =>
      _response.headers.value(HttpHeaders.etagHeader);

  @override
  String get fileExtension {
    final contentType = _response.headers
        .value(HttpHeaders.contentTypeHeader);
    if (contentType == null) return '';
    if (contentType.contains('jpeg') ||
        contentType.contains('jpg')) {
      return '.jpg';
    }
    if (contentType.contains('png')) return '.png';
    if (contentType.contains('gif')) return '.gif';
    if (contentType.contains('webp')) return '.webp';
    if (contentType.contains('svg')) return '.svg';
    return '';
  }
}
