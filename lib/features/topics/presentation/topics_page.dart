import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';

@RoutePage()
class TopicsPage extends CompositionWidget {
  const TopicsPage({super.key});

  @override
  Widget Function(BuildContext) setup() {
    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('專題'),
          ),
          body: const Center(
            child: Text('專題列表'),
          ),
        );
  }
}
