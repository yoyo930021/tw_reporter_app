import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';
import 'package:tw_reporter_app/shared/composables/use_infinite_scroll.dart';

/// 作者文章列表結果類型
typedef AuthorArticlesResult = ({
  String authorId,
  Ref<List<Article>> articles,
  Ref<bool> isLoading,
  Ref<bool> hasMore,
  Future<void> Function() loadMore,
  Future<void> Function() refresh,
});

/// 作者文章列表 Composable
AuthorArticlesResult useAuthorArticles(
  ArticleRepository repo, {
  required String authorId,
  int pageSize = 10,
}) {
  final scrollResult = useInfiniteScroll<Article>(
    fetcher: (page) => repo.fetchByAuthor(
      authorId: authorId,
      page: page,
      limit: pageSize,
    ),
    pageSize: pageSize,
  );

  return (
    authorId: authorId,
    articles: scrollResult.items,
    isLoading: scrollResult.isLoading,
    hasMore: scrollResult.hasMore,
    loadMore: scrollResult.loadMore,
    refresh: scrollResult.refresh,
  );
}
