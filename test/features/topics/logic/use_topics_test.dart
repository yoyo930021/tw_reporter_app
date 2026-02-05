import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/topics/logic/use_topics.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

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

  group('useTopics', () {
    testWidgets('should load initial topics on mount', (WidgetTester tester) async {
      // Arrange
      final List<Topic> mockTopics = List<Topic>.generate(
        10,
        (int index) => Topic(
          id: '$index',
          slug: 'topic-$index',
          title: '專題 $index',
          ogDescription: '專題描述 $index',
          publishedDate: DateTime.now(),
        ),
      );

      when(() => mockApi.fetchTopics(page: 1)).thenAnswer((_) async => mockTopics);

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

      // 等待載入完成
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Count: 10'), findsOneWidget);
      expect(find.text('Loading: false'), findsOneWidget);
      expect(find.text('HasMore: true'), findsOneWidget);
      verify(() => mockApi.fetchTopics(page: 1)).called(1);
    });

    testWidgets('should load more topics when loadMore is called',
        (WidgetTester tester) async {
      // Arrange
      int currentPage = 1;
      when(() => mockApi.fetchTopics(page: any(named: 'page')))
          .thenAnswer((_) async {
        return List<Topic>.generate(
          10,
          (int index) => Topic(
            id: 'page${currentPage}_$index',
            slug: 'topic-page${currentPage}_$index',
            title: '專題 $currentPage-$index',
            ogDescription: '描述',
            publishedDate: DateTime.now(),
          ),
        )..forEach((_) => currentPage++);
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

      // 等待初始載入
      await tester.pumpAndSettle();
      expect(find.text('Count: 10'), findsOneWidget);

      // Act - 載入更多
      await tester.tap(find.text('Load More'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Count: 20'), findsOneWidget);
    });

    testWidgets('should set hasMore to false when topics less than page size',
        (WidgetTester tester) async {
      // Arrange
      final List<Topic> mockTopics = List<Topic>.generate(
        5, // Less than page size (10)
        (int index) => Topic(
          id: '$index',
          slug: 'topic-$index',
          title: '專題 $index',
          ogDescription: '描述',
          publishedDate: DateTime.now(),
        ),
      );

      when(() => mockApi.fetchTopics(page: 1)).thenAnswer((_) async => mockTopics);

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

      // 等待載入完成
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Count: 5'), findsOneWidget);
      expect(find.text('HasMore: false'), findsOneWidget);
    });

    testWidgets('should refresh and reset topics', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;
      when(() => mockApi.fetchTopics(page: 1)).thenAnswer((_) async {
        callCount++;
        return List<Topic>.generate(
          10,
          (int index) => Topic(
            id: 'call${callCount}_$index',
            slug: 'topic-call${callCount}_$index',
            title: '專題 $callCount-$index',
            ogDescription: '描述',
            publishedDate: DateTime.now(),
          ),
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
                          Text('FirstId: ${result.topics.value.first.id}'),
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

      // Act - 重新整理
      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      // Assert
      expect(callCount, equals(2));
      expect(find.text('Count: 10'), findsOneWidget);
      expect(find.text('FirstId: call2_0'), findsOneWidget);
    });

    testWidgets('should call API with correct parameters',
        (WidgetTester tester) async {
      // Arrange
      final List<Topic> mockTopics = List<Topic>.generate(
        10,
        (int index) => Topic(
          id: '$index',
          slug: 'topic-$index',
          title: '專題 $index',
          ogDescription: '描述',
          publishedDate: DateTime.now(),
        ),
      );

      when(() => mockApi.fetchTopics(page: 1)).thenAnswer((_) async => mockTopics);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final TopicsResult result = useTopics(mockApi, pageSize: 10);

              return (BuildContext context) => Scaffold(
                    body: Text('Count: ${result.topics.value.length}'),
                  );
            },
          ),
        ),
      );

      // 等待載入完成
      await tester.pumpAndSettle();

      // Assert - 驗證 API 被正確調用
      verify(() => mockApi.fetchTopics(page: 1)).called(1);
      expect(find.text('Count: 10'), findsOneWidget);
    });
  });
}
