// ignore_for_file: missing_whitespace_between_adjacent_strings // Adjacent strings used intentionally for multi-line HTML test data

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tw_reporter_app/shared/utils/content_renderer.dart';

void main() {
  group('convertContentToHtml - embeddedcode', () {
    test('should render video with autoplay/muted/loop attributes', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'caption': '影片說明',
                'embeddedCodeWithoutScript':
                    '<div><video autoplay loop muted playsinline>'
                        '<source src="https://example.com/test.mp4" '
                        'type="video/mp4">'
                        '</video></div>',
                'embeddedCode':
                    '<div><video autoplay loop muted playsinline>'
                        '<source src="https://example.com/test.mp4" '
                        'type="video/mp4">'
                        '</video></div>',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<embedded-video'));
      expect(
        result,
        contains('src="https://example.com/test.mp4"'),
      );
      expect(result, contains('autoplay="true"'));
      expect(result, contains('muted="true"'));
      expect(result, contains('loop="true"'));
      expect(result, contains('caption="影片說明"'));
      expect(result, contains('</embedded-video>'));
    });

    test('should render video without autoplay when not present', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'caption': '',
                'embeddedCodeWithoutScript':
                    '<div><video><source src="https://example.com/v.mp4" '
                        'type="video/mp4"></video></div>',
                'embeddedCode':
                    '<div><video><source src="https://example.com/v.mp4" '
                        'type="video/mp4"></video></div>',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('autoplay="false"'));
      expect(result, contains('muted="false"'));
      expect(result, contains('loop="false"'));
    });

    test('should render iframe with height from style', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'caption': '互動地圖',
                'embeddedCodeWithoutScript':
                    '<iframe src="https://example.com/map" '
                        'style="width:100%;height:720px"></iframe>',
                'embeddedCode':
                    '<iframe src="https://example.com/map" '
                        'style="width:100%;height:720px"></iframe>',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<embedded-iframe'));
      expect(
        result,
        contains('src="https://example.com/map"'),
      );
      expect(result, contains('height="720"'));
      expect(result, contains('caption="互動地圖"'));
      expect(result, contains('</embedded-iframe>'));
    });

    test('should render iframe with vh height approximation', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'caption': '',
                'embeddedCodeWithoutScript':
                    '<iframe src="https://example.com/map"></iframe>'
                        '<style>iframe{height:80vh}</style>',
                'embeddedCode':
                    '<iframe src="https://example.com/map"></iframe>'
                        '<style>iframe{height:80vh}</style>',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<embedded-iframe'));
      // 80vh * 8 = 640
      expect(result, contains('height="640"'));
    });

    test('should render iframe with default height when none specified',
        () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'caption': '',
                'embeddedCodeWithoutScript':
                    '<iframe src="https://example.com/embed"></iframe>',
                'embeddedCode':
                    '<iframe src="https://example.com/embed"></iframe>',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('height="400"'));
    });

    test('should render custom component with scripts as webview', () {
      const fullCode = '<script type="module" '
          'src="https://example.com/widget.js"></script>'
          '<my-widget data="test"></my-widget>';

      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'caption': '互動圖表',
                'embeddedCodeWithoutScript':
                    '<my-widget data="test"></my-widget>',
                'embeddedCode': fullCode,
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<embedded-webview'));
      expect(result, contains('data="'));
      expect(result, contains('caption="互動圖表"'));
      expect(result, contains('</embedded-webview>'));

      // Verify the data attribute is valid base64 of a full HTML document
      final dataRegex = RegExp('data="([^"]*)"');
      final dataMatch = dataRegex.firstMatch(result);
      expect(dataMatch, isNotNull);
      final decoded = utf8.decode(
        base64Url.decode(dataMatch!.group(1)!),
      );
      expect(decoded, contains('<!DOCTYPE html>'));
      expect(decoded, contains('<my-widget data="test"></my-widget>'));
      expect(decoded, contains('<script'));
      expect(decoded, contains('</body></html>'));
    });

    test('should render custom web component without scripts as webview',
        () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'caption': '疊圖',
                'embeddedCodeWithoutScript':
                    '<style>.lp{width:100%}</style>'
                        '<twreporter-layered-photos '
                        'data="test"></twreporter-layered-photos>',
                'embeddedCode':
                    '<twreporter-layered-photos '
                        'data="test"></twreporter-layered-photos>',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<embedded-webview'));
      expect(result, contains('caption="疊圖"'));
      expect(result, contains('</embedded-webview>'));

      // Verify data decodes to a full HTML document
      final dataRegex = RegExp('data="([^"]*)"');
      final dataMatch = dataRegex.firstMatch(result);
      expect(dataMatch, isNotNull);
      final decoded = utf8.decode(
        base64Url.decode(dataMatch!.group(1)!),
      );
      expect(decoded, contains('<!DOCTYPE html>'));
      expect(decoded, contains('<twreporter-layered-photos'));
      expect(decoded, contains('<style>.lp{width:100%}</style>'));
    });

    test('should fallback to unsupported for unknown embedded content',
        () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'caption': '',
                'embeddedCodeWithoutScript': '<div>Hello</div>',
                'embeddedCode': '<div>Hello</div>',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('此內容格式未支援'));
    });

    test('should fallback to unsupported for empty content list', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <dynamic>[],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('此內容格式未支援'));
    });

    test('should fallback to unsupported for non-list content', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': 'not a list',
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('此內容格式未支援'));
    });

    test('should prefer embeddedCodeWithoutScript over embeddedCode', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'caption': '',
                'embeddedCodeWithoutScript':
                    '<iframe src="https://safe.com/embed">'
                        '</iframe>',
                'embeddedCode':
                    '<iframe src="https://safe.com/embed">'
                        '</iframe><script>alert("hi")</script>',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      // Should detect iframe from embeddedCodeWithoutScript
      expect(result, contains('<embedded-iframe'));
      expect(result, contains('src="https://safe.com/embed"'));
    });

    test('should escape HTML in caption', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'embeddedcode',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'caption': 'Test <b>bold</b> & "quotes"',
                'embeddedCodeWithoutScript':
                    '<video autoplay muted>'
                        '<source src="https://example.com/v.mp4">'
                        '</video>',
                'embeddedCode':
                    '<video autoplay muted>'
                        '<source src="https://example.com/v.mp4">'
                        '</video>',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(
        result,
        contains(
          'caption="Test &lt;b&gt;bold&lt;/b&gt; &amp; &quot;quotes&quot;"',
        ),
      );
    });
  });

  group('convertContentToHtml - imagediff', () {
    test('should render two images as diffimg custom tags', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'imagediff',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'description': '改造前',
                'mobile': <String, dynamic>{
                  'url': 'https://example.com/before.jpg',
                },
              },
              <String, dynamic>{
                'description': '改造後',
                'mobile': <String, dynamic>{
                  'url': 'https://example.com/after.jpg',
                },
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<imagediff>'));
      expect(result, contains('</imagediff>'));
      expect(
        result,
        contains('src="https://example.com/before.jpg"'),
      );
      expect(
        result,
        contains('src="https://example.com/after.jpg"'),
      );
      expect(result, contains('desc="改造前"'));
      expect(result, contains('desc="改造後"'));
      // Should have two diffimg tags
      expect(
        '<diffimg '.allMatches(result).length,
        equals(2),
      );
    });

    test('should handle empty imagediff content', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'imagediff',
            'content': <dynamic>[],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, isEmpty);
    });

    test('should handle imagediff with no description', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'imagediff',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'mobile': <String, dynamic>{
                  'url': 'https://example.com/img.jpg',
                },
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<imagediff>'));
      expect(result, contains('<diffimg'));
      expect(result, contains('desc=""'));
    });

    test('should prefer mobile image size', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'imagediff',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'description': '',
                'mobile': <String, dynamic>{
                  'url': 'https://example.com/mobile.jpg',
                },
                'desktop': <String, dynamic>{
                  'url': 'https://example.com/desktop.jpg',
                },
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(
        result,
        contains('src="https://example.com/mobile.jpg"'),
      );
    });
  });

  group('convertContentToHtml - quoteby', () {
    test('should render quoteby with quote and quoteBy', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'quoteby',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'quote': '引述文字內容',
                'quoteBy': '出處人名',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<quoteby'));
      expect(result, contains('quote="引述文字內容"'));
      expect(result, contains('quoteby-author="出處人名"'));
      expect(result, contains('</quoteby>'));
    });

    test('should render quoteby with empty quoteBy', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'quoteby',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'quote': '只有引述文字',
                'quoteBy': '',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<quoteby'));
      expect(result, contains('quote="只有引述文字"'));
      expect(result, contains('quoteby-author=""'));
    });

    test('should render quoteby with missing quoteBy field', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'quoteby',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'quote': '沒有出處欄位',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<quoteby'));
      expect(result, contains('quote="沒有出處欄位"'));
      expect(result, contains('quoteby-author=""'));
    });

    test('should not render quoteby with empty content', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'quoteby',
            'content': <dynamic>[],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, isEmpty);
    });

    test('should not render quoteby with non-list content', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'quoteby',
            'content': 'not a list',
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, isEmpty);
    });

    test('should escape HTML in quote and quoteBy', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'quoteby',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'quote': 'Test <b>bold</b> & "quotes"',
                'quoteBy': 'Author <script>alert("xss")</script>',
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(
        result,
        contains(
          'quote="Test &lt;b&gt;bold&lt;/b&gt; &amp; &quot;quotes&quot;"',
        ),
      );
      expect(
        result,
        contains(
          'quoteby-author="Author &lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;"',
        ),
      );
    });
  });

  group('convertContentToHtml - slideshow', () {
    test('should render slideshow with multiple slides', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'slideshow',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'description': '第一張',
                'mobile': <String, dynamic>{
                  'url': 'https://example.com/slide1.jpg',
                },
              },
              <String, dynamic>{
                'description': '第二張',
                'mobile': <String, dynamic>{
                  'url': 'https://example.com/slide2.jpg',
                },
              },
              <String, dynamic>{
                'description': '第三張',
                'mobile': <String, dynamic>{
                  'url': 'https://example.com/slide3.jpg',
                },
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, contains('<slideshow>'));
      expect(result, contains('</slideshow>'));
      expect(
        '<slide '.allMatches(result).length,
        equals(3),
      );
      expect(
        result,
        contains('src="https://example.com/slide1.jpg"'),
      );
      expect(
        result,
        contains('src="https://example.com/slide2.jpg"'),
      );
      expect(
        result,
        contains('src="https://example.com/slide3.jpg"'),
      );
      expect(result, contains('desc="第一張"'));
      expect(result, contains('desc="第二張"'));
      expect(result, contains('desc="第三張"'));
    });

    test('should handle empty slideshow content', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'slideshow',
            'content': <dynamic>[],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(result, isEmpty);
    });

    test('should escape HTML in slide descriptions', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'slideshow',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'description': 'Test <b>bold</b>',
                'mobile': <String, dynamic>{
                  'url': 'https://example.com/s.jpg',
                },
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect(
        result,
        contains('desc="Test &lt;b&gt;bold&lt;/b&gt;"'),
      );
    });

    test('should skip slides without image url', () {
      final content = <String, dynamic>{
        'api_data': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'slideshow',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'description': '有圖',
                'mobile': <String, dynamic>{
                  'url': 'https://example.com/s.jpg',
                },
              },
              <String, dynamic>{
                'description': '無圖',
                // no image urls
              },
            ],
          },
        ],
      };

      final result = convertContentToHtml(content);

      expect('<slide '.allMatches(result).length, equals(1));
      expect(result, contains('desc="有圖"'));
      expect(result, isNot(contains('desc="無圖"')));
    });
  });
}
