import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/features/my_reading/presentation/my_reading_page.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockReadingRepository mockReadingRepo;

  setUp(() {
    mockReadingRepo = MockReadingRepository();
    when(() => mockReadingRepo.getHistory())
        .thenReturn(<ReadingRecord>[]);
    when(() => mockReadingRepo.getBookmarks())
        .thenReturn(<ReadingRecord>[]);
  });

  group('MyReadingPage', () {
    testWidgets(
      'should display tab bar with two tabs',
      (tester) async {
        await tester.pumpWidget(
          wrapWithProviders(
            const MyReadingPage(),
            readingRepository: mockReadingRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('我的閱讀'), findsOneWidget);
        expect(find.text('閱讀記錄'), findsOneWidget);
        expect(find.text('收藏'), findsOneWidget);
      },
    );

    testWidgets(
      'should display empty history state',
      (tester) async {
        await tester.pumpWidget(
          wrapWithProviders(
            const MyReadingPage(),
            readingRepository: mockReadingRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('尚無閱讀記錄\n瀏覽文章後會自動記錄'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display reading history items',
      (tester) async {
        when(() => mockReadingRepo.getHistory()).thenReturn(
          <ReadingRecord>[
            ReadingRecord(
              slug: 'slug-1',
              title: '文章標題一',
              timestamp: DateTime(2024),
            ),
            ReadingRecord(
              slug: 'slug-2',
              title: '文章標題二',
              timestamp: DateTime(2024, 1, 2),
            ),
          ],
        );

        await tester.pumpWidget(
          wrapWithProviders(
            const MyReadingPage(),
            readingRepository: mockReadingRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('文章標題一'), findsOneWidget);
        expect(find.text('文章標題二'), findsOneWidget);
      },
    );

    testWidgets(
      'should display empty bookmarks state',
      (tester) async {
        await tester.pumpWidget(
          wrapWithProviders(
            const MyReadingPage(),
            readingRepository: mockReadingRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Switch to bookmarks tab
        await tester.tap(find.text('收藏'));
        await tester.pumpAndSettle();

        expect(
          find.text('尚無收藏文章\n在文章頁面點擊愛心收藏'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display bookmark items',
      (tester) async {
        when(() => mockReadingRepo.getBookmarks()).thenReturn(
          <ReadingRecord>[
            ReadingRecord(
              slug: 'slug-1',
              title: '收藏文章',
              timestamp: DateTime(2024),
            ),
          ],
        );

        await tester.pumpWidget(
          wrapWithProviders(
            const MyReadingPage(),
            readingRepository: mockReadingRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Switch to bookmarks tab
        await tester.tap(find.text('收藏'));
        await tester.pumpAndSettle();

        expect(find.text('收藏文章'), findsOneWidget);
      },
    );

    testWidgets(
      'should have settings button in app bar',
      (tester) async {
        await tester.pumpWidget(
          wrapWithProviders(
            const MyReadingPage(),
            readingRepository: mockReadingRepo,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byIcon(Icons.settings),
          findsOneWidget,
        );
      },
    );
  });
}
