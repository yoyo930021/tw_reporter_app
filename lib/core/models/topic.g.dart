// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Topic _$TopicFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Topic', json, ($checkedConvert) {
      final val = _Topic(
        id: $checkedConvert('id', (v) => v as String),
        slug: $checkedConvert('slug', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        ogDescription: $checkedConvert('ogDescription', (v) => v as String?),
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
        publishedDate: $checkedConvert(
          'publishedDate',
          (v) => DateTime.parse(v as String),
        ),
        relatedsBackground: $checkedConvert(
          'relatedsBackground',
          (v) => v as String?,
        ),
        relatedsFormat: $checkedConvert('relatedsFormat', (v) => v as String?),
        relatedPosts: $checkedConvert(
          'relatedPosts',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Article.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TopicToJson(_Topic instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'ogDescription': instance.ogDescription,
  'heroImage': instance.heroImage?.toJson(),
  'ogImage': instance.ogImage?.toJson(),
  'publishedDate': instance.publishedDate.toIso8601String(),
  'relatedsBackground': instance.relatedsBackground,
  'relatedsFormat': instance.relatedsFormat,
  'relatedPosts': instance.relatedPosts?.map((e) => e.toJson()).toList(),
};
