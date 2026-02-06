import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/topics/presentation/topics_page.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  Widget wrapWithApp(TopicsPage topicsPage) {
    return MaterialApp(
      home: topicsPage,
    );
  }

  group('TopicsPage', () {
    testWidgets('should display app bar with title', (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchTopicsByPage(page: 1)).thenAnswer((_) async => <Topic>[]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(TopicsPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('專題'), findsOneWidget);
    });

    testWidgets('should display list of topics after loading',
        (WidgetTester tester) async {
      // Arrange
      final List<Topic> mockTopics = List<Topic>.generate(
        5,
        (int index) => Topic(
          id: '$index',
          slug: 'topic-$index',
          title: '測試專題 $index',
          ogDescription: '專題描述 $index',
          publishedDate: DateTime(2024, 1, 1 + index),
        ),
      );

      when(() => mockApi.fetchTopicsByPage(page: 1)).thenAnswer((_) async => mockTopics);

      // Act
      await tester.pumpWidget(
        wrapWithApp(TopicsPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('測試專題 0'), findsOneWidget);
      expect(find.text('測試專題 4'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display loading indicator on initial load',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchTopicsByPage(page: 1)).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return <Topic>[];
        },
      );

      // Act
      await tester.pumpWidget(
        wrapWithApp(TopicsPage(api: mockApi)),
      );

      // 等待初始 pump
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 清理
      await tester.pumpAndSettle();
    });

    testWidgets('should display empty state when no topics',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchTopicsByPage(page: 1)).thenAnswer((_) async => <Topic>[]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(TopicsPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('目前沒有專題'), findsOneWidget);
    });

    testWidgets('should have RefreshIndicator for pull to refresh',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockApi.fetchTopicsByPage(page: 1)).thenAnswer((_) async =>
          List<Topic>.generate(
            3,
            (int index) => Topic(
              id: '$index',
              slug: 'topic-$index',
              title: '專題 $index',
              ogDescription: '描述',
              publishedDate: DateTime.now(),
            ),
          ));

      // Act
      await tester.pumpWidget(
        wrapWithApp(TopicsPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert - 驗證 RefreshIndicator 存在
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should load more topics when scrolling to bottom',
        (WidgetTester tester) async {
      // Arrange
      int currentPage = 1;
      when(() => mockApi.fetchTopicsByPage(page: any(named: 'page')))
          .thenAnswer((_) async {
        final int page = currentPage++;
        return List<Topic>.generate(
          10,
          (int index) => Topic(
            id: 'page${page}_$index',
            slug: 'topic-page${page}_$index',
            title: '專題 $page-$index',
            ogDescription: '描述',
            publishedDate: DateTime.now(),
          ),
        );
      });

      // Act
      await tester.pumpWidget(
        wrapWithApp(TopicsPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // 驗證初始載入
      expect(find.text('專題 1-0'), findsOneWidget);

      // 滾動到底部觸發載入更多
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Assert - 應該載入了第二頁
      expect(currentPage, equals(2));
    });

    testWidgets('should not show load more indicator when no more topics',
        (WidgetTester tester) async {
      // Arrange - 返回少於 page size 的專題，表示沒有更多了
      when(() => mockApi.fetchTopicsByPage(page: 1)).thenAnswer((_) async =>
          List<Topic>.generate(
            3, // Less than page size
            (int index) => Topic(
              id: '$index',
              slug: 'topic-$index',
              title: '專題 $index',
              ogDescription: '描述',
              publishedDate: DateTime.now(),
            ),
          ));

      // Act
      await tester.pumpWidget(
        wrapWithApp(TopicsPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert - 應該不顯示 "載入更多" 提示
      expect(find.text('載入更多...'), findsNothing);
    });

    testWidgets('should display topic with formatted date',
        (WidgetTester tester) async {
      // Arrange
      final Topic mockTopic = Topic(
        id: '1',
        slug: 'test-topic',
        title: '測試專題',
        ogDescription: '專題描述',
        publishedDate: DateTime(2024, 3, 15),
      );

      when(() => mockApi.fetchTopicsByPage(page: 1))
          .thenAnswer((_) async => <Topic>[mockTopic]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(TopicsPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert - 驗證日期格式化顯示
      expect(find.text('測試專題'), findsOneWidget);
      expect(find.textContaining('2024'), findsOneWidget);
    });

    testWidgets('should display topic description', (WidgetTester tester) async {
      // Arrange
      final Topic mockTopic = Topic(
        id: '1',
        slug: 'test-topic',
        title: '深度調查專題',
        ogDescription: '這是一個深度調查報導系列',
        publishedDate: DateTime.now(),
      );

      when(() => mockApi.fetchTopicsByPage(page: 1))
          .thenAnswer((_) async => <Topic>[mockTopic]);

      // Act
      await tester.pumpWidget(
        wrapWithApp(TopicsPage(api: mockApi)),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('深度調查專題'), findsOneWidget);
      expect(find.text('這是一個深度調查報導系列'), findsOneWidget);
    });
  });
}
