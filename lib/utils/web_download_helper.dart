// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Web平台下载助手类
/// 使用HTML5的download API实现文件下载
class WebDownloadHelper {
  /// 下载文件到浏览器
  ///
  /// [fileName] 文件名
  /// [data] 文件数据
  /// [mimeType] MIME类型
  static Future<void> downloadFile(
    String fileName,
    Uint8List data,
    String mimeType,
  ) async {
    try {
      // 创建Blob对象
      final blob = html.Blob([data], mimeType);

      // 创建下载URL
      final url = html.Url.createObjectUrlFromBlob(blob);

      // 创建隐藏的anchor元素
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';

      // 添加到DOM并触发点击
      html.document.body?.children.add(anchor);
      anchor.click();

      // 清理：移除元素并释放URL
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      throw Exception('Web文件下载失败: $e');
    }
  }
}
