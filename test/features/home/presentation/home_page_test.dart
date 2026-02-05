import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  Widget wrapWithApp(HomePage homePage) {
    return MaterialApp(
      home: homePage,
    );
  }

  group('HomePage', () {
    testWidgets('should display app bar with title', (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchFeaturedArticles())
          .thenAnswer((_) async => <Article>[]);
      when(() => mockApi.fetchCategoryArticles(
            category: any(named: 'category'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => <Article>[]);

      // Act
      await tester.pumpWidget(wrapWithApp(HomePage(api: mockApi)));

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('報導者'), findsOneWidget);
    });

    testWidgets('should display page without error when data loads', (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchFeaturedArticles())
          .thenAnswer((_) async => <Article>[]);
      when(() => mockApi.fetchCategoryArticles(
            category: any(named: 'category'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => <Article>[]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      // 等待所有動畫完成
      await tester.pumpAndSettle();

      // Assert - 頁面正常載入，沒有錯誤
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display featured articles after loading', (WidgetTester tester) async {
      // Arrange
      final List<Article> mockArticles = <Article>[
        Article(
          id: '1',
          slug: 'featured-1',
          title: '精選文章標題',
          ogDescription: '這是精選文章的描述內容',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 1, 1),
          isExternal: false,
        ),
      ];

      when(() => mockApi.fetchFeaturedArticles())
          .thenAnswer((_) async => mockArticles);
      when(() => mockApi.fetchCategoryArticles(
            category: any(named: 'category'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => <Article>[]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      // 等待載入完成
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('精選文章標題'), findsOneWidget);
      expect(find.text('這是精選文章的描述內容'), findsOneWidget);
    });

    testWidgets('should display error message when loading fails', (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchFeaturedArticles())
          .thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      // 等待錯誤發生
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.textContaining('發生錯誤'), findsOneWidget);
      expect(find.textContaining('Network error'), findsOneWidget);
    });

    testWidgets('should display category sections', (WidgetTester tester) async {
      // Arrange
      final List<Article> internationalArticles = <Article>[
        Article(
          id: '1',
          slug: 'intl-1',
          title: '國際新聞標題',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 1, 1),
          isExternal: false,
        ),
      ];

      final List<Article> politicsArticles = <Article>[
        Article(
          id: '2',
          slug: 'politics-1',
          title: '政治新聞標題',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 1, 2),
          isExternal: false,
        ),
      ];

      when(() => mockApi.fetchFeaturedArticles())
          .thenAnswer((_) async => <Article>[]);

      when(() => mockApi.fetchCategoryArticles(
            category: '國際',
            page: 1,
            limit: 5,
          )).thenAnswer((_) async => internationalArticles);

      when(() => mockApi.fetchCategoryArticles(
            category: '政治',
            page: 1,
            limit: 5,
          )).thenAnswer((_) async => politicsArticles);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      // 等待載入完成
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('國際'), findsOneWidget);
      expect(find.text('政治'), findsOneWidget);
      expect(find.text('國際新聞標題'), findsOneWidget);
      expect(find.text('政治新聞標題'), findsOneWidget);
    });

    testWidgets('should have RefreshIndicator for pull to refresh', (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchFeaturedArticles())
          .thenAnswer((_) async => <Article>[]);
      when(() => mockApi.fetchCategoryArticles(
            category: any(named: 'category'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => <Article>[]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert - 頁面有 RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no articles', (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchFeaturedArticles())
          .thenAnswer((_) async => <Article>[]);
      when(() => mockApi.fetchCategoryArticles(
            category: any(named: 'category'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => <Article>[]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      // 等待載入完成
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('目前沒有文章'), findsOneWidget);
    });

    testWidgets('should display retry button on error', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;

      when(() => mockApi.fetchFeaturedArticles()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Network error');
        }
        return <Article>[];
      });

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      // 等待錯誤發生
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('發生錯誤'), findsOneWidget);

      // 點擊重試按鈕
      await tester.tap(find.text('重試'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - 應該再呼叫一次且成功
      expect(callCount, equals(2));
      expect(find.textContaining('發生錯誤'), findsNothing);
    });
  });
}
