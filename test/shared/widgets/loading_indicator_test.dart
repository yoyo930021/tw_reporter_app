import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('displays CircularProgressIndicator',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is centered', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(),
        ),
      ));

      expect(find.byType(Center), findsOneWidget);
    });
  });
}
