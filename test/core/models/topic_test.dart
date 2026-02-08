import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/topic.dart';

void main() {
  group('Topic', () {
    test('should create Topic from JSON with all fields', () {
      // Arrange
      final json = <String, dynamic>{
        'id': 'topic123',
        'slug': 'test-topic',
        'title': '測試專題',
        'short_title': '測試',
        'og_description': '專題描述',
        'leading_image': <String, dynamic>{
          'id': 'img123',
          'filetype': 'image/jpeg',
          'description': '主圖',
          'resized_targets': <String, dynamic>{},
        },
        'og_image': <String, dynamic>{
          'id': 'img456',
          'filetype': 'image/jpeg',
          'resized_targets': <String, dynamic>{},
        },
        'published_date': '2026-01-28T16:00:00Z',
        'relateds_background': '#ffffff',
        'relateds_format': 'list',
        'relateds': <String>['article1', 'article2'],
        'full': true,
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.id, equals('topic123'));
      expect(topic.slug, equals('test-topic'));
      expect(topic.title, equals('測試專題'));
      expect(topic.shortTitle, equals('測試'));
      expect(topic.ogDescription, equals('專題描述'));
      expect(topic.leadingImage, isNotNull);
      expect(topic.ogImage, isNotNull);
      expect(
        topic.publishedDate,
        equals(DateTime.parse('2026-01-28T16:00:00Z')),
      );
      expect(topic.relatedsBackground, equals('#ffffff'));
      expect(topic.relatedsFormat, equals('list'));
      expect(topic.relateds, hasLength(2));
      expect(topic.relateds?.first, equals('article1'));
      expect(topic.full, isTrue);
    });

    test('should create Topic with minimal required fields', () {
      // Arrange
      final json = <String, dynamic>{
        'id': '123',
        'slug': 'minimal-topic',
        'title': '最小專題',
        'published_date': '2026-01-01T00:00:00Z',
      };

      // Act
      final topic = Topic.fromJson(json);

      // Assert
      expect(topic.id, equals('123'));
      expect(topic.title, equals('最小專題'));
      expect(topic.shortTitle, isNull);
      expect(topic.ogDescription, isNull);
      expect(topic.leadingImage, isNull);
      expect(topic.ogImage, isNull);
      expect(topic.relatedsBackground, isNull);
      expect(topic.relatedsFormat, isNull);
      expect(topic.relateds, isNull);
      expect(topic.full, isNull);
    });

    test('should convert Topic to JSON', () {
      // Arrange
      final topic = Topic(
        id: '123',
        slug: 'test-topic',
        title: '測試專題',
        publishedDate: DateTime.parse('2026-01-01T00:00:00Z'),
        relateds: <String>['article1', 'article2'],
      );

      // Act
      final json = topic.toJson();

      // Assert
      expect(json['id'], equals('123'));
      expect(json['title'], equals('測試專題'));
      expect(json['relateds'], isA<List<dynamic>>());
      expect(json['relateds'], hasLength(2));
    });

    test('should support equality comparison', () {
      // Arrange
      final now = DateTime.now();
      final topic1 = Topic(
        id: '123',
        slug: 'test',
        title: '測試',
        publishedDate: now,
      );
      final topic2 = Topic(
        id: '123',
        slug: 'test',
        title: '測試',
        publishedDate: now,
      );

      // Assert
      expect(topic1, equals(topic2));
    });

    test('should support copyWith', () {
      // Arrange
      final topic = Topic(
        id: '123',
        slug: 'test',
        title: '原標題',
        publishedDate: DateTime.now(),
      );

      // Act
      final updatedTopic = topic.copyWith(
        title: '新標題',
        ogDescription: '新描述',
      );

      // Assert
      expect(topic.title, equals('原標題'));
      expect(updatedTopic.title, equals('新標題'));
      expect(updatedTopic.ogDescription, equals('新描述'));
    });
  });
}
