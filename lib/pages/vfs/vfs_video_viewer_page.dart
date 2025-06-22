import 'package:flutter/material.dart';
import '../../components/layout/main_layout.dart';
import '../../components/vfs/viewers/media_kit_video_player.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';
import '../../services/virtual_file_system/vfs_service_provider.dart';

/// VFS 视频查看器页面
class VfsVideoViewerPage extends BasePage {
  /// VFS文件路径
  final String vfsPath;

  /// 文件信息（可选）
  final VfsFileInfo? fileInfo;

  /// 关闭回调
  final VoidCallback? onClose;

  const VfsVideoViewerPage({
    super.key,
    required this.vfsPath,
    this.fileInfo,
    this.onClose,
  });

  @override
  Widget buildContent(BuildContext context) {
    return _VfsVideoViewerPageContent(
      vfsPath: vfsPath,
      fileInfo: fileInfo,
      onClose: onClose,
    );
  }
}

class _VfsVideoViewerPageContent extends StatefulWidget {
  final String vfsPath;
  final VfsFileInfo? fileInfo;
  final VoidCallback? onClose;

  const _VfsVideoViewerPageContent({
    required this.vfsPath,
    this.fileInfo,
    this.onClose,
  });

  @override
  State<_VfsVideoViewerPageContent> createState() =>
      _VfsVideoViewerPageContentState();
}

class _VfsVideoViewerPageContentState
    extends State<_VfsVideoViewerPageContent> {
  final VfsServiceProvider _vfsService = VfsServiceProvider();
  
  bool _isLoading = true;
  String? _errorMessage;
  VfsFileInfo? _fileInfo;
  bool _isFullscreen = false;
  bool _autoPlay = true;
  bool _looping = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _loadVideoInfo();
  }

  /// 获取页面标题
  String _getPageTitle() {
    if (_fileInfo != null) {
      return _fileInfo!.name;
    }
    return widget.vfsPath.split('/').last;
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
          print('获取VFS文件信息失败: $e');
        }
      } else {
        _fileInfo = widget.fileInfo;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载视频信息失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullscreen ? null : _buildAppBar(),
      body: _isLoading ? _buildLoadingWidget() : _buildVideoContent(),
      backgroundColor: Colors.black,
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_getPageTitle()),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // 自动播放开关
        IconButton(
          icon: Icon(
            _autoPlay ? Icons.play_circle_filled : Icons.play_circle_outline,
            color: _autoPlay ? Colors.green : Colors.white,
          ),
          onPressed: () => setState(() => _autoPlay = !_autoPlay),
          tooltip: _autoPlay ? '关闭自动播放' : '开启自动播放',
        ),

        // 循环播放开关
        IconButton(
          icon: Icon(
            Icons.repeat,
            color: _looping ? Colors.green : Colors.white,
          ),
          onPressed: () => setState(() => _looping = !_looping),
          tooltip: _looping ? '关闭循环播放' : '开启循环播放',
        ),

        // 静音开关
        IconButton(
          icon: Icon(
            _muted ? Icons.volume_off : Icons.volume_up,
            color: _muted ? Colors.red : Colors.white,
          ),
          onPressed: () => setState(() => _muted = !_muted),
          tooltip: _muted ? '取消静音' : '静音',
        ),

        // 全屏按钮
        IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: _toggleFullscreen,
          tooltip: '全屏模式',
        ),

        // 更多选项
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'window',
              child: Row(
                children: [
                  Icon(Icons.open_in_new),
                  SizedBox(width: 8),
                  Text('在窗口中打开'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('视频信息'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'copy_url',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('复制链接'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建视频内容
  Widget _buildVideoContent() {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
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
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              '正在加载视频...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误组件
  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              '视频加载失败',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _loadVideoInfo(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _copyUrlToClipboard(),
                  icon: const Icon(Icons.copy),
                  label: const Text('复制链接'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 切换全屏模式
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'window':
        _openInWindow();
        break;
      case 'info':
        _showVideoInfo();
        break;
      case 'copy_url':
        _copyUrlToClipboard();
        break;
    }
  }

  /// 在窗口中打开
  void _openInWindow() {
    // 导入视频窗口查看器并在窗口中打开
    Navigator.of(context).pop(); // 关闭当前页面
    // 这里应该调用窗口版本的视频查看器
    print('在窗口中打开视频: ${widget.vfsPath}');
  }

  /// 显示视频信息
  void _showVideoInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('视频信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('文件名', widget.vfsPath.split('/').last),
            _buildInfoRow('路径', widget.vfsPath),
            if (_fileInfo != null) ...[
              _buildInfoRow('大小', _formatFileSize(_fileInfo!.size)),
              _buildInfoRow('修改时间', _formatDateTime(_fileInfo!.modifiedAt)),
            ],
            _buildInfoRow('文件类型', widget.vfsPath.split('.').last.toUpperCase() + ' 视频文件'),
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
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// 复制URL到剪贴板
  void _copyUrlToClipboard() {
    // 这里可以添加复制到剪贴板的功能
    print('复制视频链接: ${widget.vfsPath}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('视频链接已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
