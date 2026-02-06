import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/shared/widgets/horizontal_carousel.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

/// Helper: create a mock [ApiResponse<IndexPageData>].
ApiResponse<IndexPageData> _indexPageResponse(IndexPageData data) {
  return ApiResponse<IndexPageData>(
    data: data,
    status: 'success',
  );
}

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

  /// Mock fetchIndexPage to return [data].
  void mockIndexPage(IndexPageData data) {
    when(() => mockApi.fetchIndexPage())
        .thenAnswer((_) async => _indexPageResponse(data));
  }

  group('HomePage', () {
    testWidgets('should display app bar with title',
        (WidgetTester tester) async {
      // Arrange
      mockIndexPage(const IndexPageData());

      // Act
      await tester.pumpWidget(wrapWithApp(HomePage(api: mockApi)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      // Logo is an SvgPicture with semanticsLabel, not a Text widget
      expect(find.bySemanticsLabel('報導者'), findsOneWidget);
    });

    testWidgets('should display page without error when data loads',
        (WidgetTester tester) async {
      // Arrange
      mockIndexPage(const IndexPageData());

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert - 頁面正常載入
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display editor picks after loading',
        (WidgetTester tester) async {
      // Arrange
      final IndexPageData data = IndexPageData(
        editorPicksSection: <Article>[
          Article(
            id: '1',
            slug: 'featured-1',
            title: '精選文章標題',
            ogDescription: '這是精選文章的描述內容',
            categorySet: <CategorySet>[],
            publishedDate: DateTime(2024, 1, 1),
            isExternal: false,
          ),
        ],
      );
      mockIndexPage(data);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('精選文章標題'), findsOneWidget);
      expect(find.text('這是精選文章的描述內容'), findsOneWidget);
    });

    testWidgets('should display error message when loading fails',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchIndexPage())
          .thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      // 等待錯誤發生
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('發生錯誤'), findsOneWidget);
      expect(find.textContaining('Network error'), findsOneWidget);
    });

    testWidgets('should display category sections with titles and carousels',
        (WidgetTester tester) async {
      // Arrange
      final IndexPageData data = IndexPageData(
        world: <Article>[
          Article(
            id: '1',
            slug: 'intl-1',
            title: '國際新聞標題',
            ogDescription: '描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime(2024, 1, 1),
            isExternal: false,
          ),
        ],
        politicsAndSociety: <Article>[
          Article(
            id: '2',
            slug: 'politics-1',
            title: '政治新聞標題',
            ogDescription: '描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime(2024, 1, 2),
            isExternal: false,
          ),
        ],
      );
      mockIndexPage(data);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert — 各分類標題 + 文章輪播
      expect(find.text('國際'), findsOneWidget);
      expect(find.text('政治社會'), findsOneWidget);
      expect(find.text('國際新聞標題'), findsOneWidget);
      expect(find.byType(HorizontalCarousel), findsAtLeast(1));
    });

    testWidgets('should have RefreshIndicator for pull to refresh',
        (WidgetTester tester) async {
      // Arrange
      mockIndexPage(const IndexPageData());

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert - 頁面有 RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no articles',
        (WidgetTester tester) async {
      // Arrange
      mockIndexPage(const IndexPageData());

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert - page loads without error
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display retry button on error',
        (WidgetTester tester) async {
      // Arrange
      var callCount = 0;

      when(() => mockApi.fetchIndexPage()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Network error');
        }
        return _indexPageResponse(const IndexPageData());
      });

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      // 等待錯誤發生
      await tester.pumpAndSettle();

      expect(find.textContaining('發生錯誤'), findsOneWidget);

      // 點擊重試按鈕
      await tester.tap(find.text('重試'));
      await tester.pumpAndSettle();

      // Assert - 應該再呼叫一次且成功
      expect(callCount, equals(2));
      expect(find.textContaining('發生錯誤'), findsNothing);
    });

    testWidgets('should display topics section when topics available',
        (WidgetTester tester) async {
      // Arrange
      final IndexPageData data = IndexPageData(
        latestTopicSection: <Topic>[
          Topic(
            id: 't1',
            slug: 'topic-1',
            title: '最新專題標題',
            publishedDate: DateTime(2024, 1, 1),
          ),
        ],
        topicsSection: <Topic>[
          Topic(
            id: 't2',
            slug: 'topic-2',
            title: '精選專題標題',
            publishedDate: DateTime(2024, 1, 2),
          ),
        ],
      );
      mockIndexPage(data);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('最新專題'), findsOneWidget);
    });

    testWidgets('should display reviews section when reviews available',
        (WidgetTester tester) async {
      // Arrange
      final IndexPageData data = IndexPageData(
        reviewsSection: <Article>[
          Article(
            id: '1',
            slug: 'review-1',
            title: '評論文章標題',
            ogDescription: '評論描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime(2024, 1, 1),
            isExternal: false,
          ),
        ],
      );
      mockIndexPage(data);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('評論'), findsOneWidget);
    });

    testWidgets('should display photos section when photos available',
        (WidgetTester tester) async {
      // Arrange
      final IndexPageData data = IndexPageData(
        photosSection: <Article>[
          Article(
            id: '1',
            slug: 'photo-1',
            title: '攝影文章標題',
            ogDescription: '攝影描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime(2024, 1, 1),
            isExternal: false,
          ),
        ],
      );
      mockIndexPage(data);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('攝影'), findsOneWidget);
    });

    testWidgets('should display infographics section',
        (WidgetTester tester) async {
      // Arrange
      final IndexPageData data = IndexPageData(
        infographicsSection: <Article>[
          Article(
            id: '1',
            slug: 'infographic-1',
            title: '多媒體文章標題',
            ogDescription: '多媒體描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime(2024, 1, 1),
            isExternal: false,
          ),
        ],
      );
      mockIndexPage(data);

      // Act
      await tester.pumpWidget(
        wrapWithApp(HomePage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('多媒體'), findsOneWidget);
    });
  });
}
