import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';

@RoutePage()
class LatestPage extends CompositionWidget {
  const LatestPage({super.key});

  @override
  Widget Function(BuildContext) setup() {
    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('最新文章'),
          ),
          body: const Center(
            child: Text('最新文章列表'),
          ),
        );
  }
}
