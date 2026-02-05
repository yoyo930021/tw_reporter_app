# 報導者 API 端點文檔

## API 架構分析

### 基本資訊
- **Base URL**: `https://www.twreporter.org`
- **資料格式**: JSON (嵌入在 HTML 的 `__REDUX_STATE__` 中)
- **認證方式**: Token-based (`auth.accessToken`)
- **狀態管理**: Redux

### Redux State 結構

網站使用 Server-Side Rendering (SSR)，初始狀態透過 `__REDUX_STATE__` 注入到 HTML 中。

```javascript
window.__REDUX_STATE__ = {
  articlesByAuthor: {},
  auth: {
    accessToken: "",
    actionType: "",
    lastAction: null,
    isAuthed: false,
    isRequesting: false,
    userInfo: null
  },
  entities: {
    posts: {
      allIds: [...],  // 文章 ID 列表
      byId: {...}     // 文章詳細資料（正規化格式）
    }
  },
  // ... 其他狀態
}
```

---

## API 端點推測

由於報導者沒有公開 API 文檔，以下是基於網站結構推測的端點：

### 1. 文章相關 API

#### 1.1 獲取文章列表
```
GET /api/articles
```

**Query Parameters**:
- `page` (number): 頁碼，預設 1
- `limit` (number): 每頁數量，預設 10
- `category` (string, optional): 分類篩選

**Response**:
```json
{
  "data": [
    {
      "id": "69787503f7e6ab070044a7ae",
      "slug": "swedish-civil-psychological-defence-resilience",
      "title": "人民能成為國家之盾嗎？從制度、心防到文化，瑞典打造「全民防禦」之路",
      "subtitle": "",
      "og_description": "專訪瑞典國防學者與心理防衛局專家...",
      "hero_image": {
        "resized_targets": {
          "mobile": {
            "url": "https://www.twreporter.org/images/...-mobile.jpg",
            "width": 800,
            "height": 533
          },
          "desktop": {...},
          "tablet": {...}
        }
      },
      "category_set": [
        {
          "category": {
            "id": "63206383207bf7c5f871622c",
            "name": "國際兩岸"
          },
          "subcategory": {
            "id": "63206383207bf7c5f8716232",
            "name": "歐洲"
          }
        }
      ],
      "published_date": "2026-01-28T16:00:00Z",
      "is_external": false,
      "tags": [...]
    }
  ],
  "total": 100,
  "page": 1
}
```

#### 1.2 獲取文章詳情
```
GET /a/{slug}
```

**URL Parameters**:
- `slug` (string): 文章 slug

**Response**:
返回完整的 HTML 頁面，其中包含 `__REDUX_STATE__`，內含文章完整內容。

**可能的 API 端點**:
```
GET /api/articles/{slug}
```

#### 1.3 獲取最新文章
```
GET /latest
```

頁面 URL，返回 HTML + Redux State

**可能的 API 端點**:
```
GET /api/articles?sort=published_date&order=desc
```

---

### 2. 分類相關 API

#### 2.1 獲取分類列表
```
GET /api/categories
```

**Categories** (從 Redux State 推測):
- 國際兩岸 (id: 63206383207bf7c5f871622c)
- 人權司法
- 政治社會
- 健康醫療
- 環境永續
- 經濟產業
- 文化
- 教育

#### 2.2 獲取分類文章
```
GET /categories/{category-name}
```

頁面 URL，返回 HTML + Redux State

**可能的 API 端點**:
```
GET /api/articles?category={category-id}&page={page}&limit={limit}
```

---

### 3. 專題相關 API

#### 3.1 獲取專題列表
```
GET /topics
```

**可能的 API 端點**:
```
GET /api/topics?page={page}&limit={limit}
```

**Response**:
```json
{
  "data": [
    {
      "id": "...",
      "slug": "topic-slug",
      "title": "專題標題",
      "og_description": "專題描述",
      "hero_image": {...},
      "published_date": "...",
      "relateds_background": "...",
      "relateds_format": "...",
      "related_posts": [...]
    }
  ]
}
```

---

### 4. 搜尋 API

#### 4.1 搜尋文章
```
GET /search
```

**Query Parameters**:
- `q` (string): 搜尋關鍵字
- `page` (number): 頁碼

**可能的 API 端點**:
```
GET /api/search?q={query}&page={page}&limit={limit}
```

---

### 5. 使用者相關 API (需認證)

#### 5.1 我的閱讀 (書籤)
```
GET /myreading
```

**需要認證**: `auth.accessToken`

**可能的 API 端點**:
```
GET /api/bookmarks
Authorization: Bearer {accessToken}
```

**Response** (從 Redux State 推測):
```json
{
  "data": {
    "bookmarkIDList": [...],
    "entities": {...},
    "offset": 0,
    "total": 10,
    "limit": 10
  }
}
```

#### 5.2 新增書籤
```
POST /api/bookmarks
Authorization: Bearer {accessToken}
```

**Request Body**:
```json
{
  "post_id": "69787503f7e6ab070044a7ae"
}
```

#### 5.3 刪除書籤
```
DELETE /api/bookmarks/{bookmark-id}
Authorization: Bearer {accessToken}
```

---

## 圖片資源

### 圖片尺寸變體

文章圖片提供多種尺寸：
- `tiny`: 150x100 (縮圖)
- `w400`: 400x267 (小卡片)
- `mobile`: 800x533 (行動裝置)
- `tablet`: 1200x800 (平板)
- `desktop`: 2000x1333 (桌面)

**URL 格式**:
```
https://www.twreporter.org/images/{hash}-{size}.jpg
```

---

## RSS Feed

```
GET /a/rss2.xml
```

提供 RSS 2.0 格式的最新文章訂閱。

---

## 實作策略

### 方法 1: 解析 SSR HTML (短期)
1. 透過 HTTP 請求獲取頁面 HTML
2. 從 HTML 中提取 `__REDUX_STATE__` JSON
3. 解析 JSON 獲取資料

**優點**:
- 不需要找真正的 API 端點
- 資料結構完整

**缺點**:
- 需要解析 HTML
- 效能較差
- 容易因為網站改版而失效

### 方法 2: 逆向工程真正的 API (推薦)
1. 使用瀏覽器開發者工具 (Network tab)
2. 觀察網站的 XHR/Fetch 請求
3. 找出真正的 API 端點

**需要進一步驗證的端點**:
- [ ] `/api/articles` - 文章列表
- [ ] `/api/articles/{slug}` - 文章詳情
- [ ] `/api/categories` - 分類列表
- [ ] `/api/topics` - 專題列表
- [ ] `/api/search` - 搜尋
- [ ] `/api/bookmarks` - 書籤 (需認證)

### 方法 3: 使用 RSS Feed (備用)
- 解析 `/a/rss2.xml`
- 只能獲取最新文章列表
- 不包含完整內容

---

## TODO

- [ ] 使用瀏覽器開發者工具驗證真實 API 端點
- [ ] 記錄完整的 request/response 範例
- [ ] 測試分頁、排序、篩選參數
- [ ] 測試認證流程
- [ ] 建立 JSON 測試夾具 (fixtures)
