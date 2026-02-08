import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/search/logic/use_search.dart';

import '../../../helpers/test_helpers.dart';

/// Helper: create articles with title containing [query].
List<Article> _searchableArticles(
  String query,
  int count, {
  String prefix = '',
}) {
  return List<Article>.generate(
    count,
    (i) => Article(
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

void main() {
  late MockArticleRepository mockRepo;

  setUp(() {
    mockRepo = MockArticleRepository();
  });

  /// Setup mock search returning articles.
  void mockSearch(List<Article> articles) {
    when(() => mockRepo.search(
          query: any(named: 'query'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => articles);
  }

  group('useSearch', () {
    testWidgets(
      'should start with empty query and no results',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useSearch(mockRepo);

                return (BuildContext context) =>
                    Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Query: '
                            '${result.query.value}',
                          ),
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
                          ),
                          Text(
                            'IsSearching: '
                            '${result.isSearching.value}',
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Query: '),
          findsOneWidget,
        );
        expect(
          find.text('Count: 0'),
          findsOneWidget,
        );
        expect(
          find.text('IsSearching: false'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should update query when setQuery is called',
      (tester) async {
        mockSearch(_searchableArticles('測試', 5));

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useSearch(mockRepo);

                return (BuildContext context) =>
                    Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Query: '
                            '${result.query.value}',
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                result.setQuery('測試'),
                            child: const Text(
                              'Set Query',
                            ),
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Set Query'));
        await tester.pump();

        expect(
          find.text('Query: 測試'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should search with debounce when query changes',
      (tester) async {
        mockSearch(_searchableArticles('測試', 5));

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useSearch(mockRepo);

                return (BuildContext context) =>
                    Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                result.setQuery('測試'),
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

        await tester.tap(find.text('Search'));
        await tester.pump();
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Count: 5'),
          findsOneWidget,
        );
        verify(() => mockRepo.search(
              query: '測試',
              page: 1,
            )).called(1);
      },
    );

    testWidgets(
      'should not search if query is empty',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useSearch(mockRepo);

                return (BuildContext context) =>
                    Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                result.setQuery(''),
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

        await tester.tap(find.text('Clear'));
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();

        verifyNever(() => mockRepo.search(
              query: any(named: 'query'),
              page: any(named: 'page'),
            ));
        expect(
          find.text('Count: 0'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should load more results when loadMore is called',
      (tester) async {
        var callCount = 0;
        when(() => mockRepo.search(
              query: any(named: 'query'),
              page: any(named: 'page'),
            )).thenAnswer((_) async {
          callCount++;
          return _searchableArticles(
            '測試',
            10,
            prefix: 'p${callCount}_',
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useSearch(mockRepo);

                return (BuildContext context) =>
                    Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                result.setQuery('測試'),
                            child: const Text('Search'),
                          ),
                          ElevatedButton(
                            onPressed: result.loadMore,
                            child: const Text(
                              'Load More',
                            ),
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Trigger search
        await tester.tap(find.text('Search'));
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Count: 10'),
          findsOneWidget,
        );

        // Load more
        await tester.tap(find.text('Load More'));
        await tester.pumpAndSettle();

        expect(
          find.text('Count: 20'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should clear results when query changes',
      (tester) async {
        var callCount = 0;
        when(() => mockRepo.search(
              query: any(named: 'query'),
              page: any(named: 'page'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return _searchableArticles(
              '第一次',
              5,
              prefix: 'first_',
            );
          } else {
            return _searchableArticles(
              '第二次',
              3,
              prefix: 'second_',
            );
          }
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useSearch(mockRepo);

                return (BuildContext context) =>
                    Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
                          ),
                          if (result
                              .articles.value.isNotEmpty)
                            Text(
                              'FirstId: '
                              '${result.articles.value.first.id}',
                            ),
                          ElevatedButton(
                            onPressed: () =>
                                result.setQuery('第一次'),
                            child: const Text('First'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                result.setQuery('第二次'),
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

        // First search
        await tester.tap(find.text('First'));
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Count: 5'),
          findsOneWidget,
        );
        expect(
          find.text('FirstId: first_0'),
          findsOneWidget,
        );

        // Second search
        await tester.tap(find.text('Second'));
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Count: 3'),
          findsOneWidget,
        );
        expect(
          find.text('FirstId: second_0'),
          findsOneWidget,
        );
      },
    );
  });
}
