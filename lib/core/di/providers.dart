import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/injection_keys.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';
import 'package:tw_reporter_app/core/repositories/home_repository.dart';
import 'package:tw_reporter_app/core/repositories/reading_repository.dart';
import 'package:tw_reporter_app/core/repositories/topic_repository.dart';
import 'package:tw_reporter_app/core/settings/media_load_mode.dart';

void provideArticleRepository(ArticleRepository repo) {
  provide(AppKeys.articleRepository, repo);
}

void provideTopicRepository(TopicRepository repo) {
  provide(AppKeys.topicRepository, repo);
}

void provideHomeRepository(HomeRepository repo) {
  provide(AppKeys.homeRepository, repo);
}

void provideReadingRepository(ReadingRepository repo) {
  provide(AppKeys.readingRepository, repo);
}

void provideThemeMode(Ref<ThemeMode> themeModeRef) {
  provide(AppKeys.themeMode, themeModeRef);
}

void provideMediaLoadMode(Ref<MediaLoadMode> mediaLoadModeRef) {
  provide(AppKeys.mediaLoadMode, mediaLoadModeRef);
}
