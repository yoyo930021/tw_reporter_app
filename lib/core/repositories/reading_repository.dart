import 'package:flutter/foundation.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';

/// 閱讀記錄與收藏抽象介面
abstract class ReadingRepository extends ChangeNotifier {
  /// 新增閱讀記錄
  void addToHistory(
    String slug,
    String title,
    String? imageUrl,
    DateTime timestamp,
  );

  /// 取得閱讀記錄
  List<ReadingRecord> getHistory();

  /// 是否已閱讀
  bool isRead(String slug);

  /// 清除所有閱讀記錄
  void clearHistory();

  /// 新增收藏
  void addBookmark(String slug, String title, String? imageUrl);

  /// 取消收藏
  void removeBookmark(String slug);

  /// 是否已收藏
  bool isBookmarked(String slug);

  /// 取得收藏列表
  List<ReadingRecord> getBookmarks();
}
