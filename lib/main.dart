import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:http_cache_stream/http_cache_stream.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rhttp/rhttp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_reporter_app/core/api/api_client.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';
import 'package:tw_reporter_app/core/di/providers.dart';
import 'package:tw_reporter_app/core/push/push_service.dart';
import 'package:tw_reporter_app/core/repositories/reading_repository.dart';
import 'package:tw_reporter_app/core/repositories_impl/local_reading_repository.dart';
import 'package:tw_reporter_app/core/repositories_impl/tw_reporter_article_repository.dart';
import 'package:tw_reporter_app/core/repositories_impl/tw_reporter_home_repository.dart';
import 'package:tw_reporter_app/core/repositories_impl/tw_reporter_topic_repository.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/settings/media_load_mode.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/features/welcome/presentation/welcome_page.dart';

const String _themeModeKey = 'theme_mode';
const String _mediaLoadModeKey = 'media_load_mode';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 rhttp (Rust HTTP)
  await Rhttp.init();
  final rhttpClient = await RhttpCompatibleClient.create();

  // 初始化影片快取 (http_cache_stream)
  final cacheDir = await getApplicationCacheDirectory();
  await HttpCacheManager.init(
    cacheDir: Directory('${cacheDir.path}/video_cache'),
    customHttpClient: rhttpClient,
  );

  // 初始化圖片 Dio 與快取管理器
  final imageDio = ApiClient.createImageDio(rhttpClient);
  await AppCacheManager.instance.init(imageDio: imageDio);
  unawaited(AppCacheManager.instance.cleanExpired());
  await PushService.instance.init(args);

  // 如果由 UnifiedPush 背景啟動，不需要顯示 UI
  if (args.contains('--unifiedpush-bg')) return;

  final prefs = await SharedPreferences.getInstance();
  final welcomeShown = prefs.getBool(welcomeShownKey) ?? false;

  // 同步建立 ReadingRepository（不再需要 onMounted 非同步初始化）
  final readingRepo = LocalReadingRepository(ReadingStorage(prefs));

  // 從 SharedPreferences 讀取初始 ThemeMode
  final savedThemeMode = prefs.getString(_themeModeKey);
  final initialThemeMode = savedThemeMode != null
      ? ThemeMode.values.firstWhere(
          (m) => m.name == savedThemeMode,
          orElse: () => ThemeMode.system,
        )
      : ThemeMode.system;

  // 從 SharedPreferences 讀取初始 MediaLoadMode
  final savedMediaLoadMode = prefs.getString(_mediaLoadModeKey);
  final initialMediaLoadMode = savedMediaLoadMode != null
      ? MediaLoadMode.values.firstWhere(
          (m) => m.name == savedMediaLoadMode,
          orElse: () => MediaLoadMode.normal,
        )
      : MediaLoadMode.normal;

  runApp(MyApp(
    showWelcome: !welcomeShown,
    readingRepo: readingRepo,
    initialThemeMode: initialThemeMode,
    rhttpClient: rhttpClient,
    initialMediaLoadMode: initialMediaLoadMode,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.readingRepo,
    required this.initialThemeMode,
    required this.rhttpClient,
    required this.initialMediaLoadMode,
    super.key,
    this.showWelcome = false,
  });

  final bool showWelcome;
  final ReadingRepository readingRepo;
  final ThemeMode initialThemeMode;
  final RhttpCompatibleClient rhttpClient;
  final MediaLoadMode initialMediaLoadMode;

  @override
  Widget build(BuildContext context) => _MyAppContent(
        showWelcome: showWelcome,
        readingRepo: readingRepo,
        initialThemeMode: initialThemeMode,
        rhttpClient: rhttpClient,
        initialMediaLoadMode: initialMediaLoadMode,
      );
}

class _MyAppContent extends CompositionWidget {
  const _MyAppContent({
    required this.showWelcome,
    required this.readingRepo,
    required this.initialThemeMode,
    required this.rhttpClient,
    required this.initialMediaLoadMode,
  });

  final bool showWelcome;
  final ReadingRepository readingRepo;
  final ThemeMode initialThemeMode;
  final RhttpCompatibleClient rhttpClient;
  final MediaLoadMode initialMediaLoadMode;

  @override
  Widget Function(BuildContext) setup() {
    final themeModeRef = ref(initialThemeMode);
    final mediaLoadModeRef = ref(initialMediaLoadMode);

    final dio = ApiClient.createDio(
      rhttpClient: rhttpClient,
      cacheOptions: AppCacheManager.instance.httpCacheOptions,
    );
    final api = TwReporterApi(dio);
    final articleRepo = TwReporterArticleRepository(api);
    final topicRepo = TwReporterTopicRepository(api);
    final homeRepo = TwReporterHomeRepository(api);
    final appRouter = AppRouter();

    // Provide all dependencies
    provideArticleRepository(articleRepo);
    provideTopicRepository(topicRepo);
    provideHomeRepository(homeRepo);
    provideReadingRepository(readingRepo);
    provideThemeMode(themeModeRef);
    provideMediaLoadMode(mediaLoadModeRef);

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

    onMounted(() {
      PushService.instance.addStateListener(handlePushNotificationTap);

      // 首次啟動導航到歡迎頁面
      if (showWelcome) {
        unawaited(appRouter.push(const WelcomeRoute()));
      }
    });

    onUnmounted(() {
      PushService.instance.removeStateListener(handlePushNotificationTap);
    });

    return (BuildContext context) {
      return MaterialApp.router(
        title: '閱報導者',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeModeRef.value,
        routerConfig: appRouter.config(),
        debugShowCheckedModeBanner: false,
      );
    };
  }
}
