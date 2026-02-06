import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/home/logic/use_home_data.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

// Helper function to create mock IndexPageData
IndexPageData createMockIndexPageData({
  List<Article>? editorPicksSection,
  List<Article>? latestSection,
  List<Article>? reviewsSection,
  List<Article>? photosSection,
  List<Article>? infographicsSection,
  List<Article>? culture,
  List<Article>? econ,
  List<Article>? education,
  List<Article>? environment,
  List<Article>? health,
  List<Article>? humanrights,
  List<Article>? politicsAndSociety,
  List<Article>? world,
}) {
  return IndexPageData(
    editorPicksSection: editorPicksSection,
    latestSection: latestSection,
    reviewsSection: reviewsSection,
    photosSection: photosSection,
    infographicsSection: infographicsSection,
    culture: culture,
    econ: econ,
    education: education,
    environment: environment,
    health: health,
    humanrights: humanrights,
    politicsAndSociety: politicsAndSociety,
    world: world,
  );
}

// Helper function to create mock ApiResponse
ApiResponse<IndexPageData> createMockIndexPageResponse(IndexPageData data) {
  return ApiResponse<IndexPageData>(
    data: data,
    status: 'success',
  );
}

// 測試用的 Composition Widget
class TestWidget extends CompositionWidget {
  TestWidget({
    required this.setupFn,
    super.key,
  });

  final Widget Function(BuildContext) Function() setupFn;

  @override
  Widget Function(BuildContext) setup() => setupFn();
}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  group('useHomeData', () {
    testWidgets('should load featured articles on mount', (WidgetTester tester) async {
      // Arrange
      final List<Article> mockArticles = <Article>[
        Article(
          id: '1',
          slug: 'featured-1',
          title: '精選文章 1',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 1, 1),
          isExternal: false,
        ),
        Article(
          id: '2',
          slug: 'featured-2',
          title: '精選文章 2',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 1, 2),
          isExternal: false,
        ),
      ];

      when(() => mockApi.fetchIndexPage())
          .thenAnswer((_) async => mockArticles);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final HomeDataResult result = useHomeData(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Loading: ${result.isLoadingFeatured.value}'),
                        Text('Count: ${result.featuredArticles.value.length}'),
                        if (result.featuredArticles.value.isNotEmpty)
                          Text('First: ${result.featuredArticles.value.first.title}'),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待初始載入
      await tester.pump(); // 啟動 onMounted
      await tester.pump(); // 開始執行 loadFeaturedArticles

      // Assert - 載入完成
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('Count: 2'), findsOneWidget);
      expect(find.text('First: 精選文章 1'), findsOneWidget);
      verify(() => mockApi.fetchIndexPage()).called(1);
    });

    testWidgets('should handle featured articles fetch error', (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchIndexPage())
          .thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final HomeDataResult result = useHomeData(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('HasError: ${result.hasError.value}'),
                        if (result.error.value != null)
                          Text('Error: ${result.error.value}'),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待錯誤發生
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('HasError: true'), findsOneWidget);
      expect(find.text('Error: Exception: Network error'), findsOneWidget);
    });

    testWidgets('should load category articles on mount', (WidgetTester tester) async {
      // Arrange
      final List<Article> mockInternationalArticles = <Article>[
        Article(
          id: '1',
          slug: 'intl-1',
          title: '國際文章 1',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 1, 1),
          isExternal: false,
        ),
      ];

      final List<Article> mockPoliticsArticles = <Article>[
        Article(
          id: '2',
          slug: 'politics-1',
          title: '政治文章 1',
          ogDescription: '描述',
          categorySet: <CategorySet>[],
          publishedDate: DateTime(2024, 1, 2),
          isExternal: false,
        ),
      ];

      when(() => mockApi.fetchIndexPage())
          .thenAnswer((_) async => <Article>[]);

      when(() => mockApi.fetchCategoryArticles(
            category: '國際',
            page: 1,
            limit: 5,
          )).thenAnswer((_) async => mockInternationalArticles);

      when(() => mockApi.fetchCategoryArticles(
            category: '政治',
            page: 1,
            limit: 5,
          )).thenAnswer((_) async => mockPoliticsArticles);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final HomeDataResult result = useHomeData(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Categories: ${result.categoryArticles.value.length}'),
                        if (result.categoryArticles.value.containsKey('國際'))
                          Text('國際: ${result.categoryArticles.value['國際']!.length}'),
                        if (result.categoryArticles.value.containsKey('政治'))
                          Text('政治: ${result.categoryArticles.value['政治']!.length}'),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待載入完成
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('Categories: 2'), findsOneWidget);
      expect(find.text('國際: 1'), findsOneWidget);
      expect(find.text('政治: 1'), findsOneWidget);
    });

    testWidgets('should refresh all data when refresh is called', (WidgetTester tester) async {
      // Arrange
      int featuredCallCount = 0;
      int categoryCallCount = 0;

      when(() => mockApi.fetchIndexPage()).thenAnswer((_) async {
        featuredCallCount++;
        return <Article>[
          Article(
            id: '$featuredCallCount',
            slug: 'article-$featuredCallCount',
            title: '文章 $featuredCallCount',
            ogDescription: '描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime.now(),
            isExternal: false,
          ),
        ];
      });

      when(() => mockApi.fetchCategoryArticles(
            category: any(named: 'category'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async {
        categoryCallCount++;
        return <Article>[];
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final HomeDataResult result = useHomeData(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.featuredArticles.value.length}'),
                        if (result.featuredArticles.value.isNotEmpty)
                          Text('First: ${result.featuredArticles.value.first.id}'),
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

      // 等待初始載入
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('First: 1'), findsOneWidget);

      // 執行重新整理
      await tester.tap(find.text('Refresh'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('First: 2'), findsOneWidget);
      expect(featuredCallCount, equals(2));
    });

    testWidgets('should not load when already loading', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;

      when(() => mockApi.fetchIndexPage()).thenAnswer((_) async {
        callCount++;
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return <Article>[];
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final HomeDataResult result = useHomeData(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Loading: ${result.isLoadingFeatured.value}'),
                        Text('CallCount: $callCount'),
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

      // 等待初始載入開始
      await tester.pump();
      expect(find.text('Loading: true'), findsOneWidget);

      // 嘗試再次載入（應該被忽略）
      await tester.tap(find.text('Refresh'));
      await tester.pump();

      // 等待載入完成
      await tester.pump(const Duration(milliseconds: 150));

      // Assert - 應該只呼叫一次
      expect(callCount, equals(1));
    });
  });
}
