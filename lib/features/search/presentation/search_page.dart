import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/features/search/logic/use_search.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';

@RoutePage()
class SearchPage extends StatelessWidget {
  const SearchPage({this.api, super.key});

  final TwReporterApi? api;

  @override
  Widget build(BuildContext context) {
    final apiInstance = api ?? ApiProvider.of(context).api;
    return _SearchPageContent(api: apiInstance);
  }
}

class _SearchPageContent extends CompositionWidget {
  const _SearchPageContent({required this.api});

  final TwReporterApi api;

  @override
  Widget Function(BuildContext) setup() {
    final SearchResult search = useSearch(api);

    final (
      TextEditingController textController,
      WritableRef<String> _,
      WritableRef<TextEditingValue> __,
    ) = useTextEditingController();

    final ReadonlyRef<ScrollController> scrollControllerRef =
        useScrollController();

    watchEffect(() {
      final ScrollController scrollController = scrollControllerRef.value;
      if (scrollController.hasClients) {
        final double position = scrollController.position.pixels;
        final double maxScroll = scrollController.position.maxScrollExtent;

        if (position >= maxScroll - 200 &&
            search.hasMore.value &&
            !search.isSearching.value &&
            search.query.value.isNotEmpty) {
          search.loadMore();
        }
      }
    });

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('搜尋'),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: AppSpacing.edgeInsetsMd,
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: '請輸入關鍵字',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: search.setQuery,
                ),
              ),

              Expanded(
                child: _buildBody(search, scrollControllerRef.value),
              ),
            ],
          ),
        );
  }

  Widget _buildBody(SearchResult search, ScrollController scrollController) {
    if (search.isSearching.value && search.articles.value.isEmpty) {
      return const LoadingIndicator();
    }

    if (search.query.value.isEmpty) {
      return const EmptyState(
        message: '請輸入關鍵字開始搜尋',
        icon: Icons.search,
      );
    }

    if (search.articles.value.isEmpty) {
      return const EmptyState(
        message: '找不到相關文章',
        icon: Icons.search_off,
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount:
          search.articles.value.length + (search.hasMore.value ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index == search.articles.value.length) {
          return Padding(
            padding: AppSpacing.edgeInsetsMd,
            child: Center(
              child: Text('載入更多...', style: AppTextStyles.caption),
            ),
          );
        }

        final Article article = search.articles.value[index];
        return ArticleCard(
          article: article,
          onTap: () {
            context.router.push(ArticleRoute(
              slug: article.slug,
              heroImageUrl: ArticleCard.getArticleImageUrl(article),
            ));
          },
        );
      },
    );
  }
}
