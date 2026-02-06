import 'package:flutter_compositions/flutter_compositions.dart';
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
///
/// 管理閱讀記錄和收藏列表的載入與操作
ReadingDataResult useReadingData({ReadingStorage? storage}) {
  final Ref<List<ReadingRecord>> history =
      ref<List<ReadingRecord>>(<ReadingRecord>[]);
  final Ref<List<ReadingRecord>> bookmarks =
      ref<List<ReadingRecord>>(<ReadingRecord>[]);
  final Ref<bool> isLoading = ref<bool>(true);
  final Ref<ReadingStorage?> storageRef = ref<ReadingStorage?>(storage);

  Future<void> loadData() async {
    if (storageRef.value == null) {
      storageRef.value = await ReadingStorage.create();
    }
    final s = storageRef.value!;
    history.value = s.getHistory();
    bookmarks.value = s.getBookmarks();
    isLoading.value = false;
  }

  Future<void> refresh() async {
    isLoading.value = true;
    await loadData();
  }

  void clearHistory() {
    storageRef.value?.clearHistory();
    history.value = <ReadingRecord>[];
  }

  void removeBookmark(String slug) {
    storageRef.value?.removeBookmark(slug);
    bookmarks.value = bookmarks.value.where((r) => r.slug != slug).toList();
  }

  onMounted(() {
    loadData();
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
