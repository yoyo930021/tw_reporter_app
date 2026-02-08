import 'package:flutter/foundation.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';

/// 專題詳情結果類型
typedef TopicDetailResult = ({
  Ref<Topic> topic,
  Ref<List<Article>> relatedArticles,
  Ref<bool> isLoading,
  Ref<bool> hasError,
  Ref<String?> error,
  Future<void> Function() refresh,
});

/// 專題詳情 Composable
TopicDetailResult useTopicDetail(
  ArticleRepository repo, {
  required Topic topic,
}) {
  final topicRef = ref<Topic>(topic);
  final relatedArticles = ref<List<Article>>(<Article>[]);
  final isLoading = ref<bool>(false);
  final hasError = ref<bool>(false);
  final error = ref<String?>(null);

  Future<void> loadRelatedArticles() async {
    if (isLoading.value) return;

    final ids = topicRef.value.relateds;
    if (ids == null || ids.isEmpty) return;

    isLoading.value = true;
    hasError.value = false;
    error.value = null;

    try {
      relatedArticles.value = await repo.fetchByIds(ids);
    } on Object catch (e, stackTrace) {
      hasError.value = true;
      error.value = e.toString();
      debugPrint('載入相關文章失敗: $e');
      debugPrint('堆疊追蹤: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadRelatedArticles();
  }

  onMounted(loadRelatedArticles);

  return (
    topic: topicRef,
    relatedArticles: relatedArticles,
    isLoading: isLoading,
    hasError: hasError,
    error: error,
    refresh: refresh,
  );
}
