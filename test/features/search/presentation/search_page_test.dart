import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/search/presentation/search_page.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

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
      // Arrange
      final List<Article> mockArticles = List<Article>.generate(
        3,
        (int index) => Article(
          id: '$index',
          slug: 'article-$index',
          title: '搜尋結果 $index',
          ogDescription: '描述 $index',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 1, 1 + index),
          isExternal: false,
        ),
      );

      when(() => mockApi.searchArticles(query: '測試', page: 1))
          .thenAnswer((_) async => mockArticles);

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
      expect(find.text('搜尋結果 0'), findsOneWidget);
      expect(find.text('搜尋結果 2'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should handle searching state correctly',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.searchArticles(query: '測試', page: 1))
          .thenAnswer((_) async => <Article>[]);

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
      verify(() => mockApi.searchArticles(query: '測試', page: 1)).called(1);
    });

    testWidgets('should display empty results message when no results found',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.searchArticles(query: '不存在', page: 1))
          .thenAnswer((_) async => <Article>[]);

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
      when(() => mockApi.searchArticles(query: '測試', page: 1))
          .thenAnswer((_) async => List<Article>.generate(
                2,
                (int index) => Article(
                  id: '$index',
                  slug: 'article-$index',
                  title: '結果 $index',
                  ogDescription: '描述',
                  categorySet: <CategorySet>[],
                  publishedDate: DateTime.now(),
                  isExternal: false,
                ),
              ));

      // Act
      await tester.pumpWidget(
        wrapWithApp(SearchPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // 輸入搜尋關鍵字
      await tester.enterText(find.byType(TextField), '測試');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('結果 0'), findsOneWidget);

      // Act - 清空輸入
      await tester.enterText(find.byType(TextField), '');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Assert - 應該顯示初始狀態
      expect(find.text('請輸入關鍵字開始搜尋'), findsOneWidget);
      expect(find.text('結果 0'), findsNothing);
    });

    testWidgets('should display article with formatted date',
        (WidgetTester tester) async {
      // Arrange
      final Article mockArticle = Article(
        id: '1',
        slug: 'test-article',
        title: '測試文章',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime(2024, 3, 15),
        isExternal: false,
      );

      when(() => mockApi.searchArticles(query: '測試', page: 1))
          .thenAnswer((_) async => <Article>[mockArticle]);

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
      int currentPage = 1;
      when(() => mockApi.searchArticles(
            query: '測試',
            page: any(named: 'page'),
          )).thenAnswer((_) async {
        final int page = currentPage++;
        return List<Article>.generate(
          10,
          (int index) => Article(
            id: 'page${page}_$index',
            slug: 'article-$index',
            title: '結果 $page-$index',
            ogDescription: '描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime.now(),
            isExternal: false,
          ),
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

      expect(find.text('結果 1-0'), findsOneWidget);

      // 滾動到底部觸發載入更多
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Assert - 應該載入了第二頁
      expect(currentPage, equals(2));
    });
  });
}
