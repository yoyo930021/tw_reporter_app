import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/features/category/logic/use_category_articles.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';

@RoutePage()
class CategoryPage extends StatelessWidget {
  const CategoryPage({
    this.api,
    super.key,
    @PathParam('category') required this.category,
  });

  final TwReporterApi? api;
  final String category;

  @override
  Widget build(BuildContext context) {
    final apiInstance = api ?? ApiProvider.of(context).api;
    return _CategoryPageContent(api: apiInstance, category: category);
  }
}

class _CategoryPageContent extends CompositionWidget {
  const _CategoryPageContent({
    required this.api,
    required this.category,
  });

  final TwReporterApi api;
  final String category;

  @override
  Widget Function(BuildContext) setup() {
    final CategoryArticlesResult categoryArticles = useCategoryArticles(
      api,
      category: category,
    );
    final Ref<Set<String>> readSlugs = ref<Set<String>>(<String>{});

    onMounted(() async {
      final storage = await ReadingStorage.create();
      readSlugs.value = storage.getReadSlugs();
    });

    final ReadonlyRef<ScrollController> scrollControllerRef =
        useScrollController();

    watchEffect(() {
      final ScrollController scrollController = scrollControllerRef.value;
      if (scrollController.hasClients) {
        final double position = scrollController.position.pixels;
        final double maxScroll = scrollController.position.maxScrollExtent;

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
          body: _buildBody(categoryArticles, scrollControllerRef.value, readSlugs.value),
        );
  }

  Widget _buildBody(
    CategoryArticlesResult categoryArticles,
    ScrollController scrollController,
    Set<String> readSlugs,
  ) {
    if (categoryArticles.isLoading.value &&
        categoryArticles.articles.value.isEmpty) {
      return const LoadingIndicator();
    }

    if (categoryArticles.articles.value.isEmpty) {
      return const EmptyState(message: '此分類目前沒有文章');
    }

    return RefreshIndicator(
      onRefresh: categoryArticles.refresh,
      child: ListView.builder(
        controller: scrollController,
        itemCount: categoryArticles.articles.value.length +
            (categoryArticles.hasMore.value ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index == categoryArticles.articles.value.length) {
            return Padding(
              padding: AppSpacing.edgeInsetsMd,
              child: Center(
                child: Text('載入更多...', style: AppTextStyles.caption),
              ),
            );
          }

          final Article article = categoryArticles.articles.value[index];
          return ArticleCard(
            article: article,
            isRead: readSlugs.contains(article.slug),
            onTap: () {
              context.router.push(ArticleRoute(
                slug: article.slug,
                heroImageUrl: ArticleCard.getArticleImageUrl(article),
              ));
            },
          );
        },
      ),
    );
  }
}
