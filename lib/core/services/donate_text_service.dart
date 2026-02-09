import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data class for donate banner content.
class DonateTextData {
  const DonateTextData({
    required this.html,
    required this.buttonUrl,
  });

  /// The raw HTML content of the donation box section.
  final String html;

  /// The URL for the donate button (extracted from the first link).
  final String buttonUrl;
}

/// Fetches and caches donate text from twreporter.org pages.
///
/// Supports fetching from different page URLs (homepage, article
/// pages, etc.) with per-URL caching.
class DonateTextService {
  DonateTextService._({Future<String> Function(String url)? fetcher})
      : _fetcher = fetcher;

  /// For testing with mock fetcher or default throwing fetcher.
  factory DonateTextService.forTest({
    Future<String> Function(String url)? fetcher,
  }) {
    return DonateTextService._(
      fetcher: fetcher ??
          (_) => throw Exception('No network in test'),
    );
  }

  static final instance = DonateTextService._();

  final Future<String> Function(String url)? _fetcher;

  static const _baseUrl = 'https://www.twreporter.org';

  static const defaultHtml = '<h3>深度求真 眾聲同行</h3>\n'
      '<p>在艱困的媒體環境，《報導者》堅持以非營利組織的模式'
      '投入公共領域的調查與深度報導。我們透過讀者的贊助支持'
      '來營運，不仰賴商業廣告置入，在獨立自主的前提下，'
      '穿梭在各項重要公共議題中。</p>';

  static const defaultButtonUrl = 'https://support.twreporter.org';

  static const defaultData = DonateTextData(
    html: defaultHtml,
    buttonUrl: defaultButtonUrl,
  );

  static const _cacheKeyPrefix = 'donate_text_cache';
  static const _cacheTtl = Duration(days: 1);

  /// Fetches donate text from a specific page path.
  ///
  /// [pagePath] is the path portion, e.g. `'/'` for homepage
  /// or `'/a/some-article-slug'` for an article page.
  /// Returns cached data if fresh, otherwise fetches from
  /// website. Falls back to cached or default data.
  Future<DonateTextData> fetch({String pagePath = '/'}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKeyFor(pagePath);

    // Check cache
    final cached = _readCache(prefs, cacheKey);
    if (cached != null && !_isCacheExpired(prefs, cacheKey)) {
      return cached;
    }

    // Try fetch from web
    try {
      final url = '$_baseUrl$pagePath';
      final pageHtml = await _fetchHtml(url);
      final parsed = parseHtml(pageHtml);
      if (parsed != null) {
        await _writeCache(prefs, cacheKey, parsed);
        return parsed;
      }
    } on Exception {
      // Network error - fall through to fallback
    }

    // Fallback: expired cache or default
    return cached ?? defaultData;
  }

  static String _cacheKeyFor(String pagePath) {
    // Use a simple suffix derived from the path
    final suffix =
        pagePath.replaceAll('/', '_').replaceAll(RegExp('[^a-zA-Z0-9_-]'), '');
    return '${_cacheKeyPrefix}_$suffix';
  }

  Future<String> _fetchHtml(String url) async {
    if (_fetcher != null) {
      return _fetcher(url);
    }
    final dio = Dio();
    try {
      final response = await dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      return response.data ?? '';
    } finally {
      dio.close();
    }
  }

  /// Parses the donation box content from HTML page.
  /// Finds the element with "donation-box" in its class name
  /// and extracts the inner HTML content.
  static DonateTextData? parseHtml(String html) {
    // Find donation-box section by class name
    final boxPattern = RegExp(
      'class="[^"]*donation-box[^"]*"',
      caseSensitive: false,
    );
    final boxMatch = boxPattern.firstMatch(html);
    if (boxMatch == null) return null;

    // Find the opening tag that contains this class
    final tagStart = html.lastIndexOf('<', boxMatch.start);
    if (tagStart < 0) return null;

    // Extract the tag name
    final tagNameMatch = RegExp('<([a-zA-Z][a-zA-Z0-9]*)')
        .firstMatch(html.substring(tagStart));
    if (tagNameMatch == null) return null;
    final tagName = tagNameMatch.group(1)!;

    // Find the end of opening tag
    final openTagEnd = html.indexOf('>', boxMatch.end);
    if (openTagEnd < 0) return null;

    // Extract inner HTML between opening and closing tags
    final innerStart = openTagEnd + 1;
    final closeIndex = _findMatchingClose(
      html,
      innerStart,
      tagName,
    );
    if (closeIndex < 0) return null;

    final innerHtml =
        html.substring(innerStart, closeIndex).trim();
    if (innerHtml.isEmpty) return null;

    // Extract button URL from the first <a> tag
    final aPattern = RegExp('href="([^"]*)"');
    final aMatch = aPattern.firstMatch(innerHtml);
    final buttonUrl =
        aMatch?.group(1) ?? defaultButtonUrl;

    return DonateTextData(
      html: innerHtml,
      buttonUrl: buttonUrl,
    );
  }

  /// Finds the index of the matching closing tag, handling
  /// nested tags of the same name.
  static int _findMatchingClose(
    String html,
    int start,
    String tagName,
  ) {
    final openPattern = RegExp('<$tagName[\\s>]');
    final closePattern = RegExp('</$tagName>');
    var depth = 1;
    var pos = start;

    while (depth > 0 && pos < html.length) {
      final nextOpen = openPattern.firstMatch(
        html.substring(pos),
      );
      final nextClose = closePattern.firstMatch(
        html.substring(pos),
      );

      if (nextClose == null) return -1;

      if (nextOpen != null &&
          nextOpen.start < nextClose.start) {
        depth++;
        pos += nextOpen.start + 1;
      } else {
        depth--;
        if (depth == 0) return pos + nextClose.start;
        pos += nextClose.start + closePattern.pattern.length;
      }
    }
    return -1;
  }

  DonateTextData? _readCache(
    SharedPreferences prefs,
    String cacheKey,
  ) {
    final raw = prefs.getString(cacheKey);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final html = data['html'];
      final buttonUrl = data['buttonUrl'];
      if (html is! String || buttonUrl is! String) {
        return null;
      }
      return DonateTextData(
        html: html,
        buttonUrl: buttonUrl,
      );
    } on Object {
      return null;
    }
  }

  bool _isCacheExpired(
    SharedPreferences prefs,
    String cacheKey,
  ) {
    final raw = prefs.getString(cacheKey);
    if (raw == null) return true;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final timestamp = data['timestamp'];
      if (timestamp is! int) return true;
      final cached =
          DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cached) > _cacheTtl;
    } on Object {
      return true;
    }
  }

  Future<void> _writeCache(
    SharedPreferences prefs,
    String cacheKey,
    DonateTextData data,
  ) async {
    final json = jsonEncode({
      'html': data.html,
      'buttonUrl': data.buttonUrl,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    await prefs.setString(cacheKey, json);
  }
}
