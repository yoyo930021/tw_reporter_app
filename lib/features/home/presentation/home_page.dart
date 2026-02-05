import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';

@RoutePage()
class HomePage extends CompositionWidget {
  const HomePage({super.key});

  @override
  Widget Function(BuildContext) setup() {
    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: const Text('報導者'),
          ),
          body: const Center(
            child: Text('首頁'),
          ),
        );
  }
}
