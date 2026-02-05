import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/async_value.dart';

void main() {
  group('AsyncValue', () {
    test('should create AsyncIdle state', () {
      // Act
      final AsyncValue<String> state = AsyncValue<String>.idle();

      // Assert
      expect(state, isA<AsyncIdle<String>>());
      expect(
        state.when(
          idle: () => 'idle',
          loading: () => 'loading',
          data: (_) => 'data',
          error: (_, __) => 'error',
        ),
        equals('idle'),
      );
    });

    test('should create AsyncLoading state', () {
      // Act
      final AsyncValue<String> state = AsyncValue<String>.loading();

      // Assert
      expect(state, isA<AsyncLoading<String>>());
      expect(
        state.when(
          idle: () => 'idle',
          loading: () => 'loading',
          data: (_) => 'data',
          error: (_, __) => 'error',
        ),
        equals('loading'),
      );
    });

    test('should create AsyncData state with value', () {
      // Act
      final AsyncValue<String> state = AsyncValue<String>.data('test data');

      // Assert
      expect(state, isA<AsyncData<String>>());
      expect(
        state.when(
          idle: () => 'idle',
          loading: () => 'loading',
          data: (String value) => value,
          error: (_, __) => 'error',
        ),
        equals('test data'),
      );
    });

    test('should create AsyncError state with error', () {
      // Arrange
      final Exception error = Exception('test error');
      final StackTrace stackTrace = StackTrace.current;

      // Act
      final AsyncValue<String> state = AsyncValue<String>.error(
        error,
        stackTrace,
      );

      // Assert
      expect(state, isA<AsyncError<String>>());
      expect(
        state.when(
          idle: () => 'idle',
          loading: () => 'loading',
          data: (_) => 'data',
          error: (Object e, StackTrace? st) => e.toString(),
        ),
        equals(error.toString()),
      );
    });

    test('should support pattern matching with map', () {
      // Arrange
      final AsyncValue<int> state = AsyncValue<int>.data(42);

      // Act
      final String result = state.map(
        idle: (_) => 'is idle',
        loading: (_) => 'is loading',
        data: (AsyncData<int> data) => 'value: ${data.value}',
        error: (_) => 'is error',
      );

      // Assert
      expect(result, equals('value: 42'));
    });

    test('should support maybeWhen with orElse', () {
      // Arrange
      final AsyncValue<String> loadingState = AsyncValue<String>.loading();
      final AsyncValue<String> dataState = AsyncValue<String>.data('test');

      // Act & Assert
      expect(
        loadingState.maybeWhen(
          loading: () => 'loading',
          orElse: () => 'other',
        ),
        equals('loading'),
      );

      expect(
        dataState.maybeWhen(
          loading: () => 'loading',
          orElse: () => 'other',
        ),
        equals('other'),
      );
    });

    test('should support equality comparison', () {
      // Arrange
      final AsyncValue<String> state1 = AsyncValue<String>.data('test');
      final AsyncValue<String> state2 = AsyncValue<String>.data('test');
      final AsyncValue<String> state3 = AsyncValue<String>.data('different');

      // Assert
      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('should support different types', () {
      // Act
      final AsyncValue<int> intState = AsyncValue<int>.data(42);
      final AsyncValue<List<String>> listState = AsyncValue<List<String>>.data(
        <String>['a', 'b'],
      );

      // Assert
      expect(
        intState.when(
          idle: () => 0,
          loading: () => 0,
          data: (int value) => value,
          error: (_, __) => 0,
        ),
        equals(42),
      );

      expect(
        listState.when(
          idle: () => <String>[],
          loading: () => <String>[],
          data: (List<String> value) => value,
          error: (_, __) => <String>[],
        ),
        equals(<String>['a', 'b']),
      );
    });

    test('should handle AsyncError without stackTrace', () {
      // Arrange
      final Exception error = Exception('test error');

      // Act
      final AsyncValue<String> state = AsyncValue<String>.error(error);

      // Assert
      expect(state, isA<AsyncError<String>>());
      expect(
        state.when(
          idle: () => false,
          loading: () => false,
          data: (_) => false,
          error: (Object e, StackTrace? st) => st == null,
        ),
        isTrue,
      );
    });
  });
}
