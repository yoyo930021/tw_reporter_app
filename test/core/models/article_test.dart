import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/core/models/image_size.dart';
import 'package:tw_reporter_app/core/models/tag.dart';

void main() {
  group('Article', () {
    test('should create Article from JSON with all fields', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '69787503f7e6ab070044a7ae',
        'slug': 'test-article',
        'title': '測試文章標題',
        'subtitle': '測試副標題',
        'og_description': '這是測試描述',
        'hero_image': <String, dynamic>{
          'id': 'img123',
          'filetype': 'image/jpeg',
          'description': '主圖描述',
          'resized_targets': <String, dynamic>{
            'mobile': <String, dynamic>{
              'url': 'https://example.com/image.jpg',
              'width': 800,
              'height': 533,
            },
          },
        },
        'og_image': <String, dynamic>{
          'id': 'img456',
          'filetype': 'image/jpeg',
          'resized_targets': <String, dynamic>{},
        },
        'category_set': <Map<String, dynamic>>[
          <String, dynamic>{
            'category': <String, dynamic>{
              'id': 'cat123',
              'name': '國際兩岸',
              'sort_order': 17,
            },
            'subcategory': <String, dynamic>{
              'id': 'subcat123',
              'key': 'europe',
              'name': '歐洲',
            },
          },
        ],
        'published_date': '2026-01-28T16:00:00Z',
        'is_external': false,
        'tags': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'tag123',
            'key': 'china',
            'name': '中國',
            'latestOrder': 10,
          },
        ],
        'style': 'article:v2:default',
        'content': '<p>文章內容</p>',
      };

      // Act
      final Article article = Article.fromJson(json);

      // Assert
      expect(article.id, equals('69787503f7e6ab070044a7ae'));
      expect(article.slug, equals('test-article'));
      expect(article.title, equals('測試文章標題'));
      expect(article.subtitle, equals('測試副標題'));
      expect(article.ogDescription, equals('這是測試描述'));
      expect(article.heroImage, isNotNull);
      expect(article.heroImage?.id, equals('img123'));
      expect(article.ogImage, isNotNull);
      expect(article.categorySet, hasLength(1));
      expect(article.categorySet.first.category.name, equals('國際兩岸'));
      expect(
        article.publishedDate,
        equals(DateTime.parse('2026-01-28T16:00:00Z')),
      );
      expect(article.isExternal, isFalse);
      expect(article.tags, hasLength(1));
      expect(article.tags?.first.name, equals('中國'));
      expect(article.style, equals('article:v2:default'));
      expect(article.htmlContent, equals('<p>文章內容</p>'));
    });

    test('should create Article with minimal required fields', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '123',
        'slug': 'minimal-article',
        'title': '最小文章',
        'og_description': '描述',
        'category_set': <Map<String, dynamic>>[],
        'published_date': '2026-01-01T00:00:00Z',
        'is_external': false,
      };

      // Act
      final Article article = Article.fromJson(json);

      // Assert
      expect(article.id, equals('123'));
      expect(article.title, equals('最小文章'));
      expect(article.subtitle, isNull);
      expect(article.heroImage, isNull);
      expect(article.ogImage, isNull);
      expect(article.categorySet, isEmpty);
      expect(article.tags, isNull);
      expect(article.style, isNull);
      expect(article.htmlContent, isNull);
    });

    test('should convert Article to JSON', () {
      // Arrange
      final Article article = Article(
        id: '123',
        slug: 'test-slug',
        title: '測試標題',
        ogDescription: '測試描述',
        categorySet: <CategorySet>[
          CategorySet(
            category: Category(
              id: 'cat1',
              name: '分類',
            ),
          ),
        ],
        publishedDate: DateTime.parse('2026-01-01T00:00:00Z'),
        isExternal: false,
        tags: <Tag>[
          Tag(
            id: 'tag1',
            key: 'test',
            name: '測試標籤',
          ),
        ],
      );

      // Act
      final Map<String, dynamic> json = article.toJson();

      // Assert
      expect(json['id'], equals('123'));
      expect(json['slug'], equals('test-slug'));
      expect(json['title'], equals('測試標題'));
      expect(json['categorySet'], isA<List<dynamic>>());
      expect(json['tags'], isA<List<dynamic>>());
    });

    test('should support copyWith for immutability', () {
      // Arrange
      final Article article = Article(
        id: '123',
        slug: 'test',
        title: '原標題',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime.now(),
        isExternal: false,
      );

      // Act
      final Article updatedArticle = article.copyWith(
        title: '新標題',
        subtitle: '新副標題',
      );

      // Assert
      expect(article.title, equals('原標題'));
      expect(updatedArticle.title, equals('新標題'));
      expect(updatedArticle.subtitle, equals('新副標題'));
      expect(updatedArticle.id, equals(article.id));
    });

    test('should support equality comparison', () {
      // Arrange
      final DateTime now = DateTime.now();
      final Article article1 = Article(
        id: '123',
        slug: 'test',
        title: '測試',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: now,
        isExternal: false,
      );
      final Article article2 = Article(
        id: '123',
        slug: 'test',
        title: '測試',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: now,
        isExternal: false,
      );

      // Assert
      expect(article1, equals(article2));
      expect(article1.hashCode, equals(article2.hashCode));
    });

    test('should handle external articles', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '123',
        'slug': 'external-link',
        'title': '外部連結',
        'ogDescription': '描述',
        'categorySet': <Map<String, dynamic>>[],
        'publishedDate': '2026-01-01T00:00:00Z',
        'isExternal': true,
      };

      // Act
      final Article article = Article.fromJson(json);

      // Assert
      expect(article.isExternal, isTrue);
    });
  });
}
