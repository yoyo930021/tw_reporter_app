import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:intl/intl.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/features/article/logic/use_article_detail.dart';

@RoutePage()
class ArticlePage extends CompositionWidget {
  const ArticlePage({
    this.api,
    super.key,
    @PathParam('slug') required this.slug,
  });

  final TwReporterApi? api;
  final String slug;

  @override
  Widget Function(BuildContext) setup() {
    // 使用 useArticleDetail composable 取得文章資料
    final ArticleDetailResult articleDetail = useArticleDetail(
      api!,
      slug: slug,
    );

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('文章'),
          ),
          body: _buildBody(articleDetail),
        );
  }

  Widget _buildBody(ArticleDetailResult articleDetail) {
    // 錯誤狀態
    if (articleDetail.hasError.value) {
      return _buildErrorView(articleDetail);
    }

    // 載入中狀態
    if (articleDetail.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 文章未載入
    if (articleDetail.article.value == null) {
      return const Center(
        child: Text('文章不存在'),
      );
    }

    // 正常顯示文章內容
    return _buildArticleContent(articleDetail.article.value!);
  }

  Widget _buildErrorView(ArticleDetailResult articleDetail) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              articleDetail.error.value ?? '未知錯誤',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: articleDetail.refresh,
              child: const Text('重試'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleContent(Article article) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 文章標題
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 發布日期
          Text(
            _formatDate(article.publishedDate),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // 文章內容或描述
          if (article.htmlContent != null)
            Text(
              article.htmlContent!,
              style: const TextStyle(fontSize: 16),
            )
          else
            Text(
              article.ogDescription,
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy年MM月dd日');
    return formatter.format(date);
  }
}
