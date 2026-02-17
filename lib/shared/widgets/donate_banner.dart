import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:tw_reporter_app/core/services/donate_text_service.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 贊助報導者橫幅
///
/// 可用於首頁底部和文章底部，點擊開啟贊助頁面
/// 文字內容從報導者官網動態抓取，支援快取和 fallback
///
/// [pagePath] 指定從哪個頁面抓取贊助區塊：
/// - `'/'` 首頁（預設）
/// - `'/a/{slug}'` 文章頁面
class DonateBanner extends StatelessWidget {
  DonateBanner({
    super.key,
    this.pagePath = '/',
    DonateTextService? service,
  }) : _service = service ?? DonateTextService.instance;

  /// 要抓取贊助內容的頁面路徑
  final String pagePath;

  final DonateTextService _service;

  @override
  Widget build(BuildContext context) {
    return _DonateBannerContent(
      pagePath: pagePath,
      service: _service,
    );
  }
}

class _DonateBannerContent extends CompositionWidget {
  const _DonateBannerContent({
    required this.pagePath,
    required this.service,
  });

  final String pagePath;
  final DonateTextService service;

  /// Injects inline styles into the HTML.
  ///
  /// Title is identified by `<h3>` tag or class containing
  /// "Title" (article pages use `<p class="...Title...">`)
  /// and styled differently from body text.
  static String _styledHtml(String html) {
    const titleStyle = 'color:#fff;font-size:20px;'
        'font-weight:bold;text-align:center;'
        'margin:0;padding:0;';
    const textStyle = 'color:rgba(255,255,255,0.7);'
        'font-size:14px;line-height:1.6;'
        'margin:12px 0 0 0;padding:0;';

    // Remove the donate button div (class contains "Donate")
    // since we have our own native button.
    final result = html.replaceAll(
      RegExp('<div [^>]*class="[^"]*Donate[^"]*"[^>]*>.*?</div>',
          dotAll: true),
      '',
    );

    // Replace tags with inline styles using regex to
    // avoid double-replacement issues.
    return result
        // h3 tags → title style
        .replaceAllMapped(
          RegExp('<h3([> ])'),
          (m) => '<h3 style="$titleStyle"${m[1]}',
        )
        // p tags with "Title" in class → title style
        .replaceAllMapped(
          RegExp('<p ([^>]*class="[^"]*Title[^"]*"[^>]*)>'),
          (m) => '<p ${m[1]} style="$titleStyle">',
        )
        // remaining p tags → text style
        .replaceAllMapped(
          RegExp('<p([ >])(?![^>]*style=)'),
          (m) => '<p style="$textStyle"${m[1]}',
        );
  }

  @override
  Widget Function(BuildContext) setup() {
    final data = ref<DonateTextData>(DonateTextService.defaultData);

    onMounted(() async {
      data.value = await service.fetch(pagePath: pagePath);
    });

    void openDonation() {
      unawaited(launchUrl(
        Uri.parse(data.value.buttonUrl),
        mode: LaunchMode.inAppBrowserView,
      ));
    }

    return (BuildContext context) {
      return Padding(
        padding: AppSpacing.edgeInsetsHorizontalMd,
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: AppColors.primary,
          child: Padding(
            padding: AppSpacing.edgeInsetsLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                HtmlWidget(
                  _styledHtml(data.value.html),
                  onTapUrl: (url) async {
                    if (url.isNotEmpty) {
                      unawaited(launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.inAppBrowserView,
                      ));
                    }
                    return true;
                  },
                  customStylesBuilder: (element) {
                    final tag = element.localName;
                    if (tag == 'a') {
                      return <String, String>{
                        'color': '#E67E22',
                        'text-decoration': 'underline',
                      };
                    }
                    if (tag == 'svg') {
                      return <String, String>{'display': 'none'};
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalSpacerMd,
                Center(
                  child: FilledButton.icon(
                    onPressed: openDonation,
                    icon: const Icon(Icons.favorite, size: 18),
                    label: const Text('贊助報導者'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    };
  }
}
