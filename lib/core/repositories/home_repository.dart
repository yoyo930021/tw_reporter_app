import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';

/// 首頁資料存取抽象介面
// ignore: one_member_abstracts
abstract class HomeRepository {
  /// 獲取首頁聚合內容
  Future<IndexPageData> fetchIndexPage();
}
