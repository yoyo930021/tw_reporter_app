import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_reporter_app/core/services/donate_text_service.dart';

void main() {
  group('DonateTextService', () {
    late DonateTextService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = DonateTextService.forTest();
    });

    group('parseHtml', () {
      test('extracts inner HTML from donation-box section', () {
        const html = '''
<div class="new-donation-box-section__Container-sc-abc123">
  <h3>贊助報導者的下一個十年</h3>
  <p>自2015年9月，《報導者》靠社會大眾的贊助走到了今天。</p>
  <a href="https://10th.twreporter.org">看見改變</a>
</div>
''';
        final result = DonateTextService.parseHtml(html);
        expect(result, isNotNull);
        expect(
          result!.html,
          contains('贊助報導者的下一個十年'),
        );
        expect(result.html, contains('自2015年9月'));
        expect(
          result.buttonUrl,
          'https://10th.twreporter.org',
        );
      });

      test('returns null for HTML without donation box', () {
        const html = '<div><h3>Other content</h3></div>';
        final result = DonateTextService.parseHtml(html);
        expect(result, isNull);
      });

      test('returns null for empty HTML', () {
        final result = DonateTextService.parseHtml('');
        expect(result, isNull);
      });

      test('extracts button URL from first link', () {
        const html = '''
<section class="donation-box">
  <h3>贊助我們</h3>
  <a href="https://donate.twreporter.org">贊助</a>
  <a href="https://other.url">其他</a>
</section>
''';
        final result = DonateTextService.parseHtml(html);
        expect(result, isNotNull);
        expect(
          result!.buttonUrl,
          'https://donate.twreporter.org',
        );
      });

      test('uses default URL when no link found', () {
        const html = '''
<div class="donation-box">
  <h3>贊助報導者</h3>
  <p>請支持我們。</p>
</div>
''';
        final result = DonateTextService.parseHtml(html);
        expect(result, isNotNull);
        expect(
          result!.buttonUrl,
          DonateTextService.defaultButtonUrl,
        );
      });

      test('handles nested tags of same type', () {
        const html = '''
<div class="donation-box">
  <div><h3>贊助報導者</h3></div>
  <div><p>描述文字</p></div>
</div>
''';
        final result = DonateTextService.parseHtml(html);
        expect(result, isNotNull);
        expect(result!.html, contains('贊助報導者'));
        expect(result.html, contains('描述文字'));
      });

      test('preserves full HTML structure', () {
        const html = '''
<div class="donation-box">
  <h3>標題</h3>
  <p>段落一</p>
  <p>段落二</p>
  <a href="https://url.com">按鈕</a>
</div>
''';
        final result = DonateTextService.parseHtml(html);
        expect(result, isNotNull);
        expect(result!.html, contains('<h3>'));
        expect(result.html, contains('<p>'));
        expect(result.html, contains('段落一'));
        expect(result.html, contains('段落二'));
      });
    });

    group('caching', () {
      test('returns cached data when not expired', () async {
        final prefs =
            await SharedPreferences.getInstance();
        final cachedData = {
          'html': '<h3>快取標題</h3><p>快取描述</p>',
          'buttonUrl': 'https://cached.url',
          'timestamp':
              DateTime.now().millisecondsSinceEpoch,
        };
        // Default pagePath '/' → cache key 'donate_text_cache__'
        await prefs.setString(
          'donate_text_cache__',
          jsonEncode(cachedData),
        );

        final result = await service.fetch();
        expect(result.html, contains('快取標題'));
        expect(result.buttonUrl, 'https://cached.url');
      });

      test(
          'returns expired cache as fallback '
          'when fetch fails', () async {
        final prefs =
            await SharedPreferences.getInstance();
        final cachedData = {
          'html': '<h3>過期快取</h3>',
          'buttonUrl': 'https://expired.url',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
        };
        await prefs.setString(
          'donate_text_cache__',
          jsonEncode(cachedData),
        );

        final result = await service.fetch();
        expect(result.html, contains('過期快取'));
      });

      test(
          'returns default data when no cache '
          'and fetch fails', () async {
        final result = await service.fetch();
        expect(
          result.html,
          DonateTextService.defaultData.html,
        );
        expect(
          result.buttonUrl,
          DonateTextService.defaultData.buttonUrl,
        );
      });

      test(
          'uses separate cache keys for '
          'different page paths', () async {
        final fetchService = DonateTextService.forTest(
          fetcher: (url) async => '''
<div class="donation-box">
  <h3>$url 的贊助內容</h3>
  <p>描述</p>
</div>
''',
        );

        // Fetch for homepage
        final homeResult = await fetchService.fetch();
        expect(
          homeResult.html,
          contains('https://www.twreporter.org/'),
        );

        // Fetch for article
        final articleResult = await fetchService.fetch(
          pagePath: '/a/test-slug',
        );
        expect(
          articleResult.html,
          contains(
            'https://www.twreporter.org/a/test-slug',
          ),
        );

        // Verify both are cached separately
        final prefs =
            await SharedPreferences.getInstance();
        final homeCache =
            prefs.getString('donate_text_cache__');
        final articleCache = prefs
            .getString('donate_text_cache__a_test-slug');
        expect(homeCache, isNotNull);
        expect(articleCache, isNotNull);
      });
    });

    group('fetch with custom fetcher', () {
      test('fetches and parses HTML successfully', () async {
        const mockHtml = '''
<html><body>
<div class="donation-box-section">
  <h3>贊助報導者走過十年</h3>
  <p>感謝您的支持。</p>
  <a href="https://10th.twreporter.org">了解更多</a>
</div>
</body></html>
''';
        final fetchService = DonateTextService.forTest(
          fetcher: (_) async => mockHtml,
        );

        final result = await fetchService.fetch();
        expect(
          result.html,
          contains('贊助報導者走過十年'),
        );
        expect(result.html, contains('感謝您的支持'));
        expect(
          result.buttonUrl,
          'https://10th.twreporter.org',
        );
      });

      test('passes correct URL to fetcher', () async {
        String? capturedUrl;
        final fetchService = DonateTextService.forTest(
          fetcher: (url) async {
            capturedUrl = url;
            return '''
<div class="donation-box">
  <h3>贊助</h3><p>描述</p>
</div>
''';
          },
        );

        await fetchService.fetch(
          pagePath: '/a/my-article',
        );
        expect(
          capturedUrl,
          'https://www.twreporter.org/a/my-article',
        );
      });

      test('saves fetched data to cache', () async {
        const mockHtml = '''
<div class="donation-box">
  <h3>贊助新聞自由</h3>
  <p>獨立媒體需要您。</p>
  <a href="https://donate.tw">贊助</a>
</div>
''';
        final fetchService = DonateTextService.forTest(
          fetcher: (_) async => mockHtml,
        );

        await fetchService.fetch();

        final prefs =
            await SharedPreferences.getInstance();
        final cached =
            prefs.getString('donate_text_cache__');
        expect(cached, isNotNull);
        final data =
            jsonDecode(cached!) as Map<String, dynamic>;
        expect(data['html'], contains('贊助新聞自由'));
      });
    });
  });
}
