import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/repositories/reading_repository.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';

/// 閱讀數據結果類型
typedef ReadingDataResult = ({
  Ref<List<ReadingRecord>> history,
  Ref<List<ReadingRecord>> bookmarks,
  Ref<bool> isLoading,
  Future<void> Function() refresh,
  void Function() clearHistory,
  void Function(String slug) removeBookmark,
});

/// 閱讀數據 Composable
ReadingDataResult useReadingData(ReadingRepository repo) {
  final history =
      ref<List<ReadingRecord>>(<ReadingRecord>[]);
  final bookmarks =
      ref<List<ReadingRecord>>(<ReadingRecord>[]);
  final isLoading = ref<bool>(true);

  void loadData() {
    history.value = repo.getHistory();
    bookmarks.value = repo.getBookmarks();
    isLoading.value = false;
  }

  Future<void> refresh() async {
    isLoading.value = true;
    loadData();
  }

  void clearHistory() {
    repo.clearHistory();
  }

  void removeBookmark(String slug) {
    repo.removeBookmark(slug);
  }

  onMounted(() {
    loadData();
    // 監聽 repository 變更（例如從文章頁面新增閱讀記錄/收藏）
    repo.addListener(loadData);
  });

  onUnmounted(() {
    repo.removeListener(loadData);
  });

  return (
    history: history,
    bookmarks: bookmarks,
    isLoading: isLoading,
    refresh: refresh,
    clearHistory: clearHistory,
    removeBookmark: removeBookmark,
  );
}
