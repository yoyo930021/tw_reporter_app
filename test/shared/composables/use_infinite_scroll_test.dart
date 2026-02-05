import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/composables/use_infinite_scroll.dart';

// 測試用的 Composition Widget
class TestWidget extends CompositionWidget {
  TestWidget({
    required this.setupFn,
    super.key,
  });

  final Widget Function(BuildContext) Function() setupFn;

  @override
  Widget Function(BuildContext) setup() => setupFn();
}

void main() {
  group('useInfiniteScroll', () {
    testWidgets('should load initial data on mount', (WidgetTester tester) async {
      // Arrange
      int fetchCallCount = 0;

      Future<List<String>> mockFetcher(int page) async {
        fetchCallCount++;
        return <String>['item$page'];
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final InfiniteScrollResult<String> result = useInfiniteScroll<String>(
                fetcher: mockFetcher,
                pageSize: 10,
              );

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.items.value.length}'),
                        Text('Loading: ${result.isLoading.value}'),
                        Text('HasMore: ${result.hasMore.value}'),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待非同步操作完成
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(fetchCallCount, equals(1));
      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('should load more data when loadMore is called', (WidgetTester tester) async {
      // Arrange
      final List<List<String>> mockData = <List<String>>[
        <String>['item1', 'item2'],
        <String>['item3', 'item4'],
      ];
      int currentPage = 0;

      Future<List<String>> mockFetcher(int page) async {
        final List<String> data = mockData[currentPage];
        currentPage++;
        return data;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final InfiniteScrollResult<String> result = useInfiniteScroll<String>(
                fetcher: mockFetcher,
                pageSize: 2,
              );

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.items.value.length}'),
                        ElevatedButton(
                          onPressed: result.loadMore,
                          child: const Text('Load More'),
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待初始載入
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Count: 2'), findsOneWidget);

      // 載入更多
      await tester.tap(find.text('Load More'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('Count: 4'), findsOneWidget);
    });

    testWidgets('should set hasMore to false when fetched items less than pageSize',
        (WidgetTester tester) async {
      // Arrange
      Future<List<String>> mockFetcher(int page) async {
        return <String>['item1']; // Less than pageSize
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final InfiniteScrollResult<String> result = useInfiniteScroll<String>(
                fetcher: mockFetcher,
                pageSize: 10,
              );

              return (BuildContext context) => Scaffold(
                    body: Text('HasMore: ${result.hasMore.value}'),
                  );
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.text('HasMore: false'), findsOneWidget);
    });

    testWidgets('should reset data on refresh', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;

      Future<List<String>> mockFetcher(int page) async {
        callCount++;
        return <String>['item$callCount'];
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final InfiniteScrollResult<String> result = useInfiniteScroll<String>(
                fetcher: mockFetcher,
                pageSize: 10,
              );

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${result.items.value.length}'),
                        if (result.items.value.isNotEmpty)
                          Text('First: ${result.items.value.first}'),
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

      // 等待初始載入
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Count: 1'), findsOneWidget);
      expect(find.text('First: item1'), findsOneWidget);
      expect(callCount, equals(1));

      // 重新整理
      await tester.tap(find.text('Refresh'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(callCount, equals(2));
      expect(find.text('Count: 1'), findsOneWidget);
      expect(find.text('First: item2'), findsOneWidget);
    });

    testWidgets('should not load more when already loading', (WidgetTester tester) async {
      // Arrange
      int fetchCallCount = 0;

      Future<List<String>> mockFetcher(int page) async {
        fetchCallCount++;
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // 返回 10 個項目以確保 hasMore 為 true
        return List<String>.generate(10, (int index) => 'item${page}_$index');
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final InfiniteScrollResult<String> result = useInfiniteScroll<String>(
                fetcher: mockFetcher,
                pageSize: 10,
              );

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('Count: ${fetchCallCount}'),
                        ElevatedButton(
                          onPressed: result.loadMore,
                          child: const Text('Load More'),
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待初始載入完成
      await tester.pump(); // 啟動 onMounted
      await tester.pump(); // 開始執行 loadMore
      await tester.pump(const Duration(milliseconds: 100)); // 等待 fetcher 的 delay
      await tester.pump(); // 完成 loadMore 的後續操作

      // 確保初始載入已完成
      expect(fetchCallCount, equals(1));

      // 快速連續點擊兩次
      await tester.tap(find.text('Load More'));
      await tester.pump(); // 啟動第一次點擊
      await tester.pump(const Duration(milliseconds: 10)); // 不等待完成
      await tester.tap(find.text('Load More')); // 第二次點擊應該被忽略
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150)); // 等待第一次點擊完成

      // Assert - 應該只增加一次（總共 2 次：初始 + 第一次點擊）
      expect(fetchCallCount, equals(2));
    });

    testWidgets('should not load more when hasMore is false', (WidgetTester tester) async {
      // Arrange
      int fetchCallCount = 0;

      Future<List<String>> mockFetcher(int page) async {
        fetchCallCount++;
        return <String>['item$page']; // Less than pageSize
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final InfiniteScrollResult<String> result = useInfiniteScroll<String>(
                fetcher: mockFetcher,
                pageSize: 10,
              );

              return (BuildContext context) => Scaffold(
                    body: Column(
                      children: <Widget>[
                        Text('FetchCount: $fetchCallCount'),
                        Text('HasMore: ${result.hasMore.value}'),
                        ElevatedButton(
                          onPressed: result.loadMore,
                          child: const Text('Load More'),
                        ),
                      ],
                    ),
                  );
            },
          ),
        ),
      );

      // 等待初始載入
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fetchCallCount, equals(1));
      expect(find.text('HasMore: false'), findsOneWidget);

      // 嘗試載入更多（應該被忽略，因為 hasMore 是 false）
      await tester.tap(find.text('Load More'));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(fetchCallCount, equals(1)); // 沒有增加
    });
  });
}
