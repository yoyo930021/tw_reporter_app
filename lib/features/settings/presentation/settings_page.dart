import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/theme_notifier.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({required this.themeNotifier, super.key});

  final ThemeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListenableBuilder(
        listenable: themeNotifier,
        builder: (context, _) {
          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '外觀',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('跟隨系統'),
                subtitle: const Text('自動根據裝置設定切換亮色/暗色模式'),
                value: ThemeMode.system,
                groupValue: themeNotifier.themeMode,
                onChanged: (value) {
                  if (value != null) themeNotifier.setThemeMode(value);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('亮色模式'),
                value: ThemeMode.light,
                groupValue: themeNotifier.themeMode,
                onChanged: (value) {
                  if (value != null) themeNotifier.setThemeMode(value);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('暗色模式'),
                value: ThemeMode.dark,
                groupValue: themeNotifier.themeMode,
                onChanged: (value) {
                  if (value != null) themeNotifier.setThemeMode(value);
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  '資料',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('清除閱讀記錄'),
                subtitle: const Text('刪除所有閱讀歷史紀錄'),
                onTap: () => _showClearHistoryDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('清除閱讀記錄'),
        content: const Text('確定要清除所有閱讀記錄嗎？此操作無法復原。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final storage = await ReadingStorage.create();
              storage.clearHistory();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }
}
