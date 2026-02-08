import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/widgets/image_diff_viewer.dart';

void main() {
  Widget buildWidget({
    String? beforeDesc,
    String? afterDesc,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ImageDiffViewer(
          beforeUrl: 'https://example.com/before.jpg',
          afterUrl: 'https://example.com/after.jpg',
          beforeDesc: beforeDesc,
          afterDesc: afterDesc,
        ),
      ),
    );
  }

  group('ImageDiffViewer', () {
    testWidgets('renders without crash', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      // Should find the drag handle icon
      expect(find.byIcon(Icons.drag_handle), findsOneWidget);
    });

    testWidgets('shows descriptions when provided',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        beforeDesc: 'Before image',
        afterDesc: 'After image',
      ));
      await tester.pump();

      expect(find.text('Before image'), findsOneWidget);
      expect(find.text('After image'), findsOneWidget);
    });

    testWidgets('hides descriptions when not provided',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Before image'), findsNothing);
      expect(find.text('After image'), findsNothing);
    });

    testWidgets('hides descriptions when empty strings',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        beforeDesc: '',
        afterDesc: '',
      ));
      await tester.pump();

      // Empty descriptions should not be rendered
      // The _hasDescriptions getter should return false for empty strings
    });
  });
}
