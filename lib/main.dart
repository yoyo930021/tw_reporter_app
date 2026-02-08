import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/api_client.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/di/app_providers.dart';
import 'package:tw_reporter_app/core/push/push_service.dart';
import 'package:tw_reporter_app/core/repositories/reading_repository.dart';
import 'package:tw_reporter_app/core/repositories_impl/local_reading_repository.dart';
import 'package:tw_reporter_app/core/repositories_impl/tw_reporter_article_repository.dart';
import 'package:tw_reporter_app/core/repositories_impl/tw_reporter_home_repository.dart';
import 'package:tw_reporter_app/core/repositories_impl/tw_reporter_topic_repository.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/core/theme/theme_notifier.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushService.instance.init(args);

  // 如果由 UnifiedPush 背景啟動，不需要顯示 UI
  if (args.contains('--unifiedpush-bg')) return;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const _MyAppContent();
}

class _MyAppContent extends CompositionWidget {
  const _MyAppContent();

  @override
  Widget Function(BuildContext) setup() {
    final themeNotifierRef = manageChangeNotifier(ThemeNotifier());

    final api = TwReporterApi(ApiClient.createDio());
    final articleRepo = TwReporterArticleRepository(api);
    final topicRepo = TwReporterTopicRepository(api);
    final homeRepo = TwReporterHomeRepository(api);
    final appRouter = AppRouter();
    final readingRepo = ref<ReadingRepository?>(null);

    void handlePushNotificationTap() {
      final payload = PushService.instance.consumePendingPayload();
      if (payload == null) return;

      final uri = Uri.tryParse(payload);
      if (uri == null) return;

      final segments = uri.pathSegments;
      if (segments.length >= 2 && segments[0] == 'a') {
        unawaited(appRouter.push(ArticleRoute(slug: segments[1])));
      } else if (segments.length >= 2 && segments[0] == 'topics') {
        unawaited(appRouter.push(TopicDetailRoute(slug: segments[1])));
      }
    }

    onMounted(() async {
      PushService.instance.addListener(handlePushNotificationTap);
      final repo = await LocalReadingRepository.create();
      readingRepo.value = repo;
    });

    onUnmounted(() {
      PushService.instance.removeListener(handlePushNotificationTap);
    });

    return (BuildContext context) {
      final repo = readingRepo.value;
      if (repo == null) {
        return const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      final notifier = themeNotifierRef.value;
      return AppProviders(
        articleRepository: articleRepo,
        topicRepository: topicRepo,
        homeRepository: homeRepo,
        readingRepository: repo,
        themeNotifier: notifier,
        child: MaterialApp.router(
          title: '報導者',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: notifier.themeMode,
          routerConfig: appRouter.config(),
          debugShowCheckedModeBanner: false,
        ),
      );
    };
  }
}
