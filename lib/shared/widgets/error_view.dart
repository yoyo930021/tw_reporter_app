import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: AppSpacing.edgeInsetsMd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 48,
              color: colors.error,
            ),
            AppSpacing.verticalSpacerMd,
            Text(
              '發生錯誤',
              style: textTheme.displaySmall!.copyWith(
                color: colors.onSurface,
              ),
            ),
            AppSpacing.verticalSpacerSm,
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium!.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalSpacerMd,
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重試'),
            ),
          ],
        ),
      ),
    );
  }
}
