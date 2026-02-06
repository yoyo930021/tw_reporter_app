import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';

class HorizontalCarousel extends StatelessWidget {
  const HorizontalCarousel({
    required this.itemWidth,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    super.key,
  });

  final double itemWidth;
  final double height;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: itemWidth,
            child: itemBuilder(context, index),
          );
        },
      ),
    );
  }
}
