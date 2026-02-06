import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/category/logic/use_category_articles.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

// Helper function to create mock ListResponse
ListResponse<Article> createMockListResponse(List<Article> articles, int offset) {
  return ListResponse<Article>(
    data: ListData<Article>(
      meta: ListMeta(limit: articles.length > 0 ? articles.length : 10, offset: offset, total: 100),
      records: articles,
    ),
    status: 'success',
  );
}

// Helper to create articles with specific category
List<Article> createArticlesWithCategory(String categoryName, int count) {
  return List<Article>.generate(
    count,
    (int index) => Article(
      id: '$index',
      slug: 'article-$index',
      title: '$categoryName文章 $index',
      ogDescription: '描述',
      categorySet: <CategorySet>[
        CategorySet(
          category: Category(
            id: 'cat-$categoryName',
            name: categoryName,
          ),
        ),
      ],
      publishedDate: DateTime.now(),
      isExternal: false,
    ),
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

  group('useCategoryArticles', () {
    testWidgets('should load articles for specific category on mount',
        (WidgetTester tester) async {
      // Arrange
      // Create articles with the correct category
      final List<Article> mockArticles = createArticlesWithCategory('國際', 10);

      // Mock fetchPosts - extension method calls this with limit * 8
      when(() => mockApi.fetchPosts(limit: 80, offset: 0))
          .thenAnswer((_) async => createMockListResponse(mockArticles, 0));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final CategoryArticlesResult result =
                  useCategoryArticles(mockApi, category: '國際');

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.articles.value.length}'),
                        Text('Category: ${result.category}'),
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
      expect(find.text('Category: 國際'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('HasMore: true'), findsOneWidget);
      verify(() => mockApi.fetchCategoryArticles(
            category: '國際',
            page: 1,
            limit: 10,
          )).called(1);
    });

    testWidgets('should load more articles when loadMore is called',
        (WidgetTester tester) async {
      // Arrange
      int currentPage = 1;
      when(() => mockApi.fetchCategoryArticles(
            category: '政治',
            page: any(named: 'page'),
            limit: 10,
          )).thenAnswer((_) async {
        return List<Article>.generate(
          10,
          (int index) => Article(
            id: 'page${currentPage}_$index',
            slug: 'article-page${currentPage}_$index',
            title: '政治文章 $currentPage-$index',
            ogDescription: '描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime.now(),
            isExternal: false,
          ),
        )..forEach((_) => currentPage++);
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final CategoryArticlesResult result =
                  useCategoryArticles(mockApi, category: '政治');

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
          title: '人權文章 $index',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime.now(),
          isExternal: false,
        ),
      );

      when(() => mockApi.fetchCategoryArticles(
            category: '人權',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => mockArticles);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final CategoryArticlesResult result =
                  useCategoryArticles(mockApi, category: '人權');

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
      when(() => mockApi.fetchCategoryArticles(
            category: '環境',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async {
        callCount++;
        return List<Article>.generate(
          10,
          (int index) => Article(
            id: 'call${callCount}_$index',
            slug: 'article-call${callCount}_$index',
            title: '環境文章 $callCount-$index',
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
              final CategoryArticlesResult result =
                  useCategoryArticles(mockApi, category: '環境');

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

    testWidgets('should handle different categories', (WidgetTester tester) async {
      // Arrange
      final List<Article> mockArticles1 = List<Article>.generate(
        3,
        (int index) => Article(
          id: 'culture_$index',
          slug: 'article-$index',
          title: '文化文章 $index',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime.now(),
          isExternal: false,
        ),
      );

      final List<Article> mockArticles2 = List<Article>.generate(
        5,
        (int index) => Article(
          id: 'education_$index',
          slug: 'article-$index',
          title: '教育文章 $index',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime.now(),
          isExternal: false,
        ),
      );

      when(() => mockApi.fetchCategoryArticles(
            category: '文化',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => mockArticles1);

      when(() => mockApi.fetchCategoryArticles(
            category: '教育',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => mockArticles2);

      // Act - 載入文化分類
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final CategoryArticlesResult result =
                  useCategoryArticles(mockApi, category: '文化');

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.articles.value.length}'),
                        Text('Category: ${result.category}'),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Count: 3'), findsOneWidget);
      expect(find.text('Category: 文化'), findsOneWidget);
      verify(() => mockApi.fetchCategoryArticles(
            category: '文化',
            page: 1,
            limit: 10,
          )).called(1);
    });

    testWidgets('should call API with correct parameters',
        (WidgetTester tester) async {
      // Arrange
      final List<Article> mockArticles = List<Article>.generate(
        10,
        (int index) => Article(
          id: '$index',
          slug: 'article-$index',
          title: '經濟文章 $index',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime.now(),
          isExternal: false,
        ),
      );

      when(() => mockApi.fetchCategoryArticles(
            category: '經濟',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => mockArticles);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final CategoryArticlesResult result = useCategoryArticles(
                mockApi,
                category: '經濟',
                pageSize: 10,
              );

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
      verify(() => mockApi.fetchCategoryArticles(
            category: '經濟',
            page: 1,
            limit: 10,
          )).called(1);
      expect(find.text('Count: 10'), findsOneWidget);
    });
  });
}
