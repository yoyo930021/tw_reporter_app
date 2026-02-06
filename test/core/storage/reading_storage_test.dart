import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';

void main() {
  late ReadingStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    return SharedPreferences.getInstance().then((prefs) {
      storage = ReadingStorage(prefs);
    });
  });

  group('ReadingStorage - History', () {
    test('should start with empty history', () {
      expect(storage.getHistory(), isEmpty);
    });

    test('should add reading record', () {
      storage.addToHistory('slug-1', '文章標題', 'http://img.jpg', DateTime(2024, 1, 1));

      final history = storage.getHistory();
      expect(history, hasLength(1));
      expect(history.first.slug, 'slug-1');
      expect(history.first.title, '文章標題');
      expect(history.first.imageUrl, 'http://img.jpg');
    });

    test('should return history in reverse chronological order', () {
      storage.addToHistory('slug-1', '文章1', null, DateTime(2024, 1, 1));
      storage.addToHistory('slug-2', '文章2', null, DateTime(2024, 1, 2));

      final history = storage.getHistory();
      expect(history, hasLength(2));
      expect(history[0].slug, 'slug-2');
      expect(history[1].slug, 'slug-1');
    });

    test('should deduplicate - move existing slug to top', () {
      storage.addToHistory('slug-1', '文章1', null, DateTime(2024, 1, 1));
      storage.addToHistory('slug-2', '文章2', null, DateTime(2024, 1, 2));
      storage.addToHistory('slug-1', '文章1-更新', null, DateTime(2024, 1, 3));

      final history = storage.getHistory();
      expect(history, hasLength(2));
      expect(history[0].slug, 'slug-1');
      expect(history[0].title, '文章1-更新');
      expect(history[1].slug, 'slug-2');
    });

    test('should clear history', () {
      storage.addToHistory('slug-1', '文章1', null, DateTime(2024, 1, 1));
      storage.addToHistory('slug-2', '文章2', null, DateTime(2024, 1, 2));

      storage.clearHistory();

      expect(storage.getHistory(), isEmpty);
    });

    test('should handle null image URL', () {
      storage.addToHistory('slug-1', '文章1', null, DateTime(2024, 1, 1));

      final record = storage.getHistory().first;
      expect(record.imageUrl, isNull);
    });
  });

  group('ReadingStorage - Bookmarks', () {
    test('should start with empty bookmarks', () {
      expect(storage.getBookmarks(), isEmpty);
    });

    test('should add bookmark', () {
      storage.addBookmark('slug-1', '文章標題', 'http://img.jpg');

      final bookmarks = storage.getBookmarks();
      expect(bookmarks, hasLength(1));
      expect(bookmarks.first.slug, 'slug-1');
      expect(bookmarks.first.title, '文章標題');
    });

    test('should not add duplicate bookmark', () {
      storage.addBookmark('slug-1', '文章1', null);
      storage.addBookmark('slug-1', '文章1', null);

      expect(storage.getBookmarks(), hasLength(1));
    });

    test('should remove bookmark', () {
      storage.addBookmark('slug-1', '文章1', null);
      storage.addBookmark('slug-2', '文章2', null);

      storage.removeBookmark('slug-1');

      final bookmarks = storage.getBookmarks();
      expect(bookmarks, hasLength(1));
      expect(bookmarks.first.slug, 'slug-2');
    });

    test('should check if bookmarked', () {
      storage.addBookmark('slug-1', '文章1', null);

      expect(storage.isBookmarked('slug-1'), isTrue);
      expect(storage.isBookmarked('slug-2'), isFalse);
    });

    test('isBookmarked should return false after removing', () {
      storage.addBookmark('slug-1', '文章1', null);
      storage.removeBookmark('slug-1');

      expect(storage.isBookmarked('slug-1'), isFalse);
    });
  });

  group('ReadingRecord', () {
    test('should serialize to and from JSON', () {
      final record = ReadingRecord(
        slug: 'test-slug',
        title: '測試標題',
        imageUrl: 'http://img.jpg',
        timestamp: DateTime(2024, 6, 15, 10, 30),
      );

      final json = record.toJson();
      final restored = ReadingRecord.fromJson(json);

      expect(restored.slug, record.slug);
      expect(restored.title, record.title);
      expect(restored.imageUrl, record.imageUrl);
      expect(restored.timestamp, record.timestamp);
    });

    test('should handle null imageUrl in JSON', () {
      final record = ReadingRecord(
        slug: 'test-slug',
        title: '測試標題',
        imageUrl: null,
        timestamp: DateTime(2024, 6, 15),
      );

      final json = record.toJson();
      final restored = ReadingRecord.fromJson(json);

      expect(restored.imageUrl, isNull);
    });
  });
}
