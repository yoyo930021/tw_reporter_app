import 'package:flutter/foundation.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';

/// 文章詳情結果類型
typedef ArticleDetailResult = ({
  Ref<Article?> article,
  Ref<List<Article>> relatedArticles,
  Ref<bool> isLoading,
  Ref<bool> hasError,
  Ref<String?> error,
  Future<void> Function() refresh,
});

/// 文章詳情 Composable
ArticleDetailResult useArticleDetail(
  ArticleRepository repo, {
  required String slug,
}) {
  final article = ref<Article?>(null);
  final relatedArticles = ref<List<Article>>(<Article>[]);
  final isLoading = ref<bool>(false);
  final hasError = ref<bool>(false);
  final error = ref<String?>(null);

  Future<void> loadArticle() async {
    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    error.value = null;

    try {
      final data = await repo.fetchById(slug: slug);
      article.value = data;

      final relatedIds = data.relateds;
      if (relatedIds != null && relatedIds.isNotEmpty) {
        try {
          relatedArticles.value =
              await repo.fetchByIds(relatedIds);
        } on Object catch (_) {
          // 相關文章載入失敗不影響主文章顯示
        }
      }
    } on Object catch (e, stackTrace) {
      hasError.value = true;
      error.value = e.toString();
      debugPrint('載入文章詳情失敗: $e');
      debugPrint('堆疊追蹤: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadArticle();
  }

  onMounted(loadArticle);

  return (
    article: article,
    relatedArticles: relatedArticles,
    isLoading: isLoading,
    hasError: hasError,
    error: error,
    refresh: refresh,
  );
}
