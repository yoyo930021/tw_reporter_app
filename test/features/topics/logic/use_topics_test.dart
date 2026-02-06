import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/topics/logic/use_topics.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

/// Helper: wrap topics in a [ListResponse].
ListResponse<Topic> _listResponse(
  List<Topic> topics, {
  int offset = 0,
  int total = 100,
}) {
  return ListResponse<Topic>(
    data: ListData<Topic>(
      meta: ListMeta(
        limit: topics.length,
        offset: offset,
        total: total,
      ),
      records: topics,
    ),
    status: 'success',
  );
}

/// Helper: create test topics.
List<Topic> _topics(int count, {String prefix = ''}) {
  return List<Topic>.generate(
    count,
    (int i) => Topic(
      id: '$prefix$i',
      slug: 'topic-$prefix$i',
      title: '專題 $prefix$i',
      ogDescription: '專題描述 $prefix$i',
      publishedDate: DateTime.now(),
    ),
  );
}

// 測試用的 Composition Widget
class TestWidget extends CompositionWidget {
  const TestWidget({required this.setupFn, super.key});

  final Widget Function(BuildContext) Function() setupFn;

  @override
  Widget Function(BuildContext) setup() => setupFn();
}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  group('useTopics', () {
    testWidgets(
      'should load initial topics on mount',
      (WidgetTester tester) async {
        // Arrange - fetchTopicsByPage calls fetchTopics(limit:10, offset:0)
        when(() => mockApi.fetchTopics(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer(
          (_) async => _listResponse(_topics(10)),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final TopicsResult result = useTopics(mockApi);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text('Count: ${result.topics.value.length}'),
                          Text('Loading: ${result.isLoading.value}'),
                          Text('HasMore: ${result.hasMore.value}'),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Count: 10'), findsOneWidget);
        expect(find.text('Loading: false'), findsOneWidget);
        expect(find.text('HasMore: true'), findsOneWidget);
        verify(() => mockApi.fetchTopics(
              limit: 10,
              offset: 0,
            )).called(1);
      },
    );

    testWidgets(
      'should load more topics when loadMore is called',
      (WidgetTester tester) async {
        // Arrange
        var callCount = 0;
        when(() => mockApi.fetchTopics(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async {
          callCount++;
          return _listResponse(
            _topics(10, prefix: 'p${callCount}_'),
          );
        });

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final TopicsResult result = useTopics(mockApi);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text('Count: ${result.topics.value.length}'),
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

        // Act - 載入更多
        await tester.tap(find.text('Load More'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Count: 20'), findsOneWidget);
      },
    );

    testWidgets(
      'should set hasMore to false when topics less than page size',
      (WidgetTester tester) async {
        // Arrange - return only 5 topics (< pageSize 10)
        when(() => mockApi.fetchTopics(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer(
          (_) async => _listResponse(_topics(5)),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final TopicsResult result = useTopics(mockApi);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text('Count: ${result.topics.value.length}'),
                          Text('HasMore: ${result.hasMore.value}'),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Count: 5'), findsOneWidget);
        expect(find.text('HasMore: false'), findsOneWidget);
      },
    );

    testWidgets(
      'should refresh and reset topics',
      (WidgetTester tester) async {
        // Arrange
        var callCount = 0;
        when(() => mockApi.fetchTopics(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async {
          callCount++;
          return _listResponse(
            _topics(10, prefix: 'call${callCount}_'),
          );
        });

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final TopicsResult result = useTopics(mockApi);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text('Count: ${result.topics.value.length}'),
                          if (result.topics.value.isNotEmpty)
                            Text(
                              'FirstId: ${result.topics.value.first.id}',
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
        expect(find.text('FirstId: call1_0'), findsOneWidget);

        // Act - Refresh
        await tester.tap(find.text('Refresh'));
        await tester.pumpAndSettle();

        // Assert
        expect(callCount, equals(2));
        expect(find.text('Count: 10'), findsOneWidget);
        expect(find.text('FirstId: call2_0'), findsOneWidget);
      },
    );

    testWidgets(
      'should call API with correct parameters',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockApi.fetchTopics(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer(
          (_) async => _listResponse(_topics(10)),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final TopicsResult result =
                    useTopics(mockApi, pageSize: 10);

                return (BuildContext context) => Scaffold(
                      body: Text(
                        'Count: ${result.topics.value.length}',
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        verify(() => mockApi.fetchTopics(
              limit: 10,
              offset: 0,
            )).called(1);
        expect(find.text('Count: 10'), findsOneWidget);
      },
    );
  });
}
