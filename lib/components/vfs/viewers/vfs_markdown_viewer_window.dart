import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../components/common/floating_window.dart';
import '../../../services/virtual_file_system/vfs_service_provider.dart';
import '../../../services/vfs/vfs_file_opener_service.dart';
import '../../../services/virtual_file_system/vfs_protocol.dart';
import 'vfs_text_viewer_window.dart';

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
  final VfsServiceProvider _vfsService = VfsServiceProvider();
  final TocController _tocController = TocController();

  bool _isLoading = true;
  String? _errorMessage;
  String _markdownContent = '';
  VfsFileInfo? _fileInfo;

  // 显示配置
  bool _isDarkTheme = false;
  bool _showToc = false;
  double _contentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadMarkdownFile();
  }  @override
  void dispose() {
    _tocController.dispose();
    super.dispose();
  }

  /// 加载Markdown文件
  Future<void> _loadMarkdownFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fileContent = await _vfsService.vfs.readFile(widget.vfsPath);
      if (fileContent != null) {
        String textContent;
        try {
          textContent = utf8.decode(fileContent.data);
        } catch (e) {
          // 如果UTF-8解码失败，尝试使用Latin-1
          textContent = latin1.decode(fileContent.data);
        }

        setState(() {
          _markdownContent = textContent;
          _fileInfo = widget.fileInfo;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '无法读取Markdown文件';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '加载Markdown文件失败: $e';
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
        // 内容区域
        Expanded(child: _buildContent()),
        // 状态栏
        _buildStatusBar(),
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
          // 目录切换
          IconButton(
            onPressed: _toggleToc,
            icon: Icon(_showToc ? Icons.menu_open : Icons.menu),
            tooltip: _showToc ? '隐藏目录' : '显示目录',
          ),

          const SizedBox(width: 16),

          // 主题切换
          IconButton(
            onPressed: _toggleTheme,
            icon: Icon(_isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            tooltip: _isDarkTheme ? '浅色主题' : '深色主题',
          ),

          const SizedBox(width: 16),

          // 缩放控制
          IconButton(
            onPressed: _canZoomOut() ? _zoomOut : null,
            icon: const Icon(Icons.zoom_out),
            tooltip: '缩小',
          ),
          Text(
            '${(_contentScale * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          IconButton(
            onPressed: _canZoomIn() ? _zoomIn : null,
            icon: const Icon(Icons.zoom_in),
            tooltip: '放大',
          ),

          const SizedBox(width: 16),

          // 重置缩放
          IconButton(
            onPressed: _resetZoom,
            icon: const Icon(Icons.crop_free),
            tooltip: '重置缩放',
          ),

          const Spacer(),

          // 使用文本编辑器打开
          IconButton(
            onPressed: _openWithTextEditor,
            icon: const Icon(Icons.edit),
            tooltip: '使用文本编辑器打开',
          ),

          // 复制按钮
          IconButton(
            onPressed: _copyContent,
            icon: const Icon(Icons.copy),
            tooltip: '复制Markdown内容',
          ),

          // 刷新按钮
          IconButton(
            onPressed: _loadMarkdownFile,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载Markdown文件中...'),
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
            ElevatedButton(
              onPressed: _loadMarkdownFile,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_markdownContent.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Markdown文件为空'),
          ],
        ),
      );
    }

    return Row(
      children: [
        // 目录面板
        if (_showToc) ...[
          SizedBox(width: 250, child: _buildTocPanel()),
          const VerticalDivider(),
        ],

        // 主内容区域
        Expanded(child: _buildMarkdownContent()),
      ],
    );
  }

  /// 构建目录面板
  Widget _buildTocPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '目录',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(child: TocWidget(controller: _tocController)),
        ],
      ),
    );
  }  /// 构建Markdown内容
  Widget _buildMarkdownContent() {
    final config = _buildMarkdownConfig();

    return Container(
      color: _isDarkTheme ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
      padding: const EdgeInsets.all(24),
      child: MarkdownWidget(
        data: _markdownContent,
        config: config,
        tocController: _tocController,
      ),
    );
  }

  /// 构建Markdown配置
  MarkdownConfig _buildMarkdownConfig() {
    final isDark = _isDarkTheme;
    final baseConfig = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;    return baseConfig.copy(
      configs: [
        // 段落文本配置 - 确保在黑暗模式下文本可见
        PConfig(
          textStyle: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            height: 1.6,
          ),
        ),

        // 标题配置
        H1Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        H2Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        H3Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        H4Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        H5Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        H6Config(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),

        // 链接配置 - 支持VFS协议链接
        LinkConfig(
          style: TextStyle(
            color: isDark ? Colors.lightBlueAccent : Colors.blue,
            decoration: TextDecoration.underline,
          ),
          onTap: _onLinkTap,
        ),

        // 图片配置 - 支持VFS协议图片
        ImgConfig(
          builder: (url, attributes) => _buildImage(url, attributes),
          errorBuilder: (url, alt, error) =>
              _buildImageError(url, error.toString()),
        ),

        // 代码块配置
        PreConfig(
          theme: isDark
              ? const {
                  'root': TextStyle(
                    backgroundColor: Color(0xFF2D2D2D),
                    color: Color(0xFFE6E6E6),
                  ),
                }
              : const {
                  'root': TextStyle(
                    backgroundColor: Color(0xFFF8F8F8),
                    color: Color(0xFF333333),
                  ),
                },
        ),

        // 行内代码配置
        CodeConfig(
          style: TextStyle(
            color: isDark ? const Color(0xFFE6E6E6) : const Color(0xFF333333),
            backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F8F8),
            fontFamily: 'Courier',
            fontSize: 14,
          ),
        ),        // 引用块配置
        BlockquoteConfig(
          textColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          sideColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),

        // 列表配置 - 支持自定义标记颜色
        ListConfig(
          marginLeft: 32.0,
          marginBottom: 4.0,
          marker: (isOrdered, depth, index) {
            final color = isDark ? Colors.white : Colors.black87;
            if (isOrdered) {
              // 有序列表数字标记
              return Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 1),
                child: SelectionContainer.disabled(
                  child: Text(
                    '${index + 1}.',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
              );
            } else {
              // 无序列表点标记
              final parentStyleHeight = 16.0 * 1.6;
              return Padding(
                padding: EdgeInsets.only(top: (parentStyleHeight / 2) - 1.5),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: _getUnorderedListDecoration(depth, color),
                  ),
                ),
              );
            }
          },
        ),

        // 复选框配置 - 支持自定义颜色
        CheckBoxConfig(
          builder: (checked) => Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),

        // // HTML支持扩展
        // HtmlExtension(onLinkTap: _onLinkTap, isDarkTheme: isDark),

        // // LaTeX支持扩展
        // LatexExtension(isDarkTheme: isDark),

        // // 任务列表扩展
        // TaskListExtension(isDarkTheme: isDark),
      ],
    );
  }  /// 处理链接点击
  void _onLinkTap(String url) {
    if (url.startsWith('indexeddb://')) {
      // VFS协议链接，使用文件打开服务
      _openVfsLink(url);
    } else if (url.startsWith('http://') || url.startsWith('https://')) {
      // 外部链接
      _openExternalLink(url);
    } else if (url.startsWith('#')) {
      // 锚点链接，跳转到对应位置
      _handleAnchorLink(url);
    } else {
      // 相对路径链接，解析为VFS路径
      _openRelativeLink(url);
    }
  }

  /// 打开VFS链接
  Future<void> _openVfsLink(String vfsUrl) async {
    try {
      await VfsFileOpenerService.openFile(context, vfsUrl);
    } catch (e) {
      _showErrorSnackBar('打开VFS链接失败: $e');
    }
  }

  /// 打开外部链接
  Future<void> _openExternalLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar('无法打开链接: $url');
      }
    } catch (e) {
      _showErrorSnackBar('打开链接失败: $e');
    }
  }
  /// 处理锚点链接
  void _handleAnchorLink(String anchor) {
    try {
      // 移除 # 前缀并进行URL解码
      String anchorId = Uri.decodeComponent(anchor.substring(1));
      
      // 简单的文本搜索滚动
      _scrollToText(anchorId);
      
    } catch (e) {
      _showErrorSnackBar('跳转到锚点失败: $e');
    }
  }  /// 使用TOC控制器跳转到锚点
  void _scrollToText(String searchText) {
    try {
      // 尝试使用TOC控制器直接跳转到锚点
      // 首先尝试完整匹配
      if (_tocController.tocList.isNotEmpty) {        // 查找匹配的TOC项
        for (final toc in _tocController.tocList) {
          // 从HeadingNode获取标题文本
          final headingSpan = toc.node.childrenSpan;
          final headingText = headingSpan.toPlainText().replaceAll(RegExp(r'[#\s]+'), '');
          
          // 尝试匹配标题文本
          if (headingText.toLowerCase().contains(searchText.toLowerCase())) {
            _tocController.jumpToIndex(toc.widgetIndex);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已跳转到: $headingText'),
                duration: const Duration(seconds: 1),
              ),
            );
            return;
          }
        }
      }
      
      // 如果TOC中没找到，显示未找到提示
      _showErrorSnackBar('未找到锚点: $searchText');
    } catch (e) {
      _showErrorSnackBar('锚点跳转失败: $e');
    }
  }
  /// 构建图片组件 - 支持VFS协议
  Widget _buildImage(String url, Map<String, String> attributes) {
    if (url.startsWith('indexeddb://')) {
      return _buildVfsImage(url, attributes);
    } else if (url.startsWith('http://') || url.startsWith('https://')) {
      return _buildNetworkImage(url, attributes);
    } else {
      // 处理相对路径，解析为VFS绝对路径
      final currentDir = _getCurrentDirectory();
      final absolutePath = _resolveRelativePath(currentDir, url);
      return _buildVfsImage(absolutePath, attributes);
    }
  }

  /// 构建VFS图片
  Widget _buildVfsImage(String vfsUrl, Map<String, String> attributes) {
    return FutureBuilder<Uint8List?>(
      future: _loadVfsImage(vfsUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildImageError(vfsUrl, snapshot.error?.toString() ?? '加载失败');
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageError(vfsUrl, error.toString());
              },
            ),
          ),
        );
      },
    );
  }

  /// 构建网络图片
  Widget _buildNetworkImage(String url, Map<String, String> attributes) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError(url, error.toString());
          },
        ),
      ),
    );
  }

  /// 构建图片错误显示
  Widget _buildImageError(String url, String? error) {
    return Container(
      height: 120,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.red.shade400, size: 32),
          const SizedBox(height: 8),
          Text(
            '图片加载失败',
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(color: Colors.red.shade500, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// 加载VFS图片
  Future<Uint8List?> _loadVfsImage(String vfsUrl) async {
    try {
      final fileContent = await _vfsService.vfs.readFile(vfsUrl);
      return fileContent?.data;
    } catch (e) {
      print('加载VFS图片失败: $e');
      return null;
    }
  }

  /// 构建状态栏
  Widget _buildStatusBar() {
    final wordCount = _markdownContent.split(RegExp(r'\s+')).length;
    final charCount = _markdownContent.length;
    final lineCount = _markdownContent.split('\n').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Text('行数: $lineCount', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 16),
          Text('字数: $wordCount', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 16),
          Text('字符数: $charCount', style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          if (_fileInfo != null) ...[
            Text(
              '文件大小: ${_formatFileSize(_fileInfo!.size)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 16),
          ],
          Text(
            '缩放: ${(_contentScale * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
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

  /// 切换目录显示
  void _toggleToc() {
    setState(() {
      _showToc = !_showToc;
    });
  }

  /// 切换主题
  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  /// 缩放控制
  bool _canZoomIn() => _contentScale < 3.0;
  bool _canZoomOut() => _contentScale > 0.5;

  void _zoomIn() {
    if (_canZoomIn()) {
      setState(() {
        _contentScale = (_contentScale * 1.2).clamp(0.5, 3.0);
      });
    }
  }

  void _zoomOut() {
    if (_canZoomOut()) {
      setState(() {
        _contentScale = (_contentScale / 1.2).clamp(0.5, 3.0);
      });
    }
  }

  void _resetZoom() {
    setState(() {
      _contentScale = 1.0;
    });
  }

  /// 复制内容
  void _copyContent() {
    Clipboard.setData(ClipboardData(text: _markdownContent));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 2)),
    );
  }
  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 打开相对路径链接
  Future<void> _openRelativeLink(String relativePath) async {
    try {
      // 获取当前文件的目录路径
      final currentDir = _getCurrentDirectory();
      
      // 解析相对路径为绝对VFS路径
      final absolutePath = _resolveRelativePath(currentDir, relativePath);
      
      // 使用VFS文件打开服务打开文件
      await VfsFileOpenerService.openFile(context, absolutePath);
    } catch (e) {
      _showErrorSnackBar('打开相对路径链接失败: $e');
    }
  }
  /// 获取当前Markdown文件的目录路径
  String _getCurrentDirectory() {
    // 解析VFS路径
    final vfsPath = VfsProtocol.parsePath(widget.vfsPath);
    if (vfsPath == null || vfsPath.segments.isEmpty) {
      return '';
    }
    
    // 获取文件所在目录的路径（移除文件名）
    if (vfsPath.segments.length > 1) {
      final dirSegments = vfsPath.segments.sublist(0, vfsPath.segments.length - 1);
      return dirSegments.join('/');
    }
    
    return '';
  }
  /// 解析相对路径为绝对路径
  String _resolveRelativePath(String currentDir, String relativePath) {
    // 如果是绝对路径，直接返回
    if (relativePath.startsWith('/') || relativePath.startsWith('indexeddb://')) {
      return relativePath;
    }

    // 从当前VFS路径中提取数据库和集合信息
    final currentVfsPath = VfsProtocol.parsePath(widget.vfsPath);
    if (currentVfsPath == null) {
      return relativePath; // 如果解析失败，返回原路径
    }

    // 处理相对路径
    List<String> currentParts = currentDir.isEmpty ? [] : currentDir.split('/');
    List<String> relativeParts = relativePath.split('/');

    // 处理 ".." 和 "." 路径段
    for (String part in relativeParts) {
      if (part == '..') {
        if (currentParts.isNotEmpty) {
          currentParts.removeLast();
        }
      } else if (part != '.' && part.isNotEmpty) {
        currentParts.add(part);
      }
    }

    // 构建最终路径
    final finalRelativePath = currentParts.join('/');
    
    // 使用VfsProtocol构建完整的VFS路径
    return VfsProtocol.buildPath(
      currentVfsPath.database,
      currentVfsPath.collection,
      finalRelativePath,
    );
  }

  /// 使用文本编辑器打开当前Markdown文件
  Future<void> _openWithTextEditor() async {
    try {
      await VfsTextViewerWindow.show(
        context,
        vfsPath: widget.vfsPath,
        fileInfo: _fileInfo,
        config: VfsFileOpenConfig.forText,
      );
    } catch (e) {
      _showErrorSnackBar('打开文本编辑器失败: $e');
    }
  }

  /// 获取无序列表标记装饰
  BoxDecoration _getUnorderedListDecoration(int depth, Color color) {
    switch (depth % 3) {
      case 0:
        // 第一层：实心圆点
        return BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        );
      case 1:
        // 第二层：空心圆点
        return BoxDecoration(
          border: Border.all(color: color, width: 1),
          shape: BoxShape.circle,
        );
      case 2:
      default:
        // 第三层及以上：实心方块
        return BoxDecoration(color: color);
    }
  }
}