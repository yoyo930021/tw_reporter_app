import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/cache/dio_http_file_service.dart';

class MockDio extends Mock implements Dio {}

class FakeOptions extends Fake implements Options {}

void main() {
  late MockDio mockDio;
  late DioHttpFileService service;

  setUpAll(() {
    registerFallbackValue(FakeOptions());
  });

  setUp(() {
    mockDio = MockDio();
    service = DioHttpFileService(mockDio);
  });

  group('DioHttpFileService', () {
    test('get returns FileServiceResponse with correct status code',
        () async {
      final responseBody = ResponseBody.fromString('', 200);

      when(
        () => mockDio.get<ResponseBody>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<ResponseBody>(
          data: responseBody,
          statusCode: 200,
          requestOptions: RequestOptions(),
          headers: Headers.fromMap(<String, List<String>>{
            'content-length': ['1024'],
            'content-type': ['image/jpeg'],
          }),
        ),
      );

      final response = await service.get('https://example.com/image.jpg');

      expect(response.statusCode, 200);
      expect(response.contentLength, 1024);
    });

    test('get passes custom headers to Dio', () async {
      final responseBody = ResponseBody.fromString('', 200);

      when(
        () => mockDio.get<ResponseBody>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<ResponseBody>(
          data: responseBody,
          statusCode: 200,
          requestOptions: RequestOptions(),
          headers: Headers(),
        ),
      );

      await service.get(
        'https://example.com/image.jpg',
        headers: {'Authorization': 'Bearer token'},
      );

      verify(
        () => mockDio.get<ResponseBody>(
          'https://example.com/image.jpg',
          options: any(named: 'options'),
        ),
      ).called(1);
    });
  });

  group('DioGetResponse', () {
    test('fileExtension returns .jpg for JPEG content type', () {
      final response = _createResponse(
        headers: {HttpHeaders.contentTypeHeader: ['image/jpeg']},
      );
      final dioResponse = DioGetResponse(response, null);
      expect(dioResponse.fileExtension, '.jpg');
    });

    test('fileExtension returns .png for PNG content type', () {
      final response = _createResponse(
        headers: {HttpHeaders.contentTypeHeader: ['image/png']},
      );
      final dioResponse = DioGetResponse(response, null);
      expect(dioResponse.fileExtension, '.png');
    });

    test('fileExtension returns .gif for GIF content type', () {
      final response = _createResponse(
        headers: {HttpHeaders.contentTypeHeader: ['image/gif']},
      );
      final dioResponse = DioGetResponse(response, null);
      expect(dioResponse.fileExtension, '.gif');
    });

    test('fileExtension returns .webp for WebP content type', () {
      final response = _createResponse(
        headers: {HttpHeaders.contentTypeHeader: ['image/webp']},
      );
      final dioResponse = DioGetResponse(response, null);
      expect(dioResponse.fileExtension, '.webp');
    });

    test('fileExtension returns .svg for SVG content type', () {
      final response = _createResponse(
        headers: {HttpHeaders.contentTypeHeader: ['image/svg+xml']},
      );
      final dioResponse = DioGetResponse(response, null);
      expect(dioResponse.fileExtension, '.svg');
    });

    test('fileExtension returns empty string for unknown type', () {
      final response = _createResponse(
        headers: {HttpHeaders.contentTypeHeader: ['application/octet-stream']},
      );
      final dioResponse = DioGetResponse(response, null);
      expect(dioResponse.fileExtension, '');
    });

    test('fileExtension returns empty string when no content type', () {
      final response = _createResponse();
      final dioResponse = DioGetResponse(response, null);
      expect(dioResponse.fileExtension, '');
    });

    test('eTag returns header value', () {
      final response = _createResponse(
        headers: {HttpHeaders.etagHeader: ['"abc123"']},
      );
      final dioResponse = DioGetResponse(response, null);
      expect(dioResponse.eTag, '"abc123"');
    });

    test('eTag returns null when not present', () {
      final response = _createResponse();
      final dioResponse = DioGetResponse(response, null);
      expect(dioResponse.eTag, isNull);
    });

    test('statusCode defaults to 200 when response has no status', () {
      final response = _createResponse();
      final dioResponse = DioGetResponse(response, null);
      expect(dioResponse.statusCode, 200);
    });

    test('contentLength returns provided value', () {
      final response = _createResponse();
      final dioResponse = DioGetResponse(response, 2048);
      expect(dioResponse.contentLength, 2048);
    });

    test('validTill defaults to 7 days when no cache-control', () {
      final now = DateTime.now();
      final response = _createResponse();
      final dioResponse = DioGetResponse(response, null);

      final validTill = dioResponse.validTill;
      final diff = validTill.difference(now);

      // Should be approximately 7 days (within 5 seconds tolerance)
      expect(diff.inSeconds, closeTo(7 * 24 * 3600, 5));
    });

    test('validTill respects max-age cache-control', () {
      final response = _createResponse(
        headers: {HttpHeaders.cacheControlHeader: ['max-age=3600']},
      );
      final dioResponse = DioGetResponse(response, null);

      final now = DateTime.now();
      final validTill = dioResponse.validTill;
      final diff = validTill.difference(now);

      // Should be approximately 1 hour
      expect(diff.inMinutes, closeTo(60, 1));
    });

    test('validTill handles no-cache directive', () {
      final response = _createResponse(
        headers: {HttpHeaders.cacheControlHeader: ['no-cache']},
      );
      final dioResponse = DioGetResponse(response, null);

      final now = DateTime.now();
      final validTill = dioResponse.validTill;

      // Should be essentially now (within seconds)
      expect(
        validTill.difference(now).inSeconds.abs(),
        lessThan(2),
      );
    });

    test('content returns empty stream when data is null', () async {
      final response = Response<ResponseBody>(
        requestOptions: RequestOptions(),
      );
      final dioResponse = DioGetResponse(response, null);
      final chunks = await dioResponse.content.toList();
      expect(chunks, isEmpty);
    });
  });
}

Response<ResponseBody> _createResponse({
  Map<String, List<String>>? headers,
  int? statusCode,
}) {
  final code = statusCode ?? 200;
  return Response<ResponseBody>(
    requestOptions: RequestOptions(),
    statusCode: code,
    data: ResponseBody.fromString('', code),
    headers: Headers.fromMap(headers ?? {}),
  );
}
