import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/core/models/tag.dart';

void main() {
  group('Tag', () {
    test('should create Tag from JSON', () {
      // Arrange
      final json = <String, dynamic>{
        'id': '5768ed08406be01000c69076',
        'key': '5768ed08406be01000c69076',
        'name': '中國',
        'latest_order': 10,
        'category': null,
      };

      // Act
      final tag = Tag.fromJson(json);

      // Assert
      expect(tag.id, equals('5768ed08406be01000c69076'));
      expect(tag.key, equals('5768ed08406be01000c69076'));
      expect(tag.name, equals('中國'));
      expect(tag.latestOrder, equals(10));
      expect(tag.category, isNull);
    });

    test('should create Tag with category', () {
      // Arrange
      final json = <String, dynamic>{
        'id': '123',
        'key': 'test-key',
        'name': '測試標籤',
        'latest_order': 5,
        'category': <String, dynamic>{
          'id': '456',
          'name': '測試分類',
        },
      };

      // Act
      final tag = Tag.fromJson(json);

      // Assert
      expect(tag.name, equals('測試標籤'));
      expect(tag.category, isNotNull);
      expect(tag.category?.name, equals('測試分類'));
    });

    test('should handle nullable latestOrder and category', () {
      // Arrange
      final json = <String, dynamic>{
        'id': '123',
        'key': 'test-key',
        'name': '測試',
      };

      // Act
      final tag = Tag.fromJson(json);

      // Assert
      expect(tag.latestOrder, isNull);
      expect(tag.category, isNull);
    });

    test('should convert Tag to JSON', () {
      // Arrange
      const tag = Tag(
        id: '123',
        key: 'test-key',
        name: '測試標籤',
        latestOrder: 10,
        category: Category(
          id: '456',
          name: '分類',
        ),
      );

      // Act
      final json = tag.toJson();

      // Assert
      expect(json['name'], equals('測試標籤'));
      expect(json['latest_order'], equals(10));
      expect(
        (json['category'] as Map<String, dynamic>)['name'],
        equals('分類'),
      );
    });

    test('should support equality comparison', () {
      // Arrange
      const tag1 = Tag(
        id: '123',
        key: 'test',
        name: '測試',
      );
      const tag2 = Tag(
        id: '123',
        key: 'test',
        name: '測試',
      );

      // Assert
      expect(tag1, equals(tag2));
    });
  });
}
