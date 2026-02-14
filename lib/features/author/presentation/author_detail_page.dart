import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';
import 'package:tw_reporter_app/core/di/composables.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/features/author/logic/use_author_articles.dart';
import 'package:tw_reporter_app/shared/composables/use_reading.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';

@RoutePage()
class AuthorDetailPage extends StatelessWidget {
  const AuthorDetailPage({
    @PathParam('id') required this.authorId,
    required this.authorName,
    super.key,
    this.authorJobTitle,
    this.authorBio,
    this.authorThumbnailUrl,
  });

  final String authorId;
  final String authorName;
  final String? authorJobTitle;
  final String? authorBio;
  final String? authorThumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return _AuthorDetailPageContent(
      authorId: authorId,
      authorName: authorName,
      authorJobTitle: authorJobTitle,
      authorBio: authorBio,
      authorThumbnailUrl: authorThumbnailUrl,
    );
  }
}

class _AuthorDetailPageContent extends CompositionWidget {
  const _AuthorDetailPageContent({
    required this.authorId,
    required this.authorName,
    this.authorJobTitle,
    this.authorBio,
    this.authorThumbnailUrl,
  });

  final String authorId;
  final String authorName;
  final String? authorJobTitle;
  final String? authorBio;
  final String? authorThumbnailUrl;

  @override
  Widget Function(BuildContext) setup() {
    final repo = useArticleRepository();
    final authorArticles = useAuthorArticles(repo, authorId: authorId);
    final (:readSlugs) = useReadingSlugs();

    final scrollControllerRef = useScrollController();

    watchEffect(() {
      final scrollController = scrollControllerRef.value;
      if (scrollController.hasClients) {
        final position = scrollController.position.pixels;
        final maxScroll = scrollController.position.maxScrollExtent;

        if (position >= maxScroll - 200 &&
            authorArticles.hasMore.value &&
            !authorArticles.isLoading.value) {
          unawaited(authorArticles.loadMore());
        }
      }
    });

    return (BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(authorName),
      ),
      body: _AuthorBody(
        authorArticles: authorArticles,
        readSlugs: readSlugs,
        scrollControllerRef: scrollControllerRef,
        authorHeader: _AuthorHeader(
          authorName: authorName,
          authorJobTitle: authorJobTitle,
          authorBio: authorBio,
          authorThumbnailUrl: authorThumbnailUrl,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private StatelessWidget: Author header
// ---------------------------------------------------------------------------

class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({
    required this.authorName,
    this.authorJobTitle,
    this.authorBio,
    this.authorThumbnailUrl,
  });

  final String authorName;
  final String? authorJobTitle;
  final String? authorBio;
  final String? authorThumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: AppSpacing.edgeInsetsMd,
      child: Column(
        children: <Widget>[
          AppSpacing.verticalSpacerMd,
          if (authorThumbnailUrl != null)
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  CachedNetworkImageProvider(
                    authorThumbnailUrl!,
                    cacheManager:
                        AppCacheManager.instance.imageCacheManager,
                  ),
              backgroundColor: AppColors.grey200,
            )
          else
            CircleAvatar(
              radius: 40,
              backgroundColor: colors.primaryContainer,
              child: Text(
                authorName.isNotEmpty ? authorName[0] : '?',
                style: textTheme.headlineMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          AppSpacing.verticalSpacerMd,
          Text(
            authorName,
            style: textTheme.headlineSmall,
          ),
          if (authorJobTitle != null &&
              authorJobTitle!.isNotEmpty) ...<Widget>[
            AppSpacing.verticalSpacerXs,
            Text(
              authorJobTitle!,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (authorBio != null &&
              authorBio!.isNotEmpty) ...<Widget>[
            AppSpacing.verticalSpacerSm,
            Text(
              authorBio!,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          AppSpacing.verticalSpacerMd,
          const Divider(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private CompositionWidget: Author body (reads reactive state)
// ---------------------------------------------------------------------------

class _AuthorBody extends CompositionWidget {
  const _AuthorBody({
    required this.authorArticles,
    required this.readSlugs,
    required this.scrollControllerRef,
    required this.authorHeader,
  });

  final AuthorArticlesResult authorArticles;
  final ReadonlyRef<Set<String>> readSlugs;
  final ReadonlyRef<ScrollController> scrollControllerRef;
  final Widget authorHeader;

  @override
  Widget Function(BuildContext) setup() {
    final articles = computed(() => authorArticles.articles.value);
    final isLoading = computed(() => authorArticles.isLoading.value);
    final hasMore = computed(() => authorArticles.hasMore.value);

    final itemCount = computed(() {
      final a = articles.value;
      final loading = isLoading.value;
      return 1 + // header
          (loading && a.isEmpty ? 1 : 0) +
          (a.isEmpty && !loading ? 1 : 0) +
          a.length +
          (hasMore.value ? 1 : 0);
    });

    return (BuildContext context) {
      final textTheme = Theme.of(context).textTheme;

      return RefreshIndicator(
        onRefresh: authorArticles.refresh,
        child: ListView.builder(
          controller: scrollControllerRef.raw,
          itemCount: itemCount.value,
          itemBuilder: (context, index) {
            if (index == 0) {
              return authorHeader;
            }

            final contentIndex = index - 1;
            final currentArticles = articles.value;
            final currentIsLoading = isLoading.value;

            if (currentIsLoading && currentArticles.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 64),
                child: LoadingIndicator(),
              );
            }

            if (currentArticles.isEmpty && !currentIsLoading) {
              return const EmptyState(message: '此作者目前沒有文章');
            }

            if (contentIndex == currentArticles.length) {
              return Padding(
                padding: AppSpacing.edgeInsetsMd,
                child: Center(
                  child: Text(
                    '載入更多...',
                    style: textTheme.bodySmall,
                  ),
                ),
              );
            }

            final article = currentArticles[contentIndex];
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
    };
  }
}
