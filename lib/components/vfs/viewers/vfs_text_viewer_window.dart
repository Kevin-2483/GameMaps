import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/common/floating_window.dart';
import '../../../services/virtual_file_system/vfs_service_provider.dart';
import '../../../services/vfs/vfs_file_opener_service.dart';
import '../../../services/virtual_file_system/vfs_protocol.dart';

/// VFS文本查看器窗口
class VfsTextViewerWindow extends StatefulWidget {
  /// VFS文件路径
  final String vfsPath;
  
  /// 文件信息（可选）
  final VfsFileInfo? fileInfo;
  
  /// 窗口配置
  final VfsFileOpenConfig config;
  
  /// 关闭回调
  final VoidCallback? onClose;

  const VfsTextViewerWindow({
    super.key,
    required this.vfsPath,
    this.fileInfo,
    required this.config,
    this.onClose,
  });

  /// 显示文本查看器窗口
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
      icon: Icons.text_snippet,
      widthRatio: finalConfig.widthRatio,
      heightRatio: finalConfig.heightRatio,
      minSize: finalConfig.minSize ?? const Size(600, 400),
      maxSize: finalConfig.maxSize,
      draggable: finalConfig.draggable,
      resizable: finalConfig.resizable,
      barrierDismissible: finalConfig.barrierDismissible,
      child: VfsTextViewerWindow(
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
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  State<VfsTextViewerWindow> createState() => _VfsTextViewerWindowState();
}

class _VfsTextViewerWindowState extends State<VfsTextViewerWindow> {
  final VfsServiceProvider _vfsService = VfsServiceProvider();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  String? _errorMessage;
  String? _textContent;
  VfsFileInfo? _fileInfo;
  
  // 文本查看器状态
  double _fontSize = 14.0;
  bool _wordWrap = true;
  TextSelection? _currentSelection;
  int _lineCount = 0;
  bool _isJson = false;
  bool _jsonFormatted = false;

  @override
  void initState() {
    super.initState();
    _loadTextFile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载文本文件
  Future<void> _loadTextFile() async {
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
        
        final extension = widget.vfsPath.split('.').last.toLowerCase();
        final isJsonFile = extension == 'json';
        
        setState(() {
          _textContent = textContent;
          _fileInfo = widget.fileInfo;
          _lineCount = _countLines(textContent);
          _isJson = isJsonFile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '无法读取文本文件';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '加载文本文件失败: $e';
        _isLoading = false;
      });
    }
  }

  /// 计算行数
  int _countLines(String text) {
    return text.split('\n').length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 工具栏
        _buildToolbar(),
        // 文本查看区域
        Expanded(
          child: _buildTextViewer(),
        ),
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
          // 字体大小控制
          IconButton(
            onPressed: _decreaseFontSize,
            icon: const Icon(Icons.text_decrease),
            tooltip: '减小字体',
          ),
          Text(
            '${_fontSize.toInt()}px',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          IconButton(
            onPressed: _increaseFontSize,
            icon: const Icon(Icons.text_increase),
            tooltip: '增大字体',
          ),
          
          const SizedBox(width: 16),
          
          // 自动换行
          IconButton(
            onPressed: _toggleWordWrap,
            icon: Icon(_wordWrap ? Icons.wrap_text : Icons.text_fields),
            tooltip: _wordWrap ? '关闭自动换行' : '开启自动换行',
          ),
          
          // JSON格式化（仅JSON文件）
          if (_isJson) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _toggleJsonFormat,
              icon: Icon(_jsonFormatted ? Icons.code_off : Icons.code),
              tooltip: _jsonFormatted ? '显示原始格式' : '格式化JSON',
            ),
          ],
          
          const Spacer(),
          
          // 复制按钮
          if (_currentSelection != null && !_currentSelection!.isCollapsed) ...[
            IconButton(
              onPressed: _copySelection,
              icon: const Icon(Icons.copy),
              tooltip: '复制选中文本',
            ),
            const SizedBox(width: 8),
          ],
          
          // 全选按钮
          IconButton(
            onPressed: _selectAll,
            icon: const Icon(Icons.select_all),
            tooltip: '全选',
          ),
          
          // 刷新按钮
          IconButton(
            onPressed: _loadTextFile,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
    );
  }

  /// 构建文本查看器
  Widget _buildTextViewer() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载文本文件中...'),
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
              onPressed: _loadTextFile,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_textContent == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.text_snippet_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('无法显示文本内容'),
          ],
        ),
      );
    }

    String displayText = _textContent!;
    if (_isJson && _jsonFormatted) {
      try {
        final jsonObject = json.decode(_textContent!);
        displayText = const JsonEncoder.withIndent('  ').convert(jsonObject);
      } catch (e) {
        // 如果格式化失败，显示原始内容
        displayText = _textContent!;
      }
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            displayText,
            style: TextStyle(
              fontSize: _fontSize,
              fontFamily: 'Courier',
              height: 1.4,
            ),
            onSelectionChanged: (selection, cause) {
              setState(() {
                _currentSelection = selection;
              });
            },
            scrollPhysics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }

  /// 构建状态栏
  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            '行数: $_lineCount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          if (_textContent != null)
            Text(
              '字符数: ${_textContent!.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const Spacer(),
          if (_fileInfo != null) ...[
            Text(
              '文件大小: ${_formatFileSize(_fileInfo!.size)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  /// 减小字体
  void _decreaseFontSize() {
    setState(() {
      _fontSize = (_fontSize - 1).clamp(8.0, 32.0);
    });
  }

  /// 增大字体
  void _increaseFontSize() {
    setState(() {
      _fontSize = (_fontSize + 1).clamp(8.0, 32.0);
    });
  }

  /// 切换自动换行
  void _toggleWordWrap() {
    setState(() {
      _wordWrap = !_wordWrap;
    });
  }

  /// 切换JSON格式化
  void _toggleJsonFormat() {
    setState(() {
      _jsonFormatted = !_jsonFormatted;
    });
  }

  /// 复制选中文本
  void _copySelection() {
    if (_currentSelection != null && !_currentSelection!.isCollapsed && _textContent != null) {
      final selectedText = _textContent!.substring(
        _currentSelection!.start,
        _currentSelection!.end,
      );
      Clipboard.setData(ClipboardData(text: selectedText));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已复制到剪贴板'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 全选
  void _selectAll() {
    setState(() {
      if (_textContent != null) {
        _currentSelection = TextSelection(
          baseOffset: 0,
          extentOffset: _textContent!.length,
        );
      }
    });
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }
}
