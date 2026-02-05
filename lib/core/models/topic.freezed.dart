// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Topic {

 String get id; String get slug; String get title; String? get ogDescription; HeroImage? get heroImage; HeroImage? get ogImage; DateTime get publishedDate; String? get relatedsBackground; String? get relatedsFormat; List<Article>? get relatedPosts;
/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopicCopyWith<Topic> get copyWith => _$TopicCopyWithImpl<Topic>(this as Topic, _$identity);

  /// Serializes this Topic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Topic&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.ogDescription, ogDescription) || other.ogDescription == ogDescription)&&(identical(other.heroImage, heroImage) || other.heroImage == heroImage)&&(identical(other.ogImage, ogImage) || other.ogImage == ogImage)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate)&&(identical(other.relatedsBackground, relatedsBackground) || other.relatedsBackground == relatedsBackground)&&(identical(other.relatedsFormat, relatedsFormat) || other.relatedsFormat == relatedsFormat)&&const DeepCollectionEquality().equals(other.relatedPosts, relatedPosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,ogDescription,heroImage,ogImage,publishedDate,relatedsBackground,relatedsFormat,const DeepCollectionEquality().hash(relatedPosts));

@override
String toString() {
  return 'Topic(id: $id, slug: $slug, title: $title, ogDescription: $ogDescription, heroImage: $heroImage, ogImage: $ogImage, publishedDate: $publishedDate, relatedsBackground: $relatedsBackground, relatedsFormat: $relatedsFormat, relatedPosts: $relatedPosts)';
}


}

/// @nodoc
abstract mixin class $TopicCopyWith<$Res>  {
  factory $TopicCopyWith(Topic value, $Res Function(Topic) _then) = _$TopicCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String title, String? ogDescription, HeroImage? heroImage, HeroImage? ogImage, DateTime publishedDate, String? relatedsBackground, String? relatedsFormat, List<Article>? relatedPosts
});


$HeroImageCopyWith<$Res>? get heroImage;$HeroImageCopyWith<$Res>? get ogImage;

}
/// @nodoc
class _$TopicCopyWithImpl<$Res>
    implements $TopicCopyWith<$Res> {
  _$TopicCopyWithImpl(this._self, this._then);

  final Topic _self;
  final $Res Function(Topic) _then;

/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? ogDescription = freezed,Object? heroImage = freezed,Object? ogImage = freezed,Object? publishedDate = null,Object? relatedsBackground = freezed,Object? relatedsFormat = freezed,Object? relatedPosts = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,ogDescription: freezed == ogDescription ? _self.ogDescription : ogDescription // ignore: cast_nullable_to_non_nullable
as String?,heroImage: freezed == heroImage ? _self.heroImage : heroImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,ogImage: freezed == ogImage ? _self.ogImage : ogImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,publishedDate: null == publishedDate ? _self.publishedDate : publishedDate // ignore: cast_nullable_to_non_nullable
as DateTime,relatedsBackground: freezed == relatedsBackground ? _self.relatedsBackground : relatedsBackground // ignore: cast_nullable_to_non_nullable
as String?,relatedsFormat: freezed == relatedsFormat ? _self.relatedsFormat : relatedsFormat // ignore: cast_nullable_to_non_nullable
as String?,relatedPosts: freezed == relatedPosts ? _self.relatedPosts : relatedPosts // ignore: cast_nullable_to_non_nullable
as List<Article>?,
  ));
}
/// Create a copy of Topic
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
}/// Create a copy of Topic
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


/// Adds pattern-matching-related methods to [Topic].
extension TopicPatterns on Topic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Topic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Topic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Topic value)  $default,){
final _that = this;
switch (_that) {
case _Topic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Topic value)?  $default,){
final _that = this;
switch (_that) {
case _Topic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? ogDescription,  HeroImage? heroImage,  HeroImage? ogImage,  DateTime publishedDate,  String? relatedsBackground,  String? relatedsFormat,  List<Article>? relatedPosts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Topic() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.ogDescription,_that.heroImage,_that.ogImage,_that.publishedDate,_that.relatedsBackground,_that.relatedsFormat,_that.relatedPosts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? ogDescription,  HeroImage? heroImage,  HeroImage? ogImage,  DateTime publishedDate,  String? relatedsBackground,  String? relatedsFormat,  List<Article>? relatedPosts)  $default,) {final _that = this;
switch (_that) {
case _Topic():
return $default(_that.id,_that.slug,_that.title,_that.ogDescription,_that.heroImage,_that.ogImage,_that.publishedDate,_that.relatedsBackground,_that.relatedsFormat,_that.relatedPosts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String title,  String? ogDescription,  HeroImage? heroImage,  HeroImage? ogImage,  DateTime publishedDate,  String? relatedsBackground,  String? relatedsFormat,  List<Article>? relatedPosts)?  $default,) {final _that = this;
switch (_that) {
case _Topic() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.ogDescription,_that.heroImage,_that.ogImage,_that.publishedDate,_that.relatedsBackground,_that.relatedsFormat,_that.relatedPosts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Topic implements Topic {
  const _Topic({required this.id, required this.slug, required this.title, this.ogDescription, this.heroImage, this.ogImage, required this.publishedDate, this.relatedsBackground, this.relatedsFormat, final  List<Article>? relatedPosts}): _relatedPosts = relatedPosts;
  factory _Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String title;
@override final  String? ogDescription;
@override final  HeroImage? heroImage;
@override final  HeroImage? ogImage;
@override final  DateTime publishedDate;
@override final  String? relatedsBackground;
@override final  String? relatedsFormat;
 final  List<Article>? _relatedPosts;
@override List<Article>? get relatedPosts {
  final value = _relatedPosts;
  if (value == null) return null;
  if (_relatedPosts is EqualUnmodifiableListView) return _relatedPosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopicCopyWith<_Topic> get copyWith => __$TopicCopyWithImpl<_Topic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Topic&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.ogDescription, ogDescription) || other.ogDescription == ogDescription)&&(identical(other.heroImage, heroImage) || other.heroImage == heroImage)&&(identical(other.ogImage, ogImage) || other.ogImage == ogImage)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate)&&(identical(other.relatedsBackground, relatedsBackground) || other.relatedsBackground == relatedsBackground)&&(identical(other.relatedsFormat, relatedsFormat) || other.relatedsFormat == relatedsFormat)&&const DeepCollectionEquality().equals(other._relatedPosts, _relatedPosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,ogDescription,heroImage,ogImage,publishedDate,relatedsBackground,relatedsFormat,const DeepCollectionEquality().hash(_relatedPosts));

@override
String toString() {
  return 'Topic(id: $id, slug: $slug, title: $title, ogDescription: $ogDescription, heroImage: $heroImage, ogImage: $ogImage, publishedDate: $publishedDate, relatedsBackground: $relatedsBackground, relatedsFormat: $relatedsFormat, relatedPosts: $relatedPosts)';
}


}

/// @nodoc
abstract mixin class _$TopicCopyWith<$Res> implements $TopicCopyWith<$Res> {
  factory _$TopicCopyWith(_Topic value, $Res Function(_Topic) _then) = __$TopicCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String title, String? ogDescription, HeroImage? heroImage, HeroImage? ogImage, DateTime publishedDate, String? relatedsBackground, String? relatedsFormat, List<Article>? relatedPosts
});


@override $HeroImageCopyWith<$Res>? get heroImage;@override $HeroImageCopyWith<$Res>? get ogImage;

}
/// @nodoc
class __$TopicCopyWithImpl<$Res>
    implements _$TopicCopyWith<$Res> {
  __$TopicCopyWithImpl(this._self, this._then);

  final _Topic _self;
  final $Res Function(_Topic) _then;

/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? ogDescription = freezed,Object? heroImage = freezed,Object? ogImage = freezed,Object? publishedDate = null,Object? relatedsBackground = freezed,Object? relatedsFormat = freezed,Object? relatedPosts = freezed,}) {
  return _then(_Topic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,ogDescription: freezed == ogDescription ? _self.ogDescription : ogDescription // ignore: cast_nullable_to_non_nullable
as String?,heroImage: freezed == heroImage ? _self.heroImage : heroImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,ogImage: freezed == ogImage ? _self.ogImage : ogImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,publishedDate: null == publishedDate ? _self.publishedDate : publishedDate // ignore: cast_nullable_to_non_nullable
as DateTime,relatedsBackground: freezed == relatedsBackground ? _self.relatedsBackground : relatedsBackground // ignore: cast_nullable_to_non_nullable
as String?,relatedsFormat: freezed == relatedsFormat ? _self.relatedsFormat : relatedsFormat // ignore: cast_nullable_to_non_nullable
as String?,relatedPosts: freezed == relatedPosts ? _self._relatedPosts : relatedPosts // ignore: cast_nullable_to_non_nullable
as List<Article>?,
  ));
}

/// Create a copy of Topic
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
}/// Create a copy of Topic
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
