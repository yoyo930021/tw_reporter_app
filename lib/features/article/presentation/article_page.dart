import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';

@RoutePage()
class ArticlePage extends CompositionWidget {
  const ArticlePage({
    super.key,
    @PathParam('slug') required this.slug,
  });

  final String slug;

  @override
  Widget Function(BuildContext) setup() {
    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('文章詳情'),
          ),
          body: Center(
            child: Text('文章: $slug'),
          ),
        );
  }
}
