import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';
import 'package:tw_reporter_app/shared/widgets/cached_image.dart';
import 'package:tw_reporter_app/shared/widgets/category_badge.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    required this.article,
    required this.onTap,
    this.isRead = false,
    super.key,
  });

  final Article article;
  final VoidCallback onTap;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    final placeholderUrl = _getPlaceholderUrl();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      clipBehavior: Clip.antiAlias,
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (imageUrl != null)
              Hero(
                tag: 'article-image-${article.slug}',
                child: CachedImage(
                  imageUrl: imageUrl,
                  placeholderUrl: placeholderUrl,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            Padding(
              padding: AppSpacing.edgeInsetsCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (article.categorySet.isNotEmpty &&
                      article.categorySet.first.category !=
                          null) ...<Widget>[
                    CategoryBadge(
                      categoryName:
                          article
                              .categorySet.first.category!.name,
                    ),
                    AppSpacing.verticalSpacerSm,
                  ],
                  Text(
                    article.title,
                    style: textTheme.displaySmall!
                        .copyWith(fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    article.ogDescription,
                    style: textTheme.bodyMedium!.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalSpacerSm,
                  Row(
                    children: <Widget>[
                      Text(
                        formatDate(article.publishedDate),
                        style: textTheme.timestamp,
                      ),
                      if (isRead) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colors.outlineVariant,
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                          child: Text(
                            '已讀',
                            style:
                                textTheme.labelSmall!.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getImageUrl() => getArticleImageUrl(article);

  String? _getPlaceholderUrl() {
    final heroImage = article.heroImage ?? article.ogImage;
    if (heroImage == null) return null;
    return heroImage.resizedTargets.tiny?.url;
  }

  static String? getArticleImageUrl(Article article) {
    final heroImage = article.heroImage ?? article.ogImage;
    if (heroImage == null) return null;
    return heroImage.resizedTargets.w400?.url ??
        heroImage.resizedTargets.mobile?.url ??
        heroImage.resizedTargets.tiny?.url;
  }
}
