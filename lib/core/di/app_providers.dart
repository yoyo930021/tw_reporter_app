import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/injection_keys.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';
import 'package:tw_reporter_app/core/repositories/home_repository.dart';
import 'package:tw_reporter_app/core/repositories/reading_repository.dart';
import 'package:tw_reporter_app/core/repositories/topic_repository.dart';
import 'package:tw_reporter_app/core/theme/theme_notifier.dart';

/// 應用程式 DI Provider
///
/// 在 Widget tree 頂層提供所有 Repository 實例，
/// 子組件可透過 `inject(AppKeys.xxx)` 取得。
class AppProviders extends CompositionWidget {
  const AppProviders({
    required this.articleRepository,
    required this.topicRepository,
    required this.homeRepository,
    required this.readingRepository,
    required this.themeNotifier,
    required this.child,
    super.key,
  });

  final ArticleRepository articleRepository;
  final TopicRepository topicRepository;
  final HomeRepository homeRepository;
  final ReadingRepository readingRepository;
  final ThemeNotifier themeNotifier;
  final Widget child;

  @override
  Widget Function(BuildContext) setup() {
    provide(AppKeys.articleRepository, articleRepository);
    provide(AppKeys.topicRepository, topicRepository);
    provide(AppKeys.homeRepository, homeRepository);
    provide(
      AppKeys.readingRepository,
      readingRepository,
    );
    provide(AppKeys.themeNotifier, themeNotifier);

    return (context) => child;
  }
}
