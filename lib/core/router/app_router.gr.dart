// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ArticlePage]
class ArticleRoute extends PageRouteInfo<ArticleRouteArgs> {
  ArticleRoute({Key? key, required String slug, List<PageRouteInfo>? children})
    : super(
        ArticleRoute.name,
        args: ArticleRouteArgs(key: key, slug: slug),
        rawPathParams: {'slug': slug},
        initialChildren: children,
      );

  static const String name = 'ArticleRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ArticleRouteArgs>(
        orElse: () => ArticleRouteArgs(slug: pathParams.getString('slug')),
      );
      return ArticlePage(key: args.key, slug: args.slug);
    },
  );
}

class ArticleRouteArgs {
  const ArticleRouteArgs({this.key, required this.slug});

  final Key? key;

  final String slug;

  @override
  String toString() {
    return 'ArticleRouteArgs{key: $key, slug: $slug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArticleRouteArgs) return false;
    return key == other.key && slug == other.slug;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode;
}

/// generated route for
/// [CategoryPage]
class CategoryRoute extends PageRouteInfo<CategoryRouteArgs> {
  CategoryRoute({
    Key? key,
    required String category,
    List<PageRouteInfo>? children,
  }) : super(
         CategoryRoute.name,
         args: CategoryRouteArgs(key: key, category: category),
         rawPathParams: {'category': category},
         initialChildren: children,
       );

  static const String name = 'CategoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CategoryRouteArgs>(
        orElse: () =>
            CategoryRouteArgs(category: pathParams.getString('category')),
      );
      return CategoryPage(key: args.key, category: args.category);
    },
  );
}

class CategoryRouteArgs {
  const CategoryRouteArgs({this.key, required this.category});

  final Key? key;

  final String category;

  @override
  String toString() {
    return 'CategoryRouteArgs{key: $key, category: $category}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CategoryRouteArgs) return false;
    return key == other.key && category == other.category;
  }

  @override
  int get hashCode => key.hashCode ^ category.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LatestPage]
class LatestRoute extends PageRouteInfo<void> {
  const LatestRoute({List<PageRouteInfo>? children})
    : super(LatestRoute.name, initialChildren: children);

  static const String name = 'LatestRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LatestPage();
    },
  );
}

/// generated route for
/// [MyReadingPage]
class MyReadingRoute extends PageRouteInfo<void> {
  const MyReadingRoute({List<PageRouteInfo>? children})
    : super(MyReadingRoute.name, initialChildren: children);

  static const String name = 'MyReadingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyReadingPage();
    },
  );
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchPage();
    },
  );
}

/// generated route for
/// [TopicsPage]
class TopicsRoute extends PageRouteInfo<void> {
  const TopicsRoute({List<PageRouteInfo>? children})
    : super(TopicsRoute.name, initialChildren: children);

  static const String name = 'TopicsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TopicsPage();
    },
  );
}
