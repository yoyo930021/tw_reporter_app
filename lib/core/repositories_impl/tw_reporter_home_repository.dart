import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/repositories/home_repository.dart';

/// 報導者 API 首頁資料存取實作
class TwReporterHomeRepository implements HomeRepository {
  TwReporterHomeRepository(this._api);

  final TwReporterApi _api;

  @override
  Future<IndexPageData> fetchIndexPage() async {
    final response = await _api.fetchIndexPage();
    return response.data;
  }
}
