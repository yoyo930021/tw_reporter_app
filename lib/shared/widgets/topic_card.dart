import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';

class TopicCard extends StatelessWidget {
  const TopicCard({
    required this.topic,
    required this.onTap,
    super.key,
  });

  final Topic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = _getImageUrl();

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      clipBehavior: Clip.antiAlias,
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
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) => Container(
                  height: 180,
                  color: AppColors.grey200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget:
                    (BuildContext context, String url, Object error) =>
                        Container(
                  height: 180,
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
                  Text(
                    topic.title,
                    style: AppTextStyles.headline3.copyWith(fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (topic.ogDescription != null) ...<Widget>[
                    AppSpacing.verticalSpacerSm,
                    Text(
                      topic.ogDescription!,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  AppSpacing.verticalSpacerSm,
                  Text(
                    formatDate(topic.publishedDate),
                    style: AppTextStyles.timestamp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getImageUrl() {
    final ogImage = topic.ogImage ?? topic.leadingImage;
    if (ogImage == null) return null;
    return ogImage.resizedTargets.w400?.url ??
        ogImage.resizedTargets.mobile?.url ??
        ogImage.resizedTargets.tiny?.url;
  }
}
