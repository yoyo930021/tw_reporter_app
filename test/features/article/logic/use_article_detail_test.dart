import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/article/logic/use_article_detail.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

// Helper function to create mock ApiResponse
ApiResponse<Article> createMockArticleResponse(Article article) {
  return ApiResponse<Article>(
    data: article,
    status: 'success',
  );
}

// 測試用的 Composition Widget
class TestWidget extends CompositionWidget {
  TestWidget({
    required this.setupFn,
    super.key,
  });

  final Widget Function(BuildContext) Function() setupFn;

  @override
  Widget Function(BuildContext) setup() => setupFn();
}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  group('useArticleDetail', () {
    testWidgets('should load article detail on mount', (WidgetTester tester) async {
      // Arrange
      final Article mockArticle = Article(
        id: '1',
        slug: 'test-article',
        title: '測試文章標題',
        ogDescription: '這是測試文章的描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime(2024, 1, 1),
        isExternal: false,
        content: <String, dynamic>{
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
      );

      when(() => mockApi.fetchPost('test-article', full: any(named: 'full')))
          .thenAnswer((_) async => createMockArticleResponse(mockArticle));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final ArticleDetailResult result = useArticleDetail(
                mockApi,
                slug: 'test-article',
              );

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Loading: ${result.isLoading.value}'),
                        if (result.article.value != null)
                          Text('Title: ${result.article.value!.title}'),
                        if (result.article.value?.content != null)
                          Text('Content: has content'),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待載入完成
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('Title: 測試文章標題'), findsOneWidget);
      expect(find.text('Content: has content'), findsOneWidget);
      verify(() => mockApi.fetchPost('test-article', full: any(named: 'full'))).called(1);
    });

    testWidgets('should handle article fetch error', (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchPost('test-article', full: any(named: 'full')))
          .thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final ArticleDetailResult result = useArticleDetail(
                mockApi,
                slug: 'test-article',
              );

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('HasError: ${result.hasError.value}'),
                        if (result.error.value != null)
                          Text('Error: ${result.error.value}'),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待錯誤發生
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('HasError: true'), findsOneWidget);
      expect(find.text('Error: Exception: Network error'), findsOneWidget);
    });

    testWidgets('should refresh article when refresh is called', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;

      when(() => mockApi.fetchPost('test-article', full: any(named: 'full'))).thenAnswer((_) async {
        callCount++;
        return createMockArticleResponse(
          Article(
            id: '$callCount',
            slug: 'test-article',
            title: '文章 $callCount',
            ogDescription: '描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime.now(),
            isExternal: false,
          ),
        );
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final ArticleDetailResult result = useArticleDetail(
                mockApi,
                slug: 'test-article',
              );

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        if (result.article.value != null)
                          Text('ID: ${result.article.value!.id}'),
                        ElevatedButton(
                          onPressed: result.refresh,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待初始載入
      await tester.pumpAndSettle();

      expect(find.text('ID: 1'), findsOneWidget);
      expect(callCount, equals(1));

      // 執行重新整理
      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      // Assert
      expect(callCount, equals(2));
      expect(find.text('ID: 2'), findsOneWidget);
    });

    testWidgets('should not load when already loading', (WidgetTester tester) async {
      // Arrange
      int fetchCallCount = 0;

      when(() => mockApi.fetchPost('test-article', full: any(named: 'full'))).thenAnswer((_) async {
        fetchCallCount++;
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return createMockArticleResponse(
          Article(
            id: '1',
            slug: 'test-article',
            title: '測試文章',
            ogDescription: '描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime.now(),
            isExternal: false,
          ),
        );
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final ArticleDetailResult result = useArticleDetail(
                mockApi,
                slug: 'test-article',
              );

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('CallCount: $fetchCallCount'),
                        ElevatedButton(
                          onPressed: result.refresh,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待初始載入完成
      await tester.pumpAndSettle();

      final int initialCallCount = fetchCallCount;

      // 快速連續點擊兩次
      await tester.tap(find.text('Refresh'));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      // Assert - 應該只增加一次
      expect(fetchCallCount, equals(initialCallCount + 1));
    });

    testWidgets('should handle different slugs', (WidgetTester tester) async {
      // Arrange
      final Article article1 = Article(
        id: '1',
        slug: 'article-1',
        title: '文章 1',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime.now(),
        isExternal: false,
      );

      final Article article2 = Article(
        id: '2',
        slug: 'article-2',
        title: '文章 2',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime.now(),
        isExternal: false,
      );

      when(() => mockApi.fetchPost('article-1', full: any(named: 'full')))
          .thenAnswer((_) async => createMockArticleResponse(article1));
      when(() => mockApi.fetchPost('article-2', full: any(named: 'full')))
          .thenAnswer((_) async => createMockArticleResponse(article2));

      // Act - 載入 article-1
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final ArticleDetailResult result = useArticleDetail(
                mockApi,
                slug: 'article-1',
              );

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        if (result.article.value != null)
                          Text('Title: ${result.article.value!.title}'),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Title: 文章 1'), findsOneWidget);
      verify(() => mockApi.fetchPost('article-1', full: any(named: 'full'))).called(1);
    });
  });
}
