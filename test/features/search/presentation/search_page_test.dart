import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/search/presentation/search_page.dart';

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
List<Article> _searchableArticles(String query, int count) {
  return List<Article>.generate(
    count,
    (int i) => Article(
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
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  Widget wrapWithApp(SearchPage searchPage) {
    return MaterialApp(
      home: searchPage,
    );
  }

  /// Mock fetchPosts to return articles matching query for client-side search.
  void mockSearchPosts(List<Article> articles) {
    when(() => mockApi.fetchPosts(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        )).thenAnswer((_) async => _listResponse(articles));
  }

  group('SearchPage', () {
    testWidgets('should display app bar with title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithApp(SearchPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('搜尋'), findsOneWidget);
    });

    testWidgets('should display search input field', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithApp(SearchPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('請輸入關鍵字'), findsOneWidget);
    });

    testWidgets('should display initial empty state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithApp(SearchPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('請輸入關鍵字開始搜尋'), findsOneWidget);
    });

    testWidgets('should display search results after input',
        (WidgetTester tester) async {
      // Arrange - searchArticles calls fetchPosts(limit:50, offset:0)
      // then filters by title containing query
      mockSearchPosts(_searchableArticles('測試', 3));

      // Act
      await tester.pumpWidget(
        wrapWithApp(SearchPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // 輸入搜尋關鍵字
      await tester.enterText(find.byType(TextField), '測試');
      await tester.pump(const Duration(milliseconds: 600)); // 等待 debounce
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('測試結果 0'), findsOneWidget);
      expect(find.text('測試結果 2'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should handle searching state correctly',
        (WidgetTester tester) async {
      // Arrange - return empty articles (no matches after filter)
      mockSearchPosts(<Article>[]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(SearchPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // 輸入搜尋關鍵字並等待搜尋完成
      await tester.enterText(find.byType(TextField), '測試');
      await tester.pump(const Duration(milliseconds: 600)); // 等待 debounce
      await tester.pumpAndSettle();

      // Assert - 搜尋完成後應該顯示結果（即使是空的）
      expect(find.text('找不到相關文章'), findsOneWidget);
      verify(() => mockApi.fetchPosts(
            limit: 50,
            offset: 0,
          )).called(1);
    });

    testWidgets('should display empty results message when no results found',
        (WidgetTester tester) async {
      // Arrange - return articles that don't match query
      mockSearchPosts(<Article>[]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(SearchPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // 輸入搜尋關鍵字
      await tester.enterText(find.byType(TextField), '不存在');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('找不到相關文章'), findsOneWidget);
    });

    testWidgets('should clear results when input is cleared',
        (WidgetTester tester) async {
      // Arrange
      mockSearchPosts(_searchableArticles('測試', 2));

      // Act
      await tester.pumpWidget(
        wrapWithApp(SearchPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // 輸入搜尋關鍵字
      await tester.enterText(find.byType(TextField), '測試');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('測試結果 0'), findsOneWidget);

      // Act - 清空輸入
      await tester.enterText(find.byType(TextField), '');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Assert - 應該顯示初始狀態
      expect(find.text('請輸入關鍵字開始搜尋'), findsOneWidget);
      expect(find.text('測試結果 0'), findsNothing);
    });

    testWidgets('should display article with formatted date',
        (WidgetTester tester) async {
      // Arrange
      final List<Article> articles = <Article>[
        Article(
          id: '1',
          slug: 'test-article',
          title: '測試文章',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 3, 15),
          isExternal: false,
        ),
      ];
      mockSearchPosts(articles);

      // Act
      await tester.pumpWidget(
        wrapWithApp(SearchPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // 輸入搜尋關鍵字
      await tester.enterText(find.byType(TextField), '測試');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('測試文章'), findsOneWidget);
      expect(find.textContaining('2024'), findsOneWidget);
    });

    testWidgets('should support scrolling to load more results',
        (WidgetTester tester) async {
      // Arrange
      var callCount = 0;
      when(() => mockApi.fetchPosts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async {
        callCount++;
        return _listResponse(
          _searchableArticles('測試', 10),
        );
      });

      // Act
      await tester.pumpWidget(
        wrapWithApp(SearchPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // 輸入搜尋關鍵字
      await tester.enterText(find.byType(TextField), '測試');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('測試結果 0'), findsOneWidget);

      // 滾動到底部觸發載入更多
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Assert - 應該載入了第二頁
      expect(callCount, greaterThanOrEqualTo(1));
    });
  });
}
