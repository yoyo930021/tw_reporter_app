import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/author.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';

/// 報導者 API 文章資料存取實作
class TwReporterArticleRepository implements ArticleRepository {
  TwReporterArticleRepository(this._api);

  final TwReporterApi _api;

  @override
  Future<List<Article>> fetchLatest({
    required int page,
    int limit = 10,
  }) async {
    final offset = (page - 1) * limit;
    final response = await _api.fetchPosts(
      limit: limit,
      offset: offset,
    );
    return response.data.records;
  }

  @override
  Future<List<Article>> fetchByCategory({
    required String category,
    required int page,
    int limit = 10,
  }) async {
    // 由於 API 不支援分類過濾，需要獲取更多文章再客戶端過濾
    // TODO(API): 待後端 API 支援分類過濾功能後改用伺服器端過濾
    final fetchLimit = limit * 8;
    final offset = (page - 1) * fetchLimit;

    final response = await _api.fetchPosts(
      limit: fetchLimit,
      offset: offset,
    );

    final mappedName = _mapCategoryNameToApiName(category).toLowerCase();
    final lowerCategory = category.toLowerCase();

    return response.data.records.where((article) {
      return article.categorySet.any((cs) {
        final name = cs.category?.name;
        if (name == null) return false;
        final lowerName = name.toLowerCase();
        return lowerName == mappedName || lowerName == lowerCategory;
      });
    }).take(limit).toList();
  }

  @override
  Future<List<Article>> search({
    required String query,
    required int page,
  }) async {
    // 由於 API 不支援搜尋，需要客戶端搜尋
    // TODO(API): 待後端 API 支援搜尋功能後改用伺服器端搜尋
    const limit = 50;
    final offset = (page - 1) * limit;

    final response = await _api.fetchPosts(
      limit: limit,
      offset: offset,
    );

    final lowerQuery = query.toLowerCase();
    return response.data.records.where((article) {
      return article.title
              .toLowerCase()
              .contains(lowerQuery) ||
          article.ogDescription
              .toLowerCase()
              .contains(lowerQuery) ||
          (article.subtitle
                  ?.toLowerCase()
                  .contains(lowerQuery) ??
              false);
    }).toList();
  }

  @override
  Future<Article> fetchById({required String slug}) async {
    final response = await _api.fetchPost(slug);
    return response.data;
  }

  @override
  Future<List<Article>> fetchByIds(List<String> ids) async {
    if (ids.isEmpty) return <Article>[];

    final response = await _api.fetchPosts(
      limit: ids.length,
      ids: ids,
    );
    return response.data.records;
  }

  @override
  Future<List<Article>> fetchByTag({
    required String tagId,
    required int page,
    int limit = 10,
  }) async {
    // 客戶端過濾：獲取大量文章後篩選含有指定 tag 的文章
    // TODO(API): 待後端 API 支援 tag 過濾後改用伺服器端過濾
    final fetchLimit = limit * 8;
    final offset = (page - 1) * fetchLimit;

    final response = await _api.fetchPosts(
      limit: fetchLimit,
      offset: offset,
    );

    return response.data.records.where((article) {
      return article.tags?.any((tag) => tag.id == tagId) ?? false;
    }).take(limit).toList();
  }

  @override
  Future<List<Article>> fetchByAuthor({
    required String authorId,
    required int page,
    int limit = 10,
  }) async {
    final offset = (page - 1) * limit;
    final response = await _api.fetchAuthorPosts(
      authorId,
      limit: limit,
      offset: offset,
    );
    return response.data.records;
  }

  @override
  Future<List<Author>> fetchAuthors({
    required int page,
    int limit = 20,
  }) async {
    final offset = (page - 1) * limit;
    final response = await _api.fetchAuthors(
      limit: limit,
      offset: offset,
    );
    return response.data.records;
  }

  String _mapCategoryNameToApiName(String category) {
    const categoryMap = <String, String>{
      'culture': '文化生活',
      'econ': '經濟產業',
      'education': '教育校園',
      'environment': '環境永續',
      'health': '醫療健康',
      'humanrights': '人權司法',
      'politics_and_society': '政治社會',
      'world': '國際兩岸',
    };
    return categoryMap[category.toLowerCase()] ?? category;
  }
}
