import 'dart:convert';
import 'dart:io';

/// 保存 API 範例資料到檔案
void main() async {
  print('儲存報導者 API 範例資料...\n');

  await saveApiSample(
    'https://go-api.twreporter.org/v2/posts?limit=2',
    'posts_list.json',
  );

  await saveApiSample(
    'https://go-api.twreporter.org/v2/topics',
    'topics_list.json',
  );

  await saveApiSample(
    'https://go-api.twreporter.org/v2/index_page',
    'index_page.json',
  );

  print('\n所有範例資料已儲存！');
}

Future<void> saveApiSample(String url, String filename) async {
  print('獲取: $url');

  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('Accept', 'application/json');

    final response = await request.close();

    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();

      // 美化 JSON
      final dynamic json = jsonDecode(body);
      final prettyJson = const JsonEncoder.withIndent('  ').convert(json);

      // 儲存到檔案
      final file = File(filename);
      await file.writeAsString(prettyJson);

      print('✓ 已儲存到: $filename (${body.length} bytes)\n');
    } else {
      print('✗ HTTP ${response.statusCode}\n');
    }

    client.close();
  } catch (e) {
    print('✗ 錯誤: $e\n');
  }
}
