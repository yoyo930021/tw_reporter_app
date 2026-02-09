import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// ── Constants ────────────────────────────────────────────────────────

/// Maximum allowed WebView height (px) to prevent GPU texture OOM.
const _maxWebViewHeight = 3000.0;

// ── Shared JS for height measurement ────────────────────────────────
//
// For HTML mode the content is wrapped in <div id="__fc"> so we can
// measure that div's actual height — body.scrollHeight returns the
// *viewport* height on macOS WKWebView when content is shorter.
//
// For URL mode (loadRequest) there is no wrapper, so we fall back to
// body/documentElement measurements (best-effort).

/// JS that expands scrollable elements once.
/// Only injected on Android where inner overflow causes clipping.
/// No MutationObserver — running once avoids feedback loops
/// (expand → DOM change → re-expand → height jumps).
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

/// Measurement JS used when a `#__fc` wrapper div is present
/// (i.e. loadHtmlString mode).
///
/// Uses a `__useScrollH` flag (injected by Dart) to decide whether
/// to cross-check with scrollHeight (needed on Android only).
/// Debounces height changes by 300 ms to prevent rapid jumps.
const _wrappedMeasureJs = '''
  var h = 0;
  var notified = false;
  var pending = 0;
  var debounceTimer = null;
  var maxH = 3000;

  function send(nh) {
    if (nh > 0 && (nh !== h || !notified)) {
      h = nh;
      window.__flutterContentHeight = nh;
      if (typeof FlutterHeight !== 'undefined') {
        try {
          FlutterHeight.postMessage(String(nh));
          notified = true;
        } catch(e) {}
      }
    }
  }

  function measure() {
    var w = document.getElementById('__fc');
    var nh = w ? w.offsetHeight : 0;
    if (nh <= 0 && w) {
      var r = w.getBoundingClientRect();
      nh = Math.ceil(r.height);
    }
    // On Android, scrollHeight may be larger after expanding
    // overflow elements. Skip on macOS/iOS where it inflates.
    if (typeof __useScrollH !== 'undefined' && __useScrollH
        && w && w.scrollHeight > nh) {
      nh = w.scrollHeight;
    }
    if (nh > maxH) nh = maxH;
    if (nh <= 0) return;
    window.__flutterContentHeight = nh;
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
    var w = document.getElementById('__fc');
    if (w) new ResizeObserver(measure).observe(w);
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
    if (++count >= 30) {
      clearInterval(poll);
      var slow = setInterval(function() { measure(); }, 2000);
      setTimeout(function() { clearInterval(slow); }, 45000);
    }
  }, 500);
''';

/// Measurement JS for URL mode (no wrapper div — best-effort).
///
/// Uses a `__useScrollH` flag (injected by Dart) to decide whether
/// to account for scrollHeight (needed on Android only).
///
/// A debounce timer prevents rapid oscillation: the height must be
/// stable for 300 ms before it is posted to Flutter.
const _urlMeasureJs = '''
  var h = 0;
  var notified = false;
  var debounceTimer = null;
  var pending = 0;
  var maxH = 3000;
  var useScrollH = (typeof __useScrollH !== 'undefined') && __useScrollH;

  function contentHeight() {
    var body = document.body;
    if (!body) return 0;
    var maxBot = 0;
    var bodyRect = body.getBoundingClientRect();
    var bodyTop = bodyRect.top;

    // Walk body's direct children for basic bounding box measurement.
    var children = body.children;
    for (var i = 0; i < children.length; i++) {
      var el = children[i];
      var tag = el.tagName;
      if (tag === "SCRIPT" || tag === "STYLE" || tag === "LINK"
          || tag === "NOSCRIPT") continue;
      var r = el.getBoundingClientRect();
      if (r.height <= 0) continue;
      if (r.bottom > maxBot) maxBot = r.bottom;
      // On Android, account for scrollable overflow content.
      if (useScrollH && el.scrollHeight > el.clientHeight + 2) {
        var extra = el.scrollHeight - el.clientHeight;
        var expanded = r.bottom + extra;
        if (expanded > maxBot) maxBot = expanded;
      }
    }
    var elemH = maxBot > 0 ? Math.ceil(maxBot - bodyTop) : 0;

    // On Android, cross-check with body.scrollHeight.
    if (useScrollH) {
      var scrollH = Math.max(
        body.scrollHeight || 0,
        document.documentElement.scrollHeight || 0
      );
      if (scrollH > elemH) elemH = scrollH;
    }

    return Math.min(elemH, maxH);
  }

  function send(nh) {
    if (nh > 0 && (nh !== h || !notified)) {
      h = nh;
      window.__flutterContentHeight = nh;
      if (typeof FlutterHeight !== "undefined") {
        try {
          FlutterHeight.postMessage(String(nh));
          notified = true;
        } catch(e) {}
      }
    }
  }

  function measure() {
    var nh = contentHeight();
    if (nh <= 0) return;
    window.__flutterContentHeight = nh;
    if (nh === pending) return;
    pending = nh;
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(function() { send(nh); }, 300);
  }

  requestAnimationFrame(function() {
    measure();
    requestAnimationFrame(measure);
  });

  new MutationObserver(function(mutations) {
    measure();
    mutations.forEach(function(m) {
      m.addedNodes.forEach(function(n) {
        if (n.nodeType !== 1) return;
        var imgs = n.tagName === "IMG" ? [n]
            : (n.querySelectorAll
               ? Array.from(n.querySelectorAll("img")) : []);
        imgs.forEach(function(img) {
          if (!img.complete) {
            img.addEventListener("load", measure);
            img.addEventListener("error", measure);
          }
        });
      });
    });
  }).observe(document.documentElement,
      {childList: true, subtree: true, attributes: true});

  if (typeof ResizeObserver !== "undefined") {
    var ro = new ResizeObserver(measure);
    if (document.body) ro.observe(document.body);
    ro.observe(document.documentElement);
  }

  document.querySelectorAll("img").forEach(function(img) {
    if (!img.complete) {
      img.addEventListener("load", measure);
      img.addEventListener("error", measure);
    }
  });

  window.addEventListener("load", measure);
  window.addEventListener("resize", measure);

  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(measure);
  }

  var count = 0;
  var poll = setInterval(function() {
    measure();
    if (++count >= 30) {
      clearInterval(poll);
      var slow = setInterval(function() { measure(); }, 2000);
      setTimeout(function() { clearInterval(slow); }, 45000);
    }
  }, 500);
''';

/// JS expression for Dart-side polling. Prefers the wrapper div
/// offsetHeight, then the cached `__flutterContentHeight` set by
/// the injected measurement script.
/// Kept simple — no scrollHeight cross-checks to avoid inflation.
const _heightExpr =
    '(function(){'
    ' var maxH=3000;'
    ' var w=document.getElementById("__fc");'
    ' if(w){'
    ' var h=w.offsetHeight;'
    ' if(h<=0){var r=w.getBoundingClientRect();h=Math.ceil(r.height);}'
    ' if(h>0)return Math.min(h,maxH);'
    ' }'
    ' if(window.__flutterContentHeight>0)'
    ' return Math.min(window.__flutterContentHeight,maxH);'
    ' return 0;'
    ' })()';

/// Fallback height (px) when all detection strategies fail.
const _defaultFallback = 300.0;

/// Result returned by [useWebViewController].
typedef WebViewState = ({
  /// The underlying controller (null before [initialize] completes).
  ReadonlyRef<WebViewController?> controller,

  /// Whether content is currently loading.
  ReadonlyRef<bool> isLoading,

  /// Height to use for the container.
  /// Uses JS-detected height when available, otherwise fallbackHeight.
  /// Capped at [_maxWebViewHeight].
  ReadonlyRef<double> viewHeight,

  /// Initialise the controller (call once when first visible).
  Future<void> Function() initialize,

  /// Destroy the controller to free resources (e.g. when scrolled off-screen).
  /// The detected height is preserved so re-initialising is seamless.
  void Function() destroy,
});

/// Creates and manages a [WebViewController] with automatic lifecycle
/// management.
///
/// The controller is created lazily via the returned `initialize` and
/// automatically cleaned up on unmount. JS channels handle height
/// auto-detection and wheel-event forwarding.
///
/// Height detection uses multiple strategies:
/// 1. Inline JS measuring a wrapper div for `loadHtmlString` content
/// 2. Injected JS via `onPageFinished` for URL content
/// 3. Dart-side polling via `runJavaScriptReturningResult` (backup)
/// 4. Fixed 300 px fallback after timeout
///
/// On Android, additionally:
/// - Expands scrollable child elements (overflow → visible)
/// - Uses `scrollHeight` cross-check for more accurate measurement
/// - Body/html overflow set to `visible` instead of `hidden`
///
/// All detected heights are capped at [_maxWebViewHeight] (3000px).
WebViewState useWebViewController({
  String? src,
  String? htmlData,
  double fallbackHeight = 300,
  String? baseUrl,
  void Function(Uri url)? onExternalUrl,
}) {
  final controllerRef = ref<WebViewController?>(null);
  final isLoading = ref(true);
  final contentHeight = ref<double?>(null);
  final heightDetected = ref(false);
  final scrollableRef = useContextRef<ScrollableState?>(Scrollable.maybeOf);
  var isDisposed = false;

  // Scroll forwarding is only needed on WebKit — WKWebView intercepts
  // wheel events and blocks the outer ScrollView.
  // Height detection is needed on all platforms because Flutter's
  // WebViewWidget has no native wrap_content equivalent.
  final needsScrollFix = Platform.isMacOS || Platform.isIOS;
  final isAndroid = Platform.isAndroid;

  // Preserves detected height across destroy/create cycles.
  // Falls back to fallbackHeight when no valid height is detected.
  // A detected height of 0 (or negative) is treated as invalid.
  // Capped at _maxWebViewHeight to prevent GPU texture OOM.
  final viewHeight = computed(() {
    final h = contentHeight.value;
    if (h != null && h > 0) {
      return h.clamp(0.0, _maxWebViewHeight);
    }
    return fallbackHeight;
  });

  Timer? pollTimer;

  // ── Scroll forwarding ────────────────────────────────────────────

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

  // ── JS injection (for URL / loadRequest mode) ────────────────────

  void injectScripts() {
    final scrollJs = needsScrollFix
        ? '''
  document.addEventListener('wheel', function(e) {
    e.preventDefault();
    FlutterScroll.postMessage(String(e.deltaY));
  }, {passive: false});'''
        : '';
    // On Android, expand scrollable elements before measuring.
    final expandJs = isAndroid ? _expandScrollableJs : '';
    unawaited(
      controllerRef.value?.runJavaScript('''
(function() {
var __useScrollH = $isAndroid;
$scrollJs
$expandJs
$_urlMeasureJs
})();
'''),
    );
  }

  // ── Dart-side polling backup ─────────────────────────────────────

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
              .runJavaScriptReturningResult(_heightExpr)
              .then((result) {
                final raw = result.toString();
                final h = double.tryParse(raw);
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
        // After 10 s, apply fixed fallback.
        if (ticks >= 20) {
          timer.cancel();
          if (!heightDetected.value && controllerRef.value != null) {
            contentHeight.value = _defaultFallback;
          }
        }
      },
    );
  }

  // ── Wrap HTML with wrapper div + inline measurement ──────────────

  String wrapHtml(String html) {
    final scrollJs = needsScrollFix
        ? '''
document.addEventListener('wheel',function(e){
e.preventDefault();
if(typeof FlutterScroll!=='undefined'){
FlutterScroll.postMessage(String(e.deltaY));
}
},{passive:false});'''
        : '';

    // On Android, use overflow:visible so scrollHeight reports the
    // full content height and inner elements can expand naturally.
    // On iOS/macOS, keep overflow:hidden to prevent WKWebView
    // scroll issues (scroll forwarding handles this instead).
    final overflowCss =
        isAndroid ? 'overflow:visible' : 'overflow:hidden';

    // On Android, inject JS to expand scrollable child elements.
    final expandJs = isAndroid ? _expandScrollableJs : '';

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
<script>(function(){
var __useScrollH = $isAndroid;
$scrollJs
$expandJs
$_wrappedMeasureJs
})();</script>
</body></html>''';
  }

  // ── Lifecycle ────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (controllerRef.value != null || isDisposed) return;

    isLoading.value = true;
    heightDetected.value = false;
    contentHeight.value = null;

    // Create controller with platform-specific params for inline
    // media playback (required for YouTube iframes, etc.).
    var params = const PlatformWebViewControllerCreationParams();
    if (Platform.isIOS || Platform.isMacOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    }
    final controller =
        WebViewController.fromPlatformCreationParams(params);
    controllerRef.value = controller;

    if (kDebugMode) {
      if (Platform.isAndroid) {
        await AndroidWebViewController.enableDebugging(true);
      } else if (Platform.isIOS || Platform.isMacOS) {
        final Object platform = controller.platform;
        if (platform is WebKitWebViewController) {
          await platform.setInspectable(true);
        }
      }
    }

    await controller.setJavaScriptMode(
      JavaScriptMode.unrestricted,
    );

    // Android: allow media playback without user gesture.
    final Object platform = controller.platform;
    if (platform is AndroidWebViewController) {
      await platform.setMediaPlaybackRequiresUserGesture(false);
    }

    await controller.addJavaScriptChannel(
      'FlutterHeight',
      onMessageReceived: (message) {
        debugPrint('[WebView channel] height: ${message.message}');
        final h = double.tryParse(message.message);
        if (h != null && h > 0 && !isDisposed) {
          contentHeight.value = h;
          heightDetected.value = true;
        }
      },
    );
    // Scroll forwarding channel — only on WebKit.
    if (needsScrollFix) {
      await controller.addJavaScriptChannel(
        'FlutterScroll',
        onMessageReceived: (message) {
          final dy = double.tryParse(message.message);
          if (dy != null && dy != 0) {
            forwardScroll(dy);
          }
        },
      );
    }

    await controller.setOnConsoleMessage((msg) {
      debugPrint(
        '[WebView ${msg.level.name}] ${msg.message}',
      );
    });

    // Determine the origin host so we can detect cross-domain
    // navigations (likely user-initiated link clicks).
    final originHost = src != null
        ? Uri.tryParse(src)?.host
        : baseUrl != null
            ? Uri.tryParse(baseUrl)?.host
            : null;

    await controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) {
          // Allow sub-frame navigations (e.g. YouTube iframe).
          if (!request.isMainFrame) {
            return NavigationDecision.navigate;
          }
          // Allow non-http navigations (about:blank, data:, etc.).
          final requestUri = Uri.tryParse(request.url);
          if (requestUri == null ||
              !requestUri.hasScheme ||
              (requestUri.scheme != 'http' &&
                  requestUri.scheme != 'https')) {
            return NavigationDecision.navigate;
          }
          // If the domain differs from the origin, open externally.
          // This catches user clicks like "Watch on YouTube" while
          // allowing same-domain redirects and the initial load.
          if (originHost != null &&
              requestUri.host != originHost) {
            if (onExternalUrl != null) {
              onExternalUrl(requestUri);
            } else {
              unawaited(
                launchUrl(
                  requestUri,
                  mode: LaunchMode.externalApplication,
                ),
              );
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (url) {
          debugPrint('[WebView] onPageFinished: $url');
          if (src != null) {
            injectScripts();
          } else if (htmlData != null) {
            // Re-inject measurement (and expansion on Android)
            // in case onPageFinished fires after the inline script.
            final expandJs = isAndroid ? _expandScrollableJs : '';
            unawaited(
              controllerRef.value?.runJavaScript(
                '(function(){$expandJs$_wrappedMeasureJs})();',
              ),
            );
          }
          if (!isDisposed) {
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

    // Dart-side polling backup for height detection.
    startHeightPolling();

    if (isDisposed) return;

    if (src != null) {
      debugPrint('[WebView] loadRequest: $src');
      await controller.loadRequest(Uri.parse(src));
    } else if (htmlData != null) {
      debugPrint('[WebView] loadHtmlString (wrapped)');
      await controller.loadHtmlString(
        wrapHtml(htmlData),
        baseUrl: baseUrl ?? _baseUrlFromHtml(htmlData),
      );
    }
  }

  // ── Destroy (recycle) ──────────────────────────────────────────────

  void destroy() {
    if (controllerRef.value == null) return;
    pollTimer?.cancel();
    final ctrl = controllerRef.value;
    controllerRef.value = null;
    isLoading.value = true;
    heightDetected.value = false;
    // Navigate to blank to release page resources, but don't await.
    if (ctrl != null) {
      unawaited(ctrl.loadRequest(Uri.parse('about:blank')));
    }
    debugPrint('[WebView] destroyed (recycled)');
  }

  // On unmount, clean up without setting reactive refs.
  // Setting refs during unmount triggers a rebuild on a deactivated widget,
  // causing "Looking up a deactivated widget's ancestor is unsafe".
  onUnmounted(() {
    isDisposed = true;
    pollTimer?.cancel();
    final ctrl = controllerRef.value;
    if (ctrl != null) {
      unawaited(ctrl.loadRequest(Uri.parse('about:blank')));
    }
  });

  return (
    controller: controllerRef,
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
