// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Article _$ArticleFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Article',
  json,
  ($checkedConvert) {
    final val = _Article(
      id: $checkedConvert('id', (v) => v as String),
      slug: $checkedConvert('slug', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      subtitle: $checkedConvert('subtitle', (v) => v as String?),
      ogDescription: $checkedConvert('og_description', (v) => v as String),
      heroImage: $checkedConvert(
        'hero_image',
        (v) => v == null ? null : HeroImage.fromJson(v as Map<String, dynamic>),
      ),
      ogImage: $checkedConvert(
        'og_image',
        (v) => v == null ? null : HeroImage.fromJson(v as Map<String, dynamic>),
      ),
      categorySet: $checkedConvert(
        'category_set',
        (v) => (v as List<dynamic>)
            .map((e) => CategorySet.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      publishedDate: $checkedConvert(
        'published_date',
        (v) => DateTime.parse(v as String),
      ),
      isExternal: $checkedConvert('is_external', (v) => v as bool),
      tags: $checkedConvert(
        'tags',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      style: $checkedConvert('style', (v) => v as String?),
      content: $checkedConvert('content', (v) => v as Map<String, dynamic>?),
      writers: $checkedConvert(
        'writers',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Author.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      photographers: $checkedConvert(
        'photographers',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Author.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      designers: $checkedConvert(
        'designers',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Author.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      extendByline: $checkedConvert('extend_byline', (v) => v as String?),
      brief: $checkedConvert('brief', (v) => v as Map<String, dynamic>?),
      relateds: $checkedConvert(
        'relateds',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      copyright: $checkedConvert('copyright', (v) => v as String?),
      leadingImageDescription: $checkedConvert(
        'leading_image_description',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'ogDescription': 'og_description',
    'heroImage': 'hero_image',
    'ogImage': 'og_image',
    'categorySet': 'category_set',
    'publishedDate': 'published_date',
    'isExternal': 'is_external',
    'extendByline': 'extend_byline',
    'updatedAt': 'updated_at',
    'leadingImageDescription': 'leading_image_description',
  },
);

Map<String, dynamic> _$ArticleToJson(_Article instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'og_description': instance.ogDescription,
  'hero_image': instance.heroImage?.toJson(),
  'og_image': instance.ogImage?.toJson(),
  'category_set': instance.categorySet.map((e) => e.toJson()).toList(),
  'published_date': instance.publishedDate.toIso8601String(),
  'is_external': instance.isExternal,
  'tags': instance.tags?.map((e) => e.toJson()).toList(),
  'style': instance.style,
  'content': instance.content,
  'writers': instance.writers?.map((e) => e.toJson()).toList(),
  'photographers': instance.photographers?.map((e) => e.toJson()).toList(),
  'designers': instance.designers?.map((e) => e.toJson()).toList(),
  'extend_byline': instance.extendByline,
  'brief': instance.brief,
  'relateds': instance.relateds,
  'updated_at': instance.updatedAt?.toIso8601String(),
  'copyright': instance.copyright,
  'leading_image_description': instance.leadingImageDescription,
};
