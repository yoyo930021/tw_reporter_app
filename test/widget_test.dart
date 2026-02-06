import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/main.dart';

void main() {
  testWidgets('App should start successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts without errors
    // This is a basic smoke test to ensure the app can be instantiated
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Bottom navigation should have 5 items',
      (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that bottom navigation bar exists with 5 items
    final Finder bottomNavBar = find.byType(BottomNavigationBar);
    expect(bottomNavBar, findsOneWidget);

    // Verify navigation items exist
    expect(find.text('首頁'), findsOneWidget);
    expect(find.text('最新'), findsOneWidget);
    expect(find.text('專題'), findsOneWidget);
    expect(find.text('搜尋'), findsOneWidget);
    expect(find.text('我的閱讀'), findsOneWidget);
  });
}

