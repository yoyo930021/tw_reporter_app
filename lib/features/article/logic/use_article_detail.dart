import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';

/// 文章詳情結果類型
///
/// 包含文章詳情所需的所有狀態和方法
typedef ArticleDetailResult = ({
  Ref<Article?> article,
  Ref<bool> isLoading,
  Ref<bool> hasError,
  Ref<String?> error,
  Future<void> Function() refresh,
});

/// 文章詳情 Composable
///
/// 用於載入和管理單篇文章的詳細內容
///
/// ## 使用範例
///
/// ```dart
/// final ArticleDetailResult result = useArticleDetail(
///   api,
///   slug: 'article-slug',
/// );
///
/// // 顯示文章內容
/// if (result.isLoading.value) {
///   CircularProgressIndicator()
/// } else if (result.hasError.value) {
///   Text('錯誤: ${result.error.value}')
/// } else if (result.article.value != null) {
///   ArticleContent(article: result.article.value!)
/// }
///
/// // 重新載入
/// result.refresh();
/// ```
///
/// ## 參數
///
/// - [api]: TwReporterApi 實例，用於資料獲取
/// - [slug]: 文章的 slug（唯一識別碼）
///
/// ## 返回值
///
/// - [article]: 文章詳情資料
/// - [isLoading]: 是否正在載入中
/// - [hasError]: 是否發生錯誤
/// - [error]: 錯誤訊息
/// - [refresh]: 重新載入文章的函數
ArticleDetailResult useArticleDetail(
  TwReporterApi api, {
  required String slug,
}) {
  // 文章資料
  final Ref<Article?> article = ref<Article?>(null);

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
      final Article fetchedArticle = await api.fetchArticle(slug);
      article.value = fetchedArticle;
    } catch (e) {
      hasError.value = true;
      error.value = e.toString();
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
    isLoading: isLoading,
    hasError: hasError,
    error: error,
    refresh: refresh,
  );
}
