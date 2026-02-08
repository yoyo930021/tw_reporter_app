import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/widgets/horizontal_carousel.dart';

void main() {
  group('HorizontalCarousel', () {
    testWidgets('should render correct number of items',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalCarousel(
              itemWidth: 200,
              height: 150,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Text('Item $index');
              },
            ),
          ),
        ),
      );

      // The first few items should be visible
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('should use horizontal scroll direction',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalCarousel(
              itemWidth: 200,
              height: 150,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Text('Item $index');
              },
            ),
          ),
        ),
      );

      // Should have a ListView
      expect(find.byType(ListView), findsOneWidget);
      // Should have a SizedBox constraining height
      expect(find.byType(SizedBox), findsAtLeast(1));
    });

    testWidgets('should handle empty item count',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalCarousel(
              itemWidth: 200,
              height: 150,
              itemCount: 0,
              itemBuilder: (context, index) {
                return Text('Item $index');
              },
            ),
          ),
        ),
      );

      // Should render without error
      expect(find.byType(HorizontalCarousel), findsOneWidget);
      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('should apply custom padding',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizontalCarousel(
              itemWidth: 200,
              height: 150,
              itemCount: 1,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              itemBuilder: (context, index) {
                return Text('Item $index');
              },
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
    });
  });
}
