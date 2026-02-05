# 資料模型定義

基於對報導者網站 Redux State 的分析，定義以下資料模型。

---

## 1. Article (文章)

文章是核心資料模型，包含完整的文章資訊。

### Dart Model (Freezed)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';
part 'article.g.dart';

@freezed
class Article with _$Article {
  const factory Article({
    required String id,
    required String slug,
    required String title,
    String? subtitle,
    required String ogDescription,
    HeroImage? heroImage,
    HeroImage? ogImage,
    required List<CategorySet> categorySet,
    required DateTime publishedDate,
    required bool isExternal,
    List<Tag>? tags,
    String? style,  // e.g., "article:v2:default"
    @JsonKey(name: 'content') String? htmlContent,  // HTML 內容（文章詳情才有）
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
}
```

### JSON 範例

```json
{
  "id": "69787503f7e6ab070044a7ae",
  "slug": "swedish-civil-psychological-defence-resilience",
  "title": "人民能成為國家之盾嗎？從制度、心防到文化，瑞典打造「全民防禦」之路",
  "subtitle": "",
  "ogDescription": "專訪瑞典國防學者與心理防衛局專家，解釋瑞典如何動員社會參與民防改革？",
  "heroImage": {...},
  "ogImage": {...},
  "categorySet": [...],
  "publishedDate": "2026-01-28T16:00:00Z",
  "isExternal": false,
  "tags": [...],
  "style": "article:v2:default"
}
```

---

## 2. HeroImage (主圖)

圖片資源，包含多種尺寸變體。

### Dart Model

```dart
@freezed
class HeroImage with _$HeroImage {
  const factory HeroImage({
    required String id,
    required String filetype,
    String? description,
    required ResizedTargets resizedTargets,
  }) = _HeroImage;

  factory HeroImage.fromJson(Map<String, dynamic> json) =>
      _$HeroImageFromJson(json);
}

@freezed
class ResizedTargets with _$ResizedTargets {
  const factory ResizedTargets({
    ImageSize? tiny,      // 150x100
    ImageSize? w400,      // 400x267
    ImageSize? mobile,    // 800x533
    ImageSize? tablet,    // 1200x800
    ImageSize? desktop,   // 2000x1333
  }) = _ResizedTargets;

  factory ResizedTargets.fromJson(Map<String, dynamic> json) =>
      _$ResizedTargetsFromJson(json);
}

@freezed
class ImageSize with _$ImageSize {
  const factory ImageSize({
    required String url,
    required int width,
    required int height,
  }) = _ImageSize;

  factory ImageSize.fromJson(Map<String, dynamic> json) =>
      _$ImageSizeFromJson(json);
}
```

### JSON 範例

```json
{
  "id": "6978b7cff7e6ab070044a7be",
  "filetype": "image/jpeg",
  "description": "人民能成為國家之盾嗎？從制度、心防到文化，瑞典打造「全民防禦」之路",
  "resizedTargets": {
    "tiny": {
      "url": "https://www.twreporter.org/images/...-tiny.jpg",
      "width": 150,
      "height": 100
    },
    "mobile": {
      "url": "https://www.twreporter.org/images/...-mobile.jpg",
      "width": 800,
      "height": 533
    },
    "desktop": {
      "url": "https://www.twreporter.org/images/...-desktop.jpg",
      "width": 2000,
      "height": 1333
    }
  }
}
```

---

## 3. CategorySet (分類集合)

文章的分類與子分類。

### Dart Model

```dart
@freezed
class CategorySet with _$CategorySet {
  const factory CategorySet({
    required Category category,
    Subcategory? subcategory,
  }) = _CategorySet;

  factory CategorySet.fromJson(Map<String, dynamic> json) =>
      _$CategorySetFromJson(json);
}

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    int? sortOrder,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

@freezed
class Subcategory with _$Subcategory {
  const factory Subcategory({
    required String id,
    required String key,
    required String name,
    int? latestOrder,
  }) = _Subcategory;

  factory Subcategory.fromJson(Map<String, dynamic> json) =>
      _$SubcategoryFromJson(json);
}
```

### JSON 範例

```json
{
  "category": {
    "id": "63206383207bf7c5f871622c",
    "name": "國際兩岸",
    "sortOrder": 17
  },
  "subcategory": {
    "id": "63206383207bf7c5f8716232",
    "key": "63206383207bf7c5f8716232",
    "name": "歐洲",
    "latestOrder": 0
  }
}
```

---

## 4. Tag (標籤)

文章標籤。

### Dart Model

```dart
@freezed
class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String key,
    required String name,
    int? latestOrder,
    Category? category,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) =>
      _$TagFromJson(json);
}
```

### JSON 範例

```json
{
  "id": "5768ed08406be01000c69076",
  "key": "5768ed08406be01000c69076",
  "name": "中國",
  "latestOrder": 10,
  "category": null
}
```

---

## 5. Topic (專題)

調查報導系列專題。

### Dart Model

```dart
@freezed
class Topic with _$Topic {
  const factory Topic({
    required String id,
    required String slug,
    required String title,
    String? ogDescription,
    HeroImage? heroImage,
    HeroImage? ogImage,
    required DateTime publishedDate,
    String? relatedsBackground,
    String? relatedsFormat,
    List<Article>? relatedPosts,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) =>
      _$TopicFromJson(json);
}
```

---

## 6. Bookmark (書籤)

使用者的閱讀書籤 (需認證)。

### Dart Model

```dart
@freezed
class Bookmark with _$Bookmark {
  const factory Bookmark({
    required String id,
    required String postId,
    required DateTime createdAt,
    Article? article,  // 關聯的文章資料
  }) = _Bookmark;

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);
}

@freezed
class BookmarkList with _$BookmarkList {
  const factory BookmarkList({
    required List<String> bookmarkIdList,
    required Map<String, Bookmark> entities,
    required int offset,
    required int total,
    required int limit,
  }) = _BookmarkList;

  factory BookmarkList.fromJson(Map<String, dynamic> json) =>
      _$BookmarkListFromJson(json);
}
```

---

## 7. Auth (認證資訊)

使用者認證狀態。

### Dart Model

```dart
@freezed
class Auth with _$Auth {
  const factory Auth({
    String? accessToken,
    required bool isAuthed,
    required bool isRequesting,
    UserInfo? userInfo,
  }) = _Auth;

  factory Auth.fromJson(Map<String, dynamic> json) =>
      _$AuthFromJson(json);
}

@freezed
class UserInfo with _$UserInfo {
  const factory UserInfo({
    required String id,
    required String email,
    String? nickname,
    String? firstName,
    String? lastName,
  }) = _UserInfo;

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
}
```

---

## 8. ApiResponse (通用 API 回應)

統一的 API 回應格式。

### Dart Model

```dart
@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required T data,
    int? total,
    int? page,
    int? limit,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}
```

---

## 9. AsyncValue (異步狀態)

用於包裝異步載入狀態 (借鑑 Riverpod)。

### Dart Model

```dart
@freezed
sealed class AsyncValue<T> with _$AsyncValue<T> {
  const factory AsyncValue.idle() = AsyncIdle<T>;
  const factory AsyncValue.loading() = AsyncLoading<T>;
  const factory AsyncValue.data(T value) = AsyncData<T>;
  const factory AsyncValue.error(Object error, [StackTrace? stackTrace]) = AsyncError<T>;

  // 注意：這個類別不需要 JSON 序列化，只用於前端狀態管理
}
```

### 使用範例

```dart
// 在 Composable 中使用
final Ref<AsyncValue<List<Article>>> articles = ref(AsyncValue.idle());

// 載入中
articles.value = AsyncValue.loading();

// 載入成功
try {
  final data = await api.fetchArticles();
  articles.value = AsyncValue.data(data);
} catch (e, st) {
  articles.value = AsyncValue.error(e, st);
}

// 在 UI 中使用 pattern matching
return switch (articles.value) {
  AsyncIdle() => EmptyState(),
  AsyncLoading() => LoadingIndicator(),
  AsyncData(:final value) => ArticleList(articles: value),
  AsyncError(:final error) => ErrorView(error: error),
};
```

---

## 命名規範

### JSON 欄位命名
- 使用 **snake_case**: `published_date`, `hero_image`, `category_set`
- 使用 `@JsonKey` 註解對應到 Dart 的 **camelCase**

### Dart 欄位命名
- 使用 **camelCase**: `publishedDate`, `heroImage`, `categorySet`

### 範例

```dart
@freezed
class Article with _$Article {
  const factory Article({
    @JsonKey(name: 'published_date') required DateTime publishedDate,
    @JsonKey(name: 'hero_image') HeroImage? heroImage,
    @JsonKey(name: 'category_set') required List<CategorySet> categorySet,
    @JsonKey(name: 'og_description') required String ogDescription,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
}
```

---

## 資料關係圖

```
Article
├── HeroImage (主圖)
│   └── ResizedTargets (多尺寸)
│       └── ImageSize (單一尺寸)
├── OgImage (OG 圖)
├── CategorySet[] (分類集合)
│   ├── Category (主分類)
│   └── Subcategory? (子分類)
└── Tag[] (標籤)

Topic
├── HeroImage
└── Article[] (相關文章)

Bookmark
├── Article (關聯文章)
└── UserInfo (所有者)

Auth
└── UserInfo (使用者資訊)
```

---

## TODO

- [ ] 確認文章詳情的完整欄位 (content, body, etc.)
- [ ] 確認作者 (author) 資料結構
- [ ] 確認圖片說明 (caption) 資料結構
- [ ] 測試 null safety 處理
- [ ] 建立完整的 JSON 測試夾具
