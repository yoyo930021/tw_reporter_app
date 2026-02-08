import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/api/api_exception.dart';

void main() {
  group('ApiException', () {
    group('fromDioException', () {
      test('should create NetworkError for connection timeout', () {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        );

        // Act
        final exception = ApiException.fromDioException(dioError);

        // Assert
        expect(exception, isA<NetworkError>());
        expect(
          exception.when(
            networkError: () => true,
            serverError: (_) => false,
            notFound: () => false,
            unauthorized: () => false,
            unknown: (_) => false,
          ),
          isTrue,
        );
      });

      test('should create NetworkError for send timeout', () {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.sendTimeout,
        );

        // Act
        final exception = ApiException.fromDioException(dioError);

        // Assert
        expect(exception, isA<NetworkError>());
      });

      test('should create NetworkError for receive timeout', () {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.receiveTimeout,
        );

        // Act
        final exception = ApiException.fromDioException(dioError);

        // Assert
        expect(exception, isA<NetworkError>());
      });

      test('should create NetworkError for connection error', () {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        );

        // Act
        final exception = ApiException.fromDioException(dioError);

        // Assert
        expect(exception, isA<NetworkError>());
      });

      test('should create NotFound for 404 status code', () {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            statusCode: 404,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final exception = ApiException.fromDioException(dioError);

        // Assert
        expect(exception, isA<NotFound>());
      });

      test('should create Unauthorized for 401 status code', () {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            statusCode: 401,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final exception = ApiException.fromDioException(dioError);

        // Assert
        expect(exception, isA<Unauthorized>());
      });

      test('should create ServerError for 500 status code', () {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            statusCode: 500,
            requestOptions: RequestOptions(),
          ),
        );

        // Act
        final exception = ApiException.fromDioException(dioError);

        // Assert
        expect(exception, isA<ServerError>());
        expect(
          exception.when(
            networkError: () => 0,
            serverError: (code) => code,
            notFound: () => 0,
            unauthorized: () => 0,
            unknown: (_) => 0,
          ),
          equals(500),
        );
      });

      test('should create Unknown for unhandled error types', () {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.cancel,
          message: 'Request cancelled',
        );

        // Act
        final exception = ApiException.fromDioException(dioError);

        // Assert
        expect(exception, isA<Unknown>());
      });
    });

    test('should support pattern matching with when', () {
      // Arrange
      const exception = ApiException.networkError();

      // Act
      final result = exception.when(
        networkError: () => 'Network error',
        serverError: (_) => 'Server error',
        notFound: () => 'Not found',
        unauthorized: () => 'Unauthorized',
        unknown: (_) => 'Unknown',
      );

      // Assert
      expect(result, equals('Network error'));
    });

    test('should support pattern matching with map', () {
      // Arrange
      const exception = ApiException.notFound();

      // Act
      final result = exception.map(
        networkError: (_) => 'Network',
        serverError: (_) => 'Server',
        notFound: (_) => 'Not found',
        unauthorized: (_) => 'Unauthorized',
        unknown: (_) => 'Unknown',
      );

      // Assert
      expect(result, equals('Not found'));
    });

    test('should support maybeWhen with orElse', () {
      // Arrange
      const exception = ApiException.unauthorized();

      // Act & Assert
      expect(
        exception.maybeWhen(
          unauthorized: () => 'Unauthorized',
          orElse: () => 'Other',
        ),
        equals('Unauthorized'),
      );

      expect(
        exception.maybeWhen(
          notFound: () => 'Not found',
          orElse: () => 'Other',
        ),
        equals('Other'),
      );
    });
  });
}
