import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/injection_keys.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/features/tag/logic/use_tag_articles.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';

@RoutePage()
class TagDetailPage extends StatelessWidget {
  const TagDetailPage({
    @PathParam('id') required this.tagId,
    required this.tagName,
    super.key,
  });

  final String tagId;
  final String tagName;

  @override
  Widget build(BuildContext context) {
    return _TagDetailPageContent(tagId: tagId, tagName: tagName);
  }
}

class _TagDetailPageContent extends CompositionWidget {
  const _TagDetailPageContent({
    required this.tagId,
    required this.tagName,
  });

  final String tagId;
  final String tagName;

  @override
  Widget Function(BuildContext) setup() {
    final repo = inject(AppKeys.articleRepository);
    final tagArticles = useTagArticles(repo, tagId: tagId);
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
        final position = scrollController.position.pixels;
        final maxScroll = scrollController.position.maxScrollExtent;

        if (position >= maxScroll - 200 &&
            tagArticles.hasMore.value &&
            !tagArticles.isLoading.value) {
          unawaited(tagArticles.loadMore());
        }
      }
    });

    Widget buildBody() {
      if (tagArticles.isLoading.value &&
          tagArticles.articles.value.isEmpty) {
        return const LoadingIndicator();
      }

      if (tagArticles.articles.value.isEmpty) {
        return const EmptyState(
          message: '此標籤目前沒有文章',
        );
      }

      return RefreshIndicator(
        onRefresh: tagArticles.refresh,
        child: ListView.builder(
          controller: scrollControllerRef.raw,
          itemCount: tagArticles.articles.value.length +
              (tagArticles.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == tagArticles.articles.value.length) {
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

            final article = tagArticles.articles.value[index];
            return ArticleCard(
              article: article,
              isRead: readSlugs.value.contains(article.slug),
              onTap: () {
                unawaited(
                  context.router.push(
                    ArticleRoute(
                      slug: article.slug,
                      heroImageUrl:
                          ArticleCard.getArticleImageUrl(article),
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
            title: Text('#$tagName'),
          ),
          body: buildBody(),
        );
  }
}
