import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:intl/intl.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/topics/logic/use_topics.dart';

@RoutePage()
class TopicsPage extends CompositionWidget {
  const TopicsPage({
    this.api,
    super.key,
  });

  final TwReporterApi? api;

  @override
  Widget Function(BuildContext) setup() {
    // 使用 useTopics composable 取得專題列表
    final TopicsResult topics = useTopics(api!);

    // 捲動控制器，用於檢測是否滾動到底部
    final ReadonlyRef<ScrollController> scrollControllerRef =
        useScrollController();

    // 監聽滾動事件，當接近底部時載入更多
    watchEffect(() {
      final ScrollController scrollController = scrollControllerRef.value;
      if (scrollController.hasClients) {
        final double position = scrollController.position.pixels;
        final double maxScroll = scrollController.position.maxScrollExtent;

        // 當滾動到距離底部 200 像素時，載入更多
        if (position >= maxScroll - 200 &&
            topics.hasMore.value &&
            !topics.isLoading.value) {
          topics.loadMore();
        }
      }
    });

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('專題'),
          ),
          body: _buildBody(topics, scrollControllerRef.value),
        );
  }

  Widget _buildBody(TopicsResult topics, ScrollController scrollController) {
    // 初始載入中狀態
    if (topics.isLoading.value && topics.topics.value.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 空狀態
    if (topics.topics.value.isEmpty) {
      return const Center(
        child: Text('目前沒有專題'),
      );
    }

    // 專題列表
    return RefreshIndicator(
      onRefresh: topics.refresh,
      child: ListView.builder(
        controller: scrollController,
        itemCount: topics.topics.value.length + (topics.hasMore.value ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          // 載入更多指示器
          if (index == topics.topics.value.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('載入更多...'),
              ),
            );
          }

          final Topic topic = topics.topics.value[index];
          return _buildTopicItem(topic);
        },
      ),
    );
  }

  Widget _buildTopicItem(Topic topic) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: 導航到專題詳情頁
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 專題標題
              Text(
                topic.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 專題描述
              if (topic.ogDescription != null)
                Text(
                  topic.ogDescription!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),

              // 發布日期
              Text(
                _formatDate(topic.publishedDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy年MM月dd日');
    return formatter.format(date);
  }
}
