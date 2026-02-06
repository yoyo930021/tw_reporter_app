// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Author _$AuthorFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Author', json, ($checkedConvert) {
      final val = _Author(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        jobTitle: $checkedConvert('job_title', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'jobTitle': 'job_title'});

Map<String, dynamic> _$AuthorToJson(_Author instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'job_title': instance.jobTitle,
};
