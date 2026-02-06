import 'dart:convert';
import 'dart:io';

/// 探索報導者 API 的詳細腳本
void main() async {
  print('報導者 API 完整探索\n${'=' * 60}');

  // 1. 測試文章列表 API
  await explorePostsApi();

  // 2. 測試主題 API
  await exploreTopicsApi();

  // 3. 測試首頁 API
  await exploreIndexPageApi();

  // 4. 測試單篇文章詳情
  await explorePostDetailApi();

  print('\n${'=' * 60}');
  print('探索完成！');
}

Future<void> explorePostsApi() async {
  print('\n📰 探索文章列表 API');
  print('-' * 60);

  final String url = 'https://go-api.twreporter.org/v2/posts?limit=3';
  final dynamic json = await fetchJson(url);

  if (json != null && json is Map) {
    print('✓ 成功獲取文章列表');
    print('  根鍵: ${json.keys.join(', ')}');

    if (json['data'] is List) {
      final List<dynamic> posts = json['data'] as List<dynamic>;
      print('  文章數量: ${posts.length}');

      if (posts.isNotEmpty) {
        final dynamic firstPost = posts.first;
        if (firstPost is Map) {
          print('  文章欄位: ${firstPost.keys.take(10).join(', ')}...');
          print('\n  第一篇文章:');
          print('    標題: ${firstPost['title']}');
          print('    Slug: ${firstPost['slug']}');
          print('    發佈時間: ${firstPost['published_date']}');
          if (firstPost['og_description'] != null) {
            final String desc = firstPost['og_description'].toString();
            print('    摘要: ${desc.length > 60 ? desc.substring(0, 60) + '...' : desc}');
          }
        }
      }
    }
  }
}

Future<void> exploreTopicsApi() async {
  print('\n📚 探索主題列表 API');
  print('-' * 60);

  final String url = 'https://go-api.twreporter.org/v2/topics';
  final dynamic json = await fetchJson(url);

  if (json != null && json is Map) {
    print('✓ 成功獲取主題列表');
    print('  根鍵: ${json.keys.join(', ')}');

    if (json['data'] is List) {
      final List<dynamic> topics = json['data'] as List<dynamic>;
      print('  主題數量: ${topics.length}');

      if (topics.isNotEmpty) {
        final dynamic firstTopic = topics.first;
        if (firstTopic is Map) {
          print('  主題欄位: ${firstTopic.keys.take(10).join(', ')}...');
          print('\n  第一個主題:');
          print('    標題: ${firstTopic['title']}');
          print('    Slug: ${firstTopic['slug']}');
        }
      }
    }
  }
}

Future<void> exploreIndexPageApi() async {
  print('\n🏠 探索首頁 API');
  print('-' * 60);

  final String url = 'https://go-api.twreporter.org/v2/index_page';
  final dynamic json = await fetchJson(url);

  if (json != null && json is Map) {
    print('✓ 成功獲取首頁資料');
    print('  根鍵: ${json.keys.join(', ')}');

    if (json['data'] is Map) {
      final Map<String, dynamic> data = json['data'] as Map<String, dynamic>;
      print('  首頁資料鍵: ${data.keys.join(', ')}');

      // 列出首頁各個區塊
      for (final String key in data.keys) {
        final dynamic value = data[key];
        if (value is List) {
          print('    - $key: ${value.length} 項');
        } else if (value is Map) {
          print('    - $key: ${value.keys.length} 個欄位');
        }
      }
    }
  }
}

Future<void> explorePostDetailApi() async {
  print('\n📄 探索文章詳情 API');
  print('-' * 60);

  // 先獲取一篇文章的 slug
  final String listUrl = 'https://go-api.twreporter.org/v2/posts?limit=1';
  final dynamic listJson = await fetchJson(listUrl);

  if (listJson != null &&
      listJson is Map &&
      listJson['data'] is List &&
      (listJson['data'] as List<dynamic>).isNotEmpty) {
    final dynamic firstPost = (listJson['data'] as List<dynamic>).first;
    final String? slug = firstPost['slug'] as String?;

    if (slug != null) {
      print('  測試文章 Slug: $slug');

      final String detailUrl = 'https://go-api.twreporter.org/v2/posts/$slug';
      final dynamic detailJson = await fetchJson(detailUrl);

      if (detailJson != null && detailJson is Map) {
        print('✓ 成功獲取文章詳情');
        print('  根鍵: ${detailJson.keys.join(', ')}');

        if (detailJson['data'] is Map) {
          final Map<String, dynamic> post = detailJson['data'] as Map<String, dynamic>;
          print('  文章欄位數量: ${post.keys.length}');
          print('  主要欄位: ${post.keys.take(15).join(', ')}...');

          print('\n  文章詳細資訊:');
          print('    標題: ${post['title']}');
          print('    作者數: ${(post['writers'] as List?)?.length ?? 0}');
          print('    標籤數: ${(post['tags'] as List?)?.length ?? 0}');
          print('    內容區塊數: ${(post['content'] as Map?)?['apiData']?.length ?? 0}');
        }
      }
    }
  }
}

Future<dynamic> fetchJson(String url) async {
  try {
    final HttpClient client = HttpClient();
    final HttpClientRequest request = await client.getUrl(Uri.parse(url));
    request.headers.set('Accept', 'application/json');

    final HttpClientResponse response = await request.close();

    if (response.statusCode == 200) {
      final String body = await response.transform(utf8.decoder).join();
      client.close();
      return jsonDecode(body);
    } else {
      print('✗ HTTP ${response.statusCode}: $url');
      client.close();
      return null;
    }
  } catch (e) {
    print('✗ 錯誤: $e');
    return null;
  }
}
