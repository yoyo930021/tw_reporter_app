import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';

/// 專題詳情結果類型
///
/// 包含專題詳情所需的所有狀態和方法
typedef TopicDetailResult = ({
  Ref<Topic> topic,
  Ref<List<Article>> relatedArticles,
  Ref<bool> isLoading,
  Ref<bool> hasError,
  Ref<String?> error,
  Future<void> Function() refresh,
});

/// 專題詳情 Composable
///
/// 用於載入和管理專題的相關文章
///
/// ## 參數
///
/// - [api]: TwReporterApi 實例，用於資料獲取
/// - [topic]: 專題物件（直接傳入，避免再次查詢）
///
/// ## 返回值
///
/// - [topic]: 專題資料
/// - [relatedArticles]: 相關文章列表
/// - [isLoading]: 是否正在載入中
/// - [hasError]: 是否發生錯誤
/// - [error]: 錯誤訊息
/// - [refresh]: 重新載入相關文章的函數
TopicDetailResult useTopicDetail(
  TwReporterApi api, {
  required Topic topic,
}) {
  final Ref<Topic> topicRef = ref<Topic>(topic);
  final Ref<List<Article>> relatedArticles = ref<List<Article>>(<Article>[]);
  final Ref<bool> isLoading = ref<bool>(false);
  final Ref<bool> hasError = ref<bool>(false);
  final Ref<String?> error = ref<String?>(null);

  /// 載入相關文章
  Future<void> loadRelatedArticles() async {
    if (isLoading.value) return;

    final ids = topicRef.value.relateds;
    if (ids == null || ids.isEmpty) return;

    isLoading.value = true;
    hasError.value = false;
    error.value = null;

    try {
      relatedArticles.value = await api.fetchArticlesByIds(ids);
    } catch (e, stackTrace) {
      hasError.value = true;
      error.value = e.toString();
      print('載入相關文章失敗: $e');
      print('堆疊追蹤: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  /// 重新載入
  Future<void> refresh() async {
    await loadRelatedArticles();
  }

  // 在組件掛載時自動載入相關文章
  onMounted(() {
    loadRelatedArticles();
  });

  return (
    topic: topicRef,
    relatedArticles: relatedArticles,
    isLoading: isLoading,
    hasError: hasError,
    error: error,
    refresh: refresh,
  );
}
