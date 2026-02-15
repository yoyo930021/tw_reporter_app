import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 閱讀記錄資料類別
class ReadingRecord {
  ReadingRecord({
    required this.slug,
    required this.title,
    required this.timestamp,
    this.imageUrl,
  });

  factory ReadingRecord.fromJson(Map<String, dynamic> json) {
    return ReadingRecord(
      slug: json['slug'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  final String slug;
  final String title;
  final String? imageUrl;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'slug': slug,
    'title': title,
    'image_url': imageUrl,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 閱讀記錄與收藏本地儲存服務
class ReadingStorage {
  ReadingStorage(this._prefs);

  static const String _historyKey = 'reading_history';
  static const String _bookmarksKey = 'bookmarks';
  static const int _maxHistoryItems = 200;

  final SharedPreferences _prefs;

  /// 建立 ReadingStorage 實例
  static Future<ReadingStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ReadingStorage(prefs);
  }

  // --- 閱讀記錄 ---

  /// 新增閱讀記錄（自動去重，最新在前）
  void addToHistory(
    String slug,
    String title,
    String? imageUrl,
    DateTime timestamp,
  ) {
    final history = getHistory()
      // 移除同一篇文章的舊記錄
      ..removeWhere((r) => r.slug == slug)
      // 在最前面新增
      ..insert(
        0,
        ReadingRecord(
          slug: slug,
          title: title,
          imageUrl: imageUrl,
          timestamp: timestamp,
        ),
      );

    // 限制數量
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    _saveList(_historyKey, history);
  }

  /// 取得閱讀記錄（按時間倒序）
  List<ReadingRecord> getHistory() {
    return _loadList(_historyKey);
  }

  /// 是否已閱讀過
  bool isRead(String slug) {
    return getHistory().any((r) => r.slug == slug);
  }

  /// 取得所有已讀的 slug 集合（用於批次查詢）
  Set<String> getReadSlugs() {
    return getHistory().map((r) => r.slug).toSet();
  }

  /// 清除所有閱讀記錄
  void clearHistory() {
    unawaited(_prefs.remove(_historyKey));
  }

  // --- 收藏 ---

  /// 新增收藏
  void addBookmark(String slug, String title, String? imageUrl) {
    final bookmarks = getBookmarks();

    // 已收藏則不重複添加
    if (bookmarks.any((r) => r.slug == slug)) return;

    bookmarks.insert(
      0,
      ReadingRecord(
        slug: slug,
        title: title,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      ),
    );

    _saveList(_bookmarksKey, bookmarks);
  }

  /// 取消收藏
  void removeBookmark(String slug) {
    final bookmarks = getBookmarks()..removeWhere((r) => r.slug == slug);
    _saveList(_bookmarksKey, bookmarks);
  }

  /// 是否已收藏
  bool isBookmarked(String slug) {
    return getBookmarks().any((r) => r.slug == slug);
  }

  /// 取得收藏列表
  List<ReadingRecord> getBookmarks() {
    return _loadList(_bookmarksKey);
  }

  // --- 私有方法 ---

  List<ReadingRecord> _loadList(String key) {
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null || jsonStr.isEmpty) return <ReadingRecord>[];

    try {
      final jsonList = json.decode(jsonStr) as List<dynamic>;
      return jsonList
          .map((e) => ReadingRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Object catch (_) {
      return <ReadingRecord>[];
    }
  }

  void _saveList(String key, List<ReadingRecord> list) {
    final jsonStr = json.encode(list.map((r) => r.toJson()).toList());
    unawaited(_prefs.setString(key, jsonStr));
  }
}
