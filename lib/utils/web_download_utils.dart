// This file has been processed by AI for internationalization
import 'package:flutter/foundation.dart';

// 条件导入：Web平台使用dart:html实现，其他平台使用存根实现
import 'web_download_helper_stub.dart'
    if (dart.library.html) 'web_download_helper.dart';
import '../services/localization_service.dart';

/// Web平台文件下载工具类
/// 提供Web平台兼容的文件下载功能
class WebDownloadUtils {
  /// 检查是否为Web平台
  static bool get isWebPlatform => kIsWeb;

  /// 下载单个文件到Web浏览器
  ///
  /// [fileName] 文件名
  /// [data] 文件数据
  /// [mimeType] MIME类型，默认为 'application/octet-stream'
  static Future<void> downloadFile(
    String fileName,
    Uint8List data, {
    String mimeType = 'application/octet-stream',
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError(
        LocalizationService.instance.current.webDownloadUtilsWebOnly_7281,
      );
    }

    try {
      await WebDownloadHelper.downloadFile(fileName, data, mimeType);
    } catch (e) {
      throw Exception(
        LocalizationService.instance.current.webFileDownloadFailed_7285(e),
      );
    }
  }

  /// 下载压缩包到Web浏览器
  ///
  /// [fileName] 压缩包文件名
  /// [zipData] 压缩包数据
  static Future<void> downloadZipFile(
    String fileName,
    Uint8List zipData,
  ) async {
    if (!kIsWeb) {
      throw UnsupportedError(
        LocalizationService.instance.current.webDownloadUtilsWebOnly_7281,
      );
    }

    try {
      await WebDownloadHelper.downloadFile(
        fileName,
        zipData,
        'application/zip',
      );
    } catch (e) {
      throw Exception(
        LocalizationService.instance.current.webDownloadFailed_7285(e),
      );
    }
  }

  /// 批量下载文件（作为单独的文件下载）
  ///
  /// [files] 要下载的文件列表，每个元素包含文件名和数据
  static Future<void> downloadMultipleFiles(
    List<Map<String, dynamic>> files,
  ) async {
    if (!kIsWeb) {
      throw UnsupportedError(
        LocalizationService.instance.current.webDownloadUtilsWebOnly_7281,
      );
    }

    for (final file in files) {
      final fileName = file['name'] as String;
      final data = file['data'] as Uint8List;
      final mimeType =
          file['mimeType'] as String? ?? 'application/octet-stream';

      try {
        await downloadFile(fileName, data, mimeType: mimeType);
        // 添加小延迟，避免浏览器阻止多个下载
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        throw Exception(
          LocalizationService.instance.current.batchDownloadFailed(fileName, e),
        );
      }
    }
  }

  /// 生成安全的文件名（移除非法字符）
  static String sanitizeFileName(String fileName) {
    // 移除或替换文件名中的非法字符
    final sanitized = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    // 确保文件名不为空
    return sanitized.isEmpty ? 'download' : sanitized;
  }

  /// 生成带时间戳的文件名
  static String generateTimestampedFileName(String baseName, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedBaseName = sanitizeFileName(baseName);
    return '${sanitizedBaseName}_$timestamp.$extension';
  }
}
