import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Constants ────────────────────────────────────────────────────────

/// Maximum allowed WebView height (px) to prevent GPU texture OOM.
const _maxWebViewHeight = 3000.0;

/// Fallback height (px) when all detection strategies fail.
const _defaultFallback = 300.0;

// ── JS helpers ───────────────────────────────────────────────────────

/// JS that expands scrollable elements once (Android only).
/// Inner overflow causes clipping on Android; this makes them visible.
const _expandScrollableJs = '''
  (function() {
    var all = document.querySelectorAll('*');
    for (var i = 0; i < all.length; i++) {
      var el = all[i];
      var tag = el.tagName;
      if (tag === 'IFRAME' || tag === 'VIDEO' || tag === 'CANVAS'
          || tag === 'SCRIPT' || tag === 'STYLE') continue;
      if (el.scrollHeight > el.clientHeight + 2) {
        var cs = getComputedStyle(el);
        var ov = cs.overflow + ' ' + cs.overflowY;
        if (ov.indexOf('hidden') >= 0 || ov.indexOf('auto') >= 0
            || ov.indexOf('scroll') >= 0) {
          el.style.setProperty('overflow', 'visible', 'important');
          el.style.setProperty('max-height', 'none', 'important');
          el.style.setProperty('height', 'auto', 'important');
        }
      }
    }
  })();
''';

/// Height measurement JS injected on all platforms.
/// On iOS/macOS this supplements `onContentSizeChanged` which may not
/// fire correctly when `disableVerticalScroll` is true.
/// On Android this is the primary height detection mechanism since
/// `onContentSizeChanged` is not supported.
/// Posts height via callHandler to Flutter.
const _measureJs = '''
(function(){
  var h = 0;
  var pending = 0;
  var debounceTimer = null;
  var maxH = 3000;

  function send(nh) {
    if (nh > 0 && nh !== h) {
      h = nh;
      window.flutter_inappwebview.callHandler('FlutterHeight', String(nh));
    }
  }

  function measure() {
    var w = document.getElementById('__fc');
    var nh = 0;
    if (w) {
      nh = w.offsetHeight;
      if (nh <= 0) {
        var r = w.getBoundingClientRect();
        nh = Math.ceil(r.height);
      }
      if (w.scrollHeight > nh) nh = w.scrollHeight;
    } else {
      var body = document.body;
      if (!body) return;
      nh = Math.max(body.scrollHeight || 0,
        document.documentElement.scrollHeight || 0);
    }
    if (nh > maxH) nh = maxH;
    if (nh <= 0) return;
    if (nh === pending) return;
    pending = nh;
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(function() { send(nh); }, 300);
  }

  requestAnimationFrame(function() {
    measure();
    requestAnimationFrame(measure);
  });

  new MutationObserver(function() { measure(); })
    .observe(document.documentElement,
      {childList: true, subtree: true, attributes: true});

  if (typeof ResizeObserver !== 'undefined') {
    var ro = new ResizeObserver(measure);
    if (document.body) ro.observe(document.body);
    ro.observe(document.documentElement);
    var w = document.getElementById('__fc');
    if (w) ro.observe(w);
  }

  document.querySelectorAll('img').forEach(function(img) {
    if (!img.complete) {
      img.addEventListener('load', measure);
      img.addEventListener('error', measure);
    }
  });

  window.addEventListener('load', measure);
  window.addEventListener('resize', measure);

  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(measure);
  }

  var count = 0;
  var poll = setInterval(function() {
    measure();
    if (++count >= 20) {
      clearInterval(poll);
      var slow = setInterval(function() { measure(); }, 2000);
      setTimeout(function() { clearInterval(slow); }, 30000);
    }
  }, 500);
})();
''';

// ── Result type ──────────────────────────────────────────────────────

/// Result returned by [useWebViewController].
///
/// Unlike the old webview_flutter-based composable which returned a
/// controller, this returns declarative config for [InAppWebView].
typedef WebViewState = ({
  /// Settings for the InAppWebView widget.
  InAppWebViewSettings settings,

  /// Initial HTML data (null for URL mode).
  InAppWebViewInitialData? initialData,

  /// Initial URL request (null for HTML mode).
  URLRequest? initialUrlRequest,

  /// Callback for when the WebView is created.
  void Function(InAppWebViewController) onWebViewCreated,

  /// Callback for content size changes (iOS/macOS height detection).
  void Function(InAppWebViewController, Size, Size) onContentSizeChanged,

  /// Callback for when page finishes loading.
  void Function(InAppWebViewController, WebUri?) onLoadStop,

  /// Callback for intercepting URL navigations.
  Future<NavigationActionPolicy?> Function(
    InAppWebViewController,
    NavigationAction,
  ) shouldOverrideUrlLoading,

  /// Callback for console messages.
  void Function(InAppWebViewController, ConsoleMessage) onConsoleMessage,

  /// The underlying controller (null before onWebViewCreated).
  ReadonlyRef<InAppWebViewController?> controller,

  /// Whether the WebView has been initialized (ready to render).
  ReadonlyRef<bool> isInitialized,

  /// Whether content is currently loading.
  ReadonlyRef<bool> isLoading,

  /// Height to use for the container.
  /// Uses detected height when available, otherwise fallbackHeight.
  /// Capped at [_maxWebViewHeight].
  ReadonlyRef<double> viewHeight,

  /// Initialise the controller (call once when first visible).
  Future<void> Function() initialize,

  /// Destroy the controller to free resources.
  void Function() destroy,
});

/// Creates and manages an InAppWebView with automatic lifecycle
/// management.
///
/// Height detection (all platforms):
/// 1. Injected JS measurement via `callHandler` (primary)
/// 2. `onContentSizeChanged` callback (iOS/macOS supplementary)
/// 3. Dart-side polling via `evaluateJavascript` (backup)
///
/// On macOS/iOS, WKWebView intercepts wheel events even with
/// `disableVerticalScroll: true`. JS wheel-event forwarding via
/// `FlutterScroll` handler is used to pass scroll to the parent.
///
/// All detected heights are capped at [_maxWebViewHeight] (3000px).
WebViewState useWebViewController({
  String? src,
  String? htmlData,
  double fallbackHeight = 300,
  String? baseUrl,
  void Function(Uri url)? onExternalUrl,
}) {
  final controllerRef = ref<InAppWebViewController?>(null);
  final isLoading = ref(true);
  final contentHeight = ref<double?>(null);
  final heightDetected = ref(false);
  final initialized = ref(false);
  var isDisposed = false;

  final isAndroid = Platform.isAndroid;
  // WKWebView intercepts wheel events — need JS forwarding.
  final needsScrollFix = Platform.isMacOS || Platform.isIOS;
  final scrollableRef = useContextRef<ScrollableState?>(Scrollable.maybeOf);

  // Preserves detected height across destroy/create cycles.
  final viewHeight = computed(() {
    final h = contentHeight.value;
    if (h != null && h > 0) {
      return h.clamp(0.0, _maxWebViewHeight);
    }
    return fallbackHeight;
  });

  Timer? pollTimer;

  // ── Determine origin for external link detection ──────────────────

  final originHost = src != null
      ? Uri.tryParse(src)?.host
      : baseUrl != null
          ? Uri.tryParse(baseUrl)?.host
          : null;

  // ── Settings ──────────────────────────────────────────────────────

  final settings = InAppWebViewSettings(
    // Do NOT set disableVerticalScroll — it would prevent scrolling
    // inside iframes (e.g. YouTube). Instead, JS wheel-event
    // forwarding handles passing scroll to the parent ScrollView
    // on macOS/iOS, and CSS overflow:hidden prevents the main page
    // from scrolling.
    //
    // Inline media playback (required for YouTube iframes).
    allowsInlineMediaPlayback: true,
    mediaPlaybackRequiresUserGesture: false,
    // Allow iframes (YouTube embeds, etc.)
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,
    // Debug in development.
    isInspectable: kDebugMode,
  );

  // ── Wrap HTML with wrapper div ────────────────────────────────────

  String wrapHtml(String html) {
    final overflowCss =
        isAndroid ? 'overflow:visible' : 'overflow:hidden';

    return '''
<!DOCTYPE html>
<html><head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
html,body{margin:0;padding:0;height:auto;$overflowCss}
#__fc{display:inline-block;width:100%}
</style>
</head><body>
<div id="__fc">$html</div>
</body></html>''';
  }

  // ── Build initial data / request ──────────────────────────────────

  InAppWebViewInitialData? initialData;
  URLRequest? initialUrlRequest;

  if (src != null) {
    initialUrlRequest = URLRequest(url: WebUri(src));
  } else if (htmlData != null) {
    final resolvedBaseUrl = baseUrl ?? _baseUrlFromHtml(htmlData);
    initialData = InAppWebViewInitialData(
      data: wrapHtml(htmlData),
      baseUrl: resolvedBaseUrl != null ? WebUri(resolvedBaseUrl) : null,
      encoding: 'utf-8',
    );
  }

  // ── Scroll forwarding (macOS/iOS) ──────────────────────────────────

  void forwardScroll(double dy) {
    final scrollable = scrollableRef.value;
    if (scrollable == null) return;
    final position = scrollable.position;
    final target = (position.pixels + dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    position.jumpTo(target);
  }

  // ── onWebViewCreated ──────────────────────────────────────────────

  void onWebViewCreated(InAppWebViewController controller) {
    controllerRef.value = controller;

    // Register height handler for JS measurement (all platforms).
    controller.addJavaScriptHandler(
      handlerName: 'FlutterHeight',
      callback: (args) {
        final raw = args.isNotEmpty ? args[0]?.toString() : null;
        debugPrint('[WebView handler] height: $raw');
        final h = raw != null ? double.tryParse(raw) : null;
        if (h != null && h > 0 && !isDisposed) {
          contentHeight.value = h;
          heightDetected.value = true;
        }
        return null;
      },
    );

    // Scroll forwarding handler (macOS/iOS).
    if (needsScrollFix) {
      controller.addJavaScriptHandler(
        handlerName: 'FlutterScroll',
        callback: (args) {
          final raw = args.isNotEmpty ? args[0]?.toString() : null;
          final dy = raw != null ? double.tryParse(raw) : null;
          if (dy != null && dy != 0) {
            forwardScroll(dy);
          }
          return null;
        },
      );
    }
  }

  // ── onContentSizeChanged (iOS/macOS native height) ────────────────

  void onContentSizeChanged(
    InAppWebViewController controller,
    Size oldContentSize,
    Size newContentSize,
  ) {
    // onContentSizeChanged is not supported on Android.
    if (isAndroid) return;
    final h = newContentSize.height;
    debugPrint('[WebView] onContentSizeChanged: $h');
    if (h > 0 && !isDisposed) {
      contentHeight.value = h;
      heightDetected.value = true;
    }
  }

  // ── onLoadStop ────────────────────────────────────────────────────

  void onLoadStop(InAppWebViewController controller, WebUri? url) {
    debugPrint('[WebView] onLoadStop: $url');
    if (!isDisposed) {
      isLoading.value = false;
    }

    // On Android, expand scrollable elements before measuring.
    final expandJs = isAndroid ? _expandScrollableJs : '';
    // On macOS/iOS, forward wheel events to parent ScrollView.
    final scrollJs = needsScrollFix
        ? 'document.addEventListener("wheel",function(e){'
          'e.preventDefault();'
          'window.flutter_inappwebview.callHandler('
          '"FlutterScroll",String(e.deltaY));'
          '},{passive:false});\n'
        : '';
    // Inject height measurement JS on all platforms.
    unawaited(
      controller.evaluateJavascript(
        source: '$expandJs$scrollJs$_measureJs',
      ),
    );
  }

  // ── shouldOverrideUrlLoading ──────────────────────────────────────

  Future<NavigationActionPolicy?> shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final request = navigationAction.request;
    final requestUri = request.url;

    // Allow sub-frame navigations (e.g. YouTube iframe).
    if (!navigationAction.isForMainFrame) {
      return NavigationActionPolicy.ALLOW;
    }

    // Allow non-http navigations (about:blank, data:, etc.).
    if (requestUri == null ||
        (requestUri.scheme != 'http' && requestUri.scheme != 'https')) {
      return NavigationActionPolicy.ALLOW;
    }

    // If the domain differs from the origin, open externally.
    if (originHost != null && requestUri.host != originHost) {
      if (onExternalUrl != null) {
        onExternalUrl(requestUri.uriValue);
      } else {
        unawaited(
          launchUrl(
            requestUri.uriValue,
            mode: LaunchMode.externalApplication,
          ),
        );
      }
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  // ── onConsoleMessage ──────────────────────────────────────────────

  void onConsoleMessage(
    InAppWebViewController controller,
    ConsoleMessage consoleMessage,
  ) {
    debugPrint(
      '[WebView ${consoleMessage.messageLevel}] '
      '${consoleMessage.message}',
    );
  }

  // ── Dart-side polling backup ────────────────────────────────────────

  void startHeightPolling() {
    pollTimer?.cancel();
    var ticks = 0;
    pollTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if (controllerRef.value == null || heightDetected.value) {
          timer.cancel();
          return;
        }
        unawaited(
          controllerRef.value!
              .evaluateJavascript(
                source:
                    '(function(){'
                    ' var maxH=3000;'
                    ' var w=document.getElementById("__fc");'
                    ' if(w){'
                    ' var h=w.offsetHeight;'
                    ' if(h<=0){var r=w.getBoundingClientRect();'
                    ' h=Math.ceil(r.height);}'
                    ' if(h>0)return Math.min(h,maxH);'
                    ' }'
                    ' var b=document.body;'
                    ' if(b){var sh=Math.max(b.scrollHeight||0,'
                    ' document.documentElement.scrollHeight||0);'
                    ' if(sh>0)return Math.min(sh,maxH);}'
                    ' return 0;'
                    ' })()',
              )
              .then((result) {
                final raw = result?.toString();
                final h = raw != null ? double.tryParse(raw) : null;
                debugPrint('[WebView poll] raw=$raw parsed=$h');
                if (h != null && h > 0 && controllerRef.value != null) {
                  contentHeight.value = h;
                  heightDetected.value = true;
                  timer.cancel();
                }
              })
              .catchError((Object error) {
                debugPrint('[WebView poll] error: $error');
              }),
        );

        ticks++;
        if (ticks >= 20) {
          timer.cancel();
          if (!heightDetected.value && controllerRef.value != null) {
            contentHeight.value = _defaultFallback;
          }
        }
      },
    );
  }

  // ── Lifecycle ─────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (initialized.value || isDisposed) return;

    isLoading.value = true;
    heightDetected.value = false;
    contentHeight.value = null;
    initialized.value = true;

    // Android debugging.
    if (kDebugMode && isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }

    // Start Dart-side polling backup.
    startHeightPolling();
  }

  void destroy() {
    if (!initialized.value) return;
    pollTimer?.cancel();
    // Don't call loadUrl on the controller — with the declarative API,
    // removing InAppWebView from the widget tree already destroys it.
    // Calling loadUrl on a destroyed WebView causes Android warnings.
    controllerRef.value = null;
    initialized.value = false;
    isLoading.value = true;
    heightDetected.value = false;
    debugPrint('[WebView] destroyed');
  }

  onUnmounted(() {
    isDisposed = true;
    pollTimer?.cancel();
    controllerRef.value = null;
  });

  return (
    settings: settings,
    initialData: initialData,
    initialUrlRequest: initialUrlRequest,
    onWebViewCreated: onWebViewCreated,
    onContentSizeChanged: onContentSizeChanged,
    onLoadStop: onLoadStop,
    shouldOverrideUrlLoading: shouldOverrideUrlLoading,
    onConsoleMessage: onConsoleMessage,
    controller: controllerRef,
    isInitialized: initialized,
    isLoading: isLoading,
    viewHeight: viewHeight,
    initialize: initialize,
    destroy: destroy,
  );
}

/// Extract origin from `<script src="...">` to use as baseUrl,
/// avoiding CORS `null` origin.
String? _baseUrlFromHtml(String html) {
  var match = RegExp(
    r'''<script[^>]+src\s*=\s*["'](https?://[^"']+)["']''',
    caseSensitive: false,
  ).firstMatch(html);
  match ??= RegExp(
    r'''(?:src|href)\s*=\s*["'](https?://[^"']+)["']''',
    caseSensitive: false,
  ).firstMatch(html);
  if (match == null) return null;
  final uri = Uri.tryParse(match.group(1)!);
  if (uri == null) return null;
  return '${uri.scheme}://${uri.host}';
}
