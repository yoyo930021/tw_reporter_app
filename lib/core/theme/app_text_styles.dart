import 'package:flutter/material.dart';
import 'package:tw_reporter_app/core/theme/app_colors.dart';

/// 應用程式文字樣式定義
class AppTextStyles {
  const AppTextStyles._();

  // 基礎字體
  static const String fontFamily = 'NotoSansTC';

  // 標題樣式
  /// 大標題 - 文章標題
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: 0.5,
  );

  /// 中標題 - 區塊標題
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: 0.25,
  );

  /// 小標題 - 卡片標題
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.15,
  );

  /// 副標題
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.15,
  );

  // 內文樣式
  /// 正文 - 文章內容
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.8,
    letterSpacing: 0.5,
  );

  /// 正文 - 次要內容
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.6,
    letterSpacing: 0.25,
  );

  /// 小字 - 標籤、時間戳等
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.4,
  );

  /// 極小字 - 版權聲明等
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 1.5,
  );

  // 按鈕樣式
  /// 按鈕文字
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 1.25,
  );

  // 特殊樣式
  /// 分類標籤
  static const TextStyle categoryTag = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// 時間戳
  static const TextStyle timestamp = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.2,
    letterSpacing: 0.4,
  );

  /// 錯誤訊息
  static const TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.error,
    letterSpacing: 0.25,
  );
}
