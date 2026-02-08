import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/widgets/error_view.dart';

void main() {
  group('ErrorView', () {
    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: '網路連線失敗',
            onRetry: () {},
          ),
        ),
      ));

      expect(find.text('網路連線失敗'), findsOneWidget);
      expect(find.text('發生錯誤'), findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'error',
            onRetry: () {},
          ),
        ),
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('triggers onRetry when retry button tapped',
        (tester) async {
      var retried = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'error',
            onRetry: () => retried = true,
          ),
        ),
      ));

      await tester.tap(find.text('重試'));
      expect(retried, isTrue);
    });
  });
}
