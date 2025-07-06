import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/sql.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:highlight/languages/markdown.dart';
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
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
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

  bool _isLoading = true;
  String? _errorMessage;
  VfsFileInfo? _fileInfo;

  // 代码编辑器相关
  late CodeController _codeController;
  bool _isReadOnly = true;
  bool? _isDarkTheme; // 使用null表示自动模式

  @override
  void initState() {
    super.initState();
    _codeController = CodeController();
    _loadTextFile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 如果是自动模式，根据Material主题更新
    if (_isDarkTheme == null) {
      setState(() {
        // 自动模式保持null，在使用时动态获取
      });
    }
  }

  /// 获取当前主题模式（自动模式时使用Material主题，手动模式时使用设定值）
  bool get _effectiveIsDarkTheme {
    return _isDarkTheme ?? Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void dispose() {
    _codeController.dispose();
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

        // 设置代码编辑器内容和语言
        _codeController.text = textContent;
        _setLanguageMode();

        setState(() {
          _fileInfo = widget.fileInfo;
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

  /// 根据文件扩展名设置语言模式
  void _setLanguageMode() {
    final extension = widget.vfsPath.split('.').last.toLowerCase();

    switch (extension) {
      case 'dart':
        _codeController.language = dart;
        break;
      case 'json':
        _codeController.language = json;
        break;
      case 'xml':
      case 'html':
        _codeController.language = xml;
        break;
      case 'js':
      case 'ts':
        _codeController.language = javascript;
        break;
      case 'py':
        _codeController.language = python;
        break;
      case 'sql':
        _codeController.language = sql;
        break;
      case 'yaml':
      case 'yml':
        _codeController.language = yaml;
        break;
      case 'md':
        _codeController.language = markdown;
        break;
      default:
        // 使用纯文本模式
        _codeController.language = null;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 工具栏
        _buildToolbar(),
        // 代码编辑器
        Expanded(child: _buildCodeEditor()),
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
          // 编辑模式切换
          IconButton(
            onPressed: _toggleReadOnlyMode,
            icon: Icon(_isReadOnly ? Icons.edit_off : Icons.edit),
            tooltip: _isReadOnly ? '启用编辑' : '只读模式',
          ),

          // 保存按钮（仅在编辑模式下显示）
          if (!_isReadOnly) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _saveFile,
              icon: const Icon(Icons.save),
              tooltip: '保存文件',
            ),
          ],

          const SizedBox(width: 16),

          // 主题切换
          IconButton(
            onPressed: _toggleTheme,
            icon: Icon(
              _effectiveIsDarkTheme ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: _isDarkTheme == null
                ? (_effectiveIsDarkTheme ? '自动主题(当前深色)' : '自动主题(当前浅色)')
                : (_effectiveIsDarkTheme ? '浅色主题' : '深色主题'),
          ),

          const SizedBox(width: 16),

          // JSON格式化（仅JSON文件）
          if (_isJsonFile()) ...[
            IconButton(
              onPressed: _formatJson,
              icon: const Icon(Icons.code),
              tooltip: '格式化JSON',
            ),
            const SizedBox(width: 8),
          ],

          const Spacer(),

          // 复制按钮
          IconButton(
            onPressed: _copyContent,
            icon: const Icon(Icons.copy),
            tooltip: '复制所有内容',
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

  /// 构建代码编辑器
  Widget _buildCodeEditor() {
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
            ElevatedButton(onPressed: _loadTextFile, child: const Text('重试')),
          ],
        ),
      );
    }
    return Container(
      color: _effectiveIsDarkTheme
          ? const Color(0xFF2B2B2B)
          : const Color(0xFFFAFAFA),
      child: CodeTheme(
        data: _effectiveIsDarkTheme
            ? CodeThemeData(styles: monokaiSublimeTheme)
            : CodeThemeData(styles: githubTheme),
        child: SingleChildScrollView(
          child: CodeField(
            controller: _codeController,
            readOnly: _isReadOnly,
            textStyle: TextStyle(
              fontFamily: 'Courier New',
              fontSize: 14,
              height: 1.4,
              color: _effectiveIsDarkTheme ? Colors.white : Colors.black,
            ),
            gutterStyle: GutterStyle(
              showLineNumbers: true,
              showErrors: true,
              showFoldingHandles: true,
              margin: 8,
              width: 60,
              background: _effectiveIsDarkTheme
                  ? const Color(0xFF3C3C3C)
                  : const Color(0xFFF5F5F5),
              textStyle: TextStyle(
                color: _effectiveIsDarkTheme ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
            wrap: true,
            lineNumberStyle: LineNumberStyle(
              width: 60,
              margin: 8,
              textAlign: TextAlign.right,
              background: _effectiveIsDarkTheme
                  ? const Color(0xFF3C3C3C)
                  : const Color(0xFFF5F5F5),
              textStyle: TextStyle(
                color: _effectiveIsDarkTheme ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
            background: _effectiveIsDarkTheme
                ? const Color(0xFF2B2B2B)
                : const Color(0xFFFAFAFA),
            decoration: BoxDecoration(
              color: _effectiveIsDarkTheme
                  ? const Color(0xFF2B2B2B)
                  : const Color(0xFFFAFAFA),
              border: Border.all(
                color: _effectiveIsDarkTheme
                    ? Colors.grey.shade700.withOpacity(0.3)
                    : Theme.of(context).dividerColor.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建状态栏
  Widget _buildStatusBar() {
    final lineCount = _codeController.text.split('\n').length;
    final charCount = _codeController.text.length;

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
          Text('字符数: $charCount', style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          if (_fileInfo != null) ...[
            Text(
              '文件大小: ${_formatFileSize(_fileInfo!.size)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(width: 16),
          Text(
            _isReadOnly ? '只读模式' : '编辑模式',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 切换只读模式
  void _toggleReadOnlyMode() {
    setState(() {
      _isReadOnly = !_isReadOnly;
    });
  }

  /// 切换主题
  void _toggleTheme() {
    setState(() {
      if (_isDarkTheme == null) {
        // 从自动模式切换到手动模式，设置为与当前自动主题相反的状态
        _isDarkTheme = !_effectiveIsDarkTheme;
      } else {
        // 在手动模式下切换，或者切换回自动模式
        _isDarkTheme = _isDarkTheme! ? false : null;
      }
    });
  }

  /// 判断是否是JSON文件
  bool _isJsonFile() {
    final extension = widget.vfsPath.split('.').last.toLowerCase();
    return extension == 'json';
  }

  /// 格式化JSON
  void _formatJson() {
    if (!_isJsonFile()) return;

    try {
      final jsonObject = jsonDecode(_codeController.text);
      final formattedJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(jsonObject);
      _codeController.text = formattedJson;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSON格式化完成'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JSON格式化失败: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 复制所有内容
  void _copyContent() {
    Clipboard.setData(ClipboardData(text: _codeController.text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 2)),
    );
  }

  /// 保存文件
  Future<void> _saveFile() async {
    try {
      // 将文本内容转换为Uint8List
      final textBytes = utf8.encode(_codeController.text);

      // 直接使用VFS路径保存文件
      await _vfsService.vfs.writeBinaryFile(
        widget.vfsPath,
        textBytes,
        mimeType: 'text/plain; charset=utf-8',
      );

      // 更新文件信息
      setState(() {
        if (_fileInfo != null) {
          final now = DateTime.now();
          _fileInfo = VfsFileInfo(
            path: _fileInfo!.path,
            name: _fileInfo!.name,
            isDirectory: _fileInfo!.isDirectory,
            size: textBytes.length,
            createdAt: _fileInfo!.createdAt,
            modifiedAt: now,
            mimeType: _fileInfo!.mimeType,
            metadata: _fileInfo!.metadata,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('文件保存成功'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存文件失败: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }
}
