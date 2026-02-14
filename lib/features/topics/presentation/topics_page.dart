import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/composables.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/features/topics/logic/use_topics.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';
import 'package:tw_reporter_app/shared/widgets/topic_card.dart';

@RoutePage()
class TopicsPage extends StatelessWidget {
  const TopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TopicsPageContent();
  }
}

class _TopicsPageContent extends CompositionWidget {
  const _TopicsPageContent();

  @override
  Widget Function(BuildContext) setup() {
    final repo = useTopicRepository();
    final topics = useTopics(repo);
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
            topics.hasMore.value &&
            !topics.isLoading.value) {
          unawaited(topics.loadMore());
        }
      }
    });

    Widget buildBody() {
      if (topics.isLoading.value &&
          topics.topics.value.isEmpty) {
        return const LoadingIndicator();
      }

      if (topics.topics.value.isEmpty) {
        return const EmptyState(message: '目前沒有專題');
      }

      return RefreshIndicator(
        onRefresh: topics.refresh,
        child: ListView.builder(
          controller: scrollControllerRef.raw,
          itemCount: topics.topics.value.length +
              (topics.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == topics.topics.value.length) {
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

            final topic = topics.topics.value[index];
            return TopicCard(
              topic: topic,
              onTap: () {
                unawaited(
                  context.router.push(
                    TopicDetailRoute(
                      slug: topic.slug,
                      topic: topic,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('專題'),
          ),
          body: buildBody(),
        );
  }
}
