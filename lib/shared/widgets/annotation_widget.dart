import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/theme/app_spacing.dart';

/// 可展開的註釋組件
/// 顯示觸發文字（如「（註）」），點擊後展開顯示詳細說明
class AnnotationWidget extends CompositionWidget {
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
  Widget Function(BuildContext) setup() {
    final expanded = ref(false);
    final props = widget();
    final theme = useTheme();

    String decodeContent() {
      try {
        return utf8.decode(base64Decode(props.value.contentBase64));
      } on Object catch (_) {
        return '';
      }
    }

    return (BuildContext context) {
      final colors = theme.value.colorScheme;
      final decodedContent = decodeContent();

      final arrow = expanded.value ? ' ▲' : ' ▼';
      final trigger = GestureDetector(
        onTap: () => expanded.value = !expanded.value,
        child: Text(
          '${props.value.triggerText}$arrow',
          style: props.value.textStyle.copyWith(
            color: props.value.linkColor,
            decoration: TextDecoration.underline,
            decorationColor: props.value.linkColor,
          ),
        ),
      );

      if (!expanded.value) return trigger;

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
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border(
                left: BorderSide(
                  color: props.value.linkColor,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              decodedContent,
              style: theme.value.textTheme.bodyMedium!.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
        ],
      );
    };
  }
}
