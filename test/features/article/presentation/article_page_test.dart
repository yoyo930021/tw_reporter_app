import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/features/article/presentation/article_page.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockArticleRepository mockArticleRepo;
  late MockReadingRepository mockReadingRepo;

  setUp(() {
    mockArticleRepo = MockArticleRepository();
    mockReadingRepo = MockReadingRepository();

    when(() => mockReadingRepo.getHistory())
        .thenReturn(<ReadingRecord>[]);
    when(() => mockReadingRepo.getBookmarks())
        .thenReturn(<ReadingRecord>[]);
    when(() => mockReadingRepo.isBookmarked(any()))
        .thenReturn(false);
    when(() => mockReadingRepo.isRead(any()))
        .thenReturn(false);
    when(
      () => mockReadingRepo.addToHistory(
        any(),
        any(),
        any(),
        any(),
      ),
    ).thenReturn(null);
  });

  Widget buildPage({String slug = 'test-article'}) {
    return wrapWithProviders(
      ArticlePage(slug: slug),
      articleRepository: mockArticleRepo,
      readingRepository: mockReadingRepo,
    );
  }

  group('ArticlePage', () {
    testWidgets(
      'should display app bar with title',
      (tester) async {
        when(
          () => mockArticleRepo.fetchById(
            slug: 'test-article',
          ),
        ).thenAnswer(
          (_) async => createTestArticle(),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.byType(SliverAppBar),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display article title and content',
      (tester) async {
        final mockArticle = createTestArticle(
          title: '測試文章標題',
          ogDescription: '這是文章描述',
          content: <String, dynamic>{
            'api_data': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'unstyled',
                'content': <String>['這是文章的內容'],
                'id': '1',
                'styles': <String, dynamic>{},
                'alignment': 'center',
              },
            ],
          },
        );

        when(
          () => mockArticleRepo.fetchById(
            slug: 'test-article',
          ),
        ).thenAnswer((_) async => mockArticle);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.text('測試文章標題'),
          findsAtLeast(1),
        );
        // HtmlWidget renders HTML content. Verify the HtmlWidget
        // is present and contains the expected HTML.
        final htmlWidgets = tester.widgetList<HtmlWidget>(
          find.byType(HtmlWidget),
        );
        expect(htmlWidgets, isNotEmpty);
        expect(
          htmlWidgets.any(
            (w) => w.html.contains('這是文章的內容'),
          ),
          isTrue,
        );
      },
    );

    testWidgets(
      'should display loading indicator when loading',
      (tester) async {
        var requestStarted = false;
        when(
          () => mockArticleRepo.fetchById(
            slug: 'test-article',
          ),
        ).thenAnswer((_) async {
          requestStarted = true;
          await Future<void>.delayed(
            const Duration(milliseconds: 50),
          );
          return createTestArticle();
        });

        await tester.pumpWidget(buildPage());
        await tester.pump();
        await tester.pump(
          const Duration(milliseconds: 10),
        );

        expect(requestStarted, isTrue);
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'should display error message when loading fails',
      (tester) async {
        when(
          () => mockArticleRepo.fetchById(
            slug: 'test-article',
          ),
        ).thenThrow(Exception('Network error'));

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
      'should display retry button on error',
      (tester) async {
        var callCount = 0;

        when(
          () => mockArticleRepo.fetchById(
            slug: 'test-article',
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return createTestArticle();
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
        expect(find.text('測試文章'), findsAtLeast(1));
      },
    );

    testWidgets(
      'should display published date',
      (tester) async {
        final mockArticle = createTestArticle(
          publishedDate: DateTime(2024, 1, 15),
        );

        when(
          () => mockArticleRepo.fetchById(
            slug: 'test-article',
          ),
        ).thenAnswer((_) async => mockArticle);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('2024'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should handle articles without content',
      (tester) async {
        final mockArticle = createTestArticle(
          ogDescription: '這是描述',
        );

        when(
          () => mockArticleRepo.fetchById(
            slug: 'test-article',
          ),
        ).thenAnswer((_) async => mockArticle);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('測試文章'), findsAtLeast(1));
        expect(find.text('這是描述'), findsOneWidget);
      },
    );
  });
}
