import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/api/api_client.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化 API 客戶端
    final api = TwReporterApi(ApiClient.createDio());

    // 初始化路由器
    final appRouter = AppRouter();

    return ApiProvider(
      api: api,
      child: MaterialApp.router(
        title: '報導者',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter.config(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
