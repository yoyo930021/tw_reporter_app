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

 String get id; String get slug; String get title;@JsonKey(name: 'published_date') DateTime get publishedDate;@JsonKey(name: 'short_title') String? get shortTitle;@JsonKey(name: 'og_description') String? get ogDescription;@JsonKey(name: 'og_image') HeroImage? get ogImage;@JsonKey(name: 'leading_image') HeroImage? get leadingImage;@JsonKey(name: 'leading_image_portrait') HeroImage? get leadingImagePortrait;@JsonKey(name: 'relateds_background') String? get relatedsBackground;@JsonKey(name: 'relateds_format') String? get relatedsFormat;// relateds 是文章 ID 陣列，不是完整的 Article 物件
 List<String>? get relateds; bool? get full;
/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopicCopyWith<Topic> get copyWith => _$TopicCopyWithImpl<Topic>(this as Topic, _$identity);

  /// Serializes this Topic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Topic&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate)&&(identical(other.shortTitle, shortTitle) || other.shortTitle == shortTitle)&&(identical(other.ogDescription, ogDescription) || other.ogDescription == ogDescription)&&(identical(other.ogImage, ogImage) || other.ogImage == ogImage)&&(identical(other.leadingImage, leadingImage) || other.leadingImage == leadingImage)&&(identical(other.leadingImagePortrait, leadingImagePortrait) || other.leadingImagePortrait == leadingImagePortrait)&&(identical(other.relatedsBackground, relatedsBackground) || other.relatedsBackground == relatedsBackground)&&(identical(other.relatedsFormat, relatedsFormat) || other.relatedsFormat == relatedsFormat)&&const DeepCollectionEquality().equals(other.relateds, relateds)&&(identical(other.full, full) || other.full == full));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,publishedDate,shortTitle,ogDescription,ogImage,leadingImage,leadingImagePortrait,relatedsBackground,relatedsFormat,const DeepCollectionEquality().hash(relateds),full);

@override
String toString() {
  return 'Topic(id: $id, slug: $slug, title: $title, publishedDate: $publishedDate, shortTitle: $shortTitle, ogDescription: $ogDescription, ogImage: $ogImage, leadingImage: $leadingImage, leadingImagePortrait: $leadingImagePortrait, relatedsBackground: $relatedsBackground, relatedsFormat: $relatedsFormat, relateds: $relateds, full: $full)';
}


}

/// @nodoc
abstract mixin class $TopicCopyWith<$Res>  {
  factory $TopicCopyWith(Topic value, $Res Function(Topic) _then) = _$TopicCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String title,@JsonKey(name: 'published_date') DateTime publishedDate,@JsonKey(name: 'short_title') String? shortTitle,@JsonKey(name: 'og_description') String? ogDescription,@JsonKey(name: 'og_image') HeroImage? ogImage,@JsonKey(name: 'leading_image') HeroImage? leadingImage,@JsonKey(name: 'leading_image_portrait') HeroImage? leadingImagePortrait,@JsonKey(name: 'relateds_background') String? relatedsBackground,@JsonKey(name: 'relateds_format') String? relatedsFormat, List<String>? relateds, bool? full
});


$HeroImageCopyWith<$Res>? get ogImage;$HeroImageCopyWith<$Res>? get leadingImage;$HeroImageCopyWith<$Res>? get leadingImagePortrait;

}
/// @nodoc
class _$TopicCopyWithImpl<$Res>
    implements $TopicCopyWith<$Res> {
  _$TopicCopyWithImpl(this._self, this._then);

  final Topic _self;
  final $Res Function(Topic) _then;

/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? publishedDate = null,Object? shortTitle = freezed,Object? ogDescription = freezed,Object? ogImage = freezed,Object? leadingImage = freezed,Object? leadingImagePortrait = freezed,Object? relatedsBackground = freezed,Object? relatedsFormat = freezed,Object? relateds = freezed,Object? full = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,publishedDate: null == publishedDate ? _self.publishedDate : publishedDate // ignore: cast_nullable_to_non_nullable
as DateTime,shortTitle: freezed == shortTitle ? _self.shortTitle : shortTitle // ignore: cast_nullable_to_non_nullable
as String?,ogDescription: freezed == ogDescription ? _self.ogDescription : ogDescription // ignore: cast_nullable_to_non_nullable
as String?,ogImage: freezed == ogImage ? _self.ogImage : ogImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,leadingImage: freezed == leadingImage ? _self.leadingImage : leadingImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,leadingImagePortrait: freezed == leadingImagePortrait ? _self.leadingImagePortrait : leadingImagePortrait // ignore: cast_nullable_to_non_nullable
as HeroImage?,relatedsBackground: freezed == relatedsBackground ? _self.relatedsBackground : relatedsBackground // ignore: cast_nullable_to_non_nullable
as String?,relatedsFormat: freezed == relatedsFormat ? _self.relatedsFormat : relatedsFormat // ignore: cast_nullable_to_non_nullable
as String?,relateds: freezed == relateds ? _self.relateds : relateds // ignore: cast_nullable_to_non_nullable
as List<String>?,full: freezed == full ? _self.full : full // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of Topic
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
}/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeroImageCopyWith<$Res>? get leadingImage {
    if (_self.leadingImage == null) {
    return null;
  }

  return $HeroImageCopyWith<$Res>(_self.leadingImage!, (value) {
    return _then(_self.copyWith(leadingImage: value));
  });
}/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeroImageCopyWith<$Res>? get leadingImagePortrait {
    if (_self.leadingImagePortrait == null) {
    return null;
  }

  return $HeroImageCopyWith<$Res>(_self.leadingImagePortrait!, (value) {
    return _then(_self.copyWith(leadingImagePortrait: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String title, @JsonKey(name: 'published_date')  DateTime publishedDate, @JsonKey(name: 'short_title')  String? shortTitle, @JsonKey(name: 'og_description')  String? ogDescription, @JsonKey(name: 'og_image')  HeroImage? ogImage, @JsonKey(name: 'leading_image')  HeroImage? leadingImage, @JsonKey(name: 'leading_image_portrait')  HeroImage? leadingImagePortrait, @JsonKey(name: 'relateds_background')  String? relatedsBackground, @JsonKey(name: 'relateds_format')  String? relatedsFormat,  List<String>? relateds,  bool? full)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Topic() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.publishedDate,_that.shortTitle,_that.ogDescription,_that.ogImage,_that.leadingImage,_that.leadingImagePortrait,_that.relatedsBackground,_that.relatedsFormat,_that.relateds,_that.full);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String title, @JsonKey(name: 'published_date')  DateTime publishedDate, @JsonKey(name: 'short_title')  String? shortTitle, @JsonKey(name: 'og_description')  String? ogDescription, @JsonKey(name: 'og_image')  HeroImage? ogImage, @JsonKey(name: 'leading_image')  HeroImage? leadingImage, @JsonKey(name: 'leading_image_portrait')  HeroImage? leadingImagePortrait, @JsonKey(name: 'relateds_background')  String? relatedsBackground, @JsonKey(name: 'relateds_format')  String? relatedsFormat,  List<String>? relateds,  bool? full)  $default,) {final _that = this;
switch (_that) {
case _Topic():
return $default(_that.id,_that.slug,_that.title,_that.publishedDate,_that.shortTitle,_that.ogDescription,_that.ogImage,_that.leadingImage,_that.leadingImagePortrait,_that.relatedsBackground,_that.relatedsFormat,_that.relateds,_that.full);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String title, @JsonKey(name: 'published_date')  DateTime publishedDate, @JsonKey(name: 'short_title')  String? shortTitle, @JsonKey(name: 'og_description')  String? ogDescription, @JsonKey(name: 'og_image')  HeroImage? ogImage, @JsonKey(name: 'leading_image')  HeroImage? leadingImage, @JsonKey(name: 'leading_image_portrait')  HeroImage? leadingImagePortrait, @JsonKey(name: 'relateds_background')  String? relatedsBackground, @JsonKey(name: 'relateds_format')  String? relatedsFormat,  List<String>? relateds,  bool? full)?  $default,) {final _that = this;
switch (_that) {
case _Topic() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.publishedDate,_that.shortTitle,_that.ogDescription,_that.ogImage,_that.leadingImage,_that.leadingImagePortrait,_that.relatedsBackground,_that.relatedsFormat,_that.relateds,_that.full);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Topic implements Topic {
  const _Topic({required this.id, required this.slug, required this.title, @JsonKey(name: 'published_date') required this.publishedDate, @JsonKey(name: 'short_title') this.shortTitle, @JsonKey(name: 'og_description') this.ogDescription, @JsonKey(name: 'og_image') this.ogImage, @JsonKey(name: 'leading_image') this.leadingImage, @JsonKey(name: 'leading_image_portrait') this.leadingImagePortrait, @JsonKey(name: 'relateds_background') this.relatedsBackground, @JsonKey(name: 'relateds_format') this.relatedsFormat, final  List<String>? relateds, this.full}): _relateds = relateds;
  factory _Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String title;
@override@JsonKey(name: 'published_date') final  DateTime publishedDate;
@override@JsonKey(name: 'short_title') final  String? shortTitle;
@override@JsonKey(name: 'og_description') final  String? ogDescription;
@override@JsonKey(name: 'og_image') final  HeroImage? ogImage;
@override@JsonKey(name: 'leading_image') final  HeroImage? leadingImage;
@override@JsonKey(name: 'leading_image_portrait') final  HeroImage? leadingImagePortrait;
@override@JsonKey(name: 'relateds_background') final  String? relatedsBackground;
@override@JsonKey(name: 'relateds_format') final  String? relatedsFormat;
// relateds 是文章 ID 陣列，不是完整的 Article 物件
 final  List<String>? _relateds;
// relateds 是文章 ID 陣列，不是完整的 Article 物件
@override List<String>? get relateds {
  final value = _relateds;
  if (value == null) return null;
  if (_relateds is EqualUnmodifiableListView) return _relateds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool? full;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Topic&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate)&&(identical(other.shortTitle, shortTitle) || other.shortTitle == shortTitle)&&(identical(other.ogDescription, ogDescription) || other.ogDescription == ogDescription)&&(identical(other.ogImage, ogImage) || other.ogImage == ogImage)&&(identical(other.leadingImage, leadingImage) || other.leadingImage == leadingImage)&&(identical(other.leadingImagePortrait, leadingImagePortrait) || other.leadingImagePortrait == leadingImagePortrait)&&(identical(other.relatedsBackground, relatedsBackground) || other.relatedsBackground == relatedsBackground)&&(identical(other.relatedsFormat, relatedsFormat) || other.relatedsFormat == relatedsFormat)&&const DeepCollectionEquality().equals(other._relateds, _relateds)&&(identical(other.full, full) || other.full == full));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,publishedDate,shortTitle,ogDescription,ogImage,leadingImage,leadingImagePortrait,relatedsBackground,relatedsFormat,const DeepCollectionEquality().hash(_relateds),full);

@override
String toString() {
  return 'Topic(id: $id, slug: $slug, title: $title, publishedDate: $publishedDate, shortTitle: $shortTitle, ogDescription: $ogDescription, ogImage: $ogImage, leadingImage: $leadingImage, leadingImagePortrait: $leadingImagePortrait, relatedsBackground: $relatedsBackground, relatedsFormat: $relatedsFormat, relateds: $relateds, full: $full)';
}


}

/// @nodoc
abstract mixin class _$TopicCopyWith<$Res> implements $TopicCopyWith<$Res> {
  factory _$TopicCopyWith(_Topic value, $Res Function(_Topic) _then) = __$TopicCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String title,@JsonKey(name: 'published_date') DateTime publishedDate,@JsonKey(name: 'short_title') String? shortTitle,@JsonKey(name: 'og_description') String? ogDescription,@JsonKey(name: 'og_image') HeroImage? ogImage,@JsonKey(name: 'leading_image') HeroImage? leadingImage,@JsonKey(name: 'leading_image_portrait') HeroImage? leadingImagePortrait,@JsonKey(name: 'relateds_background') String? relatedsBackground,@JsonKey(name: 'relateds_format') String? relatedsFormat, List<String>? relateds, bool? full
});


@override $HeroImageCopyWith<$Res>? get ogImage;@override $HeroImageCopyWith<$Res>? get leadingImage;@override $HeroImageCopyWith<$Res>? get leadingImagePortrait;

}
/// @nodoc
class __$TopicCopyWithImpl<$Res>
    implements _$TopicCopyWith<$Res> {
  __$TopicCopyWithImpl(this._self, this._then);

  final _Topic _self;
  final $Res Function(_Topic) _then;

/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? publishedDate = null,Object? shortTitle = freezed,Object? ogDescription = freezed,Object? ogImage = freezed,Object? leadingImage = freezed,Object? leadingImagePortrait = freezed,Object? relatedsBackground = freezed,Object? relatedsFormat = freezed,Object? relateds = freezed,Object? full = freezed,}) {
  return _then(_Topic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,publishedDate: null == publishedDate ? _self.publishedDate : publishedDate // ignore: cast_nullable_to_non_nullable
as DateTime,shortTitle: freezed == shortTitle ? _self.shortTitle : shortTitle // ignore: cast_nullable_to_non_nullable
as String?,ogDescription: freezed == ogDescription ? _self.ogDescription : ogDescription // ignore: cast_nullable_to_non_nullable
as String?,ogImage: freezed == ogImage ? _self.ogImage : ogImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,leadingImage: freezed == leadingImage ? _self.leadingImage : leadingImage // ignore: cast_nullable_to_non_nullable
as HeroImage?,leadingImagePortrait: freezed == leadingImagePortrait ? _self.leadingImagePortrait : leadingImagePortrait // ignore: cast_nullable_to_non_nullable
as HeroImage?,relatedsBackground: freezed == relatedsBackground ? _self.relatedsBackground : relatedsBackground // ignore: cast_nullable_to_non_nullable
as String?,relatedsFormat: freezed == relatedsFormat ? _self.relatedsFormat : relatedsFormat // ignore: cast_nullable_to_non_nullable
as String?,relateds: freezed == relateds ? _self._relateds : relateds // ignore: cast_nullable_to_non_nullable
as List<String>?,full: freezed == full ? _self.full : full // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of Topic
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
}/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeroImageCopyWith<$Res>? get leadingImage {
    if (_self.leadingImage == null) {
    return null;
  }

  return $HeroImageCopyWith<$Res>(_self.leadingImage!, (value) {
    return _then(_self.copyWith(leadingImage: value));
  });
}/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeroImageCopyWith<$Res>? get leadingImagePortrait {
    if (_self.leadingImagePortrait == null) {
    return null;
  }

  return $HeroImageCopyWith<$Res>(_self.leadingImagePortrait!, (value) {
    return _then(_self.copyWith(leadingImagePortrait: value));
  });
}
}

// dart format on
