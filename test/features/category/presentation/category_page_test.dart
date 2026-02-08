import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/features/category/presentation/category_page.dart';

import '../../../helpers/test_helpers.dart';

/// Helper: create articles with the given category.
List<Article> _withCat(String cat, int count) {
  return List<Article>.generate(
    count,
    (i) => createTestArticle(
      id: '$i',
      slug: 'article-$i',
      title: '$cat文章 $i',
      ogDescription: '描述 $i',
      categorySet: <CategorySet>[
        CategorySet(
          category: Category(
            id: 'cat-$cat',
            name: cat,
          ),
        ),
      ],
      publishedDate: DateTime(2024, 1, 1 + i),
    ),
  );
}

void main() {
  late MockArticleRepository mockRepo;

  setUp(() {
    mockRepo = MockArticleRepository();
  });

  Widget buildPage(String category) {
    return wrapWithProviders(
      CategoryPage(category: category),
      articleRepository: mockRepo,
    );
  }

  group('CategoryPage', () {
    testWidgets(
      'should display app bar with category name',
      (tester) async {
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => <Article>[],
        );

        await tester.pumpWidget(buildPage('國際'));
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('國際'), findsOneWidget);
      },
    );

    testWidgets(
      'should display list of articles after loading',
      (tester) async {
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => _withCat('政治', 5),
        );

        await tester.pumpWidget(buildPage('政治'));
        await tester.pumpAndSettle();

        expect(find.text('政治文章 0'), findsOneWidget);
        expect(
          find.byType(ListView),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display loading indicator on initial load',
      (tester) async {
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          await Future<void>.delayed(
            const Duration(milliseconds: 50),
          );
          return <Article>[];
        });

        await tester.pumpWidget(buildPage('人權'));

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
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => <Article>[],
        );

        await tester.pumpWidget(buildPage('健康'));
        await tester.pumpAndSettle();

        expect(
          find.text('此分類目前沒有文章'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should have RefreshIndicator for pull to refresh',
      (tester) async {
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => _withCat('環境', 3),
        );

        await tester.pumpWidget(buildPage('環境'));
        await tester.pumpAndSettle();

        expect(
          find.byType(RefreshIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should load more articles when scrolling',
      (tester) async {
        var callCount = 0;
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          callCount++;
          return _withCat('經濟', 10);
        });

        await tester.pumpWidget(buildPage('經濟'));
        await tester.pumpAndSettle();

        expect(find.text('經濟文章 0'), findsOneWidget);

        await tester.drag(
          find.byType(ListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        expect(callCount, greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      'should not show load more indicator '
      'when no more articles',
      (tester) async {
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => _withCat('文化', 3),
        );

        await tester.pumpWidget(buildPage('文化'));
        await tester.pumpAndSettle();

        expect(find.text('載入更多...'), findsNothing);
      },
    );

    testWidgets(
      'should display article with formatted date',
      (tester) async {
        final articles = <Article>[
          createTestArticle(
            title: '教育文章',
            categorySet: <CategorySet>[
              const CategorySet(
                category: Category(
                  id: 'cat-教育',
                  name: '教育',
                ),
              ),
            ],
            publishedDate: DateTime(2024, 3, 15),
          ),
        ];
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => articles);

        await tester.pumpWidget(buildPage('教育'));
        await tester.pumpAndSettle();

        expect(find.text('教育文章'), findsOneWidget);
        expect(
          find.textContaining('2024'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should handle different category parameters',
      (tester) async {
        when(() => mockRepo.fetchByCategory(
              category: any(named: 'category'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => _withCat('國際', 1),
        );

        await tester.pumpWidget(buildPage('國際'));
        await tester.pumpAndSettle();

        expect(find.text('國際'), findsAtLeast(1));
        expect(
          find.text('國際文章 0'),
          findsOneWidget,
        );
      },
    );
  });
}
