import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/latest/presentation/latest_page.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockArticleRepository mockRepo;

  setUp(() {
    mockRepo = MockArticleRepository();
  });

  Widget buildPage() {
    return wrapWithProviders(
      const LatestPage(),
      articleRepository: mockRepo,
    );
  }

  /// Generate a list of test articles.
  List<Article> generateArticles(
    int count, {
    DateTime? publishedDate,
  }) {
    return List<Article>.generate(
      count,
      (i) => Article(
        id: '$i',
        slug: 'article-$i',
        title: '測試文章 $i',
        ogDescription: '描述 $i',
        categorySet: <CategorySet>[],
        publishedDate:
            publishedDate ?? DateTime(2024, 1, 1 + i),
        isExternal: false,
      ),
    );
  }

  group('LatestPage', () {
    testWidgets(
      'should display app bar with title',
      (tester) async {
        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => <Article>[],
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('最新文章'), findsOneWidget);
      },
    );

    testWidgets(
      'should display list of articles after loading',
      (tester) async {
        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => generateArticles(5),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('測試文章 0'), findsOneWidget);
        expect(find.text('測試文章 4'), findsOneWidget);
      },
    );

    testWidgets(
      'should display loading indicator on initial load',
      (tester) async {
        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          await Future<void>.delayed(
            const Duration(milliseconds: 50),
          );
          return <Article>[];
        });

        await tester.pumpWidget(buildPage());
        await tester.pump();
        await tester.pump(
          const Duration(milliseconds: 10),
        );

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'should display empty state when no articles',
      (tester) async {
        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => <Article>[],
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.text('目前沒有文章'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should have RefreshIndicator for pull to refresh',
      (tester) async {
        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => generateArticles(3),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.byType(RefreshIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should call repo on initial load',
      (tester) async {
        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => generateArticles(10),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        verify(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).called(greaterThanOrEqualTo(1));
        expect(find.text('測試文章 0'), findsOneWidget);
      },
    );

    testWidgets(
      'should not show load more when no more articles',
      (tester) async {
        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => generateArticles(3),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.text('載入更多...'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'should display article with formatted date',
      (tester) async {
        when(() => mockRepo.fetchLatest(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => <Article>[
            createTestArticle(
              publishedDate: DateTime(2024, 3, 15),
            ),
          ],
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('測試文章'), findsOneWidget);
        expect(
          find.textContaining('2024'),
          findsOneWidget,
        );
      },
    );
  });
}
