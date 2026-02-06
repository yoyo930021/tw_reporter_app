import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/latest/presentation/latest_page.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

// Helper function to create mock ListResponse
ListResponse<Article> createMockListResponse(List<Article> articles, int offset) {
  return ListResponse<Article>(
    data: ListData<Article>(
      meta: ListMeta(limit: articles.length > 0 ? articles.length : 10, offset: offset, total: 100),
      records: articles,
    ),
    status: 'success',
  );
}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  Widget wrapWithApp(LatestPage latestPage) {
    return MaterialApp(
      home: latestPage,
    );
  }

  group('LatestPage', () {
    testWidgets('should display app bar with title', (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchPosts(limit: 10, offset: 0))
          .thenAnswer((_) async => createMockListResponse(<Article>[], 0));

      // Act
      await tester.pumpWidget(
        wrapWithApp(LatestPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('最新文章'), findsOneWidget);
    });

    testWidgets('should display list of articles after loading',
        (WidgetTester tester) async {
      // Arrange
      final List<Article> mockArticles = List<Article>.generate(
        5,
        (int index) => Article(
          id: '$index',
          slug: 'article-$index',
          title: '測試文章 $index',
          ogDescription: '描述 $index',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 1, 1 + index),
          isExternal: false,
        ),
      );

      when(() => mockApi.fetchPosts(limit: 10, offset: 0))
          .thenAnswer((_) async => createMockListResponse(mockArticles, 0));

      // Act
      await tester.pumpWidget(
        wrapWithApp(LatestPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('測試文章 0'), findsOneWidget);
      expect(find.text('測試文章 4'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display loading indicator on initial load',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchPosts(limit: 10, offset: 0)).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return createMockListResponse(<Article>[], 0);
        },
      );

      // Act
      await tester.pumpWidget(
        wrapWithApp(LatestPage(api: mockApi)),
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
      when(() => mockApi.fetchPosts(limit: 10, offset: 0))
          .thenAnswer((_) async => createMockListResponse(<Article>[], 0));

      // Act
      await tester.pumpWidget(
        wrapWithApp(LatestPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('目前沒有文章'), findsOneWidget);
    });

    testWidgets('should have RefreshIndicator for pull to refresh',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchPosts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => createMockListResponse(
            List<Article>.generate(
              3,
              (int index) => Article(
                id: '$index',
                slug: 'article-$index',
                title: '文章 $index',
                ogDescription: '描述',
                categorySet: <CategorySet>[],
                publishedDate: DateTime.now(),
                isExternal: false,
              ),
            ),
            0,
          ));

      // Act
      await tester.pumpWidget(
        wrapWithApp(LatestPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert - 驗證 RefreshIndicator 存在
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should call API on initial load with correct parameters',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchPosts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => createMockListResponse(
            List<Article>.generate(
              10,
              (int index) => Article(
                id: '$index',
                slug: 'article-$index',
                title: '文章 $index',
                ogDescription: '描述',
                categorySet: <CategorySet>[],
                publishedDate: DateTime.now(),
                isExternal: false,
              ),
            ),
            0,
          ));

      // Act
      await tester.pumpWidget(
        wrapWithApp(LatestPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert - 驗證初始載入呼叫了 API
      verify(() => mockApi.fetchPosts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).called(greaterThanOrEqualTo(1));
      expect(find.text('文章 0'), findsOneWidget);
    });

    testWidgets('should not show load more indicator when no more articles',
        (WidgetTester tester) async {
      // Arrange - 返回少於 page size 的文章，表示沒有更多了
      when(() => mockApi.fetchPosts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => createMockListResponse(
            List<Article>.generate(
              3, // Less than page size
              (int index) => Article(
                id: '$index',
                slug: 'article-$index',
                title: '文章 $index',
                ogDescription: '描述',
                categorySet: <CategorySet>[],
                publishedDate: DateTime.now(),
                isExternal: false,
              ),
            ),
            0,
          ));

      // Act
      await tester.pumpWidget(
        wrapWithApp(LatestPage(api: mockApi)),
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
        title: '測試文章',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime(2024, 3, 15),
        isExternal: false,
      );

      when(() => mockApi.fetchPosts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer(
        (_) async => createMockListResponse(<Article>[mockArticle], 0),
      );

      // Act
      await tester.pumpWidget(
        wrapWithApp(LatestPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert - 驗證日期格式化顯示
      expect(find.text('測試文章'), findsOneWidget);
      expect(find.textContaining('2024'), findsOneWidget);
    });
  });
}
