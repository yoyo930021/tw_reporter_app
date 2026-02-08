import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/author.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/core/models/tag.dart';

void main() {
  group('Article', () {
    test('should create Article from JSON with all fields', () {
      // Arrange
      final json = <String, dynamic>{
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
        'content': <String, dynamic>{
          'api_data': <Map<String, dynamic>>[
            <String, dynamic>{
              'type': 'unstyled',
              'content': <String>['文章內容'],
              'id': '1',
              'styles': <String, dynamic>{},
              'alignment': 'center',
            },
          ],
        },
      };

      // Act
      final article = Article.fromJson(json);

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
      expect(article.categorySet.first.category?.name, equals('國際兩岸'));
      expect(
        article.publishedDate,
        equals(DateTime.parse('2026-01-28T16:00:00Z')),
      );
      expect(article.isExternal, isFalse);
      expect(article.tags, hasLength(1));
      expect(article.tags?.first.name, equals('中國'));
      expect(article.style, equals('article:v2:default'));
      expect(article.content, isNotNull);
      expect(article.content!['api_data'], isNotNull);
    });

    test('should create Article with minimal required fields', () {
      // Arrange
      final json = <String, dynamic>{
        'id': '123',
        'slug': 'minimal-article',
        'title': '最小文章',
        'og_description': '描述',
        'category_set': <Map<String, dynamic>>[],
        'published_date': '2026-01-01T00:00:00Z',
        'is_external': false,
      };

      // Act
      final article = Article.fromJson(json);

      // Assert
      expect(article.id, equals('123'));
      expect(article.title, equals('最小文章'));
      expect(article.subtitle, isNull);
      expect(article.heroImage, isNull);
      expect(article.ogImage, isNull);
      expect(article.categorySet, isEmpty);
      expect(article.tags, isNull);
      expect(article.style, isNull);
      expect(article.content, isNull);
    });

    test('should convert Article to JSON', () {
      // Arrange
      final article = Article(
        id: '123',
        slug: 'test-slug',
        title: '測試標題',
        ogDescription: '測試描述',
        categorySet: <CategorySet>[
          const CategorySet(
            category: Category(
              id: 'cat1',
              name: '分類',
            ),
          ),
        ],
        publishedDate: DateTime.parse('2026-01-01T00:00:00Z'),
        isExternal: false,
        tags: <Tag>[
          const Tag(
            id: 'tag1',
            key: 'test',
            name: '測試標籤',
          ),
        ],
      );

      // Act
      final json = article.toJson();

      // Assert
      expect(json['id'], equals('123'));
      expect(json['slug'], equals('test-slug'));
      expect(json['title'], equals('測試標題'));
      expect(json['category_set'], isA<List<dynamic>>());
      expect(json['tags'], isA<List<dynamic>>());
    });

    test('should support copyWith for immutability', () {
      // Arrange
      final article = Article(
        id: '123',
        slug: 'test',
        title: '原標題',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: DateTime.now(),
        isExternal: false,
      );

      // Act
      final updatedArticle = article.copyWith(
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
      final now = DateTime.now();
      final article1 = Article(
        id: '123',
        slug: 'test',
        title: '測試',
        ogDescription: '描述',
        categorySet: <CategorySet>[],
        publishedDate: now,
        isExternal: false,
      );
      final article2 = Article(
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
      final json = <String, dynamic>{
        'id': '123',
        'slug': 'external-link',
        'title': '外部連結',
        'og_description': '描述',
        'category_set': <Map<String, dynamic>>[],
        'published_date': '2026-01-01T00:00:00Z',
        'is_external': true,
      };

      // Act
      final article = Article.fromJson(json);

      // Assert
      expect(article.isExternal, isTrue);
    });

    test('should parse new fields (writers, brief, relateds, etc.)', () {
      // Arrange
      final json = <String, dynamic>{
        'id': '1',
        'slug': 'full-article',
        'title': '完整文章',
        'og_description': '描述',
        'category_set': <Map<String, dynamic>>[],
        'published_date': '2026-01-01T00:00:00Z',
        'is_external': false,
        'writers': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'w1',
            'name': '張三',
            'job_title': '記者',
          },
        ],
        'photographers': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'p1',
            'name': '李四',
          },
        ],
        'designers': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'd1',
            'name': '王五',
            'job_title': '設計師',
          },
        ],
        'extend_byline': '共同採訪/方君竹',
        'brief': <String, dynamic>{
          'api_data': <Map<String, dynamic>>[
            <String, dynamic>{
              'type': 'unstyled',
              'content': <String>['前言內容'],
            },
          ],
        },
        'relateds': <String>['id1', 'id2', 'id3'],
        'updated_at': '2026-01-15T00:00:00Z',
        'copyright': 'Creative-Commons',
        'leading_image_description': '這是主圖描述',
      };

      // Act
      final article = Article.fromJson(json);

      // Assert
      expect(article.writers, hasLength(1));
      expect(article.writers!.first.name, equals('張三'));
      expect(article.writers!.first.jobTitle, equals('記者'));
      expect(article.photographers, hasLength(1));
      expect(article.photographers!.first.name, equals('李四'));
      expect(article.designers, hasLength(1));
      expect(article.designers!.first.name, equals('王五'));
      expect(article.extendByline, equals('共同採訪/方君竹'));
      expect(article.brief, isNotNull);
      expect(article.relateds, equals(<String>['id1', 'id2', 'id3']));
      expect(
        article.updatedAt,
        equals(DateTime.parse('2026-01-15T00:00:00Z')),
      );
      expect(article.copyright, equals('Creative-Commons'));
      expect(article.leadingImageDescription, equals('這是主圖描述'));
    });

    test('should create Author from JSON', () {
      final json = <String, dynamic>{
        'id': 'a1',
        'name': '測試作者',
        'job_title': '記者',
      };

      final author = Author.fromJson(json);

      expect(author.id, equals('a1'));
      expect(author.name, equals('測試作者'));
      expect(author.jobTitle, equals('記者'));
    });
  });
}
