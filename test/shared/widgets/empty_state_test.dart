import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyState(message: '目前沒有內容'),
        ),
      ));

      expect(find.text('目前沒有內容'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            message: '空',
            icon: Icons.inbox,
          ),
        ),
      ));

      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('does not display icon when not provided',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyState(message: '空'),
        ),
      ));

      // No icon should be rendered
      expect(find.byType(Icon), findsNothing);
    });
  });
}
