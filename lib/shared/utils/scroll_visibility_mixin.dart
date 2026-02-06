import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Mixin that detects whether a widget is visible in the viewport
/// by listening to the nearest ancestor [Scrollable]'s position.
///
/// Subclasses must implement [onVisibilityChanged] to react to
/// visibility changes.
mixin ScrollVisibilityMixin<T extends StatefulWidget> on State<T> {
  ScrollPosition? _scrollPosition;
  bool _isVisibleInViewport = false;

  /// Whether the widget is currently visible in the viewport.
  bool get isVisibleInViewport => _isVisibleInViewport;

  /// Called when the widget's visibility in the viewport changes.
  void onVisibilityChanged({required bool visible});

  void _checkVisibility() {
    if (!mounted) return;
    // Element may be deactivated but not yet disposed — guard against that.
    if (context is Element && !(context as Element).debugIsActive) return;

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final Offset offset = renderObject.localToGlobal(Offset.zero);
    final Size size = renderObject.size;
    final double screenHeight = MediaQuery.of(context).size.height;

    final bool visible =
        offset.dy < screenHeight && offset.dy + size.height > 0;
    if (visible != _isVisibleInViewport) {
      _isVisibleInViewport = visible;
      onVisibilityChanged(visible: visible);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_checkVisibility);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibility);
    super.dispose();
  }
}
