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
    String? subcategoryId,
  }) async {
    final categoryId = _categorySlugToId[category.toLowerCase()];
    if (categoryId == null) return <Article>[];

    final offset = (page - 1) * limit;
    final response = await _api.fetchPosts(
      limit: limit,
      offset: offset,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
    );
    return response.data.records;
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
    final offset = (page - 1) * limit;
    final response = await _api.fetchPosts(
      limit: limit,
      offset: offset,
      tagId: tagId,
    );
    return response.data.records;
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

  /// 分類 slug → MongoDB ObjectId 映射
  static const _categorySlugToId = <String, String>{
    'culture': '63206383207bf7c5f8716259',
    'econ': '63206383207bf7c5f8716254',
    'education': '63206383207bf7c5f8716260',
    'environment': '63206383207bf7c5f871624d',
    'health': '63206383207bf7c5f8716245',
    'humanrights': '63206383207bf7c5f8716234',
    'politics_and_society': '63206383207bf7c5f871623d',
    'world': '63206383207bf7c5f871622c',
  };
}
