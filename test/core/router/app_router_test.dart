import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';

void main() {
  late AppRouter router;

  setUp(() {
    router = AppRouter();
  });

  group('AppRouter', () {
    test('should have routes configured', () {
      // Assert
      expect(router.routes, isNotEmpty);
      // 現在有 3 個頂層路由: MainShellRoute, ArticleRoute, CategoryRoute
      expect(router.routes, hasLength(3));
    });

    test('should have MainShellRoute as initial route', () {
      // Act
      final List<AutoRoute> routes = router.routes;
      final AutoRoute initialRoute = routes.firstWhere(
        (AutoRoute route) => route.initial == true,
      );

      // Assert
      expect(initialRoute.page.name, equals('MainShellRoute'));
    });

    test('should have child routes in MainShellRoute', () {
      // Act
      final List<AutoRoute> routes = router.routes;
      final AutoRoute mainShellRoute = routes.firstWhere(
        (AutoRoute route) => route.page.name == 'MainShellRoute',
      );

      // Assert
      expect(mainShellRoute.children, isNotNull);
      expect(mainShellRoute.children, hasLength(5));
    });

    test('should generate type-safe route for HomePage', () {
      // Act
      final PageRouteInfo<dynamic> route = HomeRoute();

      // Assert
      expect(route.routeName, equals('HomeRoute'));
      expect(HomeRoute.name, equals('HomeRoute'));
    });

    test('should generate type-safe route for LatestPage', () {
      // Act
      final PageRouteInfo<dynamic> route = LatestRoute();

      // Assert
      expect(route.routeName, equals('LatestRoute'));
      expect(LatestRoute.name, equals('LatestRoute'));
    });

    test('should generate type-safe route for ArticlePage with slug', () {
      // Act
      final PageRouteInfo<dynamic> route = ArticleRoute(slug: 'test-article');

      // Assert
      expect(route.routeName, equals('ArticleRoute'));
      expect(ArticleRoute.name, equals('ArticleRoute'));
      // 檢查路徑參數是否正確設定
      expect(route.rawPathParams, containsPair('slug', 'test-article'));
    });

    test('should generate type-safe route for CategoryPage', () {
      // Act
      final PageRouteInfo<dynamic> route = CategoryRoute(category: '國際');

      // Assert
      expect(route.routeName, equals('CategoryRoute'));
      expect(CategoryRoute.name, equals('CategoryRoute'));
      // 檢查路徑參數是否正確設定
      expect(route.rawPathParams, containsPair('category', '國際'));
    });

    test('should generate type-safe route for TopicsPage', () {
      // Act
      final PageRouteInfo<dynamic> route = TopicsRoute();

      // Assert
      expect(route.routeName, equals('TopicsRoute'));
      expect(TopicsRoute.name, equals('TopicsRoute'));
    });

    test('should generate type-safe route for SearchPage', () {
      // Act
      final PageRouteInfo<dynamic> route = SearchRoute();

      // Assert
      expect(route.routeName, equals('SearchRoute'));
      expect(SearchRoute.name, equals('SearchRoute'));
    });

    test('should generate type-safe route for MyReadingPage', () {
      // Act
      const PageRouteInfo<dynamic> route = MyReadingRoute();

      // Assert
      expect(route.routeName, equals('MyReadingRoute'));
      expect(MyReadingRoute.name, equals('MyReadingRoute'));
    });

    test('should handle ArticleRoute path parameters correctly', () {
      // Arrange
      const String testSlug = 'taiwan-reporter-investigation';

      // Act
      final PageRouteInfo<dynamic> route = ArticleRoute(slug: testSlug);

      // Assert
      expect(route.rawPathParams, containsPair('slug', testSlug));
    });

    test('should handle CategoryRoute path parameters correctly', () {
      // Arrange
      const String testCategory = 'international';

      // Act
      final PageRouteInfo<dynamic> route =
          CategoryRoute(category: testCategory);

      // Assert
      expect(route.rawPathParams, containsPair('category', testCategory));
    });

    test('should have correct route paths configured', () {
      // Arrange
      final List<AutoRoute> routes = router.routes;

      // Act & Assert - 檢查頂層路由
      final AutoRoute mainShellRoute = routes.firstWhere(
        (AutoRoute route) => route.page.name == 'MainShellRoute',
      );
      expect(mainShellRoute.path, equals('/'));

      final AutoRoute articleRoute = routes.firstWhere(
        (AutoRoute route) => route.page.name == 'ArticleRoute',
      );
      expect(articleRoute.path, equals('/a/:slug'));

      final AutoRoute categoryRoute = routes.firstWhere(
        (AutoRoute route) => route.page.name == 'CategoryRoute',
      );
      expect(categoryRoute.path, equals('/categories/:category'));

      // 檢查 MainShellRoute 的子路由
      final List<AutoRoute>? childRoutes = mainShellRoute.children;
      expect(childRoutes, isNotNull);

      final AutoRoute homeRoute = childRoutes!.firstWhere(
        (AutoRoute route) => route.page.name == 'HomeRoute',
      );
      expect(homeRoute.path, equals(''));

      final AutoRoute latestRoute = childRoutes.firstWhere(
        (AutoRoute route) => route.page.name == 'LatestRoute',
      );
      expect(latestRoute.path, equals('latest'));

      final AutoRoute topicsRoute = childRoutes.firstWhere(
        (AutoRoute route) => route.page.name == 'TopicsRoute',
      );
      expect(topicsRoute.path, equals('topics'));

      final AutoRoute searchRoute = childRoutes.firstWhere(
        (AutoRoute route) => route.page.name == 'SearchRoute',
      );
      expect(searchRoute.path, equals('search'));

      final AutoRoute myReadingRoute = childRoutes.firstWhere(
        (AutoRoute route) => route.page.name == 'MyReadingRoute',
      );
      expect(myReadingRoute.path, equals('myreading'));
    });
  });
}
