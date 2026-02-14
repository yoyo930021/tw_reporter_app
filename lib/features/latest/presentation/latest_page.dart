import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/composables.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/features/latest/logic/use_latest_articles.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';

@RoutePage()
class LatestPage extends StatelessWidget {
  const LatestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LatestPageContent();
  }
}

class _LatestPageContent extends CompositionWidget {
  const _LatestPageContent();

  @override
  Widget Function(BuildContext) setup() {
    final repo = useArticleRepository();
    final latestArticles = useLatestArticles(repo);
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
            latestArticles.hasMore.value &&
            !latestArticles.isLoading.value) {
          unawaited(latestArticles.loadMore());
        }
      }
    });

    Widget buildBody() {
      if (latestArticles.isLoading.value &&
          latestArticles.articles.value.isEmpty) {
        return const LoadingIndicator();
      }

      if (latestArticles.articles.value.isEmpty) {
        return const EmptyState(message: '目前沒有文章');
      }

      return RefreshIndicator(
        onRefresh: latestArticles.refresh,
        child: ListView.builder(
          controller: scrollControllerRef.raw,
          itemCount: latestArticles.articles.value.length +
              (latestArticles.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index ==
                latestArticles.articles.value.length) {
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
                latestArticles.articles.value[index];
            return ComputedBuilder(
              builder: () => ArticleCard(
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
              ),
            );
          },
        ),
      );
    }

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('最新文章'),
          ),
          body: buildBody(),
        );
  }
}
