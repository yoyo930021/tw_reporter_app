import 'dart:async';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/shared/composables/use_scroll_visibility.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Widget that displays embedded web content using WebView.
/// Lazily initializes the WebView when first visible.
///
/// Supports two modes:
/// - URL mode: loads content from [src]
/// - HTML mode: loads raw HTML from [htmlData]
class EmbeddedWebView extends StatelessWidget {
  /// Creates an [EmbeddedWebView].
  const EmbeddedWebView({
    this.src,
    this.htmlData,
    this.height = 400,
    this.caption,
    super.key,
  }) : assert(
         src != null || htmlData != null,
         'Either src or htmlData must be provided',
       );

  /// URL to load in the WebView (iframe mode).
  final String? src;

  /// Raw HTML content to render (custom component mode).
  final String? htmlData;

  /// Initial / fallback height of the WebView container.
  final double height;

  /// Optional caption displayed below the WebView.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return _EmbeddedWebViewContent(
      src: src,
      htmlData: htmlData,
      height: height,
      caption: caption,
    );
  }
}

class _EmbeddedWebViewContent extends CompositionWidget {
  const _EmbeddedWebViewContent({
    this.src,
    this.htmlData,
    this.height = 400,
    this.caption,
  });

  final String? src;
  final String? htmlData;
  final double height;
  final String? caption;

  @override
  Widget Function(BuildContext) setup() {
    final controllerRef = ref<WebViewController?>(null);
    final isLoading = ref<bool>(true);
    final hasBeenVisible = ref<bool>(false);
    final contentHeight = ref<double?>(null);

    void injectScripts() {
      unawaited(controllerRef.value?.runJavaScript('''
(function() {
  // Forward wheel events to Flutter so the parent ScrollView scrolls.
  document.addEventListener('wheel', function(e) {
    e.preventDefault();
    FlutterScroll.postMessage(String(e.deltaY));
  }, {passive: false});

  // Measure content height.
  var h = 0;
  function measure() {
    var bh = document.body ? document.body.scrollHeight : 0;
    var dh = document.documentElement.scrollHeight;
    var nh = Math.max(bh, dh);
    if (nh > 0 && nh !== h) {
      h = nh;
      FlutterHeight.postMessage(String(h));
    }
  }
  measure();
  new MutationObserver(measure).observe(
    document.documentElement,
    {childList: true, subtree: true, attributes: true}
  );
  if (typeof ResizeObserver !== 'undefined' && document.body) {
    new ResizeObserver(measure).observe(document.body);
  }
  var count = 0;
  var poll = setInterval(function() {
    measure();
    if (++count >= 30) clearInterval(poll);
  }, 500);
})();
'''));
    }

    // Declare onVisibilityChanged before useScrollVisibility so it can
    // be passed as the callback, and declare forwardScroll /
    // initController as late locals so that onVisibilityChanged can
    // reference initController and initController can reference
    // forwardScroll (all invoked lazily via closures).
    late final void Function(double dy) forwardScroll;
    late final Future<void> Function() initController;

    void onVisibilityChanged({required bool visible}) {
      if (visible) {
        if (controllerRef.value == null) {
          hasBeenVisible.value = true;
          isLoading.value = true;
          controllerRef.value = WebViewController();
          unawaited(initController());
        }
      } else {
        if (controllerRef.value != null) {
          unawaited(
              controllerRef.value!.loadRequest(Uri.parse('about:blank')));
          controllerRef.value = null;
        }
      }
    }

    final (visibilityKey, _) = useScrollVisibility(
      onChanged: onVisibilityChanged,
    );

    forwardScroll = (dy) {
      final ctx = visibilityKey.currentContext;
      if (ctx == null) return;
      final scrollable = Scrollable.maybeOf(ctx);
      if (scrollable == null) return;
      final position = scrollable.position;
      final target = (position.pixels + dy).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      position.jumpTo(target);
    };

    initController = () async {
      if (kDebugMode) {
        if (Platform.isAndroid) {
          await AndroidWebViewController.enableDebugging(true);
        } else if (Platform.isIOS) {
          final Object platform = controllerRef.value!.platform;
          if (platform is WebKitWebViewController) {
            await platform.setInspectable(true);
          }
        }
      }
      await controllerRef.value!.setJavaScriptMode(
        JavaScriptMode.unrestricted,
      );
      await controllerRef.value!.addJavaScriptChannel(
        'FlutterHeight',
        onMessageReceived: (message) {
          final h = double.tryParse(message.message);
          if (h != null && h > 0 && controllerRef.value != null) {
            contentHeight.value = h;
          }
        },
      );
      await controllerRef.value!.addJavaScriptChannel(
        'FlutterScroll',
        onMessageReceived: (message) {
          final dy = double.tryParse(message.message);
          if (dy != null && dy != 0) {
            forwardScroll(dy);
          }
        },
      );
      await controllerRef.value!.setOnConsoleMessage((msg) {
        debugPrint('[WebView ${msg.level.name}] ${msg.message}');
      });
      await controllerRef.value!.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            injectScripts();
            if (controllerRef.value != null) {
              isLoading.value = false;
            }
          },
          onWebResourceError: (error) {
            debugPrint(
              '[WebView error] ${error.errorCode}: '
              '${error.description} (${error.url})',
            );
          },
        ),
      );

      if (src != null) {
        debugPrint('[WebView] loadRequest: $src');
        await controllerRef.value!.loadRequest(
          Uri.parse(src!),
        );
      } else if (htmlData != null) {
        debugPrint('[WebView] loadHtmlString:\n$htmlData');
        await controllerRef.value!.loadHtmlString(
          htmlData!,
          baseUrl: _baseUrlFromHtml(htmlData!),
        );
      }
    };

    onUnmounted(() {
      if (controllerRef.value != null) {
        unawaited(
            controllerRef.value!.loadRequest(Uri.parse('about:blank')));
        controllerRef.value = null;
      }
    });

    return (BuildContext context) {
      final colors = Theme.of(context).colorScheme;
      final viewHeight = contentHeight.value ?? height;

      return Column(
        key: visibilityKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: viewHeight,
            child: hasBeenVisible.value && controllerRef.value != null
                ? Stack(
                    children: <Widget>[
                      WebViewWidget(controller: controllerRef.value!),
                      if (isLoading.value)
                        const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  )
                : const ColoredBox(
                    color: AppColors.grey200,
                    child: Center(
                      child: Icon(
                        Icons.web,
                        color: AppColors.grey400,
                        size: 48,
                      ),
                    ),
                  ),
          ),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
              ),
              child: Text(
                caption!,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      );
    };
  }
}

/// Extract origin from `<script src="...">` to use as baseUrl,
/// avoiding CORS `null` origin.
String? _baseUrlFromHtml(String html) {
  // Try <script src="https://..."> first
  var match = RegExp(
    r'''<script[^>]+src\s*=\s*["'](https?://[^"']+)["']''',
    caseSensitive: false,
  ).firstMatch(html);
  // Fallback to any src/href
  match ??= RegExp(
    r'''(?:src|href)\s*=\s*["'](https?://[^"']+)["']''',
    caseSensitive: false,
  ).firstMatch(html);
  if (match == null) return null;
  final uri = Uri.tryParse(match.group(1)!);
  if (uri == null) return null;
  return '${uri.scheme}://${uri.host}';
}
