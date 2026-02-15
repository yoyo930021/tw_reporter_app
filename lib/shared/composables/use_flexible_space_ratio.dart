import 'dart:ui' show clampDouble;

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';

/// Returns a reactive [ReadonlyRef<double>] that tracks the expand/collapse
/// ratio of the nearest [FlexibleSpaceBar].
///
/// The value ranges from `1.0` (fully expanded) to `0.0` (fully collapsed).
///
/// Must be called inside a `CompositionBuilder.setup` or
/// `CompositionWidget.setup` whose widget is a descendant of [SliverAppBar]
/// (which provides [FlexibleSpaceBarSettings]).
ReadonlyRef<double> useFlexibleSpaceRatio() {
  final settings = useContextRef(
    (context) =>
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!,
  );

  return computed(() {
    final deltaExtent =
        settings.value.maxExtent - settings.value.minExtent;
    return 1 -
        clampDouble(
          1.0 -
              (settings.value.currentExtent - settings.value.minExtent) /
                  deltaExtent,
          0,
          1,
        );
  });
}
