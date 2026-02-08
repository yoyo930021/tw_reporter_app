import 'package:flutter/widgets.dart';

/// 應用程式間距常數
class AppSpacing {
  const AppSpacing._();

  /// 極小間距 - 4px
  static const double xs = 4;

  /// 小間距 - 8px
  static const double sm = 8;

  /// 中間距 - 16px
  static const double md = 16;

  /// 大間距 - 24px
  static const double lg = 24;

  /// 極大間距 - 32px
  static const double xl = 32;

  /// 超大間距 - 48px
  static const double xxl = 48;

  /// 常用的 EdgeInsets
  /// 無間距
  static const EdgeInsets edgeInsetsZero = EdgeInsets.zero;

  /// 極小全邊距 - 4px
  static const EdgeInsets edgeInsetsXs = EdgeInsets.all(xs);

  /// 小全邊距 - 8px
  static const EdgeInsets edgeInsetsSm = EdgeInsets.all(sm);

  /// 中全邊距 - 16px
  static const EdgeInsets edgeInsetsMd = EdgeInsets.all(md);

  /// 大全邊距 - 24px
  static const EdgeInsets edgeInsetsLg = EdgeInsets.all(lg);

  /// 極大全邊距 - 32px
  static const EdgeInsets edgeInsetsXl = EdgeInsets.all(xl);

  /// 水平間距 - 16px
  static const EdgeInsets edgeInsetsHorizontalMd =
      EdgeInsets.symmetric(horizontal: md);

  /// 垂直間距 - 16px
  static const EdgeInsets edgeInsetsVerticalMd =
      EdgeInsets.symmetric(vertical: md);

  /// 頁面邊距 - 水平 16px, 垂直 8px
  static const EdgeInsets edgeInsetsPage = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// 卡片內邊距 - 16px
  static const EdgeInsets edgeInsetsCard = EdgeInsets.all(md);

  /// 列表項目邊距 - 水平 16px, 垂直 12px
  static const EdgeInsets edgeInsetsListItem = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 12,
  );

  /// 常用的 SizedBox
  /// 水平間距盒 - 4px
  static const SizedBox horizontalSpacerXs = SizedBox(width: xs);

  /// 水平間距盒 - 8px
  static const SizedBox horizontalSpacerSm = SizedBox(width: sm);

  /// 水平間距盒 - 16px
  static const SizedBox horizontalSpacerMd = SizedBox(width: md);

  /// 水平間距盒 - 24px
  static const SizedBox horizontalSpacerLg = SizedBox(width: lg);

  /// 垂直間距盒 - 4px
  static const SizedBox verticalSpacerXs = SizedBox(height: xs);

  /// 垂直間距盒 - 8px
  static const SizedBox verticalSpacerSm = SizedBox(height: sm);

  /// 垂直間距盒 - 16px
  static const SizedBox verticalSpacerMd = SizedBox(height: md);

  /// 垂直間距盒 - 24px
  static const SizedBox verticalSpacerLg = SizedBox(height: lg);

  /// 垂直間距盒 - 32px
  static const SizedBox verticalSpacerXl = SizedBox(height: xl);

  /// 常用的圓角半徑
  /// 小圓角 - 4px
  static const double radiusSm = 4;

  /// 中圓角 - 8px
  static const double radiusMd = 8;

  /// 大圓角 - 12px
  static const double radiusLg = 12;

  /// 極大圓角 - 16px
  static const double radiusXl = 16;

  /// 圓形
  static const double radiusFull = 9999;
}
