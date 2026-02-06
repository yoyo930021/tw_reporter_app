import 'package:freezed_annotation/freezed_annotation.dart';
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
    @JsonKey(name: 'content') String? htmlContent,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
}
