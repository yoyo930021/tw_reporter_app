# 閱報導者 - AI 開發注意事項

## 核心開發原則（必須嚴格遵守）

1. **TDD 開發法**：先寫測試，再寫實作。所有新功能都必須有對應的測試
2. **Lint 零容忍**：每次改動後必須確保 `fvm flutter analyze` 零 error
3. **測試全通過**：每次改動後必須確保 `fvm flutter test --no-pub` 全部通過
4. 開發流程：寫測試 → 確認測試失敗 → 寫實作 → 確認測試通過 → 確認 lint 通過

## 專案架構

- **fvm** 管理 Flutter SDK，所有指令用 `fvm` 前綴（`fvm dart`、`fvm flutter`）
- **flutter_compositions**（CompositionWidget, ref, computed, watch, onMounted）
- **auto_route** 路由管理，路由定義在 `lib/core/router/app_router.dart`
- **Retrofit + Dio** API 客戶端，定義在 `lib/core/api/tw_reporter_api.dart`
- **shared_preferences** 本地儲存（閱讀記錄、收藏、設定）

## 編碼規範

- snake_case JSON keys + `@JsonKey` 註解
- freezed models + build_runner：`fvm dart run build_runner build --delete-conflicting-outputs`
- 主題使用 `Theme.of(context).colorScheme.*`，**不用** isDark 判斷
- `useTextEditingController()` 返回 tuple `(controller, textRef, editingValueRef)`

## API 注意事項

- Base URL: `https://go-api.twreporter.org/v2`
- Extension methods（fetchLatestArticles, fetchCategoryArticles, searchArticles, fetchTopicsByPage）為**客戶端過濾**，非伺服器端
- 測試必須 mock 底層 API 方法（fetchPosts / fetchPost / fetchTopics），**不能** mock extension method
- Response 包裝：
  - `fetchPosts` → `ListResponse<Article>`
  - `fetchPost` → `ApiResponse<Article>`
  - `fetchIndexPage` → `ApiResponse<IndexPageData>`

## WebView 注意事項

- 滾動修復只在 macOS/iOS（WebKit）
- baseUrl 設定 origin 讓嵌入內容正常（如 YouTube）
- 外部連結需確認對話框

## 路由架構

```
MainShellRoute (/)
├── HomeRoute ('') - 含搜尋列
├── LatestRoute ('latest')
├── TopicsRoute ('topics')
├── MyReadingRoute ('myreading')
└── MenuRoute ('menu')

ArticleRoute ('/a/:slug')
TopicDetailRoute ('/topics/:slug')
CategoryRoute ('/categories/:category')
TagDetailRoute ('/tags/:id')
AuthorDetailRoute ('/authors/:id')
SettingsRoute ('/settings')
WelcomeRoute ('/welcome')
```

## 主題系統

- 定義在 `lib/core/theme/`（app_colors, app_text_styles, app_theme, app_spacing）
- Primary: #04295E（報導者深藍）
- Secondary: #E67E22（橘色）
- 使用 Material 3 ColorScheme tokens

## 分類系統

culture, econ, education, environment, health, humanrights, politics_and_society, world

## 效能最佳化經驗法則

- **`computed()`** 適用於衍生狀態（合併列表、布林判斷、過濾結果、HTML 轉換），避免每次 render 重新計算
- **`ComputedBuilder`** 適用於縮小 rebuild 範圍：將響應式狀態讀取隔離在子樹中（如收藏按鈕、已讀標記）
- **Builder functions → private widgets**：讓 Flutter framework 能跳過未變更的子樹
- 何時用 **CompositionWidget** vs **StatelessWidget**：需要響應式狀態（ref/computed/onMounted）→ CompositionWidget，純展示 → StatelessWidget

## 重要提醒

- 文章使用 **slug** 作為唯一識別符
- Topic 的 relateds 欄位是文章 **ID 陣列**，不是完整文章物件
- API 時間戳使用 UTC 時區
- 圖片提供 5 種尺寸：mobile, tablet, desktop, w400, tiny
- 本 APP 為**非官方**開源客戶端，非報導者官方出品
