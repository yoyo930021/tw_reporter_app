// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Author _$AuthorFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Author',
  json,
  ($checkedConvert) {
    final val = _Author(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      jobTitle: $checkedConvert('job_title', (v) => v as String?),
      email: $checkedConvert('email', (v) => v as String?),
      bio: $checkedConvert('bio', (v) => v as String?),
      thumbnail: $checkedConvert(
        'thumbnail',
        (v) => v == null ? null : HeroImage.fromJson(v as Map<String, dynamic>),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'jobTitle': 'job_title', 'updatedAt': 'updated_at'},
);

Map<String, dynamic> _$AuthorToJson(_Author instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'job_title': instance.jobTitle,
  'email': instance.email,
  'bio': instance.bio,
  'thumbnail': instance.thumbnail?.toJson(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
