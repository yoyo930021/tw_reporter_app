import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/shared/widgets/horizontal_carousel.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockHomeRepository mockHomeRepo;
  late MockArticleRepository mockArticleRepo;

  setUp(() {
    mockHomeRepo = MockHomeRepository();
    mockArticleRepo = MockArticleRepository();
  });

  Widget buildPage() {
    return wrapWithProviders(
      const HomePage(),
      homeRepository: mockHomeRepo,
      articleRepository: mockArticleRepo,
    );
  }

  /// Mock fetchIndexPage to return [data].
  void mockIndexPage(IndexPageData data) {
    when(() => mockHomeRepo.fetchIndexPage())
        .thenAnswer((_) async => data);
  }

  group('HomePage', () {
    testWidgets(
      'should display app bar with title',
      (tester) async {
        mockIndexPage(const IndexPageData());

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.bySemanticsLabel('報導者'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display page without error when data loads',
      (tester) async {
        mockIndexPage(const IndexPageData());

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      },
    );

    testWidgets(
      'should display editor picks after loading',
      (tester) async {
        final data = IndexPageData(
          editorPicksSection: <Article>[
            createTestArticle(
              slug: 'featured-1',
              title: '精選文章標題',
              ogDescription: '這是精選文章的描述內容',
            ),
          ],
        );
        mockIndexPage(data);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.text('精選文章標題'),
          findsOneWidget,
        );
        expect(
          find.text('這是精選文章的描述內容'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display error message when loading fails',
      (tester) async {
        when(() => mockHomeRepo.fetchIndexPage())
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('發生錯誤'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Network error'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display category sections with carousels',
      (tester) async {
        final data = IndexPageData(
          world: <Article>[
            createTestArticle(
              slug: 'intl-1',
              title: '國際新聞標題',
            ),
          ],
          politicsAndSociety: <Article>[
            createTestArticle(
              id: '2',
              slug: 'politics-1',
              title: '政治新聞標題',
              publishedDate: DateTime(2024, 1, 2),
            ),
          ],
        );
        mockIndexPage(data);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('國際新聞標題'), findsOneWidget);
        expect(
          find.byType(HorizontalCarousel),
          findsAtLeast(1),
        );
      },
    );

    testWidgets(
      'should have RefreshIndicator for pull to refresh',
      (tester) async {
        mockIndexPage(const IndexPageData());

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.byType(RefreshIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display empty state when no articles',
      (tester) async {
        mockIndexPage(const IndexPageData());

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);
      },
    );

    testWidgets(
      'should display retry button on error',
      (tester) async {
        var callCount = 0;

        when(() => mockHomeRepo.fetchIndexPage())
            .thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return const IndexPageData();
        });

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('發生錯誤'),
          findsOneWidget,
        );

        await tester.tap(find.text('重試'));
        await tester.pumpAndSettle();

        expect(callCount, equals(2));
        expect(
          find.textContaining('發生錯誤'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'should display topics section when available',
      (tester) async {
        final data = IndexPageData(
          latestTopicSection: <Topic>[
            createTestTopic(
              id: 't1',
              slug: 'topic-1',
              title: '最新專題標題',
            ),
          ],
          topicsSection: <Topic>[
            createTestTopic(
              id: 't2',
              slug: 'topic-2',
              title: '精選專題標題',
              publishedDate: DateTime(2024, 1, 2),
            ),
          ],
        );
        mockIndexPage(data);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('最新專題'), findsOneWidget);
      },
    );

    testWidgets(
      'should display reviews section when available',
      (tester) async {
        final data = IndexPageData(
          reviewsSection: <Article>[
            createTestArticle(
              slug: 'review-1',
              title: '評論文章標題',
              ogDescription: '評論描述',
            ),
          ],
        );
        mockIndexPage(data);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('評論'), findsOneWidget);
      },
    );

    testWidgets(
      'should display photos section when available',
      (tester) async {
        final data = IndexPageData(
          photosSection: <Article>[
            createTestArticle(
              slug: 'photo-1',
              title: '攝影文章標題',
              ogDescription: '攝影描述',
            ),
          ],
        );
        mockIndexPage(data);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('攝影'), findsOneWidget);
      },
    );

    testWidgets(
      'should display infographics section',
      (tester) async {
        final data = IndexPageData(
          infographicsSection: <Article>[
            createTestArticle(
              slug: 'infographic-1',
              title: '多媒體文章標題',
              ogDescription: '多媒體描述',
            ),
          ],
        );
        mockIndexPage(data);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('多媒體'), findsOneWidget);
      },
    );
  });
}
