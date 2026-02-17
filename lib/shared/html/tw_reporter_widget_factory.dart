import 'dart:convert' show base64Url, utf8;

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as dom;
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/shared/widgets/cached_image.dart';
import 'package:tw_reporter_app/shared/widgets/embedded_video_player.dart';
import 'package:tw_reporter_app/shared/widgets/embedded_webview.dart';
import 'package:tw_reporter_app/shared/widgets/image_diff_viewer.dart';
import 'package:tw_reporter_app/shared/widgets/slideshow_viewer.dart';
import 'package:tw_reporter_app/shared/widgets/tap_to_load_wrapper.dart';
import 'package:tw_reporter_app/shared/widgets/youtube_player_widget.dart';

/// Custom [WidgetFactory] for the TW Reporter app.
///
/// Handles all custom HTML tags produced by `convertContentToHtml`:
/// `embedded-video`, `embedded-iframe`, `embedded-webview`,
/// `embedded-youtube`, `imagediff`, `slideshow`, `quoteby`,
/// `infobox`, `ext-icon`.
class TwReporterWidgetFactory extends WidgetFactory {
  TwReporterWidgetFactory({this.isDataSaving = false});

  final bool isDataSaving;

  @override
  void parse(BuildTree tree) {
    final element = tree.element;
    final tag = element.localName;

    switch (tag) {
      case 'ext-icon':
        tree.register(
          BuildOp(
            debugLabel: 'ext-icon',
            alwaysRenderBlock: false,
            onParsed: (tree) {
              tree.append(
                WidgetBit.inline(
                  tree,
                  Builder(
                    builder: (context) => Icon(
                      Icons.open_in_new,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
              );
              return tree;
            },
          ),
        );
        return;

      case 'embedded-video':
        _registerBlockWidget(tree, _buildEmbeddedVideo(element));
        return;

      case 'embedded-iframe':
        _registerBlockWidget(tree, _buildEmbeddedIframe(element));
        return;

      case 'embedded-webview':
        _registerBlockWidget(tree, _buildEmbeddedWebview(element));
        return;

      case 'embedded-youtube':
        _registerBlockWidget(tree, _buildEmbeddedYoutube(element));
        return;

      case 'imagediff':
        _registerBlockWidget(tree, _buildImageDiff(element));
        return;

      case 'slideshow':
        _registerBlockWidget(tree, _buildSlideshow(element));
        return;

      case 'quoteby':
        tree.register(
          BuildOp(
            debugLabel: 'quoteby',
            onRenderBlock: (tree, placeholder) {
              return placeholder.wrapWith(
                (context, _) => _buildQuoteBy(context, element),
              );
            },
          ),
        );
        return;

      case 'infobox':
        tree.register(
          BuildOp(
            debugLabel: 'infobox',
            onRenderBlock: (tree, placeholder) {
              return placeholder.wrapWith(
                (context, _) => _buildInfobox(context, element),
              );
            },
          ),
        );
        return;

      case 'diffimg':
      case 'slide':
        // Handled by parent (imagediff / slideshow). Skip default parsing.
        return;
    }

    // Handle data-saving mode for images
    if (isDataSaving && tag == 'img') {
      final src = element.attributes['src'] ?? '';
      if (src.isNotEmpty) {
        _registerBlockWidget(tree, _buildDataSavingImage(src));
        return;
      }
    }

    super.parse(tree);
  }

  void _registerBlockWidget(BuildTree tree, Widget widget) {
    tree.register(
      BuildOp(
        debugLabel: tree.element.localName,
        onRenderBlock: (tree, placeholder) {
          return placeholder.wrapWith((_, _) => widget);
        },
      ),
    );
  }

  Widget _buildEmbeddedVideo(dom.Element element) {
    final src = element.attributes['src'] ?? '';
    final caption = element.attributes['caption'] ?? '';
    final autoplay = element.attributes['autoplay'] == 'true';
    final muted = element.attributes['muted'] == 'true';
    final loop = element.attributes['loop'] == 'true';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: TapToLoadWrapper(
        mediaType: MediaType.video,
        child: EmbeddedVideoPlayer(
          url: src,
          autoplay: autoplay,
          muted: muted,
          loop: loop,
          caption: caption.isNotEmpty ? caption : null,
        ),
      ),
    );
  }

  Widget _buildEmbeddedIframe(dom.Element element) {
    final src = element.attributes['src'] ?? '';
    final caption = element.attributes['caption'] ?? '';
    final height = double.tryParse(
      element.attributes['height'] ?? '',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: TapToLoadWrapper(
        mediaType: MediaType.webview,
        child: EmbeddedWebView(
          src: src,
          height: height,
          caption: caption.isNotEmpty ? caption : null,
        ),
      ),
    );
  }

  Widget _buildEmbeddedWebview(dom.Element element) {
    final data = element.attributes['data'] ?? '';
    final caption = element.attributes['caption'] ?? '';
    var htmlData = '';
    if (data.isNotEmpty) {
      try {
        htmlData = utf8.decode(base64Url.decode(data));
      } on FormatException catch (_) {
        // ignore decode errors
      }
    }
    if (htmlData.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: TapToLoadWrapper(
        mediaType: MediaType.webview,
        child: EmbeddedWebView(
          htmlData: htmlData,
          caption: caption.isNotEmpty ? caption : null,
        ),
      ),
    );
  }

  Widget _buildEmbeddedYoutube(dom.Element element) {
    final id = element.attributes['id'] ?? '';
    final caption = element.attributes['caption'] ?? '';
    if (id.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: TapToLoadWrapper(
        mediaType: MediaType.youtube,
        child: YoutubePlayerWidget(
          videoId: id,
          caption: caption.isNotEmpty ? caption : null,
        ),
      ),
    );
  }

  Widget _buildImageDiff(dom.Element element) {
    final images = <({String url, String desc})>[];
    for (final child in element.children) {
      if (child.localName == 'diffimg') {
        final src = child.attributes['src'] ?? '';
        final desc = child.attributes['desc'] ?? '';
        if (src.isNotEmpty) {
          images.add((url: src, desc: desc));
        }
      }
    }
    if (images.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: TapToLoadWrapper(
        mediaType: MediaType.imagediff,
        child: ImageDiffViewer(
          beforeUrl: images[0].url,
          afterUrl: images[1].url,
          beforeDesc: images[0].desc.isNotEmpty ? images[0].desc : null,
          afterDesc: images[1].desc.isNotEmpty ? images[1].desc : null,
        ),
      ),
    );
  }

  Widget _buildSlideshow(dom.Element element) {
    final slides = <SlideItem>[];
    for (final child in element.children) {
      if (child.localName == 'slide') {
        final src = child.attributes['src'] ?? '';
        final desc = child.attributes['desc'] ?? '';
        if (src.isNotEmpty) {
          slides.add((url: src, description: desc));
        }
      }
    }
    if (slides.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: TapToLoadWrapper(
        mediaType: MediaType.slideshow,
        child: SlideshowViewer(slides: slides),
      ),
    );
  }

  Widget _buildQuoteBy(BuildContext context, dom.Element element) {
    final quote = element.attributes['quote'] ?? '';
    final quoteByAuthor = element.attributes['quoteby-author'] ?? '';
    final colors = Theme.of(context).colorScheme;
    final textColor = colors.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: <Widget>[
          Container(
            width: 2,
            height: 80,
            color: AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            quote,
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: textColor,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (quoteByAuthor.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              '\u2500\u2500 $quoteByAuthor',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfobox(BuildContext context, dom.Element element) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: HtmlWidget(
        element.innerHtml,
        customStylesBuilder: _infoboxStylesBuilder,
        onTapUrl: (url) async {
          return false;
        },
        textStyle: TextStyle(
          fontSize: 14,
          height: 1.7,
          color: colors.onSurface,
        ),
      ),
    );
  }

  Widget _buildDataSavingImage(String src) {
    return TapToLoadWrapper(
      mediaType: MediaType.image,
      child: CachedImage(
        imageUrl: src,
        fit: BoxFit.contain,
        width: double.infinity,
        errorWidget: const AspectRatio(
          aspectRatio: 16 / 9,
          child: ColoredBox(
            color: AppColors.grey200,
            child: Icon(
              Icons.image_not_supported,
              color: AppColors.grey400,
            ),
          ),
        ),
      ),
    );
  }

  static Map<String, String>? _infoboxStylesBuilder(dom.Element element) {
    final tag = element.localName;
    switch (tag) {
      case 'h4':
        return <String, String>{
          'font-size': '17px',
          'font-weight': 'bold',
          'margin': '0 0 8px 0',
        };
      case 'p':
        return <String, String>{
          'font-size': '14px',
          'line-height': '1.7',
          'margin': '0 0 8px 0',
        };
      case 'a':
        return <String, String>{
          'text-decoration': 'underline',
        };
    }
    return null;
  }
}
