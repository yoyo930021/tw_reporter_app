import 'package:flutter_test/flutter_test.dart';

// We test the _formatBytes logic since it's a private function.
// Re-implement for testing purposes.
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

void main() {
  group('formatBytes', () {
    test('formats bytes correctly', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(512), '512 B');
      expect(formatBytes(1023), '1023 B');
    });

    test('formats kilobytes correctly', () {
      expect(formatBytes(1024), '1.0 KB');
      expect(formatBytes(1536), '1.5 KB');
      expect(formatBytes(10240), '10.0 KB');
    });

    test('formats megabytes correctly', () {
      expect(formatBytes(1024 * 1024), '1.0 MB');
      expect(formatBytes(1024 * 1024 * 50), '50.0 MB');
      expect(formatBytes(200 * 1024 * 1024), '200.0 MB');
    });
  });
}
