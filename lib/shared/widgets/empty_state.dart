import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.icon,
    super.key,
  });

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(
              icon,
              size: 48,
              color: colors.onSurfaceVariant,
            ),
            AppSpacing.verticalSpacerMd,
          ],
          Text(
            message,
            style: textTheme.bodyLarge!.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
