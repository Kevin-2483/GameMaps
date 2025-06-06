import 'dart:typed_data';

/// Web平台下载助手类的存根实现
/// 用于非Web平台，防止编译错误
class WebDownloadHelper {
  /// 下载文件到浏览器（存根实现）
  static Future<void> downloadFile(
    String fileName,
    Uint8List data,
    String mimeType,
  ) async {
    throw UnsupportedError('WebDownloadHelper只能在Web平台使用');
  }
}
