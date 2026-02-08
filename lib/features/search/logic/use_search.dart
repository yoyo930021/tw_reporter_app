import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/repositories/article_repository.dart';
import 'package:tw_reporter_app/shared/composables/use_debounce.dart';

/// 搜尋結果類型
typedef SearchResult = ({
  Ref<String> query,
  Ref<List<Article>> articles,
  Ref<bool> isSearching,
  Ref<bool> hasMore,
  void Function(String) setQuery,
  Future<void> Function() loadMore,
});

/// 搜尋 Composable
SearchResult useSearch(
  ArticleRepository repo, {
  int debounceMs = 500,
  int pageSize = 10,
}) {
  final query = ref<String>('');
  final articles = ref<List<Article>>(<Article>[]);
  final isSearching = ref<bool>(false);
  final hasMore = ref<bool>(false);
  final currentPage = ref<int>(1);

  final debouncedSearch = useDebounce(
    () async {
      final searchQuery = query.value.trim();

      if (searchQuery.isEmpty) {
        articles.value = <Article>[];
        hasMore.value = false;
        return;
      }

      isSearching.value = true;
      currentPage.value = 1;

      try {
        final results = await repo.search(
          query: searchQuery,
          page: 1,
        );

        articles.value = results;
        hasMore.value = results.length >= pageSize;
      } on Object {
        articles.value = <Article>[];
        hasMore.value = false;
        rethrow;
      } finally {
        isSearching.value = false;
      }
    },
    delay: Duration(milliseconds: debounceMs),
  );

  void setQuery(String newQuery) {
    query.value = newQuery;
    debouncedSearch();
  }

  Future<void> loadMore() async {
    final searchQuery = query.value.trim();

    if (isSearching.value ||
        !hasMore.value ||
        searchQuery.isEmpty) {
      return;
    }

    isSearching.value = true;
    final nextPage = currentPage.value + 1;

    try {
      final newResults = await repo.search(
        query: searchQuery,
        page: nextPage,
      );

      articles.value = <Article>[
        ...articles.value,
        ...newResults,
      ];
      currentPage.value = nextPage;
      hasMore.value = newResults.length >= pageSize;
    } finally {
      isSearching.value = false;
    }
  }

  return (
    query: query,
    articles: articles,
    isSearching: isSearching,
    hasMore: hasMore,
    setQuery: setQuery,
    loadMore: loadMore,
  );
}
