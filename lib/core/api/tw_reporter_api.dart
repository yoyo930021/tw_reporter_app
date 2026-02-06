import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';

part 'tw_reporter_api.g.dart';

/// 報導者 API 響應格式
class ApiResponse<T> {
  final T data;
  final String status;

  const ApiResponse({
    required this.data,
    required this.status,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return ApiResponse<T>(
      data: fromJsonT(json['data'])!,
      status: json['status'] as String,
    );
  }
}

/// 列表 API 響應格式
class ListResponse<T> {
  final ListData<T> data;
  final String status;

  const ListResponse({
    required this.data,
    required this.status,
  });

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return ListResponse<T>(
      data: ListData<T>.fromJson(
        json['data'] as Map<String, dynamic>,
        fromJsonT,
      ),
      status: json['status'] as String,
    );
  }
}

/// 列表資料格式
class ListData<T> {
  final ListMeta meta;
  final List<T> records;

  const ListData({
    required this.meta,
    required this.records,
  });

  factory ListData.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return ListData<T>(
      meta: ListMeta.fromJson(json['meta'] as Map<String, dynamic>),
      records: (json['records'] as List<dynamic>)
          .map((dynamic e) => fromJsonT(e)!)
          .toList(),
    );
  }
}

/// 列表元資料
class ListMeta {
  final int limit;
  final int offset;
  final int total;

  const ListMeta({
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory ListMeta.fromJson(Map<String, dynamic> json) {
    return ListMeta(
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      total: json['total'] as int,
    );
  }
}

/// 首頁內容響應格式
class IndexPageData {
  final List<Article>? editorPicksSection;
  final List<Article>? latestSection;
  final List<Topic>? latestTopicSection;
  final List<Topic>? topicsSection;
  final List<Article>? reviewsSection;
  final List<Article>? photosSection;
  final List<Article>? infographicsSection;
  final List<Article>? culture;
  final List<Article>? econ;
  final List<Article>? education;
  final List<Article>? environment;
  final List<Article>? health;
  final List<Article>? humanrights;
  final List<Article>? politicsAndSociety;
  final List<Article>? world;

  const IndexPageData({
    this.editorPicksSection,
    this.latestSection,
    this.latestTopicSection,
    this.topicsSection,
    this.reviewsSection,
    this.photosSection,
    this.infographicsSection,
    this.culture,
    this.econ,
    this.education,
    this.environment,
    this.health,
    this.humanrights,
    this.politicsAndSociety,
    this.world,
  });

  factory IndexPageData.fromJson(Map<String, dynamic> json) {
    return IndexPageData(
      editorPicksSection: (json['editor_picks_section'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      latestSection: (json['latest_section'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      latestTopicSection: (json['latest_topic_section'] as List<dynamic>?)
          ?.map((dynamic e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
      topicsSection: (json['topics_section'] as List<dynamic>?)
          ?.map((dynamic e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviewsSection: (json['reviews_section'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      photosSection: (json['photos_section'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      infographicsSection: (json['infographics_section'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      culture: (json['culture'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      econ: (json['econ'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: (json['education'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      environment: (json['environment'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      health: (json['health'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      humanrights: (json['humanrights'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      politicsAndSociety: (json['politics_and_society'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
      world: (json['world'] as List<dynamic>?)
          ?.map((dynamic e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

@RestApi(baseUrl: 'https://go-api.twreporter.org/v2')
abstract class TwReporterApi {
  factory TwReporterApi(Dio dio, {String? baseUrl}) = _TwReporterApi;

  /// 獲取文章列表
  ///
  /// [limit] 每頁文章數量，預設 10
  /// [offset] 偏移量，用於分頁
  /// [ids] 文章 ID 列表（用於按 ID 過濾）
  @GET('/posts')
  Future<ListResponse<Article>> fetchPosts({
    @Query('limit') int limit = 10,
    @Query('offset') int offset = 0,
    @Query('id') List<String>? ids,
  });

  /// 獲取單篇文章詳情
  ///
  /// [slug] 文章的 slug（唯一識別符）
  /// [full] 是否取得完整內容（含 content、brief 等欄位）
  @GET('/posts/{slug}')
  Future<ApiResponse<Article>> fetchPost(
    @Path('slug') String slug, {
    @Query('full') bool full = true,
  });

  /// 獲取專題列表
  ///
  /// [limit] 每頁專題數量，預設 10
  /// [offset] 偏移量，用於分頁
  @GET('/topics')
  Future<ListResponse<Topic>> fetchTopics({
    @Query('limit') int limit = 10,
    @Query('offset') int offset = 0,
  });

  /// 獲取首頁內容
  ///
  /// 返回包含所有首頁區塊的聚合資料
  @GET('/index_page')
  Future<ApiResponse<IndexPageData>> fetchIndexPage();
}

/// TwReporterApi 擴充方法：提供便利的 wrapper 方法
extension TwReporterApiExtensions on TwReporterApi {
  /// 獲取最新文章列表（wrapper method）
  ///
  /// [page] 頁碼（從 1 開始）
  /// [limit] 每頁文章數量
  Future<List<Article>> fetchLatestArticles({
    required int page,
    int limit = 10,
  }) async {
    final int offset = (page - 1) * limit;
    final ListResponse<Article> response = await fetchPosts(
      limit: limit,
      offset: offset,
    );
    return response.data.records;
  }

  /// 獲取分類文章列表（wrapper method）
  ///
  /// 注意：此方法使用客戶端過濾，效率較低
  /// TODO(API): 待後端 API 支援分類過濾功能後改用伺服器端過濾
  ///
  /// [category] 分類名稱（如 'world', 'econ' 等）
  /// [page] 頁碼（從 1 開始）
  /// [limit] 每頁文章數量
  Future<List<Article>> fetchCategoryArticles({
    required String category,
    required int page,
    int limit = 10,
  }) async {
    // 由於 API 不支援分類過濾，我們需要獲取更多文章然後客戶端過濾
    // 假設需要的文章數是請求數的 3 倍（因為有 8 個分類）
    final int fetchLimit = limit * 8;
    final int offset = (page - 1) * fetchLimit;

    final ListResponse<Article> response = await fetchPosts(
      limit: fetchLimit,
      offset: offset,
    );

    // 客戶端過濾分類
    final List<Article> filteredArticles =
        response.data.records.where((Article article) {
      // 檢查 category_set 中是否有匹配的分類
      return article.categorySet.any((dynamic cs) {
        // ignore: avoid_dynamic_calls
        final String? name = cs.category?.name as String?;
        if (name == null) return false;
        return name.toLowerCase() ==
                _mapCategoryNameToApiName(category).toLowerCase() ||
            name.toLowerCase() == category.toLowerCase();
      });
    }).take(limit).toList();

    return filteredArticles;
  }

  /// 搜尋文章（wrapper method）
  ///
  /// 注意：此方法使用客戶端搜尋，效率較低
  /// TODO(API): 待後端 API 支援搜尋功能後改用伺服器端搜尋
  ///
  /// [query] 搜尋關鍵字
  /// [page] 頁碼（從 1 開始）
  Future<List<Article>> searchArticles({
    required String query,
    required int page,
  }) async {
    // 由於 API 不支援搜尋，我們需要獲取較多文章然後客戶端搜尋
    const int limit = 50; // 每次獲取 50 篇文章進行搜尋
    final int offset = (page - 1) * limit;

    final ListResponse<Article> response = await fetchPosts(
      limit: limit,
      offset: offset,
    );

    // 客戶端搜尋
    final String lowerQuery = query.toLowerCase();
    final List<Article> searchResults =
        response.data.records.where((Article article) {
      return article.title.toLowerCase().contains(lowerQuery) ||
          article.ogDescription.toLowerCase().contains(lowerQuery) ||
          (article.subtitle?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    return searchResults;
  }

  /// 獲取專題列表（wrapper method with page-based pagination）
  ///
  /// [page] 頁碼（從 1 開始）
  /// [limit] 每頁專題數量
  Future<List<Topic>> fetchTopicsByPage({
    required int page,
    int limit = 10,
  }) async {
    final int offset = (page - 1) * limit;
    final ListResponse<Topic> response = await fetchTopics(
      limit: limit,
      offset: offset,
    );
    return response.data.records;
  }

  /// 根據 ID 列表獲取文章（wrapper method）
  ///
  /// 使用 GET /posts?id=xxx&id=yyy 批次查詢
  ///
  /// [ids] 文章 ID 列表
  Future<List<Article>> fetchArticlesByIds(List<String> ids) async {
    if (ids.isEmpty) return <Article>[];

    final ListResponse<Article> response = await fetchPosts(
      limit: ids.length,
      ids: ids,
    );
    return response.data.records;
  }

  /// 映射分類名稱到 API 名稱
  String _mapCategoryNameToApiName(String category) {
    const Map<String, String> categoryMap = <String, String>{
      'culture': '文化',
      'econ': '經濟產業',
      'education': '教育',
      'environment': '環境',
      'health': '健康',
      'humanrights': '人權司法',
      'politics_and_society': '政治社會',
      'world': '國際',
    };
    return categoryMap[category.toLowerCase()] ?? category;
  }
}
