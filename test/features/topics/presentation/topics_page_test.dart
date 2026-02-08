import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/topics/presentation/topics_page.dart';

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

  Widget buildPage() {
    return wrapWithProviders(
      const TopicsPage(),
      topicRepository: mockRepo,
    );
  }

  group('TopicsPage', () {
    testWidgets(
      'should display app bar with title',
      (tester) async {
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => <Topic>[],
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('專題'), findsOneWidget);
      },
    );

    testWidgets(
      'should display list of topics after loading',
      (tester) async {
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => _topics(5, prefix: '測試專題'),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.text('專題 測試專題0'),
          findsOneWidget,
        );
        expect(
          find.text('專題 測試專題4'),
          findsOneWidget,
        );
        expect(
          find.byType(ListView),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display loading indicator on initial load',
      (tester) async {
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          await Future<void>.delayed(
            const Duration(milliseconds: 50),
          );
          return <Topic>[];
        });

        await tester.pumpWidget(buildPage());

        await tester.pump();
        await tester.pump(
          const Duration(milliseconds: 10),
        );

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'should display empty state when no topics',
      (tester) async {
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => <Topic>[],
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('目前沒有專題'), findsOneWidget);
      },
    );

    testWidgets(
      'should have RefreshIndicator for pull to refresh',
      (tester) async {
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => _topics(3),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.byType(RefreshIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should load more topics when scrolling',
      (tester) async {
        var callCount = 0;
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          callCount++;
          return _topics(
            10,
            prefix: 'p${callCount}_',
          );
        });

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.text('專題 p1_0'),
          findsOneWidget,
        );

        await tester.drag(
          find.byType(ListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        expect(callCount, greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      'should not show load more indicator '
      'when no more topics',
      (tester) async {
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => _topics(3),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('載入更多...'), findsNothing);
      },
    );

    testWidgets(
      'should display topic with formatted date',
      (tester) async {
        final topics = <Topic>[
          createTestTopic(
            ogDescription: '專題描述',
          ),
        ];
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => topics);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('測試專題'), findsOneWidget);
        expect(
          find.textContaining('2024'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display topic description',
      (tester) async {
        final topics = <Topic>[
          createTestTopic(
            slug: 'deep-topic',
            title: '深度調查專題',
            ogDescription: '這是一個深度調查報導系列',
          ),
        ];
        when(() => mockRepo.fetchTopics(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => topics);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.text('深度調查專題'),
          findsOneWidget,
        );
        expect(
          find.text('這是一個深度調查報導系列'),
          findsOneWidget,
        );
      },
    );
  });
}
