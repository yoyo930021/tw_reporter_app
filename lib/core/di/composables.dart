import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/injection_keys.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';
import 'package:tw_reporter_app/core/repositories/home_repository.dart';
import 'package:tw_reporter_app/core/repositories/reading_repository.dart';
import 'package:tw_reporter_app/core/repositories/topic_repository.dart';
import 'package:tw_reporter_app/core/settings/media_load_mode.dart';

ArticleRepository useArticleRepository() =>
    inject(AppKeys.articleRepository);

TopicRepository useTopicRepository() =>
    inject(AppKeys.topicRepository);

HomeRepository useHomeRepository() =>
    inject(AppKeys.homeRepository);

ReadingRepository useReadingRepository() =>
    inject(AppKeys.readingRepository);

Ref<ThemeMode> useThemeMode() =>
    inject(AppKeys.themeMode);

Ref<MediaLoadMode> useMediaLoadMode() =>
    inject(AppKeys.mediaLoadMode);
