import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';

void main() {
  group('formatDate', () {
    test('formats normal date correctly', () {
      expect(formatDate(DateTime(2024, 1, 15)), '2024年01月15日');
    });

    test('pads single-digit month and day with zero', () {
      expect(formatDate(DateTime(2024, 3, 5)), '2024年03月05日');
    });

    test('handles year-end date', () {
      expect(formatDate(DateTime(2024, 12, 31)), '2024年12月31日');
    });

    test('handles first day of year', () {
      expect(formatDate(DateTime(2025)), '2025年01月01日');
    });

    test('handles UTC date', () {
      final utcDate = DateTime.utc(2024, 6, 15);
      expect(formatDate(utcDate), '2024年06月15日');
    });
  });
}
