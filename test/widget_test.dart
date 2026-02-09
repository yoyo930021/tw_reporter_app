import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/cache/video_cache_service.dart';
import 'package:tw_reporter_app/core/di/app_providers.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/core/theme/theme_notifier.dart';

import 'helpers/test_helpers.dart';

void main() {
  late MockArticleRepository mockArticleRepo;
  late MockTopicRepository mockTopicRepo;
  late MockHomeRepository mockHomeRepo;
  late MockReadingRepository mockReadingRepo;

  setUp(() {
    mockArticleRepo = MockArticleRepository();
    mockTopicRepo = MockTopicRepository();
    mockHomeRepo = MockHomeRepository();
    mockReadingRepo = MockReadingRepository();

    when(() => mockHomeRepo.fetchIndexPage()).thenAnswer(
      (_) async => const IndexPageData(
        latestSection: <Article>[],
        editorPicksSection: <Article>[],
        topicsSection: <Topic>[],
        reviewsSection: <Article>[],
        photosSection: <Article>[],
        infographicsSection: <Article>[],
      ),
    );
    when(
      () => mockArticleRepo.fetchLatest(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => <Article>[]);
    when(
      () => mockTopicRepo.fetchTopics(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => <Topic>[]);
    when(() => mockReadingRepo.getHistory()).thenReturn([]);
    when(() => mockReadingRepo.getBookmarks()).thenReturn([]);
  });

  testWidgets(
    'App should start successfully',
    (tester) async {
      final router = AppRouter();
      await tester.pumpWidget(
        AppProviders(
          articleRepository: mockArticleRepo,
          topicRepository: mockTopicRepo,
          homeRepository: mockHomeRepo,
          readingRepository: mockReadingRepo,
          themeNotifier: ThemeNotifier(),
          videoCacheService: VideoCacheService(Dio()),
          child: MaterialApp.router(
            title: '報導者',
            theme: AppTheme.lightTheme,
            routerConfig: router.config(),
          ),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    },
  );

  testWidgets(
    'Bottom navigation should have 5 items',
    (tester) async {
      final router = AppRouter();
      await tester.pumpWidget(
        AppProviders(
          articleRepository: mockArticleRepo,
          topicRepository: mockTopicRepo,
          homeRepository: mockHomeRepo,
          readingRepository: mockReadingRepo,
          themeNotifier: ThemeNotifier(),
          videoCacheService: VideoCacheService(Dio()),
          child: MaterialApp.router(
            title: '報導者',
            theme: AppTheme.lightTheme,
            routerConfig: router.config(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bottomNavBar =
          find.byType(BottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);

      expect(find.text('首頁'), findsOneWidget);
      expect(find.text('最新'), findsOneWidget);
      expect(find.text('專題'), findsOneWidget);
      expect(find.text('我的閱讀'), findsOneWidget);
      expect(find.text('選單'), findsOneWidget);
    },
  );
}
