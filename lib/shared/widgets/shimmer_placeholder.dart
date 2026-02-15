import 'dart:async';

import 'package:flutter/material.dart';

/// An animated shimmer placeholder shown while images are loading.
///
/// Displays a repeating left-to-right gradient sweep (grey -> light grey ->
/// grey) to indicate loading state.
class ShimmerPlaceholder extends StatefulWidget {
  /// Creates a [ShimmerPlaceholder].
  const ShimmerPlaceholder({this.height, this.width, super.key});

  /// Optional fixed height.
  final double? height;

  /// Optional fixed width.
  final double? width;

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final highlightColor =
        isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * v, 0),
              end: Alignment(2 * v, 0),
              colors: <Color>[baseColor, highlightColor, baseColor],
              stops: const <double>[0, 0.5, 1],
            ),
          ),
        );
      },
    );
  }
}
