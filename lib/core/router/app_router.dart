import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/theme_notifier.dart';
import 'package:tw_reporter_app/features/article/presentation/article_page.dart';
import 'package:tw_reporter_app/features/category/presentation/category_page.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/features/latest/presentation/latest_page.dart';
import 'package:tw_reporter_app/features/main/presentation/main_shell.dart';
import 'package:tw_reporter_app/features/my_reading/presentation/my_reading_page.dart';
import 'package:tw_reporter_app/features/search/presentation/search_page.dart';
import 'package:tw_reporter_app/features/settings/presentation/settings_page.dart';
import 'package:tw_reporter_app/features/topics/presentation/topic_detail_page.dart';
import 'package:tw_reporter_app/features/topics/presentation/topics_page.dart';

part 'app_router.gr.dart';

/// 應用程式路由配置
/// 使用 auto_route 實現型別安全的路由系統
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        // 主要導航 Shell - 包含底部導航列
        AutoRoute(
          page: MainShellRoute.page,
          path: '/',
          initial: true,
          children: <AutoRoute>[
            // 首頁
            AutoRoute(
              page: HomeRoute.page,
              path: '',
            ),

            // 最新文章
            AutoRoute(
              page: LatestRoute.page,
              path: 'latest',
            ),

            // 專題列表
            AutoRoute(
              page: TopicsRoute.page,
              path: 'topics',
            ),

            // 我的閱讀
            AutoRoute(
              page: MyReadingRoute.page,
              path: 'myreading',
            ),
          ],
        ),

        // 文章詳情 - 不在底部導航列中
        AutoRoute(
          page: ArticleRoute.page,
          path: '/a/:slug',
        ),

        // 專題詳情 - 不在底部導航列中
        AutoRoute(
          page: TopicDetailRoute.page,
          path: '/topics/:slug',
        ),

        // 分類頁面 - 不在底部導航列中
        AutoRoute(
          page: CategoryRoute.page,
          path: '/categories/:category',
        ),

        // 設定頁面
        AutoRoute(
          page: SettingsRoute.page,
          path: '/settings',
        ),
      ];
}

