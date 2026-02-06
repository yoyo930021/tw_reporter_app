import 'dart:convert' show base64Url, utf8;
import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/author.dart';
import 'package:tw_reporter_app/core/models/image_size.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/features/article/logic/use_article_detail.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/shared/utils/content_renderer.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/category_badge.dart';
import 'package:tw_reporter_app/shared/widgets/embedded_video_player.dart';
import 'package:tw_reporter_app/shared/widgets/embedded_webview.dart';
import 'package:tw_reporter_app/shared/widgets/error_view.dart';
import 'package:tw_reporter_app/shared/widgets/horizontal_carousel.dart';
import 'package:tw_reporter_app/shared/widgets/image_diff_viewer.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';
import 'package:tw_reporter_app/shared/widgets/slideshow_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ArticlePage extends StatelessWidget {
  const ArticlePage({
    this.api,
    this.storage,
    super.key,
    @PathParam('slug') required this.slug,
    this.heroImageUrl,
  });

  final TwReporterApi? api;
  final ReadingStorage? storage;
  final String slug;
  final String? heroImageUrl;

  @override
  Widget build(BuildContext context) {
    final apiInstance = api ?? ApiProvider.of(context).api;
    return _ArticlePageContent(
      api: apiInstance,
      storage: storage,
      slug: slug,
      heroImageUrl: heroImageUrl,
    );
  }
}

class _ArticlePageContent extends CompositionWidget {
  const _ArticlePageContent({
    required this.api,
    this.storage,
    required this.slug,
    this.heroImageUrl,
  });

  final TwReporterApi api;
  final ReadingStorage? storage;
  final String slug;
  final String? heroImageUrl;

  @override
  Widget Function(BuildContext) setup() {
    final ArticleDetailResult articleDetail = useArticleDetail(
      api,
      slug: slug,
    );

    // 收藏狀態
    final Ref<bool> isBookmarked = ref<bool>(false);
    final Ref<ReadingStorage?> storageRef = ref<ReadingStorage?>(storage);

    // 是否已記錄過閱讀
    final Ref<bool> hasRecordedReading = ref<bool>(false);

    // 追蹤展開比例（用於動態 icon 顏色）
    final Ref<double> expandRatioRef = ref<double>(1.0);

    onMounted(() async {
      if (storageRef.value == null) {
        storageRef.value = await ReadingStorage.create();
      }
      isBookmarked.value = storageRef.value!.isBookmarked(slug);
    });

    // 監聽文章載入完成後自動記錄閱讀
    void recordReadingIfNeeded(Article? article) {
      if (article != null &&
          !hasRecordedReading.value &&
          storageRef.value != null) {
        hasRecordedReading.value = true;
        final String? imageUrl = _getImageUrl(article);
        storageRef.value!.addToHistory(
          slug,
          article.title,
          imageUrl,
          DateTime.now(),
        );
      }
    }

    return (BuildContext context) {
      final article = articleDetail.article.value;

      // 自動記錄閱讀
      recordReadingIfNeeded(article);

      // Use loaded article image, fall back to passed-in heroImageUrl
      final String? imageUrl =
          article != null ? _getImageUrl(article) : heroImageUrl;
      final String title = article?.title ?? '';
      final bool hasImage = imageUrl != null;

      void toggleBookmark() {
        final s = storageRef.value;
        if (s == null || article == null) return;

        if (isBookmarked.value) {
          s.removeBookmark(slug);
          isBookmarked.value = false;
        } else {
          s.addBookmark(slug, article.title, imageUrl);
          isBookmarked.value = true;
        }
      }

      return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: hasImage ? 300.0 : 160.0,
              pinned: true,
              foregroundColor: hasImage
                  ? Color.lerp(
                      Colors.black, Colors.white, expandRatioRef.value)
                  : Colors.black,
              iconTheme: IconThemeData(
                color: hasImage
                    ? Color.lerp(
                        Colors.black, Colors.white, expandRatioRef.value)
                    : Colors.black,
              ),
              actions: <Widget>[
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String value) {
                    switch (value) {
                      case 'bookmark':
                        toggleBookmark();
                      case 'share':
                        _shareArticle(title);
                      case 'browser':
                        launchUrl(
                          Uri.parse('https://www.twreporter.org/a/$slug'),
                          mode: LaunchMode.inAppBrowserView,
                        );
                    }
                  },
                  itemBuilder: (BuildContext ctx) {
                    final Color menuIconColor =
                        Theme.of(ctx).iconTheme.color ?? Colors.black87;
                    return <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'bookmark',
                        child: Row(
                          children: <Widget>[
                            Icon(
                              isBookmarked.value
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isBookmarked.value
                                  ? AppColors.accent
                                  : menuIconColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(isBookmarked.value ? '取消收藏' : '收藏'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'share',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.share,
                                size: 20, color: menuIconColor),
                            const SizedBox(width: 12),
                            const Text('分享'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'browser',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.open_in_browser,
                                size: 20, color: menuIconColor),
                            const SizedBox(width: 12),
                            const Text('在瀏覽器中開啟'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
              flexibleSpace: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints constraints) {
                  final double statusBarHeight =
                      MediaQuery.of(context).padding.top;
                  final double minExtent =
                      kToolbarHeight + statusBarHeight;
                  final double expandedHeight =
                      hasImage ? 300.0 : 160.0;
                  final double maxExtent =
                      expandedHeight + statusBarHeight;
                  final double expandRatio =
                      ((constraints.maxHeight - minExtent) /
                              (maxExtent - minExtent))
                          .clamp(0.0, 1.0);

                  // 同步展開比例到 ref（下一幀更新 icon 顏色）
                  if ((expandRatioRef.value - expandRatio).abs() > 0.01) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      expandRatioRef.value = expandRatio;
                    });
                  }

                  return FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    expandedTitleScale: 1.5,
                    titlePadding: EdgeInsetsDirectional.only(
                      start: lerpDouble(56, 16, expandRatio)!,
                      bottom: 16,
                      end: lerpDouble(100, 16, expandRatio)!,
                    ),
                    title: Text(
                      title,
                      maxLines: expandRatio > 0.4 ? 4 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: hasImage
                            ? Color.lerp(
                                Colors.black, Colors.white, expandRatio)
                            : Colors.black,
                        shadows: hasImage && expandRatio > 0.3
                            ? <Shadow>[
                                Shadow(
                                  color: Colors.black54
                                      .withValues(alpha: expandRatio),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    background: _buildFlexibleBackground(
                      context,
                      imageUrl: imageUrl,
                      hasImage: hasImage,
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _buildContent(
                context,
                articleDetail,
                isBookmarked: isBookmarked.value,
                onToggleBookmark: toggleBookmark,
              ),
            ),
          ],
        ),
      );
    };
  }

  void _shareArticle(String title) {
    final String url = 'https://www.twreporter.org/a/$slug';
    final String shareText = '$title\n$url';
    Share.share(shareText);
  }

  Widget _buildContent(
    BuildContext context,
    ArticleDetailResult articleDetail, {
    required bool isBookmarked,
    required VoidCallback onToggleBookmark,
  }) {
    if (articleDetail.hasError.value) {
      return ErrorView(
        message: articleDetail.error.value ?? '未知錯誤',
        onRetry: articleDetail.refresh,
      );
    }

    if (articleDetail.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.only(top: 64),
        child: LoadingIndicator(),
      );
    }

    if (articleDetail.article.value == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 64),
        child: Center(child: Text('文章不存在')),
      );
    }

    return _buildArticleBody(
      context,
      articleDetail.article.value!,
      relatedArticles: articleDetail.relatedArticles.value,
      isBookmarked: isBookmarked,
      onToggleBookmark: onToggleBookmark,
    );
  }

  Widget _buildArticleBody(
    BuildContext context,
    Article article, {
    required List<Article> relatedArticles,
    required bool isBookmarked,
    required VoidCallback onToggleBookmark,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final Color secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final Color linkColor = isDark ? AppColors.secondary : AppColors.primary;

    final String htmlContent =
        _markExternalLinks(convertContentToHtml(article.content));

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: AppSpacing.edgeInsetsMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppSpacing.verticalSpacerSm,

                // 主圖描述
                if (article.leadingImageDescription != null &&
                    article.leadingImageDescription!.isNotEmpty) ...<Widget>[
                  Text(
                    article.leadingImageDescription!,
                    style: AppTextStyles.caption.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                  AppSpacing.verticalSpacerSm,
                ],

                // 分類標記
                if (article.categorySet.isNotEmpty &&
                    article.categorySet.first.category != null) ...<Widget>[
                  CategoryBadge(
                    categoryName: article.categorySet.first.category!.name,
                  ),
                  AppSpacing.verticalSpacerSm,
                ],

                // 發布日期 + 更新日期
                _buildDateRow(article, secondaryTextColor),
                AppSpacing.verticalSpacerSm,

                // 作者署名區塊
                _buildByline(article, secondaryTextColor),

                AppSpacing.verticalSpacerLg,

                // 前言（brief）
                if (article.brief != null) ...<Widget>[
                  _buildBriefSection(article.brief!, context, textColor),
                  AppSpacing.verticalSpacerLg,
                ],

                // 正文
                if (htmlContent.isNotEmpty)
                  Html(
                    data: htmlContent,
                    extensions: <HtmlExtension>[
                      TagExtension(
                        tagsToExtend: <String>{'ext-icon'},
                        builder: (_) => Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: linkColor,
                        ),
                      ),
                      TagExtension(
                        tagsToExtend: <String>{'embedded-video'},
                        builder: (extensionContext) {
                          final String src =
                              extensionContext.attributes['src'] ??
                                  '';
                          final String caption =
                              extensionContext
                                  .attributes['caption'] ??
                              '';
                          final bool autoplay =
                              extensionContext
                                  .attributes['autoplay'] ==
                              'true';
                          final bool muted =
                              extensionContext
                                  .attributes['muted'] ==
                              'true';
                          final bool loop =
                              extensionContext
                                  .attributes['loop'] ==
                              'true';
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: EmbeddedVideoPlayer(
                              url: src,
                              autoplay: autoplay,
                              muted: muted,
                              loop: loop,
                              caption: caption.isNotEmpty
                                  ? caption
                                  : null,
                            ),
                          );
                        },
                      ),
                      TagExtension(
                        tagsToExtend: <String>{
                          'embedded-iframe',
                        },
                        builder: (extensionContext) {
                          final String src =
                              extensionContext.attributes['src'] ??
                                  '';
                          final String caption =
                              extensionContext
                                  .attributes['caption'] ??
                              '';
                          final double height = double.tryParse(
                                extensionContext
                                        .attributes['height'] ??
                                    '',
                              ) ??
                              400;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: EmbeddedWebView(
                              src: src,
                              height: height,
                              caption: caption.isNotEmpty
                                  ? caption
                                  : null,
                            ),
                          );
                        },
                      ),
                      TagExtension(
                        tagsToExtend: <String>{
                          'embedded-webview',
                        },
                        builder: (extensionContext) {
                          final String data =
                              extensionContext
                                      .attributes['data'] ??
                                  '';
                          final String caption =
                              extensionContext
                                  .attributes['caption'] ??
                              '';
                          String htmlData = '';
                          if (data.isNotEmpty) {
                            try {
                              htmlData = utf8.decode(
                                base64Url.decode(data),
                              );
                            } on FormatException catch (_) {
                              // ignore decode errors
                            }
                          }
                          if (htmlData.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: EmbeddedWebView(
                              htmlData: htmlData,
                              height: 500,
                              caption: caption.isNotEmpty
                                  ? caption
                                  : null,
                            ),
                          );
                        },
                      ),
                      TagExtension(
                        tagsToExtend: <String>{'imagediff'},
                        builder: (extensionContext) {
                          final List<({String url, String desc})>
                              images = <({String url, String desc})>[];
                          for (final child
                              in extensionContext.elementChildren) {
                            if (child.localName == 'diffimg') {
                              final String src =
                                  child.attributes['src'] ?? '';
                              final String desc =
                                  child.attributes['desc'] ?? '';
                              if (src.isNotEmpty) {
                                images.add((url: src, desc: desc));
                              }
                            }
                          }
                          if (images.length < 2) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: ImageDiffViewer(
                              beforeUrl: images[0].url,
                              afterUrl: images[1].url,
                              beforeDesc: images[0].desc.isNotEmpty
                                  ? images[0].desc
                                  : null,
                              afterDesc: images[1].desc.isNotEmpty
                                  ? images[1].desc
                                  : null,
                            ),
                          );
                        },
                      ),
                      TagExtension(
                        tagsToExtend: <String>{'slideshow'},
                        builder: (extensionContext) {
                          final List<SlideItem>
                              slides = <SlideItem>[];
                          for (final child
                              in extensionContext.elementChildren) {
                            if (child.localName == 'slide') {
                              final String src =
                                  child.attributes['src'] ?? '';
                              final String desc =
                                  child.attributes['desc'] ?? '';
                              if (src.isNotEmpty) {
                                slides.add(
                                  (url: src, description: desc),
                                );
                              }
                            }
                          }
                          if (slides.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: SlideshowViewer(
                              slides: slides,
                            ),
                          );
                        },
                      ),
                      TagExtension(
                        tagsToExtend: <String>{'infobox'},
                        builder: (extensionContext) {
                          final bool dark =
                              Theme.of(context).brightness == Brightness.dark;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : AppColors.grey100,
                              border: Border.all(
                                color: dark
                                    ? AppColors.grey700
                                    : AppColors.grey300,
                              ),
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd),
                            ),
                            child: Html(
                              data: extensionContext.innerHtml,
                              extensions: <HtmlExtension>[
                                TagExtension(
                                  tagsToExtend: <String>{'ext-icon'},
                                  builder: (_) => Icon(
                                    Icons.open_in_new,
                                    size: 14,
                                    color: linkColor,
                                  ),
                                ),
                              ],
                              style: <String, Style>{
                                'body': Style(
                                  fontSize: FontSize(14),
                                  lineHeight: LineHeight(1.7),
                                  color: textColor,
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                ),
                                'h4': Style(
                                  fontSize: FontSize(17),
                                  fontWeight: FontWeight.bold,
                                  margin: Margins.only(bottom: 8),
                                  color: linkColor,
                                ),
                                'p': Style(
                                  fontSize: FontSize(14),
                                  lineHeight: LineHeight(1.7),
                                  margin: Margins.only(bottom: 8),
                                ),
                                'a': Style(
                                  color: linkColor,
                                  textDecoration:
                                      TextDecoration.underline,
                                ),
                              },
                              onLinkTap: (url, _, _) async {
                                if (url == null) return;
                                if (url.startsWith('anno://')) {
                                  _showAnnotation(context,
                                      url.substring('anno://'.length));
                                  return;
                                }
                                final uri = Uri.tryParse(url);
                                if (uri != null &&
                                    (uri.host == 'www.twreporter.org' ||
                                        uri.host == 'twreporter.org')) {
                                  final segments = uri.pathSegments;
                                  if (segments.length >= 2 &&
                                      segments[0] == 'a') {
                                    context.router.push(ArticleRoute(
                                        slug: segments[1]));
                                    return;
                                  }
                                  if (segments.length >= 2 &&
                                      segments[0] == 'topics') {
                                    context.router.push(TopicDetailRoute(
                                        slug: segments[1]));
                                    return;
                                  }
                                  if (segments.length >= 2 &&
                                      segments[0] == 'categories') {
                                    context.router.push(CategoryRoute(
                                        category: segments[1]));
                                    return;
                                  }
                                }
                                await launchUrl(
                                  Uri.parse(url),
                                  mode: LaunchMode.inAppBrowserView,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                    style: <String, Style>{
                      'body': Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.8),
                        color: textColor,
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      'p': Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.8),
                        margin: Margins.only(bottom: 16),
                      ),
                      'h1': Style(
                        fontSize: FontSize(28),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 24, bottom: 12),
                      ),
                      'h2': Style(
                        fontSize: FontSize(24),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 20, bottom: 10),
                      ),
                      'h3': Style(
                        fontSize: FontSize(20),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 16, bottom: 8),
                      ),
                      'h4': Style(
                        fontSize: FontSize(18),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 12, bottom: 8),
                      ),
                      'blockquote': Style(
                        margin: Margins.only(left: 16, top: 8, bottom: 8),
                        padding: HtmlPaddings.only(left: 12),
                        border: const Border(
                          left: BorderSide(
                            color: AppColors.secondary,
                            width: 3,
                          ),
                        ),
                        fontStyle: FontStyle.italic,
                        color: secondaryTextColor,
                      ),
                      'a': Style(
                        color: linkColor,
                        textDecoration: TextDecoration.underline,
                      ),
                      'img': Style(
                        margin: Margins.only(top: 8, bottom: 8),
                      ),
                      'figcaption': Style(
                        fontSize: FontSize(13),
                        color: secondaryTextColor,
                        margin: Margins.only(top: 4, bottom: 16),
                      ),
                      'figure': Style(
                        margin: Margins.only(top: 16, bottom: 16),
                      ),
                    },
                    onLinkTap: (url, _, _) async {
                      if (url == null) return;
                      if (url.startsWith('anno://')) {
                        _showAnnotation(
                            context, url.substring('anno://'.length));
                        return;
                      }
                      final uri = Uri.tryParse(url);
                      if (uri != null &&
                          (uri.host == 'www.twreporter.org' ||
                              uri.host == 'twreporter.org')) {
                        final segments = uri.pathSegments;
                        if (segments.length >= 2 &&
                            segments[0] == 'a') {
                          context.router.push(ArticleRoute(
                            slug: segments[1],
                          ));
                          return;
                        }
                        if (segments.length >= 2 &&
                            segments[0] == 'topics') {
                          context.router.push(TopicDetailRoute(
                            slug: segments[1],
                          ));
                          return;
                        }
                        if (segments.length >= 2 &&
                            segments[0] == 'categories') {
                          context.router.push(CategoryRoute(
                            category: segments[1],
                          ));
                          return;
                        }
                      }
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.inAppBrowserView,
                      );
                    },
                  )
                else
                  Text(
                    article.ogDescription,
                    style: AppTextStyles.body1,
                  ),

                // 版權資訊
                if (article.copyright != null &&
                    article.copyright!.isNotEmpty) ...<Widget>[
                  AppSpacing.verticalSpacerLg,
                  Text(
                    _formatCopyright(article.copyright!),
                    style: AppTextStyles.caption.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],

                AppSpacing.verticalSpacerXl,

                // 底部分享與收藏按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () => _shareArticle(article.title),
                      icon: const Icon(Icons.share),
                      label: const Text('分享'),
                    ),
                    AppSpacing.horizontalSpacerMd,
                    OutlinedButton.icon(
                      onPressed: onToggleBookmark,
                      icon: Icon(
                        isBookmarked ? Icons.favorite : Icons.favorite_border,
                        color: isBookmarked ? AppColors.accent : null,
                      ),
                      label: Text(isBookmarked ? '已收藏' : '收藏'),
                    ),
                  ],
                ),
                AppSpacing.verticalSpacerXl,
              ],
            ),
          ),

          // 相關報導（全寬水平輪播）
          if (relatedArticles.isNotEmpty) ...<Widget>[
            Padding(
              padding: AppSpacing.edgeInsetsHorizontalMd,
              child: Text('相關報導', style: AppTextStyles.headline3),
            ),
            AppSpacing.verticalSpacerSm,
            HorizontalCarousel(
              itemWidth: 280,
              height: 260,
              itemCount: relatedArticles.length,
              itemBuilder: (BuildContext ctx, int index) {
                final Article related = relatedArticles[index];
                final String? relatedImageUrl =
                    ArticleCard.getArticleImageUrl(related);
                return GestureDetector(
                  onTap: () {
                    ctx.router.push(ArticleRoute(
                      slug: related.slug,
                      heroImageUrl: relatedImageUrl,
                    ));
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
                        if (relatedImageUrl != null)
                          CachedNetworkImage(
                            imageUrl: relatedImageUrl,
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
                                  related.title,
                                  style: AppTextStyles.headline3
                                      .copyWith(fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Text(
                                  related.ogDescription,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
            ),
            AppSpacing.verticalSpacerLg,
          ],

        ],
      ),
    );
  }

  String _formatCopyright(String copyright) {
    switch (copyright) {
      case 'Creative-Commons':
        return '本文採 Creative Commons 授權';
      case 'Copyrighted':
        return '本文版權歸屬報導者';
      default:
        return copyright;
    }
  }

  /// 日期列（發布日期 + 更新日期）
  Widget _buildDateRow(Article article, Color secondaryTextColor) {
    final String publishedStr = formatDate(article.publishedDate);
    final bool hasUpdate = article.updatedAt != null &&
        !_isSameDay(article.updatedAt!, article.publishedDate);

    if (!hasUpdate) {
      return Text(publishedStr, style: AppTextStyles.timestamp);
    }

    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          TextSpan(text: publishedStr),
          TextSpan(
            text: '（更新於 ${formatDate(article.updatedAt!)}）',
            style: TextStyle(color: secondaryTextColor),
          ),
        ],
      ),
      style: AppTextStyles.timestamp,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 作者署名區塊
  Widget _buildByline(Article article, Color secondaryTextColor) {
    final List<Widget> bylineWidgets = <Widget>[];
    final TextStyle bylineStyle = AppTextStyles.body2.copyWith(
      color: secondaryTextColor,
    );

    if (article.writers != null && article.writers!.isNotEmpty) {
      bylineWidgets.add(Text(
        '文／${_formatAuthors(article.writers!)}',
        style: bylineStyle,
      ));
    }

    if (article.photographers != null && article.photographers!.isNotEmpty) {
      bylineWidgets.add(Text(
        '攝影／${_formatAuthors(article.photographers!)}',
        style: bylineStyle,
      ));
    }

    if (article.designers != null && article.designers!.isNotEmpty) {
      bylineWidgets.add(Text(
        '設計／${_formatAuthors(article.designers!)}',
        style: bylineStyle,
      ));
    }

    if (article.extendByline != null && article.extendByline!.isNotEmpty) {
      bylineWidgets.add(Text(
        article.extendByline!,
        style: bylineStyle,
      ));
    }

    if (bylineWidgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bylineWidgets,
    );
  }

  String _formatAuthors(List<Author> authors) {
    return authors.map((Author a) => a.name).join('、');
  }

  /// 前言區塊（brief）
  Widget _buildBriefSection(
    Map<String, dynamic> brief,
    BuildContext context,
    Color textColor,
  ) {
    final String briefHtml =
        _markExternalLinks(convertContentToHtml(brief));
    if (briefHtml.isEmpty) return const SizedBox.shrink();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color linkColor = isDark ? AppColors.secondary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        border: const Border(
          left: BorderSide(
            color: AppColors.secondary,
            width: 3,
          ),
        ),
      ),
      child: Html(
        data: briefHtml,
        extensions: <HtmlExtension>[
          TagExtension(
            tagsToExtend: <String>{'ext-icon'},
            builder: (_) => Icon(
              Icons.open_in_new,
              size: 14,
              color: linkColor,
            ),
          ),
        ],
        style: <String, Style>{
          'body': Style(
            fontSize: FontSize(15),
            lineHeight: LineHeight(1.7),
            color: textColor,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'p': Style(
            fontSize: FontSize(15),
            lineHeight: LineHeight(1.7),
            margin: Margins.only(bottom: 8),
          ),
          'a': Style(
            color: isDark ? AppColors.secondary : AppColors.primary,
            textDecoration: TextDecoration.underline,
          ),
        },
        onLinkTap: (url, _, _) async {
          if (url == null) return;
          if (url.startsWith('anno://')) {
            _showAnnotation(context, url.substring('anno://'.length));
            return;
          }
          final uri = Uri.tryParse(url);
          if (uri != null &&
              (uri.host == 'www.twreporter.org' ||
                  uri.host == 'twreporter.org')) {
            final segments = uri.pathSegments;
            if (segments.length >= 2 && segments[0] == 'a') {
              context.router.push(ArticleRoute(slug: segments[1]));
              return;
            }
            if (segments.length >= 2 && segments[0] == 'topics') {
              context.router.push(TopicDetailRoute(slug: segments[1]));
              return;
            }
            if (segments.length >= 2 && segments[0] == 'categories') {
              context.router.push(CategoryRoute(category: segments[1]));
              return;
            }
          }
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.inAppBrowserView,
          );
        },
      ),
    );
  }

  Widget? _buildFlexibleBackground(
    BuildContext context, {
    required String? imageUrl,
    required bool hasImage,
  }) {
    if (!hasImage || imageUrl == null) return null;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Hero(
          tag: 'article-image-$slug',
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: AppColors.grey200,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.grey200,
              child: const Icon(Icons.image_not_supported,
                  color: AppColors.grey400, size: 48),
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.transparent, Colors.black87],
              stops: <double>[0.3, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  /// 顯示註釋內容
  /// [encodedPath] 格式: "base64urlContent|base64urlTrigger"
  static void _showAnnotation(BuildContext context, String encodedPath) {
    try {
      final List<String> parts = encodedPath.split('|');
      final String content = utf8.decode(base64Url.decode(parts[0]));
      final String title = parts.length > 1
          ? utf8.decode(base64Url.decode(parts[1]))
          : '註釋';
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext ctx) => DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          expand: false,
          builder: (BuildContext ctx, ScrollController scrollController) =>
              SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.grey400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyles.headline3.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  content,
                  style: AppTextStyles.body1.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (_) {}
  }

  /// 為外部連結加上 <ext-icon></ext-icon> 標記
  static String _markExternalLinks(String html) {
    return html.replaceAllMapped(
      RegExp(r'<a\s([^>]*?)href="(https?://[^"]*)"([^>]*)>([\s\S]*?)</a>'),
      (Match m) {
        final String before = m.group(1)!;
        final String href = m.group(2)!;
        final String after = m.group(3)!;
        final String content = m.group(4)!;
        if (!href.contains('twreporter.org')) {
          return '<a ${before}href="$href"$after>$content</a><ext-icon></ext-icon>';
        }
        return m.group(0)!;
      },
    );
  }

  static String? _getImageUrl(Article article) {
    final HeroImage? heroImage = article.heroImage ?? article.ogImage;
    if (heroImage == null) return null;
    return heroImage.resizedTargets.mobile?.url ??
        heroImage.resizedTargets.w400?.url ??
        heroImage.resizedTargets.tiny?.url;
  }
}
