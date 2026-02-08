import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/shared/widgets/topic_card.dart';

Topic _createTopic({
  String title = '測試專題',
  String? ogDescription,
}) {
  return Topic(
    id: '1',
    slug: 'test-topic',
    title: title,
    ogDescription: ogDescription,
    publishedDate: DateTime(2024, 6, 15),
  );
}

void main() {
  group('TopicCard', () {
    testWidgets('displays topic title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TopicCard(
            topic: _createTopic(title: '專題標題'),
            onTap: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('專題標題'), findsOneWidget);
    });

    testWidgets('displays topic description', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TopicCard(
            topic: _createTopic(ogDescription: '專題描述'),
            onTap: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('專題描述'), findsOneWidget);
    });

    testWidgets('does not show description when null',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TopicCard(
            topic: _createTopic(),
            onTap: () {},
          ),
        ),
      ));
      await tester.pump();

      // Only title and date should be visible
      expect(find.text('測試專題'), findsOneWidget);
      expect(find.text('2024年06月15日'), findsOneWidget);
    });

    testWidgets('triggers onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TopicCard(
            topic: _createTopic(),
            onTap: () => tapped = true,
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byType(TopicCard));
      expect(tapped, isTrue);
    });

    testWidgets('displays formatted date', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TopicCard(
            topic: _createTopic(),
            onTap: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('2024年06月15日'), findsOneWidget);
    });
  });
}
