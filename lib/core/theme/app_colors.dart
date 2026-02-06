import 'package:flutter/material.dart';

/// 應用程式顏色定義
/// 基於報導者品牌色系設計
class AppColors {
  const AppColors._();

  // 主要品牌色
  /// 報導者主色 - 深藍色
  static const Color primary = Color(0xFF04295E);

  /// 報導者次要色 - 橘色
  static const Color secondary = Color(0xFFE67E22);

  /// 強調色 - 紅色（用於重要新聞、警示）
  static const Color accent = Color(0xFFE74C3C);

  // 灰階
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // 語意化顏色
  /// 成功狀態
  static const Color success = Color(0xFF27AE60);

  /// 警告狀態
  static const Color warning = Color(0xFFF39C12);

  /// 錯誤狀態
  static const Color error = Color(0xFFE74C3C);

  /// 資訊提示
  static const Color info = Color(0xFF3498DB);

  // 文字顏色（亮色主題）
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // 文字顏色（暗色主題）
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);

  // 背景顏色
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // 分隔線
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // 分類顏色（用於不同新聞分類的標籤）
  static const Map<String, Color> categoryColors = <String, Color>{
    'culture': Color(0xFF9B59B6),
    'econ': Color(0xFF3498DB),
    'education': Color(0xFF1ABC9C),
    'environment': Color(0xFF27AE60),
    'health': Color(0xFFE74C3C),
    'humanrights': Color(0xFFE67E22),
    'politics_and_society': Color(0xFF34495E),
    'world': Color(0xFF2C3E50),
  };
}
