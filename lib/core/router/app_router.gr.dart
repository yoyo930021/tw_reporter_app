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
  ArticleRoute({
    TwReporterApi? api,
    ReadingStorage? storage,
    Key? key,
    required String slug,
    String? heroImageUrl,
    List<PageRouteInfo>? children,
  }) : super(
         ArticleRoute.name,
         args: ArticleRouteArgs(
           api: api,
           storage: storage,
           key: key,
           slug: slug,
           heroImageUrl: heroImageUrl,
         ),
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
      return ArticlePage(
        api: args.api,
        storage: args.storage,
        key: args.key,
        slug: args.slug,
        heroImageUrl: args.heroImageUrl,
      );
    },
  );
}

class ArticleRouteArgs {
  const ArticleRouteArgs({
    this.api,
    this.storage,
    this.key,
    required this.slug,
    this.heroImageUrl,
  });

  final TwReporterApi? api;

  final ReadingStorage? storage;

  final Key? key;

  final String slug;

  final String? heroImageUrl;

  @override
  String toString() {
    return 'ArticleRouteArgs{api: $api, storage: $storage, key: $key, slug: $slug, heroImageUrl: $heroImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArticleRouteArgs) return false;
    return api == other.api &&
        storage == other.storage &&
        key == other.key &&
        slug == other.slug &&
        heroImageUrl == other.heroImageUrl;
  }

  @override
  int get hashCode =>
      api.hashCode ^
      storage.hashCode ^
      key.hashCode ^
      slug.hashCode ^
      heroImageUrl.hashCode;
}

/// generated route for
/// [CategoryPage]
class CategoryRoute extends PageRouteInfo<CategoryRouteArgs> {
  CategoryRoute({
    TwReporterApi? api,
    Key? key,
    required String category,
    List<PageRouteInfo>? children,
  }) : super(
         CategoryRoute.name,
         args: CategoryRouteArgs(api: api, key: key, category: category),
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
      return CategoryPage(
        api: args.api,
        key: args.key,
        category: args.category,
      );
    },
  );
}

class CategoryRouteArgs {
  const CategoryRouteArgs({this.api, this.key, required this.category});

  final TwReporterApi? api;

  final Key? key;

  final String category;

  @override
  String toString() {
    return 'CategoryRouteArgs{api: $api, key: $key, category: $category}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CategoryRouteArgs) return false;
    return api == other.api && key == other.key && category == other.category;
  }

  @override
  int get hashCode => api.hashCode ^ key.hashCode ^ category.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<HomeRouteArgs> {
  HomeRoute({TwReporterApi? api, Key? key, List<PageRouteInfo>? children})
    : super(
        HomeRoute.name,
        args: HomeRouteArgs(api: api, key: key),
        initialChildren: children,
      );

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HomeRouteArgs>(
        orElse: () => const HomeRouteArgs(),
      );
      return HomePage(api: args.api, key: args.key);
    },
  );
}

class HomeRouteArgs {
  const HomeRouteArgs({this.api, this.key});

  final TwReporterApi? api;

  final Key? key;

  @override
  String toString() {
    return 'HomeRouteArgs{api: $api, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HomeRouteArgs) return false;
    return api == other.api && key == other.key;
  }

  @override
  int get hashCode => api.hashCode ^ key.hashCode;
}

/// generated route for
/// [LatestPage]
class LatestRoute extends PageRouteInfo<LatestRouteArgs> {
  LatestRoute({TwReporterApi? api, Key? key, List<PageRouteInfo>? children})
    : super(
        LatestRoute.name,
        args: LatestRouteArgs(api: api, key: key),
        initialChildren: children,
      );

  static const String name = 'LatestRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LatestRouteArgs>(
        orElse: () => const LatestRouteArgs(),
      );
      return LatestPage(api: args.api, key: args.key);
    },
  );
}

class LatestRouteArgs {
  const LatestRouteArgs({this.api, this.key});

  final TwReporterApi? api;

  final Key? key;

  @override
  String toString() {
    return 'LatestRouteArgs{api: $api, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LatestRouteArgs) return false;
    return api == other.api && key == other.key;
  }

  @override
  int get hashCode => api.hashCode ^ key.hashCode;
}

/// generated route for
/// [MainShellPage]
class MainShellRoute extends PageRouteInfo<void> {
  const MainShellRoute({List<PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainShellPage();
    },
  );
}

/// generated route for
/// [MyReadingPage]
class MyReadingRoute extends PageRouteInfo<MyReadingRouteArgs> {
  MyReadingRoute({
    ReadingStorage? storage,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         MyReadingRoute.name,
         args: MyReadingRouteArgs(storage: storage, key: key),
         initialChildren: children,
       );

  static const String name = 'MyReadingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MyReadingRouteArgs>(
        orElse: () => const MyReadingRouteArgs(),
      );
      return MyReadingPage(storage: args.storage, key: args.key);
    },
  );
}

class MyReadingRouteArgs {
  const MyReadingRouteArgs({this.storage, this.key});

  final ReadingStorage? storage;

  final Key? key;

  @override
  String toString() {
    return 'MyReadingRouteArgs{storage: $storage, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MyReadingRouteArgs) return false;
    return storage == other.storage && key == other.key;
  }

  @override
  int get hashCode => storage.hashCode ^ key.hashCode;
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<SearchRouteArgs> {
  SearchRoute({TwReporterApi? api, Key? key, List<PageRouteInfo>? children})
    : super(
        SearchRoute.name,
        args: SearchRouteArgs(api: api, key: key),
        initialChildren: children,
      );

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchRouteArgs>(
        orElse: () => const SearchRouteArgs(),
      );
      return SearchPage(api: args.api, key: args.key);
    },
  );
}

class SearchRouteArgs {
  const SearchRouteArgs({this.api, this.key});

  final TwReporterApi? api;

  final Key? key;

  @override
  String toString() {
    return 'SearchRouteArgs{api: $api, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SearchRouteArgs) return false;
    return api == other.api && key == other.key;
  }

  @override
  int get hashCode => api.hashCode ^ key.hashCode;
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<SettingsRouteArgs> {
  SettingsRoute({
    required ThemeNotifier themeNotifier,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         SettingsRoute.name,
         args: SettingsRouteArgs(themeNotifier: themeNotifier, key: key),
         initialChildren: children,
       );

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SettingsRouteArgs>();
      return SettingsPage(themeNotifier: args.themeNotifier, key: args.key);
    },
  );
}

class SettingsRouteArgs {
  const SettingsRouteArgs({required this.themeNotifier, this.key});

  final ThemeNotifier themeNotifier;

  final Key? key;

  @override
  String toString() {
    return 'SettingsRouteArgs{themeNotifier: $themeNotifier, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SettingsRouteArgs) return false;
    return themeNotifier == other.themeNotifier && key == other.key;
  }

  @override
  int get hashCode => themeNotifier.hashCode ^ key.hashCode;
}

/// generated route for
/// [TopicDetailPage]
class TopicDetailRoute extends PageRouteInfo<TopicDetailRouteArgs> {
  TopicDetailRoute({
    TwReporterApi? api,
    required String slug,
    Topic? topic,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         TopicDetailRoute.name,
         args: TopicDetailRouteArgs(
           api: api,
           slug: slug,
           topic: topic,
           key: key,
         ),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'TopicDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TopicDetailRouteArgs>(
        orElse: () => TopicDetailRouteArgs(slug: pathParams.getString('slug')),
      );
      return TopicDetailPage(
        api: args.api,
        slug: args.slug,
        topic: args.topic,
        key: args.key,
      );
    },
  );
}

class TopicDetailRouteArgs {
  const TopicDetailRouteArgs({
    this.api,
    required this.slug,
    this.topic,
    this.key,
  });

  final TwReporterApi? api;

  final String slug;

  final Topic? topic;

  final Key? key;

  @override
  String toString() {
    return 'TopicDetailRouteArgs{api: $api, slug: $slug, topic: $topic, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TopicDetailRouteArgs) return false;
    return api == other.api &&
        slug == other.slug &&
        topic == other.topic &&
        key == other.key;
  }

  @override
  int get hashCode =>
      api.hashCode ^ slug.hashCode ^ topic.hashCode ^ key.hashCode;
}

/// generated route for
/// [TopicsPage]
class TopicsRoute extends PageRouteInfo<TopicsRouteArgs> {
  TopicsRoute({TwReporterApi? api, Key? key, List<PageRouteInfo>? children})
    : super(
        TopicsRoute.name,
        args: TopicsRouteArgs(api: api, key: key),
        initialChildren: children,
      );

  static const String name = 'TopicsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TopicsRouteArgs>(
        orElse: () => const TopicsRouteArgs(),
      );
      return TopicsPage(api: args.api, key: args.key);
    },
  );
}

class TopicsRouteArgs {
  const TopicsRouteArgs({this.api, this.key});

  final TwReporterApi? api;

  final Key? key;

  @override
  String toString() {
    return 'TopicsRouteArgs{api: $api, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TopicsRouteArgs) return false;
    return api == other.api && key == other.key;
  }

  @override
  int get hashCode => api.hashCode ^ key.hashCode;
}
