import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/composables.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/features/topics/logic/use_topic_detail.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/cached_image.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/error_view.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';
import 'package:tw_reporter_app/shared/widgets/section_header.dart';

enum _ViewState { error, loading, empty, ready }

String? _getTopicImageUrl(Topic topic) {
  final leadingImage = topic.leadingImage ?? topic.ogImage;
  if (leadingImage == null) return null;
  return leadingImage.resizedTargets.mobile?.url ??
      leadingImage.resizedTargets.w400?.url ??
      leadingImage.resizedTargets.tiny?.url;
}

String? _getLowResTopicImageUrl(Topic topic) {
  final ogImage = topic.ogImage ?? topic.leadingImage;
  if (ogImage == null) return null;
  return ogImage.resizedTargets.w400?.url ??
      ogImage.resizedTargets.tiny?.url;
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

@RoutePage()
class TopicDetailPage extends StatelessWidget {
  const TopicDetailPage({
    @PathParam('slug') required this.slug,
    this.topic,
    super.key,
  });

  final String slug;
  final Topic? topic;

  @override
  Widget build(BuildContext context) {
    if (topic == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('專題')),
        body: const Center(child: Text('無法載入專題資料')),
      );
    }
    return _TopicDetailPageContent(topic: topic!);
  }
}

class _TopicDetailPageContent extends CompositionWidget {
  const _TopicDetailPageContent({
    required this.topic,
  });

  final Topic topic;

  @override
  Widget Function(BuildContext) setup() {
    final repo = useArticleRepository();
    final detail = useTopicDetail(
      repo,
      topic: topic,
    );

    final title = computed(() {
      final t = detail.topic.value;
      return t.shortTitle ?? t.title;
    });
    final imageUrl = computed(() => _getTopicImageUrl(detail.topic.value));
    final lowResImageUrl =
        computed(() => _getLowResTopicImageUrl(detail.topic.value));
    final hasImage = computed(() => imageUrl.value != null);

    return (BuildContext context) {
      return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: hasImage.value ? 300.0 : 160.0,
              pinned: true,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final statusBarHeight =
                      MediaQuery.of(context).padding.top;
                  final minExtent =
                      kToolbarHeight + statusBarHeight;
                  final expandedHeight =
                      hasImage.value ? 300.0 : 160.0;
                  final maxExtent =
                      expandedHeight + statusBarHeight;
                  final expandRatio =
                      ((constraints.maxHeight - minExtent) /
                              (maxExtent - minExtent))
                          .clamp(0.0, 1.0);

                  return FlexibleSpaceBar(
                    titlePadding: EdgeInsetsDirectional.only(
                      start:
                          lerpDouble(56, 16, expandRatio)!,
                      bottom: 16,
                      end:
                          lerpDouble(16, 16, expandRatio)!,
                    ),
                    title: Text(
                      title.value,
                      maxLines:
                          expandRatio > 0.4 ? 4 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: hasImage.value
                            ? Colors.white
                            : null,
                        shadows: hasImage.value
                            ? const <Shadow>[
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    background: _buildFlexibleBackground(
                      slug: detail.topic.value.slug,
                      imageUrl: imageUrl.value,
                      hasImage: hasImage.value,
                      lowResImageUrl: lowResImageUrl.value,
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _TopicBody(
                detail: detail,
              ),
            ),
          ],
        ),
      );
    };
  }
}

// ---------------------------------------------------------------------------
// Private CompositionWidget: Topic body
// ---------------------------------------------------------------------------

class _TopicBody extends CompositionWidget {
  const _TopicBody({
    required this.detail,
  });

  final TopicDetailResult detail;

  @override
  Widget Function(BuildContext) setup() {
    final theme = useTheme();

    return (BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: AppSpacing.edgeInsetsMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppSpacing.verticalSpacerSm,
                Text(
                  formatDate(detail.topic.value.publishedDate),
                  style: theme.value.textTheme.timestamp,
                ),
                AppSpacing.verticalSpacerMd,
                if (detail.topic.value.ogDescription !=
                    null) ...<Widget>[
                  Text(
                    detail.topic.value.ogDescription!,
                    style: theme.value.textTheme.bodyLarge,
                  ),
                  AppSpacing.verticalSpacerLg,
                ],
                const Divider(),
                AppSpacing.verticalSpacerMd,
                const SectionHeader(title: '相關文章'),
                AppSpacing.verticalSpacerMd,
              ],
            ),
          ),
          _TopicRelatedArticles(detail: detail),
        ],
      );
    };
  }
}

// ---------------------------------------------------------------------------
// Private CompositionWidget: Topic related articles
// ---------------------------------------------------------------------------

class _TopicRelatedArticles extends CompositionWidget {
  const _TopicRelatedArticles({
    required this.detail,
  });

  final TopicDetailResult detail;

  @override
  Widget Function(BuildContext) setup() {
    final state = computed(() {
      if (detail.hasError.value) return _ViewState.error;
      if (detail.isLoading.value) return _ViewState.loading;
      if (detail.relatedArticles.value.isEmpty) return _ViewState.empty;
      return _ViewState.ready;
    });

    return (BuildContext context) => switch (state.value) {
          _ViewState.error => Padding(
              padding: AppSpacing.edgeInsetsMd,
              child: ErrorView(
                message: detail.error.value ?? '載入相關文章失敗',
                onRetry: detail.refresh,
              ),
            ),
          _ViewState.loading => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: LoadingIndicator(),
            ),
          _ViewState.empty => const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: EmptyState(message: '沒有相關文章'),
            ),
          _ViewState.ready => Column(
              children: detail.relatedArticles.value.map((article) {
                return ArticleCard(
                  article: article,
                  onTap: () {
                    unawaited(context.router.push(
                      ArticleRoute(
                        slug: article.slug,
                        heroImageUrl:
                            ArticleCard.getArticleImageUrl(article),
                      ),
                    ));
                  },
                );
              }).toList(),
            ),
        };
  }
}
