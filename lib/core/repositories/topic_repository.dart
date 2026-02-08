import 'package:tw_reporter_app/core/models/topic.dart';

/// 專題資料存取抽象介面
// ignore: one_member_abstracts
abstract class TopicRepository {
  /// 獲取專題列表（分頁）
  Future<List<Topic>> fetchTopics({
    required int page,
    int limit = 10,
  });
}
