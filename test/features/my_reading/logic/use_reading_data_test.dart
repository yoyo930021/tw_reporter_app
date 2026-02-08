import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';

void main() {
  late ReadingStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    storage = ReadingStorage(prefs);
  });

  group('ReadingStorage used by useReadingData', () {
    test('should load history from storage', () {
      storage
        ..addToHistory('slug-1', '文章1', null, DateTime(2024))
        ..addToHistory('slug-2', '文章2', null, DateTime(2024, 1, 2));

      final history = storage.getHistory();
      expect(history, hasLength(2));
      expect(history[0].slug, 'slug-2');
      expect(history[1].slug, 'slug-1');
    });

    test('should load bookmarks from storage', () {
      storage.addBookmark('slug-1', '文章1', null);

      final bookmarks = storage.getBookmarks();
      expect(bookmarks, hasLength(1));
      expect(bookmarks.first.slug, 'slug-1');
    });

    test('should clear history', () {
      storage
        ..addToHistory('slug-1', '文章1', null, DateTime(2024))
        ..clearHistory();

      expect(storage.getHistory(), isEmpty);
    });

    test('should remove bookmark', () {
      storage
        ..addBookmark('slug-1', '文章1', null)
        ..addBookmark('slug-2', '文章2', null)
        ..removeBookmark('slug-1');

      final bookmarks = storage.getBookmarks();
      expect(bookmarks, hasLength(1));
      expect(bookmarks.first.slug, 'slug-2');
    });
  });
}
