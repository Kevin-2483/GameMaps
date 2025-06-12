import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../components/common/floating_window.dart';
import '../../../services/virtual_file_system/vfs_service_provider.dart';
import '../../../services/vfs/vfs_file_opener_service.dart';
import '../../../services/virtual_file_system/vfs_protocol.dart';

/// VFS图片查看器窗口
class VfsImageViewerWindow extends StatefulWidget {
  /// VFS文件路径
  final String vfsPath;

  /// 文件信息（可选）
  final VfsFileInfo? fileInfo;

  /// 窗口配置
  final VfsFileOpenConfig config;

  /// 关闭回调
  final VoidCallback? onClose;

  const VfsImageViewerWindow({
    super.key,
    required this.vfsPath,
    this.fileInfo,
    required this.config,
    this.onClose,
  });

  /// 显示图片查看器窗口
  static Future<void> show(
    BuildContext context, {
    required String vfsPath,
    VfsFileInfo? fileInfo,
    VfsFileOpenConfig? config,
  }) {
    final finalConfig = config ?? VfsFileOpenConfig.forImage;

    return FloatingWindow.show(
      context,
      title: _getTitleFromPath(vfsPath, fileInfo),
      subtitle: _getSubtitleFromPath(vfsPath, fileInfo),
      icon: Icons.image,
      widthRatio: finalConfig.widthRatio,
      heightRatio: finalConfig.heightRatio,
      minSize: finalConfig.minSize ?? const Size(400, 300),
      maxSize: finalConfig.maxSize,
      draggable: finalConfig.draggable,
      resizable: finalConfig.resizable,
      barrierDismissible: finalConfig.barrierDismissible,
      child: VfsImageViewerWindow(
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
  State<VfsImageViewerWindow> createState() => _VfsImageViewerWindowState();
}

class _VfsImageViewerWindowState extends State<VfsImageViewerWindow> {
  final VfsServiceProvider _vfsService = VfsServiceProvider();

  bool _isLoading = true;
  String? _errorMessage;
  Uint8List? _imageData;
  VfsFileInfo? _fileInfo; // 图片查看器状态
  final TransformationController _transformationController =
      TransformationController();
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /// 加载图片
  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fileContent = await _vfsService.vfs.readFile(widget.vfsPath);
      if (fileContent != null) {
        setState(() {
          _imageData = fileContent.data;
          _fileInfo = widget.fileInfo;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '无法读取图片文件';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '加载图片失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 工具栏
        _buildToolbar(),
        // 图片查看区域
        Expanded(child: _buildImageViewer()),
      ],
    );
  }

  /// 构建工具栏
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          // 缩放控制
          IconButton(
            onPressed: _canZoomOut() ? _zoomOut : null,
            icon: const Icon(Icons.zoom_out),
            tooltip: '缩小',
          ),
          Text(
            '${(_getCurrentScale() * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          IconButton(
            onPressed: _canZoomIn() ? _zoomIn : null,
            icon: const Icon(Icons.zoom_in),
            tooltip: '放大',
          ),

          const SizedBox(width: 16),

          // 适应窗口
          IconButton(
            onPressed: _fitToWindow,
            icon: const Icon(Icons.fit_screen),
            tooltip: '适应窗口',
          ),

          // 实际大小
          IconButton(
            onPressed: _actualSize,
            icon: const Icon(Icons.fullscreen),
            tooltip: '实际大小',
          ),

          const Spacer(),

          // 文件信息
          if (_fileInfo != null) ...[
            Text(
              '${_fileInfo!.name}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
          ],

          // 刷新按钮
          IconButton(
            onPressed: _loadImage,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
    );
  }

  /// 构建图片查看器
  Widget _buildImageViewer() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载图片中...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadImage, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_imageData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('无法显示图片'),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: _toggleControls,
      onDoubleTap: _toggleActualSize,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.1,
        maxScale: 10.0,
        // 确保启用拖动功能
        panEnabled: true,
        scaleEnabled: true,
        // 设置边界行为，允许图片被拖动到边界外
        boundaryMargin: const EdgeInsets.all(double.infinity),
        onInteractionStart: (details) {
          setState(() {
            _showControls = false;
          });
        },
        onInteractionEnd: (details) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showControls = true;
              });
            }
          });
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black12,
          child: Center(
            child: Image.memory(
              _imageData!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('图片格式不支持或已损坏'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 获取当前缩放比例
  double _getCurrentScale() {
    return _transformationController.value.getMaxScaleOnAxis();
  }

  /// 设置缩放比例
  void _setScale(double scale) {
    final matrix = Matrix4.identity()..scale(scale);
    _transformationController.value = matrix;
    setState(() {}); // 触发重建以更新工具栏显示
  }

  /// 缩小
  void _zoomOut() {
    final currentScale = _getCurrentScale();
    final newScale = (currentScale / 1.2).clamp(0.1, 10.0);
    _setScale(newScale);
  }

  /// 放大
  void _zoomIn() {
    final currentScale = _getCurrentScale();
    final newScale = (currentScale * 1.2).clamp(0.1, 10.0);
    _setScale(newScale);
  }

  /// 是否可以缩小
  bool _canZoomOut() => _getCurrentScale() > 0.1;

  /// 是否可以放大
  bool _canZoomIn() => _getCurrentScale() < 10.0;

  /// 适应窗口
  void _fitToWindow() {
    _transformationController.value = Matrix4.identity();
    setState(() {}); // 触发重建以更新工具栏显示
  }

  /// 实际大小
  void _actualSize() {
    _setScale(1.0);
  }

  /// 切换控制栏显示
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  /// 切换实际大小
  void _toggleActualSize() {
    final currentScale = _getCurrentScale();
    if ((currentScale - 1.0).abs() < 0.1) {
      _fitToWindow();
    } else {
      _actualSize();
    }
  }
}
