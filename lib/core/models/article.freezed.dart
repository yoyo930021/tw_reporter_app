// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Article {

 String get id; String get slug; String get title; String? get subtitle; String get ogDescription; HeroImage? get heroImage; HeroImage? get ogImage; List<CategorySet> get categorySet; DateTime get publishedDate; bool get isExternal; List<Tag>? get tags; String? get style;@JsonKey(name: 'content') String? get htmlContent;
/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticleCopyWith<Article> get copyWith => _$ArticleCopyWithImpl<Article>(this as Article, _$identity);

  /// Serializes this Article to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Article&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.ogDescription, ogDescription) || other.ogDescription == ogDescription)&&(identical(other.heroImage, heroImage) || other.heroImage == heroImage)&&(identical(other.ogImage, ogImage) || other.ogImage == ogImage)&&const DeepCollectionEquality().equals(other.categorySet, categorySet)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate)&&(identical(other.isExternal, isExternal) || other.isExternal == isExternal)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.style, style) || other.style == style)&&(identical(other.htmlContent, htmlContent) || other.htmlContent == htmlContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,subtitle,ogDescription,heroImage,ogImage,const DeepCollectionEquality().hash(categorySet),publishedDate,isExternal,const DeepCollectionEquality().hash(tags),style,htmlContent);

@override
String toString() {
  return 'Article(id: $id, slug: $slug, title: $title, subtitle: $subtitle, ogDescription: $ogDescription, heroImage: $heroImage, ogImage: $ogImage, categorySet: $categorySet, publishedDate: $publishedDate, isExternal: $isExternal, tags: $tags, style: $style, htmlContent: $htmlContent)';
}


}

/// @nodoc
abstract mixin class $ArticleCopyWith<$Res>  {
  factory $ArticleCopyWith(Article value, $Res Function(Article) _then) = _$ArticleCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String title, String? subtitle, String ogDescription, HeroImage? heroImage, HeroImage? ogImage, List<CategorySet> categorySet, DateTime publishedDate, bool isExternal, List<Tag>? tags, String? style,@JsonKey(name: 'content') String? htmlContent
});


$HeroImageCopyWith<$Res>? get heroImage;$HeroImageCopyWith<$Res>? get ogImage;

}
/// @nodoc
class _$ArticleCopyWithImpl<$Res>
    implements $ArticleCopyWith<$Res> {
  _$ArticleCopyWithImpl(this._self, this._then);

  final Article _self;
  final $Res Function(Article) _then;

/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? subtitle = freezed,Object? ogDescription = null,Object? heroImage = freezed,Object? ogImage = freezed,Object? categorySet = null,Object? publishedDate = null,Object? isExternal = null,Object? tags = freezed,Object? style = freezed,Object? htmlContent = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,ogDescription: null == ogDescription ? _self.ogDescription : ogDescription // ignore: cast_nullable_to_non_nullable
as String,heroImage: freezed == heroImage ? _self.heroImage : heroImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,ogImage: freezed == ogImage ? _self.ogImage : ogImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,categorySet: null == categorySet ? _self.categorySet : categorySet // ignore: cast_nullable_to_non_nullable
as List<CategorySet>,publishedDate: null == publishedDate ? _self.publishedDate : publishedDate // ignore: cast_nullable_to_non_nullable
as DateTime,isExternal: null == isExternal ? _self.isExternal : isExternal // ignore: cast_nullable_to_non_nullable
as bool,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<Tag>?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String?,htmlContent: freezed == htmlContent ? _self.htmlContent : htmlContent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeroImageCopyWith<$Res>? get heroImage {
    if (_self.heroImage == null) {
    return null;
  }

  return $HeroImageCopyWith<$Res>(_self.heroImage!, (value) {
    return _then(_self.copyWith(heroImage: value));
  });
}/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeroImageCopyWith<$Res>? get ogImage {
    if (_self.ogImage == null) {
    return null;
  }

  return $HeroImageCopyWith<$Res>(_self.ogImage!, (value) {
    return _then(_self.copyWith(ogImage: value));
  });
}
}


/// Adds pattern-matching-related methods to [Article].
extension ArticlePatterns on Article {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Article value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Article() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Article value)  $default,){
final _that = this;
switch (_that) {
case _Article():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Article value)?  $default,){
final _that = this;
switch (_that) {
case _Article() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? subtitle,  String ogDescription,  HeroImage? heroImage,  HeroImage? ogImage,  List<CategorySet> categorySet,  DateTime publishedDate,  bool isExternal,  List<Tag>? tags,  String? style, @JsonKey(name: 'content')  String? htmlContent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Article() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.subtitle,_that.ogDescription,_that.heroImage,_that.ogImage,_that.categorySet,_that.publishedDate,_that.isExternal,_that.tags,_that.style,_that.htmlContent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? subtitle,  String ogDescription,  HeroImage? heroImage,  HeroImage? ogImage,  List<CategorySet> categorySet,  DateTime publishedDate,  bool isExternal,  List<Tag>? tags,  String? style, @JsonKey(name: 'content')  String? htmlContent)  $default,) {final _that = this;
switch (_that) {
case _Article():
return $default(_that.id,_that.slug,_that.title,_that.subtitle,_that.ogDescription,_that.heroImage,_that.ogImage,_that.categorySet,_that.publishedDate,_that.isExternal,_that.tags,_that.style,_that.htmlContent);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String title,  String? subtitle,  String ogDescription,  HeroImage? heroImage,  HeroImage? ogImage,  List<CategorySet> categorySet,  DateTime publishedDate,  bool isExternal,  List<Tag>? tags,  String? style, @JsonKey(name: 'content')  String? htmlContent)?  $default,) {final _that = this;
switch (_that) {
case _Article() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.subtitle,_that.ogDescription,_that.heroImage,_that.ogImage,_that.categorySet,_that.publishedDate,_that.isExternal,_that.tags,_that.style,_that.htmlContent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Article implements Article {
  const _Article({required this.id, required this.slug, required this.title, this.subtitle, required this.ogDescription, this.heroImage, this.ogImage, required final  List<CategorySet> categorySet, required this.publishedDate, required this.isExternal, final  List<Tag>? tags, this.style, @JsonKey(name: 'content') this.htmlContent}): _categorySet = categorySet,_tags = tags;
  factory _Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String title;
@override final  String? subtitle;
@override final  String ogDescription;
@override final  HeroImage? heroImage;
@override final  HeroImage? ogImage;
 final  List<CategorySet> _categorySet;
@override List<CategorySet> get categorySet {
  if (_categorySet is EqualUnmodifiableListView) return _categorySet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categorySet);
}

@override final  DateTime publishedDate;
@override final  bool isExternal;
 final  List<Tag>? _tags;
@override List<Tag>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? style;
@override@JsonKey(name: 'content') final  String? htmlContent;

/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArticleCopyWith<_Article> get copyWith => __$ArticleCopyWithImpl<_Article>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArticleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Article&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.ogDescription, ogDescription) || other.ogDescription == ogDescription)&&(identical(other.heroImage, heroImage) || other.heroImage == heroImage)&&(identical(other.ogImage, ogImage) || other.ogImage == ogImage)&&const DeepCollectionEquality().equals(other._categorySet, _categorySet)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate)&&(identical(other.isExternal, isExternal) || other.isExternal == isExternal)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.style, style) || other.style == style)&&(identical(other.htmlContent, htmlContent) || other.htmlContent == htmlContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,subtitle,ogDescription,heroImage,ogImage,const DeepCollectionEquality().hash(_categorySet),publishedDate,isExternal,const DeepCollectionEquality().hash(_tags),style,htmlContent);

@override
String toString() {
  return 'Article(id: $id, slug: $slug, title: $title, subtitle: $subtitle, ogDescription: $ogDescription, heroImage: $heroImage, ogImage: $ogImage, categorySet: $categorySet, publishedDate: $publishedDate, isExternal: $isExternal, tags: $tags, style: $style, htmlContent: $htmlContent)';
}


}

/// @nodoc
abstract mixin class _$ArticleCopyWith<$Res> implements $ArticleCopyWith<$Res> {
  factory _$ArticleCopyWith(_Article value, $Res Function(_Article) _then) = __$ArticleCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String title, String? subtitle, String ogDescription, HeroImage? heroImage, HeroImage? ogImage, List<CategorySet> categorySet, DateTime publishedDate, bool isExternal, List<Tag>? tags, String? style,@JsonKey(name: 'content') String? htmlContent
});


@override $HeroImageCopyWith<$Res>? get heroImage;@override $HeroImageCopyWith<$Res>? get ogImage;

}
/// @nodoc
class __$ArticleCopyWithImpl<$Res>
    implements _$ArticleCopyWith<$Res> {
  __$ArticleCopyWithImpl(this._self, this._then);

  final _Article _self;
  final $Res Function(_Article) _then;

/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? subtitle = freezed,Object? ogDescription = null,Object? heroImage = freezed,Object? ogImage = freezed,Object? categorySet = null,Object? publishedDate = null,Object? isExternal = null,Object? tags = freezed,Object? style = freezed,Object? htmlContent = freezed,}) {
  return _then(_Article(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,ogDescription: null == ogDescription ? _self.ogDescription : ogDescription // ignore: cast_nullable_to_non_nullable
as String,heroImage: freezed == heroImage ? _self.heroImage : heroImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,ogImage: freezed == ogImage ? _self.ogImage : ogImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,categorySet: null == categorySet ? _self._categorySet : categorySet // ignore: cast_nullable_to_non_nullable
as List<CategorySet>,publishedDate: null == publishedDate ? _self.publishedDate : publishedDate // ignore: cast_nullable_to_non_nullable
as DateTime,isExternal: null == isExternal ? _self.isExternal : isExternal // ignore: cast_nullable_to_non_nullable
as bool,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<Tag>?,style: freezed == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String?,htmlContent: freezed == htmlContent ? _self.htmlContent : htmlContent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeroImageCopyWith<$Res>? get heroImage {
    if (_self.heroImage == null) {
    return null;
  }

  return $HeroImageCopyWith<$Res>(_self.heroImage!, (value) {
    return _then(_self.copyWith(heroImage: value));
  });
}/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeroImageCopyWith<$Res>? get ogImage {
    if (_self.ogImage == null) {
    return null;
  }

  return $HeroImageCopyWith<$Res>(_self.ogImage!, (value) {
    return _then(_self.copyWith(ogImage: value));
  });
}
}

// dart format on
