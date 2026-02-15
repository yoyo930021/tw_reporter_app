# 閱報導者

[報導者 The Reporter](https://www.twreporter.org/) 的**非官方**開源行動應用程式，使用 Flutter 開發。

本專案同時作為 [flutter_compositions](https://github.com/aspect-build/flutter_compositions) 狀態管理框架的實戰驗證場景，展示 CompositionWidget、ref、computed、watch 等 API 在中大型應用中的使用方式。

> **聲明**：本專案為社群開發，與報導者基金會無隸屬關係。所有新聞內容之著作權歸報導者所有。

## 下載

| 平台 | 連結 |
|------|------|
| Android | [Google Play](https://play.google.com/store/apps/details?id=com.yokikiyo.tw_reporter_app) |
| iOS | Coming soon |

## 特色

- **完整閱讀體驗** — 瀏覽首頁編輯精選、最新報導、各分類文章與專題
- **文章 HTML 渲染** — 支援內嵌影片、YouTube、圖片比較、相簿等多媒體元件
- **離線友善** — HTTP 快取、圖片快取，省流量模式可手動點擊才載入媒體
- **深色模式** — 完整亮色 / 暗色主題，可跟隨系統或手動切換
- **閱讀記錄與收藏** — 本地儲存閱讀歷史與收藏文章，方便回顧
- **搜尋與分類** — 依分類、標籤、作者瀏覽，首頁搜尋列快速查找
- **推播通知** — 透過報導者官方 WebPush 接收新文章通知，使用 [UnifiedPush](https://unifiedpush.org/) 協定（Android）。熟悉 UnifiedPush 的使用者可選擇自己偏好的 distributor，一般使用者直接選擇內建的 FCM 管道即可
- **跨平台** — 支援 Android、iOS、macOS
- **不涉及登入功能** — 本 APP 僅提供公開內容閱讀，不處理會員登入與付費牆

## 截圖

<!-- TODO: 加入截圖 -->

## 開始開發

### 環境需求

- Flutter SDK（透過 [fvm](https://fvm.app/) 管理）
- Dart SDK（隨 Flutter 附帶）

### 安裝與執行

```bash
# 安裝 fvm（如尚未安裝）
dart pub global activate fvm

# 安裝專案指定的 Flutter SDK 版本
fvm install

# 安裝依賴
fvm flutter pub get

# 產生程式碼（freezed、retrofit、auto_route）
fvm dart run build_runner build --delete-conflicting-outputs

# 執行
fvm flutter run
```

### 測試

```bash
fvm flutter test
```

### 程式碼分析

```bash
fvm flutter analyze
```

## 技術架構

| 層級 | 技術 |
|------|------|
| UI 框架 | Flutter + Material 3 |
| 狀態管理 | [flutter_compositions](https://github.com/aspect-build/flutter_compositions)（CompositionWidget、ref、computed、watch） |
| 路由 | auto_route |
| API 客戶端 | Retrofit + Dio + rhttp |
| 資料模型 | freezed + json_serializable |
| 快取 | dio_cache_interceptor + flutter_cache_manager |
| 本地儲存 | shared_preferences |
| 推播 | UnifiedPush |

## 專案結構

```
lib/
├── core/                  # 核心基礎設施
│   ├── api/               # API 客戶端（Retrofit + Dio）
│   ├── cache/             # 快取管理
│   ├── di/                # 依賴注入（composables、providers）
│   ├── push/              # 推播通知服務
│   ├── router/            # auto_route 路由定義
│   ├── settings/          # 設定（媒體載入模式）
│   └── theme/             # Material 3 主題系統
├── features/              # 功能模組
│   ├── article/           # 文章詳情頁
│   ├── author/            # 作者詳情頁
│   ├── category/          # 分類頁
│   ├── home/              # 首頁
│   ├── latest/            # 最新報導
│   ├── my_reading/        # 閱讀記錄與收藏
│   ├── search/            # 搜尋
│   ├── settings/          # 設定頁
│   ├── tag/               # 標籤詳情頁
│   └── topics/            # 專題列表與詳情
└── shared/                # 共用元件
    ├── composables/       # 共用 composable hooks
    ├── utils/             # 工具函式
    └── widgets/           # 共用 UI 元件
```

## 支持報導者

[報導者](https://www.twreporter.org/)是台灣第一個由公益基金會成立的非營利網路媒體，致力於深度調查報導與公共議題。他們的運作仰賴讀者的支持：

**[贊助報導者](https://support.twreporter.org/)**

每一份贊助都能讓獨立新聞走得更遠。

## 授權條款

本專案採用 [MIT License](LICENSE) 授權。

新聞內容著作權歸[報導者基金會](https://www.twreporter.org/)所有。
