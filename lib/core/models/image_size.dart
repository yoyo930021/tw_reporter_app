import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_size.freezed.dart';
part 'image_size.g.dart';

@freezed
sealed class ImageSize with _$ImageSize {
  const factory ImageSize({
    required String url,
    required int width,
    required int height,
  }) = _ImageSize;

  factory ImageSize.fromJson(Map<String, dynamic> json) =>
      _$ImageSizeFromJson(json);
}

@freezed
sealed class ResizedTargets with _$ResizedTargets {
  const factory ResizedTargets({
    ImageSize? tiny, // 150x100
    ImageSize? w400, // 400x267
    ImageSize? mobile, // 800x533
    ImageSize? tablet, // 1200x800
    ImageSize? desktop, // 2000x1333
  }) = _ResizedTargets;

  factory ResizedTargets.fromJson(Map<String, dynamic> json) =>
      _$ResizedTargetsFromJson(json);
}

@freezed
sealed class HeroImage with _$HeroImage {
  const factory HeroImage({
    required String id,
    required String filetype,
    String? description,
    @JsonKey(name: 'resized_targets') required ResizedTargets resizedTargets,
  }) = _HeroImage;

  factory HeroImage.fromJson(Map<String, dynamic> json) =>
      _$HeroImageFromJson(json);
}
