import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/home/logic/use_home_data.dart';

import '../../../helpers/test_helpers.dart';

/// Helper: create test articles.
List<Article> _articles(int count, {String prefix = ''}) {
  return List<Article>.generate(
    count,
    (i) => Article(
      id: '$prefix$i',
      slug: 'article-$prefix$i',
      title: '$prefix文章 $i',
      ogDescription: '描述',
      categorySet: <CategorySet>[],
      publishedDate: DateTime(2024, 1, 1 + i),
      isExternal: false,
    ),
  );
}

void main() {
  late MockHomeRepository mockRepo;

  setUp(() {
    mockRepo = MockHomeRepository();
  });

  group('useHomeData', () {
    testWidgets(
      'should load index page data on mount',
      (tester) async {
        // Arrange
        final editorPicks = _articles(2, prefix: 'ep_');
        final indexData = IndexPageData(
          editorPicksSection: editorPicks,
          latestSection:
              _articles(3, prefix: 'latest_'),
        );

        when(() => mockRepo.fetchIndexPage())
            .thenAnswer((_) async => indexData);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useHomeData(mockRepo);

                return (BuildContext context) {
                  final data = result.indexData.value;
                  final epLen = data
                      ?.editorPicksSection?.length ?? 0;
                  final ltLen =
                      data?.latestSection?.length ?? 0;
                  return Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text(
                          'Loading: '
                          '${result.isLoading.value}',
                        ),
                        Text(
                          'HasData: ${data != null}',
                        ),
                        if (data != null)
                          Text('EditorPicks: $epLen'),
                        if (data != null)
                          Text('Latest: $ltLen'),
                      ],
                    ),
                  );
                };
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Loading: false'),
          findsOneWidget,
        );
        expect(
          find.text('HasData: true'),
          findsOneWidget,
        );
        expect(
          find.text('EditorPicks: 2'),
          findsOneWidget,
        );
        expect(
          find.text('Latest: 3'),
          findsOneWidget,
        );
        verify(() => mockRepo.fetchIndexPage())
            .called(1);
      },
    );

    testWidgets(
      'should handle fetch error',
      (tester) async {
        // Arrange
        when(() => mockRepo.fetchIndexPage())
            .thenThrow(Exception('Network error'));

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useHomeData(mockRepo);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'HasError: '
                            '${result.hasError.value}',
                          ),
                          if (result.error.value != null)
                            Text(
                              'Error: '
                              '${result.error.value}',
                            ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('HasError: true'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Error: Exception: Network error',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should load category articles from index page',
      (tester) async {
        // Arrange
        final indexData = IndexPageData(
          world: _articles(2, prefix: 'world_'),
          culture:
              _articles(1, prefix: 'culture_'),
        );

        when(() => mockRepo.fetchIndexPage())
            .thenAnswer((_) async => indexData);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useHomeData(mockRepo);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'HasData: '
                            '${result.indexData.value != null}',
                          ),
                          if (result.indexData.value !=
                              null)
                            Text(
                              'World: '
                              '${result.indexData.value!.world?.length ?? 0}',
                            ),
                          if (result.indexData.value !=
                              null)
                            Text(
                              'Culture: '
                              '${result.indexData.value!.culture?.length ?? 0}',
                            ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('HasData: true'),
          findsOneWidget,
        );
        expect(
          find.text('World: 2'),
          findsOneWidget,
        );
        expect(
          find.text('Culture: 1'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should refresh all data when refresh is called',
      (tester) async {
        // Arrange
        var callCount = 0;

        when(() => mockRepo.fetchIndexPage())
            .thenAnswer((_) async {
          callCount++;
          return IndexPageData(
            editorPicksSection: _articles(
              1,
              prefix: 'call${callCount}_',
            ),
          );
        });

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useHomeData(mockRepo);

                return (BuildContext context) {
                  final eps = result.indexData.value
                      ?.editorPicksSection;
                  return Scaffold(
                    body: Column(
                      children: <Widget>[
                        if (eps?.isNotEmpty ?? false)
                          Text(
                            'FirstId: '
                            '${eps!.first.id}',
                          ),
                        ElevatedButton(
                          onPressed: result.refresh,
                          child: const Text(
                            'Refresh',
                          ),
                        ),
                      ],
                    ),
                  );
                };
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(
          find.text('FirstId: call1_0'),
          findsOneWidget,
        );

        // Refresh
        await tester.tap(find.text('Refresh'));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('FirstId: call2_0'),
          findsOneWidget,
        );
        expect(callCount, equals(2));
      },
    );

    testWidgets(
      'should not load when already loading',
      (tester) async {
        // Arrange
        var callCount = 0;

        when(() => mockRepo.fetchIndexPage())
            .thenAnswer((_) async {
          callCount++;
          await Future<void>.delayed(
            const Duration(milliseconds: 100),
          );
          return const IndexPageData();
        });

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useHomeData(mockRepo);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Loading: '
                            '${result.isLoading.value}',
                          ),
                          Text(
                            'CallCount: $callCount',
                          ),
                          ElevatedButton(
                            onPressed: result.refresh,
                            child: const Text(
                              'Refresh',
                            ),
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pump();
        expect(
          find.text('Loading: true'),
          findsOneWidget,
        );

        // Try refresh while loading (should be ignored)
        await tester.tap(find.text('Refresh'));
        await tester.pump();

        await tester.pump(
          const Duration(milliseconds: 150),
        );

        // Assert - should only be called once
        expect(callCount, equals(1));
      },
    );
  });
}
