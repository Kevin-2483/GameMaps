/// Web平台的VFS平台接口实现
class VfsPlatformIO {
  /// Web平台不支持获取临时目录
  static Future<void> getTempDirectory() async {
    throw UnsupportedError('Web平台不支持获取临时目录');
  }

  /// Web平台不支持创建目录
  static void createDirectory(String path) {
    throw UnsupportedError('Web平台不支持创建目录');
  }

  /// Web平台不支持创建文件
  static void createFile(String path) {
    throw UnsupportedError('Web平台不支持创建文件');
  }

  /// Web平台不需要清理临时文件
  static Future<void> cleanupTempFiles() async {
    // Web平台不需要清理临时文件，因为不会创建临时文件
    print('🔗 VfsPlatformWeb: Web平台不需要清理临时文件');
  }

  /// Web平台不支持生成临时文件
  static Future<String?> generateTempFile(String vfsPath, List<int> data, String? mimeType) async {
    // Web平台不支持生成临时文件，应该使用Data URI或Blob URL
    throw UnsupportedError('Web平台不支持生成临时文件，请使用Data URI或Blob URL');
  }
}
