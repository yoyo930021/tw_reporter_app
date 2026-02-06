import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';

/// 主要導航 Shell
/// 提供底部導航列整合所有主要功能頁面
@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: [
        HomeRoute(),
        LatestRoute(),
        TopicsRoute(),
        SearchRoute(),
        const MyReadingRoute(),
      ],
      bottomNavigationBuilder: (_, TabsRouter tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首頁',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: '最新',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.topic),
              label: '專題',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '搜尋',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: '我的閱讀',
            ),
          ],
        );
      },
    );
  }
}
