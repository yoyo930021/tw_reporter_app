import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/features/article/logic/use_article_detail.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockArticleRepository mockRepo;

  setUp(() {
    mockRepo = MockArticleRepository();
  });

  group('useArticleDetail', () {
    testWidgets(
      'should load article detail on mount',
      (tester) async {
        final mockArticle = createTestArticle(
          title: '測試文章標題',
          ogDescription: '這是測試文章的描述',
          content: <String, dynamic>{
            'api_data': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'unstyled',
                'content': <String>['文章內容'],
                'id': '1',
                'styles': <String, dynamic>{},
                'alignment': 'center',
              },
            ],
          },
        );

        when(() => mockRepo.fetchById(slug: 'test-article'))
            .thenAnswer((_) async => mockArticle);

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useArticleDetail(
                  mockRepo,
                  slug: 'test-article',
                );

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Loading: '
                            '${result.isLoading.value}',
                          ),
                          if (result.article.value != null)
                            Text(
                              'Title: '
                              '${result.article.value!.title}',
                            ),
                          if (result.article.value?.content !=
                              null)
                            const Text('Content: has content'),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Loading: false'),
          findsOneWidget,
        );
        expect(
          find.text('Title: 測試文章標題'),
          findsOneWidget,
        );
        expect(
          find.text('Content: has content'),
          findsOneWidget,
        );
        verify(
          () => mockRepo.fetchById(slug: 'test-article'),
        ).called(1);
      },
    );

    testWidgets(
      'should handle article fetch error',
      (tester) async {
        when(() => mockRepo.fetchById(slug: 'test-article'))
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useArticleDetail(
                  mockRepo,
                  slug: 'test-article',
                );

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'HasError: '
                            '${result.hasError.value}',
                          ),
                          if (result.error.value != null)
                            Text(
                              'Error: ${result.error.value}',
                            ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('HasError: true'),
          findsOneWidget,
        );
        expect(
          find.text('Error: Exception: Network error'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should refresh article when refresh is called',
      (tester) async {
        var callCount = 0;

        when(
          () => mockRepo.fetchById(slug: 'test-article'),
        ).thenAnswer((_) async {
          callCount++;
          return createTestArticle(
            id: '$callCount',
            title: '文章 $callCount',
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useArticleDetail(
                  mockRepo,
                  slug: 'test-article',
                );

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          if (result.article.value != null)
                            Text(
                              'ID: '
                              '${result.article.value!.id}',
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

        await tester.pumpAndSettle();

        expect(find.text('ID: 1'), findsOneWidget);
        expect(callCount, equals(1));

        await tester.tap(find.text('Refresh'));
        await tester.pumpAndSettle();

        expect(callCount, equals(2));
        expect(find.text('ID: 2'), findsOneWidget);
      },
    );

    testWidgets(
      'should not load when already loading',
      (tester) async {
        var fetchCallCount = 0;

        when(
          () => mockRepo.fetchById(slug: 'test-article'),
        ).thenAnswer((_) async {
          fetchCallCount++;
          await Future<void>.delayed(
            const Duration(milliseconds: 100),
          );
          return createTestArticle();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useArticleDetail(
                  mockRepo,
                  slug: 'test-article',
                );

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text('CallCount: $fetchCallCount'),
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

        await tester.pumpAndSettle();

        final initialCallCount = fetchCallCount;

        await tester.tap(find.text('Refresh'));
        await tester.pump(
          const Duration(milliseconds: 10),
        );
        await tester.tap(find.text('Refresh'));
        await tester.pumpAndSettle();

        expect(
          fetchCallCount,
          equals(initialCallCount + 1),
        );
      },
    );

    testWidgets(
      'should handle different slugs',
      (tester) async {
        final article1 = createTestArticle(
          slug: 'article-1',
          title: '文章 1',
        );

        when(() => mockRepo.fetchById(slug: 'article-1'))
            .thenAnswer((_) async => article1);

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useArticleDetail(
                  mockRepo,
                  slug: 'article-1',
                );

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          if (result.article.value != null)
                            Text(
                              'Title: '
                              '${result.article.value!.title}',
                            ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Title: 文章 1'),
          findsOneWidget,
        );
        verify(
          () => mockRepo.fetchById(slug: 'article-1'),
        ).called(1);
      },
    );

    testWidgets(
      'should load related articles when article has relateds',
      (tester) async {
        final mainArticle = createTestArticle(
          title: '主文章',
          relateds: <String>['related-1', 'related-2'],
        );

        final relatedArticles = <Article>[
          createTestArticle(
            id: 'r1',
            slug: 'related-1',
            title: '相關文章 1',
          ),
          createTestArticle(
            id: 'r2',
            slug: 'related-2',
            title: '相關文章 2',
          ),
        ];

        when(() => mockRepo.fetchById(slug: 'test-article'))
            .thenAnswer((_) async => mainArticle);
        when(
          () => mockRepo.fetchByIds(
            <String>['related-1', 'related-2'],
          ),
        ).thenAnswer((_) async => relatedArticles);

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useArticleDetail(
                  mockRepo,
                  slug: 'test-article',
                );

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          if (result.article.value != null)
                            Text(
                              'Title: '
                              '${result.article.value!.title}',
                            ),
                          Text(
                            'Related: '
                            '${result.relatedArticles.value.length}',
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Title: 主文章'),
          findsOneWidget,
        );
        expect(
          find.text('Related: 2'),
          findsOneWidget,
        );
        verify(
          () => mockRepo.fetchByIds(
            <String>['related-1', 'related-2'],
          ),
        ).called(1);
      },
    );
  });
}
