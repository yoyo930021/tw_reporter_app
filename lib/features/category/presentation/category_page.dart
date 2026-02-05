import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:intl/intl.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/features/category/logic/use_category_articles.dart';

@RoutePage()
class CategoryPage extends CompositionWidget {
  const CategoryPage({
    this.api,
    super.key,
    @PathParam('category') required this.category,
  });

  final TwReporterApi? api;
  final String category;

  @override
  Widget Function(BuildContext) setup() {
    // 使用 useCategoryArticles composable 取得分類文章列表
    final CategoryArticlesResult categoryArticles = useCategoryArticles(
      api!,
      category: category,
    );

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
            categoryArticles.hasMore.value &&
            !categoryArticles.isLoading.value) {
          categoryArticles.loadMore();
        }
      }
    });

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: Text(category),
          ),
          body: _buildBody(categoryArticles, scrollControllerRef.value),
        );
  }

  Widget _buildBody(
    CategoryArticlesResult categoryArticles,
    ScrollController scrollController,
  ) {
    // 初始載入中狀態
    if (categoryArticles.isLoading.value &&
        categoryArticles.articles.value.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 空狀態
    if (categoryArticles.articles.value.isEmpty) {
      return const Center(
        child: Text('此分類目前沒有文章'),
      );
    }

    // 文章列表
    return RefreshIndicator(
      onRefresh: categoryArticles.refresh,
      child: ListView.builder(
        controller: scrollController,
        itemCount: categoryArticles.articles.value.length +
            (categoryArticles.hasMore.value ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          // 載入更多指示器
          if (index == categoryArticles.articles.value.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('載入更多...'),
              ),
            );
          }

          final Article article = categoryArticles.articles.value[index];
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
