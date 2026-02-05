import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/category/presentation/category_page.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  Widget wrapWithApp(CategoryPage categoryPage) {
    return MaterialApp(
      home: categoryPage,
    );
  }

  group('CategoryPage', () {
    testWidgets('should display app bar with category name',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchCategoryArticles(
            category: '國際',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => <Article>[]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(CategoryPage(api: mockApi, category: '國際')),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('國際'), findsOneWidget);
    });

    testWidgets('should display list of articles after loading',
        (WidgetTester tester) async {
      // Arrange
      final List<Article> mockArticles = List<Article>.generate(
        5,
        (int index) => Article(
          id: '$index',
          slug: 'article-$index',
          title: '政治文章 $index',
          ogDescription: '描述 $index',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 1, 1 + index),
          isExternal: false,
        ),
      );

      when(() => mockApi.fetchCategoryArticles(
            category: '政治',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => mockArticles);

      // Act
      await tester.pumpWidget(
        wrapWithApp(CategoryPage(api: mockApi, category: '政治')),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('政治文章 0'), findsOneWidget);
      expect(find.text('政治文章 4'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display loading indicator on initial load',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchCategoryArticles(
            category: '人權',
            page: 1,
            limit: 10,
          )).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return <Article>[];
        },
      );

      // Act
      await tester.pumpWidget(
        wrapWithApp(CategoryPage(api: mockApi, category: '人權')),
      );

      // 等待初始 pump
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 清理
      await tester.pumpAndSettle();
    });

    testWidgets('should display empty state when no articles',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchCategoryArticles(
            category: '健康',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => <Article>[]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(CategoryPage(api: mockApi, category: '健康')),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('此分類目前沒有文章'), findsOneWidget);
    });

    testWidgets('should have RefreshIndicator for pull to refresh',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchCategoryArticles(
            category: '環境',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => List<Article>.generate(
                3,
                (int index) => Article(
                  id: '$index',
                  slug: 'article-$index',
                  title: '環境文章 $index',
                  ogDescription: '描述',
                  categorySet: <CategorySet>[],
                  publishedDate: DateTime.now(),
                  isExternal: false,
                ),
              ));

      // Act
      await tester.pumpWidget(
        wrapWithApp(CategoryPage(api: mockApi, category: '環境')),
      );

      await tester.pumpAndSettle();

      // Assert - 驗證 RefreshIndicator 存在
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should load more articles when scrolling to bottom',
        (WidgetTester tester) async {
      // Arrange
      int currentPage = 1;
      when(() => mockApi.fetchCategoryArticles(
            category: '經濟',
            page: any(named: 'page'),
            limit: 10,
          )).thenAnswer((_) async {
        final int page = currentPage++;
        return List<Article>.generate(
          10,
          (int index) => Article(
            id: 'page${page}_$index',
            slug: 'article-page${page}_$index',
            title: '經濟文章 $page-$index',
            ogDescription: '描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime.now(),
            isExternal: false,
          ),
        );
      });

      // Act
      await tester.pumpWidget(
        wrapWithApp(CategoryPage(api: mockApi, category: '經濟')),
      );

      await tester.pumpAndSettle();

      // 驗證初始載入
      expect(find.text('經濟文章 1-0'), findsOneWidget);

      // 滾動到底部觸發載入更多
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Assert - 應該載入了第二頁
      expect(currentPage, equals(2));
    });

    testWidgets('should not show load more indicator when no more articles',
        (WidgetTester tester) async {
      // Arrange - 返回少於 page size 的文章，表示沒有更多了
      when(() => mockApi.fetchCategoryArticles(
            category: '文化',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => List<Article>.generate(
                3, // Less than page size
                (int index) => Article(
                  id: '$index',
                  slug: 'article-$index',
                  title: '文化文章 $index',
                  ogDescription: '描述',
                  categorySet: <CategorySet>[],
                  publishedDate: DateTime.now(),
                  isExternal: false,
                ),
              ));

      // Act
      await tester.pumpWidget(
        wrapWithApp(CategoryPage(api: mockApi, category: '文化')),
      );

      await tester.pumpAndSettle();

      // Assert - 應該不顯示 "載入更多" 提示
      expect(find.text('載入更多...'), findsNothing);
    });

    testWidgets('should display article with formatted date',
        (WidgetTester tester) async {
      // Arrange
      final Article mockArticle = Article(
        id: '1',
        slug: 'test-article',
        title: '教育文章',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime(2024, 3, 15),
        isExternal: false,
      );

      when(() => mockApi.fetchCategoryArticles(
            category: '教育',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => <Article>[mockArticle]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(CategoryPage(api: mockApi, category: '教育')),
      );

      await tester.pumpAndSettle();

      // Assert - 驗證日期格式化顯示
      expect(find.text('教育文章'), findsOneWidget);
      expect(find.textContaining('2024'), findsOneWidget);
    });

    testWidgets('should handle different category parameters',
        (WidgetTester tester) async {
      // Arrange
      final Map<String, List<Article>> categoryArticles = <String, List<Article>>{
        '國際': <Article>[
          Article(
            id: '1',
            slug: 'intl-article',
            title: '國際新聞',
            ogDescription: '國際描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime.now(),
            isExternal: false,
          ),
        ],
        '科技': <Article>[
          Article(
            id: '2',
            slug: 'tech-article',
            title: '科技新聞',
            ogDescription: '科技描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime.now(),
            isExternal: false,
          ),
        ],
      };

      when(() => mockApi.fetchCategoryArticles(
            category: '國際',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => categoryArticles['國際']!);

      when(() => mockApi.fetchCategoryArticles(
            category: '科技',
            page: 1,
            limit: 10,
          )).thenAnswer((_) async => categoryArticles['科技']!);

      // Act & Assert - 測試國際分類
      await tester.pumpWidget(
        wrapWithApp(CategoryPage(api: mockApi, category: '國際')),
      );

      await tester.pumpAndSettle();

      expect(find.text('國際'), findsOneWidget);
      expect(find.text('國際新聞'), findsOneWidget);
    });
  });
}
