import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/storage/reading_storage.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_theme.dart';
import 'package:tw_reporter_app/shared/composables/use_reading.dart';
import 'package:tw_reporter_app/shared/utils/date_formatter.dart';
import 'package:tw_reporter_app/shared/widgets/cached_image.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';

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
    final reading = useReading();

    return (BuildContext context) => DefaultTabController(
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
            _HistoryTab(reading: reading),
            _BookmarksTab(reading: reading),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// Private widget: History tab
// -------------------------------------------------------------------

class _HistoryTab extends CompositionWidget {
  const _HistoryTab({required this.reading});

  final UseReadingResult reading;

  @override
  Widget Function(BuildContext) setup() {
    final history = computed(() => reading.history.value);

    final isEmpty = computed(() => history.value.isEmpty);

    return (BuildContext context) => isEmpty.value
        ? const EmptyState(
            message: '尚無閱讀記錄\n瀏覽文章後會自動記錄',
            icon: Icons.history,
          )
        : ListView.separated(
            padding: AppSpacing.edgeInsetsSm,
            itemCount: history.value.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1),
            itemBuilder: (context, index) =>
                _RecordTile(record: history.value[index]),
          );
  }
}

// -------------------------------------------------------------------
// Private widget: Bookmarks tab
// -------------------------------------------------------------------

class _BookmarksTab extends CompositionWidget {
  const _BookmarksTab({required this.reading});

  final UseReadingResult reading;

  @override
  Widget Function(BuildContext) setup() {
    final bookmarks = computed(() => reading.bookmarks.value);
    final isEmpty = computed(() => bookmarks.value.isEmpty);

    return (BuildContext context) => isEmpty.value
        ? const EmptyState(
            message: '尚無收藏文章\n在文章頁面點擊愛心收藏',
            icon: Icons.favorite_border,
          )
        : ListView.separated(
            padding: AppSpacing.edgeInsetsSm,
            itemCount: bookmarks.value.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = bookmarks.value[index];
              return _DismissibleBookmark(
                record: record,
                onDismissed: () =>
                    reading.removeBookmark(record.slug),
              );
            },
          );
  }
}

// -------------------------------------------------------------------
// Private widget: Dismissible bookmark
// -------------------------------------------------------------------

class _DismissibleBookmark extends StatelessWidget {
  const _DismissibleBookmark({
    required this.record,
    required this.onDismissed,
  });

  final ReadingRecord record;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<String>('bookmark-${record.slug}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding:
            const EdgeInsets.only(right: AppSpacing.md),
        color: AppColors.accent,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismissed(),
      child: _RecordTile(record: record),
    );
  }
}

// -------------------------------------------------------------------
// Private widget: Record tile
// -------------------------------------------------------------------

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final ReadingRecord record;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: AppSpacing.edgeInsetsListItem,
      leading: record.imageUrl != null
          ? ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
              child: CachedImage(
                imageUrl: record.imageUrl!,
                width: 64,
                height: 48,
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
}
