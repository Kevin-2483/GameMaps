import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// IO平台（移动端/桌面端）的VFS平台接口实现
class VfsPlatformIO {
  /// 获取临时目录（使用应用运行目录）
  static Future<Directory> getTempDirectory() async {
    // 获取应用文档目录作为基础目录
    final appDocDir = await getApplicationDocumentsDirectory();

    // 在应用文档目录下创建temp子目录
    final tempDir = Directory(path.join(appDocDir.path, 'r6box'));

    // 确保目录存在
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
      debugPrint('🔗 VfsPlatformIO: 创建应用临时目录 - ${tempDir.path}');
    }

    return tempDir;
  }

  /// 创建目录
  static Directory createDirectory(String path) {
    return Directory(path);
  }

  /// 创建文件
  static File createFile(String path) {
    return File(path);
  }

  /// 获取WebDAV导入临时目录
  static Future<Directory> getWebDAVImportTempDirectory() async {
    // 获取基础临时目录
    final tempDir = await getTempDirectory();
    
    // 在基础目录下创建webdav_import子目录
    final webdavImportDir = createDirectory('${tempDir.path}/webdav_import');
    
    // 确保目录存在
    if (!await webdavImportDir.exists()) {
      await webdavImportDir.create(recursive: true);
      debugPrint('🔗 VfsPlatformIO: 创建WebDAV导入临时目录 - ${webdavImportDir.path}');
    }
    
    return webdavImportDir;
  }

  /// 生成WebDAV导入临时文件路径
  static Future<String> generateWebDAVImportTempFilePath(String fileName) async {
    final webdavImportDir = await getWebDAVImportTempDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeFileName = _sanitizeFileName(fileName);
    return '${webdavImportDir.path}/webdav_import_${timestamp}_$safeFileName';
  }

  /// 清理WebDAV导入临时文件
  static Future<void> cleanupWebDAVImportTempFiles() async {
    try {
      final tempDir = await getTempDirectory();
      final webdavImportDir = createDirectory('${tempDir.path}/webdav_import');

      if (await webdavImportDir.exists()) {
        await webdavImportDir.delete(recursive: true);
        debugPrint('🔗 VfsPlatformIO: 已清理WebDAV导入临时文件');
      }
    } catch (e) {
      debugPrint('🔗 VfsPlatformIO: 清理WebDAV导入临时文件失败 - $e');
    }
  }

  /// 清理VFS临时文件
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTempDirectory();
      final vfsFilesDir = createDirectory('${tempDir.path}/vfs_files');

      if (await vfsFilesDir.exists()) {
        await vfsFilesDir.delete(recursive: true);
        debugPrint('🔗 VfsPlatformIO: 已清理临时文件');
      }
    } catch (e) {
      debugPrint('🔗 VfsPlatformIO: 清理临时文件失败 - $e');
    }
  }

  /// 清理所有临时文件（包括VFS和WebDAV导入）
  static Future<void> cleanupAllTempFiles() async {
    await Future.wait([
      cleanupTempFiles(),
      cleanupWebDAVImportTempFiles(),
    ]);
  }

  /// 生成临时文件
  static Future<String?> generateTempFile(
    String vfsPath,
    List<int> data,
    String? mimeType,
  ) async {
    try {
      debugPrint('🔗 VfsPlatformIO: 开始创建临时文件');

      // 获取临时目录
      final tempDir = await getTempDirectory();
      final vfsVideoDir = createDirectory('${tempDir.path}/vfs_files');

      // 确保目录存在
      if (!await vfsVideoDir.exists()) {
        await vfsVideoDir.create(recursive: true);
      }

      // 从VFS路径生成文件名
      final fileName = _generateTempFileName(vfsPath, mimeType);
      final tempFile = createFile('${vfsVideoDir.path}/$fileName');

      // 检查文件是否已存在且内容相同
      if (await tempFile.exists()) {
        final existingData = await tempFile.readAsBytes();
        if (_bytesEqual(existingData, data)) {
          debugPrint('🔗 VfsPlatformIO: 临时文件已存在，直接返回路径');
          return tempFile.path;
        }
      }

      // 写入临时文件
      await tempFile.writeAsBytes(data);
      debugPrint('🔗 VfsPlatformIO: 成功创建临时文件 - ${tempFile.path}');

      return tempFile.path;
    } catch (e) {
      debugPrint('🔗 VfsPlatformIO: 生成临时文件失败 - $e');
      return null;
    }
  }

  /// 生成临时文件名
  static String _generateTempFileName(String vfsPath, String? mimeType) {
    // 从VFS路径生成哈希值作为文件名
    final pathHash = vfsPath.hashCode.abs().toString();

    // 优先从MIME类型推断文件扩展名
    String extension = _getExtensionFromMimeType(mimeType);

    // 如果MIME类型无法确定扩展名（返回.bin），尝试从文件名中提取
    if (extension == '.bin') {
      extension = _getExtensionFromFileName(vfsPath) ?? '.bin';
    }

    return 'vfs_file_$pathHash$extension';
  }

  /// 从文件名中提取扩展名
  static String? _getExtensionFromFileName(String filePath) {
    // 获取文件名（去掉路径）
    final fileName = filePath.split('/').last;

    // 查找最后一个点的位置
    final lastDotIndex = fileName.lastIndexOf('.');

    // 如果没有找到点，或者点在开头（隐藏文件），返回null
    if (lastDotIndex == -1 || lastDotIndex == 0) {
      return null;
    }

    // 提取扩展名（包含点）
    final extension = fileName.substring(lastDotIndex).toLowerCase();

    // 验证扩展名是否合理（长度在1-10之间，只包含字母数字）
    if (extension.length > 1 && extension.length <= 10) {
      final extWithoutDot = extension.substring(1);
      if (RegExp(r'^[a-z0-9]+$').hasMatch(extWithoutDot)) {
        return extension;
      }
    }

    return null;
  }

  /// 从MIME类型获取文件扩展名
  static String _getExtensionFromMimeType(String? mimeType) {
    if (mimeType == null) return '.bin';

    // 完整的MIME类型到扩展名映射表
    const mimeToExt = {
      // 图片类型
      'image/png': '.png',
      'image/jpeg': '.jpg',
      'image/jpg': '.jpg',
      'image/gif': '.gif',
      'image/webp': '.webp',
      'image/svg+xml': '.svg',
      'image/bmp': '.bmp',
      'image/tiff': '.tiff',
      'image/ico': '.ico',

      // 视频类型
      'video/mp4': '.mp4',
      'video/webm': '.webm',
      'video/ogg': '.ogg',
      'video/quicktime': '.mov',
      'video/mov': '.mov',
      'video/x-msvideo': '.avi',
      'video/x-matroska': '.mkv',
      'video/x-flv': '.flv',
      'video/3gpp': '.3gp',
      'video/x-ms-wmv': '.wmv',

      // 音频类型
      'audio/mpeg': '.mp3',
      'audio/wav': '.wav',
      'audio/ogg': '.ogg',
      'audio/aac': '.aac',
      'audio/flac': '.flac',
      'audio/x-ms-wma': '.wma',

      // 文档类型
      'application/pdf': '.pdf',
      'application/msword': '.doc',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
          '.docx',
      'application/vnd.ms-excel': '.xls',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
          '.xlsx',
      'application/vnd.ms-powerpoint': '.ppt',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation':
          '.pptx',

      // 文本类型
      'text/plain': '.txt',
      'text/html': '.html',
      'text/css': '.css',
      'text/javascript': '.js',
      'text/markdown': '.md',
      'text/csv': '.csv',
      'text/xml': '.xml',

      // 数据类型
      'application/json': '.json',
      'application/xml': '.xml',
      'application/yaml': '.yaml',
      'application/x-yaml': '.yml',

      // 压缩文件
      'application/zip': '.zip',
      'application/x-rar-compressed': '.rar',
      'application/x-7z-compressed': '.7z',
      'application/x-tar': '.tar',
      'application/gzip': '.gz',

      // 其他常见类型
      'application/octet-stream': '.bin',
      'application/x-executable': '.exe',
      'application/x-sharedlib': '.so',
      'application/x-mach-binary': '.dylib',
    };

    // 首先尝试精确匹配
    final exactMatch = mimeToExt[mimeType.toLowerCase()];
    if (exactMatch != null) {
      return exactMatch;
    }

    // 如果没有精确匹配，尝试部分匹配
    final lowerMimeType = mimeType.toLowerCase();

    // 视频类型的部分匹配
    if (lowerMimeType.startsWith('video/')) {
      if (lowerMimeType.contains('mp4')) return '.mp4';
      if (lowerMimeType.contains('webm')) return '.webm';
      if (lowerMimeType.contains('ogg')) return '.ogg';
      if (lowerMimeType.contains('quicktime') || lowerMimeType.contains('mov'))
        return '.mov';
      if (lowerMimeType.contains('msvideo') || lowerMimeType.contains('avi'))
        return '.avi';
      if (lowerMimeType.contains('matroska') || lowerMimeType.contains('mkv'))
        return '.mkv';
      if (lowerMimeType.contains('flv')) return '.flv';
      if (lowerMimeType.contains('3gpp')) return '.3gp';
      if (lowerMimeType.contains('wmv')) return '.wmv';
      return '.mp4'; // 默认视频扩展名
    }

    // 音频类型的部分匹配
    if (lowerMimeType.startsWith('audio/')) {
      if (lowerMimeType.contains('mpeg') || lowerMimeType.contains('mp3'))
        return '.mp3';
      if (lowerMimeType.contains('wav')) return '.wav';
      if (lowerMimeType.contains('ogg')) return '.ogg';
      if (lowerMimeType.contains('aac')) return '.aac';
      if (lowerMimeType.contains('flac')) return '.flac';
      if (lowerMimeType.contains('wma')) return '.wma';
      return '.mp3'; // 默认音频扩展名
    }

    // 图片类型的部分匹配
    if (lowerMimeType.startsWith('image/')) {
      if (lowerMimeType.contains('png')) return '.png';
      if (lowerMimeType.contains('jpeg') || lowerMimeType.contains('jpg'))
        return '.jpg';
      if (lowerMimeType.contains('gif')) return '.gif';
      if (lowerMimeType.contains('webp')) return '.webp';
      if (lowerMimeType.contains('svg')) return '.svg';
      if (lowerMimeType.contains('bmp')) return '.bmp';
      if (lowerMimeType.contains('tiff')) return '.tiff';
      if (lowerMimeType.contains('ico')) return '.ico';
      return '.png'; // 默认图片扩展名
    }

    // 文本类型的部分匹配
    if (lowerMimeType.startsWith('text/')) {
      if (lowerMimeType.contains('html')) return '.html';
      if (lowerMimeType.contains('css')) return '.css';
      if (lowerMimeType.contains('javascript')) return '.js';
      if (lowerMimeType.contains('markdown')) return '.md';
      if (lowerMimeType.contains('csv')) return '.csv';
      if (lowerMimeType.contains('xml')) return '.xml';
      return '.txt'; // 默认文本扩展名
    }

    // 应用程序类型的部分匹配
    if (lowerMimeType.startsWith('application/')) {
      if (lowerMimeType.contains('json')) return '.json';
      if (lowerMimeType.contains('xml')) return '.xml';
      if (lowerMimeType.contains('yaml')) return '.yaml';
      if (lowerMimeType.contains('pdf')) return '.pdf';
      if (lowerMimeType.contains('zip')) return '.zip';
      if (lowerMimeType.contains('rar')) return '.rar';
      if (lowerMimeType.contains('7z')) return '.7z';
      if (lowerMimeType.contains('tar')) return '.tar';
      if (lowerMimeType.contains('gzip')) return '.gz';
    }

    // 如果都没有匹配，返回默认扩展名
    return '.bin';
  }

  /// 比较两个字节数组是否相等
  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// 清理文件名中的非法字符
  static String _sanitizeFileName(String fileName) {
    // 移除或替换文件名中的非法字符
    return fileName
        .replaceAll(RegExp(r'[<>:"/\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
