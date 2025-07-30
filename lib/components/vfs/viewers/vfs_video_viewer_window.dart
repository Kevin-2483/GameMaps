// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../../../components/common/floating_window.dart';
import '../../../services/virtual_file_system/vfs_service_provider.dart';
import '../../../services/vfs/vfs_file_opener_service.dart';
import '../../../services/virtual_file_system/vfs_protocol.dart';
import 'media_kit_video_player.dart';
import '../../../services/notification/notification_service.dart';

import '../../../services/localization_service.dart';

/// VFS视频查看器窗口
class VfsVideoViewerWindow extends StatefulWidget {
  /// VFS文件路径
  final String vfsPath;

  /// 文件信息（可选）
  final VfsFileInfo? fileInfo;

  /// 窗口配置
  final VfsFileOpenConfig config;

  /// 关闭回调
  final VoidCallback? onClose;

  const VfsVideoViewerWindow({
    super.key,
    required this.vfsPath,
    this.fileInfo,
    required this.config,
    this.onClose,
  });

  /// 显示视频查看器窗口
  static Future<void> show(
    BuildContext context, {
    required String vfsPath,
    VfsFileInfo? fileInfo,
    VfsFileOpenConfig? config,
  }) {
    final finalConfig = config ?? VfsFileOpenConfig.forVideo;

    return FloatingWindow.show(
      context,
      title: _getTitleFromPath(vfsPath, fileInfo),
      subtitle: _getSubtitleFromPath(vfsPath, fileInfo),
      icon: Icons.videocam,
      widthRatio: finalConfig.widthRatio,
      heightRatio: finalConfig.heightRatio,
      minSize: finalConfig.minSize ?? const Size(640, 360),
      maxSize: finalConfig.maxSize,
      draggable: finalConfig.draggable,
      resizable: finalConfig.resizable,
      barrierDismissible: finalConfig.barrierDismissible,
      child: VfsVideoViewerWindow(
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
    final parts = <String>[];

    if (fileInfo != null) {
      // 显示文件大小
      if (fileInfo.size > 0) {
        parts.add(_formatFileSize(fileInfo.size));
      } // 显示修改时间
      parts.add(
        LocalizationService.instance.current.modifiedAtText_7281(
          _formatDateTime(fileInfo.modifiedAt),
        ),
      );
    }

    // 如果没有其他信息，显示文件类型
    if (parts.isEmpty) {
      final extension = vfsPath.split('.').last.toUpperCase();
      parts.add(
        '$extension ${LocalizationService.instance.current.videoFile_7421}',
      );
    }

    return parts.join(' • ');
  }

  /// 格式化文件大小
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// 格式化日期时间
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  State<VfsVideoViewerWindow> createState() => _VfsVideoViewerWindowState();
}

class _VfsVideoViewerWindowState extends State<VfsVideoViewerWindow> {
  final VfsServiceProvider _vfsService = VfsServiceProvider();

  bool _isLoading = true;
  String? _errorMessage;
  VfsFileInfo? _fileInfo;
  bool _showControls = true;
  bool _autoPlay = false;
  bool _looping = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _loadVideoInfo();
  }

  /// 加载视频信息
  Future<void> _loadVideoInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 如果没有传入文件信息，尝试从VFS获取
      if (widget.fileInfo == null) {
        try {
          final vfsInfo = await _vfsService.vfs.getFileInfo(widget.vfsPath);
          if (vfsInfo != null) {
            setState(() {
              _fileInfo = vfsInfo;
            });
          }
        } catch (e) {
          debugPrint(
            LocalizationService.instance.current.vfsFileInfoError_4821(e),
          );
        }
      } else {
        _fileInfo = widget.fileInfo;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = LocalizationService.instance.current
            .videoInfoLoadFailed(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    return Column(
      children: [
        // 工具栏
        if (_showControls) _buildToolbar(),
        // 视频播放器区域
        Expanded(child: _buildVideoPlayer()),
      ],
    );
  }

  /// 构建工具栏
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 播放控制
          _buildPlaybackControls(),
          const Spacer(),

          // 音量控制
          IconButton(
            onPressed: () => setState(() => _muted = !_muted),
            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
            tooltip: _muted
                ? LocalizationService.instance.current.unmute_4821
                : LocalizationService.instance.current.mute_4821,
          ),

          // 循环播放
          IconButton(
            onPressed: () => setState(() => _looping = !_looping),
            icon: Icon(
              Icons.repeat,
              color: _looping ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: _looping
                ? LocalizationService.instance.current.stopLooping_5421
                : LocalizationService.instance.current.startLooping_5422,
          ),

          // 隐藏/显示控制栏
          IconButton(
            onPressed: () => setState(() => _showControls = !_showControls),
            icon: const Icon(Icons.fullscreen),
            tooltip: LocalizationService.instance.current.fullscreenMode_7281,
          ),

          // 更多选项
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 8),
                    Text(LocalizationService.instance.current.videoInfo_4271),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy_url',
                child: Row(
                  children: [
                    const Icon(Icons.copy),
                    const SizedBox(width: 8),
                    Text(LocalizationService.instance.current.copyLink_1234),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建播放控制按钮
  Widget _buildPlaybackControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 自动播放开关
        InkWell(
          onTap: () => setState(() => _autoPlay = !_autoPlay),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 16,
                  color: _autoPlay
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: 4),
                Text(
                  LocalizationService.instance.current.autoPlayText_4821,
                  style: TextStyle(
                    fontSize: 12,
                    color: _autoPlay
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建视频播放器
  Widget _buildVideoPlayer() {
    return Container(
      color: Colors.black,
      child: Center(
        child: MediaKitVideoPlayer(
          url: widget.vfsPath,
          config: MediaKitVideoConfig(
            autoPlay: _autoPlay,
            looping: _looping,
            aspectRatio: 16 / 9, // 默认宽高比
          ),
          muted: _muted,
        ),
      ),
    );
  }

  /// 构建加载中组件
  Widget _buildLoadingWidget() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(LocalizationService.instance.current.loadingVideo_7421),
          ],
        ),
      ),
    );
  }

  /// 构建错误组件
  Widget _buildErrorWidget() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              LocalizationService.instance.current.videoLoadFailed_4821,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade500, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _retryLoading(),
                  icon: const Icon(Icons.refresh),
                  label: Text(LocalizationService.instance.current.retry_7281),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _copyUrlToClipboard(),
                  icon: const Icon(Icons.copy),
                  label: Text(
                    LocalizationService.instance.current.copyLink_4271,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'info':
        _showVideoInfo();
        break;
      case 'copy_url':
        _copyUrlToClipboard();
        break;
    }
  }

  /// 显示视频信息
  void _showVideoInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.videoInfo_4271),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              LocalizationService.instance.current.fileName_4821,
              widget.vfsPath.split('/').last,
            ),
            _buildInfoRow(
              LocalizationService.instance.current.pathLabel_4821,
              widget.vfsPath,
            ),
            if (_fileInfo != null) ...[
              _buildInfoRow(
                LocalizationService.instance.current.fileSize_4821,
                VfsVideoViewerWindow._formatFileSize(_fileInfo!.size),
              ),
              _buildInfoRow(
                LocalizationService.instance.current.modifiedTimeLabel_4821,
                VfsVideoViewerWindow._formatDateTime(_fileInfo!.modifiedAt),
              ),
            ],
            _buildInfoRow(
              LocalizationService.instance.current.fileType_4821,
              '${widget.vfsPath.split('.').last.toUpperCase()} ${LocalizationService.instance.current.videoFile_4821}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              LocalizationService.instance.current.confirmButton_7281,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  /// 重试加载
  void _retryLoading() {
    _loadVideoInfo();
  }

  /// 复制URL到剪贴板
  void _copyUrlToClipboard() {
    // 这里可以添加复制到剪贴板的功能
    debugPrint(
      LocalizationService.instance.current.copyVideoLink(widget.vfsPath),
    );
    context.showSuccessSnackBar(
      LocalizationService.instance.current.videoLinkCopiedToClipboard_4821,
    );
  }
}
