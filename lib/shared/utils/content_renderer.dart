import 'dart:convert';

/// Remembered scripts/links from earlier embeddedcode blocks,
/// keyed by custom element tag name (e.g. `twreporter-layered-photos`).
class _ComponentAssets {
  final Map<String, ({String scripts, String links})> _registry = {};

  void store(String tag, {required String scripts, required String links}) {
    _registry[tag] = (scripts: scripts, links: links);
  }

  ({String scripts, String links})? lookup(String tag) => _registry[tag];
}

/// 將報導者 API 的結構化內容（content.api_data）轉換為 HTML 字串
String convertContentToHtml(Map<String, dynamic>? content) {
  if (content == null) return '';

  final List<dynamic>? apiData = content['api_data'] as List<dynamic>?;
  if (apiData == null || apiData.isEmpty) return '';

  final StringBuffer html = StringBuffer();
  final _ComponentAssets assets = _ComponentAssets();

  for (final dynamic block in apiData) {
    if (block is! Map<String, dynamic>) continue;

    final String type = block['type'] as String? ?? 'unstyled';
    final dynamic blockContent = block['content'];

    switch (type) {
      case 'unstyled':
      case 'annotation':
        _renderParagraph(html, blockContent);
      case 'header-one':
        _renderHeader(html, blockContent, 'h1');
      case 'header-two':
        _renderHeader(html, blockContent, 'h2');
      case 'header-three':
        _renderHeader(html, blockContent, 'h3');
      case 'header-four':
        _renderHeader(html, blockContent, 'h4');
      case 'blockquote':
        _renderBlockquote(html, blockContent);
      case 'unordered-list-item':
        _renderListItem(html, blockContent, ordered: false);
      case 'ordered-list-item':
        _renderListItem(html, blockContent, ordered: true);
      case 'image':
        _renderImage(html, blockContent);
      case 'infobox':
        _renderInfobox(html, blockContent);
      case 'embeddedcode':
        _renderEmbeddedCode(html, blockContent, assets);
      case 'imagediff':
        _renderImageDiff(html, blockContent);
      case 'slideshow':
        _renderSlideshow(html, blockContent);
      default:
        _renderUnsupported(html, type);
    }
  }

  return html.toString();
}

void _renderParagraph(StringBuffer html, dynamic content) {
  final String text = _extractText(content);
  if (text.isNotEmpty) {
    html.write('<p>$text</p>');
  }
}

void _renderHeader(StringBuffer html, dynamic content, String tag) {
  final String text = _extractText(content);
  if (text.isNotEmpty) {
    html.write('<$tag>$text</$tag>');
  }
}

void _renderBlockquote(StringBuffer html, dynamic content) {
  final String text = _extractText(content);
  if (text.isNotEmpty) {
    html.write('<blockquote>$text</blockquote>');
  }
}

void _renderListItem(StringBuffer html, dynamic content,
    {required bool ordered}) {
  final String text = _extractText(content);
  if (text.isNotEmpty) {
    final String tag = ordered ? 'ol' : 'ul';
    html.write('<$tag><li>$text</li></$tag>');
  }
}

void _renderImage(StringBuffer html, dynamic content) {
  if (content is Map<String, dynamic>) {
    final String? url = _getImageUrl(content);
    final String description = content['description'] as String? ?? '';
    if (url != null) {
      html.write('<figure>');
      html.write('<img src="$url" alt="${_escapeHtml(description)}" />');
      if (description.isNotEmpty) {
        html.write('<figcaption>$description</figcaption>');
      }
      html.write('</figure>');
    }
  } else if (content is List) {
    for (final dynamic item in content) {
      if (item is Map<String, dynamic>) {
        _renderImage(html, item);
      }
    }
  }
}

void _renderInfobox(StringBuffer html, dynamic content) {
  if (content is Map<String, dynamic>) {
    final String? title = content['title'] as String?;
    final String? body = content['body'] as String?;
    html.write('<infobox>');
    if (title != null && title.isNotEmpty) {
      html.write('<h4>$title</h4>');
    }
    if (body != null && body.isNotEmpty) {
      html.write(body);
    }
    html.write('</infobox>');
  } else if (content is List) {
    for (final dynamic item in content) {
      if (item is Map<String, dynamic>) {
        _renderInfobox(html, item);
      }
    }
  }
}

void _renderEmbeddedCode(
  StringBuffer html,
  dynamic content,
  _ComponentAssets assets,
) {
  if (content is! List || content.isEmpty) {
    _renderUnsupported(html, 'embeddedcode');
    return;
  }

  final Map<String, dynamic>? item =
      content[0] is Map<String, dynamic>
          ? content[0] as Map<String, dynamic>
          : null;
  if (item == null) {
    _renderUnsupported(html, 'embeddedcode');
    return;
  }

  final String caption = item['caption'] as String? ?? '';
  String codeWithoutScript =
      item['embeddedCodeWithoutScript'] as String? ?? '';
  String fullCode =
      item['embeddedCode'] as String? ?? '';
  final String rawHtml = codeWithoutScript.isNotEmpty
      ? codeWithoutScript
      : fullCode;

  // Detect video: <source src="...mp4">
  final RegExpMatch? videoMatch = RegExp(
    r'<source\s[^>]*src="([^"]*\.mp4)"',
    caseSensitive: false,
  ).firstMatch(rawHtml);

  if (videoMatch != null) {
    final String videoUrl = videoMatch.group(1)!;
    final bool autoplay = RegExp(
      r'\bautoplay\b',
      caseSensitive: false,
    ).hasMatch(rawHtml);
    final bool muted = RegExp(
      r'\bmuted\b',
      caseSensitive: false,
    ).hasMatch(rawHtml);
    final bool loop = RegExp(
      r'\bloop\b',
      caseSensitive: false,
    ).hasMatch(rawHtml);
    final String escapedUrl = _escapeHtml(videoUrl);
    final String escapedCaption = _escapeHtml(caption);
    html.write(
      '<embedded-video src="$escapedUrl" '
      'autoplay="$autoplay" muted="$muted" '
      'loop="$loop" '
      'caption="$escapedCaption">'
      '</embedded-video>',
    );
    return;
  }

  // Detect iframe
  final RegExpMatch? iframeMatch = RegExp(
    r'<iframe\s[^>]*src="([^"]*)"',
    caseSensitive: false,
  ).firstMatch(rawHtml);

  if (iframeMatch != null) {
    final String iframeSrc = iframeMatch.group(1)!;
    double height = 400;

    final RegExpMatch? heightPxMatch =
        RegExp(r'height:\s*(\d+)px').firstMatch(rawHtml);
    if (heightPxMatch != null) {
      height = double.tryParse(
            heightPxMatch.group(1)!,
          ) ??
          400;
    } else {
      final RegExpMatch? heightAttrMatch =
          RegExp(r'height[=:]\s*"?(\d+)')
              .firstMatch(rawHtml);
      if (heightAttrMatch != null) {
        height = double.tryParse(
              heightAttrMatch.group(1)!,
            ) ??
            400;
      }
      final RegExpMatch? vhMatch =
          RegExp(r'(\d+)vh').firstMatch(rawHtml);
      if (vhMatch != null) {
        final double vh =
            double.tryParse(vhMatch.group(1)!) ?? 80;
        height = vh * 8;
      }
    }

    final String escapedSrc = _escapeHtml(iframeSrc);
    final String escapedCaption = _escapeHtml(caption);
    html.write(
      '<embedded-iframe '
      'src="$escapedSrc" '
      'height="${height.toInt()}" '
      'caption="$escapedCaption">'
      '</embedded-iframe>',
    );
    return;
  }

  // Custom component with scripts, or custom web component (tag with hyphen)
  final bool hasScripts = fullCode.contains('<script') ||
      fullCode.contains('</script>');
  final RegExp customElementRe = RegExp(
    r'<([a-z][a-z0-9]*-[a-z][\w-]*)',
  );
  final RegExpMatch? customMatch =
      customElementRe.firstMatch('$rawHtml$fullCode');

  if (hasScripts || customMatch != null) {
    final String? tagName = customMatch?.group(1);

    // If this block has scripts/links, remember them for later blocks.
    if (tagName != null && hasScripts) {
      final RegExp scriptRe = RegExp(
        r'<script[^>]*>[\s\S]*?</script>',
        caseSensitive: false,
      );
      final RegExp linkRe = RegExp(
        r'<link\s[^>]*/?>',
        caseSensitive: false,
      );
      final String src = fullCode.isNotEmpty ? fullCode : codeWithoutScript;
      assets.store(
        tagName,
        scripts: scriptRe.allMatches(src).map((m) => m.group(0)!).join(),
        links: linkRe.allMatches(src).map((m) => m.group(0)!).join(),
      );
    }

    // If this block has no scripts, inject remembered assets.
    if (!hasScripts && tagName != null) {
      final stored = assets.lookup(tagName);
      if (stored != null) {
        fullCode = '${stored.scripts}$fullCode';
        codeWithoutScript = '${stored.links}$codeWithoutScript';
      }
    }

    final String encoded = base64Url.encode(
      utf8.encode(
        _buildHtmlDocument(
          codeWithoutScript: codeWithoutScript,
          fullCode: fullCode,
        ),
      ),
    );
    final String escapedCaption = _escapeHtml(caption);
    html.write(
      '<embedded-webview data="$encoded" '
      'caption="$escapedCaption">'
      '</embedded-webview>',
    );
    return;
  }

  _renderUnsupported(html, 'embeddedcode');
}

void _renderImageDiff(StringBuffer html, dynamic content) {
  if (content is! List || content.isEmpty) return;

  html.write('<imagediff>');
  for (final dynamic item in content) {
    if (item is Map<String, dynamic>) {
      final String? url = _getImageUrl(item);
      final String description =
          item['description'] as String? ?? '';
      if (url != null) {
        final String escapedUrl = _escapeHtml(url);
        final String escapedDesc = _escapeHtml(description);
        html.write(
          '<diffimg src="$escapedUrl" '
          'desc="$escapedDesc">'
          '</diffimg>',
        );
      }
    }
  }
  html.write('</imagediff>');
}

void _renderSlideshow(StringBuffer html, dynamic content) {
  if (content is! List || content.isEmpty) return;

  html.write('<slideshow>');
  for (final dynamic item in content) {
    if (item is Map<String, dynamic>) {
      final String? url = _getImageUrl(item);
      final String description =
          item['description'] as String? ?? '';
      if (url != null) {
        final String escapedUrl = _escapeHtml(url);
        final String escapedDesc = _escapeHtml(description);
        html.write(
          '<slide src="$escapedUrl" '
          'desc="$escapedDesc">'
          '</slide>',
        );
      }
    }
  }
  html.write('</slideshow>');
}

void _renderUnsupported(StringBuffer html, String type) {
  html.write(
    '<div style="padding:12px;margin:8px 0;background:#f5f5f5;border-radius:4px;text-align:center;color:#757575;font-size:14px;">'
    '此內容格式未支援（$type），請至網頁版閱讀完整內容'
    '</div>',
  );
}

String _extractText(dynamic content) {
  if (content is String) {
    return _cleanAnnotations(content);
  }
  if (content is List) {
    return content.map((dynamic item) {
      if (item is String) {
        return _cleanAnnotations(item);
      }
      return '';
    }).join('');
  }
  return '';
}

/// Convert annotation HTML comments into custom <anno> tags
String _cleanAnnotations(String text) {
  // Convert <!--__ANNOTATION__={...}--><!--trigger--> into <anno> tags
  text = text.replaceAllMapped(
    RegExp(r'<!--__ANNOTATION__=(\{[\s\S]*?\})--><!--([\s\S]*?)-->'),
    (Match m) {
      try {
        final String jsonStr = m.group(1)!;
        final Map<String, dynamic> data =
            json.decode(jsonStr) as Map<String, dynamic>;
        final String triggerText =
            data['text'] as String? ?? m.group(2)!;
        final String annotationText =
            data['pureAnnotationText'] as String? ?? '';
        if (annotationText.isEmpty) return triggerText;
        final String encodedContent = base64Url.encode(utf8.encode(annotationText));
        final String encodedTrigger = base64Url.encode(utf8.encode(triggerText));
        return '<a href="anno://$encodedContent|$encodedTrigger">$triggerText ▼</a>';
      } catch (_) {
        return m.group(2) ?? '';
      }
    },
  );
  // Remove any remaining HTML comments
  text = text.replaceAll(
    RegExp(r'<!--.*?-->'),
    '',
  );
  return text;
}

String? _getImageUrl(Map<String, dynamic> imageData) {
  // Prefer mobile size for app display
  final Map<String, dynamic>? mobile =
      imageData['mobile'] as Map<String, dynamic>?;
  if (mobile != null && mobile['url'] != null) {
    return mobile['url'] as String;
  }
  final Map<String, dynamic>? w400 =
      imageData['w400'] as Map<String, dynamic>?;
  if (w400 != null && w400['url'] != null) {
    return w400['url'] as String;
  }
  final Map<String, dynamic>? tablet =
      imageData['tablet'] as Map<String, dynamic>?;
  if (tablet != null && tablet['url'] != null) {
    return tablet['url'] as String;
  }
  return imageData['url'] as String?;
}

/// Build a proper HTML document from embedded code parts.
///
/// Extracts `<style>` and `<link>` into `<head>`, places markup in `<body>`,
/// and puts `<script>` before `</body>`.
String _buildHtmlDocument({
  required String codeWithoutScript,
  required String fullCode,
}) {
  final RegExp styleRe = RegExp(
    r'<style[^>]*>[\s\S]*?</style>',
    caseSensitive: false,
  );
  final RegExp linkRe = RegExp(
    r'<link\s[^>]*/?>',
    caseSensitive: false,
  );
  final RegExp scriptRe = RegExp(
    r'<script[^>]*>[\s\S]*?</script>',
    caseSensitive: false,
  );

  // Extract <style> and <link> from codeWithoutScript (has styles but no scripts)
  final String headSource =
      codeWithoutScript.isNotEmpty ? codeWithoutScript : fullCode;
  final Iterable<String> styles =
      styleRe.allMatches(headSource).map((m) => m.group(0)!);
  final Iterable<String> links =
      linkRe.allMatches(headSource).map((m) => m.group(0)!);

  // Extract <script> blocks from fullCode (has scripts)
  final Iterable<String> scripts =
      scriptRe.allMatches(fullCode).map((m) => m.group(0)!);

  // Body = codeWithoutScript with <style>, <link>, <script> stripped out
  String body = codeWithoutScript.isNotEmpty ? codeWithoutScript : fullCode;
  body = body.replaceAll(styleRe, '');
  body = body.replaceAll(linkRe, '');
  body = body.replaceAll(scriptRe, '');

  final StringBuffer doc = StringBuffer()
    ..write('<!DOCTYPE html>')
    ..write('<html><head>')
    ..write('<meta charset="utf-8">')
    ..write('<meta name="viewport" '
        'content="width=device-width, initial-scale=1.0">')
    ..write('<style>html,body{background:transparent!important;'
        'margin:0;padding:0;}</style>')
    ..writeAll(styles)
    ..writeAll(links)
    ..write('</head>')
    ..write('<body>')
    ..write(body)
    ..writeAll(scripts)
    ..write('</body></html>');

  return doc.toString();
}

String _escapeHtml(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
