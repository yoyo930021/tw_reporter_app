import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/category.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/features/topics/logic/use_topic_detail.dart';

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

/// Helper: create a test topic with related IDs.
Topic _topic({List<String>? relateds}) {
  return Topic(
    id: 'topic-1',
    slug: 'test-topic',
    title: '測試專題',
    ogDescription: '專題描述',
    publishedDate: DateTime(2024, 1, 1),
    relateds: relateds,
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

// 測試用的 Composition Widget
class TestWidget extends CompositionWidget {
  const TestWidget({required this.setupFn, super.key});

  final Widget Function(BuildContext) Function() setupFn;

  @override
  Widget Function(BuildContext) setup() => setupFn();
}

void main() {
  late MockTwReporterApi mockApi;

  setUp(() {
    mockApi = MockTwReporterApi();
  });

  group('useTopicDetail', () {
    testWidgets(
      'should load related articles on mount',
      (WidgetTester tester) async {
        // Arrange
        final topic = _topic(relateds: <String>['id1', 'id2', 'id3']);

        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              ids: any(named: 'ids'),
            )).thenAnswer(
          (_) async => _listResponse(
            <Article>[_article('id1'), _article('id2'), _article('id3')],
          ),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(mockApi, topic: topic);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Articles: ${result.relatedArticles.value.length}',
                          ),
                          Text('Loading: ${result.isLoading.value}'),
                          Text('HasError: ${result.hasError.value}'),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Articles: 3'), findsOneWidget);
        expect(find.text('Loading: false'), findsOneWidget);
        expect(find.text('HasError: false'), findsOneWidget);
      },
    );

    testWidgets(
      'should handle fetch error gracefully',
      (WidgetTester tester) async {
        // Arrange
        final topic = _topic(relateds: <String>['id1', 'id2']);

        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              ids: any(named: 'ids'),
            )).thenThrow(Exception('Network error'));

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(mockApi, topic: topic);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Articles: ${result.relatedArticles.value.length}',
                          ),
                          Text('HasError: ${result.hasError.value}'),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Articles: 0'), findsOneWidget);
        expect(find.text('HasError: true'), findsOneWidget);
      },
    );

    testWidgets(
      'should not load when relateds is null',
      (WidgetTester tester) async {
        // Arrange
        final topic = _topic(relateds: null);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(mockApi, topic: topic);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          Text(
                            'Articles: ${result.relatedArticles.value.length}',
                          ),
                          Text('Loading: ${result.isLoading.value}'),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Articles: 0'), findsOneWidget);
        expect(find.text('Loading: false'), findsOneWidget);
        verifyNever(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              ids: any(named: 'ids'),
            ));
      },
    );

    testWidgets(
      'should not load when relateds is empty',
      (WidgetTester tester) async {
        // Arrange
        final topic = _topic(relateds: <String>[]);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(mockApi, topic: topic);

                return (BuildContext context) => Scaffold(
                      body: Text(
                        'Articles: ${result.relatedArticles.value.length}',
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Articles: 0'), findsOneWidget);
        verifyNever(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              ids: any(named: 'ids'),
            ));
      },
    );

    testWidgets(
      'should refresh and reload articles',
      (WidgetTester tester) async {
        // Arrange
        final topic = _topic(relateds: <String>['id1']);
        var callCount = 0;

        when(() => mockApi.fetchPosts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              ids: any(named: 'ids'),
            )).thenAnswer((_) async {
          callCount++;
          return _listResponse(<Article>[_article('call$callCount')]);
        });

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(mockApi, topic: topic);

                return (BuildContext context) => Scaffold(
                      body: Column(
                        children: <Widget>[
                          if (result.relatedArticles.value.isNotEmpty)
                            Text(
                              'First: ${result.relatedArticles.value.first.id}',
                            ),
                          ElevatedButton(
                            onPressed: result.refresh,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('First: call1'), findsOneWidget);

        // Refresh
        await tester.tap(find.text('Refresh'));
        await tester.pumpAndSettle();

        // Assert
        expect(callCount, equals(2));
        expect(find.text('First: call2'), findsOneWidget);
      },
    );

    testWidgets(
      'should expose topic data',
      (WidgetTester tester) async {
        // Arrange
        final topic = _topic(relateds: null);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: TestWidget(
              setupFn: () {
                final result = useTopicDetail(mockApi, topic: topic);

                return (BuildContext context) => Scaffold(
                      body: Text('Title: ${result.topic.value.title}'),
                    );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Title: 測試專題'), findsOneWidget);
      },
    );
  });
}
