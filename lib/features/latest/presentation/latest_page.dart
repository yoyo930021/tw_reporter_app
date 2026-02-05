import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:intl/intl.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/features/latest/logic/use_latest_articles.dart';

@RoutePage()
class LatestPage extends CompositionWidget {
  const LatestPage({
    this.api,
    super.key,
  });

  final TwReporterApi? api;

  @override
  Widget Function(BuildContext) setup() {
    // 使用 useLatestArticles composable 取得最新文章列表
    final LatestArticlesResult latestArticles = useLatestArticles(api!);

    // 捲動控制器，用於檢測是否滾動到底部
    final ReadonlyRef<ScrollController> scrollControllerRef = useScrollController();

    // 監聽滾動事件，當接近底部時載入更多
    watchEffect(() {
      final ScrollController scrollController = scrollControllerRef.value;
      if (scrollController.hasClients) {
        final double position = scrollController.position.pixels;
        final double maxScroll = scrollController.position.maxScrollExtent;

        // 當滾動到距離底部 200 像素時，載入更多
        if (position >= maxScroll - 200 &&
            latestArticles.hasMore.value &&
            !latestArticles.isLoading.value) {
          latestArticles.loadMore();
        }
      }
    });

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('最新文章'),
          ),
          body: _buildBody(latestArticles, scrollControllerRef.value),
        );
  }

  Widget _buildBody(
    LatestArticlesResult latestArticles,
    ScrollController scrollController,
  ) {
    // 初始載入中狀態
    if (latestArticles.isLoading.value &&
        latestArticles.articles.value.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 空狀態
    if (latestArticles.articles.value.isEmpty) {
      return const Center(
        child: Text('目前沒有文章'),
      );
    }

    // 文章列表
    return RefreshIndicator(
      onRefresh: latestArticles.refresh,
      child: ListView.builder(
        controller: scrollController,
        itemCount: latestArticles.articles.value.length +
            (latestArticles.hasMore.value ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          // 載入更多指示器
          if (index == latestArticles.articles.value.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('載入更多...'),
              ),
            );
          }

          final Article article = latestArticles.articles.value[index];
          return _buildArticleItem(article);
        },
      ),
    );
  }

  Widget _buildArticleItem(Article article) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: 導航到文章詳情頁
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 文章標題
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 文章描述
              Text(
                article.ogDescription,
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
                _formatDate(article.publishedDate),
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
