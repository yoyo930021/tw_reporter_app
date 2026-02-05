import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';

@RoutePage()
class CategoryPage extends CompositionWidget {
  const CategoryPage({
    super.key,
    @PathParam('category') required this.category,
  });

  final String category;

  @override
  Widget Function(BuildContext) setup() {
    return (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: Text('分類: $category'),
          ),
          body: Center(
            child: Text('$category 分類文章'),
          ),
        );
  }
}
