import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/cache/video_cache_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late VideoCacheService service;
  late Directory tempDir;

  setUp(() async {
    mockDio = MockDio();
    tempDir = await Directory.systemTemp.createTemp('video_cache_test_');
    service = VideoCacheService(mockDio, cacheDir: tempDir.path);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('VideoCacheService', () {
    test('maxFileCacheSize is 3MB', () {
      expect(
        VideoCacheService.maxFileCacheSize,
        3 * 1024 * 1024,
      );
    });

    group('getCachedFilePath', () {
      test('generates path in cache directory', () {
        const url = 'https://example.com/video.mp4';
        final path = service.getCachedFilePath(url);

        expect(path, startsWith(tempDir.path));
        expect(path, endsWith('.mp4'));
      });

      test('extracts .webm extension', () {
        expect(
          service.getCachedFilePath('https://example.com/clip.webm'),
          endsWith('.webm'),
        );
      });

      test('extracts .mov extension', () {
        expect(
          service.getCachedFilePath('https://example.com/clip.mov'),
          endsWith('.mov'),
        );
      });

      test('defaults to .mp4 for URLs without extension', () {
        final path = service.getCachedFilePath(
          'https://example.com/stream',
        );
        expect(path, endsWith('.mp4'));
      });

      test('defaults to .mp4 for long extensions', () {
        final path = service.getCachedFilePath(
          'https://example.com/file.toolong',
        );
        expect(path, endsWith('.mp4'));
      });

      test('uses URL hashCode for filename', () {
        const url = 'https://example.com/video.mp4';
        final path = service.getCachedFilePath(url);
        final hash = url.hashCode.toRadixString(16);
        expect(path, contains(hash));
      });
    });

    group('getVideoPath', () {
      test('returns cached path when file already exists', () async {
        const url = 'https://example.com/cached.mp4';
        final cachedPath = service.getCachedFilePath(url);

        // Pre-create the cached file
        await File(cachedPath).writeAsString('fake video');

        final result = await service.getVideoPath(url);
        expect(result, cachedPath);

        // Dio should not be called
        verifyNever(() => mockDio.head<void>(any()));
      });

      test('returns URL when HEAD shows file too large', () async {
        const url = 'https://example.com/large.mp4';

        when(() => mockDio.head<void>(url)).thenAnswer(
          (_) async => Response<void>(
            requestOptions: RequestOptions(path: url),
            headers: Headers.fromMap(<String, List<String>>{
              'content-length': ['${4 * 1024 * 1024}'],
            }),
          ),
        );

        final result = await service.getVideoPath(url);
        expect(result, url);
      });

      test('returns URL when content-length is missing', () async {
        const url = 'https://example.com/no-length.mp4';

        when(() => mockDio.head<void>(url)).thenAnswer(
          (_) async => Response<void>(
            requestOptions: RequestOptions(path: url),
            headers: Headers(),
          ),
        );

        final result = await service.getVideoPath(url);
        expect(result, url);
      });

      test('downloads and returns local path for small video', () async {
        const url = 'https://example.com/small.mp4';
        final cachedPath = service.getCachedFilePath(url);

        when(() => mockDio.head<void>(url)).thenAnswer(
          (_) async => Response<void>(
            requestOptions: RequestOptions(path: url),
            headers: Headers.fromMap(<String, List<String>>{
              'content-length': ['${1024 * 1024}'],
            }),
          ),
        );

        when(() => mockDio.download(url, cachedPath)).thenAnswer(
          (_) async {
            await File(cachedPath).writeAsBytes(
              List.filled(1024, 0),
            );
            return Response<dynamic>(
              requestOptions: RequestOptions(path: url),
            );
          },
        );

        final result = await service.getVideoPath(url);
        expect(result, cachedPath);
      });

      test('returns URL when HEAD request throws', () async {
        const url = 'https://example.com/error.mp4';

        when(() => mockDio.head<void>(url)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: url),
          ),
        );

        final result = await service.getVideoPath(url);
        expect(result, url);
      });

      test('returns URL when download throws', () async {
        const url = 'https://example.com/download-fail.mp4';
        final cachedPath = service.getCachedFilePath(url);

        when(() => mockDio.head<void>(url)).thenAnswer(
          (_) async => Response<void>(
            requestOptions: RequestOptions(path: url),
            headers: Headers.fromMap(<String, List<String>>{
              'content-length': ['1024'],
            }),
          ),
        );

        when(() => mockDio.download(url, cachedPath)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: url),
          ),
        );

        final result = await service.getVideoPath(url);
        expect(result, url);
      });

      test('deletes file and returns URL when downloaded file exceeds limit',
          () async {
        const url = 'https://example.com/sneaky-large.mp4';
        final cachedPath = service.getCachedFilePath(url);

        when(() => mockDio.head<void>(url)).thenAnswer(
          (_) async => Response<void>(
            requestOptions: RequestOptions(path: url),
            headers: Headers.fromMap(<String, List<String>>{
              'content-length': ['1024'], // Lies about size
            }),
          ),
        );

        when(() => mockDio.download(url, cachedPath)).thenAnswer(
          (_) async {
            // Write a file that exceeds the limit
            await File(cachedPath).writeAsBytes(
              List.filled(4 * 1024 * 1024, 0),
            );
            return Response<dynamic>(
              requestOptions: RequestOptions(path: url),
            );
          },
        );

        final result = await service.getVideoPath(url);
        expect(result, url);
        // File should be cleaned up
        expect(File(cachedPath).existsSync(), isFalse);
      });
    });
  });
}
