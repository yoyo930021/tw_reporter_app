import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/image_size.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

@freezed
sealed class Topic with _$Topic {
  const factory Topic({
    required String id,
    required String slug,
    required String title,
    String? ogDescription,
    HeroImage? heroImage,
    HeroImage? ogImage,
    required DateTime publishedDate,
    String? relatedsBackground,
    String? relatedsFormat,
    List<Article>? relatedPosts,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
}
