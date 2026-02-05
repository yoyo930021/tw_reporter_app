import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/shared/composables/use_infinite_scroll.dart';

/// 分類文章列表結果類型
///
/// 包含分類文章列表所需的所有狀態和方法
typedef CategoryArticlesResult = ({
  String category,
  Ref<List<Article>> articles,
  Ref<bool> isLoading,
  Ref<bool> hasMore,
  Future<void> Function() loadMore,
  Future<void> Function() refresh,
});

/// 分類文章列表 Composable
///
/// 用於載入和管理特定分類的文章列表，支援無限滾動和下拉重新整理
///
/// ## 使用範例
///
/// ```dart
/// final CategoryArticlesResult result = useCategoryArticles(
///   api,
///   category: '國際',
/// );
///
/// // 顯示文章列表
/// ListView.builder(
///   itemCount: result.articles.value.length,
///   itemBuilder: (context, index) {
///     return ArticleCard(article: result.articles.value[index]);
///   },
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
/// - [api]: TwReporterApi 實例，用於資料獲取
/// - [category]: 分類名稱（例如：國際、人權、政治、健康、環境、經濟、文化、教育）
/// - [pageSize]: 每頁文章數量，預設 10
///
/// ## 返回值
///
/// - [category]: 當前分類名稱
/// - [articles]: 文章列表
/// - [isLoading]: 是否正在載入中
/// - [hasMore]: 是否還有更多文章
/// - [loadMore]: 載入更多文章的函數
/// - [refresh]: 重新整理文章列表的函數
CategoryArticlesResult useCategoryArticles(
  TwReporterApi api, {
  required String category,
  int pageSize = 10,
}) {
  // 使用 useInfiniteScroll 處理無限滾動邏輯
  final InfiniteScrollResult<Article> scrollResult = useInfiniteScroll<Article>(
    fetcher: (int page) => api.fetchCategoryArticles(
      category: category,
      page: page,
      limit: pageSize,
    ),
    pageSize: pageSize,
  );

  return (
    category: category,
    articles: scrollResult.items,
    isLoading: scrollResult.isLoading,
    hasMore: scrollResult.hasMore,
    loadMore: scrollResult.loadMore,
    refresh: scrollResult.refresh,
  );
}
