// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Article _$ArticleFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Article', json, ($checkedConvert) {
      final val = _Article(
        id: $checkedConvert('id', (v) => v as String),
        slug: $checkedConvert('slug', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        subtitle: $checkedConvert('subtitle', (v) => v as String?),
        ogDescription: $checkedConvert('ogDescription', (v) => v as String),
        heroImage: $checkedConvert(
          'heroImage',
          (v) =>
              v == null ? null : HeroImage.fromJson(v as Map<String, dynamic>),
        ),
        ogImage: $checkedConvert(
          'ogImage',
          (v) =>
              v == null ? null : HeroImage.fromJson(v as Map<String, dynamic>),
        ),
        categorySet: $checkedConvert(
          'categorySet',
          (v) => (v as List<dynamic>)
              .map((e) => CategorySet.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        publishedDate: $checkedConvert(
          'publishedDate',
          (v) => DateTime.parse(v as String),
        ),
        isExternal: $checkedConvert('isExternal', (v) => v as bool),
        tags: $checkedConvert(
          'tags',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        style: $checkedConvert('style', (v) => v as String?),
        htmlContent: $checkedConvert('content', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'htmlContent': 'content'});

Map<String, dynamic> _$ArticleToJson(_Article instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'ogDescription': instance.ogDescription,
  'heroImage': instance.heroImage?.toJson(),
  'ogImage': instance.ogImage?.toJson(),
  'categorySet': instance.categorySet.map((e) => e.toJson()).toList(),
  'publishedDate': instance.publishedDate.toIso8601String(),
  'isExternal': instance.isExternal,
  'tags': instance.tags?.map((e) => e.toJson()).toList(),
  'style': instance.style,
  'content': instance.htmlContent,
};
