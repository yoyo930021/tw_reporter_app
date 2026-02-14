import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/di/providers.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';
import 'package:tw_reporter_app/core/repositories/home_repository.dart';
import 'package:tw_reporter_app/core/repositories/reading_repository.dart';
import 'package:tw_reporter_app/core/repositories/topic_repository.dart';
import 'package:tw_reporter_app/core/settings/media_load_mode.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';

// Mock repositories
class MockArticleRepository extends Mock
    implements ArticleRepository {}

class MockTopicRepository extends Mock
    implements TopicRepository {}

class MockHomeRepository extends Mock implements HomeRepository {}

class MockReadingRepository extends Mock implements ReadingRepository {
  final ChangeNotifier _notifier = ChangeNotifier();

  @override
  void addListener(VoidCallback listener) =>
      _notifier.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _notifier.removeListener(listener);

  @override
  void dispose() => _notifier.dispose();

  @override
  bool get hasListeners => _notifier.hasListeners;
}

// Composition test helper
class TestWidget extends CompositionWidget {
  const TestWidget({
    required this.setupFn,
    super.key,
  });

  final Widget Function(BuildContext) Function() setupFn;

  @override
  Widget Function(BuildContext) setup() => setupFn();
}

/// Wraps a widget with DI providers for testing
Widget wrapWithProviders(
  Widget child, {
  ArticleRepository? articleRepository,
  TopicRepository? topicRepository,
  HomeRepository? homeRepository,
  ReadingRepository? readingRepository,
  Ref<ThemeMode>? themeMode,
  Ref<MediaLoadMode>? mediaLoadMode,
}) {
  return MaterialApp(
    home: _TestProviders(
      articleRepository:
          articleRepository ?? MockArticleRepository(),
      topicRepository:
          topicRepository ?? MockTopicRepository(),
      homeRepository: homeRepository ?? MockHomeRepository(),
      readingRepository:
          readingRepository ?? MockReadingRepository(),
      themeMode: themeMode,
      mediaLoadMode: mediaLoadMode,
      child: child,
    ),
  );
}

class _TestProviders extends CompositionWidget {
  const _TestProviders({
    required this.articleRepository,
    required this.topicRepository,
    required this.homeRepository,
    required this.readingRepository,
    required this.child,
    this.themeMode,
    this.mediaLoadMode,
  });

  final ArticleRepository articleRepository;
  final TopicRepository topicRepository;
  final HomeRepository homeRepository;
  final ReadingRepository readingRepository;
  final Ref<ThemeMode>? themeMode;
  final Ref<MediaLoadMode>? mediaLoadMode;
  final Widget child;

  @override
  Widget Function(BuildContext) setup() {
    provideArticleRepository(articleRepository);
    provideTopicRepository(topicRepository);
    provideHomeRepository(homeRepository);
    provideReadingRepository(readingRepository);
    provideThemeMode(themeMode ?? ref(ThemeMode.system));
    provideMediaLoadMode(
      mediaLoadMode ?? ref(MediaLoadMode.normal),
    );

    return (context) => child;
  }
}

/// Create a test article with minimal required fields
Article createTestArticle({
  String id = '1',
  String slug = 'test-article',
  String title = '測試文章',
  String ogDescription = '測試描述',
  List<CategorySet>? categorySet,
  DateTime? publishedDate,
  bool isExternal = false,
  Map<String, dynamic>? content,
  List<String>? relateds,
}) {
  return Article(
    id: id,
    slug: slug,
    title: title,
    ogDescription: ogDescription,
    categorySet: categorySet ?? <CategorySet>[],
    publishedDate: publishedDate ?? DateTime(2024),
    isExternal: isExternal,
    content: content,
    relateds: relateds,
  );
}

/// Create a test topic with minimal required fields
Topic createTestTopic({
  String id = '1',
  String slug = 'test-topic',
  String title = '測試專題',
  String? ogDescription,
  List<String>? relateds,
  DateTime? publishedDate,
}) {
  return Topic(
    id: id,
    slug: slug,
    title: title,
    publishedDate: publishedDate ?? DateTime(2024),
    ogDescription: ogDescription,
    relateds: relateds,
  );
}

/// Create a test reading record
ReadingRecord createTestReadingRecord({
  String slug = 'test-article',
  String title = '測試文章',
  String? imageUrl,
  DateTime? timestamp,
}) {
  return ReadingRecord(
    slug: slug,
    title: title,
    imageUrl: imageUrl,
    timestamp: timestamp ?? DateTime(2024),
  );
}
