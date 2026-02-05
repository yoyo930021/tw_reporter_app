import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/models/topic.dart';

part 'tw_reporter_api.g.dart';

@RestApi(baseUrl: 'https://www.twreporter.org')
abstract class TwReporterApi {
  factory TwReporterApi(Dio dio, {String? baseUrl}) = _TwReporterApi;

  @GET('/api/articles')
  Future<List<Article>> fetchLatestArticles({
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('/api/articles/{slug}')
  Future<Article> fetchArticle(@Path('slug') String slug);

  @GET('/api/articles')
  Future<List<Article>> fetchCategoryArticles({
    @Query('category') required String category,
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });

  @GET('/api/featured')
  Future<List<Article>> fetchFeaturedArticles();

  @GET('/api/topics')
  Future<List<Topic>> fetchTopics({
    @Query('page') int page = 1,
  });

  @GET('/api/search')
  Future<List<Article>> searchArticles({
    @Query('q') required String query,
    @Query('page') int page = 1,
  });
}
