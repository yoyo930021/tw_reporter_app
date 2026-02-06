import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/shared/composables/use_infinite_scroll.dart';

/// 專題列表結果類型
///
/// 包含專題列表所需的所有狀態和方法
typedef TopicsResult = ({
  Ref<List<Topic>> topics,
  Ref<bool> isLoading,
  Ref<bool> hasMore,
  Future<void> Function() loadMore,
  Future<void> Function() refresh,
});

/// 專題列表 Composable
///
/// 用於載入和管理專題列表，支援無限滾動和下拉重新整理
///
/// ## 使用範例
///
/// ```dart
/// final TopicsResult result = useTopics(api);
///
/// // 顯示專題列表
/// ListView.builder(
///   itemCount: result.topics.value.length,
///   itemBuilder: (context, index) {
///     return TopicCard(topic: result.topics.value[index]);
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
/// - [pageSize]: 每頁專題數量，預設 10
///
/// ## 返回值
///
/// - [topics]: 專題列表
/// - [isLoading]: 是否正在載入中
/// - [hasMore]: 是否還有更多專題
/// - [loadMore]: 載入更多專題的函數
/// - [refresh]: 重新整理專題列表的函數
TopicsResult useTopics(
  TwReporterApi api, {
  int pageSize = 10,
}) {
  // 使用 useInfiniteScroll 處理無限滾動邏輯
  final InfiniteScrollResult<Topic> scrollResult = useInfiniteScroll<Topic>(
    fetcher: (int page) => api.fetchTopicsByPage(page: page, limit: pageSize),
    pageSize: pageSize,
  );

  return (
    topics: scrollResult.items,
    isLoading: scrollResult.isLoading,
    hasMore: scrollResult.hasMore,
    loadMore: scrollResult.loadMore,
    refresh: scrollResult.refresh,
  );
}
