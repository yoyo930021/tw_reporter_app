import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tw_reporter_app/core/models/author.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/core/models/image_size.dart';
import 'package:tw_reporter_app/core/models/tag.dart';

part 'article.freezed.dart';
part 'article.g.dart';

@freezed
sealed class Article with _$Article {
  const factory Article({
    required String id,
    required String slug,
    required String title,
    String? subtitle,
    @JsonKey(name: 'og_description') required String ogDescription,
    @JsonKey(name: 'hero_image') HeroImage? heroImage,
    @JsonKey(name: 'og_image') HeroImage? ogImage,
    @JsonKey(name: 'category_set') required List<CategorySet> categorySet,
    @JsonKey(name: 'published_date') required DateTime publishedDate,
    @JsonKey(name: 'is_external') required bool isExternal,
    List<Tag>? tags,
    String? style,
    @JsonKey(name: 'content') Map<String, dynamic>? content,
    List<Author>? writers,
    List<Author>? photographers,
    List<Author>? designers,
    @JsonKey(name: 'extend_byline') String? extendByline,
    Map<String, dynamic>? brief,
    List<String>? relateds,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    String? copyright,
    @JsonKey(name: 'leading_image_description') String? leadingImageDescription,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
}
