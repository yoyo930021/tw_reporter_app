// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Topic _$TopicFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Topic',
  json,
  ($checkedConvert) {
    final val = _Topic(
      id: $checkedConvert('id', (v) => v as String),
      slug: $checkedConvert('slug', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      publishedDate: $checkedConvert(
        'published_date',
        (v) => DateTime.parse(v as String),
      ),
      shortTitle: $checkedConvert('short_title', (v) => v as String?),
      ogDescription: $checkedConvert('og_description', (v) => v as String?),
      ogImage: $checkedConvert(
        'og_image',
        (v) => v == null ? null : HeroImage.fromJson(v as Map<String, dynamic>),
      ),
      leadingImage: $checkedConvert(
        'leading_image',
        (v) => v == null ? null : HeroImage.fromJson(v as Map<String, dynamic>),
      ),
      leadingImagePortrait: $checkedConvert(
        'leading_image_portrait',
        (v) => v == null ? null : HeroImage.fromJson(v as Map<String, dynamic>),
      ),
      relatedsBackground: $checkedConvert(
        'relateds_background',
        (v) => v as String?,
      ),
      relatedsFormat: $checkedConvert('relateds_format', (v) => v as String?),
      relateds: $checkedConvert(
        'relateds',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      full: $checkedConvert('full', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'publishedDate': 'published_date',
    'shortTitle': 'short_title',
    'ogDescription': 'og_description',
    'ogImage': 'og_image',
    'leadingImage': 'leading_image',
    'leadingImagePortrait': 'leading_image_portrait',
    'relatedsBackground': 'relateds_background',
    'relatedsFormat': 'relateds_format',
  },
);

Map<String, dynamic> _$TopicToJson(_Topic instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'published_date': instance.publishedDate.toIso8601String(),
  'short_title': instance.shortTitle,
  'og_description': instance.ogDescription,
  'og_image': instance.ogImage?.toJson(),
  'leading_image': instance.leadingImage?.toJson(),
  'leading_image_portrait': instance.leadingImagePortrait?.toJson(),
  'relateds_background': instance.relatedsBackground,
  'relateds_format': instance.relatedsFormat,
  'relateds': instance.relateds,
  'full': instance.full,
};
