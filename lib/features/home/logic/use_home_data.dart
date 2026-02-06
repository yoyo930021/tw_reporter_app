import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';

/// 首頁資料結果類型
///
/// 包含首頁所需的所有狀態和方法
typedef HomeDataResult = ({
  Ref<IndexPageData?> indexData,
  Ref<bool> isLoading,
  Ref<bool> hasError,
  Ref<String?> error,
  Future<void> Function() refresh,
});

/// 首頁資料 Composable
///
/// 用於管理首頁的所有內容資料載入（使用 /index_page API）
///
/// ## 使用範例
///
/// ```dart
/// final HomeDataResult result = useHomeData(api);
///
/// // 顯示載入狀態
/// if (result.isLoading.value) {
///   CircularProgressIndicator()
/// } else if (result.hasError.value) {
///   Text('錯誤: ${result.error.value}')
/// } else if (result.indexData.value != null) {
///   // 顯示編輯精選
///   FeaturedSection(articles: result.indexData.value!.editorPicksSection)
///
///   // 顯示最新文章
///   LatestSection(articles: result.indexData.value!.latestSection)
///
///   // 顯示分類文章
///   CategorySection(articles: result.indexData.value!.culture)
/// }
///
/// // 重新整理
/// result.refresh();
/// ```
///
/// ## 參數
///
/// - [api]: TwReporterApi 實例，用於資料獲取
///
/// ## 返回值
///
/// - [indexData]: 首頁完整資料（包含所有區塊）
/// - [isLoading]: 是否正在載入
/// - [hasError]: 是否發生錯誤
/// - [error]: 錯誤訊息
/// - [refresh]: 重新載入資料的函數
HomeDataResult useHomeData(TwReporterApi api) {
  // 首頁完整資料
  final Ref<IndexPageData?> indexData = ref<IndexPageData?>(null);

  // 載入狀態
  final Ref<bool> isLoading = ref<bool>(false);

  // 錯誤狀態
  final Ref<bool> hasError = ref<bool>(false);
  final Ref<String?> error = ref<String?>(null);

  /// 載入首頁資料
  Future<void> loadIndexPage() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    error.value = null;

    try {
      final ApiResponse<IndexPageData> response = await api.fetchIndexPage();
      indexData.value = response.data;
    } catch (e, stackTrace) {
      hasError.value = true;
      error.value = e.toString();
      print('載入首頁資料失敗: $e');
      print('堆疊追蹤: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  /// 重新載入資料
  Future<void> refresh() async {
    await loadIndexPage();
  }

  // 初始載入
  onMounted(() {
    loadIndexPage();
  });

  return (
    indexData: indexData,
    isLoading: isLoading,
    hasError: hasError,
    error: error,
    refresh: refresh,
  );
}
