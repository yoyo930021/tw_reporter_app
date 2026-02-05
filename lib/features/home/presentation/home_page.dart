import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/features/home/logic/use_home_data.dart';

// API Provider - 提供 API 實例給子組件
class ApiProvider extends InheritedWidget {
  const ApiProvider({
    required this.api,
    required super.child,
    super.key,
  });

  final TwReporterApi api;

  static ApiProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ApiProvider>();
  }

  static ApiProvider of(BuildContext context) {
    final ApiProvider? result = maybeOf(context);
    assert(result != null, 'No ApiProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ApiProvider oldWidget) => api != oldWidget.api;
}

@RoutePage()
class HomePage extends CompositionWidget {
  const HomePage({this.api, super.key});

  // API - 可選參數，用於測試注入或從 context 獲取
  final TwReporterApi? api;

  @override
  Widget Function(BuildContext) setup() {
    // 使用 useHomeData composable 取得首頁資料
    // API 從構造函數參數獲取（測試時），或稍後從 context 獲取（生產環境）
    final HomeDataResult homeData = useHomeData(api!);

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('報導者'),
          ),
          body: RefreshIndicator(
            onRefresh: homeData.refresh,
            child: _buildBody(homeData),
          ),
        );
  }

  Widget _buildBody(HomeDataResult homeData) {
    // 錯誤狀態
    if (homeData.hasError.value) {
      return _buildErrorView(homeData);
    }

    // 載入中狀態
    if (homeData.isLoadingFeatured.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 空狀態
    final bool hasFeatured = homeData.featuredArticles.value.isNotEmpty;
    final bool hasCategories = homeData.categoryArticles.value.values
        .any((List<Article> articles) => articles.isNotEmpty);

    if (!hasFeatured && !hasCategories) {
      return const Center(
        child: Text('目前沒有文章'),
      );
    }

    // 正常顯示文章列表
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        // 精選文章區塊
        if (hasFeatured) ...<Widget>[
          const Text(
            '精選報導',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...homeData.featuredArticles.value.map(
            (Article article) => _buildArticleCard(article),
          ),
          const SizedBox(height: 24),
        ],

        // 分類文章區塊
        ...homeData.categoryArticles.value.entries.map(
          (MapEntry<String, List<Article>> entry) =>
              _buildCategorySection(entry.key, entry.value),
        ),
      ],
    );
  }

  Widget _buildErrorView(HomeDataResult homeData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            '發生錯誤',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            homeData.error.value ?? '未知錯誤',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: homeData.refresh,
            child: const Text('重試'),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return Builder(
      builder: (BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            context.router.push(ArticleRoute(slug: article.slug));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.ogDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<Article> articles) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          category,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...articles.map(
          (Article article) => _buildArticleCard(article),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
