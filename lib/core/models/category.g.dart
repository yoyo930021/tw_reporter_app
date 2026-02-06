// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Category', json, ($checkedConvert) {
      final val = _Category(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        sortOrder: $checkedConvert('sort_order', (v) => (v as num?)?.toInt()),
      );
      return val;
    }, fieldKeyMap: const {'sortOrder': 'sort_order'});

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sort_order': instance.sortOrder,
};

_Subcategory _$SubcategoryFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Subcategory',
  json,
  ($checkedConvert) {
    final val = _Subcategory(
      id: $checkedConvert('id', (v) => v as String),
      key: $checkedConvert('key', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      latestOrder: $checkedConvert('latest_order', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {'latestOrder': 'latest_order'},
);

Map<String, dynamic> _$SubcategoryToJson(_Subcategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'name': instance.name,
      'latest_order': instance.latestOrder,
    };

_CategorySet _$CategorySetFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_CategorySet',
  json,
  ($checkedConvert) {
    final val = _CategorySet(
      category: $checkedConvert(
        'category',
        (v) => Category.fromJson(v as Map<String, dynamic>),
      ),
      subcategory: $checkedConvert(
        'subcategory',
        (v) =>
            v == null ? null : Subcategory.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$CategorySetToJson(_CategorySet instance) =>
    <String, dynamic>{
      'category': instance.category.toJson(),
      'subcategory': instance.subcategory?.toJson(),
    };
