import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tw_reporter_app/core/models/image_size.dart';

part 'author.freezed.dart';
part 'author.g.dart';

@freezed
sealed class Author with _$Author {
  const factory Author({
    required String id,
    required String name,
    @JsonKey(name: 'job_title') String? jobTitle,
    String? email,
    String? bio,
    HeroImage? thumbnail,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Author;

  factory Author.fromJson(Map<String, dynamic> json) =>
      _$AuthorFromJson(json);
}
