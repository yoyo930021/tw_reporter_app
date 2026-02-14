import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/composables/use_scroll_visibility.dart';

/// A test widget that uses [useScrollVisibility] and exposes the result.
class _TestWidget extends CompositionWidget {
  const _TestWidget({required this.onSetup});

  final void Function(Ref<bool> isVisible) onSetup;

  @override
  Widget Function(BuildContext) setup() {
    final isVisible = useScrollVisibility();
    onSetup(isVisible);

    return (context) => const SizedBox(height: 100);
  }
}

void main() {
  group('useScrollVisibility', () {
    testWidgets('returns Ref<bool> initially true when in viewport',
        (tester) async {
      late Ref<bool> isVisibleRef;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: <Widget>[
                _TestWidget(
                  onSetup: (isVisible) {
                    isVisibleRef = isVisible;
                  },
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(isVisibleRef.value, isTrue);
    });

    testWidgets('sets false when widget is unmounted by scrolling out',
        (tester) async {
      late Ref<bool> isVisibleRef;
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              controller: controller,
              // Minimal cache extent so the widget is disposed sooner.
              cacheExtent: 0,
              children: <Widget>[
                const SizedBox(height: 100),
                _TestWidget(
                  onSetup: (isVisible) {
                    isVisibleRef = isVisible;
                  },
                ),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(isVisibleRef.value, isTrue);

      // Scroll the widget out of the viewport + cache extent.
      controller.jumpTo(800);
      await tester.pumpAndSettle();

      // Widget was unmounted by the ListView → isVisible set to false.
      expect(isVisibleRef.value, isFalse);

      controller.dispose();
    });

    testWidgets(
        'detects visibility change via scroll in non-recycling scroll view',
        (tester) async {
      late Ref<bool> isVisibleRef;
      final controller = ScrollController();

      // Use SingleChildScrollView which does NOT recycle children.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 100),
                  _TestWidget(
                    onSetup: (isVisible) {
                      isVisibleRef = isVisible;
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(isVisibleRef.value, isTrue);

      // Scroll out of view.
      controller.jumpTo(800);
      await tester.pump(); // layout update
      await tester.pump(const Duration(milliseconds: 200)); // debounce

      expect(isVisibleRef.value, isFalse);

      // Scroll back.
      controller.jumpTo(0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(isVisibleRef.value, isTrue);

      controller.dispose();
    });

    testWidgets('debounces rapid scroll events', (tester) async {
      var changeCount = 0;
      late Ref<bool> isVisibleRef;
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 100),
                  _TestWidget(
                    onSetup: (isVisible) {
                      isVisibleRef = isVisible;
                      watch(() => isVisible.value, (_, _) {
                        changeCount++;
                      });
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      changeCount = 0;

      // Rapidly scroll in small increments (widget stays in viewport).
      for (var i = 1; i <= 5; i++) {
        controller.jumpTo(i * 10.0);
        await tester.pump(const Duration(milliseconds: 30));
      }

      // Wait for debounce.
      await tester.pump(const Duration(milliseconds: 200));

      // Widget is still visible (small scrolls), no change expected.
      expect(isVisibleRef.value, isTrue);
      expect(changeCount, 0);

      controller.dispose();
    });

    testWidgets('works without a Scrollable ancestor', (tester) async {
      late Ref<bool> isVisibleRef;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestWidget(
              onSetup: (isVisible) {
                isVisibleRef = isVisible;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(isVisibleRef.value, isTrue);
    });

    testWidgets('supports custom debounce duration', (tester) async {
      late Ref<bool> isVisibleRef;
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 100),
                  _CustomDebounceTestWidget(
                    onSetup: (isVisible) {
                      isVisibleRef = isVisible;
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.jumpTo(800);
      await tester.pump(); // layout update
      // Custom 50ms debounce should fire within 80ms.
      await tester.pump(const Duration(milliseconds: 80));
      expect(isVisibleRef.value, isFalse);

      controller.dispose();
    });
  });
}

/// Test widget using custom debounce duration.
class _CustomDebounceTestWidget extends CompositionWidget {
  const _CustomDebounceTestWidget({required this.onSetup});

  final void Function(Ref<bool> isVisible) onSetup;

  @override
  Widget Function(BuildContext) setup() {
    final isVisible = useScrollVisibility(
      debounceDuration: const Duration(milliseconds: 50),
    );
    onSetup(isVisible);

    return (context) => const SizedBox(height: 100);
  }
}
