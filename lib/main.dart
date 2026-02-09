import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_reporter_app/core/api/api_client.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';
import 'package:tw_reporter_app/core/cache/video_cache_service.dart';
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
import 'package:tw_reporter_app/features/welcome/presentation/welcome_page.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppCacheManager.instance.init();
  unawaited(AppCacheManager.instance.cleanExpired());
  await PushService.instance.init(args);

  // 如果由 UnifiedPush 背景啟動，不需要顯示 UI
  if (args.contains('--unifiedpush-bg')) return;

  final prefs = await SharedPreferences.getInstance();
  final welcomeShown = prefs.getBool(welcomeShownKey) ?? false;

  runApp(MyApp(showWelcome: !welcomeShown));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.showWelcome = false});

  final bool showWelcome;

  @override
  Widget build(BuildContext context) => _MyAppContent(showWelcome: showWelcome);
}

class _MyAppContent extends CompositionWidget {
  const _MyAppContent({required this.showWelcome});

  final bool showWelcome;

  @override
  Widget Function(BuildContext) setup() {
    final themeNotifierRef = manageChangeNotifier(ThemeNotifier());

    final dio = ApiClient.createDio();
    final api = TwReporterApi(dio);
    final articleRepo = TwReporterArticleRepository(api);
    final topicRepo = TwReporterTopicRepository(api);
    final homeRepo = TwReporterHomeRepository(api);
    final videoCacheService = VideoCacheService(dio);
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

      // 首次啟動導航到歡迎頁面
      if (showWelcome) {
        unawaited(appRouter.push(const WelcomeRoute()));
      }
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
        videoCacheService: videoCacheService,
        child: MaterialApp.router(
          title: '閱報導者',
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
