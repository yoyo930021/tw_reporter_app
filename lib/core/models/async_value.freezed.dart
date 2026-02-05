// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'async_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AsyncValue<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncValue<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AsyncValue<$T>()';
}


}

/// @nodoc
class $AsyncValueCopyWith<T,$Res>  {
$AsyncValueCopyWith(AsyncValue<T> _, $Res Function(AsyncValue<T>) __);
}


/// Adds pattern-matching-related methods to [AsyncValue].
extension AsyncValuePatterns<T> on AsyncValue<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AsyncIdle<T> value)?  idle,TResult Function( AsyncLoading<T> value)?  loading,TResult Function( AsyncData<T> value)?  data,TResult Function( AsyncError<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AsyncIdle() when idle != null:
return idle(_that);case AsyncLoading() when loading != null:
return loading(_that);case AsyncData() when data != null:
return data(_that);case AsyncError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AsyncIdle<T> value)  idle,required TResult Function( AsyncLoading<T> value)  loading,required TResult Function( AsyncData<T> value)  data,required TResult Function( AsyncError<T> value)  error,}){
final _that = this;
switch (_that) {
case AsyncIdle():
return idle(_that);case AsyncLoading():
return loading(_that);case AsyncData():
return data(_that);case AsyncError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AsyncIdle<T> value)?  idle,TResult? Function( AsyncLoading<T> value)?  loading,TResult? Function( AsyncData<T> value)?  data,TResult? Function( AsyncError<T> value)?  error,}){
final _that = this;
switch (_that) {
case AsyncIdle() when idle != null:
return idle(_that);case AsyncLoading() when loading != null:
return loading(_that);case AsyncData() when data != null:
return data(_that);case AsyncError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( T value)?  data,TResult Function( Object error,  StackTrace? stackTrace)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AsyncIdle() when idle != null:
return idle();case AsyncLoading() when loading != null:
return loading();case AsyncData() when data != null:
return data(_that.value);case AsyncError() when error != null:
return error(_that.error,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( T value)  data,required TResult Function( Object error,  StackTrace? stackTrace)  error,}) {final _that = this;
switch (_that) {
case AsyncIdle():
return idle();case AsyncLoading():
return loading();case AsyncData():
return data(_that.value);case AsyncError():
return error(_that.error,_that.stackTrace);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( T value)?  data,TResult? Function( Object error,  StackTrace? stackTrace)?  error,}) {final _that = this;
switch (_that) {
case AsyncIdle() when idle != null:
return idle();case AsyncLoading() when loading != null:
return loading();case AsyncData() when data != null:
return data(_that.value);case AsyncError() when error != null:
return error(_that.error,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class AsyncIdle<T> implements AsyncValue<T> {
  const AsyncIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncIdle<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AsyncValue<$T>.idle()';
}


}




/// @nodoc


class AsyncLoading<T> implements AsyncValue<T> {
  const AsyncLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncLoading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AsyncValue<$T>.loading()';
}


}




/// @nodoc


class AsyncData<T> implements AsyncValue<T> {
  const AsyncData(this.value);
  

 final  T value;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsyncDataCopyWith<T, AsyncData<T>> get copyWith => _$AsyncDataCopyWithImpl<T, AsyncData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncData<T>&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'AsyncValue<$T>.data(value: $value)';
}


}

/// @nodoc
abstract mixin class $AsyncDataCopyWith<T,$Res> implements $AsyncValueCopyWith<T, $Res> {
  factory $AsyncDataCopyWith(AsyncData<T> value, $Res Function(AsyncData<T>) _then) = _$AsyncDataCopyWithImpl;
@useResult
$Res call({
 T value
});




}
/// @nodoc
class _$AsyncDataCopyWithImpl<T,$Res>
    implements $AsyncDataCopyWith<T, $Res> {
  _$AsyncDataCopyWithImpl(this._self, this._then);

  final AsyncData<T> _self;
  final $Res Function(AsyncData<T>) _then;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = freezed,}) {
  return _then(AsyncData<T>(
freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class AsyncError<T> implements AsyncValue<T> {
  const AsyncError(this.error, [this.stackTrace]);
  

 final  Object error;
 final  StackTrace? stackTrace;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsyncErrorCopyWith<T, AsyncError<T>> get copyWith => _$AsyncErrorCopyWithImpl<T, AsyncError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsyncError<T>&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'AsyncValue<$T>.error(error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $AsyncErrorCopyWith<T,$Res> implements $AsyncValueCopyWith<T, $Res> {
  factory $AsyncErrorCopyWith(AsyncError<T> value, $Res Function(AsyncError<T>) _then) = _$AsyncErrorCopyWithImpl;
@useResult
$Res call({
 Object error, StackTrace? stackTrace
});




}
/// @nodoc
class _$AsyncErrorCopyWithImpl<T,$Res>
    implements $AsyncErrorCopyWith<T, $Res> {
  _$AsyncErrorCopyWithImpl(this._self, this._then);

  final AsyncError<T> _self;
  final $Res Function(AsyncError<T>) _then;

/// Create a copy of AsyncValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,Object? stackTrace = freezed,}) {
  return _then(AsyncError<T>(
null == error ? _self.error : error ,freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
