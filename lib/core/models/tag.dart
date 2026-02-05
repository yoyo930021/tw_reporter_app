import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tw_reporter_app/core/models/category.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
sealed class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String key,
    required String name,
    int? latestOrder,
    Category? category,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}
