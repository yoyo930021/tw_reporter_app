import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/injection_keys.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/features/category/logic/use_category_articles.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';

@RoutePage()
class CategoryPage extends StatelessWidget {
  const CategoryPage({
    @PathParam('category') required this.category,
    super.key,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    return _CategoryPageContent(category: category);
  }
}

class _CategoryPageContent extends CompositionWidget {
  const _CategoryPageContent({required this.category});

  final String category;

  @override
  Widget Function(BuildContext) setup() {
    final repo = inject(AppKeys.articleRepository);
    final categoryArticles = useCategoryArticles(
      repo,
      category: category,
    );
    final readSlugs = ref<Set<String>>(<String>{});
    final theme = useTheme();

    onMounted(() async {
      final storage = await ReadingStorage.create();
      readSlugs.value = storage.getReadSlugs();
    });

    final scrollControllerRef = useScrollController();

    watchEffect(() {
      final scrollController = scrollControllerRef.value;
      if (scrollController.hasClients) {
        final position =
            scrollController.position.pixels;
        final maxScroll =
            scrollController.position.maxScrollExtent;

        if (position >= maxScroll - 200 &&
            categoryArticles.hasMore.value &&
            !categoryArticles.isLoading.value) {
          unawaited(categoryArticles.loadMore());
        }
      }
    });

    Widget buildBody() {
      if (categoryArticles.isLoading.value &&
          categoryArticles.articles.value.isEmpty) {
        return const LoadingIndicator();
      }

      if (categoryArticles.articles.value.isEmpty) {
        return const EmptyState(
          message: '此分類目前沒有文章',
        );
      }

      return RefreshIndicator(
        onRefresh: categoryArticles.refresh,
        child: ListView.builder(
          controller: scrollControllerRef.raw,
          itemCount:
              categoryArticles.articles.value.length +
                  (categoryArticles.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index ==
                categoryArticles.articles.value.length) {
              return Padding(
                padding: AppSpacing.edgeInsetsMd,
                child: Center(
                  child: Text(
                    '載入更多...',
                    style: theme.value.textTheme.bodySmall,
                  ),
                ),
              );
            }

            final article =
                categoryArticles.articles.value[index];
            return ArticleCard(
              article: article,
              isRead: readSlugs.value.contains(article.slug),
              onTap: () {
                unawaited(
                  context.router.push(
                    ArticleRoute(
                      slug: article.slug,
                      heroImageUrl:
                          ArticleCard.getArticleImageUrl(
                        article,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: Text(category),
          ),
          body: buildBody(),
        );
  }
}
