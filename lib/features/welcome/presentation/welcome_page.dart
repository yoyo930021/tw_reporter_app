import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// SharedPreferences key for welcome screen shown flag
const String welcomeShownKey = 'welcome_shown';

@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _onStart(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(welcomeShownKey, true);
    if (context.mounted) {
      unawaited(
        context.router.replaceAll(const [MainShellRoute()]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: <Widget>[
              const Spacer(flex: 2),
              // App name
              Text(
                '閱報導者',
                style: textTheme.headlineLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalSpacerSm,
              Text(
                '非官方開源客戶端',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              // Description
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _InfoRow(
                      icon: Icons.auto_stories,
                      text: '這是一個開源的報導者閱讀器',
                      color: colors.onSurface,
                    ),
                    AppSpacing.verticalSpacerSm,
                    _InfoRow(
                      icon: Icons.language,
                      text: '內容來自報導者（The Reporter）',
                      color: colors.onSurface,
                    ),
                    AppSpacing.verticalSpacerSm,
                    const _InfoRow(
                      icon: Icons.info_outline,
                      text: '本 APP 非報導者官方出品',
                      color: AppColors.accent,
                    ),
                    AppSpacing.verticalSpacerSm,
                    const _InfoRow(
                      icon: Icons.warning_amber,
                      text: '遇到問題請到 GitHub 回報，勿聯繫報導者官方',
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalSpacerLg,
              // GitHub link
              TextButton.icon(
                onPressed: () {
                  unawaited(launchUrl(
                    Uri.parse(
                        'https://github.com/yoyo930021/tw_reporter_app'),
                    mode: LaunchMode.inAppBrowserView,
                  ));
                },
                icon: const Icon(Icons.code),
                label: const Text('GitHub 原始碼'),
              ),
              const Spacer(),
              // Start button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _onStart(context),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Text(
                      '開始使用',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                ),
          ),
        ),
      ],
    );
  }
}
