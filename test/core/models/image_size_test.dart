import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/image_size.dart';

void main() {
  group('ImageSize', () {
    test('should create ImageSize from JSON', () {
      // Arrange
      final json = <String, dynamic>{
        'url': 'https://www.twreporter.org/images/test.jpg',
        'width': 800,
        'height': 533,
      };

      // Act
      final imageSize = ImageSize.fromJson(json);

      // Assert
      expect(imageSize.url, equals('https://www.twreporter.org/images/test.jpg'));
      expect(imageSize.width, equals(800));
      expect(imageSize.height, equals(533));
    });

    test('should convert ImageSize to JSON', () {
      // Arrange
      const imageSize = ImageSize(
        url: 'https://www.twreporter.org/images/test.jpg',
        width: 800,
        height: 533,
      );

      // Act
      final json = imageSize.toJson();

      // Assert
      expect(json['url'], equals('https://www.twreporter.org/images/test.jpg'));
      expect(json['width'], equals(800));
      expect(json['height'], equals(533));
    });

    test('should be immutable and support copyWith', () {
      // Arrange
      const imageSize = ImageSize(
        url: 'https://www.twreporter.org/images/test.jpg',
        width: 800,
        height: 533,
      );

      // Act
      final updatedImageSize = imageSize.copyWith(width: 1200);

      // Assert
      expect(imageSize.width, equals(800));
      expect(updatedImageSize.width, equals(1200));
      expect(updatedImageSize.url, equals(imageSize.url));
      expect(updatedImageSize.height, equals(imageSize.height));
    });

    test('should support equality comparison', () {
      // Arrange
      const imageSize1 = ImageSize(
        url: 'https://www.twreporter.org/images/test.jpg',
        width: 800,
        height: 533,
      );
      const imageSize2 = ImageSize(
        url: 'https://www.twreporter.org/images/test.jpg',
        width: 800,
        height: 533,
      );
      const imageSize3 = ImageSize(
        url: 'https://www.twreporter.org/images/other.jpg',
        width: 800,
        height: 533,
      );

      // Assert
      expect(imageSize1, equals(imageSize2));
      expect(imageSize1.hashCode, equals(imageSize2.hashCode));
      expect(imageSize1, isNot(equals(imageSize3)));
    });
  });
}
