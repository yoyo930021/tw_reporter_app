import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/shared/composables/use_scroll_visibility.dart';
import 'package:tw_reporter_app/shared/composables/use_web_view_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const kWebviewDefaultHeight = 150.0;

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
    this.height = kWebviewDefaultHeight,
    this.caption,
    this.baseUrl,
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
  final double? height;

  /// Optional caption displayed below the WebView.
  final String? caption;

  /// Base URL for HTML mode. Used as the origin for CORS requests.
  final String? baseUrl;

  @override
  Widget build(BuildContext context) {
    return _EmbeddedWebViewContent(
      src: src,
      htmlData: htmlData,
      height: max(height ?? kWebviewDefaultHeight, kWebviewDefaultHeight),
      caption: caption,
      baseUrl: baseUrl,
    );
  }
}

class _EmbeddedWebViewContent extends CompositionWidget {
  const _EmbeddedWebViewContent({
    this.src,
    this.htmlData,
    this.height = 300,
    this.caption,
    this.baseUrl,
  });

  final String? src;
  final String? htmlData;
  final double height;
  final String? caption;
  final String? baseUrl;

  @override
  Widget Function(BuildContext) setup() {
    // Capture the latest BuildContext for showing dialogs from
    // the onExternalUrl callback (which fires asynchronously).
    BuildContext? dialogContext;

    final webView = useWebViewController(
      src: src,
      htmlData: htmlData,
      fallbackHeight: height,
      baseUrl: baseUrl,
      onExternalUrl: (uri) {
        final ctx = dialogContext;
        if (ctx == null || !ctx.mounted) return;
        unawaited(showDialog<void>(
          context: ctx,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('開啟外部連結'),
            content: Text('即將前往 ${uri.host}，是否繼續？'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  unawaited(
                    launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    ),
                  );
                },
                child: const Text('開啟'),
              ),
            ],
          ),
        ));
      },
    );

    final (visibilityKey, isVisible) = useScrollVisibility();

    watch(() => isVisible.value, (visible, _) {
      if (visible && webView.controller.value == null) {
        unawaited(webView.initialize());
      } else if (!visible && webView.controller.value != null) {
        webView.destroy();
      }
    });

    return (BuildContext context) {
      dialogContext = context;
      final colors = Theme.of(context).colorScheme;
      final controller = webView.controller.value;

      Widget content;
      if (controller != null) {
        content = Stack(
          children: <Widget>[
            WebViewWidget(controller: controller),
            if (webView.isLoading.value) _buildPlaceholder(context, colors),
          ],
        );
      } else {
        content = _buildPlaceholder(context, colors);
      }

      return Column(
        key: visibilityKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: min(max(webView.viewHeight.value, height), 3000),
            child: content,
          ),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
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

Widget _buildPlaceholder(BuildContext context, ColorScheme colors) {
  return ColoredBox(
    color: colors.surfaceContainer,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.web,
            color: colors.onSurfaceVariant,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '載入中…',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
