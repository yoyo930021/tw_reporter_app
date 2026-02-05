import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/composables/use_debounce.dart';

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
  group('useDebounce', () {
    testWidgets('should delay execution by specified duration', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;
      void callback() {
        callCount++;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final void Function() debouncedFn = useDebounce(
                callback,
                delay: const Duration(milliseconds: 500),
              );

              return (BuildContext context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: debouncedFn,
                      child: const Text('Click'),
                    ),
                  );
            },
          ),
        ),
      );

      // 點擊按鈕
      await tester.tap(find.text('Click'));
      await tester.pump();

      // Assert - 立即執行時不應該被呼叫
      expect(callCount, equals(0));

      // 等待不足 500ms
      await tester.pump(const Duration(milliseconds: 300));
      expect(callCount, equals(0));

      // 等待超過 500ms
      await tester.pump(const Duration(milliseconds: 250));
      expect(callCount, equals(1));
    });

    testWidgets('should cancel previous timer on rapid calls', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;
      void callback() {
        callCount++;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final void Function() debouncedFn = useDebounce(
                callback,
                delay: const Duration(milliseconds: 500),
              );

              return (BuildContext context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: debouncedFn,
                      child: const Text('Click'),
                    ),
                  );
            },
          ),
        ),
      );

      // 快速連續點擊 3 次
      await tester.tap(find.text('Click'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('Click'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('Click'));
      await tester.pump();

      // Assert - 應該還沒有執行
      expect(callCount, equals(0));

      // 等待最後一次點擊的 500ms
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - 只應該執行一次
      expect(callCount, equals(1));
    });

    testWidgets('should execute multiple times if calls are spaced apart', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;
      void callback() {
        callCount++;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final void Function() debouncedFn = useDebounce(
                callback,
                delay: const Duration(milliseconds: 500),
              );

              return (BuildContext context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: debouncedFn,
                      child: const Text('Click'),
                    ),
                  );
            },
          ),
        ),
      );

      // 第一次點擊
      await tester.tap(find.text('Click'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(callCount, equals(1));

      // 第二次點擊（間隔足夠）
      await tester.tap(find.text('Click'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(callCount, equals(2));
    });

    testWidgets('should cancel timer on dispose', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;
      void callback() {
        callCount++;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final void Function() debouncedFn = useDebounce(
                callback,
                delay: const Duration(milliseconds: 500),
              );

              return (BuildContext context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: debouncedFn,
                      child: const Text('Click'),
                    ),
                  );
            },
          ),
        ),
      );

      // 點擊按鈕
      await tester.tap(find.text('Click'));
      await tester.pump();

      // 在計時器觸發前 dispose widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // 等待計時器應該觸發的時間
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - 不應該被呼叫
      expect(callCount, equals(0));
    });

    testWidgets('should work with different delay durations', (WidgetTester tester) async {
      // Arrange
      int callCount = 0;
      void callback() {
        callCount++;
      }

      // Act - 使用 100ms 延遲
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(
            setupFn: () {
              final void Function() debouncedFn = useDebounce(
                callback,
                delay: const Duration(milliseconds: 100),
              );

              return (BuildContext context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: debouncedFn,
                      child: const Text('Click'),
                    ),
                  );
            },
          ),
        ),
      );

      // 點擊並等待 100ms
      await tester.tap(find.text('Click'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(callCount, equals(1));
    });
  });
}
