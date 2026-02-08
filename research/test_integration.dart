import 'package:dio/dio.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';

/// 測試 API 整合
void main() async {
  print('測試報導者 API 整合\n${'=' * 60}');

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final api = TwReporterApi(dio);

  // 1. 測試文章列表
  await testFetchPosts(api);

  // 2. 測試專題列表
  await testFetchTopics(api);

  // 3. 測試首頁內容
  await testFetchIndexPage(api);

  // 4. 測試文章詳情
  await testFetchPost(api);

  print('\n${'=' * 60}');
  print('✓ 所有測試完成！');
}

Future<void> testFetchPosts(TwReporterApi api) async {
  print('\n📰 測試文章列表 API');
  print('-' * 60);

  try {
    final ListResponse<dynamic> response = await api.fetchPosts(limit: 3);

    print('✓ 成功獲取文章列表');
    print('  狀態: ${response.status}');
    print('  總數: ${response.data.meta.total}');
    print('  當前頁數量: ${response.data.records.length}');

    if (response.data.records.isNotEmpty) {
      final dynamic firstArticle = response.data.records.first;
      print('\n  第一篇文章:');
      print('    標題: ${firstArticle.title}');
      print('    Slug: ${firstArticle.slug}');
      print('    發佈時間: ${firstArticle.publishedDate}');
    }
  } catch (e, stackTrace) {
    print('✗ 錯誤: $e');
    print('堆疊追蹤:\n$stackTrace');
  }
}

Future<void> testFetchTopics(TwReporterApi api) async {
  print('\n📚 測試專題列表 API');
  print('-' * 60);

  try {
    final ListResponse<dynamic> response = await api.fetchTopics(limit: 3);

    print('✓ 成功獲取專題列表');
    print('  狀態: ${response.status}');
    print('  總數: ${response.data.meta.total}');
    print('  當前頁數量: ${response.data.records.length}');

    if (response.data.records.isNotEmpty) {
      final dynamic firstTopic = response.data.records.first;
      print('\n  第一個專題:');
      print('    標題: ${firstTopic.title}');
      print('    Slug: ${firstTopic.slug}');
    }
  } catch (e, stackTrace) {
    print('✗ 錯誤: $e');
    print('堆疊追蹤:\n$stackTrace');
  }
}

Future<void> testFetchIndexPage(TwReporterApi api) async {
  print('\n🏠 測試首頁內容 API');
  print('-' * 60);

  try {
    final response = await api.fetchIndexPage();

    print('✓ 成功獲取首頁內容');
    print('  狀態: ${response.status}');

    final data = response.data;
    print('\n  內容區塊:');
    print('    編輯精選: ${data.editorPicksSection?.length ?? 0} 篇');
    print('    最新文章: ${data.latestSection?.length ?? 0} 篇');
    print('    最新專題: ${data.latestTopicSection?.length ?? 0} 個');
    print('    專題區塊: ${data.topicsSection?.length ?? 0} 個');
    print('    評論: ${data.reviewsSection?.length ?? 0} 篇');
    print('    攝影: ${data.photosSection?.length ?? 0} 篇');
    print('    多媒體: ${data.infographicsSection?.length ?? 0} 篇');
  } catch (e, stackTrace) {
    print('✗ 錯誤: $e');
    print('堆疊追蹤:\n$stackTrace');
  }
}

Future<void> testFetchPost(TwReporterApi api) async {
  print('\n📄 測試文章詳情 API');
  print('-' * 60);

  try {
    // 先獲取第一篇文章的 slug
    final ListResponse<dynamic> listResponse =
        await api.fetchPosts(limit: 1);

    if (listResponse.data.records.isEmpty) {
      print('✗ 沒有文章可供測試');
      return;
    }

    final dynamic firstArticle = listResponse.data.records.first;
    final slug = firstArticle.slug as String;

    print('  測試文章 Slug: $slug');

    final ApiResponse<dynamic> response = await api.fetchPost(slug);

    print('✓ 成功獲取文章詳情');
    print('  狀態: ${response.status}');

    final dynamic article = response.data;
    print('\n  文章詳細資訊:');
    print('    標題: ${article.title}');
    print('    副標題: ${article.subtitle ?? '(無)'}');
    print('    分類數: ${article.categorySet?.length ?? 0}');
    print('    標籤數: ${article.tags?.length ?? 0}');
  } catch (e, stackTrace) {
    print('✗ 錯誤: $e');
    print('堆疊追蹤:\n$stackTrace');
  }
}
