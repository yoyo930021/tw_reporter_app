import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/article/presentation/article_page.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

// Helper function to create mock ApiResponse
ApiResponse<Article> createMockArticleResponse(Article article) {
  return ApiResponse<Article>(
    data: article,
    status: 'success',
  );
}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  Widget wrapWithApp(ArticlePage articlePage) {
    return MaterialApp(
      home: articlePage,
    );
  }

  group('ArticlePage', () {
    testWidgets('should display app bar with title', (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchPost('test-article', full: any(named: 'full')))
          .thenAnswer((_) async => createMockArticleResponse(
                Article(
                  id: '1',
                  slug: 'test-article',
                  title: '測試文章',
                  ogDescription: '描述',
                  categorySet: <CategorySet>[],
                  publishedDate: DateTime(2024, 1, 1),
                  isExternal: false,
                ),
              ));

      // Act
      await tester.pumpWidget(
        wrapWithApp(ArticlePage(api: mockApi, slug: 'test-article')),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SliverAppBar), findsOneWidget);
    });

    testWidgets('should display article title and content after loading',
        (WidgetTester tester) async {
      // Arrange
      final Article mockArticle = Article(
        id: '1',
        slug: 'test-article',
        title: '測試文章標題',
        ogDescription: '這是文章描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime(2024, 1, 1),
        isExternal: false,
        content: <String, dynamic>{
          'api_data': <Map<String, dynamic>>[
            <String, dynamic>{
              'type': 'unstyled',
              'content': <String>['這是文章的內容'],
              'id': '1',
              'styles': <String, dynamic>{},
              'alignment': 'center',
            },
          ],
        },
      );

      when(() => mockApi.fetchPost('test-article', full: any(named: 'full')))
          .thenAnswer((_) async => createMockArticleResponse(mockArticle));

      // Act
      await tester.pumpWidget(
        wrapWithApp(ArticlePage(api: mockApi, slug: 'test-article')),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('測試文章標題'), findsAtLeast(1));
      expect(find.textContaining('這是文章的內容'), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading',
        (WidgetTester tester) async {
      // Arrange
      bool requestStarted = false;
      when(() => mockApi.fetchPost('test-article', full: any(named: 'full'))).thenAnswer((_) async {
        requestStarted = true;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return createMockArticleResponse(Article(
          id: '1',
          slug: 'test-article',
          title: '測試文章',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime.now(),
          isExternal: false,
        ));
      });

      // Act
      await tester.pumpWidget(
        wrapWithApp(ArticlePage(api: mockApi, slug: 'test-article')),
      );

      // 等待初始 pump 和 mount 完成
      await tester.pump();

      // 等待足夠時間讓 async 操作開始
      await tester.pump(const Duration(milliseconds: 10));

      // Assert - 載入中應該顯示 loading indicator
      expect(requestStarted, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 清理：等待完成避免 pending timer
      await tester.pumpAndSettle();
    });

    testWidgets('should display error message when loading fails',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchPost('test-article', full: any(named: 'full')))
          .thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(
        wrapWithApp(ArticlePage(api: mockApi, slug: 'test-article')),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('發生錯誤'), findsOneWidget);
      expect(find.textContaining('Network error'), findsOneWidget);
    });

    testWidgets('should display retry button on error', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;

      when(() => mockApi.fetchPost('test-article', full: any(named: 'full'))).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Network error');
        }
        return createMockArticleResponse(Article(
          id: '1',
          slug: 'test-article',
          title: '測試文章',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime.now(),
          isExternal: false,
        ));
      });

      // Act
      await tester.pumpWidget(
        wrapWithApp(ArticlePage(api: mockApi, slug: 'test-article')),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('發生錯誤'), findsOneWidget);

      // 點擊重試按鈕
      await tester.tap(find.text('重試'));
      await tester.pumpAndSettle();

      // Assert - 應該成功載入
      expect(callCount, equals(2));
      expect(find.textContaining('發生錯誤'), findsNothing);
      expect(find.text('測試文章'), findsAtLeast(1));
    });

    testWidgets('should display published date', (WidgetTester tester) async {
      // Arrange
      final Article mockArticle = Article(
        id: '1',
        slug: 'test-article',
        title: '測試文章',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime(2024, 1, 15),
        isExternal: false,
      );

      when(() => mockApi.fetchPost('test-article', full: any(named: 'full')))
          .thenAnswer((_) async => createMockArticleResponse(mockArticle));

      // Act
      await tester.pumpWidget(
        wrapWithApp(ArticlePage(api: mockApi, slug: 'test-article')),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('2024'), findsOneWidget);
    });

    testWidgets('should handle articles without content',
        (WidgetTester tester) async {
      // Arrange
      final Article mockArticle = Article(
        id: '1',
        slug: 'test-article',
        title: '測試文章',
        ogDescription: '這是描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime(2024, 1, 1),
        isExternal: false,
        // content is null
      );

      when(() => mockApi.fetchPost('test-article', full: any(named: 'full')))
          .thenAnswer((_) async => createMockArticleResponse(mockArticle));

      // Act
      await tester.pumpWidget(
        wrapWithApp(ArticlePage(api: mockApi, slug: 'test-article')),
      );

      await tester.pumpAndSettle();

      // Assert - 應該顯示描述而不是內容
      expect(find.text('測試文章'), findsAtLeast(1));
      expect(find.text('這是描述'), findsOneWidget);
    });
  });
}
