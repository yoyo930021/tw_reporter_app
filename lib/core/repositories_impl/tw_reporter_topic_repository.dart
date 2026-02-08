import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/repositories/topic_repository.dart';

/// 報導者 API 專題資料存取實作
class TwReporterTopicRepository implements TopicRepository {
  TwReporterTopicRepository(this._api);

  final TwReporterApi _api;

  @override
  Future<List<Topic>> fetchTopics({
    required int page,
    int limit = 10,
  }) async {
    final offset = (page - 1) * limit;
    final response = await _api.fetchTopics(
      limit: limit,
      offset: offset,
    );
    return response.data.records;
  }
}
