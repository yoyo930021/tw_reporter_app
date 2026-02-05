import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';

void main() {
  group('Topic', () {
    test('should create Topic from JSON with all fields', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'topic123',
        'slug': 'test-topic',
        'title': '測試專題',
        'ogDescription': '專題描述',
        'heroImage': <String, dynamic>{
          'id': 'img123',
          'filetype': 'image/jpeg',
          'description': '主圖',
          'resizedTargets': <String, dynamic>{},
        },
        'ogImage': <String, dynamic>{
          'id': 'img456',
          'filetype': 'image/jpeg',
          'resizedTargets': <String, dynamic>{},
        },
        'publishedDate': '2026-01-28T16:00:00Z',
        'relatedsBackground': '#ffffff',
        'relatedsFormat': 'list',
        'relatedPosts': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'article1',
            'slug': 'related-article',
            'title': '相關文章',
            'ogDescription': '描述',
            'categorySet': <Map<String, dynamic>>[],
            'publishedDate': '2026-01-01T00:00:00Z',
            'isExternal': false,
          },
        ],
      };

      // Act
      final Topic topic = Topic.fromJson(json);

      // Assert
      expect(topic.id, equals('topic123'));
      expect(topic.slug, equals('test-topic'));
      expect(topic.title, equals('測試專題'));
      expect(topic.ogDescription, equals('專題描述'));
      expect(topic.heroImage, isNotNull);
      expect(topic.ogImage, isNotNull);
      expect(
        topic.publishedDate,
        equals(DateTime.parse('2026-01-28T16:00:00Z')),
      );
      expect(topic.relatedsBackground, equals('#ffffff'));
      expect(topic.relatedsFormat, equals('list'));
      expect(topic.relatedPosts, hasLength(1));
      expect(topic.relatedPosts?.first.title, equals('相關文章'));
    });

    test('should create Topic with minimal required fields', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '123',
        'slug': 'minimal-topic',
        'title': '最小專題',
        'publishedDate': '2026-01-01T00:00:00Z',
      };

      // Act
      final Topic topic = Topic.fromJson(json);

      // Assert
      expect(topic.id, equals('123'));
      expect(topic.title, equals('最小專題'));
      expect(topic.ogDescription, isNull);
      expect(topic.heroImage, isNull);
      expect(topic.ogImage, isNull);
      expect(topic.relatedsBackground, isNull);
      expect(topic.relatedsFormat, isNull);
      expect(topic.relatedPosts, isNull);
    });

    test('should convert Topic to JSON', () {
      // Arrange
      final Topic topic = Topic(
        id: '123',
        slug: 'test-topic',
        title: '測試專題',
        publishedDate: DateTime.parse('2026-01-01T00:00:00Z'),
        relatedPosts: <Article>[
          Article(
            id: 'article1',
            slug: 'test-article',
            title: '測試文章',
            ogDescription: '描述',
            categorySet: <CategorySet>[],
            publishedDate: DateTime.now(),
            isExternal: false,
          ),
        ],
      );

      // Act
      final Map<String, dynamic> json = topic.toJson();

      // Assert
      expect(json['id'], equals('123'));
      expect(json['title'], equals('測試專題'));
      expect(json['relatedPosts'], isA<List<dynamic>>());
    });

    test('should support equality comparison', () {
      // Arrange
      final DateTime now = DateTime.now();
      final Topic topic1 = Topic(
        id: '123',
        slug: 'test',
        title: '測試',
        publishedDate: now,
      );
      final Topic topic2 = Topic(
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
      final Topic topic = Topic(
        id: '123',
        slug: 'test',
        title: '原標題',
        publishedDate: DateTime.now(),
      );

      // Act
      final Topic updatedTopic = topic.copyWith(
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
