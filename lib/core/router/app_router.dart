import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/article/presentation/article_page.dart';
import 'package:tw_reporter_app/features/author/presentation/author_detail_page.dart';
import 'package:tw_reporter_app/features/category/presentation/category_page.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/features/latest/presentation/latest_page.dart';
import 'package:tw_reporter_app/features/main/presentation/main_shell.dart';
import 'package:tw_reporter_app/features/menu/presentation/menu_page.dart';
import 'package:tw_reporter_app/features/my_reading/presentation/my_reading_page.dart';
import 'package:tw_reporter_app/features/search/presentation/search_page.dart';
import 'package:tw_reporter_app/features/settings/presentation/settings_page.dart';
import 'package:tw_reporter_app/features/tag/presentation/tag_detail_page.dart';
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
            AutoRoute(
              page: HomeRoute.page,
              path: '',
            ),
            AutoRoute(
              page: LatestRoute.page,
              path: 'latest',
            ),
            AutoRoute(
              page: TopicsRoute.page,
              path: 'topics',
            ),
            AutoRoute(
              page: MyReadingRoute.page,
              path: 'myreading',
            ),
            AutoRoute(
              page: MenuRoute.page,
              path: 'menu',
            ),
          ],
        ),

        // 文章詳情
        AutoRoute(
          page: ArticleRoute.page,
          path: '/a/:slug',
        ),

        // 專題詳情
        AutoRoute(
          page: TopicDetailRoute.page,
          path: '/topics/:slug',
        ),

        // 分類頁面
        AutoRoute(
          page: CategoryRoute.page,
          path: '/categories/:category',
        ),

        // 標籤詳情
        AutoRoute(
          page: TagDetailRoute.page,
          path: '/tags/:id',
        ),

        // 作者詳情
        AutoRoute(
          page: AuthorDetailRoute.page,
          path: '/authors/:id',
        ),

        // 設定頁面
        AutoRoute(
          page: SettingsRoute.page,
          path: '/settings',
        ),
      ];
}
