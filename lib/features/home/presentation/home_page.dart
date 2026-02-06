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
class HomePage extends StatelessWidget {
  const HomePage({this.api, super.key});

  // API - 可選參數，用於測試注入或從 context 獲取
  final TwReporterApi? api;

  @override
  Widget build(BuildContext context) {
    // 從 context 獲取 API（如果未提供）
    final apiInstance = api ?? ApiProvider.of(context).api;

    return _HomePageContent(api: apiInstance);
  }
}

class _HomePageContent extends CompositionWidget {
  const _HomePageContent({required this.api});

  final TwReporterApi api;

  @override
  Widget Function(BuildContext) setup() {
    // 使用 useHomeData composable 取得首頁資料
    final HomeDataResult homeData = useHomeData(api);

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
    if (homeData.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 空狀態
    final indexData = homeData.indexData.value;
    if (indexData == null) {
      return const Center(
        child: Text('目前沒有文章'),
      );
    }

    // 正常顯示文章列表
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        // 編輯精選區塊
        if (indexData.editorPicksSection?.isNotEmpty ?? false) ...<Widget>[
          _buildSectionTitle('編輯精選'),
          const SizedBox(height: 12),
          ...indexData.editorPicksSection!.map(
            (Article article) => _buildArticleCard(article),
          ),
          const SizedBox(height: 24),
        ],

        // 最新文章區塊
        if (indexData.latestSection?.isNotEmpty ?? false) ...<Widget>[
          _buildSectionTitle('最新報導'),
          const SizedBox(height: 12),
          ...indexData.latestSection!.map(
            (Article article) => _buildArticleCard(article),
          ),
          const SizedBox(height: 24),
        ],

        // 分類文章區塊
        if (indexData.culture?.isNotEmpty ?? false)
          _buildCategorySection('文化', indexData.culture!),
        if (indexData.econ?.isNotEmpty ?? false)
          _buildCategorySection('經濟產業', indexData.econ!),
        if (indexData.environment?.isNotEmpty ?? false)
          _buildCategorySection('環境', indexData.environment!),
        if (indexData.health?.isNotEmpty ?? false)
          _buildCategorySection('健康', indexData.health!),
        if (indexData.humanrights?.isNotEmpty ?? false)
          _buildCategorySection('人權司法', indexData.humanrights!),
        if (indexData.politicsAndSociety?.isNotEmpty ?? false)
          _buildCategorySection('政治社會', indexData.politicsAndSociety!),
        if (indexData.world?.isNotEmpty ?? false)
          _buildCategorySection('國際', indexData.world!),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
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
