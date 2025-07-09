import 'package:flutter/material.dart';
import '../../../components/common/floating_window.dart';
import '../../../services/vfs/vfs_file_opener_service.dart';
import '../../../services/virtual_file_system/vfs_protocol.dart';
import 'vfs_markdown_renderer.dart';
import '../../../services/notification/notification_service.dart';

/// VFS Markdown查看器窗口
class VfsMarkdownViewerWindow extends StatefulWidget {
  /// VFS文件路径
  final String vfsPath;

  /// 文件信息（可选）
  final VfsFileInfo? fileInfo;

  /// 窗口配置
  final VfsFileOpenConfig config;

  /// 关闭回调
  final VoidCallback? onClose;

  const VfsMarkdownViewerWindow({
    super.key,
    required this.vfsPath,
    this.fileInfo,
    required this.config,
    this.onClose,
  });

  /// 显示Markdown查看器窗口
  static Future<void> show(
    BuildContext context, {
    required String vfsPath,
    VfsFileInfo? fileInfo,
    VfsFileOpenConfig? config,
  }) {
    final finalConfig = config ?? VfsFileOpenConfig.forText;

    return FloatingWindow.show(
      context,
      title: _getTitleFromPath(vfsPath, fileInfo),
      subtitle: _getSubtitleFromPath(vfsPath, fileInfo),
      icon: Icons.description,
      widthRatio: finalConfig.widthRatio,
      heightRatio: finalConfig.heightRatio,
      minSize: finalConfig.minSize ?? const Size(700, 500),
      maxSize: finalConfig.maxSize,
      draggable: finalConfig.draggable,
      resizable: finalConfig.resizable,
      barrierDismissible: finalConfig.barrierDismissible,
      child: VfsMarkdownViewerWindow(
        vfsPath: vfsPath,
        fileInfo: fileInfo,
        config: finalConfig,
      ),
    );
  }

  /// 从路径获取标题
  static String _getTitleFromPath(String vfsPath, VfsFileInfo? fileInfo) {
    if (fileInfo != null) {
      return fileInfo.name;
    }
    return vfsPath.split('/').last;
  }

  /// 从路径获取副标题
  static String _getSubtitleFromPath(String vfsPath, VfsFileInfo? fileInfo) {
    if (fileInfo != null) {
      return '大小: ${_formatFileSize(fileInfo.size)} • 修改时间: ${_formatDateTime(fileInfo.modifiedAt)}';
    }
    return vfsPath;
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  State<VfsMarkdownViewerWindow> createState() =>
      _VfsMarkdownViewerWindowState();
}

class _VfsMarkdownViewerWindowState extends State<VfsMarkdownViewerWindow> {
  @override
  Widget build(BuildContext context) {
    return VfsMarkdownRenderer(
      vfsPath: widget.vfsPath,
      fileInfo: widget.fileInfo,
      config: MarkdownRendererConfig.window,
      onClose: widget.onClose,
      onError: (error) {
        // 可以在这里添加窗口特定的错误处理
        context.showErrorSnackBar(error);
      },
    );
  }
}
