import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';

/// 首頁資料結果類型
///
/// 包含首頁所需的所有狀態和方法
typedef HomeDataResult = ({
  Ref<List<Article>> featuredArticles,
  Ref<bool> isLoadingFeatured,
  Ref<bool> hasError,
  Ref<String?> error,
  Ref<Map<String, List<Article>>> categoryArticles,
  Future<void> Function() refresh,
});

/// 首頁資料 Composable
///
/// 用於管理首頁的精選文章和分類文章資料載入
///
/// ## 使用範例
///
/// ```dart
/// final HomeDataResult result = useHomeData(api);
///
/// // 顯示精選文章
/// if (result.isLoadingFeatured.value) {
///   CircularProgressIndicator()
/// } else if (result.hasError.value) {
///   Text('錯誤: ${result.error.value}')
/// } else {
///   FeaturedCarousel(articles: result.featuredArticles.value)
/// }
///
/// // 顯示分類文章
/// for (final category in result.categoryArticles.value.keys) {
///   CategorySection(
///     category: category,
///     articles: result.categoryArticles.value[category]!,
///   )
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
/// - [featuredArticles]: 精選文章列表
/// - [isLoadingFeatured]: 是否正在載入精選文章
/// - [hasError]: 是否發生錯誤
/// - [error]: 錯誤訊息
/// - [categoryArticles]: 分類文章對照表（分類名稱 -> 文章列表）
/// - [refresh]: 重新載入所有資料的函數
HomeDataResult useHomeData(TwReporterApi api) {
  // 精選文章列表
  final Ref<List<Article>> featuredArticles = ref<List<Article>>(<Article>[]);

  // 載入狀態
  final Ref<bool> isLoadingFeatured = ref<bool>(false);

  // 錯誤狀態
  final Ref<bool> hasError = ref<bool>(false);
  final Ref<String?> error = ref<String?>(null);

  // 分類文章對照表
  final Ref<Map<String, List<Article>>> categoryArticles =
      ref<Map<String, List<Article>>>(<String, List<Article>>{});

  // 要載入的分類列表
  final List<String> categories = <String>['國際', '政治'];

  /// 載入精選文章
  Future<void> loadFeaturedArticles() async {
    if (isLoadingFeatured.value) {
      return;
    }

    isLoadingFeatured.value = true;
    hasError.value = false;
    error.value = null;

    try {
      final List<Article> articles = await api.fetchFeaturedArticles();
      featuredArticles.value = articles;
    } catch (e) {
      hasError.value = true;
      error.value = e.toString();
    } finally {
      isLoadingFeatured.value = false;
    }
  }

  /// 載入分類文章
  Future<void> loadCategoryArticles() async {
    try {
      final Map<String, List<Article>> result = <String, List<Article>>{};

      for (final String category in categories) {
        final List<Article> articles = await api.fetchCategoryArticles(
          category: category,
          page: 1,
          limit: 5,
        );
        result[category] = articles;
      }

      categoryArticles.value = result;
    } catch (e) {
      // 分類文章載入失敗不影響主要流程
    }
  }

  /// 重新載入所有資料
  Future<void> refresh() async {
    await Future.wait(<Future<void>>[
      loadFeaturedArticles(),
      loadCategoryArticles(),
    ]);
  }

  // 初始載入
  onMounted(() {
    refresh();
  });

  return (
    featuredArticles: featuredArticles,
    isLoadingFeatured: isLoadingFeatured,
    hasError: hasError,
    error: error,
    categoryArticles: categoryArticles,
    refresh: refresh,
  );
}
