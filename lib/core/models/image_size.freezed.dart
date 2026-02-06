// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_size.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageSize {

 String get url; int get width; int get height;
/// Create a copy of ImageSize
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<ImageSize> get copyWith => _$ImageSizeCopyWithImpl<ImageSize>(this as ImageSize, _$identity);

  /// Serializes this ImageSize to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageSize&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height);

@override
String toString() {
  return 'ImageSize(url: $url, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class $ImageSizeCopyWith<$Res>  {
  factory $ImageSizeCopyWith(ImageSize value, $Res Function(ImageSize) _then) = _$ImageSizeCopyWithImpl;
@useResult
$Res call({
 String url, int width, int height
});




}
/// @nodoc
class _$ImageSizeCopyWithImpl<$Res>
    implements $ImageSizeCopyWith<$Res> {
  _$ImageSizeCopyWithImpl(this._self, this._then);

  final ImageSize _self;
  final $Res Function(ImageSize) _then;

/// Create a copy of ImageSize
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? width = null,Object? height = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageSize].
extension ImageSizePatterns on ImageSize {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageSize value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageSize() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageSize value)  $default,){
final _that = this;
switch (_that) {
case _ImageSize():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageSize value)?  $default,){
final _that = this;
switch (_that) {
case _ImageSize() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  int width,  int height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageSize() when $default != null:
return $default(_that.url,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  int width,  int height)  $default,) {final _that = this;
switch (_that) {
case _ImageSize():
return $default(_that.url,_that.width,_that.height);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  int width,  int height)?  $default,) {final _that = this;
switch (_that) {
case _ImageSize() when $default != null:
return $default(_that.url,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageSize implements ImageSize {
  const _ImageSize({required this.url, required this.width, required this.height});
  factory _ImageSize.fromJson(Map<String, dynamic> json) => _$ImageSizeFromJson(json);

@override final  String url;
@override final  int width;
@override final  int height;

/// Create a copy of ImageSize
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageSizeCopyWith<_ImageSize> get copyWith => __$ImageSizeCopyWithImpl<_ImageSize>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageSizeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageSize&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height);

@override
String toString() {
  return 'ImageSize(url: $url, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$ImageSizeCopyWith<$Res> implements $ImageSizeCopyWith<$Res> {
  factory _$ImageSizeCopyWith(_ImageSize value, $Res Function(_ImageSize) _then) = __$ImageSizeCopyWithImpl;
@override @useResult
$Res call({
 String url, int width, int height
});




}
/// @nodoc
class __$ImageSizeCopyWithImpl<$Res>
    implements _$ImageSizeCopyWith<$Res> {
  __$ImageSizeCopyWithImpl(this._self, this._then);

  final _ImageSize _self;
  final $Res Function(_ImageSize) _then;

/// Create a copy of ImageSize
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? width = null,Object? height = null,}) {
  return _then(_ImageSize(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ResizedTargets {

 ImageSize? get tiny;// 150x100
 ImageSize? get w400;// 400x267
 ImageSize? get mobile;// 800x533
 ImageSize? get tablet;// 1200x800
 ImageSize? get desktop;
/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResizedTargetsCopyWith<ResizedTargets> get copyWith => _$ResizedTargetsCopyWithImpl<ResizedTargets>(this as ResizedTargets, _$identity);

  /// Serializes this ResizedTargets to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResizedTargets&&(identical(other.tiny, tiny) || other.tiny == tiny)&&(identical(other.w400, w400) || other.w400 == w400)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.tablet, tablet) || other.tablet == tablet)&&(identical(other.desktop, desktop) || other.desktop == desktop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tiny,w400,mobile,tablet,desktop);

@override
String toString() {
  return 'ResizedTargets(tiny: $tiny, w400: $w400, mobile: $mobile, tablet: $tablet, desktop: $desktop)';
}


}

/// @nodoc
abstract mixin class $ResizedTargetsCopyWith<$Res>  {
  factory $ResizedTargetsCopyWith(ResizedTargets value, $Res Function(ResizedTargets) _then) = _$ResizedTargetsCopyWithImpl;
@useResult
$Res call({
 ImageSize? tiny, ImageSize? w400, ImageSize? mobile, ImageSize? tablet, ImageSize? desktop
});


$ImageSizeCopyWith<$Res>? get tiny;$ImageSizeCopyWith<$Res>? get w400;$ImageSizeCopyWith<$Res>? get mobile;$ImageSizeCopyWith<$Res>? get tablet;$ImageSizeCopyWith<$Res>? get desktop;

}
/// @nodoc
class _$ResizedTargetsCopyWithImpl<$Res>
    implements $ResizedTargetsCopyWith<$Res> {
  _$ResizedTargetsCopyWithImpl(this._self, this._then);

  final ResizedTargets _self;
  final $Res Function(ResizedTargets) _then;

/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tiny = freezed,Object? w400 = freezed,Object? mobile = freezed,Object? tablet = freezed,Object? desktop = freezed,}) {
  return _then(_self.copyWith(
tiny: freezed == tiny ? _self.tiny : tiny // ignore: cast_nullable_to_non_nullable
as ImageSize?,w400: freezed == w400 ? _self.w400 : w400 // ignore: cast_nullable_to_non_nullable
as ImageSize?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as ImageSize?,tablet: freezed == tablet ? _self.tablet : tablet // ignore: cast_nullable_to_non_nullable
as ImageSize?,desktop: freezed == desktop ? _self.desktop : desktop // ignore: cast_nullable_to_non_nullable
as ImageSize?,
  ));
}
/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<$Res>? get tiny {
    if (_self.tiny == null) {
    return null;
  }

  return $ImageSizeCopyWith<$Res>(_self.tiny!, (value) {
    return _then(_self.copyWith(tiny: value));
  });
}/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<$Res>? get w400 {
    if (_self.w400 == null) {
    return null;
  }

  return $ImageSizeCopyWith<$Res>(_self.w400!, (value) {
    return _then(_self.copyWith(w400: value));
  });
}/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<$Res>? get mobile {
    if (_self.mobile == null) {
    return null;
  }

  return $ImageSizeCopyWith<$Res>(_self.mobile!, (value) {
    return _then(_self.copyWith(mobile: value));
  });
}/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<$Res>? get tablet {
    if (_self.tablet == null) {
    return null;
  }

  return $ImageSizeCopyWith<$Res>(_self.tablet!, (value) {
    return _then(_self.copyWith(tablet: value));
  });
}/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<$Res>? get desktop {
    if (_self.desktop == null) {
    return null;
  }

  return $ImageSizeCopyWith<$Res>(_self.desktop!, (value) {
    return _then(_self.copyWith(desktop: value));
  });
}
}


/// Adds pattern-matching-related methods to [ResizedTargets].
extension ResizedTargetsPatterns on ResizedTargets {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResizedTargets value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResizedTargets() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResizedTargets value)  $default,){
final _that = this;
switch (_that) {
case _ResizedTargets():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResizedTargets value)?  $default,){
final _that = this;
switch (_that) {
case _ResizedTargets() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ImageSize? tiny,  ImageSize? w400,  ImageSize? mobile,  ImageSize? tablet,  ImageSize? desktop)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResizedTargets() when $default != null:
return $default(_that.tiny,_that.w400,_that.mobile,_that.tablet,_that.desktop);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ImageSize? tiny,  ImageSize? w400,  ImageSize? mobile,  ImageSize? tablet,  ImageSize? desktop)  $default,) {final _that = this;
switch (_that) {
case _ResizedTargets():
return $default(_that.tiny,_that.w400,_that.mobile,_that.tablet,_that.desktop);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ImageSize? tiny,  ImageSize? w400,  ImageSize? mobile,  ImageSize? tablet,  ImageSize? desktop)?  $default,) {final _that = this;
switch (_that) {
case _ResizedTargets() when $default != null:
return $default(_that.tiny,_that.w400,_that.mobile,_that.tablet,_that.desktop);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResizedTargets implements ResizedTargets {
  const _ResizedTargets({this.tiny, this.w400, this.mobile, this.tablet, this.desktop});
  factory _ResizedTargets.fromJson(Map<String, dynamic> json) => _$ResizedTargetsFromJson(json);

@override final  ImageSize? tiny;
// 150x100
@override final  ImageSize? w400;
// 400x267
@override final  ImageSize? mobile;
// 800x533
@override final  ImageSize? tablet;
// 1200x800
@override final  ImageSize? desktop;

/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResizedTargetsCopyWith<_ResizedTargets> get copyWith => __$ResizedTargetsCopyWithImpl<_ResizedTargets>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResizedTargetsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResizedTargets&&(identical(other.tiny, tiny) || other.tiny == tiny)&&(identical(other.w400, w400) || other.w400 == w400)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.tablet, tablet) || other.tablet == tablet)&&(identical(other.desktop, desktop) || other.desktop == desktop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tiny,w400,mobile,tablet,desktop);

@override
String toString() {
  return 'ResizedTargets(tiny: $tiny, w400: $w400, mobile: $mobile, tablet: $tablet, desktop: $desktop)';
}


}

/// @nodoc
abstract mixin class _$ResizedTargetsCopyWith<$Res> implements $ResizedTargetsCopyWith<$Res> {
  factory _$ResizedTargetsCopyWith(_ResizedTargets value, $Res Function(_ResizedTargets) _then) = __$ResizedTargetsCopyWithImpl;
@override @useResult
$Res call({
 ImageSize? tiny, ImageSize? w400, ImageSize? mobile, ImageSize? tablet, ImageSize? desktop
});


@override $ImageSizeCopyWith<$Res>? get tiny;@override $ImageSizeCopyWith<$Res>? get w400;@override $ImageSizeCopyWith<$Res>? get mobile;@override $ImageSizeCopyWith<$Res>? get tablet;@override $ImageSizeCopyWith<$Res>? get desktop;

}
/// @nodoc
class __$ResizedTargetsCopyWithImpl<$Res>
    implements _$ResizedTargetsCopyWith<$Res> {
  __$ResizedTargetsCopyWithImpl(this._self, this._then);

  final _ResizedTargets _self;
  final $Res Function(_ResizedTargets) _then;

/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tiny = freezed,Object? w400 = freezed,Object? mobile = freezed,Object? tablet = freezed,Object? desktop = freezed,}) {
  return _then(_ResizedTargets(
tiny: freezed == tiny ? _self.tiny : tiny // ignore: cast_nullable_to_non_nullable
as ImageSize?,w400: freezed == w400 ? _self.w400 : w400 // ignore: cast_nullable_to_non_nullable
as ImageSize?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as ImageSize?,tablet: freezed == tablet ? _self.tablet : tablet // ignore: cast_nullable_to_non_nullable
as ImageSize?,desktop: freezed == desktop ? _self.desktop : desktop // ignore: cast_nullable_to_non_nullable
as ImageSize?,
  ));
}

/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<$Res>? get tiny {
    if (_self.tiny == null) {
    return null;
  }

  return $ImageSizeCopyWith<$Res>(_self.tiny!, (value) {
    return _then(_self.copyWith(tiny: value));
  });
}/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<$Res>? get w400 {
    if (_self.w400 == null) {
    return null;
  }

  return $ImageSizeCopyWith<$Res>(_self.w400!, (value) {
    return _then(_self.copyWith(w400: value));
  });
}/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<$Res>? get mobile {
    if (_self.mobile == null) {
    return null;
  }

  return $ImageSizeCopyWith<$Res>(_self.mobile!, (value) {
    return _then(_self.copyWith(mobile: value));
  });
}/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<$Res>? get tablet {
    if (_self.tablet == null) {
    return null;
  }

  return $ImageSizeCopyWith<$Res>(_self.tablet!, (value) {
    return _then(_self.copyWith(tablet: value));
  });
}/// Create a copy of ResizedTargets
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageSizeCopyWith<$Res>? get desktop {
    if (_self.desktop == null) {
    return null;
  }

  return $ImageSizeCopyWith<$Res>(_self.desktop!, (value) {
    return _then(_self.copyWith(desktop: value));
  });
}
}


/// @nodoc
mixin _$HeroImage {

 String get id; String get filetype; String? get description;@JsonKey(name: 'resized_targets') ResizedTargets get resizedTargets;
/// Create a copy of HeroImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeroImageCopyWith<HeroImage> get copyWith => _$HeroImageCopyWithImpl<HeroImage>(this as HeroImage, _$identity);

  /// Serializes this HeroImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeroImage&&(identical(other.id, id) || other.id == id)&&(identical(other.filetype, filetype) || other.filetype == filetype)&&(identical(other.description, description) || other.description == description)&&(identical(other.resizedTargets, resizedTargets) || other.resizedTargets == resizedTargets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,filetype,description,resizedTargets);

@override
String toString() {
  return 'HeroImage(id: $id, filetype: $filetype, description: $description, resizedTargets: $resizedTargets)';
}


}

/// @nodoc
abstract mixin class $HeroImageCopyWith<$Res>  {
  factory $HeroImageCopyWith(HeroImage value, $Res Function(HeroImage) _then) = _$HeroImageCopyWithImpl;
@useResult
$Res call({
 String id, String filetype, String? description,@JsonKey(name: 'resized_targets') ResizedTargets resizedTargets
});


$ResizedTargetsCopyWith<$Res> get resizedTargets;

}
/// @nodoc
class _$HeroImageCopyWithImpl<$Res>
    implements $HeroImageCopyWith<$Res> {
  _$HeroImageCopyWithImpl(this._self, this._then);

  final HeroImage _self;
  final $Res Function(HeroImage) _then;

/// Create a copy of HeroImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? filetype = null,Object? description = freezed,Object? resizedTargets = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filetype: null == filetype ? _self.filetype : filetype // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,resizedTargets: null == resizedTargets ? _self.resizedTargets : resizedTargets // ignore: cast_nullable_to_non_nullable
as ResizedTargets,
  ));
}
/// Create a copy of HeroImage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResizedTargetsCopyWith<$Res> get resizedTargets {
  
  return $ResizedTargetsCopyWith<$Res>(_self.resizedTargets, (value) {
    return _then(_self.copyWith(resizedTargets: value));
  });
}
}


/// Adds pattern-matching-related methods to [HeroImage].
extension HeroImagePatterns on HeroImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HeroImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HeroImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HeroImage value)  $default,){
final _that = this;
switch (_that) {
case _HeroImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HeroImage value)?  $default,){
final _that = this;
switch (_that) {
case _HeroImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String filetype,  String? description, @JsonKey(name: 'resized_targets')  ResizedTargets resizedTargets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HeroImage() when $default != null:
return $default(_that.id,_that.filetype,_that.description,_that.resizedTargets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String filetype,  String? description, @JsonKey(name: 'resized_targets')  ResizedTargets resizedTargets)  $default,) {final _that = this;
switch (_that) {
case _HeroImage():
return $default(_that.id,_that.filetype,_that.description,_that.resizedTargets);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String filetype,  String? description, @JsonKey(name: 'resized_targets')  ResizedTargets resizedTargets)?  $default,) {final _that = this;
switch (_that) {
case _HeroImage() when $default != null:
return $default(_that.id,_that.filetype,_that.description,_that.resizedTargets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HeroImage implements HeroImage {
  const _HeroImage({required this.id, required this.filetype, this.description, @JsonKey(name: 'resized_targets') required this.resizedTargets});
  factory _HeroImage.fromJson(Map<String, dynamic> json) => _$HeroImageFromJson(json);

@override final  String id;
@override final  String filetype;
@override final  String? description;
@override@JsonKey(name: 'resized_targets') final  ResizedTargets resizedTargets;

/// Create a copy of HeroImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeroImageCopyWith<_HeroImage> get copyWith => __$HeroImageCopyWithImpl<_HeroImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HeroImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HeroImage&&(identical(other.id, id) || other.id == id)&&(identical(other.filetype, filetype) || other.filetype == filetype)&&(identical(other.description, description) || other.description == description)&&(identical(other.resizedTargets, resizedTargets) || other.resizedTargets == resizedTargets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,filetype,description,resizedTargets);

@override
String toString() {
  return 'HeroImage(id: $id, filetype: $filetype, description: $description, resizedTargets: $resizedTargets)';
}


}

/// @nodoc
abstract mixin class _$HeroImageCopyWith<$Res> implements $HeroImageCopyWith<$Res> {
  factory _$HeroImageCopyWith(_HeroImage value, $Res Function(_HeroImage) _then) = __$HeroImageCopyWithImpl;
@override @useResult
$Res call({
 String id, String filetype, String? description,@JsonKey(name: 'resized_targets') ResizedTargets resizedTargets
});


@override $ResizedTargetsCopyWith<$Res> get resizedTargets;

}
/// @nodoc
class __$HeroImageCopyWithImpl<$Res>
    implements _$HeroImageCopyWith<$Res> {
  __$HeroImageCopyWithImpl(this._self, this._then);

  final _HeroImage _self;
  final $Res Function(_HeroImage) _then;

/// Create a copy of HeroImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? filetype = null,Object? description = freezed,Object? resizedTargets = null,}) {
  return _then(_HeroImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,filetype: null == filetype ? _self.filetype : filetype // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,resizedTargets: null == resizedTargets ? _self.resizedTargets : resizedTargets // ignore: cast_nullable_to_non_nullable
as ResizedTargets,
  ));
}

/// Create a copy of HeroImage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResizedTargetsCopyWith<$Res> get resizedTargets {
  
  return $ResizedTargetsCopyWith<$Res>(_self.resizedTargets, (value) {
    return _then(_self.copyWith(resizedTargets: value));
  });
}
}

// dart format on
