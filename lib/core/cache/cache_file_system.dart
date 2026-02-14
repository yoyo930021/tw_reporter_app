import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

/// 自訂 [FileSystem]，將快取檔案存放在 [getApplicationCacheDirectory]
/// 而非 flutter_cache_manager 預設的 [getTemporaryDirectory]。
class CacheFileSystem implements FileSystem {
  CacheFileSystem(this._cacheKey) : _fileDir = _createDirectory(_cacheKey);

  final String _cacheKey;
  final Future<Directory> _fileDir;

  static Future<Directory> _createDirectory(String key) async {
    final baseDir = await getApplicationCacheDirectory();
    const fs = LocalFileSystem();
    final directory = fs.directory('${baseDir.path}/$key');
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    final directory = await _fileDir;
    if (!(await directory.exists())) {
      await _createDirectory(_cacheKey);
    }
    return directory.childFile(name);
  }
}
