import 'package:flutter/material.dart';
import '../../components/vfs/viewers/vfs_image_viewer_window.dart';
import '../../components/vfs/viewers/vfs_text_viewer_window.dart';
import '../../components/vfs/viewers/vfs_markdown_viewer_window.dart';
import '../../components/vfs/viewers/vfs_video_viewer_window.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';

/// VFS文件打开配置
class VfsFileOpenConfig {
  /// 窗口位置（相对于屏幕的偏移）
  final Offset? position;

  /// 窗口大小比例
  final double widthRatio;
  final double heightRatio;

  /// 最小和最大尺寸
  final Size? minSize;
  final Size? maxSize;

  /// 是否可拖拽
  final bool draggable;

  /// 是否可调整大小
  final bool resizable;

  /// 是否允许点击遮罩关闭
  final bool barrierDismissible;

  /// 自定义窗口标题
  final String? customTitle;

  /// 自定义副标题
  final String? customSubtitle;

  const VfsFileOpenConfig({
    this.position,
    this.widthRatio = 0.8,
    this.heightRatio = 0.8,
    this.minSize,
    this.maxSize,
    this.draggable = true,
    this.resizable = false,
    this.barrierDismissible = true,
    this.customTitle,
    this.customSubtitle,
  });

  /// 为图片查看器创建默认配置
  static const VfsFileOpenConfig forImage = VfsFileOpenConfig(
    widthRatio: 0.9,
    heightRatio: 0.9,
    draggable: true,
    resizable: true,
    barrierDismissible: true,
  );

  /// 为文本查看器创建默认配置
  static const VfsFileOpenConfig forText = VfsFileOpenConfig(
    widthRatio: 0.8,
    heightRatio: 0.8,
    draggable: true,
    resizable: true,
    barrierDismissible: true,
  );
  /// 为Markdown查看器创建默认配置
  static const VfsFileOpenConfig forMarkdown = VfsFileOpenConfig(
    widthRatio: 0.85,
    heightRatio: 0.9,
    draggable: true,
    resizable: true,
    barrierDismissible: true,
  );

  /// 为视频查看器创建默认配置
  static const VfsFileOpenConfig forVideo = VfsFileOpenConfig(
    widthRatio: 0.9,
    heightRatio: 0.8,
    draggable: true,
    resizable: true,
    barrierDismissible: true,
  );

  /// 为小窗口创建配置
  static const VfsFileOpenConfig small = VfsFileOpenConfig(
    widthRatio: 0.5,
    heightRatio: 0.6,
    draggable: true,
    resizable: false,
    barrierDismissible: true,
  );

  /// 为全屏创建配置
  static const VfsFileOpenConfig fullscreen = VfsFileOpenConfig(
    widthRatio: 0.95,
    heightRatio: 0.95,
    draggable: false,
    resizable: false,
    barrierDismissible: false,
  );
}

/// 支持的文件类型
enum VfsFileType {
  image,
  text,
  json,
  markdown,
  pdf,
  video,
  audio,
  archive,
  unknown,
}

/// VFS文件打开服务
class VfsFileOpenerService {
  static final VfsFileOpenerService _instance =
      VfsFileOpenerService._internal();
  factory VfsFileOpenerService() => _instance;
  VfsFileOpenerService._internal();

  /// 打开VFS文件
  static Future<void> openFile(
    BuildContext context,
    String vfsPath, {
    VfsFileOpenConfig? config,
    VfsFileInfo? fileInfo,
  }) async {
    try {
      final service = VfsFileOpenerService();
      await service._openFile(
        context,
        vfsPath,
        config: config,
        fileInfo: fileInfo,
      );
    } catch (e) {
      _showErrorDialog(context, '打开文件失败', e.toString());
    }
  }

  /// 内部打开文件方法
  Future<void> _openFile(
    BuildContext context,
    String vfsPath, {
    VfsFileOpenConfig? config,
    VfsFileInfo? fileInfo,
  }) async {
    final fileType = _getFileType(vfsPath);
    final defaultConfig = _getDefaultConfig(fileType);
    final finalConfig = config ?? defaultConfig;    switch (fileType) {
      case VfsFileType.image:
        await _openImageFile(context, vfsPath, finalConfig, fileInfo);
        break;
      case VfsFileType.text:
      case VfsFileType.json:
        await _openTextFile(context, vfsPath, finalConfig, fileInfo);
        break;
      case VfsFileType.markdown:
        await _openMarkdownFile(context, vfsPath, finalConfig, fileInfo);
        break;
      case VfsFileType.video:
        await _openVideoFile(context, vfsPath, finalConfig, fileInfo);
        break;
      default:
        _showUnsupportedFileDialog(context, vfsPath, fileType);
    }
  }

  /// 打开图片文件
  Future<void> _openImageFile(
    BuildContext context,
    String vfsPath,
    VfsFileOpenConfig config,
    VfsFileInfo? fileInfo,
  ) async {
    await VfsImageViewerWindow.show(
      context,
      vfsPath: vfsPath,
      fileInfo: fileInfo,
      config: config,
    );
  }

  /// 打开文本文件
  Future<void> _openTextFile(
    BuildContext context,
    String vfsPath,
    VfsFileOpenConfig config,
    VfsFileInfo? fileInfo,
  ) async {
    await VfsTextViewerWindow.show(
      context,
      vfsPath: vfsPath,
      fileInfo: fileInfo,
      config: config,
    );
  }
  /// 打开Markdown文件
  Future<void> _openMarkdownFile(
    BuildContext context,
    String vfsPath,
    VfsFileOpenConfig config,
    VfsFileInfo? fileInfo,
  ) async {
    await VfsMarkdownViewerWindow.show(
      context,
      vfsPath: vfsPath,
      fileInfo: fileInfo,
      config: config,
    );
  }

  /// 打开视频文件
  Future<void> _openVideoFile(
    BuildContext context,
    String vfsPath,
    VfsFileOpenConfig config,
    VfsFileInfo? fileInfo,
  ) async {
    await VfsVideoViewerWindow.show(
      context,
      vfsPath: vfsPath,
      fileInfo: fileInfo,
      config: config,
    );
  }

  /// 获取文件类型
  VfsFileType _getFileType(String vfsPath) {
    final extension = vfsPath.split('.').last.toLowerCase();

    switch (extension) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'svg':
        return VfsFileType.image;

      case 'txt':
      case 'log':
      case 'csv':
        return VfsFileType.text;

      case 'json':
        return VfsFileType.json;

      case 'md':
      case 'markdown':
        return VfsFileType.markdown;

      case 'pdf':
        return VfsFileType.pdf;

      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        return VfsFileType.video;

      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
        return VfsFileType.audio;

      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
        return VfsFileType.archive;

      default:
        return VfsFileType.unknown;
    }
  }
  /// 获取默认配置
  VfsFileOpenConfig _getDefaultConfig(VfsFileType fileType) {
    switch (fileType) {
      case VfsFileType.image:
        return VfsFileOpenConfig.forImage;
      case VfsFileType.text:
      case VfsFileType.json:
        return VfsFileOpenConfig.forText;
      case VfsFileType.markdown:
        return VfsFileOpenConfig.forMarkdown;
      case VfsFileType.video:
        return VfsFileOpenConfig.forVideo;
      default:
        return const VfsFileOpenConfig();
    }
  }

  /// 显示不支持的文件类型对话框
  static void _showUnsupportedFileDialog(
    BuildContext context,
    String vfsPath,
    VfsFileType fileType,
  ) {
    final fileName = vfsPath.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('不支持的文件类型'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('文件名: $fileName'),
            Text('文件类型: .$extension'),
            const SizedBox(height: 16),            const Text('当前支持的文件类型:'),
            const Text('• 图片: png, jpg, jpeg, gif, bmp, webp, svg'),
            const Text('• 视频: mp4, avi, mov, wmv'),
            const Text('• 文本: txt, log, csv, json'),
            const Text('• Markdown: md, markdown'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示错误对话框
  static void _showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// VFS文件打开扩展方法
extension VfsFileOpenerExtensions on BuildContext {
  /// 打开VFS文件的便捷方法
  Future<void> openVfsFile(
    String vfsPath, {
    VfsFileOpenConfig? config,
    VfsFileInfo? fileInfo,
  }) {
    return VfsFileOpenerService.openFile(
      this,
      vfsPath,
      config: config,
      fileInfo: fileInfo,
    );
  }
}
