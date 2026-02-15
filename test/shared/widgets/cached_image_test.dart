import 'dart:async';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tw_reporter_app/shared/widgets/cached_image.dart';
import 'package:tw_reporter_app/shared/widgets/shimmer_placeholder.dart';

class _MockCacheManager extends Mock implements BaseCacheManager {}

void main() {
  late _MockCacheManager mockCacheManager;
  late File fakeFile;
  late io.Directory tempDir;

  setUpAll(() {
    tempDir = io.Directory.systemTemp.createTempSync('cached_image_test');
    const fs = LocalFileSystem();
    fakeFile = fs.file('${tempDir.path}/test.png')
      // Minimal 1x1 red PNG
      ..writeAsBytesSync(<int>[
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
        0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
        0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
        0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
        0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
        0x44, 0xAE, 0x42, 0x60, 0x82,
      ]);
  });

  tearDownAll(() {
    tempDir.deleteSync(recursive: true);
  });

  setUp(() {
    mockCacheManager = _MockCacheManager();
    // Clear the global image cache to prevent cross-test contamination.
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });

  FileInfo fakeFileInfo(String url) {
    return FileInfo(
      fakeFile,
      FileSource.Cache,
      DateTime.now().add(const Duration(days: 7)),
      url,
    );
  }

  Stream<FileResponse> fileStream(String url) {
    return Stream<FileResponse>.value(fakeFileInfo(url));
  }

  void stubAny() {
    when(
      () => mockCacheManager.getFileStream(
        any(),
        withProgress: any(named: 'withProgress'),
        key: any(named: 'key'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer(
      (inv) => fileStream(inv.positionalArguments[0] as String),
    );
  }

  void stubUrl(String url, Stream<FileResponse> stream) {
    when(
      () => mockCacheManager.getFileStream(
        url,
        withProgress: any(named: 'withProgress'),
        key: any(named: 'key'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer((_) => stream);
  }

  void stubAnyWith(Stream<FileResponse> Function() streamFactory) {
    when(
      () => mockCacheManager.getFileStream(
        any(),
        withProgress: any(named: 'withProgress'),
        key: any(named: 'key'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer((_) => streamFactory());
  }

  Widget buildWidget({
    String imageUrl = 'https://example.com/image.jpg',
    String? placeholderUrl,
    double? height,
    double? width,
    Widget? errorWidget,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CachedImage(
          imageUrl: imageUrl,
          placeholderUrl: placeholderUrl,
          height: height,
          width: width,
          errorWidget: errorWidget,
          cacheManager: mockCacheManager,
        ),
      ),
    );
  }

  group('CachedImage without placeholderUrl', () {
    testWidgets('renders FadeInImage', (tester) async {
      stubAnyWith(() => StreamController<FileResponse>().stream);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byType(FadeInImage), findsOneWidget);
    });

    testWidgets('calls getFileStream for image URL', (tester) async {
      stubAny();

      await tester.pumpWidget(buildWidget(height: 200));
      await tester.pump();

      verify(
        () => mockCacheManager.getFileStream(
          'https://example.com/image.jpg',
          withProgress: true,
          key: any(named: 'key'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });
  });

  group('CachedImage with placeholderUrl', () {
    testWidgets('renders Image (not FadeInImage)', (tester) async {
      stubAnyWith(() => StreamController<FileResponse>().stream);

      await tester.pumpWidget(
        buildWidget(
          imageUrl: 'https://example.com/main.jpg',
          placeholderUrl: 'https://example.com/tiny.jpg',
        ),
      );
      await tester.pump();

      // Uses Image + frameBuilder (not FadeInImage).
      // Two Image widgets: outer (main) and inner (placeholder via frameBuilder).
      expect(find.byType(FadeInImage), findsNothing);
      expect(find.byType(Image), findsNWidgets(2));
    });

    testWidgets('calls getFileStream for both URLs', (tester) async {
      stubAny();

      await tester.pumpWidget(
        buildWidget(
          imageUrl: 'https://example.com/main.jpg',
          placeholderUrl: 'https://example.com/tiny.jpg',
        ),
      );
      await tester.pump();

      verify(
        () => mockCacheManager.getFileStream(
          'https://example.com/main.jpg',
          withProgress: true,
          key: any(named: 'key'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
      verify(
        () => mockCacheManager.getFileStream(
          'https://example.com/tiny.jpg',
          withProgress: true,
          key: any(named: 'key'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    testWidgets('shows shimmer when placeholder fails', (tester) async {
      stubUrl(
        'https://example.com/tiny.jpg',
        Stream<FileResponse>.error(Exception('fail')),
      );
      // Main image still loading.
      stubUrl(
        'https://example.com/main.jpg',
        StreamController<FileResponse>().stream,
      );

      await tester.pumpWidget(
        buildWidget(
          imageUrl: 'https://example.com/main.jpg',
          placeholderUrl: 'https://example.com/tiny.jpg',
        ),
      );
      await tester.pump();

      // The inner placeholder Image's errorBuilder provides shimmer fallback.
      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });
  });

  group('CachedImage error handling', () {
    testWidgets('shows custom error widget on failure', (tester) async {
      stubAnyWith(
        () => Stream<FileResponse>.error(Exception('Network error')),
      );

      await tester.pumpWidget(
        buildWidget(
          errorWidget: const Icon(
            Icons.broken_image,
            key: ValueKey<String>('custom-error'),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('custom-error')),
        findsOneWidget,
      );
    });

    testWidgets('shows default error icon on failure', (tester) async {
      stubAnyWith(
        () => Stream<FileResponse>.error(Exception('Network error')),
      );

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });
  });
}
