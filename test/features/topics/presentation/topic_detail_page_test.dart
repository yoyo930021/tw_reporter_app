import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/topics/presentation/topic_detail_page.dart';

class MockTwReporterApi extends Mock implements TwReporterApi {}

/// Helper: create a test article.
Article _article(String id) {
  return Article(
    id: id,
    slug: 'article-$id',
    title: '文章 $id',
    ogDescription: '描述 $id',
    categorySet: <CategorySet>[],
    publishedDate: DateTime(2024, 1, 1),
    isExternal: false,
  );
}

/// Helper: create a ListResponse for articles
ListResponse<Article> _listResponse(List<Article> articles) {
  return ListResponse<Article>(
    data: ListData<Article>(
      meta: ListMeta(
        limit: articles.length,
        offset: 0,
        total: articles.length,
      ),
      records: articles,
    ),
    status: 'success',
  );
}

/// Helper: create a test topic.
Topic _topic({
  List<String>? relateds,
  String? ogDescription,
}) {
  return Topic(
    id: 'topic-1',
    slug: 'test-topic',
    title: '測試專題標題',
    ogDescription: ogDescription ?? '專題描述內容',
    publishedDate: DateTime(2024, 3, 15),
    relateds: relateds,
  );
}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  Widget wrapWithApp(TopicDetailPage page) {
    return MaterialApp(home: page);
  }

  group('TopicDetailPage', () {
    testWidgets(
      'should display topic title and description',
      (WidgetTester tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(
          wrapWithApp(TopicDetailPage(
            api: mockApi,
            slug: 'test-topic',
            topic: topic,
          )),
        );

        await tester.pumpAndSettle();

        // Title appears in both AppBar and body
        expect(find.text('測試專題標題'), findsAtLeast(1));
        expect(find.text('專題描述內容'), findsOneWidget);
      },
    );

    testWidgets(
      'should display published date',
      (WidgetTester tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(
          wrapWithApp(TopicDetailPage(
            api: mockApi,
            slug: 'test-topic',
            topic: topic,
          )),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('2024'), findsOneWidget);
      },
    );

    testWidgets(
      'should display related articles section header',
      (WidgetTester tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(
          wrapWithApp(TopicDetailPage(
            api: mockApi,
            slug: 'test-topic',
            topic: topic,
          )),
        );

        await tester.pumpAndSettle();

        expect(find.text('相關文章'), findsOneWidget);
      },
    );

    testWidgets(
      'should display related articles after loading',
      (WidgetTester tester) async {
        final topic = _topic(relateds: <String>['id1', 'id2']);

        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              ids: any(named: 'ids'),
            )).thenAnswer(
          (_) async => _listResponse(
            <Article>[_article('id1'), _article('id2')],
          ),
        );

        await tester.pumpWidget(
          wrapWithApp(TopicDetailPage(
            api: mockApi,
            slug: 'test-topic',
            topic: topic,
          )),
        );

        await tester.pumpAndSettle();

        expect(find.text('文章 id1'), findsOneWidget);
        expect(find.text('文章 id2'), findsOneWidget);
      },
    );

    testWidgets(
      'should display empty state when no related articles',
      (WidgetTester tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(
          wrapWithApp(TopicDetailPage(
            api: mockApi,
            slug: 'test-topic',
            topic: topic,
          )),
        );

        await tester.pumpAndSettle();

        expect(find.text('沒有相關文章'), findsOneWidget);
      },
    );

    testWidgets(
      'should display loading indicator while loading articles',
      (WidgetTester tester) async {
        final topic = _topic(relateds: <String>['id1']);

        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              ids: any(named: 'ids'),
            )).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return _listResponse(<Article>[_article('id1')]);
        });

        await tester.pumpWidget(
          wrapWithApp(TopicDetailPage(
            api: mockApi,
            slug: 'test-topic',
            topic: topic,
          )),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 10));

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'should display app bar with topic title',
      (WidgetTester tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(
          wrapWithApp(TopicDetailPage(
            api: mockApi,
            slug: 'test-topic',
            topic: topic,
          )),
        );

        await tester.pumpAndSettle();

        expect(find.byType(SliverAppBar), findsOneWidget);
      },
    );

    testWidgets(
      'should display divider between description and articles',
      (WidgetTester tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(
          wrapWithApp(TopicDetailPage(
            api: mockApi,
            slug: 'test-topic',
            topic: topic,
          )),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Divider), findsOneWidget);
      },
    );
  });
}
