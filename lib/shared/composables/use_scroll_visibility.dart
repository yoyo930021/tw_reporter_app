import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';

/// Composable that tracks whether the current widget is visible in the
/// viewport.
///
/// Unlike the previous version, this does **not** return a [GlobalKey].
/// Instead it uses the owning [CompositionWidget]'s own [BuildContext] to
/// locate its [RenderObject] and determine visibility.
///
/// Scroll events are debounced (default 150 ms) to avoid excessive
/// computation during rapid scrolling.
///
/// Usage:
/// ```dart
/// final isVisible = useScrollVisibility();
///
/// watch(() => isVisible.value, (visible, _) {
///   if (visible) { /* scrolled into view */ }
/// });
/// ```
Ref<bool> useScrollVisibility({
  Duration debounceDuration = const Duration(milliseconds: 150),
}) {
  final contextRef = useContext();
  final isVisible = ref(false);
  ScrollPosition? scrollPosition;
  Timer? debounceTimer;

  void checkVisibility() {
    final ctx = contextRef.value;
    if (ctx == null || !ctx.mounted) return;
    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final offset = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    final screenHeight = MediaQuery.of(ctx).size.height;

    isVisible.value =
        offset.dy < screenHeight && offset.dy + size.height > 0;
  }

  void onScroll() {
    debounceTimer?.cancel();
    debounceTimer = Timer(debounceDuration, checkVisibility);
  }

  onMounted(() {
    final ctx = contextRef.value;
    if (ctx != null) {
      scrollPosition = Scrollable.maybeOf(ctx)?.position;
      scrollPosition?.addListener(onScroll);
    }
    // Perform an initial (non-debounced) check so the value is immediately
    // available after mount.
    checkVisibility();
  });

  onUnmounted(() {
    scrollPosition?.removeListener(onScroll);
    debounceTimer?.cancel();
    // If the widget is unmounted (e.g. recycled by a ListView), it is
    // by definition not visible.
    isVisible.value = false;
  });

  return isVisible;
}
