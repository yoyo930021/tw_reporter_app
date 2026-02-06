import 'dart:ui' show lerpDouble;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/image_size.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/features/topics/logic/use_topic_detail.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/error_view.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';
import 'package:tw_reporter_app/shared/widgets/section_header.dart';

@RoutePage()
class TopicDetailPage extends StatelessWidget {
  const TopicDetailPage({
    this.api,
    @PathParam('slug') required this.slug,
    this.topic,
    super.key,
  });

  final TwReporterApi? api;
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
    final apiInstance = api ?? ApiProvider.of(context).api;
    return _TopicDetailPageContent(api: apiInstance, topic: topic!);
  }
}

class _TopicDetailPageContent extends CompositionWidget {
  const _TopicDetailPageContent({
    required this.api,
    required this.topic,
  });

  final TwReporterApi api;
  final Topic topic;

  @override
  Widget Function(BuildContext) setup() {
    final TopicDetailResult detail = useTopicDetail(
      api,
      topic: topic,
    );

    return (BuildContext context) {
      final Topic currentTopic = detail.topic.value;
      final String title =
          currentTopic.shortTitle ?? currentTopic.title;
      final String? imageUrl = _getImageUrl(currentTopic);
      final bool hasImage = imageUrl != null;

      return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: hasImage ? 300.0 : 160.0,
              pinned: true,
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

                  return FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    expandedTitleScale: 1.5,
                    titlePadding: EdgeInsetsDirectional.only(
                      start: lerpDouble(56, 16, expandRatio)!,
                      bottom: 16,
                      end: lerpDouble(16, 16, expandRatio)!,
                    ),
                    title: Text(
                      title,
                      maxLines: expandRatio > 0.4 ? 4 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: hasImage ? Colors.white : null,
                        shadows: hasImage
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
                      imageUrl: imageUrl,
                      hasImage: hasImage,
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _buildBody(context, detail),
            ),
          ],
        ),
      );
    };
  }

  Widget _buildBody(BuildContext context, TopicDetailResult detail) {
    final Topic currentTopic = detail.topic.value;

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
                formatDate(currentTopic.publishedDate),
                style: AppTextStyles.timestamp,
              ),
              AppSpacing.verticalSpacerMd,

              if (currentTopic.ogDescription != null) ...<Widget>[
                Text(
                  currentTopic.ogDescription!,
                  style: AppTextStyles.body1,
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

        _buildRelatedArticles(context, detail),
      ],
    );
  }

  Widget _buildRelatedArticles(
      BuildContext context, TopicDetailResult detail) {
    if (detail.hasError.value) {
      return Padding(
        padding: AppSpacing.edgeInsetsMd,
        child: ErrorView(
          message: detail.error.value ?? '載入相關文章失敗',
          onRetry: detail.refresh,
        ),
      );
    }

    if (detail.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: LoadingIndicator(),
      );
    }

    if (detail.relatedArticles.value.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: EmptyState(message: '沒有相關文章'),
      );
    }

    return Column(
      children: detail.relatedArticles.value.map((Article article) {
        return ArticleCard(
          article: article,
          onTap: () {
            context.router.push(ArticleRoute(
              slug: article.slug,
              heroImageUrl: ArticleCard.getArticleImageUrl(article),
            ));
          },
        );
      }).toList(),
    );
  }

  Widget? _buildFlexibleBackground({
    required String? imageUrl,
    required bool hasImage,
  }) {
    if (!hasImage || imageUrl == null) return null;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        CachedNetworkImage(
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

  String? _getImageUrl(Topic topic) {
    final HeroImage? leadingImage = topic.leadingImage ?? topic.ogImage;
    if (leadingImage == null) return null;
    return leadingImage.resizedTargets.mobile?.url ??
        leadingImage.resizedTargets.w400?.url ??
        leadingImage.resizedTargets.tiny?.url;
  }
}
