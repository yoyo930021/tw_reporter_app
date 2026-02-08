import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/shared/widgets/category_badge.dart';

void main() {
  group('CategoryBadge', () {
    testWidgets('displays category name', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CategoryBadge(categoryName: 'culture'),
        ),
      ));

      expect(find.text('culture'), findsOneWidget);
    });

    testWidgets('uses correct color for known category',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CategoryBadge(categoryName: 'culture'),
        ),
      ));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration! as BoxDecoration;
      // culture color is 0xFF9B59B6
      expect(
        decoration.color,
        AppColors.categoryColors['culture']!.withValues(alpha: 0.1),
      );
    });

    testWidgets('uses default grey color for unknown category',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CategoryBadge(categoryName: 'unknown_category'),
        ),
      ));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(
        decoration.color,
        AppColors.grey600.withValues(alpha: 0.1),
      );
    });
  });
}
