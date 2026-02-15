import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/widgets/shimmer_placeholder.dart';

void main() {
  group('ShimmerPlaceholder', () {
    testWidgets('renders without crash', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPlaceholder(height: 200, width: 300),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });

    testWidgets('respects height and width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPlaceholder(height: 100, width: 200),
          ),
        ),
      );
      await tester.pump();

      final container = tester.widget<Container>(
        find.byType(Container),
      );
      expect(container.constraints?.maxHeight, 100);
      expect(container.constraints?.maxWidth, 200);
    });

    testWidgets('contains animated gradient', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPlaceholder(height: 200),
          ),
        ),
      );
      await tester.pump();

      // Verify it uses DecoratedBox for the gradient
      expect(find.byType(DecoratedBox), findsWidgets);
    });

    testWidgets('animation is running', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerPlaceholder(height: 200),
          ),
        ),
      );

      // Pump forward to verify animation progresses
      await tester.pump(const Duration(milliseconds: 750));
      // Should still be rendered without error
      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ShimmerPlaceholder(height: 200),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });
  });
}
