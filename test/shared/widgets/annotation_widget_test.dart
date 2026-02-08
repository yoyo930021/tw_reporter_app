import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/widgets/annotation_widget.dart';

void main() {
  Widget buildWidget({
    required String triggerText,
    required String contentBase64,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AnnotationWidget(
          triggerText: triggerText,
          contentBase64: contentBase64,
          linkColor: Colors.blue,
          textStyle: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  group('AnnotationWidget', () {
    testWidgets('shows trigger text with down arrow initially', (tester) async {
      final encoded = base64Encode(utf8.encode('annotation content'));
      await tester.pumpWidget(buildWidget(
        triggerText: '（註）',
        contentBase64: encoded,
      ));

      expect(find.text('（註） ▼'), findsOneWidget);
      // Should NOT show the decoded content
      expect(find.text('annotation content'), findsNothing);
    });

    testWidgets('expands on tap and shows decoded content with up arrow',
        (tester) async {
      final encoded = base64Encode(utf8.encode('這是註釋'));
      await tester.pumpWidget(buildWidget(
        triggerText: '（註）',
        contentBase64: encoded,
      ));

      await tester.tap(find.text('（註） ▼'));
      await tester.pumpAndSettle();

      expect(find.text('（註） ▲'), findsOneWidget);
      expect(find.text('這是註釋'), findsOneWidget);
    });

    testWidgets('collapses on second tap', (tester) async {
      final encoded = base64Encode(utf8.encode('content'));
      await tester.pumpWidget(buildWidget(
        triggerText: 'Note',
        contentBase64: encoded,
      ));

      // Expand
      await tester.tap(find.text('Note ▼'));
      await tester.pumpAndSettle();
      expect(find.text('content'), findsOneWidget);

      // Collapse
      await tester.tap(find.text('Note ▲'));
      await tester.pumpAndSettle();
      expect(find.text('content'), findsNothing);
      expect(find.text('Note ▼'), findsOneWidget);
    });

    testWidgets('invalid base64 shows empty content without crash',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        triggerText: '（註）',
        contentBase64: '!!!invalid!!!',
      ));

      // Expand
      await tester.tap(find.text('（註） ▼'));
      await tester.pumpAndSettle();

      // Should not crash - shows empty string
      expect(find.text('（註） ▲'), findsOneWidget);
    });
  });
}
