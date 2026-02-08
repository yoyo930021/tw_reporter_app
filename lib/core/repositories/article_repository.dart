import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/author.dart';

/// 文章資料存取抽象介面
abstract class ArticleRepository {
  /// 獲取最新文章列表
  Future<List<Article>> fetchLatest({
    required int page,
    int limit = 10,
  });

  /// 獲取分類文章列表
  Future<List<Article>> fetchByCategory({
    required String category,
    required int page,
    int limit = 10,
  });

  /// 搜尋文章
  Future<List<Article>> search({
    required String query,
    required int page,
  });

  /// 獲取單篇文章詳情
  Future<Article> fetchById({required String slug});

  /// 根據 ID 列表獲取文章
  Future<List<Article>> fetchByIds(List<String> ids);

  /// 獲取標籤相關文章（客戶端過濾）
  Future<List<Article>> fetchByTag({
    required String tagId,
    required int page,
    int limit = 10,
  });

  /// 獲取作者相關文章（客戶端過濾）
  Future<List<Article>> fetchByAuthor({
    required String authorId,
    required int page,
    int limit = 10,
  });

  /// 獲取作者列表
  Future<List<Author>> fetchAuthors({
    required int page,
    int limit = 20,
  });
}
