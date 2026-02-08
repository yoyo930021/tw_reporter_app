import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/widgets/section_header.dart';

void main() {
  group('SectionHeader', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SectionHeader(title: '最新報導'),
        ),
      ));

      expect(find.text('最新報導'), findsOneWidget);
    });

    testWidgets('shows view all button when onViewAll is provided',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SectionHeader(
            title: '最新報導',
            onViewAll: () {},
          ),
        ),
      ));

      expect(find.text('查看全部'), findsOneWidget);
    });

    testWidgets('does not show view all button when onViewAll is null',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SectionHeader(title: '最新報導'),
        ),
      ));

      expect(find.text('查看全部'), findsNothing);
    });

    testWidgets('triggers onViewAll callback when tapped',
        (tester) async {
      var viewAllTapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SectionHeader(
            title: '最新報導',
            onViewAll: () => viewAllTapped = true,
          ),
        ),
      ));

      await tester.tap(find.text('查看全部'));
      expect(viewAllTapped, isTrue);
    });
  });
}
