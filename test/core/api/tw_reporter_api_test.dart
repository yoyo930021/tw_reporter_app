import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late TwReporterApi api;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Options(method: 'GET'));
  });

  setUp(() {
    mockDio = MockDio();

    when(() => mockDio.options).thenReturn(
      BaseOptions(
        baseUrl: 'https://go-api.twreporter.org/v2',
      ),
    );

    api = TwReporterApi(mockDio);
  });

  group('TwReporterApi', () {
    group('fetchPosts', () {
      test('should return ListResponse on success', () async {
        // Arrange
        final Map<String, dynamic> responseData =
            <String, dynamic>{
          'data': <String, dynamic>{
            'meta': <String, dynamic>{
              'limit': 10,
              'offset': 0,
              'total': 100,
            },
            'records': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': '1',
                'slug': 'article-1',
                'title': '文章 1',
                'og_description': '描述 1',
                'category_set': <Map<String, dynamic>>[],
                'published_date': '2024-01-01T00:00:00Z',
                'is_external': false,
              },
            ],
          },
          'status': 'success',
        };

        when(() => mockDio.fetch<Map<String, dynamic>>(any()))
            .thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final ListResponse<Article> response =
            await api.fetchPosts(limit: 10, offset: 0);

        // Assert
        expect(response.status, equals('success'));
        expect(response.data.records, hasLength(1));
        expect(
          response.data.records.first.title,
          equals('文章 1'),
        );
      });

      test('should throw on network error', () async {
        when(() => mockDio.fetch<Map<String, dynamic>>(any()))
            .thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        expect(
          () => api.fetchPosts(limit: 10, offset: 0),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('fetchPost', () {
      test('should return ApiResponse on success', () async {
        final Map<String, dynamic> responseData =
            <String, dynamic>{
          'data': <String, dynamic>{
            'id': '1',
            'slug': 'test-article',
            'title': '測試文章',
            'og_description': '描述',
            'category_set': <Map<String, dynamic>>[],
            'published_date': '2024-01-01T00:00:00Z',
            'is_external': false,
            'content': <String, dynamic>{
              'api_data': <Map<String, dynamic>>[
                <String, dynamic>{
                  'type': 'unstyled',
                  'content': <String>['文章內容'],
                  'id': '1',
                  'styles': <String, dynamic>{},
                  'alignment': 'center',
                },
              ],
            },
          },
          'status': 'success',
        };

        when(() => mockDio.fetch<Map<String, dynamic>>(any()))
            .thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final ApiResponse<Article> response =
            await api.fetchPost('test-article');

        expect(response.status, equals('success'));
        expect(response.data.slug, equals('test-article'));
        expect(response.data.content, isNotNull);
      });
    });

    group('fetchTopics', () {
      test('should return ListResponse on success', () async {
        final Map<String, dynamic> responseData =
            <String, dynamic>{
          'data': <String, dynamic>{
            'meta': <String, dynamic>{
              'limit': 10,
              'offset': 0,
              'total': 50,
            },
            'records': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': '1',
                'slug': 'test-topic',
                'title': '測試專題',
                'published_date': '2024-01-01T00:00:00Z',
              },
            ],
          },
          'status': 'success',
        };

        when(() => mockDio.fetch<Map<String, dynamic>>(any()))
            .thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final ListResponse<Topic> response =
            await api.fetchTopics(limit: 10, offset: 0);

        expect(response.status, equals('success'));
        expect(response.data.records, hasLength(1));
        expect(
          response.data.records.first.title,
          equals('測試專題'),
        );
      });
    });

    group('fetchIndexPage', () {
      test('should return ApiResponse on success', () async {
        final Map<String, dynamic> responseData =
            <String, dynamic>{
          'data': <String, dynamic>{
            'editor_picks_section': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': '1',
                'slug': 'featured',
                'title': '精選文章',
                'og_description': '描述',
                'category_set': <Map<String, dynamic>>[],
                'published_date': '2024-01-01T00:00:00Z',
                'is_external': false,
              },
            ],
          },
          'status': 'success',
        };

        when(() => mockDio.fetch<Map<String, dynamic>>(any()))
            .thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final ApiResponse<IndexPageData> response =
            await api.fetchIndexPage();

        expect(response.status, equals('success'));
        expect(
          response.data.editorPicksSection,
          hasLength(1),
        );
        expect(
          response.data.editorPicksSection?.first.title,
          equals('精選文章'),
        );
      });
    });
  });
}
