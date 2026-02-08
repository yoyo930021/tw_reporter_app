// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_size.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImageSize _$ImageSizeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ImageSize', json, ($checkedConvert) {
      final val = _ImageSize(
        url: $checkedConvert('url', (v) => v as String),
        width: $checkedConvert('width', (v) => (v as num).toInt()),
        height: $checkedConvert('height', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ImageSizeToJson(_ImageSize instance) =>
    <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };

_ResizedTargets _$ResizedTargetsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ResizedTargets', json, ($checkedConvert) {
      final val = _ResizedTargets(
        tiny: $checkedConvert(
          'tiny',
          (v) =>
              v == null ? null : ImageSize.fromJson(v as Map<String, dynamic>),
        ),
        w400: $checkedConvert(
          'w400',
          (v) =>
              v == null ? null : ImageSize.fromJson(v as Map<String, dynamic>),
        ),
        mobile: $checkedConvert(
          'mobile',
          (v) =>
              v == null ? null : ImageSize.fromJson(v as Map<String, dynamic>),
        ),
        tablet: $checkedConvert(
          'tablet',
          (v) =>
              v == null ? null : ImageSize.fromJson(v as Map<String, dynamic>),
        ),
        desktop: $checkedConvert(
          'desktop',
          (v) =>
              v == null ? null : ImageSize.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ResizedTargetsToJson(_ResizedTargets instance) =>
    <String, dynamic>{
      'tiny': instance.tiny?.toJson(),
      'w400': instance.w400?.toJson(),
      'mobile': instance.mobile?.toJson(),
      'tablet': instance.tablet?.toJson(),
      'desktop': instance.desktop?.toJson(),
    };

_HeroImage _$HeroImageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_HeroImage', json, ($checkedConvert) {
      final val = _HeroImage(
        id: $checkedConvert('id', (v) => v as String),
        filetype: $checkedConvert('filetype', (v) => v as String),
        resizedTargets: $checkedConvert(
          'resized_targets',
          (v) => ResizedTargets.fromJson(v as Map<String, dynamic>),
        ),
        description: $checkedConvert('description', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'resizedTargets': 'resized_targets'});

Map<String, dynamic> _$HeroImageToJson(_HeroImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filetype': instance.filetype,
      'resized_targets': instance.resizedTargets.toJson(),
      'description': instance.description,
    };
