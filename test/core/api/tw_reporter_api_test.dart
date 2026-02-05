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
    // Register fallback values for mocktail
    registerFallbackValue(RequestOptions());
    registerFallbackValue(
      Options(method: 'GET'),
    );
  });

  setUp(() {
    mockDio = MockDio();

    // Mock Dio.options which is required by Retrofit generated code
    when(() => mockDio.options).thenReturn(
      BaseOptions(baseUrl: 'https://www.twreporter.org'),
    );

    api = TwReporterApi(mockDio);
  });

  group('TwReporterApi', () {
    group('fetchLatestArticles', () {
      test('should return list of articles on success', () async {
        // Arrange
        final List<Map<String, dynamic>> responseData = <Map<String, dynamic>>[
          <String, dynamic>{
            'id': '1',
            'slug': 'article-1',
            'title': '文章 1',
            'ogDescription': '描述 1',
            'categorySet': <Map<String, dynamic>>[],
            'publishedDate': '2024-01-01T00:00:00Z',
            'isExternal': false,
          },
        ];

        when(() => mockDio.fetch<List<dynamic>>(any())).thenAnswer(
          (_) async => Response<List<dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final List<Article> articles = await api.fetchLatestArticles(
          page: 1,
          limit: 10,
        );

        // Assert
        expect(articles, hasLength(1));
        expect(articles.first.id, equals('1'));
        expect(articles.first.title, equals('文章 1'));
      });

      test('should throw exception on network error', () async {
        // Arrange
        when(() => mockDio.fetch<List<dynamic>>(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act & Assert
        expect(
          () => api.fetchLatestArticles(page: 1, limit: 10),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('fetchArticle', () {
      test('should return article detail by slug', () async {
        // Arrange
        final Map<String, dynamic> responseData = <String, dynamic>{
          'id': '1',
          'slug': 'test-article',
          'title': '測試文章',
          'ogDescription': '描述',
          'categorySet': <Map<String, dynamic>>[],
          'publishedDate': '2024-01-01T00:00:00Z',
          'isExternal': false,
          'content': '<p>文章內容</p>',
        };

        when(() => mockDio.fetch<Map<String, dynamic>>(any())).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final Article article = await api.fetchArticle('test-article');

        // Assert
        expect(article.slug, equals('test-article'));
        expect(article.htmlContent, equals('<p>文章內容</p>'));
      });
    });

    group('fetchCategoryArticles', () {
      test('should return articles filtered by category', () async {
        // Arrange
        final List<Map<String, dynamic>> responseData = <Map<String, dynamic>>[
          <String, dynamic>{
            'id': '1',
            'slug': 'category-article',
            'title': '分類文章',
            'ogDescription': '描述',
            'categorySet': <Map<String, dynamic>>[],
            'publishedDate': '2024-01-01T00:00:00Z',
            'isExternal': false,
          },
        ];

        when(() => mockDio.fetch<List<dynamic>>(any())).thenAnswer(
          (_) async => Response<List<dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final List<Article> articles = await api.fetchCategoryArticles(
          category: '國際',
          page: 1,
          limit: 10,
        );

        // Assert
        expect(articles, hasLength(1));
        expect(articles.first.title, equals('分類文章'));
      });
    });

    group('fetchFeaturedArticles', () {
      test('should return featured articles', () async {
        // Arrange
        final List<Map<String, dynamic>> responseData = <Map<String, dynamic>>[
          <String, dynamic>{
            'id': '1',
            'slug': 'featured-article',
            'title': '精選文章',
            'ogDescription': '描述',
            'categorySet': <Map<String, dynamic>>[],
            'publishedDate': '2024-01-01T00:00:00Z',
            'isExternal': false,
          },
        ];

        when(() => mockDio.fetch<List<dynamic>>(any())).thenAnswer(
          (_) async => Response<List<dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final List<Article> articles = await api.fetchFeaturedArticles();

        // Assert
        expect(articles, hasLength(1));
        expect(articles.first.title, equals('精選文章'));
      });
    });

    group('fetchTopics', () {
      test('should return list of topics', () async {
        // Arrange
        final List<Map<String, dynamic>> responseData = <Map<String, dynamic>>[
          <String, dynamic>{
            'id': '1',
            'slug': 'test-topic',
            'title': '測試專題',
            'publishedDate': '2024-01-01T00:00:00Z',
          },
        ];

        when(() => mockDio.fetch<List<dynamic>>(any())).thenAnswer(
          (_) async => Response<List<dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final List<Topic> topics = await api.fetchTopics(page: 1);

        // Assert
        expect(topics, hasLength(1));
        expect(topics.first.title, equals('測試專題'));
      });
    });

    group('searchArticles', () {
      test('should return search results', () async {
        // Arrange
        final List<Map<String, dynamic>> responseData = <Map<String, dynamic>>[
          <String, dynamic>{
            'id': '1',
            'slug': 'search-result',
            'title': '搜尋結果',
            'ogDescription': '描述',
            'categorySet': <Map<String, dynamic>>[],
            'publishedDate': '2024-01-01T00:00:00Z',
            'isExternal': false,
          },
        ];

        when(() => mockDio.fetch<List<dynamic>>(any())).thenAnswer(
          (_) async => Response<List<dynamic>>(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final List<Article> articles = await api.searchArticles(
          query: '測試',
          page: 1,
        );

        // Assert
        expect(articles, hasLength(1));
        expect(articles.first.title, equals('搜尋結果'));
      });
    });
  });
}
