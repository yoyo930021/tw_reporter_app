# 更新日誌

## 2026-02-05 - API 整合與首頁實作

### ✅ 完成項目

#### 1. API 整合
- **更新 API 客戶端** (`lib/core/api/tw_reporter_api.dart`)
  - 更改 Base URL 為真實的報導者 API: `https://go-api.twreporter.org/v2`
  - 實作 4 個 API 端點：
    - `GET /posts` - 文章列表（支援 limit/offset 分頁）
    - `GET /posts/{slug}` - 文章詳情
    - `GET /topics` - 專題列表
    - `GET /index_page` - 首頁聚合內容
  - 定義響應格式類別：`ApiResponse<T>`, `ListResponse<T>`, `IndexPageData`

#### 2. 資料模型更新
所有模型已添加 `@JsonKey` 註解以正確映射 snake_case 欄位：
- ✅ `Article` - 文章模型
- ✅ `Category` / `CategorySet` / `Subcategory` - 分類模型
- ✅ `HeroImage` / `ResizedTargets` / `ImageSize` - 圖片模型
- ✅ `Tag` - 標籤模型
- ✅ `Topic` - 專題模型（修正 `relateds` 欄位為 String[] ID 陣列）

#### 3. 首頁實作
- **更新 `use_home_data.dart`** - 首頁資料邏輯
  - 改用 `/index_page` API 一次獲取所有首頁內容
  - 簡化狀態管理，只需維護一個 `IndexPageData` 物件
  - 提供載入、錯誤、重新整理功能

- **更新 `home_page.dart`** - 首頁 UI
  - 顯示編輯精選區塊
  - 顯示最新報導區塊
  - 顯示 8 個分類文章區塊（文化、經濟、環境、健康、人權、政治、國際）
  - 實作下拉重新整理
  - 實作錯誤狀態顯示

- **更新 `main.dart`** - 應用程式初始化
  - 初始化 Dio + Retrofit API 客戶端
  - 設置 AutoRoute 路由器
  - 使用 InheritedWidget (ApiProvider) 提供 API 實例

#### 4. 測試與驗證
- 創建 `research/test_integration.dart` - 完整 API 整合測試
- ✅ 所有 4 個 API 端點測試通過：
  - 文章列表：5,652 篇文章
  - 專題列表：216 個專題
  - 首頁內容：15 個區塊
  - 文章詳情：完整內容

### 📊 API 測試結果

```
測試報導者 API 整合
============================================================

📰 測試文章列表 API
✓ 成功獲取文章列表
  狀態: success
  總數: 5652
  當前頁數量: 3

📚 測試專題列表 API
✓ 成功獲取專題列表
  狀態: success
  總數: 216
  當前頁數量: 3

🏠 測試首頁內容 API
✓ 成功獲取首頁內容
  編輯精選: 6 篇
  最新文章: 6 篇
  最新專題: 1 個
  專題區塊: 4 個
  評論: 4 篇
  攝影: 6 篇
  多媒體: 6 篇

📄 測試文章詳情 API
✓ 成功獲取文章詳情

============================================================
✓ 所有測試完成！
```

### 📁 更新的檔案

#### 核心層 (Core)
- `lib/core/api/tw_reporter_api.dart` - API 客戶端
- `lib/core/models/article.dart` - 文章模型
- `lib/core/models/category.dart` - 分類模型
- `lib/core/models/image_size.dart` - 圖片模型
- `lib/core/models/tag.dart` - 標籤模型
- `lib/core/models/topic.dart` - 專題模型

#### 功能層 (Features)
- `lib/features/home/logic/use_home_data.dart` - 首頁資料邏輯
- `lib/features/home/presentation/home_page.dart` - 首頁 UI

#### 應用層 (App)
- `lib/main.dart` - 應用程式初始化

#### 研究與測試
- `research/test_integration.dart` - API 整合測試
- `research/API_DOCUMENTATION.md` - API 完整文件
- `research/*.json` - API 響應範例

### ⚠️ 重要發現與注意事項

1. **Topic 的 relateds 欄位**
   - 是文章 ID 字串陣列 (`List<String>`)
   - 不是完整的 Article 物件
   - 如需顯示相關文章，需要另外調用 `/posts/{slug}` API

2. **API 響應格式**
   - 統一使用 `{"data": {...}, "status": "success"}`
   - 列表端點使用 `{"data": {"meta": {...}, "records": [...]}, "status": "success"}`

3. **分頁參數**
   - 使用 `limit` 和 `offset` 參數
   - 不是傳統的 `page` 參數
   - 例如：`/posts?limit=10&offset=20` 獲取第 21-30 篇文章

4. **圖片系統**
   - 所有圖片提供 5 種尺寸：mobile, tablet, desktop, w400, tiny
   - 使用 `resized_targets` 欄位

### 🚀 下一步

1. 實作文章詳情頁面
2. 實作專題列表頁面
3. 實作最新文章頁面
4. 實作搜尋功能
5. 添加圖片顯示
6. 優化 UI/UX

### 🔧 開發指令

```bash
# 執行 build_runner
fvm dart run build_runner build --delete-conflicting-outputs

# 執行 API 測試
fvm dart research/test_integration.dart

# 分析程式碼
fvm flutter analyze

# 運行應用程式
fvm flutter run
```
