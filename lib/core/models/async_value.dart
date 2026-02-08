import 'package:freezed_annotation/freezed_annotation.dart';

part 'async_value.freezed.dart';

/// AsyncValue is a wrapper for asynchronous data loading states.
/// It represents the different states of an async operation:
/// - idle: Initial state before any operation
/// - loading: Operation in progress
/// - data: Operation completed successfully with data
/// - error: Operation failed with an error
///
/// This class is used for UI state management and does
/// NOT require JSON serialization.
@freezed
sealed class AsyncValue<T> with _$AsyncValue<T> {
  const factory AsyncValue.idle() = AsyncIdle<T>;
  const factory AsyncValue.loading() = AsyncLoading<T>;
  const factory AsyncValue.data(T value) = AsyncData<T>;
  const factory AsyncValue.error(
    Object error, [
    StackTrace? stackTrace,
  ]) = AsyncError<T>;
}
