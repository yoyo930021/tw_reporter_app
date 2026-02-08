import 'dart:convert';
import 'dart:io';

/// 測試腳本：探測報導者網站的真實 API 端點
void main() async {
  print('報導者 API 端點探測\n${'=' * 50}');

  // 測試基本 API 端點
  final endpoints = <String>[
    'https://go-api.twreporter.org/v2/posts',
    'https://go-api.twreporter.org/v2/posts?limit=5',
    'https://go-api.twreporter.org/v2/topics',
    'https://go-api.twreporter.org/v2/index_page',
    'https://go-api.twreporter.org/v2/index_page_contents',
  ];

  for (final endpoint in endpoints) {
    await testEndpoint(endpoint);
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  // 測試單篇文章詳情
  print('\n${'=' * 50}');
  print('測試文章詳情 API');
  await testPostDetail();
}

Future<void> testEndpoint(String url) async {
  print('\n測試: $url');

  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('Accept', 'application/json');
    final response = await request.close();

    print('狀態碼: ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      print('成功！長度: ${body.length}');

      // 嘗試解析 JSON 並顯示結構
      try {
        final dynamic json = jsonDecode(body);
        if (json is Map) {
          print('JSON 鍵: ${json.keys.join(', ')}');

          // 如果有 records/data 陣列，顯示數量
          if (json['records'] is List) {
            print('文章數量: ${(json['records'] as List<dynamic>).length}');
            if ((json['records'] as List<dynamic>).isNotEmpty) {
              final dynamic first = (json['records'] as List<dynamic>).first;
              if (first is Map) {
                print('文章欄位: ${first.keys.join(', ')}');
              }
            }
          }
          if (json['data'] is List) {
            print('資料數量: ${(json['data'] as List<dynamic>).length}');
          }
        }
      } catch (e) {
        print('無法解析 JSON: $e');
      }
    }

    client.close();
  } catch (e) {
    print('錯誤: $e');
  }
}

Future<void> testPostDetail() async {
  // 先獲取文章列表，取得第一篇文章的 slug
  try {
    final client = HttpClient();
    final listRequest = await client.getUrl(
      Uri.parse('https://go-api.twreporter.org/v2/posts?limit=1'),
    );
    listRequest.headers.set('Accept', 'application/json');
    final listResponse = await listRequest.close();

    if (listResponse.statusCode == 200) {
      final body = await listResponse.transform(utf8.decoder).join();
      final dynamic json = jsonDecode(body);

      if (json is Map && json['records'] is List && (json['records'] as List<dynamic>).isNotEmpty) {
        final dynamic firstPost = (json['records'] as List<dynamic>).first;
        final slug = firstPost['slug'] as String?;

        if (slug != null) {
          print('\n測試文章詳情: $slug');
          final detailUrl = 'https://go-api.twreporter.org/v2/posts/$slug';

          final detailRequest = await client.getUrl(Uri.parse(detailUrl));
          detailRequest.headers.set('Accept', 'application/json');
          final detailResponse = await detailRequest.close();

          print('狀態碼: ${detailResponse.statusCode}');
          if (detailResponse.statusCode == 200) {
            final detailBody = await detailResponse.transform(utf8.decoder).join();
            print('成功！長度: ${detailBody.length}');

            final dynamic detailJson = jsonDecode(detailBody);
            if (detailJson is Map) {
              print('JSON 鍵: ${detailJson.keys.join(', ')}');
            }
          }
        }
      }
    }

    client.close();
  } catch (e) {
    print('錯誤: $e');
  }
}
