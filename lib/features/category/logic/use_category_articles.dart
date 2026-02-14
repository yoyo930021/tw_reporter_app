import 'dart:async';

import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';
import 'package:tw_reporter_app/shared/composables/use_infinite_scroll.dart';

/// 分類文章列表結果類型
typedef CategoryArticlesResult = ({
  String category,
  Ref<List<Article>> articles,
  Ref<bool> isLoading,
  Ref<bool> hasMore,
  Ref<String?> selectedSubcategoryId,
  void Function(String?) selectSubcategory,
  Future<void> Function() loadMore,
  Future<void> Function() refresh,
});

/// 分類文章列表 Composable
///
/// 使用伺服器端 `subcategory_id` 參數過濾子分類。
/// 選擇子分類後會呼叫 `refresh()` 重新從伺服器獲取資料。
CategoryArticlesResult useCategoryArticles(
  ArticleRepository repo, {
  required String category,
  int pageSize = 10,
}) {
  final selectedSubcategoryId = ref<String?>(null);

  final scrollResult = useInfiniteScroll<Article>(
    fetcher: (page) => repo.fetchByCategory(
      category: category,
      subcategoryId: selectedSubcategoryId.value,
      page: page,
      limit: pageSize,
    ),
    pageSize: pageSize,
  );

  void selectSubcategory(String? id) {
    if (selectedSubcategoryId.value == id) return;
    selectedSubcategoryId.value = id;
    unawaited(scrollResult.refresh());
  }

  return (
    category: category,
    articles: scrollResult.items,
    isLoading: scrollResult.isLoading,
    hasMore: scrollResult.hasMore,
    selectedSubcategoryId: selectedSubcategoryId,
    selectSubcategory: selectSubcategory,
    loadMore: scrollResult.loadMore,
    refresh: scrollResult.refresh,
  );
}
