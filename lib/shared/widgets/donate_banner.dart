import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 贊助報導者橫幅
///
/// 可用於首頁底部和文章底部，點擊開啟贊助頁面
class DonateBanner extends StatelessWidget {
  const DonateBanner({super.key, this.compact = false});

  /// 是否使用緊湊模式（用於文章頁面）
  final bool compact;

  static const String _donateUrl =
      'https://www.twreporter.org/donation/period';

  void _openDonation() {
    unawaited(launchUrl(
      Uri.parse(_donateUrl),
      mode: LaunchMode.inAppBrowserView,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (compact) {
      return Padding(
        padding: AppSpacing.edgeInsetsHorizontalMd,
        child: Column(
          children: <Widget>[
            AppSpacing.verticalSpacerLg,
            const Divider(),
            AppSpacing.verticalSpacerSm,
            Text(
              '喜歡這篇報導嗎？',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            AppSpacing.verticalSpacerSm,
            FilledButton.icon(
              onPressed: _openDonation,
              icon: const Icon(Icons.favorite, size: 18),
              label: const Text('贊助報導者'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
            ),
            AppSpacing.verticalSpacerSm,
          ],
        ),
      );
    }

    return Padding(
      padding: AppSpacing.edgeInsetsHorizontalMd,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: AppColors.primary,
        child: InkWell(
          onTap: _openDonation,
          child: Padding(
            padding: AppSpacing.edgeInsetsLg,
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 32,
                ),
                AppSpacing.verticalSpacerSm,
                Text(
                  '贊助報導者',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  '用行動支持好新聞',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
