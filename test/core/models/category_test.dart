import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/category.dart';

void main() {
  group('Category', () {
    test('should create Category from JSON', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '63206383207bf7c5f871622c',
        'name': '國際兩岸',
        'sort_order': 17,
      };

      // Act
      final Category category = Category.fromJson(json);

      // Assert
      expect(category.id, equals('63206383207bf7c5f871622c'));
      expect(category.name, equals('國際兩岸'));
      expect(category.sortOrder, equals(17));
    });

    test('should handle nullable sortOrder', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '123',
        'name': '測試分類',
      };

      // Act
      final Category category = Category.fromJson(json);

      // Assert
      expect(category.sortOrder, isNull);
    });

    test('should support equality comparison', () {
      // Arrange
      final Category category1 = Category(
        id: '123',
        name: '測試',
        sortOrder: 1,
      );
      final Category category2 = Category(
        id: '123',
        name: '測試',
        sortOrder: 1,
      );

      // Assert
      expect(category1, equals(category2));
    });
  });

  group('Subcategory', () {
    test('should create Subcategory from JSON', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '63206383207bf7c5f8716232',
        'key': '63206383207bf7c5f8716232',
        'name': '歐洲',
        'latest_order': 0,
      };

      // Act
      final Subcategory subcategory = Subcategory.fromJson(json);

      // Assert
      expect(subcategory.id, equals('63206383207bf7c5f8716232'));
      expect(subcategory.key, equals('63206383207bf7c5f8716232'));
      expect(subcategory.name, equals('歐洲'));
      expect(subcategory.latestOrder, equals(0));
    });

    test('should handle nullable latestOrder', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '123',
        'key': 'test-key',
        'name': '測試',
      };

      // Act
      final Subcategory subcategory = Subcategory.fromJson(json);

      // Assert
      expect(subcategory.latestOrder, isNull);
    });
  });

  group('CategorySet', () {
    test('should create CategorySet from JSON with subcategory', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'category': <String, dynamic>{
          'id': '63206383207bf7c5f871622c',
          'name': '國際兩岸',
          'sortOrder': 17,
        },
        'subcategory': <String, dynamic>{
          'id': '63206383207bf7c5f8716232',
          'key': '63206383207bf7c5f8716232',
          'name': '歐洲',
          'latestOrder': 0,
        },
      };

      // Act
      final CategorySet categorySet = CategorySet.fromJson(json);

      // Assert
      expect(categorySet.category?.name, equals('國際兩岸'));
      expect(categorySet.subcategory, isNotNull);
      expect(categorySet.subcategory?.name, equals('歐洲'));
    });

    test('should create CategorySet without subcategory', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'category': <String, dynamic>{
          'id': '123',
          'name': '測試分類',
        },
      };

      // Act
      final CategorySet categorySet = CategorySet.fromJson(json);

      // Assert
      expect(categorySet.category?.name, equals('測試分類'));
      expect(categorySet.subcategory, isNull);
    });

    test('should convert CategorySet to JSON', () {
      // Arrange
      final CategorySet categorySet = CategorySet(
        category: Category(
          id: '123',
          name: '測試',
        ),
        subcategory: Subcategory(
          id: '456',
          key: 'test-key',
          name: '子分類',
        ),
      );

      // Act
      final Map<String, dynamic> json = categorySet.toJson();

      // Assert
      expect(json['category']['name'], equals('測試'));
      expect(json['subcategory']['name'], equals('子分類'));
    });
  });
}
