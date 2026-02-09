import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/cache/app_cache_manager.dart';
import 'package:tw_reporter_app/core/di/injection_keys.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/features/my_reading/logic/use_reading_data.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';

@RoutePage()
class MyReadingPage extends StatelessWidget {
  const MyReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MyReadingPageContent();
  }
}

class _MyReadingPageContent extends CompositionWidget {
  const _MyReadingPageContent();

  @override
  Widget Function(BuildContext) setup() {
    final repo = inject(AppKeys.readingRepository);
    final readingData = useReadingData(repo);
    final theme = useTheme();

    Widget buildRecordTile(BuildContext context, ReadingRecord record) {
      return ListTile(
        contentPadding: AppSpacing.edgeInsetsListItem,
        leading: record.imageUrl != null
            ? ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusSm),
                child: CachedNetworkImage(
                  imageUrl: record.imageUrl!,
                  cacheManager:
                      AppCacheManager.instance.imageCacheManager,
                  width: 64,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 64,
                    height: 48,
                    color: AppColors.grey200,
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 64,
                    height: 48,
                    color: AppColors.grey200,
                    child: const Icon(Icons.image_not_supported,
                        size: 20, color: AppColors.grey400),
                  ),
                ),
              )
            : null,
        title: Text(
          record.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          formatDate(record.timestamp),
          style: Theme.of(context).textTheme.timestamp,
        ),
        onTap: () {
          unawaited(context.router.push(ArticleRoute(
            slug: record.slug,
            heroImageUrl: record.imageUrl,
          )));
        },
      );
    }

    Widget buildHistoryTab() {
      final history = readingData.history.value;

      if (history.isEmpty) {
        return const EmptyState(
          message: '尚無閱讀記錄\n瀏覽文章後會自動記錄',
          icon: Icons.history,
        );
      }

      return ListView.separated(
        padding: AppSpacing.edgeInsetsSm,
        itemCount: history.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final record = history[index];
          return buildRecordTile(context, record);
        },
      );
    }

    Widget buildBookmarksTab() {
      final bookmarks = readingData.bookmarks.value;

      if (bookmarks.isEmpty) {
        return const EmptyState(
          message: '尚無收藏文章\n在文章頁面點擊愛心收藏',
          icon: Icons.favorite_border,
        );
      }

      return ListView.separated(
        padding: AppSpacing.edgeInsetsSm,
        itemCount: bookmarks.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final record = bookmarks[index];
          return Dismissible(
            key: ValueKey<String>('bookmark-${record.slug}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding:
                  const EdgeInsets.only(right: AppSpacing.md),
              color: AppColors.accent,
              child:
                  const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              readingData.removeBookmark(record.slug);
            },
            child: buildRecordTile(context, record),
          );
        },
      );
    }

    return (BuildContext context) {
      // Read theme to establish reactive tracking for theme changes
      final _ = theme.value;
      if (readingData.isLoading.value) {
        return Scaffold(
          appBar: AppBar(title: const Text('我的閱讀')),
          body: const LoadingIndicator(),
        );
      }

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('我的閱讀'),
            bottom: const TabBar(
              tabs: <Tab>[
                Tab(text: '閱讀記錄'),
                Tab(text: '收藏'),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  unawaited(context.router.push(
                    const SettingsRoute(),
                  ));
                },
              ),
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              buildHistoryTab(),
              buildBookmarksTab(),
            ],
          ),
        ),
      );
    };
  }
}
