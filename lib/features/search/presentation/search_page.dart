import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/injection_keys.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/features/search/logic/use_search.dart';
import 'package:tw_reporter_app/shared/widgets/article_card.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';

@RoutePage()
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SearchPageContent();
  }
}

class _SearchPageContent extends CompositionWidget {
  const _SearchPageContent();

  @override
  Widget Function(BuildContext) setup() {
    final repo = inject(AppKeys.articleRepository);
    final search = useSearch(repo);

    final (
      TextEditingController textController,
      WritableRef<String> _,
      WritableRef<TextEditingValue> _,
    ) = useTextEditingController();

    final theme = useTheme();

    final scrollControllerRef = useScrollController();

    watchEffect(() {
      final scrollController = scrollControllerRef.value;
      if (scrollController.hasClients) {
        final position =
            scrollController.position.pixels;
        final maxScroll =
            scrollController.position.maxScrollExtent;

        if (position >= maxScroll - 200 &&
            search.hasMore.value &&
            !search.isSearching.value &&
            search.query.value.isNotEmpty) {
          unawaited(search.loadMore());
        }
      }
    });

    Widget buildBody() {
      if (search.isSearching.value &&
          search.articles.value.isEmpty) {
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
        controller: scrollControllerRef.raw,
        itemCount: search.articles.value.length +
            (search.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == search.articles.value.length) {
            return Padding(
              padding: AppSpacing.edgeInsetsMd,
              child: Center(
                child: Text(
                  '載入更多...',
                  style: theme.value.textTheme.bodySmall,
                ),
              ),
            );
          }

          final article = search.articles.value[index];
          return ArticleCard(
            article: article,
            onTap: () {
              unawaited(
                context.router.push(
                  ArticleRoute(
                    slug: article.slug,
                    heroImageUrl:
                        ArticleCard.getArticleImageUrl(
                      article,
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

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
                child: buildBody(),
              ),
            ],
          ),
        );
  }
}
