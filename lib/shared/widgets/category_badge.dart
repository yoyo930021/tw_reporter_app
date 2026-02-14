import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({
    required this.categoryName,
    super.key,
    this.subcategoryName,
  });

  final String categoryName;
  final String? subcategoryName;

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.categoryColors[categoryName] ?? AppColors.grey600;
    final label = subcategoryName != null
        ? '$categoryName / $subcategoryName'
        : categoryName;

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
        label,
        style: Theme.of(context).textTheme.categoryTag.copyWith(color: color),
      ),
    );
  }
}
