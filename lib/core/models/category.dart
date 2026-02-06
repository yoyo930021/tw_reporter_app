import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
sealed class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    @JsonKey(name: 'sort_order') int? sortOrder,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

@freezed
sealed class Subcategory with _$Subcategory {
  const factory Subcategory({
    required String id,
    required String key,
    required String name,
    @JsonKey(name: 'latest_order') int? latestOrder,
  }) = _Subcategory;

  factory Subcategory.fromJson(Map<String, dynamic> json) =>
      _$SubcategoryFromJson(json);
}

@freezed
sealed class CategorySet with _$CategorySet {
  const factory CategorySet({
    Category? category,
    Subcategory? subcategory,
  }) = _CategorySet;

  factory CategorySet.fromJson(Map<String, dynamic> json) =>
      _$CategorySetFromJson(json);
}
