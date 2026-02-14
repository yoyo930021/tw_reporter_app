import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';
import 'package:tw_reporter_app/core/repositories/home_repository.dart';
import 'package:tw_reporter_app/core/repositories/reading_repository.dart';
import 'package:tw_reporter_app/core/repositories/topic_repository.dart';
import 'package:tw_reporter_app/core/settings/media_load_mode.dart';

/// DI Injection Keys
///
/// 集中定義所有 Repository 的 InjectionKey，
/// 供 provide/inject 使用
class AppKeys {
  static const articleRepository =
      InjectionKey<ArticleRepository>(
    'app.articleRepository',
  );

  static const topicRepository =
      InjectionKey<TopicRepository>(
    'app.topicRepository',
  );

  static const homeRepository = InjectionKey<HomeRepository>(
    'app.homeRepository',
  );

  static const readingRepository =
      InjectionKey<ReadingRepository>(
    'app.readingRepository',
  );

  static const themeMode =
      InjectionKey<Ref<ThemeMode>>(
    'app.themeMode',
  );

  static const mediaLoadMode =
      InjectionKey<Ref<MediaLoadMode>>(
    'app.mediaLoadMode',
  );
}
