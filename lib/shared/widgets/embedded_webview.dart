import 'dart:async';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';
import 'package:tw_reporter_app/shared/utils/scroll_visibility_mixin.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Widget that displays embedded web content using WebView.
/// Lazily initializes the WebView when first visible.
///
/// Supports two modes:
/// - URL mode: loads content from [src]
/// - HTML mode: loads raw HTML from [htmlData]
class EmbeddedWebView extends StatefulWidget {
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
  State<EmbeddedWebView> createState() => _EmbeddedWebViewState();
}

class _EmbeddedWebViewState extends State<EmbeddedWebView>
    with ScrollVisibilityMixin<EmbeddedWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasBeenVisible = false;
  double? _contentHeight;

  @override
  void onVisibilityChanged({required bool visible}) {
    if (visible) {
      if (_controller == null) {
        _hasBeenVisible = true;
        _isLoading = true;
        _controller = WebViewController();
        unawaited(_initController());
        setState(() {});
      }
    } else {
      if (_controller != null) {
        _controller!.loadRequest(Uri.parse('about:blank'));
        _controller = null;
        setState(() {});
      }
    }
  }

  Future<void> _initController() async {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        await AndroidWebViewController.enableDebugging(true);
      } else if (Platform.isIOS) {
        final Object platform = _controller!.platform;
        if (platform is WebKitWebViewController) {
          await platform.setInspectable(true);
        }
      }
    }
    await _controller!.setJavaScriptMode(
      JavaScriptMode.unrestricted,
    );
    await _controller!.setBackgroundColor(Colors.transparent);
    await _controller!.addJavaScriptChannel(
      'FlutterHeight',
      onMessageReceived: (JavaScriptMessage message) {
        final h = double.tryParse(message.message);
        if (h != null && h > 0 && mounted) {
          setState(() => _contentHeight = h);
        }
      },
    );
    await _controller!.setOnConsoleMessage((JavaScriptConsoleMessage msg) {
      debugPrint('[WebView ${msg.level.name}] ${msg.message}');
    });
    await _controller!.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          _measureHeight();
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint(
            '[WebView error] ${error.errorCode}: '
            '${error.description} (${error.url})',
          );
        },
      ),
    );

    if (widget.src != null) {
      debugPrint('[WebView] loadRequest: ${widget.src}');
      await _controller!.loadRequest(
        Uri.parse(widget.src!),
      );
    } else if (widget.htmlData != null) {
      debugPrint('[WebView] loadHtmlString:\n${widget.htmlData}');
      await _controller!.loadHtmlString(
        widget.htmlData!,
        baseUrl: _baseUrlFromHtml(widget.htmlData!),
      );
    }
  }

  void _measureHeight() {
    _controller?.runJavaScript('''
(function() {
  var s = document.createElement('style');
  s.textContent = 'html,body{background:transparent!important}';
  (document.head || document.documentElement).appendChild(s);

  var h = document.documentElement.scrollHeight;
  if (h > 0) FlutterHeight.postMessage(String(h));
  new MutationObserver(function() {
    var nh = document.documentElement.scrollHeight;
    if (nh !== h) {
      h = nh;
      FlutterHeight.postMessage(String(h));
    }
  }).observe(document.body || document.documentElement,
    {childList: true, subtree: true, attributes: true});
})();
''');
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double viewHeight = _contentHeight ?? widget.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: viewHeight,
          child: _hasBeenVisible && _controller != null
              ? Stack(
                  children: <Widget>[
                    WebViewWidget(controller: _controller!),
                    if (_isLoading)
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
        if (widget.caption != null && widget.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
            ),
            child: Text(
              widget.caption!,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Extract origin from `<script src="...">` to use as baseUrl,
/// avoiding CORS `null` origin.
/// Prioritises `<script>` over `<link>` because the script origin
/// is what matters for CORS.
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
