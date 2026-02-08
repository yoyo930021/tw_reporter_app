import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/async_value.dart';

void main() {
  group('AsyncValue', () {
    test('should create AsyncIdle state', () {
      // Act
      const state = AsyncValue<String>.idle();

      // Assert
      expect(state, isA<AsyncIdle<String>>());
      expect(
        state.when(
          idle: () => 'idle',
          loading: () => 'loading',
          data: (_) => 'data',
          error: (_, _) => 'error',
        ),
        equals('idle'),
      );
    });

    test('should create AsyncLoading state', () {
      // Act
      const state = AsyncValue<String>.loading();

      // Assert
      expect(state, isA<AsyncLoading<String>>());
      expect(
        state.when(
          idle: () => 'idle',
          loading: () => 'loading',
          data: (_) => 'data',
          error: (_, _) => 'error',
        ),
        equals('loading'),
      );
    });

    test('should create AsyncData state with value', () {
      // Act
      const state = AsyncValue<String>.data('test data');

      // Assert
      expect(state, isA<AsyncData<String>>());
      expect(
        state.when(
          idle: () => 'idle',
          loading: () => 'loading',
          data: (value) => value,
          error: (_, _) => 'error',
        ),
        equals('test data'),
      );
    });

    test('should create AsyncError state with error', () {
      // Arrange
      final error = Exception('test error');
      final stackTrace = StackTrace.current;

      // Act
      final state = AsyncValue<String>.error(
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
          error: (e, st) => e.toString(),
        ),
        equals(error.toString()),
      );
    });

    test('should support pattern matching with map', () {
      // Arrange
      const state = AsyncValue<int>.data(42);

      // Act
      final result = state.map(
        idle: (_) => 'is idle',
        loading: (_) => 'is loading',
        data: (data) => 'value: ${data.value}',
        error: (_) => 'is error',
      );

      // Assert
      expect(result, equals('value: 42'));
    });

    test('should support maybeWhen with orElse', () {
      // Arrange
      const loadingState = AsyncValue<String>.loading();
      const dataState = AsyncValue<String>.data('test');

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
      const state1 = AsyncValue<String>.data('test');
      const state2 = AsyncValue<String>.data('test');
      const state3 = AsyncValue<String>.data('different');

      // Assert
      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('should support different types', () {
      // Act
      const intState = AsyncValue<int>.data(42);
      const listState = AsyncValue<List<String>>.data(
        <String>['a', 'b'],
      );

      // Assert
      expect(
        intState.when(
          idle: () => 0,
          loading: () => 0,
          data: (value) => value,
          error: (_, _) => 0,
        ),
        equals(42),
      );

      expect(
        listState.when(
          idle: () => <String>[],
          loading: () => <String>[],
          data: (value) => value,
          error: (_, _) => <String>[],
        ),
        equals(<String>['a', 'b']),
      );
    });

    test('should handle AsyncError without stackTrace', () {
      // Arrange
      final error = Exception('test error');

      // Act
      final state = AsyncValue<String>.error(error);

      // Assert
      expect(state, isA<AsyncError<String>>());
      expect(
        state.when(
          idle: () => false,
          loading: () => false,
          data: (_) => false,
          error: (e, st) => st == null,
        ),
        isTrue,
      );
    });
  });
}
