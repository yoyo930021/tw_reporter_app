import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/features/latest/logic/use_latest_articles.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';

@RoutePage()
class LatestPage extends StatelessWidget {
  const LatestPage({this.api, super.key});

  final TwReporterApi? api;

  @override
  Widget build(BuildContext context) {
    final apiInstance = api ?? ApiProvider.of(context).api;
    return _LatestPageContent(api: apiInstance);
  }
}

class _LatestPageContent extends CompositionWidget {
  const _LatestPageContent({required this.api});

  final TwReporterApi api;

  @override
  Widget Function(BuildContext) setup() {
    final LatestArticlesResult latestArticles = useLatestArticles(api);
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
          body: _buildBody(latestArticles, scrollControllerRef.value, readSlugs.value),
        );
  }

  Widget _buildBody(
    LatestArticlesResult latestArticles,
    ScrollController scrollController,
    Set<String> readSlugs,
  ) {
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
        controller: scrollController,
        itemCount: latestArticles.articles.value.length +
            (latestArticles.hasMore.value ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index == latestArticles.articles.value.length) {
            return Padding(
              padding: AppSpacing.edgeInsetsMd,
              child: Center(
                child: Text('載入更多...', style: AppTextStyles.caption),
              ),
            );
          }

          final Article article = latestArticles.articles.value[index];
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
