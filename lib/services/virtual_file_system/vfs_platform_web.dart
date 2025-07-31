// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';

import '../localization_service.dart';

/// Web平台的VFS平台接口实现
class VfsPlatformIO {
  /// Web平台不支持获取临时目录
  static Future<void> getTempDirectory() async {
    throw UnsupportedError(
      LocalizationService.instance.current.webTempDirUnsupported_7281,
    );
  }

  /// Web平台不支持创建目录
  static void createDirectory(String path) {
    throw UnsupportedError(
      LocalizationService
          .instance
          .current
          .webPlatformUnsupportedDirectoryCreation_4821,
    );
  }

  /// Web平台不支持创建文件
  static void createFile(String path) {
    throw UnsupportedError(
      LocalizationService.instance.current.webPlatformNotSupported_7281,
    );
  }

  /// Web平台不需要清理临时文件
  static Future<void> cleanupTempFiles() async {
    // Web平台不需要清理临时文件，因为不会创建临时文件
    debugPrint(
      LocalizationService.instance.current.webPlatformNoNeedCleanTempFiles_4821,
    );
  }

  /// Web平台不支持生成临时文件
  static Future<String?> generateTempFile(
    String vfsPath,
    List<int> data,
    String? mimeType,
  ) async {
    // Web平台不支持生成临时文件，应该使用Data URI或Blob URL
    throw UnsupportedError(
      LocalizationService.instance.current.webPlatformNotSupportTempFile_4821,
    );
  }
}
