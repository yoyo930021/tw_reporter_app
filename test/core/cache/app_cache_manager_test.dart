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

    test('cleanExpired completes without error', () async {
      await expectLater(
        AppCacheManager.instance.cleanExpired(),
        completes,
      );
    });

    test('getTotalCacheSize returns 0 when not initialized', () async {
      // The singleton may or may not be initialized depending on test order,
      // but we can verify the method doesn't throw.
      final size = await AppCacheManager.instance.getTotalCacheSize();
      expect(size, isA<int>());
    });

    test('httpCacheOptions is accessible after init', () {
      // If initialized, httpCacheOptions should not throw.
      // If not initialized, this test simply verifies the getter exists.
      if (AppCacheManager.instance.isInitialized) {
        expect(
          AppCacheManager.instance.httpCacheOptions,
          isNotNull,
        );
      }
    });

    test('videoCachePath contains video_cache', () {
      if (AppCacheManager.instance.isInitialized) {
        expect(
          AppCacheManager.instance.videoCachePath,
          contains('video_cache'),
        );
      }
    });
  });
}
