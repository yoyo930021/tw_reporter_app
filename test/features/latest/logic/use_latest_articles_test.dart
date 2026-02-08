import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/latest/logic/use_latest_articles.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockArticleRepository mockRepo;

  setUp(() {
    mockRepo = MockArticleRepository();
  });

  /// Generate a list of test articles.
  List<Article> generateArticles(
    int count, {
    String prefix = '',
  }) {
    return List<Article>.generate(
      count,
      (i) => Article(
        id: '$prefix$i',
        slug: 'article-$prefix$i',
        title: '文章 $prefix$i',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime.now(),
        isExternal: false,
      ),
    );
  }

  group('useLatestArticles', () {
    testWidgets(
      'should load initial articles on mount',
      (tester) async {
        // Arrange
        final articles = generateArticles(10);

        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => articles);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result =
                    useLatestArticles(mockRepo);

                return (BuildContext context) =>
                    Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
                          ),
                          Text(
                            'Loading: '
                            '${result.isLoading.value}',
                          ),
                          Text(
                            'HasMore: '
                            '${result.hasMore.value}',
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Count: 10'),
          findsOneWidget,
        );
        expect(
          find.text('Loading: false'),
          findsOneWidget,
        );
        expect(
          find.text('HasMore: true'),
          findsOneWidget,
        );
        verify(() => mockRepo.fetchLatest(
              page: 1,
            )).called(1);
      },
    );

    testWidgets(
      'should load more articles when loadMore is called',
      (tester) async {
        // Arrange
        var currentPage = 0;
        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          currentPage++;
          return generateArticles(
            10,
            prefix: 'page${currentPage}_',
          );
        });

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result =
                    useLatestArticles(mockRepo);

                return (BuildContext context) =>
                    Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
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
        expect(
          find.text('Count: 10'),
          findsOneWidget,
        );

        // Act - load more
        await tester.tap(find.text('Load More'));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Count: 20'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should set hasMore to false when less than page size',
      (tester) async {
        // Arrange
        final articles = generateArticles(5);

        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => articles);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result =
                    useLatestArticles(mockRepo);

                return (BuildContext context) =>
                    Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
                          ),
                          Text(
                            'HasMore: '
                            '${result.hasMore.value}',
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Count: 5'),
          findsOneWidget,
        );
        expect(
          find.text('HasMore: false'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should refresh and reset articles',
      (tester) async {
        // Arrange
        var callCount = 0;
        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          callCount++;
          return generateArticles(
            10,
            prefix: 'call${callCount}_',
          );
        });

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result =
                    useLatestArticles(mockRepo);

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
                            onPressed: result.refresh,
                            child: const Text(
                              'Refresh',
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
        expect(
          find.text('FirstId: call1_0'),
          findsOneWidget,
        );

        // Act - refresh
        await tester.tap(find.text('Refresh'));
        await tester.pumpAndSettle();

        // Assert
        expect(callCount, equals(2));
        expect(
          find.text('Count: 10'),
          findsOneWidget,
        );
        expect(
          find.text('FirstId: call2_0'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should call repo with correct parameters',
      (tester) async {
        // Arrange
        final articles = generateArticles(10);

        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => articles);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result =
                    useLatestArticles(mockRepo);

                return (BuildContext context) =>
                    Scaffold(
                      body: Text(
                        'Count: '
                        '${result.articles.value.length}',
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        verify(() => mockRepo.fetchLatest(
              page: 1,
            )).called(1);
        expect(
          find.text('Count: 10'),
          findsOneWidget,
        );
      },
    );
  });
}
