import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/features/my_reading/presentation/my_reading_page.dart';

void main() {
  late ReadingStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    storage = ReadingStorage(prefs);
  });

  Widget wrapWithApp(Widget widget) {
    return MaterialApp(home: widget);
  }

  group('MyReadingPage', () {
    testWidgets('should display tab bar with two tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithApp(MyReadingPage(storage: storage)),
      );
      await tester.pumpAndSettle();

      expect(find.text('我的閱讀'), findsOneWidget);
      expect(find.text('閱讀記錄'), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
    });

    testWidgets('should display empty history state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithApp(MyReadingPage(storage: storage)),
      );
      await tester.pumpAndSettle();

      expect(find.text('尚無閱讀記錄\n瀏覽文章後會自動記錄'), findsOneWidget);
    });

    testWidgets('should display reading history items',
        (WidgetTester tester) async {
      storage.addToHistory('slug-1', '文章標題一', null, DateTime(2024, 1, 1));
      storage.addToHistory('slug-2', '文章標題二', null, DateTime(2024, 1, 2));

      await tester.pumpWidget(
        wrapWithApp(MyReadingPage(storage: storage)),
      );
      await tester.pumpAndSettle();

      expect(find.text('文章標題一'), findsOneWidget);
      expect(find.text('文章標題二'), findsOneWidget);
    });

    testWidgets('should display empty bookmarks state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithApp(MyReadingPage(storage: storage)),
      );
      await tester.pumpAndSettle();

      // Switch to bookmarks tab
      await tester.tap(find.text('收藏'));
      await tester.pumpAndSettle();

      expect(find.text('尚無收藏文章\n在文章頁面點擊愛心收藏'), findsOneWidget);
    });

    testWidgets('should display bookmark items',
        (WidgetTester tester) async {
      storage.addBookmark('slug-1', '收藏文章', null);

      await tester.pumpWidget(
        wrapWithApp(MyReadingPage(storage: storage)),
      );
      await tester.pumpAndSettle();

      // Switch to bookmarks tab
      await tester.tap(find.text('收藏'));
      await tester.pumpAndSettle();

      expect(find.text('收藏文章'), findsOneWidget);
    });

    testWidgets('should have settings button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithApp(MyReadingPage(storage: storage)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
