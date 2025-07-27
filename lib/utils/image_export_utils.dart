import 'dart:typed_data';
import 'dart:ui' as ui;

// 条件导入：桌面平台
import 'image_export_utils_desktop.dart'
    if (dart.library.html) 'image_export_utils_web.dart'
    as platform;

/// 图片导出工具类
/// 提供跨平台的图片导出功能
class ImageExportUtils {
  /// 导出图片列表
  /// [images] 要导出的图片列表
  /// [baseName] 文件名前缀，默认为'export'
  /// [format] 图片格式，默认为'png'
  static Future<bool> exportImages(
    List<ui.Image> images, {
    String baseName = 'export',
    String format = 'png',
  }) async {
    try {
      // 将图片转换为字节数据
      final List<Uint8List> imageBytes = [];

      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          imageBytes.add(byteData.buffer.asUint8List());
        }
      }

      if (imageBytes.isEmpty) {
        return false;
      }

      // 调用平台特定的导出实现
      return await platform.exportImagesImpl(
        imageBytes,
        baseName: baseName,
        format: format,
      );
    } catch (e) {
      print('导出图片失败: $e');
      return false;
    }
  }

  /// 导出单张图片
  /// [image] 要导出的图片
  /// [fileName] 文件名，默认为'export.png'
  static Future<bool> exportSingleImage(
    ui.Image image, {
    String fileName = 'export.png',
  }) async {
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return false;
      }

      final imageBytes = byteData.buffer.asUint8List();

      // 调用平台特定的导出实现
      return await platform.exportSingleImageImpl(
        imageBytes,
        fileName: fileName,
      );
    } catch (e) {
      print('导出图片失败: $e');
      return false;
    }
  }
}
