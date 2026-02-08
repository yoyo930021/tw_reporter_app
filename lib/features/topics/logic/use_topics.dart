import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/repositories/topic_repository.dart';
import 'package:tw_reporter_app/shared/composables/use_infinite_scroll.dart';

/// 專題列表結果類型
typedef TopicsResult = ({
  Ref<List<Topic>> topics,
  Ref<bool> isLoading,
  Ref<bool> hasMore,
  Future<void> Function() loadMore,
  Future<void> Function() refresh,
});

/// 專題列表 Composable
TopicsResult useTopics(
  TopicRepository repo, {
  int pageSize = 10,
}) {
  final scrollResult = useInfiniteScroll<Topic>(
    fetcher: (page) => repo.fetchTopics(
      page: page,
      limit: pageSize,
    ),
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
