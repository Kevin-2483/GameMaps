import 'package:flutter/material.dart';
import '../../components/layout/main_layout.dart';
import '../../components/vfs/viewers/vfs_markdown_renderer.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';
import '../../../services/notification/notification_service.dart';

/// VFS Markdown查看器页面
class VfsMarkdownViewerPage extends BasePage {
  /// VFS文件路径
  final String vfsPath;

  /// 文件信息（可选）
  final VfsFileInfo? fileInfo;

  /// 关闭回调
  final VoidCallback? onClose;

  const VfsMarkdownViewerPage({
    super.key,
    required this.vfsPath,
    this.fileInfo,
    this.onClose,
  });

  @override
  Widget buildContent(BuildContext context) {
    return _VfsMarkdownViewerPageContent(
      vfsPath: vfsPath,
      fileInfo: fileInfo,
      onClose: onClose,
    );
  }
}

class _VfsMarkdownViewerPageContent extends StatefulWidget {
  final String vfsPath;
  final VfsFileInfo? fileInfo;
  final VoidCallback? onClose;

  const _VfsMarkdownViewerPageContent({
    required this.vfsPath,
    this.fileInfo,
    this.onClose,
  });

  @override
  State<_VfsMarkdownViewerPageContent> createState() =>
      _VfsMarkdownViewerPageContentState();
}

class _VfsMarkdownViewerPageContentState
    extends State<_VfsMarkdownViewerPageContent> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 页面级工具栏
          _buildPageToolbar(),
          // Markdown渲染器
          Expanded(
            child: VfsMarkdownRenderer(
              vfsPath: widget.vfsPath,
              fileInfo: widget.fileInfo,
              config: MarkdownRendererConfig.page.copyWith(
                customToolbarActions: _buildCustomToolbarActions(),
              ),
              onError: _handleError,
              onLoaded: () {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ),
        ],
      ),
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
      actions: [
        // 全屏按钮
        IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: _toggleFullscreen,
          tooltip: '全屏模式',
        ),

        // 更多选项
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
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
              value: 'share',
              child: Row(
                children: [Icon(Icons.share), SizedBox(width: 8), Text('分享')],
              ),
            ),
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [Icon(Icons.info), SizedBox(width: 8), Text('文件信息')],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建页面工具栏
  Widget _buildPageToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          // 文件路径面包屑
          Expanded(child: _buildBreadcrumb()),

          // 加载指示器
          if (_isLoading) ...[
            const SizedBox(width: 16),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建面包屑导航
  Widget _buildBreadcrumb() {
    final vfsPath = VfsProtocol.parsePath(widget.vfsPath);
    if (vfsPath == null) {
      return Text(
        widget.vfsPath,
        style: Theme.of(context).textTheme.bodySmall,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Row(
      children: [
        Icon(
          Icons.storage,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 4),
        Text(vfsPath.database, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.folder,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 4),
        Text(vfsPath.collection, style: Theme.of(context).textTheme.bodySmall),
        if (vfsPath.segments.isNotEmpty) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              vfsPath.segments.join('/'),
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  /// 构建自定义工具栏按钮
  List<Widget> _buildCustomToolbarActions() {
    return [
      // 返回按钮
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
        tooltip: '返回',
      ),

      const SizedBox(width: 8),

      // 在窗口中打开
      IconButton(
        icon: const Icon(Icons.open_in_new),
        onPressed: _openInWindow,
        tooltip: '在窗口中打开',
      ),
    ];
  }

  /// 获取页面标题
  String _getPageTitle() {
    if (widget.fileInfo != null) {
      return widget.fileInfo!.name;
    }
    return widget.vfsPath.split('/').last;
  }

  /// 处理菜单动作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'window':
        _openInWindow();
        break;
      case 'share':
        _shareFile();
        break;
      case 'info':
        _showFileInfo();
        break;
    }
  }

  /// 在窗口中打开
  void _openInWindow() {
    // 导入窗口组件
    // VfsMarkdownViewerWindow.show(
    //   context,
    //   vfsPath: widget.vfsPath,
    //   fileInfo: widget.fileInfo,
    // );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('在窗口中打开功能需要导入窗口组件')));
  }

  /// 分享文件
  void _shareFile() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('分享功能开发中...')));
  }

  /// 显示文件信息
  void _showFileInfo() {
    if (widget.fileInfo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('文件信息不可用')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('文件信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('文件名', widget.fileInfo!.name),
            _buildInfoRow('大小', _formatFileSize(widget.fileInfo!.size)),
            _buildInfoRow('创建时间', _formatDateTime(widget.fileInfo!.createdAt)),
            _buildInfoRow('修改时间', _formatDateTime(widget.fileInfo!.modifiedAt)),
            _buildInfoRow('类型', widget.fileInfo!.isDirectory ? '目录' : '文件'),
            _buildInfoRow('路径', widget.vfsPath),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
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
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  /// 切换全屏模式
  void _toggleFullscreen() {
    // 这里可以实现全屏逻辑
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('全屏模式开发中...')));
  }

  /// 处理错误
  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// 为MarkdownRendererConfig添加copyWith方法的扩展
extension MarkdownRendererConfigExtension on MarkdownRendererConfig {
  MarkdownRendererConfig copyWith({
    bool? showToolbar,
    bool? showStatusBar,
    bool? allowEdit,
    List<Widget>? customToolbarActions,
    Widget? customStatusBar,
    BoxDecoration? toolbarDecoration,
    BoxDecoration? statusBarDecoration,
  }) {
    return MarkdownRendererConfig(
      showToolbar: showToolbar ?? this.showToolbar,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      allowEdit: allowEdit ?? this.allowEdit,
      customToolbarActions: customToolbarActions ?? this.customToolbarActions,
      customStatusBar: customStatusBar ?? this.customStatusBar,
      toolbarDecoration: toolbarDecoration ?? this.toolbarDecoration,
      statusBarDecoration: statusBarDecoration ?? this.statusBarDecoration,
    );
  }
}
