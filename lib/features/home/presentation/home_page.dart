import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/features/home/logic/use_home_data.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/error_view.dart';
import 'package:tw_reporter_app/shared/widgets/horizontal_carousel.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';
import 'package:tw_reporter_app/shared/widgets/section_header.dart';
import 'package:tw_reporter_app/shared/widgets/topic_card.dart';

// API Provider - 提供 API 實例給子組件
class ApiProvider extends InheritedWidget {
  const ApiProvider({
    required this.api,
    required super.child,
    super.key,
  });

  final TwReporterApi api;

  static ApiProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ApiProvider>();
  }

  static ApiProvider of(BuildContext context) {
    final ApiProvider? result = maybeOf(context);
    assert(result != null, 'No ApiProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ApiProvider oldWidget) => api != oldWidget.api;
}

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({this.api, super.key});

  // API - 可選參數，用於測試注入或從 context 獲取
  final TwReporterApi? api;

  @override
  Widget build(BuildContext context) {
    // 從 context 獲取 API（如果未提供）
    final apiInstance = api ?? ApiProvider.of(context).api;

    return _HomePageContent(api: apiInstance);
  }
}

class _HomePageContent extends CompositionWidget {
  const _HomePageContent({required this.api});

  final TwReporterApi api;

  @override
  Widget Function(BuildContext) setup() {
    // 使用 useHomeData composable 取得首頁資料
    final HomeDataResult homeData = useHomeData(api);

    return (BuildContext context) {
      final Brightness brightness = Theme.of(context).brightness;
      final String logoAsset = brightness == Brightness.dark
          ? 'assets/images/logo-header-dark.svg'
          : 'assets/images/logo-header.svg';

      return Scaffold(
        appBar: AppBar(
          title: SvgPicture.asset(
            logoAsset,
            height: 24,
            semanticsLabel: '報導者',
          ),
          actions: <Widget>[
            SearchAnchor(
              isFullScreen: true,
              builder: (BuildContext searchContext,
                  SearchController controller) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    controller.clear();
                    controller.openView();
                  },
                  tooltip: '搜尋文章',
                );
              },
              suggestionsBuilder: (BuildContext searchContext,
                  SearchController controller) async {
                final String query = controller.text.trim();
                if (query.isEmpty) return <Widget>[];

                // 簡易防抖
                await Future<void>.delayed(
                    const Duration(milliseconds: 300));
                if (controller.text.trim() != query) {
                  return <Widget>[];
                }

                try {
                  final List<Article> results =
                      await api.searchArticles(
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

                  return results.map((Article article) {
                    final String? imageUrl =
                        ArticleCard.getArticleImageUrl(article);
                    return ListTile(
                      leading: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                imageUrl,
                                width: 56,
                                height: 42,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
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
                      subtitle: article.ogDescription.isNotEmpty
                          ? Text(
                              article.ogDescription,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        controller.closeView('');
                        context.router.push(ArticleRoute(
                          slug: article.slug,
                          heroImageUrl: imageUrl,
                        ));
                      },
                    );
                  });
                } catch (e) {
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
          child: _buildBody(homeData),
        ),
      );
    };
  }

  Widget _buildBody(HomeDataResult homeData) {
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

    // 正常顯示
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: <Widget>[
        // 1. 分類輪播 — 單條水平輪播
        _buildCategoriesRow(indexData),

        // 2. 編輯精選 — 第一篇大圖卡 + 其餘水平輪播
        if (indexData.editorPicksSection?.isNotEmpty ?? false) ...<Widget>[
          Padding(
            padding: AppSpacing.edgeInsetsHorizontalMd,
            child: const SectionHeader(title: '編輯精選'),
          ),
          AppSpacing.verticalSpacerSm,
          _buildFeaturedArticle(indexData.editorPicksSection!.first),
          if (indexData.editorPicksSection!.length > 1) ...<Widget>[
            AppSpacing.verticalSpacerSm,
            _buildHorizontalArticleSection(
              indexData.editorPicksSection!.sublist(1),
            ),
          ],
          AppSpacing.verticalSpacerLg,
        ],

        // 3. 最新專題 — latestTopicSection + topicsSection 合併水平輪播
        if (_hasTopics(indexData)) ...<Widget>[
          Padding(
            padding: AppSpacing.edgeInsetsHorizontalMd,
            child: const SectionHeader(title: '最新專題'),
          ),
          AppSpacing.verticalSpacerSm,
          _buildTopicsCarousel(indexData),
          AppSpacing.verticalSpacerLg,
        ],

        // 4. 最新報導 — 垂直 ArticleCard（維持現有）
        if (indexData.latestSection?.isNotEmpty ?? false) ...<Widget>[
          Padding(
            padding: AppSpacing.edgeInsetsHorizontalMd,
            child: const SectionHeader(title: '最新報導'),
          ),
          AppSpacing.verticalSpacerSm,
          ...indexData.latestSection!.map(
            (Article article) => _buildArticleCard(article),
          ),
          AppSpacing.verticalSpacerLg,
        ],

        // 5. 評論 — 水平輪播
        if (indexData.reviewsSection?.isNotEmpty ?? false) ...<Widget>[
          Padding(
            padding: AppSpacing.edgeInsetsHorizontalMd,
            child: const SectionHeader(title: '評論'),
          ),
          AppSpacing.verticalSpacerSm,
          _buildHorizontalArticleSection(indexData.reviewsSection!),
          AppSpacing.verticalSpacerLg,
        ],

        // 6. 攝影 — 水平輪播
        if (indexData.photosSection?.isNotEmpty ?? false) ...<Widget>[
          Padding(
            padding: AppSpacing.edgeInsetsHorizontalMd,
            child: const SectionHeader(title: '攝影'),
          ),
          AppSpacing.verticalSpacerSm,
          _buildHorizontalArticleSection(
            indexData.photosSection!,
            imageHeight: 200,
          ),
          AppSpacing.verticalSpacerLg,
        ],

        // 7. 多媒體 — 水平輪播
        if (indexData.infographicsSection?.isNotEmpty ?? false) ...<Widget>[
          Padding(
            padding: AppSpacing.edgeInsetsHorizontalMd,
            child: const SectionHeader(title: '多媒體'),
          ),
          AppSpacing.verticalSpacerSm,
          _buildHorizontalArticleSection(indexData.infographicsSection!),
          AppSpacing.verticalSpacerLg,
        ],
      ],
    );
  }

  bool _hasTopics(IndexPageData indexData) {
    return (indexData.latestTopicSection?.isNotEmpty ?? false) ||
        (indexData.topicsSection?.isNotEmpty ?? false);
  }

  /// 全寬大圖卡 — 編輯精選第一篇
  Widget _buildFeaturedArticle(Article article) {
    final String? imageUrl = ArticleCard.getArticleImageUrl(article);

    return Builder(
      builder: (BuildContext context) => GestureDetector(
        onTap: () {
          context.router.push(ArticleRoute(
            slug: article.slug,
            heroImageUrl: imageUrl,
          ));
        },
        child: Padding(
          padding: AppSpacing.edgeInsetsHorizontalMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 220,
                      color: AppColors.grey200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
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
                style: AppTextStyles.headline2,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.verticalSpacerXs,
              Text(
                article.ogDescription,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
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

  /// 水平輪播文章區塊
  Widget _buildHorizontalArticleSection(
    List<Article> articles, {
    double imageHeight = 140,
  }) {
    return HorizontalCarousel(
      itemWidth: 280,
      height: imageHeight + 136,
      itemCount: articles.length,
      itemBuilder: (BuildContext context, int index) {
        final Article article = articles[index];
        final String? imageUrl = ArticleCard.getArticleImageUrl(article);

        return GestureDetector(
          onTap: () {
            context.router.push(ArticleRoute(
              slug: article.slug,
              heroImageUrl: imageUrl,
            ));
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: imageHeight,
                      color: AppColors.grey200,
                    ),
                    errorWidget: (_, __, ___) => Container(
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
                          style: AppTextStyles.headline3.copyWith(fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.verticalSpacerXs,
                        Expanded(
                          child: Text(
                            article.ogDescription,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
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

  /// 專題水平輪播
  Widget _buildTopicsCarousel(IndexPageData indexData) {
    final List<Topic> topics = <Topic>[
      ...?indexData.latestTopicSection,
      ...?indexData.topicsSection,
    ];

    return HorizontalCarousel(
      itemWidth: 280,
      height: 400,
      itemCount: topics.length,
      itemBuilder: (BuildContext context, int index) {
        final Topic topic = topics[index];
        return TopicCard(
          topic: topic,
          onTap: () {
            context.router.push(TopicDetailRoute(
              slug: topic.slug,
              topic: topic,
            ));
          },
        );
      },
    );
  }

  Widget _buildArticleCard(Article article) {
    return Builder(
      builder: (BuildContext context) => ArticleCard(
        article: article,
        onTap: () {
          context.router.push(ArticleRoute(
            slug: article.slug,
            heroImageUrl: ArticleCard.getArticleImageUrl(article),
          ));
        },
      ),
    );
  }

  /// 分類定義
  static const List<(String, String)> _categories = <(String, String)>[
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

  /// 各分類精選 — 單條水平輪播，每項是一個分類（標題 + 第一篇文章）
  Widget _buildCategoriesRow(IndexPageData indexData) {
    final List<(String, String, Article)> items =
        <(String, String, Article)>[];
    for (final (String label, String slug) in _categories) {
      final List<Article>? articles = _getCategoryArticles(indexData, slug);
      if (articles != null && articles.isNotEmpty) {
        items.add((label, slug, articles.first));
      }
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return HorizontalCarousel(
      itemWidth: 280,
      height: 140 + 136,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final (String label, String slug, Article article) = items[index];
        final String? imageUrl = ArticleCard.getArticleImageUrl(article);

        return GestureDetector(
          onTap: () {
            context.router.push(ArticleRoute(
              slug: article.slug,
              heroImageUrl: imageUrl,
            ));
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 140,
                      color: AppColors.grey200,
                    ),
                    errorWidget: (_, __, ___) => Container(
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
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSpacing.verticalSpacerXs,
                        Text(
                          article.title,
                          style: AppTextStyles.headline3
                              .copyWith(fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.verticalSpacerXs,
                        Expanded(
                          child: Text(
                            article.ogDescription,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
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
}
