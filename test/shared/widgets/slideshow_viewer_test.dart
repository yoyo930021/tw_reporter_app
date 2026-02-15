import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/widgets/slideshow_viewer.dart';

void main() {
  Widget buildWidget(List<SlideItem> slides) {
    return MaterialApp(
      home: Scaffold(
        body: SlideshowViewer(slides: slides),
      ),
    );
  }

  final testSlides = <SlideItem>[
    (url: 'https://example.com/1.jpg', description: 'First slide'),
    (url: 'https://example.com/2.jpg', description: 'Second slide'),
    (url: 'https://example.com/3.jpg', description: 'Third slide'),
  ];

  group('SlideshowViewer', () {
    testWidgets('shows page counter starting at 1 / N',
        (tester) async {
      await tester.pumpWidget(buildWidget(testSlides));
      await tester.pump();

      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('shows first slide description', (tester) async {
      await tester.pumpWidget(buildWidget(testSlides));
      await tester.pump();

      expect(find.text('First slide'), findsOneWidget);
    });

    testWidgets('prev button is disabled on first page',
        (tester) async {
      await tester.pumpWidget(buildWidget(testSlides));
      await tester.pump();

      final prevButton = find.byIcon(Icons.chevron_left);
      expect(prevButton, findsOneWidget);

      final prevIconButton = tester.widget<IconButton>(
        find.widgetWithIcon(
          IconButton, Icons.chevron_left,
        ),
      );
      expect(prevIconButton.onPressed, isNull);
    });

    testWidgets('next button is enabled on first page',
        (tester) async {
      await tester.pumpWidget(buildWidget(testSlides));
      await tester.pump();

      final nextIconButton =
          tester.widget<IconButton>(
        find.widgetWithIcon(
          IconButton, Icons.chevron_right,
        ),
      );
      expect(nextIconButton.onPressed, isNotNull);
    });

    testWidgets('tapping next advances to page 2',
        (tester) async {
      await tester.pumpWidget(buildWidget(testSlides));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('next button is disabled on last page',
        (tester) async {
      await tester.pumpWidget(buildWidget(testSlides));
      await tester.pump();

      // Go to last page
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('3 / 3'), findsOneWidget);

      final nextIconButton =
          tester.widget<IconButton>(
        find.widgetWithIcon(
          IconButton, Icons.chevron_right,
        ),
      );
      expect(nextIconButton.onPressed, isNull);
    });

    testWidgets('hides description when empty', (tester) async {
      final slides = <SlideItem>[
        (url: 'https://example.com/1.jpg', description: ''),
      ];
      await tester.pumpWidget(buildWidget(slides));
      await tester.pump();

      expect(find.text('1 / 1'), findsOneWidget);
    });
  });
}
