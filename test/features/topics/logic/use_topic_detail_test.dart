import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/features/topics/logic/use_topic_detail.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockArticleRepository mockRepo;

  setUp(() {
    mockRepo = MockArticleRepository();
  });

  group('useTopicDetail', () {
    testWidgets(
      'should load related articles on mount',
      (tester) async {
        final topic = createTestTopic(
          relateds: <String>['id1', 'id2', 'id3'],
        );

        when(() => mockRepo.fetchByIds(
              any(),
            )).thenAnswer(
          (_) async => <Article>[
            createTestArticle(id: 'id1', slug: 'a-id1'),
            createTestArticle(id: 'id2', slug: 'a-id2'),
            createTestArticle(id: 'id3', slug: 'a-id3'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(
                  mockRepo,
                  topic: topic,
                );

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Articles: '
                            '${result.relatedArticles.value.length}',
                          ),
                          Text(
                            'Loading: '
                            '${result.isLoading.value}',
                          ),
                          Text(
                            'HasError: '
                            '${result.hasError.value}',
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
          find.text('Articles: 3'),
          findsOneWidget,
        );
        expect(
          find.text('Loading: false'),
          findsOneWidget,
        );
        expect(
          find.text('HasError: false'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should handle fetch error gracefully',
      (tester) async {
        final topic = createTestTopic(
          relateds: <String>['id1', 'id2'],
        );

        when(() => mockRepo.fetchByIds(any()))
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(
                  mockRepo,
                  topic: topic,
                );

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Articles: '
                            '${result.relatedArticles.value.length}',
                          ),
                          Text(
                            'HasError: '
                            '${result.hasError.value}',
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
          find.text('Articles: 0'),
          findsOneWidget,
        );
        expect(
          find.text('HasError: true'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should not load when relateds is null',
      (tester) async {
        final topic = createTestTopic();

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(
                  mockRepo,
                  topic: topic,
                );

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Articles: '
                            '${result.relatedArticles.value.length}',
                          ),
                          Text(
                            'Loading: '
                            '${result.isLoading.value}',
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
          find.text('Articles: 0'),
          findsOneWidget,
        );
        expect(
          find.text('Loading: false'),
          findsOneWidget,
        );
        verifyNever(
          () => mockRepo.fetchByIds(any()),
        );
      },
    );

    testWidgets(
      'should not load when relateds is empty',
      (tester) async {
        final topic = createTestTopic(
          relateds: <String>[],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(
                  mockRepo,
                  topic: topic,
                );

                return (BuildContext context) => Scaffold(
                      body: Text(
                        'Articles: '
                        '${result.relatedArticles.value.length}',
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Articles: 0'),
          findsOneWidget,
        );
        verifyNever(
          () => mockRepo.fetchByIds(any()),
        );
      },
    );

    testWidgets(
      'should refresh and reload articles',
      (tester) async {
        final topic = createTestTopic(
          relateds: <String>['id1'],
        );
        var callCount = 0;

        when(() => mockRepo.fetchByIds(any()))
            .thenAnswer((_) async {
          callCount++;
          return <Article>[
            createTestArticle(
              id: 'call$callCount',
              slug: 'a-call$callCount',
            ),
          ];
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(
                  mockRepo,
                  topic: topic,
                );

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          if (result.relatedArticles
                              .value.isNotEmpty)
                            Text(
                              'First: '
                              '${result.relatedArticles.value.first.id}',
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
        expect(
          find.text('First: call1'),
          findsOneWidget,
        );

        await tester.tap(find.text('Refresh'));
        await tester.pumpAndSettle();

        expect(callCount, equals(2));
        expect(
          find.text('First: call2'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should expose topic data',
      (tester) async {
        final topic = createTestTopic();

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(
                  mockRepo,
                  topic: topic,
                );

                return (BuildContext context) => Scaffold(
                      body: Text(
                        'Title: '
                        '${result.topic.value.title}',
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Title: 測試專題'),
          findsOneWidget,
        );
      },
    );
  });
}
