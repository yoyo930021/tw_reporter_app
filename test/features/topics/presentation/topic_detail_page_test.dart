import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/topics/presentation/topic_detail_page.dart';

import '../../../helpers/test_helpers.dart';

/// Helper: create a test topic for detail page.
Topic _topic({
  List<String>? relateds,
  String? ogDescription,
}) {
  return createTestTopic(
    title: '測試專題標題',
    ogDescription: ogDescription ?? '專題描述內容',
    relateds: relateds,
  );
}

void main() {
  late MockArticleRepository mockRepo;

  setUp(() {
    mockRepo = MockArticleRepository();
  });

  Widget buildPage(Topic topic) {
    return wrapWithProviders(
      TopicDetailPage(
        slug: topic.slug,
        topic: topic,
      ),
      articleRepository: mockRepo,
    );
  }

  group('TopicDetailPage', () {
    testWidgets(
      'should display topic title and description',
      (tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(buildPage(topic));
        await tester.pumpAndSettle();

        expect(
          find.text('測試專題標題'),
          findsAtLeast(1),
        );
        expect(
          find.text('專題描述內容'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display published date',
      (tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(buildPage(topic));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('2024'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display related articles section header',
      (tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(buildPage(topic));
        await tester.pumpAndSettle();

        expect(find.text('相關文章'), findsOneWidget);
      },
    );

    testWidgets(
      'should display related articles after loading',
      (tester) async {
        final topic = _topic(
          relateds: <String>['id1', 'id2'],
        );

        when(() => mockRepo.fetchByIds(any()))
            .thenAnswer(
          (_) async => <Article>[
            createTestArticle(
              id: 'id1',
              slug: 'a-id1',
              title: '文章 id1',
            ),
            createTestArticle(
              id: 'id2',
              slug: 'a-id2',
              title: '文章 id2',
            ),
          ],
        );

        await tester.pumpWidget(buildPage(topic));
        await tester.pumpAndSettle();

        expect(find.text('文章 id1'), findsOneWidget);
        expect(find.text('文章 id2'), findsOneWidget);
      },
    );

    testWidgets(
      'should display empty state when no '
      'related articles',
      (tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(buildPage(topic));
        await tester.pumpAndSettle();

        expect(
          find.text('沒有相關文章'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display loading indicator while '
      'loading articles',
      (tester) async {
        final topic = _topic(
          relateds: <String>['id1'],
        );

        when(() => mockRepo.fetchByIds(any()))
            .thenAnswer((_) async {
          await Future<void>.delayed(
            const Duration(milliseconds: 50),
          );
          return <Article>[
            createTestArticle(
              id: 'id1',
              slug: 'a-id1',
            ),
          ];
        });

        await tester.pumpWidget(buildPage(topic));

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
      'should display app bar with topic title',
      (tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(buildPage(topic));
        await tester.pumpAndSettle();

        expect(
          find.byType(SliverAppBar),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display divider between '
      'description and articles',
      (tester) async {
        final topic = _topic(relateds: <String>[]);

        await tester.pumpWidget(buildPage(topic));
        await tester.pumpAndSettle();

        expect(find.byType(Divider), findsOneWidget);
      },
    );
  });
}
