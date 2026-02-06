// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tag _$TagFromJson(Map<String, dynamic> json) => $checkedCreate('_Tag', json, (
  $checkedConvert,
) {
  final val = _Tag(
    id: $checkedConvert('id', (v) => v as String),
    key: $checkedConvert('key', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    latestOrder: $checkedConvert('latest_order', (v) => (v as num?)?.toInt()),
    category: $checkedConvert(
      'category',
      (v) => v == null ? null : Category.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
}, fieldKeyMap: const {'latestOrder': 'latest_order'});

Map<String, dynamic> _$TagToJson(_Tag instance) => <String, dynamic>{
  'id': instance.id,
  'key': instance.key,
  'name': instance.name,
  'latest_order': instance.latestOrder,
  'category': instance.category?.toJson(),
};
