import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/category/logic/use_category_articles.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

/// Helper: create a [ListResponse] wrapping [articles].
ListResponse<Article> _listResponse(
  List<Article> articles, {
  int offset = 0,
  int total = 100,
}) {
  return ListResponse<Article>(
    data: ListData<Article>(
      meta: ListMeta(
        limit: articles.length,
        offset: offset,
        total: total,
      ),
      records: articles,
    ),
    status: 'success',
  );
}

/// Helper: generate [count] articles whose categorySet contains [catName].
List<Article> _articlesWithCategory(String catName, int count, {String prefix = ''}) {
  return List<Article>.generate(
    count,
    (int i) => Article(
      id: '$prefix$i',
      slug: 'article-$prefix$i',
      title: '$catName文章 $prefix$i',
      ogDescription: '描述',
      categorySet: <CategorySet>[
        CategorySet(
          category: Category(id: 'cat-$catName', name: catName),
        ),
      ],
      publishedDate: DateTime.now(),
      isExternal: false,
    ),
  );
}

// 測試用的 Composition Widget
class TestWidget extends CompositionWidget {
  const TestWidget({required this.setupFn, super.key});

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
    testWidgets(
      'should load articles for specific category on mount',
      (WidgetTester tester) async {
        // fetchCategoryArticles(category:'國際', page:1, limit:10)
        // internally calls fetchPosts(limit:80, offset:0)
        final articles = _articlesWithCategory('國際', 10);
        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => _listResponse(articles));

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockApi,
                  category: '國際',
                );
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

        await tester.pumpAndSettle();

        expect(find.text('Count: 10'), findsOneWidget);
        expect(find.text('Category: 國際'), findsOneWidget);
        expect(find.text('Loading: false'), findsOneWidget);
        expect(find.text('HasMore: true'), findsOneWidget);
        verify(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: 0,
            )).called(1);
      },
    );

    testWidgets(
      'should load more articles when loadMore is called',
      (WidgetTester tester) async {
        var callCount = 0;
        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async {
          callCount++;
          return _listResponse(
            _articlesWithCategory('政治', 10, prefix: 'p${callCount}_'),
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockApi,
                  category: '政治',
                );
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

        await tester.pumpAndSettle();
        expect(find.text('Count: 10'), findsOneWidget);

        // Act – load more
        await tester.tap(find.text('Load More'));
        await tester.pumpAndSettle();

        expect(find.text('Count: 20'), findsOneWidget);
      },
    );

    testWidgets(
      'should set hasMore to false when articles less than page size',
      (WidgetTester tester) async {
        // Return only 5 articles (less than pageSize 10) → hasMore = false
        final articles = _articlesWithCategory('人權', 5);
        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => _listResponse(articles));

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockApi,
                  category: '人權',
                );
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

        await tester.pumpAndSettle();

        expect(find.text('Count: 5'), findsOneWidget);
        expect(find.text('HasMore: false'), findsOneWidget);
      },
    );

    testWidgets(
      'should refresh and reset articles',
      (WidgetTester tester) async {
        var callCount = 0;
        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async {
          callCount++;
          return _listResponse(
            _articlesWithCategory('環境', 10, prefix: 'call${callCount}_'),
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockApi,
                  category: '環境',
                );
                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text('Count: ${result.articles.value.length}'),
                          if (result.articles.value.isNotEmpty)
                            Text(
                              'FirstId: ${result.articles.value.first.id}',
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
        expect(find.text('FirstId: call1_0'), findsOneWidget);

        // Refresh
        await tester.tap(find.text('Refresh'));
        await tester.pumpAndSettle();

        expect(callCount, equals(2));
        expect(find.text('Count: 10'), findsOneWidget);
        expect(find.text('FirstId: call2_0'), findsOneWidget);
      },
    );

    testWidgets(
      'should handle different categories',
      (WidgetTester tester) async {
        final articles = _articlesWithCategory('文化', 3);
        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => _listResponse(articles));

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockApi,
                  category: '文化',
                );
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

        expect(find.text('Count: 3'), findsOneWidget);
        expect(find.text('Category: 文化'), findsOneWidget);
        verify(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: 0,
            )).called(1);
      },
    );

    testWidgets(
      'should call API with correct parameters',
      (WidgetTester tester) async {
        final articles = _articlesWithCategory('經濟', 10);
        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => _listResponse(articles));

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useCategoryArticles(
                  mockApi,
                  category: '經濟',
                  pageSize: 10,
                );
                return (BuildContext context) => Scaffold(
                      body: Text(
                        'Count: ${result.articles.value.length}',
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // fetchCategoryArticles internally calls fetchPosts with limit*8=80
        verify(() => mockApi.fetchPosts(limit: 80, offset: 0)).called(1);
        expect(find.text('Count: 10'), findsOneWidget);
      },
    );
  });
}
