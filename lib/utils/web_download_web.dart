// Web implementation for file download
import 'dart:html' as html;
import 'dart:typed_data';

class WebDownloader {
  static Future<void> downloadFile(Uint8List data, String fileName) async {
    final blob = html.Blob([data]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // 创建下载链接并触发下载
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    // 清理 URL
    html.Url.revokeObjectUrl(url);
  }
}
