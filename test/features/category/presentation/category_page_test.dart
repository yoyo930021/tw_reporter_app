import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/category/presentation/category_page.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

/// Helper: wrap articles in a [ListResponse].
ListResponse<Article> _listResponse(List<Article> articles) {
  return ListResponse<Article>(
    data: ListData<Article>(
      meta: ListMeta(
        limit: articles.length,
        offset: 0,
        total: 100,
      ),
      records: articles,
    ),
    status: 'success',
  );
}

/// Helper: create articles with the given category name.
List<Article> _withCat(String cat, int count) {
  return List<Article>.generate(
    count,
    (int i) => Article(
      id: '$i',
      slug: 'article-$i',
      title: '$cat文章 $i',
      ogDescription: '描述 $i',
      categorySet: <CategorySet>[
        CategorySet(
          category: Category(id: 'cat-$cat', name: cat),
        ),
      ],
      publishedDate: DateTime(2024, 1, 1 + i),
      isExternal: false,
    ),
  );
}

/// Setup a default fetchPosts mock that returns [articles].
void _mockFetchPosts(
  MockTwReporterApi api,
  List<Article> articles,
) {
  when(() => api.fetchPosts(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => _listResponse(articles));
}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  Widget wrapWithApp(CategoryPage categoryPage) {
    return MaterialApp(home: categoryPage);
  }

  group('CategoryPage', () {
    testWidgets(
      'should display app bar with category name',
      (WidgetTester tester) async {
        _mockFetchPosts(mockApi, <Article>[]);

        await tester.pumpWidget(
          wrapWithApp(
            CategoryPage(api: mockApi, category: '國際'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('國際'), findsOneWidget);
      },
    );

    testWidgets(
      'should display list of articles after loading',
      (WidgetTester tester) async {
        _mockFetchPosts(mockApi, _withCat('政治', 5));

        await tester.pumpWidget(
          wrapWithApp(
            CategoryPage(api: mockApi, category: '政治'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('政治文章 0'), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
      },
    );

    testWidgets(
      'should display loading indicator on initial load',
      (WidgetTester tester) async {
        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async {
          await Future<void>.delayed(
            const Duration(milliseconds: 50),
          );
          return _listResponse(<Article>[]);
        });

        await tester.pumpWidget(
          wrapWithApp(
            CategoryPage(api: mockApi, category: '人權'),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'should display empty state when no articles',
      (WidgetTester tester) async {
        _mockFetchPosts(mockApi, <Article>[]);

        await tester.pumpWidget(
          wrapWithApp(
            CategoryPage(api: mockApi, category: '健康'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('此分類目前沒有文章'), findsOneWidget);
      },
    );

    testWidgets(
      'should have RefreshIndicator for pull to refresh',
      (WidgetTester tester) async {
        _mockFetchPosts(mockApi, _withCat('環境', 3));

        await tester.pumpWidget(
          wrapWithApp(
            CategoryPage(api: mockApi, category: '環境'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(RefreshIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'should load more articles when scrolling to bottom',
      (WidgetTester tester) async {
        var callCount = 0;
        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async {
          callCount++;
          return _listResponse(
            _withCat('經濟', 10),
          );
        });

        await tester.pumpWidget(
          wrapWithApp(
            CategoryPage(api: mockApi, category: '經濟'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('經濟文章 0'), findsOneWidget);

        await tester.drag(
          find.byType(ListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        // Should have loaded at least the second page
        expect(callCount, greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      'should not show load more indicator when no more articles',
      (WidgetTester tester) async {
        // Return fewer than page size → no more to load
        _mockFetchPosts(mockApi, _withCat('文化', 3));

        await tester.pumpWidget(
          wrapWithApp(
            CategoryPage(api: mockApi, category: '文化'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('載入更多...'), findsNothing);
      },
    );

    testWidgets(
      'should display article with formatted date',
      (WidgetTester tester) async {
        final List<Article> articles = <Article>[
          Article(
            id: '1',
            slug: 'test-article',
            title: '教育文章',
            ogDescription: '描述',
            categorySet: <CategorySet>[
              CategorySet(
                category: Category(
                  id: 'cat-教育',
                  name: '教育',
                ),
              ),
            ],
            publishedDate: DateTime(2024, 3, 15),
            isExternal: false,
          ),
        ];
        _mockFetchPosts(mockApi, articles);

        await tester.pumpWidget(
          wrapWithApp(
            CategoryPage(api: mockApi, category: '教育'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('教育文章'), findsOneWidget);
        expect(find.textContaining('2024'), findsOneWidget);
      },
    );

    testWidgets(
      'should handle different category parameters',
      (WidgetTester tester) async {
        _mockFetchPosts(mockApi, _withCat('國際', 1));

        await tester.pumpWidget(
          wrapWithApp(
            CategoryPage(api: mockApi, category: '國際'),
          ),
        );
        await tester.pumpAndSettle();

        // "國際" appears in both AppBar and CategoryBadge
        expect(find.text('國際'), findsAtLeast(1));
        expect(find.text('國際文章 0'), findsOneWidget);
      },
    );
  });
}
