import 'dart:async';
import 'dart:convert' show base64Url, utf8;
import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';
import 'package:tw_reporter_app/core/di/injection_keys.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/author.dart';
import 'package:tw_reporter_app/core/repositories/reading_repository.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/features/article/logic/use_article_detail.dart';
import 'package:tw_reporter_app/shared/utils/content_renderer.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/category_badge.dart';
import 'package:tw_reporter_app/shared/widgets/donate_banner.dart';
import 'package:tw_reporter_app/shared/widgets/embedded_video_player.dart';
import 'package:tw_reporter_app/shared/widgets/embedded_webview.dart';
import 'package:tw_reporter_app/shared/widgets/error_view.dart';
import 'package:tw_reporter_app/shared/widgets/horizontal_carousel.dart';
import 'package:tw_reporter_app/shared/widgets/image_diff_viewer.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';
import 'package:tw_reporter_app/shared/widgets/slideshow_viewer.dart';
import 'package:tw_reporter_app/shared/widgets/youtube_player_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
  return heroImage.resizedTargets.w400?.url ??
      heroImage.resizedTargets.tiny?.url;
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
      Hero(
        tag: 'article-image-$slug',
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          cacheManager: AppCacheManager.instance.imageCacheManager,
          fit: BoxFit.cover,
          placeholder: (_, _) => lowResImageUrl != null
              ? CachedNetworkImage(
                  imageUrl: lowResImageUrl,
                  cacheManager: AppCacheManager.instance.imageCacheManager,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const ColoredBox(
                    color: AppColors.grey200,
                  ),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: AppColors.grey200,
                  ),
                )
              : const ColoredBox(
                  color: AppColors.grey200,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
          errorWidget: (_, _, _) => const ColoredBox(
            color: AppColors.grey200,
            child: Icon(
              Icons.image_not_supported,
              color: AppColors.grey400,
              size: 48,
            ),
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
    final articleRepo = inject(AppKeys.articleRepository);
    final readingRepo = inject(AppKeys.readingRepository);
    final articleDetail = useArticleDetail(
      articleRepo,
      slug: slug,
    );
    final isBookmarked = ref<bool>(false);
    final hasRecordedReading = ref<bool>(false);
    // Plain ValueNotifier: scroll-driven changes do NOT trigger
    // the CompositionWidget render function to re-run, avoiding
    // expensive rebuilds of the article body / HTML widget.
    final expandRatio = ValueNotifier<double>(1);

    onMounted(() {
      isBookmarked.value = readingRepo.isBookmarked(slug);
    });

    onUnmounted(expandRatio.dispose);

    void recordReadingIfNeeded(Article? article) {
      if (article != null && !hasRecordedReading.value) {
        hasRecordedReading.value = true;
        final imageUrl = _getImageUrl(article);
        readingRepo.addToHistory(
          slug,
          article.title,
          imageUrl,
          DateTime.now(),
        );
      }
    }

    void shareArticle(String title) {
      final url = 'https://www.twreporter.org/a/$slug';
      final shareText = '$title\n$url';
      unawaited(Share.share(shareText));
    }

    void toggleBookmark() {
      final article = articleDetail.article.value;
      if (article == null) return;
      final imageUrl = _getImageUrl(article);
      if (isBookmarked.value) {
        readingRepo.removeBookmark(slug);
        isBookmarked.value = false;
      } else {
        readingRepo.addBookmark(slug, article.title, imageUrl);
        isBookmarked.value = true;
      }
    }

    return (BuildContext context) {
      final article = articleDetail.article.value;
      recordReadingIfNeeded(article);

      final imageUrl = article != null ? _getImageUrl(article) : heroImageUrl;
      final lowResImageUrl = article != null
          ? _getLowResImageUrl(article)
          : heroImageUrl;
      final title = article?.title ?? '';
      final hasImage = imageUrl != null;

      return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: hasImage ? 300.0 : 160.0,
              pinned: true,
              // Animate icon colors via ListenableBuilder so
              // only the icons rebuild on scroll, not the body.
              leading: ListenableBuilder(
                listenable: expandRatio,
                builder: (context, _) {
                  final color = hasImage
                      ? Color.lerp(
                          Theme.of(context).colorScheme.onSurface,
                          Colors.white,
                          expandRatio.value,
                        )
                      : Theme.of(context).colorScheme.onSurface;
                  return BackButton(color: color);
                },
              ),
              actions: <Widget>[
                ListenableBuilder(
                  listenable: expandRatio,
                  builder: (context, _) {
                    final iconColor = hasImage
                        ? Color.lerp(
                            Theme.of(context).colorScheme.onSurface,
                            Colors.white,
                            expandRatio.value,
                          )
                        : Theme.of(context).colorScheme.onSurface;
                    return PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: iconColor,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'bookmark':
                            toggleBookmark();
                          case 'share':
                            shareArticle(title);
                          case 'browser':
                            unawaited(
                              launchUrl(
                                Uri.parse('https://www.twreporter.org/a/$slug'),
                                mode: LaunchMode.inAppBrowserView,
                              ),
                            );
                        }
                      },
                      itemBuilder: (ctx) {
                        final menuIconColor =
                            Theme.of(ctx).iconTheme.color ?? Colors.black87;
                        // Read isBookmarked.value at build time for menu items
                        final bookmarked = isBookmarked.value;
                        return <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'bookmark',
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
                          PopupMenuItem<String>(
                            value: 'share',
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
                          PopupMenuItem<String>(
                            value: 'browser',
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
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final statusBarHeight = MediaQuery.of(context).padding.top;
                  final minExtent = kToolbarHeight + statusBarHeight;
                  final expandedHeight = hasImage ? 300.0 : 160.0;
                  final maxExtent = expandedHeight + statusBarHeight;
                  final ratio =
                      ((constraints.maxHeight - minExtent) /
                              (maxExtent - minExtent))
                          .clamp(0.0, 1.0);

                  if ((expandRatio.value - ratio).abs() > 0.01) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      expandRatio.value = ratio;
                    });
                  }

                  return FlexibleSpaceBar(
                    titlePadding: EdgeInsetsDirectional.only(
                      start: lerpDouble(56, 16, ratio)!,
                      bottom: 18,
                      end: lerpDouble(56, 16, ratio)!,
                    ),
                    title: Text(
                      title,
                      maxLines: ratio > 0.4 ? 4 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: hasImage
                            ? Color.lerp(
                                Theme.of(context).colorScheme.onSurface,
                                Colors.white,
                                ratio,
                              )
                            : Theme.of(context).colorScheme.onSurface,
                        shadows: hasImage && ratio > 0.3
                            ? <Shadow>[
                                Shadow(
                                  color: Colors.black54.withValues(
                                    alpha: ratio,
                                  ),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    background: _buildFlexibleBackground(
                      slug: slug,
                      imageUrl: imageUrl,
                      hasImage: hasImage,
                      lowResImageUrl: lowResImageUrl,
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _ArticleContentView(
                articleDetail: articleDetail,
                isBookmarked: isBookmarked,
                readingRepo: readingRepo,
                slug: slug,
                onShare: shareArticle,
                onToggleBookmark: toggleBookmark,
              ),
            ),
          ],
        ),
      );
    };
  }
}

// ---------------------------------------------------------------------------
// Private CompositionWidget: Article content (replaces buildContent)
// ---------------------------------------------------------------------------

class _ArticleContentView extends CompositionWidget {
  const _ArticleContentView({
    required this.articleDetail,
    required this.isBookmarked,
    required this.readingRepo,
    required this.slug,
    required this.onShare,
    required this.onToggleBookmark,
  });

  final ArticleDetailResult articleDetail;
  final Ref<bool> isBookmarked;
  final ReadingRepository readingRepo;
  final String slug;
  final void Function(String title) onShare;
  final VoidCallback onToggleBookmark;

  @override
  Widget Function(BuildContext) setup() {
    final htmlContent = computed(() {
      final a = articleDetail.article.value;
      if (a == null) return '';
      return _markExternalLinks(convertContentToHtml(a.content));
    });

    return (BuildContext context) {
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

      return _ArticleBodyView(
        article: articleDetail.article.value!,
        relatedArticles: articleDetail.relatedArticles.value,
        htmlContent: htmlContent.value,
        isBookmarked: isBookmarked,
        onToggleBookmark: onToggleBookmark,
        onShare: onShare,
        slug: slug,
      );
    };
  }
}

// ---------------------------------------------------------------------------
// Internal StatelessWidget: Article body
// ---------------------------------------------------------------------------

class _ArticleBodyView extends StatelessWidget {
  const _ArticleBodyView({
    required this.article,
    required this.relatedArticles,
    required this.htmlContent,
    required this.isBookmarked,
    required this.onToggleBookmark,
    required this.onShare,
    required this.slug,
  });

  final Article article;
  final List<Article> relatedArticles;
  final String htmlContent;
  final Ref<bool> isBookmarked;
  final VoidCallback onToggleBookmark;
  final void Function(String title) onShare;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final textColor = colors.onSurface;
    final secondaryTextColor = colors.onSurfaceVariant;
    final linkColor = colors.primary;

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

                // 正文
                if (htmlContent.isNotEmpty)
                  _ArticleHtmlContent(
                    htmlContent: htmlContent,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    linkColor: linkColor,
                  )
                else
                  Text(
                    article.ogDescription,
                    style: textTheme.bodyLarge,
                  ),

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

          // 相關報導（全寬水平輪播）
          if (relatedArticles.isNotEmpty) ...<Widget>[
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal StatelessWidget: HTML content with extensions
// ---------------------------------------------------------------------------

class _ArticleHtmlContent extends StatelessWidget {
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
              child: EmbeddedVideoPlayer(
                url: src,
                autoplay: autoplay,
                muted: muted,
                loop: loop,
                caption: caption.isNotEmpty ? caption : null,
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
              child: EmbeddedWebView(
                src: src,
                height: height,
                caption: caption.isNotEmpty ? caption : null,
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
              child: EmbeddedWebView(
                htmlData: htmlData,
                caption: caption.isNotEmpty ? caption : null,
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
              child: YoutubePlayerWidget(
                videoId: id,
                caption: caption.isNotEmpty ? caption : null,
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
              child: ImageDiffViewer(
                beforeUrl: images[0].url,
                afterUrl: images[1].url,
                beforeDesc: images[0].desc.isNotEmpty ? images[0].desc : null,
                afterDesc: images[1].desc.isNotEmpty ? images[1].desc : null,
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
              child: SlideshowViewer(slides: slides),
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
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (relatedImageUrl != null)
                  CachedNetworkImage(
                    imageUrl: relatedImageUrl,
                    cacheManager: AppCacheManager.instance.imageCacheManager,
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
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.grey400,
                      ),
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
