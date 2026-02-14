/// 媒體載入模式
enum MediaLoadMode {
  /// 所有媒體需點擊才載入（省流量，包含圖片）
  dataSaving,

  /// 媒體自動載入（預設，影片捲動到可見才初始化）
  normal,

  /// 預先載入所有媒體（影片立即初始化，WebView 立即載入）
  preloadAll,
}
