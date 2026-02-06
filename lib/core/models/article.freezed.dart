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

 String get id; String get slug; String get title; String? get subtitle;@JsonKey(name: 'og_description') String get ogDescription;@JsonKey(name: 'hero_image') HeroImage? get heroImage;@JsonKey(name: 'og_image') HeroImage? get ogImage;@JsonKey(name: 'category_set') List<CategorySet> get categorySet;@JsonKey(name: 'published_date') DateTime get publishedDate;@JsonKey(name: 'is_external') bool get isExternal; List<Tag>? get tags; String? get style;@JsonKey(name: 'content') Map<String, dynamic>? get content; List<Author>? get writers; List<Author>? get photographers; List<Author>? get designers;@JsonKey(name: 'extend_byline') String? get extendByline; Map<String, dynamic>? get brief; List<String>? get relateds;@JsonKey(name: 'updated_at') DateTime? get updatedAt; String? get copyright;@JsonKey(name: 'leading_image_description') String? get leadingImageDescription;
/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticleCopyWith<Article> get copyWith => _$ArticleCopyWithImpl<Article>(this as Article, _$identity);

  /// Serializes this Article to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Article&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.ogDescription, ogDescription) || other.ogDescription == ogDescription)&&(identical(other.heroImage, heroImage) || other.heroImage == heroImage)&&(identical(other.ogImage, ogImage) || other.ogImage == ogImage)&&const DeepCollectionEquality().equals(other.categorySet, categorySet)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate)&&(identical(other.isExternal, isExternal) || other.isExternal == isExternal)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.style, style) || other.style == style)&&const DeepCollectionEquality().equals(other.content, content)&&const DeepCollectionEquality().equals(other.writers, writers)&&const DeepCollectionEquality().equals(other.photographers, photographers)&&const DeepCollectionEquality().equals(other.designers, designers)&&(identical(other.extendByline, extendByline) || other.extendByline == extendByline)&&const DeepCollectionEquality().equals(other.brief, brief)&&const DeepCollectionEquality().equals(other.relateds, relateds)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.copyright, copyright) || other.copyright == copyright)&&(identical(other.leadingImageDescription, leadingImageDescription) || other.leadingImageDescription == leadingImageDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,slug,title,subtitle,ogDescription,heroImage,ogImage,const DeepCollectionEquality().hash(categorySet),publishedDate,isExternal,const DeepCollectionEquality().hash(tags),style,const DeepCollectionEquality().hash(content),const DeepCollectionEquality().hash(writers),const DeepCollectionEquality().hash(photographers),const DeepCollectionEquality().hash(designers),extendByline,const DeepCollectionEquality().hash(brief),const DeepCollectionEquality().hash(relateds),updatedAt,copyright,leadingImageDescription]);

@override
String toString() {
  return 'Article(id: $id, slug: $slug, title: $title, subtitle: $subtitle, ogDescription: $ogDescription, heroImage: $heroImage, ogImage: $ogImage, categorySet: $categorySet, publishedDate: $publishedDate, isExternal: $isExternal, tags: $tags, style: $style, content: $content, writers: $writers, photographers: $photographers, designers: $designers, extendByline: $extendByline, brief: $brief, relateds: $relateds, updatedAt: $updatedAt, copyright: $copyright, leadingImageDescription: $leadingImageDescription)';
}


}

/// @nodoc
abstract mixin class $ArticleCopyWith<$Res>  {
  factory $ArticleCopyWith(Article value, $Res Function(Article) _then) = _$ArticleCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String title, String? subtitle,@JsonKey(name: 'og_description') String ogDescription,@JsonKey(name: 'hero_image') HeroImage? heroImage,@JsonKey(name: 'og_image') HeroImage? ogImage,@JsonKey(name: 'category_set') List<CategorySet> categorySet,@JsonKey(name: 'published_date') DateTime publishedDate,@JsonKey(name: 'is_external') bool isExternal, List<Tag>? tags, String? style,@JsonKey(name: 'content') Map<String, dynamic>? content, List<Author>? writers, List<Author>? photographers, List<Author>? designers,@JsonKey(name: 'extend_byline') String? extendByline, Map<String, dynamic>? brief, List<String>? relateds,@JsonKey(name: 'updated_at') DateTime? updatedAt, String? copyright,@JsonKey(name: 'leading_image_description') String? leadingImageDescription
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? subtitle = freezed,Object? ogDescription = null,Object? heroImage = freezed,Object? ogImage = freezed,Object? categorySet = null,Object? publishedDate = null,Object? isExternal = null,Object? tags = freezed,Object? style = freezed,Object? content = freezed,Object? writers = freezed,Object? photographers = freezed,Object? designers = freezed,Object? extendByline = freezed,Object? brief = freezed,Object? relateds = freezed,Object? updatedAt = freezed,Object? copyright = freezed,Object? leadingImageDescription = freezed,}) {
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
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,writers: freezed == writers ? _self.writers : writers // ignore: cast_nullable_to_non_nullable
as List<Author>?,photographers: freezed == photographers ? _self.photographers : photographers // ignore: cast_nullable_to_non_nullable
as List<Author>?,designers: freezed == designers ? _self.designers : designers // ignore: cast_nullable_to_non_nullable
as List<Author>?,extendByline: freezed == extendByline ? _self.extendByline : extendByline // ignore: cast_nullable_to_non_nullable
as String?,brief: freezed == brief ? _self.brief : brief // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,relateds: freezed == relateds ? _self.relateds : relateds // ignore: cast_nullable_to_non_nullable
as List<String>?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,copyright: freezed == copyright ? _self.copyright : copyright // ignore: cast_nullable_to_non_nullable
as String?,leadingImageDescription: freezed == leadingImageDescription ? _self.leadingImageDescription : leadingImageDescription // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? subtitle, @JsonKey(name: 'og_description')  String ogDescription, @JsonKey(name: 'hero_image')  HeroImage? heroImage, @JsonKey(name: 'og_image')  HeroImage? ogImage, @JsonKey(name: 'category_set')  List<CategorySet> categorySet, @JsonKey(name: 'published_date')  DateTime publishedDate, @JsonKey(name: 'is_external')  bool isExternal,  List<Tag>? tags,  String? style, @JsonKey(name: 'content')  Map<String, dynamic>? content,  List<Author>? writers,  List<Author>? photographers,  List<Author>? designers, @JsonKey(name: 'extend_byline')  String? extendByline,  Map<String, dynamic>? brief,  List<String>? relateds, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  String? copyright, @JsonKey(name: 'leading_image_description')  String? leadingImageDescription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Article() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.subtitle,_that.ogDescription,_that.heroImage,_that.ogImage,_that.categorySet,_that.publishedDate,_that.isExternal,_that.tags,_that.style,_that.content,_that.writers,_that.photographers,_that.designers,_that.extendByline,_that.brief,_that.relateds,_that.updatedAt,_that.copyright,_that.leadingImageDescription);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? subtitle, @JsonKey(name: 'og_description')  String ogDescription, @JsonKey(name: 'hero_image')  HeroImage? heroImage, @JsonKey(name: 'og_image')  HeroImage? ogImage, @JsonKey(name: 'category_set')  List<CategorySet> categorySet, @JsonKey(name: 'published_date')  DateTime publishedDate, @JsonKey(name: 'is_external')  bool isExternal,  List<Tag>? tags,  String? style, @JsonKey(name: 'content')  Map<String, dynamic>? content,  List<Author>? writers,  List<Author>? photographers,  List<Author>? designers, @JsonKey(name: 'extend_byline')  String? extendByline,  Map<String, dynamic>? brief,  List<String>? relateds, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  String? copyright, @JsonKey(name: 'leading_image_description')  String? leadingImageDescription)  $default,) {final _that = this;
switch (_that) {
case _Article():
return $default(_that.id,_that.slug,_that.title,_that.subtitle,_that.ogDescription,_that.heroImage,_that.ogImage,_that.categorySet,_that.publishedDate,_that.isExternal,_that.tags,_that.style,_that.content,_that.writers,_that.photographers,_that.designers,_that.extendByline,_that.brief,_that.relateds,_that.updatedAt,_that.copyright,_that.leadingImageDescription);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String title,  String? subtitle, @JsonKey(name: 'og_description')  String ogDescription, @JsonKey(name: 'hero_image')  HeroImage? heroImage, @JsonKey(name: 'og_image')  HeroImage? ogImage, @JsonKey(name: 'category_set')  List<CategorySet> categorySet, @JsonKey(name: 'published_date')  DateTime publishedDate, @JsonKey(name: 'is_external')  bool isExternal,  List<Tag>? tags,  String? style, @JsonKey(name: 'content')  Map<String, dynamic>? content,  List<Author>? writers,  List<Author>? photographers,  List<Author>? designers, @JsonKey(name: 'extend_byline')  String? extendByline,  Map<String, dynamic>? brief,  List<String>? relateds, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  String? copyright, @JsonKey(name: 'leading_image_description')  String? leadingImageDescription)?  $default,) {final _that = this;
switch (_that) {
case _Article() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.subtitle,_that.ogDescription,_that.heroImage,_that.ogImage,_that.categorySet,_that.publishedDate,_that.isExternal,_that.tags,_that.style,_that.content,_that.writers,_that.photographers,_that.designers,_that.extendByline,_that.brief,_that.relateds,_that.updatedAt,_that.copyright,_that.leadingImageDescription);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Article implements Article {
  const _Article({required this.id, required this.slug, required this.title, this.subtitle, @JsonKey(name: 'og_description') required this.ogDescription, @JsonKey(name: 'hero_image') this.heroImage, @JsonKey(name: 'og_image') this.ogImage, @JsonKey(name: 'category_set') required final  List<CategorySet> categorySet, @JsonKey(name: 'published_date') required this.publishedDate, @JsonKey(name: 'is_external') required this.isExternal, final  List<Tag>? tags, this.style, @JsonKey(name: 'content') final  Map<String, dynamic>? content, final  List<Author>? writers, final  List<Author>? photographers, final  List<Author>? designers, @JsonKey(name: 'extend_byline') this.extendByline, final  Map<String, dynamic>? brief, final  List<String>? relateds, @JsonKey(name: 'updated_at') this.updatedAt, this.copyright, @JsonKey(name: 'leading_image_description') this.leadingImageDescription}): _categorySet = categorySet,_tags = tags,_content = content,_writers = writers,_photographers = photographers,_designers = designers,_brief = brief,_relateds = relateds;
  factory _Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String title;
@override final  String? subtitle;
@override@JsonKey(name: 'og_description') final  String ogDescription;
@override@JsonKey(name: 'hero_image') final  HeroImage? heroImage;
@override@JsonKey(name: 'og_image') final  HeroImage? ogImage;
 final  List<CategorySet> _categorySet;
@override@JsonKey(name: 'category_set') List<CategorySet> get categorySet {
  if (_categorySet is EqualUnmodifiableListView) return _categorySet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categorySet);
}

@override@JsonKey(name: 'published_date') final  DateTime publishedDate;
@override@JsonKey(name: 'is_external') final  bool isExternal;
 final  List<Tag>? _tags;
@override List<Tag>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? style;
 final  Map<String, dynamic>? _content;
@override@JsonKey(name: 'content') Map<String, dynamic>? get content {
  final value = _content;
  if (value == null) return null;
  if (_content is EqualUnmodifiableMapView) return _content;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<Author>? _writers;
@override List<Author>? get writers {
  final value = _writers;
  if (value == null) return null;
  if (_writers is EqualUnmodifiableListView) return _writers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Author>? _photographers;
@override List<Author>? get photographers {
  final value = _photographers;
  if (value == null) return null;
  if (_photographers is EqualUnmodifiableListView) return _photographers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Author>? _designers;
@override List<Author>? get designers {
  final value = _designers;
  if (value == null) return null;
  if (_designers is EqualUnmodifiableListView) return _designers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'extend_byline') final  String? extendByline;
 final  Map<String, dynamic>? _brief;
@override Map<String, dynamic>? get brief {
  final value = _brief;
  if (value == null) return null;
  if (_brief is EqualUnmodifiableMapView) return _brief;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _relateds;
@override List<String>? get relateds {
  final value = _relateds;
  if (value == null) return null;
  if (_relateds is EqualUnmodifiableListView) return _relateds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override final  String? copyright;
@override@JsonKey(name: 'leading_image_description') final  String? leadingImageDescription;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Article&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.ogDescription, ogDescription) || other.ogDescription == ogDescription)&&(identical(other.heroImage, heroImage) || other.heroImage == heroImage)&&(identical(other.ogImage, ogImage) || other.ogImage == ogImage)&&const DeepCollectionEquality().equals(other._categorySet, _categorySet)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate)&&(identical(other.isExternal, isExternal) || other.isExternal == isExternal)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.style, style) || other.style == style)&&const DeepCollectionEquality().equals(other._content, _content)&&const DeepCollectionEquality().equals(other._writers, _writers)&&const DeepCollectionEquality().equals(other._photographers, _photographers)&&const DeepCollectionEquality().equals(other._designers, _designers)&&(identical(other.extendByline, extendByline) || other.extendByline == extendByline)&&const DeepCollectionEquality().equals(other._brief, _brief)&&const DeepCollectionEquality().equals(other._relateds, _relateds)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.copyright, copyright) || other.copyright == copyright)&&(identical(other.leadingImageDescription, leadingImageDescription) || other.leadingImageDescription == leadingImageDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,slug,title,subtitle,ogDescription,heroImage,ogImage,const DeepCollectionEquality().hash(_categorySet),publishedDate,isExternal,const DeepCollectionEquality().hash(_tags),style,const DeepCollectionEquality().hash(_content),const DeepCollectionEquality().hash(_writers),const DeepCollectionEquality().hash(_photographers),const DeepCollectionEquality().hash(_designers),extendByline,const DeepCollectionEquality().hash(_brief),const DeepCollectionEquality().hash(_relateds),updatedAt,copyright,leadingImageDescription]);

@override
String toString() {
  return 'Article(id: $id, slug: $slug, title: $title, subtitle: $subtitle, ogDescription: $ogDescription, heroImage: $heroImage, ogImage: $ogImage, categorySet: $categorySet, publishedDate: $publishedDate, isExternal: $isExternal, tags: $tags, style: $style, content: $content, writers: $writers, photographers: $photographers, designers: $designers, extendByline: $extendByline, brief: $brief, relateds: $relateds, updatedAt: $updatedAt, copyright: $copyright, leadingImageDescription: $leadingImageDescription)';
}


}

/// @nodoc
abstract mixin class _$ArticleCopyWith<$Res> implements $ArticleCopyWith<$Res> {
  factory _$ArticleCopyWith(_Article value, $Res Function(_Article) _then) = __$ArticleCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String title, String? subtitle,@JsonKey(name: 'og_description') String ogDescription,@JsonKey(name: 'hero_image') HeroImage? heroImage,@JsonKey(name: 'og_image') HeroImage? ogImage,@JsonKey(name: 'category_set') List<CategorySet> categorySet,@JsonKey(name: 'published_date') DateTime publishedDate,@JsonKey(name: 'is_external') bool isExternal, List<Tag>? tags, String? style,@JsonKey(name: 'content') Map<String, dynamic>? content, List<Author>? writers, List<Author>? photographers, List<Author>? designers,@JsonKey(name: 'extend_byline') String? extendByline, Map<String, dynamic>? brief, List<String>? relateds,@JsonKey(name: 'updated_at') DateTime? updatedAt, String? copyright,@JsonKey(name: 'leading_image_description') String? leadingImageDescription
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? subtitle = freezed,Object? ogDescription = null,Object? heroImage = freezed,Object? ogImage = freezed,Object? categorySet = null,Object? publishedDate = null,Object? isExternal = null,Object? tags = freezed,Object? style = freezed,Object? content = freezed,Object? writers = freezed,Object? photographers = freezed,Object? designers = freezed,Object? extendByline = freezed,Object? brief = freezed,Object? relateds = freezed,Object? updatedAt = freezed,Object? copyright = freezed,Object? leadingImageDescription = freezed,}) {
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
as String?,content: freezed == content ? _self._content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,writers: freezed == writers ? _self._writers : writers // ignore: cast_nullable_to_non_nullable
as List<Author>?,photographers: freezed == photographers ? _self._photographers : photographers // ignore: cast_nullable_to_non_nullable
as List<Author>?,designers: freezed == designers ? _self._designers : designers // ignore: cast_nullable_to_non_nullable
as List<Author>?,extendByline: freezed == extendByline ? _self.extendByline : extendByline // ignore: cast_nullable_to_non_nullable
as String?,brief: freezed == brief ? _self._brief : brief // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,relateds: freezed == relateds ? _self._relateds : relateds // ignore: cast_nullable_to_non_nullable
as List<String>?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,copyright: freezed == copyright ? _self.copyright : copyright // ignore: cast_nullable_to_non_nullable
as String?,leadingImageDescription: freezed == leadingImageDescription ? _self.leadingImageDescription : leadingImageDescription // ignore: cast_nullable_to_non_nullable
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
