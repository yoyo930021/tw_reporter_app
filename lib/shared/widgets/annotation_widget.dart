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

    final decodedContent = computed(() {
      try {
        return utf8.decode(base64Decode(props.value.contentBase64));
      } on Object catch (_) {
        return '';
      }
    });

    final arrow = computed(() => expanded.value ? ' ▲' : ' ▼');

    return (BuildContext context) => expanded.value
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _AnnotationTrigger(
                props: props,
                arrow: arrow,
                onTap: () => expanded.value = !expanded.value,
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: AppSpacing.xs,
                  bottom: AppSpacing.sm,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.value.colorScheme.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border(
                    left: BorderSide(
                      color: props.value.linkColor,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  decodedContent.value,
                  style: theme.value.textTheme.bodyMedium!.copyWith(
                    color: theme.value.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          )
        : _AnnotationTrigger(
            props: props,
            arrow: arrow,
            onTap: () => expanded.value = !expanded.value,
          );
  }
}

class _AnnotationTrigger extends StatelessWidget {
  const _AnnotationTrigger({
    required this.props,
    required this.arrow,
    required this.onTap,
  });

  final ReadonlyRef<AnnotationWidget> props;
  final ReadonlyRef<String> arrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        '${props.value.triggerText}${arrow.value}',
        style: props.value.textStyle.copyWith(
          color: props.value.linkColor,
          decoration: TextDecoration.underline,
          decorationColor: props.value.linkColor,
        ),
      ),
    );
  }
}
