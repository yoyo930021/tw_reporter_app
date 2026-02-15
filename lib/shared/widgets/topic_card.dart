import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';
import 'package:tw_reporter_app/shared/widgets/cached_image.dart';

class TopicCard extends StatelessWidget {
  const TopicCard({
    required this.topic,
    required this.onTap,
    this.margin,
    super.key,
  });

  final Topic topic;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    final placeholderUrl = _getPlaceholderUrl();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (imageUrl != null)
              CachedImage(
                imageUrl: imageUrl,
                placeholderUrl: placeholderUrl,
                height: 180,
                width: double.infinity,
              ),
            Padding(
              padding: AppSpacing.edgeInsetsCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    topic.title,
                    style: textTheme.displaySmall!
                        .copyWith(fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (topic.ogDescription !=
                      null) ...<Widget>[
                    AppSpacing.verticalSpacerSm,
                    Text(
                      topic.ogDescription!,
                      style: textTheme.bodyMedium!.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  AppSpacing.verticalSpacerSm,
                  Text(
                    formatDate(topic.publishedDate),
                    style: textTheme.timestamp,
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

  String? _getPlaceholderUrl() {
    final ogImage = topic.ogImage ?? topic.leadingImage;
    if (ogImage == null) return null;
    return ogImage.resizedTargets.tiny?.url;
  }
}
