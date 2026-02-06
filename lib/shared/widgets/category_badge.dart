import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({
    required this.categoryName,
    super.key,
  });

  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final Color color =
        AppColors.categoryColors[categoryName] ?? AppColors.grey600;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        categoryName,
        style: AppTextStyles.categoryTag.copyWith(color: color),
      ),
    );
  }
}
