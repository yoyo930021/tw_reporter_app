import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tw_reporter_app/core/models/image_size.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

@freezed
sealed class Topic with _$Topic {
  const factory Topic({
    required String id,
    required String slug,
    required String title,
    @JsonKey(name: 'short_title') String? shortTitle,
    @JsonKey(name: 'og_description') String? ogDescription,
    @JsonKey(name: 'og_image') HeroImage? ogImage,
    @JsonKey(name: 'leading_image') HeroImage? leadingImage,
    @JsonKey(name: 'leading_image_portrait') HeroImage? leadingImagePortrait,
    @JsonKey(name: 'published_date') required DateTime publishedDate,
    @JsonKey(name: 'relateds_background') String? relatedsBackground,
    @JsonKey(name: 'relateds_format') String? relatedsFormat,
    // relateds 是文章 ID 陣列，不是完整的 Article 物件
    List<String>? relateds,
    bool? full,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
}
