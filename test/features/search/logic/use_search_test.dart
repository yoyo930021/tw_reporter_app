import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/search/logic/use_search.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

/// Helper: wrap articles in a [ListResponse].
ListResponse<Article> _listResponse(List<Article> articles, {int offset = 0}) {
  return ListResponse<Article>(
    data: ListData<Article>(
      meta: ListMeta(
        limit: articles.length,
        offset: offset,
        total: 100,
      ),
      records: articles,
    ),
    status: 'success',
  );
}

/// Helper: create articles whose title contains [query] for client-side search.
List<Article> _searchableArticles(String query, int count, {String prefix = ''}) {
  return List<Article>.generate(
    count,
    (int i) => Article(
      id: '$prefix$i',
      slug: 'article-$prefix$i',
      title: '$query結果 $prefix$i',
      ogDescription: '描述 $prefix$i',
      categorySet: <CategorySet>[],
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

  /// Setup default fetchPosts mock returning articles with matching titles.
  void mockFetchPosts(List<Article> articles) {
    when(() => mockApi.fetchPosts(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => _listResponse(articles));
  }

  group('useSearch', () {
    testWidgets('should start with empty query and no results',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final SearchResult result = useSearch(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Query: ${result.query.value}'),
                        Text('Count: ${result.articles.value.length}'),
                        Text('IsSearching: ${result.isSearching.value}'),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Query: '), findsOneWidget);
      expect(find.text('Count: 0'), findsOneWidget);
      expect(find.text('IsSearching: false'), findsOneWidget);
    });

    testWidgets('should update query when setQuery is called',
        (WidgetTester tester) async {
      // Arrange - Mock fetchPosts for debounced search
      mockFetchPosts(_searchableArticles('測試', 5));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final SearchResult result = useSearch(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Query: ${result.query.value}'),
                        ElevatedButton(
                          onPressed: () => result.setQuery('測試'),
                          child: const Text('Set Query'),
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - 設定查詢
      await tester.tap(find.text('Set Query'));
      await tester.pump(); // 只 pump 一次來更新 UI

      // Assert
      expect(find.text('Query: 測試'), findsOneWidget);
    });

    testWidgets('should search with debounce when query changes',
        (WidgetTester tester) async {
      // Arrange - searchArticles internally calls fetchPosts(limit:50, offset:0)
      // and filters by title containing query
      mockFetchPosts(_searchableArticles('測試', 5));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final SearchResult result = useSearch(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.articles.value.length}'),
                        ElevatedButton(
                          onPressed: () => result.setQuery('測試'),
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - 設定查詢並等待 debounce
      await tester.tap(find.text('Search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600)); // 等待 debounce (500ms + buffer)
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Count: 5'), findsOneWidget);
      verify(() => mockApi.fetchPosts(
            limit: 50,
            offset: 0,
          )).called(1);
    });

    testWidgets('should not search if query is empty',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final SearchResult result = useSearch(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.articles.value.length}'),
                        ElevatedButton(
                          onPressed: () => result.setQuery(''),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - 設定空查詢
      await tester.tap(find.text('Clear'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Assert - 不應該調用 API
      verifyNever(() => mockApi.fetchPosts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ));
      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('should load more results when loadMore is called',
        (WidgetTester tester) async {
      // Arrange
      var callCount = 0;
      when(() => mockApi.fetchPosts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async {
        callCount++;
        return _listResponse(
          _searchableArticles('測試', 10, prefix: 'p${callCount}_'),
        );
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final SearchResult result = useSearch(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.articles.value.length}'),
                        ElevatedButton(
                          onPressed: () => result.setQuery('測試'),
                          child: const Text('Search'),
                        ),
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

      await tester.pumpAndSettle();

      // 觸發搜尋
      await tester.tap(find.text('Search'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Count: 10'), findsOneWidget);

      // Act - 載入更多
      await tester.tap(find.text('Load More'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Count: 20'), findsOneWidget);
    });

    testWidgets('should clear results when query changes',
        (WidgetTester tester) async {
      // Arrange - both searches go through fetchPosts
      // First search: articles with '第一次' in title
      // Second search: articles with '第二次' in title
      var callCount = 0;
      when(() => mockApi.fetchPosts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return _listResponse(
            _searchableArticles('第一次', 5, prefix: 'first_'),
          );
        } else {
          return _listResponse(
            _searchableArticles('第二次', 3, prefix: 'second_'),
          );
        }
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final SearchResult result = useSearch(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.articles.value.length}'),
                        if (result.articles.value.isNotEmpty)
                          Text('FirstId: ${result.articles.value.first.id}'),
                        ElevatedButton(
                          onPressed: () => result.setQuery('第一次'),
                          child: const Text('First'),
                        ),
                        ElevatedButton(
                          onPressed: () => result.setQuery('第二次'),
                          child: const Text('Second'),
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 第一次搜尋
      await tester.tap(find.text('First'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Count: 5'), findsOneWidget);
      expect(find.text('FirstId: first_0'), findsOneWidget);

      // Act - 第二次搜尋應該清空之前的結果
      await tester.tap(find.text('Second'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Count: 3'), findsOneWidget);
      expect(find.text('FirstId: second_0'), findsOneWidget);
    });
  });
}
