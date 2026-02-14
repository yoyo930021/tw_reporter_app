import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/constants/subcategory_set.dart';
import 'package:tw_reporter_app/core/di/composables.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
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
    final repo = useArticleRepository();
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

      final articles = categoryArticles.articles.value;
      final subcategories = SubcategorySet.map[category];

      return Column(
        children: <Widget>[
          // 子分類 FilterChip 列
          if (subcategories != null && subcategories.isNotEmpty)
            _SubcategoryChips(
              subcategories: subcategories,
              selectedSubcategoryId:
                  categoryArticles.selectedSubcategoryId.value,
              onSelected: categoryArticles.selectSubcategory,
            ),
          // 文章列表
          Expanded(
            child: articles.isEmpty
                ? const EmptyState(
                    message: '此子分類目前沒有文章',
                  )
                : RefreshIndicator(
                    onRefresh: categoryArticles.refresh,
                    child: ListView.builder(
                      controller: scrollControllerRef.raw,
                      itemCount: articles.length +
                          (categoryArticles.hasMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == articles.length) {
                          return Padding(
                            padding: AppSpacing.edgeInsetsMd,
                            child: Center(
                              child: Text(
                                '載入更多...',
                                style:
                                    theme.value.textTheme.bodySmall,
                              ),
                            ),
                          );
                        }

                        final article = articles[index];
                        return ComputedBuilder(
                          builder: () => ArticleCard(
                            article: article,
                            isRead: readSlugs.value
                                .contains(article.slug),
                            onTap: () {
                              unawaited(
                                context.router.push(
                                  ArticleRoute(
                                    slug: article.slug,
                                    heroImageUrl:
                                        ArticleCard
                                            .getArticleImageUrl(
                                      article,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    }

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: Text(
              AppColors.categoryLabels[category] ?? category,
            ),
          ),
          body: buildBody(),
        );
  }
}

class _SubcategoryChips extends StatelessWidget {
  const _SubcategoryChips({
    required this.subcategories,
    required this.selectedSubcategoryId,
    required this.onSelected,
  });

  final List<({String id, String name})> subcategories;
  final String? selectedSubcategoryId;
  final void Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: ChoiceChip(
              label: const Text('全部'),
              selected: selectedSubcategoryId == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...subcategories.map((sub) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: ChoiceChip(
                label: Text(sub.name),
                selected: selectedSubcategoryId == sub.id,
                onSelected: (_) => onSelected(sub.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}
