import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/shared/composables/use_debounce.dart';

/// 搜尋結果類型
///
/// 包含搜尋功能所需的所有狀態和方法
typedef SearchResult = ({
  Ref<String> query,
  Ref<List<Article>> articles,
  Ref<bool> isSearching,
  Ref<bool> hasMore,
  void Function(String) setQuery,
  Future<void> Function() loadMore,
});

/// 搜尋 Composable
///
/// 用於搜尋文章，支援防抖、無限滾動
///
/// ## 使用範例
///
/// ```dart
/// final SearchResult result = useSearch(api);
///
/// // 設定搜尋關鍵字（會自動防抖）
/// result.setQuery('關鍵字');
///
/// // 顯示搜尋結果
/// ListView.builder(
///   itemCount: result.articles.value.length,
///   itemBuilder: (context, index) {
///     return ArticleCard(article: result.articles.value[index]);
///   },
/// );
///
/// // 載入更多結果
/// if (result.hasMore.value && !result.isSearching.value) {
///   result.loadMore();
/// }
/// ```
///
/// ## 參數
///
/// - [api]: TwReporterApi 實例，用於資料獲取
/// - [debounceMs]: 防抖延遲時間（毫秒），預設 500ms
/// - [pageSize]: 每頁結果數量，預設 10
///
/// ## 返回值
///
/// - [query]: 當前搜尋關鍵字
/// - [articles]: 搜尋結果列表
/// - [isSearching]: 是否正在搜尋中
/// - [hasMore]: 是否還有更多結果
/// - [setQuery]: 設定搜尋關鍵字的函數
/// - [loadMore]: 載入更多結果的函數
SearchResult useSearch(
  TwReporterApi api, {
  int debounceMs = 500,
  int pageSize = 10,
}) {
  // 搜尋關鍵字
  final Ref<String> query = ref<String>('');

  // 搜尋結果
  final Ref<List<Article>> articles = ref<List<Article>>(<Article>[]);

  // 搜尋狀態
  final Ref<bool> isSearching = ref<bool>(false);
  final Ref<bool> hasMore = ref<bool>(false);

  // 當前頁碼
  final Ref<int> currentPage = ref<int>(1);

  // 建立防抖函數
  final void Function() debouncedSearch = useDebounce(
    () async {
      final String searchQuery = query.value.trim();

      // 如果查詢為空，清空結果
      if (searchQuery.isEmpty) {
        articles.value = <Article>[];
        hasMore.value = false;
        return;
      }

      isSearching.value = true;
      currentPage.value = 1;

      try {
        final List<Article> results = await api.searchArticles(
          query: searchQuery,
          page: 1,
        );

        articles.value = results;
        hasMore.value = results.length >= pageSize;
      } catch (e) {
        articles.value = <Article>[];
        hasMore.value = false;
        rethrow;
      } finally {
        isSearching.value = false;
      }
    },
    delay: Duration(milliseconds: debounceMs),
  );

  /// 設定搜尋關鍵字
  void setQuery(String newQuery) {
    query.value = newQuery;
    debouncedSearch();
  }

  /// 載入更多結果
  Future<void> loadMore() async {
    final String searchQuery = query.value.trim();

    if (isSearching.value || !hasMore.value || searchQuery.isEmpty) {
      return;
    }

    isSearching.value = true;
    final int nextPage = currentPage.value + 1;

    try {
      final List<Article> newResults = await api.searchArticles(
        query: searchQuery,
        page: nextPage,
      );

      articles.value = <Article>[...articles.value, ...newResults];
      currentPage.value = nextPage;
      hasMore.value = newResults.length >= pageSize;
    } catch (e) {
      rethrow;
    } finally {
      isSearching.value = false;
    }
  }

  return (
    query: query,
    articles: articles,
    isSearching: isSearching,
    hasMore: hasMore,
    setQuery: setQuery,
    loadMore: loadMore,
  );
}
