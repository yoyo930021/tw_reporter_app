import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/tag.dart';
import 'package:tw_reporter_app/core/models/category.dart';

void main() {
  group('Tag', () {
    test('should create Tag from JSON', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '5768ed08406be01000c69076',
        'key': '5768ed08406be01000c69076',
        'name': '中國',
        'latest_order': 10,
        'category': null,
      };

      // Act
      final Tag tag = Tag.fromJson(json);

      // Assert
      expect(tag.id, equals('5768ed08406be01000c69076'));
      expect(tag.key, equals('5768ed08406be01000c69076'));
      expect(tag.name, equals('中國'));
      expect(tag.latestOrder, equals(10));
      expect(tag.category, isNull);
    });

    test('should create Tag with category', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
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
      final Tag tag = Tag.fromJson(json);

      // Assert
      expect(tag.name, equals('測試標籤'));
      expect(tag.category, isNotNull);
      expect(tag.category?.name, equals('測試分類'));
    });

    test('should handle nullable latestOrder and category', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '123',
        'key': 'test-key',
        'name': '測試',
      };

      // Act
      final Tag tag = Tag.fromJson(json);

      // Assert
      expect(tag.latestOrder, isNull);
      expect(tag.category, isNull);
    });

    test('should convert Tag to JSON', () {
      // Arrange
      final Tag tag = Tag(
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
      final Map<String, dynamic> json = tag.toJson();

      // Assert
      expect(json['name'], equals('測試標籤'));
      expect(json['latest_order'], equals(10));
      expect(json['category']['name'], equals('分類'));
    });

    test('should support equality comparison', () {
      // Arrange
      final Tag tag1 = Tag(
        id: '123',
        key: 'test',
        name: '測試',
      );
      final Tag tag2 = Tag(
        id: '123',
        key: 'test',
        name: '測試',
      );

      // Assert
      expect(tag1, equals(tag2));
    });
  });
}
