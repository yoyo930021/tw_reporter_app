# 報導者 (The Reporter) API 文件

## 基本資訊

**API Base URL**: `https://go-api.twreporter.org/v2`

所有 API 響應格式：
```json
{
  "data": { /* 實際資料 */ },
  "status": "success"
}
```

---

## 1. 文章列表 API

### GET `/posts`

獲取文章列表

**Query Parameters:**
- `limit` (optional): 每頁文章數量，預設為 10
- `offset` (optional): 偏移量，用於分頁

**範例請求:**
```
GET https://go-api.twreporter.org/v2/posts?limit=10&offset=0
```

**響應結構:**
```json
{
  "data": {
    "meta": {
      "limit": 10,
      "offset": 0,
      "total": 5652  // 總文章數
    },
    "records": [
      {
        "id": "文章ID",
        "slug": "文章 slug（用於 URL）",
        "style": "article:v2:default",
        "title": "文章標題",
        "subtitle": "副標題",
        "og_description": "文章摘要",
        "published_date": "2026-02-04T16:00:00Z",
        "is_external": false,

        "hero_image": {
          "filetype": "image/jpeg",
          "resized_targets": {
            "mobile": { "width": 800, "height": 600, "url": "..." },
            "desktop": { "width": 1024, "height": 768, "url": "..." },
            "tablet": { "width": 1024, "height": 768, "url": "..." },
            "tiny": { "width": 150, "height": 113, "url": "..." },
            "w400": { "width": 400, "height": 300, "url": "..." }
          },
          "id": "圖片ID",
          "description": "圖片描述"
        },

        "og_image": { /* 同 hero_image 結構 */ },

        "category_set": [
          {
            "category": {
              "id": "分類ID",
              "name": "經濟產業",
              "sort_order": 22
            },
            "subcategory": null
          }
        ],

        "tags": [
          {
            "id": "標籤ID",
            "key": "標籤key",
            "name": "產業",
            "latest_order": 0,
            "category": null
          }
        ]
      }
    ]
  },
  "status": "success"
}
```

**主要欄位說明:**
- `slug`: 文章的唯一識別符，用於構建文章詳情 URL
- `hero_image`: 文章主圖，提供多種尺寸
- `og_image`: Open Graph 圖片（社群分享用）
- `category_set`: 文章分類（可能有主分類和子分類）
- `tags`: 文章標籤列表
- `published_date`: ISO 8601 格式的發佈時間

---

## 2. 文章詳情 API

### GET `/posts/{slug}`

獲取單篇文章的完整內容

**路徑參數:**
- `slug`: 文章的 slug（從文章列表 API 獲取）

**範例請求:**
```
GET https://go-api.twreporter.org/v2/posts/taiwan-news-media-faces-survival-battle-against-generative-ai-wave
```

**響應結構:**
包含文章列表中的所有欄位，另外還有：
- `content`: 文章完整內容（包含 apiData 陣列）
- `writers`: 作者資訊陣列
- `photographers`: 攝影師資訊
- `designers`: 設計師資訊
- `engineers`: 工程師資訊
- `related_posts`: 相關文章列表

---

## 3. 主題列表 API

### GET `/topics`

獲取專題列表

**響應結構:**
```json
{
  "data": {
    "meta": {
      "limit": 10,
      "offset": 0,
      "total": 216  // 總專題數
    },
    "records": [
      {
        "id": "專題ID",
        "slug": "專題 slug",
        "title": "專題標題",
        "short_title": "專題簡短標題",
        "og_description": "專題描述",
        "published_date": "2026-01-20T16:00:00Z",

        "og_image": { /* 圖片結構同文章 */ },
        "leading_image": { /* 主圖 */ },
        "leading_image_portrait": { /* 直式主圖 */ },

        "relateds": [
          /* 專題相關文章列表 */
        ]
      }
    ]
  },
  "status": "success"
}
```

---

## 4. 首頁內容 API

### GET `/index_page`

獲取首頁所有區塊的內容

**響應結構:**
```json
{
  "data": {
    "editor_picks_section": [ /* 編輯精選，6 篇文章 */ ],
    "latest_section": [ /* 最新文章，6 篇 */ ],
    "latest_topic_section": [ /* 最新專題，1 項 */ ],
    "topics_section": [ /* 專題區塊，4 項 */ ],
    "reviews_section": [ /* 評論區塊，4 篇 */ ],
    "photos_section": [ /* 攝影區塊，6 項 */ ],
    "infographics_section": [ /* 多媒體/資訊圖表，6 項 */ ],

    // 各分類最新文章（各 1 篇）
    "culture": [ /* 文化 */ ],
    "econ": [ /* 經濟 */ ],
    "education": [ /* 教育 */ ],
    "environment": [ /* 環境 */ ],
    "health": [ /* 健康 */ ],
    "humanrights": [ /* 人權 */ ],
    "politics_and_society": [ /* 政治社會 */ ],
    "world": [ /* 國際 */ ]
  },
  "status": "success"
}
```

**說明:**
- 這個 API 返回首頁所有區塊的內容，是一個聚合 API
- 每個區塊包含對應數量的文章或專題
- 文章結構與文章列表 API 中的結構相同

---

## 圖片尺寸說明

所有圖片都提供以下尺寸：
- `mobile`: 800x600 (或類似比例)
- `tablet`: 1200x800
- `desktop`: 2000x1334 (或類似比例)
- `w400`: 400x267
- `tiny`: 150x100 (縮略圖)

圖片格式：JPEG 或 GIF

---

## 分類列表

根據 API 數據，報導者有以下主要分類：
- 文化 (culture)
- 經濟產業 (econ)
- 教育 (education)
- 環境 (environment)
- 健康 (health)
- 人權司法 (humanrights)
- 政治社會 (politics_and_society)
- 國際 (world)

---

## 使用範例

### 1. 獲取首頁最新 10 篇文章
```dart
final response = await http.get(
  Uri.parse('https://go-api.twreporter.org/v2/posts?limit=10'),
);
```

### 2. 獲取單篇文章詳情
```dart
final slug = 'taiwan-news-media-faces-survival-battle-against-generative-ai-wave';
final response = await http.get(
  Uri.parse('https://go-api.twreporter.org/v2/posts/$slug'),
);
```

### 3. 獲取專題列表
```dart
final response = await http.get(
  Uri.parse('https://go-api.twreporter.org/v2/topics'),
);
```

### 4. 獲取首頁完整內容
```dart
final response = await http.get(
  Uri.parse('https://go-api.twreporter.org/v2/index_page'),
);
```

---

## 注意事項

1. **認證**: 目前這些公開 API 不需要認證
2. **請求頭**: 建議設置 `Accept: application/json`
3. **速率限制**: 未知，建議適度使用
4. **CORS**: 支援跨域請求
5. **時區**: 所有時間戳使用 UTC（Z 時區）

---

## 測試工具

專案中包含以下測試腳本：
- `test_api.dart`: 基本 API 端點測試
- `explore_api.dart`: 詳細 API 探索
- `save_api_samples.dart`: 保存 API 範例數據

執行測試：
```bash
fvm dart test_api.dart
fvm dart explore_api.dart
fvm dart save_api_samples.dart
```
