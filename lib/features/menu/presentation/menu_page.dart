import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  static const List<(String, String)> _categories = <(String, String)>[
    ('國際兩岸', 'world'),
    ('人權司法', 'humanrights'),
    ('政治社會', 'politics_and_society'),
    ('醫療健康', 'health'),
    ('環境永續', 'environment'),
    ('經濟產業', 'econ'),
    ('文化生活', 'culture'),
    ('教育校園', 'education'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('選單'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: <Widget>[
          // 分類區塊
          const _SectionTitle(title: '分類'),
          ..._categories.map((entry) {
            final (label, slug) = entry;
            final color = AppColors.categoryColors[slug];
            return ListTile(
              leading: Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: color ?? colors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              title: Text(label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                unawaited(
                  context.router.push(CategoryRoute(category: slug)),
                );
              },
            );
          }),

          const Divider(height: AppSpacing.lg),

          // 其他區塊
          const _SectionTitle(title: '其他'),
          ListTile(
            leading: const Icon(Icons.favorite, color: AppColors.secondary),
            title: const Text('贊助報導者'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              unawaited(launchUrl(
                Uri.parse('https://www.twreporter.org/donation/period'),
                mode: LaunchMode.inAppBrowserView,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('查看原始碼'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              unawaited(launchUrl(
                Uri.parse(
                    'https://github.com/yoyo930021/tw_reporter_app'),
                mode: LaunchMode.inAppBrowserView,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('回報問題'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              unawaited(launchUrl(
                Uri.parse(
                    'https://github.com/yoyo930021/tw_reporter_app/issues'),
                mode: LaunchMode.inAppBrowserView,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('開源授權'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: '閱報導者',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    'MIT License \u00a9 2025 yoyo930021',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              unawaited(context.router.push(const SettingsRoute()));
            },
          ),

          const Divider(height: AppSpacing.lg),

          // 底部資訊
          Padding(
            padding: AppSpacing.edgeInsetsMd,
            child: Column(
              children: <Widget>[
                AppSpacing.verticalSpacerMd,
                Text(
                  '閱報導者',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  '非官方 · 開源 · 內容來自報導者',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                AppSpacing.verticalSpacerXs,
                Text(
                  'v1.0.0',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
