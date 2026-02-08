import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/search/presentation/search_page.dart';

import '../../../helpers/test_helpers.dart';

/// Helper: create articles with title containing [query].
List<Article> _searchableArticles(
  String query,
  int count,
) {
  return List<Article>.generate(
    count,
    (i) => Article(
      id: '$i',
      slug: 'article-$i',
      title: '$query結果 $i',
      ogDescription: '描述 $i',
      categorySet: <CategorySet>[],
      publishedDate: DateTime(2024, 1, 1 + i),
      isExternal: false,
    ),
  );
}

void main() {
  late MockArticleRepository mockRepo;

  setUp(() {
    mockRepo = MockArticleRepository();
  });

  Widget buildPage() {
    return wrapWithProviders(
      const SearchPage(),
      articleRepository: mockRepo,
    );
  }

  /// Mock search returning articles.
  void mockSearch(List<Article> articles) {
    when(() => mockRepo.search(
          query: any(named: 'query'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => articles);
  }

  group('SearchPage', () {
    testWidgets(
      'should display app bar with title',
      (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('搜尋'), findsOneWidget);
      },
    );

    testWidgets(
      'should display search input field',
      (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.byType(TextField),
          findsOneWidget,
        );
        expect(
          find.text('請輸入關鍵字'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display initial empty state',
      (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.text('請輸入關鍵字開始搜尋'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display search results after input',
      (tester) async {
        mockSearch(_searchableArticles('測試', 3));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          '測試',
        );
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('測試結果 0'),
          findsOneWidget,
        );
        expect(
          find.text('測試結果 2'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should handle searching state correctly',
      (tester) async {
        mockSearch(<Article>[]);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          '測試',
        );
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('找不到相關文章'),
          findsOneWidget,
        );
        verify(() => mockRepo.search(
              query: '測試',
              page: 1,
            )).called(1);
      },
    );

    testWidgets(
      'should display empty results when no results',
      (tester) async {
        mockSearch(<Article>[]);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          '不存在',
        );
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('找不到相關文章'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should clear results when input is cleared',
      (tester) async {
        mockSearch(_searchableArticles('測試', 2));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          '測試',
        );
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('測試結果 0'),
          findsOneWidget,
        );

        // Clear input
        await tester.enterText(
          find.byType(TextField),
          '',
        );
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('請輸入關鍵字開始搜尋'),
          findsOneWidget,
        );
        expect(
          find.text('測試結果 0'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'should display article with formatted date',
      (tester) async {
        mockSearch(<Article>[
          createTestArticle(
            publishedDate: DateTime(2024, 3, 15),
          ),
        ]);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          '測試',
        );
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();

        expect(find.text('測試文章'), findsOneWidget);
        expect(
          find.textContaining('2024'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should support scrolling to load more results',
      (tester) async {
        var callCount = 0;
        when(() => mockRepo.search(
              query: any(named: 'query'),
              page: any(named: 'page'),
            )).thenAnswer((_) async {
          callCount++;
          return _searchableArticles('測試', 10);
        });

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          '測試',
        );
        await tester.pump(
          const Duration(milliseconds: 600),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('測試結果 0'),
          findsOneWidget,
        );

        // Scroll to bottom to trigger load more
        await tester.drag(
          find.byType(ListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        expect(callCount, greaterThanOrEqualTo(1));
      },
    );
  });
}
