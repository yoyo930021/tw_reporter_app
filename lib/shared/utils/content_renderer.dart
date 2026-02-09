import 'dart:convert';

/// Remembered scripts/links from earlier embeddedcode blocks,
/// keyed by custom element tag name (e.g. `twreporter-layered-photos`).
class _ComponentAssets {
  final Map<String, ({String scripts, String links})> _registry =
      <String, ({String links, String scripts})>{};

  void store(String tag, {required String scripts, required String links}) {
    _registry[tag] = (scripts: scripts, links: links);
  }

  ({String scripts, String links})? lookup(String tag) => _registry[tag];
}

/// 將報導者 API 的結構化內容（content.api_data）轉換為 HTML 字串
String convertContentToHtml(Map<String, dynamic>? content) {
  if (content == null) return '';

  final apiData = content['api_data'] as List<dynamic>?;
  if (apiData == null || apiData.isEmpty) return '';

  final html = StringBuffer();
  final assets = _ComponentAssets();

  for (final dynamic block in apiData) {
    if (block is! Map<String, dynamic>) continue;

    final type = block['type'] as String? ?? 'unstyled';
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
      case 'youtube':
        _renderYoutube(html, blockContent);
      default:
        _renderUnsupported(html, type);
    }
  }

  return html.toString();
}

void _renderParagraph(StringBuffer html, dynamic content) {
  final text = _extractText(content);
  if (text.isNotEmpty) {
    html.write('<p>$text</p>');
  }
}

void _renderHeader(StringBuffer html, dynamic content, String tag) {
  final text = _extractText(content);
  if (text.isNotEmpty) {
    html.write('<$tag>$text</$tag>');
  }
}

void _renderBlockquote(StringBuffer html, dynamic content) {
  final text = _extractText(content);
  if (text.isNotEmpty) {
    html.write('<blockquote>$text</blockquote>');
  }
}

void _renderListItem(StringBuffer html, dynamic content,
    {required bool ordered}) {
  final text = _extractText(content);
  if (text.isNotEmpty) {
    final tag = ordered ? 'ol' : 'ul';
    html.write('<$tag><li>$text</li></$tag>');
  }
}

void _renderImage(StringBuffer html, dynamic content) {
  if (content is Map<String, dynamic>) {
    final url = _getImageUrl(content);
    final description = content['description'] as String? ?? '';
    if (url != null) {
      html
        ..write('<figure>')
        ..write('<img src="$url" alt="${_escapeHtml(description)}" />');
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
    final title = content['title'] as String?;
    final body = content['body'] as String?;
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

  final item =
      content[0] is Map<String, dynamic>
          ? content[0] as Map<String, dynamic>
          : null;
  if (item == null) {
    _renderUnsupported(html, 'embeddedcode');
    return;
  }

  final caption = item['caption'] as String? ?? '';
  var codeWithoutScript =
      item['embeddedCodeWithoutScript'] as String? ?? '';
  var fullCode =
      item['embeddedCode'] as String? ?? '';
  final rawHtml = codeWithoutScript.isNotEmpty
      ? codeWithoutScript
      : fullCode;

  // Detect standalone image: <img> or <picture> without scripts
  final imgMatch = RegExp(
    r'<img\s[^>]*src="([^"]*)"',
    caseSensitive: false,
  ).firstMatch(rawHtml);
  final hasScriptsEarly = fullCode.contains('<script') ||
      fullCode.contains('</script>');
  final hasCustomElementEarly = RegExp(
    r'<([a-z][a-z0-9]*-[a-z][\w-]*)',
  ).hasMatch(rawHtml);

  if (imgMatch != null && !hasScriptsEarly && !hasCustomElementEarly) {
    final imgUrl = imgMatch.group(1)!;
    final altMatch = RegExp(
      'alt="([^"]*)"',
      caseSensitive: false,
    ).firstMatch(rawHtml);
    final alt = altMatch?.group(1) ?? '';
    final description = caption.isNotEmpty ? caption : alt;
    final escapedUrl = _escapeHtml(imgUrl);
    final escapedDesc = _escapeHtml(description);
    html
      ..write('<figure>')
      ..write('<img src="$escapedUrl" alt="$escapedDesc" />')
      ..write('<figcaption>$escapedDesc</figcaption>')
      ..write('</figure>');
    return;
  }

  // Detect video: <source src="...mp4"> (also matches .mp4?query)
  final videoMatch = RegExp(
    r'<source\s[^>]*src="([^"]*\.mp4[^"]*)"',
    caseSensitive: false,
  ).firstMatch(rawHtml);

  if (videoMatch != null) {
    final videoUrl = videoMatch.group(1)!;
    final autoplay = RegExp(
      r'\bautoplay\b',
      caseSensitive: false,
    ).hasMatch(rawHtml);
    final muted = RegExp(
      r'\bmuted\b',
      caseSensitive: false,
    ).hasMatch(rawHtml);
    final loop = RegExp(
      r'\bloop\b',
      caseSensitive: false,
    ).hasMatch(rawHtml);
    final escapedUrl = _escapeHtml(videoUrl);
    final escapedCaption = _escapeHtml(caption);
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
  final iframeMatch = RegExp(
    r'<iframe\s[^>]*src="([^"]*)"',
    caseSensitive: false,
  ).firstMatch(rawHtml);

  if (iframeMatch != null) {
    final iframeSrc = iframeMatch.group(1)!;
    double height = 400;

    final heightPxMatch =
        RegExp(r'height:\s*(\d+)px').firstMatch(rawHtml);
    if (heightPxMatch != null) {
      height = double.tryParse(
            heightPxMatch.group(1)!,
          ) ??
          400;
    } else {
      final heightAttrMatch =
          RegExp(r'height[=:]\s*"?(\d+)')
              .firstMatch(rawHtml);
      if (heightAttrMatch != null) {
        height = double.tryParse(
              heightAttrMatch.group(1)!,
            ) ??
            400;
      }
      final vhMatch =
          RegExp(r'(\d+)vh').firstMatch(rawHtml);
      if (vhMatch != null) {
        final vh =
            double.tryParse(vhMatch.group(1)!) ?? 80;
        height = vh * 8;
      }
    }

    final escapedSrc = _escapeHtml(iframeSrc);
    final escapedCaption = _escapeHtml(caption);
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
  final hasScripts = fullCode.contains('<script') ||
      fullCode.contains('</script>');
  final customElementRe = RegExp(
    r'<([a-z][a-z0-9]*-[a-z][\w-]*)',
  );
  final customMatch =
      customElementRe.firstMatch('$rawHtml$fullCode');

  if (hasScripts || customMatch != null) {
    final tagName = customMatch?.group(1);

    // If this block has scripts/links, remember them for later blocks.
    if (tagName != null && hasScripts) {
      final scriptRe = RegExp(
        r'<script[^>]*>[\s\S]*?</script>',
        caseSensitive: false,
      );
      final linkRe = RegExp(
        r'<link\s[^>]*/?>',
        caseSensitive: false,
      );
      final src = fullCode.isNotEmpty ? fullCode : codeWithoutScript;
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

    final encoded = base64Url.encode(
      utf8.encode(
        _buildHtmlDocument(
          codeWithoutScript: codeWithoutScript,
          fullCode: fullCode,
        ),
      ),
    );
    final escapedCaption = _escapeHtml(caption);
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
      final url = _getImageUrl(item);
      final description =
          item['description'] as String? ?? '';
      if (url != null) {
        final escapedUrl = _escapeHtml(url);
        final escapedDesc = _escapeHtml(description);
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
      final url = _getImageUrl(item);
      final description =
          item['description'] as String? ?? '';
      if (url != null) {
        final escapedUrl = _escapeHtml(url);
        final escapedDesc = _escapeHtml(description);
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

void _renderYoutube(StringBuffer html, dynamic content) {
  if (content is! List || content.isEmpty) return;

  for (final dynamic item in content) {
    if (item is Map<String, dynamic>) {
      final youtubeId = item['youtubeId'] as String? ?? '';
      final description = item['description'] as String? ?? '';
      if (youtubeId.isNotEmpty) {
        // Strip tracking params (e.g. ?si=...) for the embed URL
        final cleanId = youtubeId.split('?').first;
        final escapedId = _escapeHtml(cleanId);
        final escapedDesc = _escapeHtml(description);
        html.write(
          '<embedded-youtube id="$escapedId" '
          'caption="$escapedDesc">'
          '</embedded-youtube>',
        );
      }
    }
  }
}

void _renderUnsupported(StringBuffer html, String type) {
  html.write(
    '<div style="padding:12px;margin:8px 0; '
    'background:#f5f5f5;border-radius:4px; '
    'text-align:center;color:#757575; '
    'font-size:14px;"> '
    '此內容格式未支援（$type），'
    '請至網頁版閱讀完整內容</div>',
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
    }).join();
  }
  return '';
}

/// Convert annotation HTML comments into custom `<anno>` tags
String _cleanAnnotations(String text) {
  // Convert <!--__ANNOTATION__={...}--><!--trigger--> into <anno> tags
  final result = text.replaceAllMapped(
    RegExp(r'<!--__ANNOTATION__=(\{[\s\S]*?\})--><!--([\s\S]*?)-->'),
    (m) {
      try {
        final jsonStr = m.group(1)!;
        final data =
            json.decode(jsonStr) as Map<String, dynamic>;
        final triggerText =
            data['text'] as String? ?? m.group(2)!;
        final annotationText =
            data['pureAnnotationText'] as String? ?? '';
        if (annotationText.isEmpty) return triggerText;
        final encodedContent = base64Url.encode(utf8.encode(annotationText));
        final encodedTrigger = base64Url.encode(utf8.encode(triggerText));
        return '<a href="anno://$encodedContent|$encodedTrigger">$triggerText ▼</a>';
      } on Object catch (_) {
        return m.group(2) ?? '';
      }
    },
  );
  // Remove any remaining HTML comments
  return result.replaceAll(
    RegExp('<!--.*?-->'),
    '',
  );
}

String? _getImageUrl(Map<String, dynamic> imageData) {
  // Prefer mobile size for app display
  final mobile =
      imageData['mobile'] as Map<String, dynamic>?;
  if (mobile != null && mobile['url'] != null) {
    return mobile['url'] as String;
  }
  final w400 =
      imageData['w400'] as Map<String, dynamic>?;
  if (w400 != null && w400['url'] != null) {
    return w400['url'] as String;
  }
  final tablet =
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
  final styleRe = RegExp(
    r'<style[^>]*>[\s\S]*?</style>',
    caseSensitive: false,
  );
  final linkRe = RegExp(
    r'<link\s[^>]*/?>',
    caseSensitive: false,
  );
  final scriptRe = RegExp(
    r'<script[^>]*>[\s\S]*?</script>',
    caseSensitive: false,
  );

  // Extract <style> and <link> from codeWithoutScript
  // (has styles but no scripts)
  final headSource =
      codeWithoutScript.isNotEmpty ? codeWithoutScript : fullCode;
  final styles =
      styleRe.allMatches(headSource).map((m) => m.group(0)!);
  final links =
      linkRe.allMatches(headSource).map((m) => m.group(0)!);

  // Extract <script> blocks from fullCode (has scripts)
  final scripts =
      scriptRe.allMatches(fullCode).map((m) => m.group(0)!);

  // Body = codeWithoutScript with <style>, <link>, <script> stripped out
  var body = codeWithoutScript.isNotEmpty ? codeWithoutScript : fullCode;
  body = body.replaceAll(styleRe, '');
  body = body.replaceAll(linkRe, '');
  body = body.replaceAll(scriptRe, '');

  final doc = StringBuffer()
    ..write('<!DOCTYPE html>')
    ..write('<html><head>')
    ..write('<meta charset="utf-8">')
    ..write('<meta name="viewport" '
        'content="width=device-width, initial-scale=1.0">')
    ..writeAll(styles)
    ..writeAll(links)
    ..write('</head>')
    ..write('<body style="margin:0;padding:0;">')
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
