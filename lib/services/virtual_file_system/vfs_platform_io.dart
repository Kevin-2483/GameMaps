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

    // 从MIME类型推断文件扩展名
    String extension = '.bin'; // 默认扩展名
    if (mimeType != null) {
      if (mimeType.contains('video/mp4')) {
        extension = '.mp4';
      } else if (mimeType.contains('video/webm')) {
        extension = '.webm';
      } else if (mimeType.contains('video/ogg')) {
        extension = '.ogg';
      } else if (mimeType.contains('video/quicktime') ||
          mimeType.contains('video/mov')) {
        extension = '.mov';
      } else if (mimeType.contains('video/x-msvideo')) {
        extension = '.avi';
      } else if (mimeType.contains('video/x-matroska')) {
        extension = '.mkv';
      } else if (mimeType.contains('image/png')) {
        extension = '.png';
      } else if (mimeType.contains('image/jpeg')) {
        extension = '.jpg';
      } else if (mimeType.contains('image/gif')) {
        extension = '.gif';
      } else if (mimeType.contains('text/plain')) {
        extension = '.txt';
      } else if (mimeType.contains('application/json')) {
        extension = '.json';
      }
    }

    return 'vfs_file_$pathHash$extension';
  }

  /// 比较两个字节数组是否相等
  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
