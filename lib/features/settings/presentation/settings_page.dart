import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';
import 'package:tw_reporter_app/core/di/composables.dart';
import 'package:tw_reporter_app/core/push/push_service.dart';
import 'package:tw_reporter_app/core/settings/media_load_mode.dart';

const String _themeModeKey = 'theme_mode';
const String _mediaLoadModeKey = 'media_load_mode';

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _formatDistributorName(String packageName) {
  const knownNames = <String, String>{
    // Embedded FCM (self)
    'org.twreporter.tw_reporter_app': 'Firebase Cloud Messaging',
    // Dedicated distributors
    'io.heckel.ntfy': 'ntfy',
    'org.unifiedpush.distributor.fcm': 'UP-FCM Distributor',
    'org.unifiedpush.distributor.noprovider2push':
        'NoProvider2Push',
    'org.unifiedpush.distributor.nextpush':
        'NextPush (Nextcloud)',
    'eu.siacs.conversations': 'Conversations',
    'de.pixart.messenger': 'Conversations (Pixart)',
    'im.vector.app': 'Element',
    'io.element.android.x': 'Element X',
    'org.thoughtcrime.securesms': 'Molly/Signal',
    'im.molly.app': 'Molly',
    'chat.fluffy.fluffychat': 'FluffyChat',
    'org.jitsi.meet': 'Jitsi Meet',
    'com.github.gotify': 'Gotify',
    'dev.binh.notifo': 'Notifo',
  };
  return knownNames[packageName] ??
      packageName.split('.').last.replaceAll('_', ' ');
}

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsPageContent();
  }
}

class _SettingsPageContent extends CompositionWidget {
  const _SettingsPageContent();

  @override
  Widget Function(BuildContext) setup() {
    final themeModeRef = useThemeMode();
    final mediaLoadModeRef = useMediaLoadMode();
    final readingRepo = useReadingRepository();

    final pushEnabled = ref(PushService.instance.enabled);
    final pushError = ref<String?>(PushService.instance.registrationError);
    final pushService = PushService.instance;
    final cacheSize = ref<int?>(null);

    void syncPushState() {
      pushEnabled.value = pushService.enabled;
      pushError.value = pushService.registrationError;
    }

    onMounted(() {
      pushService.addStateListener(syncPushState);
      syncPushState();
    });

    onUnmounted(() {
      pushService.removeStateListener(syncPushState);
    });

    Future<void> refreshCacheSize() async {
      cacheSize.value =
          await AppCacheManager.instance.getTotalCacheSize();
    }

    onMounted(() async {
      await refreshCacheSize();
    });

    Future<void> setThemeMode(ThemeMode mode) async {
      if (themeModeRef.value == mode) return;
      themeModeRef.value = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
    }

    void showNoDistributorDialog(BuildContext context) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('需要推播服務'),
            content: const Text(
              '推播通知需要安裝 UnifiedPush 相容的推送服務 '
              '（如 ntfy、NextPush 等）。\n\n'
              '請先從應用商店安裝其中一個服務後再啟用推播。',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('了解'),
              ),
            ],
          ),
        ),
      );
    }

    Future<String?> showDistributorPicker(
      BuildContext context, List<String> distributors) {
      return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('選擇推播服務'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('請選擇要使用的推播提供者：'),
              const SizedBox(height: 16),
              ...distributors.map((d) {
                final label = _formatDistributorName(d);
                return ListTile(
                  title: Text(label),
                  subtitle: Text(
                    d,
                    style:
                        Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () => Navigator.pop(context, d),
                );
              }),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        ),
      );
    }

    Future<void> handleEnablePush(
      BuildContext context, PushService pushService) async {
      final plugin = FlutterLocalNotificationsPlugin();
      final androidPlugin =
          plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted =
            await androidPlugin.requestNotificationsPermission();
        if (granted != true) {
          return;
        }
      }

      final distributors = await pushService.getDistributors();

      if (distributors.isEmpty) {
        if (context.mounted) {
          showNoDistributorDialog(context);
        }
        return;
      }

      String? chosen;
      if (distributors.length == 1) {
        chosen = distributors.first;
      } else if (context.mounted) {
        chosen = await showDistributorPicker(
            context, distributors);
      }

      if (chosen == null) return;

      final success =
          await pushService.enable(distributor: chosen);
      if (!success && context.mounted) {
        showNoDistributorDialog(context);
      }
    }

    void showClearCacheDialog(BuildContext context) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('清除快取'),
            content:
                const Text('確定要清除所有快取資料嗎？包含 HTTP 快取、圖片快取和影片快取。'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  await AppCacheManager.instance.clearAll();
                  await refreshCacheSize();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('清除'),
              ),
            ],
          ),
        ),
      );
    }

    void showClearHistoryDialog(BuildContext context) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('清除閱讀記錄'),
            content:
                const Text('確定要清除所有閱讀記錄嗎？此操作無法復原。'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  readingRepo.clearHistory();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('清除'),
              ),
            ],
          ),
        ),
      );
    }

    return (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('設定'),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '外觀',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
              ),
            ),
            RadioGroup<ThemeMode>(
              groupValue: themeModeRef.value,
              onChanged: (value) {
                if (value != null) {
                  unawaited(setThemeMode(value));
                }
              },
              child: const Column(
                children: <Widget>[
                  RadioListTile<ThemeMode>(
                    title: Text('跟隨系統'),
                    subtitle: Text(
                      '自動根據裝置設定切換亮色/暗色模式',
                    ),
                    value: ThemeMode.system,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('亮色模式'),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('暗色模式'),
                    value: ThemeMode.dark,
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                '網路',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
              ),
            ),
            RadioGroup<MediaLoadMode>(
              groupValue: mediaLoadModeRef.value,
              onChanged: (value) async {
                if (value == null) return;
                mediaLoadModeRef.value = value;
                final prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString(
                  _mediaLoadModeKey,
                  value.name,
                );
              },
              child: const Column(
                children: <Widget>[
                  RadioListTile<MediaLoadMode>(
                    title: Text('省流量'),
                    subtitle: Text('所有媒體和圖片需手動點擊載入'),
                    value: MediaLoadMode.dataSaving,
                  ),
                  RadioListTile<MediaLoadMode>(
                    title: Text('一般'),
                    subtitle: Text('媒體捲動至可見時自動載入'),
                    value: MediaLoadMode.normal,
                  ),
                ],
              ),
            ),
            if (pushService.isSupported) ...<Widget>[
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  '通知',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                ),
              ),
              SwitchListTile(
                title: const Text('推播通知'),
                subtitle: Text(
                  pushError.value != null
                      ? '${pushError.value}'
                      : pushEnabled.value
                          ? '已啟用推播通知'
                          : '啟用後可接收報導者最新文章通知',
                ),
                value: pushEnabled.value,
                onChanged: (value) async {
                  if (value) {
                    await handleEnablePush(
                      context,
                      pushService,
                    );
                  } else {
                    await pushService.disable();
                  }
                },
              ),
            ],
            const Divider(),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                '資料',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('清除閱讀記錄'),
              subtitle: const Text('刪除所有閱讀歷史紀錄'),
              onTap: () => showClearHistoryDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('快取空間'),
              subtitle: Text(
                cacheSize.value != null
                    ? '已使用 ${_formatBytes(cacheSize.value!)}'
                    : '計算中...',
              ),
              trailing: TextButton(
                onPressed: () =>
                    showClearCacheDialog(context),
                child: const Text('清除'),
              ),
            ),
          ],
        ),
      );
    };
  }
}
