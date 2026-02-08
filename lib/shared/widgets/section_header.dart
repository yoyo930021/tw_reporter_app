import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.onViewAll,
    super.key,
  });

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text('查看全部'),
          ),
      ],
    );
  }
}
