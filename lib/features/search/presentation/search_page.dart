import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:intl/intl.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/article.dart';
import 'package:tw_reporter_app/features/search/logic/use_search.dart';

@RoutePage()
class SearchPage extends CompositionWidget {
  const SearchPage({
    this.api,
    super.key,
  });

  final TwReporterApi? api;

  @override
  Widget Function(BuildContext) setup() {
    // 使用 useSearch composable 取得搜尋功能
    final SearchResult search = useSearch(api!);

    // 文字編輯控制器
    final (
      TextEditingController textController,
      WritableRef<String> _,
      WritableRef<TextEditingValue> __,
    ) = useTextEditingController();

    // 捲動控制器，用於檢測是否滾動到底部
    final ReadonlyRef<ScrollController> scrollControllerRef =
        useScrollController();

    // 監聽滾動事件，當接近底部時載入更多
    watchEffect(() {
      final ScrollController scrollController = scrollControllerRef.value;
      if (scrollController.hasClients) {
        final double position = scrollController.position.pixels;
        final double maxScroll = scrollController.position.maxScrollExtent;

        // 當滾動到距離底部 200 像素時，載入更多
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
              // 搜尋輸入框
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: '請輸入關鍵字',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: search.setQuery,
                ),
              ),

              // 搜尋結果
              Expanded(
                child: _buildBody(search, scrollControllerRef.value),
              ),
            ],
          ),
        );
  }

  Widget _buildBody(SearchResult search, ScrollController scrollController) {
    // 載入中狀態（且沒有結果時）
    if (search.isSearching.value && search.articles.value.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 初始空狀態（還沒搜尋）
    if (search.query.value.isEmpty) {
      return const Center(
        child: Text('請輸入關鍵字開始搜尋'),
      );
    }

    // 搜尋完成但沒有結果
    if (search.articles.value.isEmpty) {
      return const Center(
        child: Text('找不到相關文章'),
      );
    }

    // 顯示搜尋結果
    return ListView.builder(
      controller: scrollController,
      itemCount: search.articles.value.length + (search.hasMore.value ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        // 載入更多指示器
        if (index == search.articles.value.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text('載入更多...'),
            ),
          );
        }

        final Article article = search.articles.value[index];
        return _buildArticleItem(article);
      },
    );
  }

  Widget _buildArticleItem(Article article) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: 導航到文章詳情頁
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 文章標題
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 文章描述
              Text(
                article.ogDescription,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 發布日期
              Text(
                _formatDate(article.publishedDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy年MM月dd日');
    return formatter.format(date);
  }
}
