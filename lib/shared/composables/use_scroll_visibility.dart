import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';

/// Composable that tracks whether the widget is visible in the viewport.
///
/// Returns a [GlobalKey] to attach to the widget being tracked and a
/// [Ref<bool>] that reactively updates when visibility changes.
///
/// Usage:
/// ```dart
/// final (visibilityKey, isVisible) = useScrollVisibility();
///
/// watch(() => isVisible.value, (visible, _) {
///   if (visible) { /* scrolled into view */ }
/// });
///
/// // In render function:
/// return SizedBox(key: visibilityKey, child: ...);
/// ```
(GlobalKey, Ref<bool>) useScrollVisibility() {
  final key = GlobalKey();
  final isVisible = ref(false);
  ScrollPosition? scrollPosition;

  void checkVisibility() {
    final ctx = key.currentContext;
    if (ctx == null) return;
    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final offset = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    final screenHeight = MediaQuery.of(ctx).size.height;

    isVisible.value =
        offset.dy < screenHeight && offset.dy + size.height > 0;
  }

  onMounted(() {
    final ctx = key.currentContext;
    if (ctx != null) {
      scrollPosition = Scrollable.maybeOf(ctx)?.position;
      scrollPosition?.addListener(checkVisibility);
    }
    checkVisibility();
  });

  onUnmounted(() {
    scrollPosition?.removeListener(checkVisibility);
  });

  return (key, isVisible);
}
