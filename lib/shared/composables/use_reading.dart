import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/composables.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';

/// Full reading composable result type.
typedef UseReadingResult = ({
  ReadonlyRef<List<ReadingRecord>> history,
  ReadonlyRef<List<ReadingRecord>> bookmarks,
  ReadonlyRef<Set<String>> readSlugs,
  void Function(String slug, String title, String? imageUrl, DateTime timestamp)
      addToHistory,
  void Function(String slug, String title, String? imageUrl) addBookmark,
  void Function(String slug) removeBookmark,
  bool Function(String slug) isBookmarked,
  void Function() clearHistory,
  void Function() refresh,
});

/// Provides reactive reading history and bookmarks.
///
/// Listens to the reading repository so that mutations from any
/// page (e.g. article page adding a record) are reflected
/// everywhere.
UseReadingResult useReading() {
  final repo = useReadingRepository();
  final history = ref<List<ReadingRecord>>(<ReadingRecord>[]);
  final bookmarks = ref<List<ReadingRecord>>(<ReadingRecord>[]);
  final readSlugs = computed(() => history.value.map((r) => r.slug).toSet());

  void sync() {
    history.value = repo.getHistory();
    bookmarks.value = repo.getBookmarks();
  }

  onMounted(() {
    sync();
    repo.addListener(sync);
  });

  onUnmounted(() {
    repo.removeListener(sync);
  });

  return (
    history: history,
    bookmarks: bookmarks,
    readSlugs: readSlugs,
    addToHistory: repo.addToHistory,
    addBookmark: repo.addBookmark,
    removeBookmark: repo.removeBookmark,
    isBookmarked: repo.isBookmarked,
    clearHistory: repo.clearHistory,
    refresh: sync,
  );
}
