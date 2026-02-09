import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/api/api_client.dart';

void main() {
  // Note: createDio() and createImageDio() cannot be fully tested in unit tests
  // because NativeAdapter requires platform-specific FFI bindings (Cronet/URLSession).
  // We test the static configuration aspects only.

  group('ApiClient', () {
    test('class exists and is accessible', () {
      // Verify the class exists and can be referenced
      expect(ApiClient, isNotNull);
    });

    test('createDio is a static method', () {
      // Verify the method signature exists
      // Cannot call it because NativeAdapter requires FFI
      expect(ApiClient.createDio, isA<Function>());
    });

    test('createImageDio is a static method', () {
      expect(ApiClient.createImageDio, isA<Function>());
    });
  });
}
