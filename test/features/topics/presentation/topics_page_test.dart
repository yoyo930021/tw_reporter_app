import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/topics/presentation/topics_page.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

/// Helper: wrap topics in a [ListResponse].
ListResponse<Topic> _listResponse(List<Topic> topics) {
  return ListResponse<Topic>(
    data: ListData<Topic>(
      meta: ListMeta(
        limit: topics.length,
        offset: 0,
        total: 100,
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
      publishedDate: DateTime(2024, 1, 1 + i),
    ),
  );
}

/// Setup default fetchTopics mock.
void _mockFetchTopics(
  MockTwReporterApi api,
  List<Topic> topics,
) {
  when(() => api.fetchTopics(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => _listResponse(topics));
}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  Widget wrapWithApp(TopicsPage topicsPage) {
    return MaterialApp(home: topicsPage);
  }

  group('TopicsPage', () {
    testWidgets(
      'should display app bar with title',
      (WidgetTester tester) async {
        _mockFetchTopics(mockApi, <Topic>[]);

        await tester.pumpWidget(
          wrapWithApp(TopicsPage(api: mockApi)),
        );

        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('專題'), findsOneWidget);
      },
    );

    testWidgets(
      'should display list of topics after loading',
      (WidgetTester tester) async {
        _mockFetchTopics(mockApi, _topics(5, prefix: '測試專題'));

        await tester.pumpWidget(
          wrapWithApp(TopicsPage(api: mockApi)),
        );

        await tester.pumpAndSettle();

        expect(find.text('專題 測試專題0'), findsOneWidget);
        expect(find.text('專題 測試專題4'), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
      },
    );

    testWidgets(
      'should display loading indicator on initial load',
      (WidgetTester tester) async {
        when(() => mockApi.fetchTopics(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async {
          await Future<void>.delayed(
            const Duration(milliseconds: 50),
          );
          return _listResponse(<Topic>[]);
        });

        await tester.pumpWidget(
          wrapWithApp(TopicsPage(api: mockApi)),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'should display empty state when no topics',
      (WidgetTester tester) async {
        _mockFetchTopics(mockApi, <Topic>[]);

        await tester.pumpWidget(
          wrapWithApp(TopicsPage(api: mockApi)),
        );

        await tester.pumpAndSettle();

        expect(find.text('目前沒有專題'), findsOneWidget);
      },
    );

    testWidgets(
      'should have RefreshIndicator for pull to refresh',
      (WidgetTester tester) async {
        _mockFetchTopics(mockApi, _topics(3));

        await tester.pumpWidget(
          wrapWithApp(TopicsPage(api: mockApi)),
        );

        await tester.pumpAndSettle();

        expect(find.byType(RefreshIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'should load more topics when scrolling to bottom',
      (WidgetTester tester) async {
        var callCount = 0;
        when(() => mockApi.fetchTopics(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async {
          callCount++;
          return _listResponse(_topics(10, prefix: 'p${callCount}_'));
        });

        await tester.pumpWidget(
          wrapWithApp(TopicsPage(api: mockApi)),
        );

        await tester.pumpAndSettle();

        expect(find.text('專題 p1_0'), findsOneWidget);

        await tester.drag(
          find.byType(ListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        expect(callCount, greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      'should not show load more indicator when no more topics',
      (WidgetTester tester) async {
        _mockFetchTopics(mockApi, _topics(3));

        await tester.pumpWidget(
          wrapWithApp(TopicsPage(api: mockApi)),
        );

        await tester.pumpAndSettle();

        expect(find.text('載入更多...'), findsNothing);
      },
    );

    testWidgets(
      'should display topic with formatted date',
      (WidgetTester tester) async {
        final List<Topic> topics = <Topic>[
          Topic(
            id: '1',
            slug: 'test-topic',
            title: '測試專題',
            ogDescription: '專題描述',
            publishedDate: DateTime(2024, 3, 15),
          ),
        ];
        _mockFetchTopics(mockApi, topics);

        await tester.pumpWidget(
          wrapWithApp(TopicsPage(api: mockApi)),
        );

        await tester.pumpAndSettle();

        expect(find.text('測試專題'), findsOneWidget);
        expect(find.textContaining('2024'), findsOneWidget);
      },
    );

    testWidgets(
      'should display topic description',
      (WidgetTester tester) async {
        final List<Topic> topics = <Topic>[
          Topic(
            id: '1',
            slug: 'test-topic',
            title: '深度調查專題',
            ogDescription: '這是一個深度調查報導系列',
            publishedDate: DateTime.now(),
          ),
        ];
        _mockFetchTopics(mockApi, topics);

        await tester.pumpWidget(
          wrapWithApp(TopicsPage(api: mockApi)),
        );

        await tester.pumpAndSettle();

        expect(find.text('深度調查專題'), findsOneWidget);
        expect(
          find.text('這是一個深度調查報導系列'),
          findsOneWidget,
        );
      },
    );
  });
}
