import 'dart:async';

import 'package:flutter_compositions/flutter_compositions.dart';

/// 防抖 Composable
///
/// 用於延遲執行回調函數，並在快速連續呼叫時取消前一次的計時器
///
/// ## 使用範例
///
/// ```dart
/// final debouncedSearch = useDebounce(
///   () => performSearch(query),
///   delay: const Duration(milliseconds: 500),
/// );
///
/// // 在搜尋輸入框中使用
/// TextField(
///   onChanged: (value) {
///     query = value;
///     debouncedSearch();  // 延遲 500ms 後執行搜尋
///   },
/// );
/// ```
///
/// ## 參數
///
/// - [callback]: 要延遲執行的回調函數
/// - [delay]: 延遲時間，預設為 500ms
///
/// ## 返回值
///
/// 返回一個防抖後的函數，呼叫它會：
/// 1. 取消前一次的計時器（如果存在）
/// 2. 啟動新的計時器
/// 3. 在延遲時間後執行 callback
void Function() useDebounce(
  void Function() callback, {
  Duration delay = const Duration(milliseconds: 500),
}) {
  // 儲存計時器的 ref
  Timer? timer;

  // 返回防抖後的函數
  void debouncedFunction() {
    // 取消前一次的計時器
    timer?.cancel();

    // 啟動新的計時器
    timer = Timer(delay, callback);
  }

  // 在組件 dispose 時取消計時器
  onUnmounted(() {
    timer?.cancel();
  });

  return debouncedFunction;
}
