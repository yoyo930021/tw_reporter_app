import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/latest/logic/use_latest_articles.dart';

// Helper function to create mock ListResponse
ListResponse<Article> createMockListResponse(List<Article> articles, int offset) {
  return ListResponse<Article>(
    data: ListData<Article>(
      meta: ListMeta(limit: articles.length, offset: offset, total: 100),
      records: articles,
    ),
    status: 'success',
  );
}

class MockTwReporterApi extends Mock implements TwReporterApi {}

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

  group('useLatestArticles', () {
    testWidgets('should load initial articles on mount', (WidgetTester tester) async {
      // Arrange
      final List<Article> mockArticles = List<Article>.generate(
        10,
        (int index) => Article(
          id: '$index',
          slug: 'article-$index',
          title: '文章 $index',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime.now(),
          isExternal: false,
        ),
      );

      when(() => mockApi.fetchPosts(limit: 10, offset: 0))
          .thenAnswer((_) async => createMockListResponse(mockArticles, 0));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final LatestArticlesResult result = useLatestArticles(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.articles.value.length}'),
                        Text('Loading: ${result.isLoading.value}'),
                        Text('HasMore: ${result.hasMore.value}'),
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
      expect(find.text('Count: 10'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('HasMore: true'), findsOneWidget);
      verify(() => mockApi.fetchPosts(limit: 10, offset: 0)).called(1);
    });

    testWidgets('should load more articles when loadMore is called',
        (WidgetTester tester) async {
      // Arrange
      int currentPage = 0;
      when(() => mockApi.fetchPosts(limit: 10, offset: any(named: 'offset')))
          .thenAnswer((Invocation invocation) async {
        currentPage++;
        final int offset = invocation.namedArguments[const Symbol('offset')] as int;
        return createMockListResponse(
          List<Article>.generate(
            10,
            (int index) => Article(
              id: 'page${currentPage}_$index',
              slug: 'article-page${currentPage}_$index',
              title: '文章 $currentPage-$index',
              ogDescription: '描述',
              categorySet: <CategorySet>[],
              publishedDate: DateTime.now(),
              isExternal: false,
            ),
          ),
          offset,
        );
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final LatestArticlesResult result = useLatestArticles(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.articles.value.length}'),
                        ElevatedButton(
                          onPressed: result.loadMore,
                          child: const Text('Load More'),
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
      expect(find.text('Count: 10'), findsOneWidget);

      // Act - 載入更多
      await tester.tap(find.text('Load More'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Count: 20'), findsOneWidget);
    });

    testWidgets('should set hasMore to false when articles less than page size',
        (WidgetTester tester) async {
      // Arrange
      final List<Article> mockArticles = List<Article>.generate(
        5, // Less than page size (10)
        (int index) => Article(
          id: '$index',
          slug: 'article-$index',
          title: '文章 $index',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime.now(),
          isExternal: false,
        ),
      );

      when(() => mockApi.fetchPosts(limit: 10, offset: 0))
          .thenAnswer((_) async => createMockListResponse(mockArticles, 0));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final LatestArticlesResult result = useLatestArticles(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.articles.value.length}'),
                        Text('HasMore: ${result.hasMore.value}'),
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
      expect(find.text('Count: 5'), findsOneWidget);
      expect(find.text('HasMore: false'), findsOneWidget);
    });

    testWidgets('should refresh and reset articles', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;
      when(() => mockApi.fetchPosts(limit: 10, offset: 0))
          .thenAnswer((_) async {
        callCount++;
        return createMockListResponse(
          List<Article>.generate(
            10,
            (int index) => Article(
              id: 'call${callCount}_$index',
              slug: 'article-call${callCount}_$index',
              title: '文章 $callCount-$index',
              ogDescription: '描述',
              categorySet: <CategorySet>[],
              publishedDate: DateTime.now(),
              isExternal: false,
            ),
          ),
          0,
        );
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final LatestArticlesResult result = useLatestArticles(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.articles.value.length}'),
                        if (result.articles.value.isNotEmpty)
                          Text('FirstId: ${result.articles.value.first.id}'),
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
      expect(find.text('FirstId: call1_0'), findsOneWidget);

      // Act - 重新整理
      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      // Assert
      expect(callCount, equals(2));
      expect(find.text('Count: 10'), findsOneWidget);
      expect(find.text('FirstId: call2_0'), findsOneWidget);
    });

    testWidgets('should call API with correct parameters', (WidgetTester tester) async {
      // Arrange
      final List<Article> mockArticles = List<Article>.generate(
        10,
        (int index) => Article(
          id: '$index',
          slug: 'article-$index',
          title: '文章 $index',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime.now(),
          isExternal: false,
        ),
      );

      when(() => mockApi.fetchPosts(limit: 10, offset: 0))
          .thenAnswer((_) async => createMockListResponse(mockArticles, 0));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final LatestArticlesResult result = useLatestArticles(mockApi, pageSize: 10);

              return (BuildContext context) => Scaffold(
                    body: Text('Count: ${result.articles.value.length}'),
                  );
            },
          ),
        ),
      );

      // 等待載入完成
      await tester.pumpAndSettle();

      // Assert - 驗證 API 被正確調用
      verify(() => mockApi.fetchPosts(limit: 10, offset: 0)).called(1);
      expect(find.text('Count: 10'), findsOneWidget);
    });
  });
}
