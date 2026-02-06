import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/api/api_client.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/core/theme/theme_notifier.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';

void main() {
  runApp(const MyApp());
}

/// ThemeNotifier Provider
class ThemeNotifierProvider extends InheritedNotifier<ThemeNotifier> {
  const ThemeNotifierProvider({
    required ThemeNotifier notifier,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  static ThemeNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeNotifierProvider>();
    return provider!.notifier!;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _themeNotifier = ThemeNotifier();
  late final AppRouter _appRouter;
  late final TwReporterApi _api;

  @override
  void initState() {
    super.initState();
    _api = TwReporterApi(ApiClient.createDio());
    _appRouter = AppRouter();
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeNotifierProvider(
      notifier: _themeNotifier,
      child: ApiProvider(
        api: _api,
        child: ListenableBuilder(
          listenable: _themeNotifier,
          builder: (context, _) {
            return MaterialApp.router(
              title: '報導者',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _themeNotifier.themeMode,
              routerConfig: _appRouter.config(),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
