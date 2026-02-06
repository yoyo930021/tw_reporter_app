import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/api/tw_reporter_api.dart';
import 'package:tw_reporter_app/core/models/topic.dart';
import 'package:tw_reporter_app/core/router/app_router.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/features/home/presentation/home_page.dart';
import 'package:tw_reporter_app/features/topics/logic/use_topics.dart';
import 'package:tw_reporter_app/shared/widgets/empty_state.dart';
import 'package:tw_reporter_app/shared/widgets/loading_indicator.dart';
import 'package:tw_reporter_app/shared/widgets/topic_card.dart';

@RoutePage()
class TopicsPage extends StatelessWidget {
  const TopicsPage({this.api, super.key});

  final TwReporterApi? api;

  @override
  Widget build(BuildContext context) {
    final apiInstance = api ?? ApiProvider.of(context).api;
    return _TopicsPageContent(api: apiInstance);
  }
}

class _TopicsPageContent extends CompositionWidget {
  const _TopicsPageContent({required this.api});

  final TwReporterApi api;

  @override
  Widget Function(BuildContext) setup() {
    final TopicsResult topics = useTopics(api);

    final ReadonlyRef<ScrollController> scrollControllerRef =
        useScrollController();

    watchEffect(() {
      final ScrollController scrollController = scrollControllerRef.value;
      if (scrollController.hasClients) {
        final double position = scrollController.position.pixels;
        final double maxScroll = scrollController.position.maxScrollExtent;

        if (position >= maxScroll - 200 &&
            topics.hasMore.value &&
            !topics.isLoading.value) {
          topics.loadMore();
        }
      }
    });

    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('專題'),
          ),
          body: _buildBody(topics, scrollControllerRef.value),
        );
  }

  Widget _buildBody(TopicsResult topics, ScrollController scrollController) {
    if (topics.isLoading.value && topics.topics.value.isEmpty) {
      return const LoadingIndicator();
    }

    if (topics.topics.value.isEmpty) {
      return const EmptyState(message: '目前沒有專題');
    }

    return RefreshIndicator(
      onRefresh: topics.refresh,
      child: ListView.builder(
        controller: scrollController,
        itemCount:
            topics.topics.value.length + (topics.hasMore.value ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index == topics.topics.value.length) {
            return Padding(
              padding: AppSpacing.edgeInsetsMd,
              child: Center(
                child: Text('載入更多...', style: AppTextStyles.caption),
              ),
            );
          }

          final Topic topic = topics.topics.value[index];
          return TopicCard(
            topic: topic,
            onTap: () {
              context.router.push(TopicDetailRoute(
                slug: topic.slug,
                topic: topic,
              ));
            },
          );
        },
      ),
    );
  }
}
