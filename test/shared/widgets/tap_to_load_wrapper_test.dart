import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/core/settings/media_load_mode.dart';
import 'package:tw_reporter_app/shared/widgets/tap_to_load_wrapper.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('TapToLoadWrapper', () {
    testWidgets('renders child directly in normal mode',
        (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const TapToLoadWrapper(
            mediaType: MediaType.video,
            child: Text('Video Content'),
          ),
          mediaLoadMode: Ref<MediaLoadMode>(MediaLoadMode.normal),
        ),
      );

      expect(find.text('Video Content'), findsOneWidget);
      expect(find.text('點擊載入影片'), findsNothing);
    });

    testWidgets('shows placeholder in dataSaving mode',
        (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const TapToLoadWrapper(
            mediaType: MediaType.video,
            child: Text('Video Content'),
          ),
          mediaLoadMode: Ref<MediaLoadMode>(MediaLoadMode.dataSaving),
        ),
      );

      expect(find.text('Video Content'), findsNothing);
      expect(find.text('點擊載入影片'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('loads child after tap in dataSaving mode',
        (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const TapToLoadWrapper(
            mediaType: MediaType.video,
            child: Text('Video Content'),
          ),
          mediaLoadMode: Ref<MediaLoadMode>(MediaLoadMode.dataSaving),
        ),
      );

      // Initially shows placeholder
      expect(find.text('Video Content'), findsNothing);
      expect(find.text('點擊載入影片'), findsOneWidget);

      // Tap the placeholder
      await tester.tap(find.text('點擊載入影片'));
      await tester.pumpAndSettle();

      // Now shows child
      expect(find.text('Video Content'), findsOneWidget);
      expect(find.text('點擊載入影片'), findsNothing);
    });

    testWidgets('shows correct label for youtube type',
        (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const TapToLoadWrapper(
            mediaType: MediaType.youtube,
            child: Text('YouTube'),
          ),
          mediaLoadMode: Ref<MediaLoadMode>(MediaLoadMode.dataSaving),
        ),
      );

      expect(find.text('點擊載入 YouTube 影片'), findsOneWidget);
    });

    testWidgets('shows correct label for webview type',
        (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const TapToLoadWrapper(
            mediaType: MediaType.webview,
            child: Text('WebView'),
          ),
          mediaLoadMode: Ref<MediaLoadMode>(MediaLoadMode.dataSaving),
        ),
      );

      expect(find.text('點擊載入嵌入內容'), findsOneWidget);
    });

    testWidgets('shows correct label for image type',
        (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const TapToLoadWrapper(
            mediaType: MediaType.image,
            child: Text('Image'),
          ),
          mediaLoadMode: Ref<MediaLoadMode>(MediaLoadMode.dataSaving),
        ),
      );

      expect(find.text('點擊載入圖片'), findsOneWidget);
    });

    testWidgets('shows correct label for imagediff type',
        (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const TapToLoadWrapper(
            mediaType: MediaType.imagediff,
            child: Text('ImageDiff'),
          ),
          mediaLoadMode: Ref<MediaLoadMode>(MediaLoadMode.dataSaving),
        ),
      );

      expect(find.text('點擊載入圖片比較'), findsOneWidget);
    });

    testWidgets('shows correct label for slideshow type',
        (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const TapToLoadWrapper(
            mediaType: MediaType.slideshow,
            child: Text('Slideshow'),
          ),
          mediaLoadMode: Ref<MediaLoadMode>(MediaLoadMode.dataSaving),
        ),
      );

      expect(find.text('點擊載入相簿'), findsOneWidget);
    });
  });
}
