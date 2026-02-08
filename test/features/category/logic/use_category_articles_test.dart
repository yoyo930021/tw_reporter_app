import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/category/logic/use_category_articles.dart';

import '../../../helpers/test_helpers.dart';

/// Generate [count] articles with [catName] category.
List<Article> _articlesWithCategory(
  String catName,
  int count, {
  String prefix = '',
}) {
  return List<Article>.generate(
    count,
    (i) => createTestArticle(
      id: '$prefix$i',
      slug: 'article-$prefix$i',
      title: '$catName文章 $prefix$i',
      categorySet: <CategorySet>[
        CategorySet(
          category: Category(
            id: 'cat-$catName',
            name: catName,
          ),
        ),
      ],
    ),
  );
}

void main() {
  late MockArticleRepository mockRepo;

  setUp(() {
    mockRepo = MockArticleRepository();
  });

  group('useCategoryArticles', () {
    testWidgets(
      'should load articles for specific category on mount',
      (tester) async {
        final articles =
            _articlesWithCategory('國際', 10);
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => articles);

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockRepo,
                  category: '國際',
                );
                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
                          ),
                          Text(
                            'Category: ${result.category}',
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

        expect(find.text('Count: 10'), findsOneWidget);
        expect(
          find.text('Category: 國際'),
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
        verify(() => mockRepo.fetchByCategory(
              category: '國際',
              page: 1,
            )).called(1);
      },
    );

    testWidgets(
      'should load more articles when loadMore is called',
      (tester) async {
        var callCount = 0;
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          callCount++;
          return _articlesWithCategory(
            '政治',
            10,
            prefix: 'p${callCount}_',
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockRepo,
                  category: '政治',
                );
                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
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
        expect(find.text('Count: 10'), findsOneWidget);

        await tester.tap(find.text('Load More'));
        await tester.pumpAndSettle();

        expect(find.text('Count: 20'), findsOneWidget);
      },
    );

    testWidgets(
      'should set hasMore to false when articles '
      'less than page size',
      (tester) async {
        final articles =
            _articlesWithCategory('人權', 5);
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => articles);

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockRepo,
                  category: '人權',
                );
                return (BuildContext context) => Scaffold(
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

        expect(find.text('Count: 5'), findsOneWidget);
        expect(
          find.text('HasMore: false'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should refresh and reset articles',
      (tester) async {
        var callCount = 0;
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          callCount++;
          return _articlesWithCategory(
            '環境',
            10,
            prefix: 'call${callCount}_',
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockRepo,
                  category: '環境',
                );
                return (BuildContext context) => Scaffold(
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
                            child: const Text('Refresh'),
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

        await tester.tap(find.text('Refresh'));
        await tester.pumpAndSettle();

        expect(callCount, equals(2));
        expect(find.text('Count: 10'), findsOneWidget);
        expect(
          find.text('FirstId: call2_0'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should handle different categories',
      (tester) async {
        final articles =
            _articlesWithCategory('文化', 3);
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => articles);

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockRepo,
                  category: '文化',
                );
                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.articles.value.length}',
                          ),
                          Text(
                            'Category: ${result.category}',
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Count: 3'), findsOneWidget);
        expect(
          find.text('Category: 文化'),
          findsOneWidget,
        );
        verify(() => mockRepo.fetchByCategory(
              category: '文化',
              page: 1,
            )).called(1);
      },
    );

    testWidgets(
      'should call repo with correct parameters',
      (tester) async {
        final articles =
            _articlesWithCategory('經濟', 10);
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => articles);

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockRepo,
                  category: '經濟',
                );
                return (BuildContext context) => Scaffold(
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

        verify(() => mockRepo.fetchByCategory(
              category: '經濟',
              page: 1,
            )).called(1);
        expect(find.text('Count: 10'), findsOneWidget);
      },
    );
  });
}
