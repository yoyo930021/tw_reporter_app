import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/home/logic/use_home_data.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

/// Helper: create a mock [ApiResponse<IndexPageData>].
ApiResponse<IndexPageData> _indexPageResponse(IndexPageData data) {
  return ApiResponse<IndexPageData>(
    data: data,
    status: 'success',
  );
}

/// Helper: create test articles.
List<Article> _articles(int count, {String prefix = ''}) {
  return List<Article>.generate(
    count,
    (int i) => Article(
      id: '$prefix$i',
      slug: 'article-$prefix$i',
      title: '${prefix}文章 $i',
      ogDescription: '描述',
      categorySet: <CategorySet>[],
      publishedDate: DateTime(2024, 1, 1 + i),
      isExternal: false,
    ),
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
    testWidgets('should load index page data on mount',
        (WidgetTester tester) async {
      // Arrange
      final List<Article> editorPicks = _articles(2, prefix: 'ep_');
      final IndexPageData indexData = IndexPageData(
        editorPicksSection: editorPicks,
        latestSection: _articles(3, prefix: 'latest_'),
      );

      when(() => mockApi.fetchIndexPage())
          .thenAnswer((_) async => _indexPageResponse(indexData));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final HomeDataResult result = useHomeData(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Loading: ${result.isLoading.value}'),
                        Text('HasData: ${result.indexData.value != null}'),
                        if (result.indexData.value != null)
                          Text(
                            'EditorPicks: ${result.indexData.value!.editorPicksSection?.length ?? 0}',
                          ),
                        if (result.indexData.value != null)
                          Text(
                            'Latest: ${result.indexData.value!.latestSection?.length ?? 0}',
                          ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待載入完成
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('HasData: true'), findsOneWidget);
      expect(find.text('EditorPicks: 2'), findsOneWidget);
      expect(find.text('Latest: 3'), findsOneWidget);
      verify(() => mockApi.fetchIndexPage()).called(1);
    });

    testWidgets('should handle fetch error',
        (WidgetTester tester) async {
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
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('HasError: true'), findsOneWidget);
      expect(find.text('Error: Exception: Network error'), findsOneWidget);
    });

    testWidgets('should load category articles from index page',
        (WidgetTester tester) async {
      // Arrange
      final IndexPageData indexData = IndexPageData(
        world: _articles(2, prefix: 'world_'),
        culture: _articles(1, prefix: 'culture_'),
      );

      when(() => mockApi.fetchIndexPage())
          .thenAnswer((_) async => _indexPageResponse(indexData));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final HomeDataResult result = useHomeData(mockApi);

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('HasData: ${result.indexData.value != null}'),
                        if (result.indexData.value != null)
                          Text(
                            'World: ${result.indexData.value!.world?.length ?? 0}',
                          ),
                        if (result.indexData.value != null)
                          Text(
                            'Culture: ${result.indexData.value!.culture?.length ?? 0}',
                          ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待載入完成
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('HasData: true'), findsOneWidget);
      expect(find.text('World: 2'), findsOneWidget);
      expect(find.text('Culture: 1'), findsOneWidget);
    });

    testWidgets('should refresh all data when refresh is called',
        (WidgetTester tester) async {
      // Arrange
      var callCount = 0;

      when(() => mockApi.fetchIndexPage()).thenAnswer((_) async {
        callCount++;
        return _indexPageResponse(
          IndexPageData(
            editorPicksSection: _articles(1, prefix: 'call${callCount}_'),
          ),
        );
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
                        if (result.indexData.value?.editorPicksSection
                                ?.isNotEmpty ??
                            false)
                          Text(
                            'FirstId: ${result.indexData.value!.editorPicksSection!.first.id}',
                          ),
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
      await tester.pumpAndSettle();

      expect(find.text('FirstId: call1_0'), findsOneWidget);

      // 執行重新整理
      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('FirstId: call2_0'), findsOneWidget);
      expect(callCount, equals(2));
    });

    testWidgets('should not load when already loading',
        (WidgetTester tester) async {
      // Arrange
      var callCount = 0;

      when(() => mockApi.fetchIndexPage()).thenAnswer((_) async {
        callCount++;
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return _indexPageResponse(const IndexPageData());
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
                        Text('Loading: ${result.isLoading.value}'),
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
