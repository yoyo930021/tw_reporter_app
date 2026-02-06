import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';
import 'package:tw_reporter_app/core/theme/app_text_styles.dart';

/// 可展開的註釋組件
/// 顯示觸發文字（如「（註）」），點擊後展開顯示詳細說明
class AnnotationWidget extends StatefulWidget {
  const AnnotationWidget({
    required this.triggerText,
    required this.contentBase64,
    required this.linkColor,
    required this.textStyle,
    super.key,
  });

  final String triggerText;
  final String contentBase64;
  final Color linkColor;
  final TextStyle textStyle;

  @override
  State<AnnotationWidget> createState() => _AnnotationWidgetState();
}

class _AnnotationWidgetState extends State<AnnotationWidget> {
  bool _expanded = false;

  String get _decodedContent {
    try {
      return utf8.decode(base64Decode(widget.contentBase64));
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final String arrow = _expanded ? ' ▲' : ' ▼';
    final Widget trigger = GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Text(
        '${widget.triggerText}$arrow',
        style: widget.textStyle.copyWith(
          color: widget.linkColor,
          decoration: TextDecoration.underline,
          decorationColor: widget.linkColor,
        ),
      ),
    );

    if (!_expanded) return trigger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        trigger,
        Container(
          margin: const EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : AppColors.grey100,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border(
              left: BorderSide(
                color: widget.linkColor,
                width: 3,
              ),
            ),
          ),
          child: Text(
            _decodedContent,
            style: AppTextStyles.body2.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
