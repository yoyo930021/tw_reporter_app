import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';

/// 文章詳情結果類型
///
/// 包含文章詳情所需的所有狀態和方法
typedef ArticleDetailResult = ({
  Ref<Article?> article,
  Ref<List<Article>> relatedArticles,
  Ref<bool> isLoading,
  Ref<bool> hasError,
  Ref<String?> error,
  Future<void> Function() refresh,
});

/// 文章詳情 Composable
///
/// 用於載入和管理單篇文章的詳細內容
ArticleDetailResult useArticleDetail(
  TwReporterApi api, {
  required String slug,
}) {
  // 文章資料
  final Ref<Article?> article = ref<Article?>(null);

  // 相關文章
  final Ref<List<Article>> relatedArticles = ref<List<Article>>(<Article>[]);

  // 載入狀態
  final Ref<bool> isLoading = ref<bool>(false);

  // 錯誤狀態
  final Ref<bool> hasError = ref<bool>(false);
  final Ref<String?> error = ref<String?>(null);

  /// 載入文章詳情
  Future<void> loadArticle() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    error.value = null;

    try {
      final ApiResponse<Article> response = await api.fetchPost(slug);
      article.value = response.data;

      // 載入相關文章
      final List<String>? relatedIds = response.data.relateds;
      if (relatedIds != null && relatedIds.isNotEmpty) {
        try {
          relatedArticles.value = await api.fetchArticlesByIds(relatedIds);
        } catch (_) {
          // 相關文章載入失敗不影響主文章顯示
        }
      }
    } catch (e, stackTrace) {
      hasError.value = true;
      error.value = e.toString();
      print('載入文章詳情失敗: $e');
      print('堆疊追蹤: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  /// 重新載入文章
  Future<void> refresh() async {
    await loadArticle();
  }

  // 在組件掛載時自動載入文章
  onMounted(() {
    loadArticle();
  });

  return (
    article: article,
    relatedArticles: relatedArticles,
    isLoading: isLoading,
    hasError: hasError,
    error: error,
    refresh: refresh,
  );
}
