import 'dart:async';
import 'dart:convert' show base64Url, utf8;
import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tw_reporter_app/core/di/composables.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/author.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/settings/media_load_mode.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/features/article/logic/use_article_detail.dart';
import 'package:tw_reporter_app/shared/composables/use_flexible_space_ratio.dart';
import 'package:tw_reporter_app/shared/composables/use_reading.dart';
import 'package:tw_reporter_app/shared/utils/content_renderer.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/cached_image.dart';
import 'package:tw_reporter_app/shared/widgets/category_badge.dart';
import 'package:tw_reporter_app/shared/widgets/donate_banner.dart';
import 'package:tw_reporter_app/shared/widgets/embedded_video_player.dart';
import 'package:tw_reporter_app/shared/widgets/embedded_webview.dart';
import 'package:tw_reporter_app/shared/widgets/error_view.dart';
import 'package:tw_reporter_app/shared/widgets/horizontal_carousel.dart';
import 'package:tw_reporter_app/shared/widgets/image_diff_viewer.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';
import 'package:tw_reporter_app/shared/widgets/slideshow_viewer.dart';
import 'package:tw_reporter_app/shared/widgets/tap_to_load_wrapper.dart';
import 'package:tw_reporter_app/shared/widgets/youtube_player_widget.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum _ArticleMenuAction { bookmark, share, browser }

// ---------------------------------------------------------------------------
// Top-level pure functions
// ---------------------------------------------------------------------------

String? _getImageUrl(Article article) {
  final heroImage = article.heroImage ?? article.ogImage;
  if (heroImage == null) return null;
  return heroImage.resizedTargets.mobile?.url ??
      heroImage.resizedTargets.w400?.url ??
      heroImage.resizedTargets.tiny?.url;
}

String? _getLowResImageUrl(Article article) {
  final heroImage = article.heroImage ?? article.ogImage;
  if (heroImage == null) return null;
  return heroImage.resizedTargets.tiny?.url ??
      heroImage.resizedTargets.w400?.url;
}

String _markExternalLinks(String html) {
  return html.replaceAllMapped(
    RegExp(r'<a\s([^>]*?)href="(https?://[^"]*)"([^>]*)>([\s\S]*?)</a>'),
    (m) {
      final before = m.group(1)!;
      final href = m.group(2)!;
      final after = m.group(3)!;
      final content = m.group(4)!;
      if (!href.contains('twreporter.org')) {
        return '<a ${before}href="$href"$after>$content</a> '
            '<ext-icon></ext-icon>';
      }
      return m.group(0)!;
    },
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

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

void _showAnnotation(BuildContext context, String encodedPath) {
  try {
    final parts = encodedPath.split('|');
    final content = utf8.decode(base64Url.decode(parts[0]));
    final title = parts.length > 1
        ? utf8.decode(base64Url.decode(parts[1]))
        : '註釋';
    final annoColors = Theme.of(context).colorScheme;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          expand: false,
          builder: (ctx, scrollController) => SingleChildScrollView(
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
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    color: annoColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: annoColors.onSurface,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } on Object catch (_) {}
}

Future<void> _handleLinkTap(BuildContext context, String? url) async {
  if (url == null) return;
  if (url.startsWith('anno://')) {
    _showAnnotation(context, url.substring('anno://'.length));
    return;
  }
  final uri = Uri.tryParse(url);
  if (uri != null &&
      (uri.host == 'www.twreporter.org' || uri.host == 'twreporter.org')) {
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'a') {
      unawaited(context.router.push(ArticleRoute(slug: segments[1])));
      return;
    }
    if (segments.length >= 2 && segments[0] == 'topics') {
      unawaited(
        context.router.push(TopicDetailRoute(slug: segments[1])),
      );
      return;
    }
    if (segments.length >= 2 && segments[0] == 'categories') {
      unawaited(
        context.router.push(CategoryRoute(category: segments[1])),
      );
      return;
    }
  }
  await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
}

Widget? _buildFlexibleBackground({
  required String slug,
  required String? imageUrl,
  required bool hasImage,
  String? lowResImageUrl,
}) {
  if (!hasImage || imageUrl == null) return null;
  return Stack(
    fit: StackFit.expand,
    children: <Widget>[
      CachedImage(
        imageUrl: imageUrl,
        placeholderUrl: lowResImageUrl,
        errorWidget: const ColoredBox(
          color: AppColors.grey200,
          child: Icon(
            Icons.image_not_supported,
            color: AppColors.grey400,
            size: 48,
          ),
        ),
      ),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.transparent, Colors.black87],
            stops: <double>[0.3, 1],
          ),
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Main page
// ---------------------------------------------------------------------------

@RoutePage()
class ArticlePage extends StatelessWidget {
  const ArticlePage({
    @PathParam('slug') required this.slug,
    super.key,
    this.heroImageUrl,
  });

  final String slug;
  final String? heroImageUrl;

  @override
  Widget build(BuildContext context) {
    return _ArticlePageContent(
      slug: slug,
      heroImageUrl: heroImageUrl,
    );
  }
}

class _ArticlePageContent extends CompositionWidget {
  const _ArticlePageContent({
    required this.slug,
    this.heroImageUrl,
  });

  final String slug;
  final String? heroImageUrl;

  @override
  Widget Function(BuildContext) setup() {
    final articleRepo = useArticleRepository();
    final reading = useReading();
    final articleDetail = useArticleDetail(
      articleRepo,
      slug: slug,
    );
    final theme = useTheme();
    void Function()? stopRecordedReading;

    final imageUrl = computed(() {
      final a = articleDetail.article.value;
      return a != null ? _getImageUrl(a) : heroImageUrl;
    });
    final lowResImageUrl = computed(() {
      final a = articleDetail.article.value;
      return a != null ? _getLowResImageUrl(a) : heroImageUrl;
    });
    final title = computed(
      () => articleDetail.article.value?.title ?? '',
    );
    final hasImage = computed(() => imageUrl.value != null);
    final isBookmarked = computed(() {
      // Read bookmarks to establish reactive tracking
      final _ = reading.bookmarks.value;
      return reading.isBookmarked(slug);
    });

    void shareArticle(String title) {
      final url = 'https://www.twreporter.org/a/$slug';
      final shareText = '$title\n$url';
      unawaited(
        SharePlus.instance.share(ShareParams(text: shareText)),
      );
    }

    void toggleBookmark() {
      final article = articleDetail.article.value;
      if (article == null) return;
      final imgUrl = _getImageUrl(article);
      if (isBookmarked.value) {
        reading.removeBookmark(slug);
      } else {
        reading.addBookmark(slug, article.title, imgUrl);
      }
    }

    stopRecordedReading = watchEffect(() {
      final article = articleDetail.article.value;
      if (article != null) {
        final imgUrl = _getImageUrl(article);
        reading.addToHistory(
          slug,
          article.title,
          imgUrl,
          DateTime.now(),
        );
        stopRecordedReading?.call();
      }
    });

    return (BuildContext context) {
      return Scaffold(
        body: CustomScrollView(
          cacheExtent: 300,
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: hasImage.value ? 300.0 : 160.0,
              pinned: true,
              // ComputedBuilder: only rebuild icons on scroll,
              // not the entire article body.
              leading: CompositionBuilder(
                setup: () {
                  final ratio = useFlexibleSpaceRatio();
                  final color = computed(
                    () => hasImage.value
                        ? Color.lerp(
                            theme.value.colorScheme.onSurface,
                            Colors.white,
                            ratio.value,
                          )
                        : theme.value.colorScheme.onSurface,
                  );

                  return (_) => BackButton(color: color.value);
                },
              ),
              actions: <Widget>[
                CompositionBuilder(
                  setup: () {
                    final ratio = useFlexibleSpaceRatio();
                    final iconColor = computed(
                      () => hasImage.value
                          ? Color.lerp(
                              theme.value.colorScheme.onSurface,
                              Colors.white,
                              ratio.value,
                            )
                          : theme.value.colorScheme.onSurface,
                    );

                    return (_) => PopupMenuButton<_ArticleMenuAction>(
                      icon: Icon(
                        Icons.more_vert,
                        color: iconColor.value,
                      ),
                      onSelected: (action) {
                        switch (action) {
                          case _ArticleMenuAction.bookmark:
                            toggleBookmark();
                          case _ArticleMenuAction.share:
                            shareArticle(title.value);
                          case _ArticleMenuAction.browser:
                            unawaited(
                              launchUrl(
                                Uri.parse(
                                  'https://www.twreporter.org/a/$slug',
                                ),
                                mode: LaunchMode.inAppBrowserView,
                              ),
                            );
                        }
                      },
                      itemBuilder: (ctx) {
                        final menuIconColor =
                            theme.value.iconTheme.color ?? Colors.black87;
                        final bookmarked = isBookmarked.value;
                        return <PopupMenuEntry<_ArticleMenuAction>>[
                          PopupMenuItem<_ArticleMenuAction>(
                            value: _ArticleMenuAction.bookmark,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  bookmarked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: bookmarked
                                      ? AppColors.accent
                                      : menuIconColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(bookmarked ? '取消收藏' : '收藏'),
                              ],
                            ),
                          ),
                          PopupMenuItem<_ArticleMenuAction>(
                            value: _ArticleMenuAction.share,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.share,
                                  size: 20,
                                  color: menuIconColor,
                                ),
                                const SizedBox(width: 12),
                                const Text('分享'),
                              ],
                            ),
                          ),
                          PopupMenuItem<_ArticleMenuAction>(
                            value: _ArticleMenuAction.browser,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.open_in_browser,
                                  size: 20,
                                  color: menuIconColor,
                                ),
                                const SizedBox(width: 12),
                                const Text('在瀏覽器中開啟'),
                              ],
                            ),
                          ),
                        ];
                      },
                    );
                  },
                ),
              ],
              flexibleSpace: CompositionBuilder(
                setup: () {
                  final ratio = useFlexibleSpaceRatio();

                  final paddingHorizontal = computed(
                    () => lerpDouble(56, 16, ratio.value)!,
                  );
                  final maxLines = computed(() => ratio.value > 0.4 ? 4 : 1);
                  final color = computed(
                    () => hasImage.value
                        ? Color.lerp(
                            theme.value.colorScheme.onSurface,
                            Colors.white,
                            ratio.value,
                          )
                        : theme.value.colorScheme.onSurface,
                  );
                  final shadows = computed(
                    () => hasImage.value && ratio.value > 0.3
                        ? <Shadow>[
                            Shadow(
                              color: Colors.black54.withValues(
                                alpha: ratio.value,
                              ),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  );

                  return (context) => FlexibleSpaceBar(
                    titlePadding: EdgeInsetsDirectional.only(
                      start: paddingHorizontal.value,
                      bottom: 16,
                      end: paddingHorizontal.value,
                    ),
                    title: Text(
                      title.value,
                      maxLines: maxLines.value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: color.value,
                        shadows: shadows.value,
                      ),
                    ),
                    background: _buildFlexibleBackground(
                      slug: slug,
                      imageUrl: imageUrl.value,
                      hasImage: hasImage.value,
                      lowResImageUrl: lowResImageUrl.value,
                    ),
                  );
                },
              ),
            ),
            ..._ArticleContentView.buildSlivers(
              context: context,
              articleDetail: articleDetail,
              isBookmarked: isBookmarked,
              slug: slug,
              onShare: shareArticle,
              onToggleBookmark: toggleBookmark,
            ),
          ],
        ),
      );
    };
  }
}

// ---------------------------------------------------------------------------
// Static helper: builds article content as a list of Slivers
// ---------------------------------------------------------------------------

class _ArticleContentView {
  _ArticleContentView._();

  static List<Widget> buildSlivers({
    required BuildContext context,
    required ArticleDetailResult articleDetail,
    required ReadonlyRef<bool> isBookmarked,
    required String slug,
    required void Function(String title) onShare,
    required VoidCallback onToggleBookmark,
  }) {
    if (articleDetail.hasError.value) {
      return <Widget>[
        SliverToBoxAdapter(
          child: ErrorView(
            message: articleDetail.error.value ?? '未知錯誤',
            onRetry: articleDetail.refresh,
          ),
        ),
      ];
    }

    if (articleDetail.isLoading.value) {
      return <Widget>[
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 64),
            child: LoadingIndicator(),
          ),
        ),
      ];
    }

    final article = articleDetail.article.value;
    if (article == null) {
      return <Widget>[
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 64),
            child: Center(child: Text('文章不存在')),
          ),
        ),
      ];
    }

    return _ArticleBodySlivers.build(
      context: context,
      article: article,
      relatedArticles: articleDetail.relatedArticles.value,
      isBookmarked: isBookmarked,
      onToggleBookmark: onToggleBookmark,
      onShare: onShare,
      slug: slug,
    );
  }
}

// ---------------------------------------------------------------------------
// Static helper: builds article body as multiple Slivers
// ---------------------------------------------------------------------------

class _ArticleBodySlivers {
  _ArticleBodySlivers._();

  static List<Widget> build({
    required BuildContext context,
    required Article article,
    required List<Article> relatedArticles,
    required ReadonlyRef<bool> isBookmarked,
    required VoidCallback onToggleBookmark,
    required void Function(String title) onShare,
    required String slug,
  }) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final textColor = colors.onSurface;
    final secondaryTextColor = colors.onSurfaceVariant;
    final linkColor = colors.primary;

    final contentBlocks = convertContentToBlocks(
      article.content,
    ).map(_markExternalLinks).toList();

    return <Widget>[
      // 1. Metadata sliver (image desc, category, tags, date, byline, brief)
      SliverToBoxAdapter(
        child: SelectionArea(
          child: Padding(
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
                    style: textTheme.bodySmall!.copyWith(
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
                    subcategoryName:
                        article.categorySet.first.subcategory?.name,
                  ),
                  AppSpacing.verticalSpacerSm,
                ],

                // 標籤 Chips
                if (article.tags != null &&
                    article.tags!.isNotEmpty) ...<Widget>[
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: article.tags!.map((tag) {
                      return ActionChip(
                        label: Text(
                          '#${tag.name}',
                          style: textTheme.bodySmall,
                        ),
                        onPressed: () {
                          unawaited(
                            context.router.push(
                              TagDetailRoute(
                                tagId: tag.id,
                                tagName: tag.name,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  AppSpacing.verticalSpacerSm,
                ],

                // 日期行
                _DateRow(article: article),
                AppSpacing.verticalSpacerSm,

                // 作者署名
                _BylineSection(article: article),

                AppSpacing.verticalSpacerLg,

                // 前言（brief）
                if (article.brief != null) ...<Widget>[
                  _BriefSection(brief: article.brief!),
                  AppSpacing.verticalSpacerLg,
                ],
              ],
            ),
          ),
        ),
      ),

      // 2. Article content blocks (virtual list with keep-alive)
      if (contentBlocks.isNotEmpty)
        SliverList.builder(
          itemCount: contentBlocks.length,
          itemBuilder: (context, index) {
            return SelectionArea(
              child: Padding(
                padding: AppSpacing.edgeInsetsHorizontalMd,
                child: _ArticleHtmlContent(
                  htmlContent: contentBlocks[index],
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  linkColor: linkColor,
                ),
              ),
            );
          },
        )
      else
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.edgeInsetsMd,
            child: Text(
              article.ogDescription,
              style: textTheme.bodyLarge,
            ),
          ),
        ),

      // 3. Footer sliver (copyright, share/bookmark, donate)
      SliverToBoxAdapter(
        child: SelectionArea(
          child: Padding(
            padding: AppSpacing.edgeInsetsMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 版權資訊
                if (article.copyright != null &&
                    article.copyright!.isNotEmpty) ...<Widget>[
                  AppSpacing.verticalSpacerLg,
                  Text(
                    _formatCopyright(article.copyright!),
                    style: textTheme.bodySmall!.copyWith(
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
                      onPressed: () => onShare(article.title),
                      icon: const Icon(Icons.share),
                      label: const Text('分享'),
                    ),
                    AppSpacing.horizontalSpacerMd,
                    ComputedBuilder(
                      builder: () => OutlinedButton.icon(
                        onPressed: onToggleBookmark,
                        icon: Icon(
                          isBookmarked.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isBookmarked.value ? AppColors.accent : null,
                        ),
                        label: Text(
                          isBookmarked.value ? '已收藏' : '收藏',
                        ),
                      ),
                    ),
                  ],
                ),
                // 贊助報導者
                DonateBanner(pagePath: '/a/$slug'),
                AppSpacing.verticalSpacerXl,
              ],
            ),
          ),
        ),
      ),

      // 4. Related articles carousel
      if (relatedArticles.isNotEmpty) ...<Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: AppSpacing.edgeInsetsHorizontalMd,
                child: Text('相關報導', style: textTheme.displaySmall),
              ),
              AppSpacing.verticalSpacerSm,
              _RelatedArticlesCarousel(
                relatedArticles: relatedArticles,
              ),
              AppSpacing.verticalSpacerLg,
            ],
          ),
        ),
      ],
    ];
  }
}

// ---------------------------------------------------------------------------
// Internal StatelessWidget: HTML content with extensions
// ---------------------------------------------------------------------------

class _ArticleHtmlContent extends CompositionWidget {
  const _ArticleHtmlContent({
    required this.htmlContent,
    required this.textColor,
    required this.secondaryTextColor,
    required this.linkColor,
  });

  final String htmlContent;
  final Color textColor;
  final Color secondaryTextColor;
  final Color linkColor;

  @override
  Widget Function(BuildContext) setup() {
    final mediaLoadModeRef = useMediaLoadMode();

    return (BuildContext context) {
      return _ArticleHtmlContentView(
        htmlContent: htmlContent,
        textColor: textColor,
        secondaryTextColor: secondaryTextColor,
        linkColor: linkColor,
        isDataSaving: mediaLoadModeRef.value == MediaLoadMode.dataSaving,
      );
    };
  }
}

class _ArticleHtmlContentView extends StatelessWidget {
  const _ArticleHtmlContentView({
    required this.htmlContent,
    required this.textColor,
    required this.secondaryTextColor,
    required this.linkColor,
    required this.isDataSaving,
  });

  final String htmlContent;
  final Color textColor;
  final Color secondaryTextColor;
  final Color linkColor;
  final bool isDataSaving;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Html(
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
            final src = extensionContext.attributes['src'] ?? '';
            final caption = extensionContext.attributes['caption'] ?? '';
            final autoplay = extensionContext.attributes['autoplay'] == 'true';
            final muted = extensionContext.attributes['muted'] == 'true';
            final loop = extensionContext.attributes['loop'] == 'true';
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
              child: TapToLoadWrapper(
                mediaType: MediaType.video,
                child: EmbeddedVideoPlayer(
                  url: src,
                  autoplay: autoplay,
                  muted: muted,
                  loop: loop,
                  caption: caption.isNotEmpty ? caption : null,
                ),
              ),
            );
          },
        ),
        TagExtension(
          tagsToExtend: <String>{'embedded-iframe'},
          builder: (extensionContext) {
            final src = extensionContext.attributes['src'] ?? '';
            final caption = extensionContext.attributes['caption'] ?? '';
            final height = double.tryParse(
              extensionContext.attributes['height'] ?? '',
            );
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
              child: TapToLoadWrapper(
                mediaType: MediaType.webview,
                child: EmbeddedWebView(
                  src: src,
                  height: height,
                  caption: caption.isNotEmpty ? caption : null,
                ),
              ),
            );
          },
        ),
        TagExtension(
          tagsToExtend: <String>{'embedded-webview'},
          builder: (extensionContext) {
            final data = extensionContext.attributes['data'] ?? '';
            final caption = extensionContext.attributes['caption'] ?? '';
            var htmlData = '';
            if (data.isNotEmpty) {
              try {
                final decoded = utf8.decode(base64Url.decode(data));
                htmlData = decoded;
              } on FormatException catch (_) {
                // ignore decode errors
              }
            }
            if (htmlData.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
              child: TapToLoadWrapper(
                mediaType: MediaType.webview,
                child: EmbeddedWebView(
                  htmlData: htmlData,
                  caption: caption.isNotEmpty ? caption : null,
                ),
              ),
            );
          },
        ),
        TagExtension(
          tagsToExtend: <String>{'embedded-youtube'},
          builder: (extensionContext) {
            final id = extensionContext.attributes['id'] ?? '';
            final caption = extensionContext.attributes['caption'] ?? '';
            if (id.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
              child: TapToLoadWrapper(
                mediaType: MediaType.youtube,
                child: YoutubePlayerWidget(
                  videoId: id,
                  caption: caption.isNotEmpty ? caption : null,
                ),
              ),
            );
          },
        ),
        TagExtension(
          tagsToExtend: <String>{'imagediff'},
          builder: (extensionContext) {
            final images = <({String url, String desc})>[];
            for (final child in extensionContext.elementChildren) {
              if (child.localName == 'diffimg') {
                final src = child.attributes['src'] ?? '';
                final desc = child.attributes['desc'] ?? '';
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
              child: TapToLoadWrapper(
                mediaType: MediaType.imagediff,
                child: ImageDiffViewer(
                  beforeUrl: images[0].url,
                  afterUrl: images[1].url,
                  beforeDesc: images[0].desc.isNotEmpty ? images[0].desc : null,
                  afterDesc: images[1].desc.isNotEmpty ? images[1].desc : null,
                ),
              ),
            );
          },
        ),
        TagExtension(
          tagsToExtend: <String>{'slideshow'},
          builder: (extensionContext) {
            final slides = <SlideItem>[];
            for (final child in extensionContext.elementChildren) {
              if (child.localName == 'slide') {
                final src = child.attributes['src'] ?? '';
                final desc = child.attributes['desc'] ?? '';
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
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
              child: TapToLoadWrapper(
                mediaType: MediaType.slideshow,
                child: SlideshowViewer(slides: slides),
              ),
            );
          },
        ),
        if (isDataSaving)
          ImageExtension(
            builder: (extensionContext) {
              final src = extensionContext.attributes['src'] ?? '';
              if (src.isEmpty) {
                return const SizedBox.shrink();
              }
              return TapToLoadWrapper(
                mediaType: MediaType.image,
                child: CachedImage(
                  imageUrl: src,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorWidget: const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ColoredBox(
                      color: AppColors.grey200,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        TagExtension(
          tagsToExtend: <String>{'quoteby'},
          builder: (extensionContext) {
            final quote = extensionContext.attributes['quote'] ?? '';
            final quoteByAuthor =
                extensionContext.attributes['quoteby-author'] ?? '';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 2,
                    height: 80,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    quote,
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: textColor,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (quoteByAuthor.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '── $quoteByAuthor',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        TagExtension(
          tagsToExtend: <String>{'infobox'},
          builder: (extensionContext) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                border: Border.all(
                  color: colors.outline,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                    lineHeight: const LineHeight(1.7),
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
                    lineHeight: const LineHeight(1.7),
                    margin: Margins.only(bottom: 8),
                  ),
                  'a': Style(
                    color: linkColor,
                    textDecoration: TextDecoration.underline,
                  ),
                },
                onLinkTap: (url, _, _) => _handleLinkTap(context, url),
              ),
            );
          },
        ),
      ],
      style: <String, Style>{
        'body': Style(
          fontSize: FontSize(16),
          lineHeight: const LineHeight(1.8),
          color: textColor,
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        'p': Style(
          fontSize: FontSize(16),
          lineHeight: const LineHeight(1.8),
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
      onLinkTap: (url, _, _) => _handleLinkTap(context, url),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal StatelessWidget: Brief section
// ---------------------------------------------------------------------------

class _BriefSection extends StatelessWidget {
  const _BriefSection({required this.brief});

  final Map<String, dynamic> brief;

  @override
  Widget build(BuildContext context) {
    final briefHtml = _markExternalLinks(convertContentToHtml(brief));
    if (briefHtml.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final textColor = colors.onSurface;
    final linkColor = colors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
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
            lineHeight: const LineHeight(1.7),
            color: textColor,
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'p': Style(
            fontSize: FontSize(15),
            lineHeight: const LineHeight(1.7),
            margin: Margins.only(bottom: 8),
          ),
          'a': Style(
            color: linkColor,
            textDecoration: TextDecoration.underline,
          ),
        },
        onLinkTap: (url, _, _) => _handleLinkTap(context, url),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal StatelessWidget: Date row
// ---------------------------------------------------------------------------

class _DateRow extends StatelessWidget {
  const _DateRow({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondaryTextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    final publishedStr = formatDate(article.publishedDate);
    final hasUpdate =
        article.updatedAt != null &&
        !_isSameDay(article.updatedAt!, article.publishedDate);

    if (!hasUpdate) {
      return Text(publishedStr, style: textTheme.timestamp);
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
      style: textTheme.timestamp,
    );
  }
}

// ---------------------------------------------------------------------------
// Internal StatelessWidget: Byline section
// ---------------------------------------------------------------------------

class _BylineSection extends StatelessWidget {
  const _BylineSection({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondaryTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final bylineStyle = textTheme.bodyMedium!.copyWith(
      color: secondaryTextColor,
    );

    final bylineWidgets = <Widget>[];

    if (article.writers != null && article.writers!.isNotEmpty) {
      bylineWidgets.add(
        _BylineRow(
          role: '文',
          authors: article.writers!,
          style: bylineStyle,
          secondaryColor: secondaryTextColor,
        ),
      );
    }

    if (article.photographers != null && article.photographers!.isNotEmpty) {
      bylineWidgets.add(
        _BylineRow(
          role: '攝影',
          authors: article.photographers!,
          style: bylineStyle,
          secondaryColor: secondaryTextColor,
        ),
      );
    }

    if (article.designers != null && article.designers!.isNotEmpty) {
      bylineWidgets.add(
        _BylineRow(
          role: '設計',
          authors: article.designers!,
          style: bylineStyle,
          secondaryColor: secondaryTextColor,
        ),
      );
    }

    if (article.extendByline != null && article.extendByline!.isNotEmpty) {
      bylineWidgets.add(
        Text(
          article.extendByline!,
          style: bylineStyle,
        ),
      );
    }

    if (bylineWidgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bylineWidgets,
    );
  }
}

// ---------------------------------------------------------------------------
// Internal StatelessWidget: Byline row (clickable authors)
// ---------------------------------------------------------------------------

class _BylineRow extends StatelessWidget {
  const _BylineRow({
    required this.role,
    required this.authors,
    required this.style,
    required this.secondaryColor,
  });

  final String role;
  final List<Author> authors;
  final TextStyle style;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Text('$role／', style: style),
        ...authors.asMap().entries.map((entry) {
          final isLast = entry.key == authors.length - 1;
          final author = entry.value;
          return GestureDetector(
            onTap: () {
              final thumbnailUrl =
                  author.thumbnail?.resizedTargets.mobile?.url ??
                  author.thumbnail?.resizedTargets.w400?.url;
              unawaited(
                context.router.push(
                  AuthorDetailRoute(
                    authorId: author.id,
                    authorName: author.name,
                    authorJobTitle: author.jobTitle,
                    authorBio: author.bio,
                    authorThumbnailUrl: thumbnailUrl,
                  ),
                ),
              );
            },
            child: Text(
              '${author.name}${isLast ? '' : '、'}',
              style: style.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: secondaryColor,
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal StatelessWidget: Related articles carousel
// ---------------------------------------------------------------------------

class _RelatedArticlesCarousel extends StatelessWidget {
  const _RelatedArticlesCarousel({
    required this.relatedArticles,
  });

  final List<Article> relatedArticles;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return HorizontalCarousel(
      itemWidth: 280,
      height: 260,
      itemCount: relatedArticles.length,
      itemBuilder: (ctx, index) {
        final related = relatedArticles[index];
        final relatedImageUrl = ArticleCard.getArticleImageUrl(related);
        return GestureDetector(
          onTap: () {
            unawaited(
              ctx.router.push(
                ArticleRoute(
                  slug: related.slug,
                  heroImageUrl: relatedImageUrl,
                ),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (relatedImageUrl != null)
                  CachedImage(
                    imageUrl: relatedImageUrl,
                    height: 140,
                    width: double.infinity,
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          related.title,
                          style: textTheme.displaySmall!.copyWith(fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          related.ogDescription,
                          style: textTheme.bodySmall!.copyWith(
                            color: colors.onSurfaceVariant,
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
    );
  }
}
