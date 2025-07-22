// Stub implementation for non-web platforms
import 'dart:typed_data';

class WebDownloader {
  static Future<void> downloadFile(Uint8List data, String fileName) async {
    throw UnsupportedError('Web download not supported on this platform');
  }
}
