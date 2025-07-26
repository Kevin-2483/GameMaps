import 'dart:html' as html;
import 'dart:typed_data';

/// Web平台的图片导出实现

/// 导出多张图片
Future<bool> exportImagesImpl(
  List<Uint8List> imageBytes, {
  String baseName = 'export',
  String format = 'png',
}) async {
  try {
    // 在Web平台，逐个下载每张图片
    for (int i = 0; i < imageBytes.length; i++) {
      final fileName = imageBytes.length == 1 
          ? '$baseName.$format'
          : '${baseName}_${i + 1}.$format';
      
      await _downloadImage(imageBytes[i], fileName);
      
      // 添加小延迟，避免浏览器阻止多个下载
      if (i < imageBytes.length - 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    return true;
  } catch (e) {
    print('Web平台导出图片失败: $e');
    return false;
  }
}

/// 导出单张图片
Future<bool> exportSingleImageImpl(
  Uint8List imageBytes, {
  String fileName = 'export.png',
}) async {
  try {
    await _downloadImage(imageBytes, fileName);
    return true;
  } catch (e) {
    print('Web平台导出单张图片失败: $e');
    return false;
  }
}

/// 下载图片的内部方法
Future<void> _downloadImage(Uint8List imageBytes, String fileName) async {
  // 创建Blob对象
  final blob = html.Blob([imageBytes], 'image/png');
  
  // 创建下载链接
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // 创建隐藏的下载链接并触发下载
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';
  
  // 添加到DOM，触发下载，然后移除
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  
  // 释放URL对象
  html.Url.revokeObjectUrl(url);
}