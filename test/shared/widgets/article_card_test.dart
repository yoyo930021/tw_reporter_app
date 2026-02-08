import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/core/models/image_size.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';

Article _createArticle({
  String title = '測試文章',
  String ogDescription = '文章描述',
  List<CategorySet>? categorySet,
  HeroImage? heroImage,
}) {
  return Article(
    id: '1',
    slug: 'test-article',
    title: title,
    ogDescription: ogDescription,
    categorySet: categorySet ?? <CategorySet>[],
    publishedDate: DateTime(2024, 6, 15),
    isExternal: false,
    heroImage: heroImage,
  );
}

HeroImage _createHeroImage({
  String? w400Url,
  String? mobileUrl,
  String? tinyUrl,
}) {
  return HeroImage(
    id: 'img-1',
    filetype: 'image/jpeg',
    resizedTargets: ResizedTargets(
      w400: w400Url != null
          ? ImageSize(url: w400Url, width: 400, height: 300)
          : null,
      mobile: mobileUrl != null
          ? ImageSize(url: mobileUrl, width: 800, height: 600)
          : null,
      tiny: tinyUrl != null
          ? ImageSize(url: tinyUrl, width: 100, height: 75)
          : null,
    ),
  );
}

void main() {
  group('ArticleCard', () {
    testWidgets('displays article title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArticleCard(
            article: _createArticle(title: '報導者測試'),
            onTap: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('報導者測試'), findsOneWidget);
    });

    testWidgets('displays article description', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArticleCard(
            article: _createArticle(ogDescription: '這是描述'),
            onTap: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('這是描述'), findsOneWidget);
    });

    testWidgets('displays formatted date', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArticleCard(
            article: _createArticle(),
            onTap: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('2024年06月15日'), findsOneWidget);
    });

    testWidgets('displays category badge when present',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArticleCard(
            article: _createArticle(
              categorySet: <CategorySet>[
                const CategorySet(
                  category: Category(id: '1', name: 'culture', sortOrder: 0),
                ),
              ],
            ),
            onTap: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('culture'), findsOneWidget);
    });

    testWidgets('triggers onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArticleCard(
            article: _createArticle(),
            onTap: () => tapped = true,
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byType(ArticleCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows read badge when isRead is true',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArticleCard(
            article: _createArticle(),
            onTap: () {},
            isRead: true,
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('已讀'), findsOneWidget);
    });

    testWidgets('does not show read badge when isRead is false',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArticleCard(
            article: _createArticle(),
            onTap: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('已讀'), findsNothing);
    });
  });

  group('ArticleCard.getArticleImageUrl', () {
    test('returns w400 url first', () {
      final article = _createArticle(
        heroImage: _createHeroImage(
          w400Url: 'https://w400.jpg',
          mobileUrl: 'https://mobile.jpg',
          tinyUrl: 'https://tiny.jpg',
        ),
      );
      expect(ArticleCard.getArticleImageUrl(article), 'https://w400.jpg');
    });

    test('falls back to mobile url when w400 is null', () {
      final article = _createArticle(
        heroImage: _createHeroImage(
          mobileUrl: 'https://mobile.jpg',
          tinyUrl: 'https://tiny.jpg',
        ),
      );
      expect(ArticleCard.getArticleImageUrl(article), 'https://mobile.jpg');
    });

    test('falls back to tiny url when w400 and mobile are null', () {
      final article = _createArticle(
        heroImage: _createHeroImage(tinyUrl: 'https://tiny.jpg'),
      );
      expect(ArticleCard.getArticleImageUrl(article), 'https://tiny.jpg');
    });

    test('returns null when no image', () {
      final article = _createArticle();
      expect(ArticleCard.getArticleImageUrl(article), isNull);
    });
  });
}
