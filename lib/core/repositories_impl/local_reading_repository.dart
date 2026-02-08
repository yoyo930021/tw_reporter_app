import 'package:tw_reporter_app/core/repositories/reading_repository.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';

/// 本地 SharedPreferences 閱讀記錄與收藏實作
class LocalReadingRepository extends ReadingRepository {
  LocalReadingRepository(this._storage);

  final ReadingStorage _storage;

  /// 非同步工廠：自動建立 ReadingStorage
  static Future<LocalReadingRepository> create() async {
    final storage = await ReadingStorage.create();
    return LocalReadingRepository(storage);
  }

  @override
  void addToHistory(
    String slug,
    String title,
    String? imageUrl,
    DateTime timestamp,
  ) {
    _storage.addToHistory(slug, title, imageUrl, timestamp);
    notifyListeners();
  }

  @override
  List<ReadingRecord> getHistory() => _storage.getHistory();

  @override
  bool isRead(String slug) => _storage.isRead(slug);

  @override
  void clearHistory() {
    _storage.clearHistory();
    notifyListeners();
  }

  @override
  void addBookmark(
    String slug,
    String title,
    String? imageUrl,
  ) {
    _storage.addBookmark(slug, title, imageUrl);
    notifyListeners();
  }

  @override
  void removeBookmark(String slug) {
    _storage.removeBookmark(slug);
    notifyListeners();
  }

  @override
  bool isBookmarked(String slug) =>
      _storage.isBookmarked(slug);

  @override
  List<ReadingRecord> getBookmarks() => _storage.getBookmarks();
}
