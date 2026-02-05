import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/features/article/presentation/article_page.dart';
import 'package:tw_reporter_app/features/latest/presentation/latest_page.dart';
import 'package:tw_reporter_app/features/category/presentation/category_page.dart';
import 'package:tw_reporter_app/features/topics/presentation/topics_page.dart';
import 'package:tw_reporter_app/features/search/presentation/search_page.dart';
import 'package:tw_reporter_app/features/my_reading/presentation/my_reading_page.dart';

part 'app_router.gr.dart';

/// 應用程式路由配置
/// 使用 auto_route 實現型別安全的路由系統
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        // 首頁 - 設為初始路由
        AutoRoute(
          page: HomeRoute.page,
          path: '/',
          initial: true,
        ),

        // 最新文章
        AutoRoute(
          page: LatestRoute.page,
          path: '/latest',
        ),

        // 文章詳情 - 使用路徑參數
        AutoRoute(
          page: ArticleRoute.page,
          path: '/a/:slug',
        ),

        // 分類頁面 - 使用路徑參數
        AutoRoute(
          page: CategoryRoute.page,
          path: '/categories/:category',
        ),

        // 專題列表
        AutoRoute(
          page: TopicsRoute.page,
          path: '/topics',
        ),

        // 搜尋頁面
        AutoRoute(
          page: SearchRoute.page,
          path: '/search',
        ),

        // 我的閱讀
        AutoRoute(
          page: MyReadingRoute.page,
          path: '/myreading',
        ),
      ];
}
