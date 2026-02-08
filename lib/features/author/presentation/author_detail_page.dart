import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/injection_keys.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/features/author/logic/use_author_articles.dart';
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
    final repo = inject(AppKeys.articleRepository);
    final authorArticles = useAuthorArticles(repo, authorId: authorId);
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
            authorArticles.hasMore.value &&
            !authorArticles.isLoading.value) {
          unawaited(authorArticles.loadMore());
        }
      }
    });

    Widget buildAuthorHeader() {
      final colors = theme.value.colorScheme;
      final textTheme = theme.value.textTheme;

      return Padding(
        padding: AppSpacing.edgeInsetsMd,
        child: Column(
          children: <Widget>[
            AppSpacing.verticalSpacerMd,
            if (authorThumbnailUrl != null)
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    CachedNetworkImageProvider(authorThumbnailUrl!),
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

    Widget buildBody() {
      final articles = authorArticles.articles.value;
      final isLoading = authorArticles.isLoading.value;

      return RefreshIndicator(
        onRefresh: authorArticles.refresh,
        child: ListView.builder(
          controller: scrollControllerRef.raw,
          itemCount:
              1 + // header
              (isLoading && articles.isEmpty ? 1 : 0) +
              (articles.isEmpty && !isLoading ? 1 : 0) +
              articles.length +
              (authorArticles.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            // Author header
            if (index == 0) {
              return buildAuthorHeader();
            }

            final contentIndex = index - 1;

            // Loading state
            if (isLoading && articles.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 64),
                child: LoadingIndicator(),
              );
            }

            // Empty state
            if (articles.isEmpty && !isLoading) {
              return const EmptyState(message: '此作者目前沒有文章');
            }

            // Load more indicator
            if (contentIndex == articles.length) {
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

            final article = articles[contentIndex];
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
        title: Text(authorName),
      ),
      body: buildBody(),
    );
  }
}
