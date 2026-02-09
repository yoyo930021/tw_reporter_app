import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';
import 'package:tw_reporter_app/core/di/injection_keys.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/features/home/logic/use_home_data.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/donate_banner.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/error_view.dart';
import 'package:tw_reporter_app/shared/widgets/horizontal_carousel.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';
import 'package:tw_reporter_app/shared/widgets/section_header.dart';
import 'package:tw_reporter_app/shared/widgets/topic_card.dart';

/// 分類定義
const List<(String, String)> _categories = <(String, String)>[
  ('文化', 'culture'),
  ('經濟產業', 'econ'),
  ('教育', 'education'),
  ('環境', 'environment'),
  ('健康', 'health'),
  ('人權司法', 'humanrights'),
  ('政治社會', 'politics_and_society'),
  ('國際', 'world'),
];

/// 取得分類對應的文章列表
List<Article>? _getCategoryArticles(IndexPageData data, String slug) {
  switch (slug) {
    case 'culture':
      return data.culture;
    case 'econ':
      return data.econ;
    case 'education':
      return data.education;
    case 'environment':
      return data.environment;
    case 'health':
      return data.health;
    case 'humanrights':
      return data.humanrights;
    case 'politics_and_society':
      return data.politicsAndSociety;
    case 'world':
      return data.world;
    default:
      return null;
  }
}

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomePageContent();
  }
}

class _HomePageContent extends CompositionWidget {
  const _HomePageContent();

  @override
  Widget Function(BuildContext) setup() {
    final homeRepo = inject(AppKeys.homeRepository);
    final articleRepo = inject(AppKeys.articleRepository);
    final homeData = useHomeData(homeRepo);
    final theme = useTheme();

    Widget buildFeaturedArticle(Article article) {
      final imageUrl = ArticleCard.getArticleImageUrl(article);

      return Builder(
        builder: (context) => GestureDetector(
          onTap: () {
            unawaited(context.router.push(ArticleRoute(
              slug: article.slug,
              heroImageUrl: imageUrl,
            )));
          },
          child: Padding(
            padding: AppSpacing.edgeInsetsHorizontalMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      cacheManager:
                          AppCacheManager.instance.imageCacheManager,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        height: 220,
                        color: AppColors.grey200,
                        child: const Center(
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        height: 220,
                        color: AppColors.grey200,
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.grey400),
                      ),
                    ),
                  ),
                AppSpacing.verticalSpacerSm,
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.displayMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  article.ogDescription,
                  style:
                      Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildHorizontalArticleSection(
      List<Article> articles, {
      double imageHeight = 140,
    }) {
      return HorizontalCarousel(
        itemWidth: 280,
        height: imageHeight + 136,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          final imageUrl = ArticleCard.getArticleImageUrl(article);

          return GestureDetector(
            onTap: () {
              unawaited(context.router.push(ArticleRoute(
                slug: article.slug,
                heroImageUrl: imageUrl,
              )));
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      cacheManager:
                          AppCacheManager.instance.imageCacheManager,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        height: imageHeight,
                        color: AppColors.grey200,
                      ),
                      errorWidget: (_, _, _) => Container(
                        height: imageHeight,
                        color: AppColors.grey200,
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.grey400),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            article.title,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppSpacing.verticalSpacerXs,
                          Expanded(
                            child: Text(
                              article.ogDescription,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget buildTopicsCarousel(IndexPageData indexData) {
      final topics = <Topic>[
        ...?indexData.latestTopicSection,
        ...?indexData.topicsSection,
      ];

      return HorizontalCarousel(
        itemWidth: 280,
        height: 400,
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return TopicCard(
            topic: topic,
            onTap: () {
              unawaited(context.router.push(TopicDetailRoute(
                slug: topic.slug,
                topic: topic,
              )));
            },
          );
        },
      );
    }

    Widget buildArticleCard(Article article) {
      return Builder(
        builder: (context) => ArticleCard(
          article: article,
          onTap: () {
            unawaited(context.router.push(ArticleRoute(
              slug: article.slug,
              heroImageUrl: ArticleCard.getArticleImageUrl(article),
            )));
          },
        ),
      );
    }

    Widget buildCategoriesRow(IndexPageData indexData) {
      final items = <(String, String, Article)>[];
      for (final (String label, String slug) in _categories) {
        final articles = _getCategoryArticles(indexData, slug);
        if (articles != null && articles.isNotEmpty) {
          items.add((label, slug, articles.first));
        }
      }

      if (items.isEmpty) return const SizedBox.shrink();

      return HorizontalCarousel(
        itemWidth: 280,
        height: 140 + 136,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final (String label, String slug, Article article) =
              items[index];
          final imageUrl = ArticleCard.getArticleImageUrl(article);

          return GestureDetector(
            onTap: () {
              unawaited(context.router.push(ArticleRoute(
                slug: article.slug,
                heroImageUrl: imageUrl,
              )));
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      cacheManager:
                          AppCacheManager.instance.imageCacheManager,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        height: 140,
                        color: AppColors.grey200,
                      ),
                      errorWidget: (_, _, _) => Container(
                        height: 140,
                        color: AppColors.grey200,
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.grey400),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            label,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.verticalSpacerXs,
                          Text(
                            article.title,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppSpacing.verticalSpacerXs,
                          Expanded(
                            child: Text(
                              article.ogDescription,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget buildBody() {
      // 錯誤狀態
      if (homeData.hasError.value) {
        return ErrorView(
          message: homeData.error.value ?? '未知錯誤',
          onRetry: homeData.refresh,
        );
      }

      // 載入中狀態
      if (homeData.isLoading.value) {
        return const LoadingIndicator();
      }

      // 空狀態
      final indexData = homeData.indexData.value;
      if (indexData == null) {
        return const EmptyState(message: '目前沒有文章');
      }

      final hasTopics =
          (indexData.latestTopicSection?.isNotEmpty ?? false) ||
              (indexData.topicsSection?.isNotEmpty ?? false);

      // 正常顯示
      return ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: <Widget>[
          // 1. 分類輪播
          buildCategoriesRow(indexData),

          // 2. 編輯精選
          if (indexData.editorPicksSection?.isNotEmpty ??
              false) ...<Widget>[
            const Padding(
              padding: AppSpacing.edgeInsetsHorizontalMd,
              child: SectionHeader(title: '編輯精選'),
            ),
            AppSpacing.verticalSpacerSm,
            buildFeaturedArticle(
                indexData.editorPicksSection!.first),
            if (indexData.editorPicksSection!.length >
                1) ...<Widget>[
              AppSpacing.verticalSpacerSm,
              buildHorizontalArticleSection(
                indexData.editorPicksSection!.sublist(1),
              ),
            ],
            AppSpacing.verticalSpacerLg,
          ],

          // 3. 最新專題
          if (hasTopics) ...<Widget>[
            const Padding(
              padding: AppSpacing.edgeInsetsHorizontalMd,
              child: SectionHeader(title: '最新專題'),
            ),
            AppSpacing.verticalSpacerSm,
            buildTopicsCarousel(indexData),
            AppSpacing.verticalSpacerLg,
          ],

          // 4. 最新報導
          if (indexData.latestSection?.isNotEmpty ??
              false) ...<Widget>[
            const Padding(
              padding: AppSpacing.edgeInsetsHorizontalMd,
              child: SectionHeader(title: '最新報導'),
            ),
            AppSpacing.verticalSpacerSm,
            ...indexData.latestSection!.map(buildArticleCard),
            AppSpacing.verticalSpacerLg,
          ],

          // 5. 評論
          if (indexData.reviewsSection?.isNotEmpty ??
              false) ...<Widget>[
            const Padding(
              padding: AppSpacing.edgeInsetsHorizontalMd,
              child: SectionHeader(title: '評論'),
            ),
            AppSpacing.verticalSpacerSm,
            buildHorizontalArticleSection(
                indexData.reviewsSection!),
            AppSpacing.verticalSpacerLg,
          ],

          // 6. 攝影
          if (indexData.photosSection?.isNotEmpty ??
              false) ...<Widget>[
            const Padding(
              padding: AppSpacing.edgeInsetsHorizontalMd,
              child: SectionHeader(title: '攝影'),
            ),
            AppSpacing.verticalSpacerSm,
            buildHorizontalArticleSection(
              indexData.photosSection!,
              imageHeight: 200,
            ),
            AppSpacing.verticalSpacerLg,
          ],

          // 7. 多媒體
          if (indexData.infographicsSection?.isNotEmpty ??
              false) ...<Widget>[
            const Padding(
              padding: AppSpacing.edgeInsetsHorizontalMd,
              child: SectionHeader(title: '多媒體'),
            ),
            AppSpacing.verticalSpacerSm,
            buildHorizontalArticleSection(
                indexData.infographicsSection!),
            AppSpacing.verticalSpacerLg,
          ],

          // 8. 贊助報導者
          AppSpacing.verticalSpacerLg,
          const DonateBanner(),
          AppSpacing.verticalSpacerLg,
        ],
      );
    }

    return (BuildContext context) {
      final isDark = theme.value.brightness == Brightness.dark;
      final logoAsset = isDark
          ? 'assets/images/logo-header-dark.svg'
          : 'assets/images/logo-header.svg';

      return Scaffold(
        appBar: AppBar(
          title: SvgPicture.asset(
            logoAsset,
            key: ValueKey<String>(logoAsset),
            height: 24,
            semanticsLabel: '報導者',
          ),
          actions: <Widget>[
            SearchAnchor(
              isFullScreen: true,
              builder: (searchContext, controller) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    controller
                      ..clear()
                      ..openView();
                  },
                  tooltip: '搜尋文章',
                );
              },
              suggestionsBuilder:
                  (searchContext, controller) async {
                final query = controller.text.trim();
                if (query.isEmpty) return <Widget>[];

                await Future<void>.delayed(
                    const Duration(milliseconds: 300));
                if (controller.text.trim() != query) {
                  return <Widget>[];
                }

                try {
                  final results = await articleRepo.search(
                    query: query,
                    page: 1,
                  );

                  if (results.isEmpty) {
                    return <Widget>[
                      const ListTile(
                        leading: Icon(Icons.search_off),
                        title: Text('找不到相關文章'),
                      ),
                    ];
                  }

                  return results.map((article) {
                    final imageUrl =
                        ArticleCard.getArticleImageUrl(article);
                    return ListTile(
                      leading: imageUrl != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(4),
                              child: Image.network(
                                imageUrl,
                                width: 56,
                                height: 42,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox(
                                  width: 56,
                                  height: 42,
                                  child: Icon(Icons.image,
                                      color: Colors.grey),
                                ),
                              ),
                            )
                          : null,
                      title: Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: article
                              .ogDescription.isNotEmpty
                          ? Text(
                              article.ogDescription,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        controller.closeView('');
                        unawaited(
                            context.router.push(ArticleRoute(
                          slug: article.slug,
                          heroImageUrl: imageUrl,
                        )));
                      },
                    );
                  });
                } on Object {
                  return <Widget>[
                    const ListTile(
                      leading: Icon(Icons.error_outline),
                      title: Text('搜尋失敗，請稍後再試'),
                    ),
                  ];
                }
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: homeData.refresh,
          child: buildBody(),
        ),
      );
    };
  }
}
