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
    required String slug,
    Key? key,
    String? heroImageUrl,
    List<PageRouteInfo>? children,
  }) : super(
         ArticleRoute.name,
         args: ArticleRouteArgs(
           slug: slug,
           key: key,
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
        slug: args.slug,
        key: args.key,
        heroImageUrl: args.heroImageUrl,
      );
    },
  );
}

class ArticleRouteArgs {
  const ArticleRouteArgs({required this.slug, this.key, this.heroImageUrl});

  final String slug;

  final Key? key;

  final String? heroImageUrl;

  @override
  String toString() {
    return 'ArticleRouteArgs{slug: $slug, key: $key, heroImageUrl: $heroImageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArticleRouteArgs) return false;
    return slug == other.slug &&
        key == other.key &&
        heroImageUrl == other.heroImageUrl;
  }

  @override
  int get hashCode => slug.hashCode ^ key.hashCode ^ heroImageUrl.hashCode;
}

/// generated route for
/// [AuthorDetailPage]
class AuthorDetailRoute extends PageRouteInfo<AuthorDetailRouteArgs> {
  AuthorDetailRoute({
    required String authorId,
    required String authorName,
    Key? key,
    String? authorJobTitle,
    String? authorBio,
    String? authorThumbnailUrl,
    List<PageRouteInfo>? children,
  }) : super(
         AuthorDetailRoute.name,
         args: AuthorDetailRouteArgs(
           authorId: authorId,
           authorName: authorName,
           key: key,
           authorJobTitle: authorJobTitle,
           authorBio: authorBio,
           authorThumbnailUrl: authorThumbnailUrl,
         ),
         rawPathParams: {'id': authorId},
         initialChildren: children,
       );

  static const String name = 'AuthorDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AuthorDetailRouteArgs>();
      return AuthorDetailPage(
        authorId: args.authorId,
        authorName: args.authorName,
        key: args.key,
        authorJobTitle: args.authorJobTitle,
        authorBio: args.authorBio,
        authorThumbnailUrl: args.authorThumbnailUrl,
      );
    },
  );
}

class AuthorDetailRouteArgs {
  const AuthorDetailRouteArgs({
    required this.authorId,
    required this.authorName,
    this.key,
    this.authorJobTitle,
    this.authorBio,
    this.authorThumbnailUrl,
  });

  final String authorId;

  final String authorName;

  final Key? key;

  final String? authorJobTitle;

  final String? authorBio;

  final String? authorThumbnailUrl;

  @override
  String toString() {
    return 'AuthorDetailRouteArgs{authorId: $authorId, authorName: $authorName, key: $key, authorJobTitle: $authorJobTitle, authorBio: $authorBio, authorThumbnailUrl: $authorThumbnailUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AuthorDetailRouteArgs) return false;
    return authorId == other.authorId &&
        authorName == other.authorName &&
        key == other.key &&
        authorJobTitle == other.authorJobTitle &&
        authorBio == other.authorBio &&
        authorThumbnailUrl == other.authorThumbnailUrl;
  }

  @override
  int get hashCode =>
      authorId.hashCode ^
      authorName.hashCode ^
      key.hashCode ^
      authorJobTitle.hashCode ^
      authorBio.hashCode ^
      authorThumbnailUrl.hashCode;
}

/// generated route for
/// [CategoryPage]
class CategoryRoute extends PageRouteInfo<CategoryRouteArgs> {
  CategoryRoute({
    required String category,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         CategoryRoute.name,
         args: CategoryRouteArgs(category: category, key: key),
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
      return CategoryPage(category: args.category, key: args.key);
    },
  );
}

class CategoryRouteArgs {
  const CategoryRouteArgs({required this.category, this.key});

  final String category;

  final Key? key;

  @override
  String toString() {
    return 'CategoryRouteArgs{category: $category, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CategoryRouteArgs) return false;
    return category == other.category && key == other.key;
  }

  @override
  int get hashCode => category.hashCode ^ key.hashCode;
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
/// [MenuPage]
class MenuRoute extends PageRouteInfo<void> {
  const MenuRoute({List<PageRouteInfo>? children})
    : super(MenuRoute.name, initialChildren: children);

  static const String name = 'MenuRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MenuPage();
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
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [TagDetailPage]
class TagDetailRoute extends PageRouteInfo<TagDetailRouteArgs> {
  TagDetailRoute({
    required String tagId,
    required String tagName,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         TagDetailRoute.name,
         args: TagDetailRouteArgs(tagId: tagId, tagName: tagName, key: key),
         rawPathParams: {'id': tagId},
         initialChildren: children,
       );

  static const String name = 'TagDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TagDetailRouteArgs>();
      return TagDetailPage(
        tagId: args.tagId,
        tagName: args.tagName,
        key: args.key,
      );
    },
  );
}

class TagDetailRouteArgs {
  const TagDetailRouteArgs({
    required this.tagId,
    required this.tagName,
    this.key,
  });

  final String tagId;

  final String tagName;

  final Key? key;

  @override
  String toString() {
    return 'TagDetailRouteArgs{tagId: $tagId, tagName: $tagName, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TagDetailRouteArgs) return false;
    return tagId == other.tagId && tagName == other.tagName && key == other.key;
  }

  @override
  int get hashCode => tagId.hashCode ^ tagName.hashCode ^ key.hashCode;
}

/// generated route for
/// [TopicDetailPage]
class TopicDetailRoute extends PageRouteInfo<TopicDetailRouteArgs> {
  TopicDetailRoute({
    required String slug,
    Topic? topic,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         TopicDetailRoute.name,
         args: TopicDetailRouteArgs(slug: slug, topic: topic, key: key),
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
      return TopicDetailPage(slug: args.slug, topic: args.topic, key: args.key);
    },
  );
}

class TopicDetailRouteArgs {
  const TopicDetailRouteArgs({required this.slug, this.topic, this.key});

  final String slug;

  final Topic? topic;

  final Key? key;

  @override
  String toString() {
    return 'TopicDetailRouteArgs{slug: $slug, topic: $topic, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TopicDetailRouteArgs) return false;
    return slug == other.slug && topic == other.topic && key == other.key;
  }

  @override
  int get hashCode => slug.hashCode ^ topic.hashCode ^ key.hashCode;
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

/// generated route for
/// [WelcomePage]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomePage();
    },
  );
}
