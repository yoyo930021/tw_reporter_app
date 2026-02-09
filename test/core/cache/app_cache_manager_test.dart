import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppCacheManager', () {
    test('instance is a singleton', () {
      expect(
        AppCacheManager.instance,
        same(AppCacheManager.instance),
      );
    });

    test('maxTotalCacheSize is 200MB', () {
      expect(
        AppCacheManager.maxTotalCacheSize,
        200 * 1024 * 1024,
      );
    });

    test('imageCacheManager returns a non-null manager', () {
      final manager = AppCacheManager.instance.imageCacheManager;
      expect(manager, isNotNull);
    });

    // Note: Full integration tests for init/clearAll/enforceLimit/cleanExpired
    // require HiveCacheStore native bindings not available in unit tests.
  });
}
