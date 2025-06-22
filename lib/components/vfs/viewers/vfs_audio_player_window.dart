import 'package:flutter/material.dart';
import 'dart:async';
import '../../../components/common/floating_window.dart';
import '../../../services/virtual_file_system/vfs_service_provider.dart';
import '../../../services/vfs/vfs_file_opener_service.dart';
import '../../../services/virtual_file_system/vfs_protocol.dart';
import '../../../services/audio/audio_player_service.dart';
import 'audio_player_widget.dart';

/// VFS音频播放器窗口
class VfsAudioPlayerWindow extends StatefulWidget {
  /// VFS文件路径
  final String vfsPath;

  /// 文件信息（可选）
  final VfsFileInfo? fileInfo;

  /// 窗口配置
  final VfsFileOpenConfig config;

  /// 关闭回调
  final VoidCallback? onClose;

  const VfsAudioPlayerWindow({
    super.key,
    required this.vfsPath,
    this.fileInfo,
    required this.config,
    this.onClose,
  });

  /// 显示音频播放器窗口
  static Future<void> show(
    BuildContext context, {
    required String vfsPath,
    VfsFileInfo? fileInfo,
    VfsFileOpenConfig? config,
  }) {
    final finalConfig = config ?? VfsFileOpenConfig.forAudio;

    return FloatingWindow.show(
      context,
      title: _getTitleFromPath(vfsPath, fileInfo),
      subtitle: _getSubtitleFromPath(vfsPath, fileInfo),
      icon: Icons.audiotrack,
      widthRatio: finalConfig.widthRatio,
      heightRatio: finalConfig.heightRatio,
      minSize: finalConfig.minSize ?? const Size(400, 300),
      maxSize: finalConfig.maxSize,
      draggable: finalConfig.draggable,
      resizable: finalConfig.resizable,
      barrierDismissible: finalConfig.barrierDismissible,      child: VfsAudioPlayerWindow(
        vfsPath: vfsPath,
        fileInfo: fileInfo,
        config: finalConfig,
        onClose: null, // 不传递回调，让FloatingWindow自己处理关闭
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
      }
      // 显示修改时间
      parts.add('修改于 ${_formatDateTime(fileInfo.modifiedAt)}');
    }

    // 如果没有其他信息，显示文件类型
    if (parts.isEmpty) {
      final extension = vfsPath.split('.').last.toUpperCase();
      parts.add('$extension 音频文件');
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
  State<VfsAudioPlayerWindow> createState() => _VfsAudioPlayerWindowState();
}

class _VfsAudioPlayerWindowState extends State<VfsAudioPlayerWindow> {
  final VfsServiceProvider _vfsService = VfsServiceProvider();
  Timer? _uiRefreshTimer;

  bool _isLoading = true;
  String? _errorMessage;
  VfsFileInfo? _fileInfo;

  @override
  void initState() {
    super.initState();
    _loadAudioInfo();
    
    // 添加定期UI刷新机制，确保状态同步
    _uiRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // 触发UI刷新
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _uiRefreshTimer?.cancel();
    // 不在dispose中调用onClose，避免在组件销毁后操作Navigator
    super.dispose();
  }
  /// 加载音频信息
  Future<void> _loadAudioInfo() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 如果没有传入文件信息，尝试从VFS获取
      if (widget.fileInfo == null) {
        try {
          final vfsInfo = await _vfsService.vfs.getFileInfo(widget.vfsPath);
          if (vfsInfo != null && mounted) {
            setState(() {
              _fileInfo = vfsInfo;
            });
          }
        } catch (e) {
          print('获取VFS文件信息失败: $e');
        }
      } else {
        _fileInfo = widget.fileInfo;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载音频信息失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_isLoading) {
      return _buildLoadingWidget();
    }    return AudioPlayerWidget(
      source: widget.vfsPath,
      title: _getTitleFromFileInfo(),
      artist: _getArtistFromFileInfo(),
      isVfsPath: true,
      config: const AudioPlayerConfig(
        autoPlay: false,
        looping: false,
      ),
      onError: (message) {
        if (mounted) {
          setState(() {
            _errorMessage = message;
          });
        }
      },
    );
  }

  /// 从文件信息获取标题
  String _getTitleFromFileInfo() {
    if (_fileInfo != null) {
      return _fileInfo!.name.split('.').first;
    }
    return widget.vfsPath.split('/').last.split('.').first;
  }

  /// 从文件信息获取艺术家信息
  String? _getArtistFromFileInfo() {
    // 这里可以扩展，从文件元数据中获取艺术家信息
    return null;
  }

  /// 构建加载中组件
  Widget _buildLoadingWidget() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载音频...'),
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
              '音频加载失败',
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
                  label: const Text('重试'),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _copyUrlToClipboard(),
                  icon: const Icon(Icons.copy),
                  label: const Text('复制链接'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  /// 重试加载
  void _retryLoading() {
    if (mounted) {
      _loadAudioInfo();
    }
  }

  /// 复制URL到剪贴板
  void _copyUrlToClipboard() {
    // 这里可以添加复制到剪贴板的功能
    print('复制音频链接: ${widget.vfsPath}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('音频链接已复制到剪贴板'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
