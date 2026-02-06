# 報導者 API 研究

這個目錄包含對報導者 (The Reporter) 網站 API 的研究成果。

## 📁 文件說明

### 文件

- **API_DOCUMENTATION.md** - 完整的 API 文件，包含所有端點、參數和響應格式說明
- **posts_list.json** - 文章列表 API 的範例響應（2 篇文章）
- **topics_list.json** - 專題列表 API 的範例響應
- **index_page.json** - 首頁內容 API 的範例響應（約 216KB）

### 測試腳本

- **test_api.dart** - 基本 API 端點測試腳本
- **explore_api.dart** - 詳細的 API 探索腳本，顯示結構化資訊
- **save_api_samples.dart** - 保存 API 響應範例到 JSON 文件

## 🚀 快速開始

### 執行測試腳本

```bash
# 測試基本 API 端點
fvm dart research/test_api.dart

# 探索 API 並顯示詳細資訊
fvm dart research/explore_api.dart

# 重新保存 API 範例數據
fvm dart research/save_api_samples.dart
```

## 📊 API 概要

**Base URL**: `https://go-api.twreporter.org/v2`

### 主要端點

1. **GET /posts** - 文章列表
   - 支援分頁 (limit, offset)
   - 總共約 5,652 篇文章

2. **GET /posts/{slug}** - 文章詳情
   - 包含完整內容、作者、相關文章等

3. **GET /topics** - 專題列表
   - 約 216 個專題

4. **GET /index_page** - 首頁內容
   - 包含編輯精選、最新文章、各分類文章等

### 響應格式

所有 API 都遵循相同的響應格式：

```json
{
  "data": { /* 實際資料 */ },
  "status": "success"
}
```

## 🎯 研究發現

1. **圖片支援多種尺寸**: mobile, tablet, desktop, w400, tiny
2. **完整的分類系統**: 包含文化、經濟、教育、環境、健康、人權、政治、國際等
3. **豐富的元數據**: 每篇文章包含作者、標籤、分類、發佈時間等完整資訊
4. **首頁 API 是聚合端點**: 一次請求獲取所有首頁區塊內容

## 📝 下一步

使用這些 API 文件來實現：
1. 文章列表頁面
2. 文章詳情頁面
3. 專題列表頁面
4. 首頁（包含各種內容區塊）

參考 `API_DOCUMENTATION.md` 獲取完整的 API 規格說明。
