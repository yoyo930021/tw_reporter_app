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
  Future<void> Function() loadMore,
  Future<void> Function() refresh,
});

/// 分類文章列表 Composable
CategoryArticlesResult useCategoryArticles(
  ArticleRepository repo, {
  required String category,
  int pageSize = 10,
}) {
  final scrollResult = useInfiniteScroll<Article>(
    fetcher: (page) => repo.fetchByCategory(
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
