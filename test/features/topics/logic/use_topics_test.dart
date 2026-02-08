import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/topics/logic/use_topics.dart';

import '../../../helpers/test_helpers.dart';

/// Helper: create test topics.
List<Topic> _topics(int count, {String prefix = ''}) {
  return List<Topic>.generate(
    count,
    (i) => createTestTopic(
      id: '$prefix$i',
      slug: 'topic-$prefix$i',
      title: '專題 $prefix$i',
      ogDescription: '專題描述 $prefix$i',
    ),
  );
}

void main() {
  late MockTopicRepository mockRepo;

  setUp(() {
    mockRepo = MockTopicRepository();
  });

  group('useTopics', () {
    testWidgets(
      'should load initial topics on mount',
      (tester) async {
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => _topics(10),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopics(mockRepo);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.topics.value.length}',
                          ),
                          Text(
                            'Loading: '
                            '${result.isLoading.value}',
                          ),
                          Text(
                            'HasMore: '
                            '${result.hasMore.value}',
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Count: 10'), findsOneWidget);
        expect(
          find.text('Loading: false'),
          findsOneWidget,
        );
        expect(
          find.text('HasMore: true'),
          findsOneWidget,
        );
        verify(() => mockRepo.fetchTopics(
              page: 1,
            )).called(1);
      },
    );

    testWidgets(
      'should load more topics when loadMore is called',
      (tester) async {
        var callCount = 0;
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          callCount++;
          return _topics(10, prefix: 'p${callCount}_');
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopics(mockRepo);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.topics.value.length}',
                          ),
                          ElevatedButton(
                            onPressed: result.loadMore,
                            child: const Text('Load More'),
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Count: 10'), findsOneWidget);

        await tester.tap(find.text('Load More'));
        await tester.pumpAndSettle();

        expect(find.text('Count: 20'), findsOneWidget);
      },
    );

    testWidgets(
      'should set hasMore to false when topics '
      'less than page size',
      (tester) async {
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => _topics(5),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopics(mockRepo);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.topics.value.length}',
                          ),
                          Text(
                            'HasMore: '
                            '${result.hasMore.value}',
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Count: 5'), findsOneWidget);
        expect(
          find.text('HasMore: false'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should refresh and reset topics',
      (tester) async {
        var callCount = 0;
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          callCount++;
          return _topics(
            10,
            prefix: 'call${callCount}_',
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopics(mockRepo);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Count: '
                            '${result.topics.value.length}',
                          ),
                          if (result
                              .topics.value.isNotEmpty)
                            Text(
                              'FirstId: '
                              '${result.topics.value.first.id}',
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
          find.text('FirstId: call1_0'),
          findsOneWidget,
        );

        await tester.tap(find.text('Refresh'));
        await tester.pumpAndSettle();

        expect(callCount, equals(2));
        expect(find.text('Count: 10'), findsOneWidget);
        expect(
          find.text('FirstId: call2_0'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should call repo with correct parameters',
      (tester) async {
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => _topics(10),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopics(mockRepo);

                return (BuildContext context) => Scaffold(
                      body: Text(
                        'Count: '
                        '${result.topics.value.length}',
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        verify(() => mockRepo.fetchTopics(
              page: 1,
            )).called(1);
        expect(find.text('Count: 10'), findsOneWidget);
      },
    );
  });
}
