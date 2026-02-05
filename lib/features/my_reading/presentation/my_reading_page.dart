import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';

@RoutePage()
class MyReadingPage extends CompositionWidget {
  const MyReadingPage({super.key});

  @override
  Widget Function(BuildContext) setup() {
    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('我的閱讀'),
          ),
          body: const Center(
            child: Text('我的閱讀紀錄'),
          ),
        );
  }
}
