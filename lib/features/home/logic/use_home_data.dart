import 'package:flutter/foundation.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/repositories/home_repository.dart';

/// 首頁資料結果類型
typedef HomeDataResult = ({
  Ref<IndexPageData?> indexData,
  Ref<bool> isLoading,
  Ref<bool> hasError,
  Ref<String?> error,
  Future<void> Function() refresh,
});

/// 首頁資料 Composable
HomeDataResult useHomeData(HomeRepository repo) {
  final indexData = ref<IndexPageData?>(null);
  final isLoading = ref<bool>(false);
  final hasError = ref<bool>(false);
  final error = ref<String?>(null);

  Future<void> loadIndexPage() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    error.value = null;

    try {
      indexData.value = await repo.fetchIndexPage();
    } on Object catch (e, stackTrace) {
      hasError.value = true;
      error.value = e.toString();
      debugPrint('載入首頁資料失敗: $e');
      debugPrint('堆疊追蹤: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadIndexPage();
  }

  onMounted(loadIndexPage);

  return (
    indexData: indexData,
    isLoading: isLoading,
    hasError: hasError,
    error: error,
    refresh: refresh,
  );
}
