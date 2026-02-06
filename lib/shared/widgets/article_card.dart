import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';
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
    final String? imageUrl = _getImageUrl();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      clipBehavior: Clip.antiAlias,
      color: isDark ? null : const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) => Container(
                  height: 200,
                  color: AppColors.grey200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget:
                    (BuildContext context, String url, Object error) =>
                        Container(
                  height: 200,
                  color: AppColors.grey200,
                  child: const Icon(Icons.image_not_supported,
                      color: AppColors.grey400),
                ),
              ),
            Padding(
              padding: AppSpacing.edgeInsetsCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (article.categorySet.isNotEmpty &&
                      article.categorySet.first.category != null) ...<Widget>[
                    CategoryBadge(
                      categoryName:
                          article.categorySet.first.category!.name,
                    ),
                    AppSpacing.verticalSpacerSm,
                  ],
                  Text(
                    article.title,
                    style: AppTextStyles.headline3.copyWith(fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalSpacerSm,
                  Text(
                    article.ogDescription,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalSpacerSm,
                  Row(
                    children: <Widget>[
                      Text(
                        formatDate(article.publishedDate),
                        style: AppTextStyles.timestamp,
                      ),
                      if (isRead) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grey300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '已讀',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.grey600,
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

  static String? getArticleImageUrl(Article article) {
    final heroImage = article.heroImage ?? article.ogImage;
    if (heroImage == null) return null;
    return heroImage.resizedTargets.w400?.url ??
        heroImage.resizedTargets.mobile?.url ??
        heroImage.resizedTargets.tiny?.url;
  }
}
