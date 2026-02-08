import 'package:flutter_compositions/flutter_compositions.dart';

/// 無限滾動結果類型
///
/// 包含無限滾動所需的所有狀態和方法
typedef InfiniteScrollResult<T> = ({
  Ref<List<T>> items,
  Ref<bool> isLoading,
  Ref<bool> hasMore,
  Future<void> Function() loadMore,
  Future<void> Function() refresh,
});

/// 無限滾動 Composable
///
/// 用於實作無限滾動列表的可重用邏輯
///
/// ## 使用範例
///
/// ```dart
/// final result = useInfiniteScroll<Article>(
///   fetcher: (page) => api.fetchArticles(page: page, limit: 20),
///   pageSize: 20,
/// );
///
/// // 使用資料
/// ListView.builder(
///   itemCount: result.items.value.length,
///   itemBuilder: (context, index) => ArticleCard(
///     article: result.items.value[index],
///   ),
/// );
///
/// // 載入更多
/// if (result.hasMore.value && !result.isLoading.value) {
///   result.loadMore();
/// }
///
/// // 重新整理
/// result.refresh();
/// ```
///
/// ## 參數
///
/// - [fetcher]: 資料獲取函數，接收頁碼返回該頁的資料列表
/// - [pageSize]: 每頁的資料數量，用於判斷是否還有更多資料
///
/// ## 返回值
///
/// - `items`: 已載入的所有項目列表
/// - `isLoading`: 是否正在載入中
/// - `hasMore`: 是否還有更多資料可載入
/// - `loadMore`: 載入下一頁資料的函數
/// - `refresh`: 重新載入第一頁資料的函數
InfiniteScrollResult<T> useInfiniteScroll<T>({
  required Future<List<T>> Function(int page) fetcher,
  int pageSize = 10,
}) {
  // 資料列表
  final items = ref<List<T>>(<T>[]);

  // 當前頁碼（從 1 開始）
  final currentPage = ref<int>(1);

  // 載入狀態
  final isLoading = ref<bool>(false);

  // 是否還有更多資料
  final hasMore = ref<bool>(true);

  /// 載入更多資料
  Future<void> loadMore() async {
    // 如果正在載入或已經沒有更多資料，則不執行
    if (isLoading.value || !hasMore.value) {
      return;
    }

    isLoading.value = true;
    try {
      final newItems = await fetcher(currentPage.value);

      // 將新資料追加到現有列表
      items.value = <T>[...items.value, ...newItems];

      // 更新頁碼
      currentPage.value++;

      // 判斷是否還有更多資料
      // 如果返回的資料少於 pageSize，表示已經到最後一頁
      hasMore.value = newItems.length >= pageSize;
    } finally {
      isLoading.value = false;
    }
  }

  /// 重新整理資料
  ///
  /// 清空現有資料並重新載入第一頁
  Future<void> refresh() async {
    currentPage.value = 1;
    items.value = <T>[];
    hasMore.value = true;
    await loadMore();
  }

  // 在組件掛載時自動載入第一頁資料
  onMounted(loadMore);

  return (
    items: items,
    isLoading: isLoading,
    hasMore: hasMore,
    loadMore: loadMore,
    refresh: refresh,
  );
}
