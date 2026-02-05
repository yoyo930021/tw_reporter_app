import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/search/logic/use_search.dart';

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
      // Arrange - Mock API 以避免 debounced search 失敗
      when(() => mockApi.searchArticles(query: '測試', page: 1))
          .thenAnswer((_) async => <Article>[]);

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
      // Arrange
      final List<Article> mockArticles = List<Article>.generate(
        5,
        (int index) => Article(
          id: '$index',
          slug: 'article-$index',
          title: '搜尋結果 $index',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime.now(),
          isExternal: false,
        ),
      );

      when(() => mockApi.searchArticles(query: '測試', page: 1))
          .thenAnswer((_) async => mockArticles);

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
      verify(() => mockApi.searchArticles(query: '測試', page: 1)).called(1);
    });

    testWidgets('should not search if query is empty', (WidgetTester tester) async {
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
      verifyNever(() => mockApi.searchArticles(query: '', page: any(named: 'page')));
      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('should load more results when loadMore is called',
        (WidgetTester tester) async {
      // Arrange
      int currentPage = 1;
      when(() => mockApi.searchArticles(
            query: '測試',
            page: any(named: 'page'),
          )).thenAnswer((_) async {
        return List<Article>.generate(
          10,
          (int index) => Article(
            id: 'page${currentPage}_$index',
            slug: 'article-$index',
            title: '結果 $currentPage-$index',
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
      // Arrange
      when(() => mockApi.searchArticles(query: '第一次', page: 1))
          .thenAnswer((_) async => List<Article>.generate(
                5,
                (int index) => Article(
                  id: 'first_$index',
                  slug: 'article-$index',
                  title: '第一次結果 $index',
                  ogDescription: '描述',
                  categorySet: <CategorySet>[],
                  publishedDate: DateTime.now(),
                  isExternal: false,
                ),
              ));

      when(() => mockApi.searchArticles(query: '第二次', page: 1))
          .thenAnswer((_) async => List<Article>.generate(
                3,
                (int index) => Article(
                  id: 'second_$index',
                  slug: 'article-$index',
                  title: '第二次結果 $index',
                  ogDescription: '描述',
                  categorySet: <CategorySet>[],
                  publishedDate: DateTime.now(),
                  isExternal: false,
                ),
              ));

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
