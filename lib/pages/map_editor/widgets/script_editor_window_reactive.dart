import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/languages/dart.dart';
import '../../../data/new_reactive_script_manager.dart';
import '../../../models/script_data.dart';

/// 响应式脚本编辑器窗口
/// 基于新的异步响应式脚本管理器的脚本编辑器
class ReactiveScriptEditorWindow extends StatefulWidget {
  final ScriptData script;
  final NewReactiveScriptManager scriptManager;
  final VoidCallback? onClose;

  const ReactiveScriptEditorWindow({
    super.key,
    required this.script,
    required this.scriptManager,
    this.onClose,
  });

  @override
  State<ReactiveScriptEditorWindow> createState() =>
      _ReactiveScriptEditorWindowState();
}

class _ReactiveScriptEditorWindowState
    extends State<ReactiveScriptEditorWindow> {
  late CodeController _codeController;
  late ScrollController _scrollController;
  bool _isDarkTheme = true;
  bool _hasUnsavedChanges = false;
  String _originalContent = ''; // 保存原始内容用于比较
  @override
  void initState() {
    super.initState();
    _originalContent = widget.script.content; // 保存原始内容
    _scrollController = ScrollController();
    _codeController = CodeController(
      text: widget.script.content,
      language: dart,
    );

    // 延迟添加监听器，避免初始化时触发
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeController.addListener(_onTextChanged);
    });
  }

  /// 文本变化监听器
  void _onTextChanged() {
    final currentContent = _codeController.text;
    final hasChanges = currentContent != _originalContent;

    if (_hasUnsavedChanges != hasChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _codeController.removeListener(_onTextChanged);
    _codeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 保存脚本
  Future<void> _saveScript() async {
    try {
      await widget.scriptManager.updateScriptContent(
        widget.script.id,
        _codeController.text,
      );

      // 保存成功后更新原始内容
      _originalContent = _codeController.text;
      setState(() {
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('脚本已保存'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 跳转到文档末尾
  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 跳转到文档开头
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 切换主题
  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  /// 处理窗口关闭
  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    if (!mounted) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('未保存的更改'),
        content: const Text('您有未保存的更改，确定要关闭吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('放弃更改'),
          ),
          FilledButton(
            onPressed: () async {
              await _saveScript();
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('保存并关闭'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop && mounted) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            // 通知父组件处理关闭逻辑
            widget.onClose?.call();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 禁用默认的后退按钮
          title: Row(
            children: [
              Text('编辑脚本: ${widget.script.name}'),
              if (_hasUnsavedChanges) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '未保存',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(_isDarkTheme ? Icons.light_mode : Icons.dark_mode),
              tooltip: _isDarkTheme ? '切换到亮色主题' : '切换到暗色主题',
            ),
            IconButton(
              onPressed: _hasUnsavedChanges ? _saveScript : null,
              icon: const Icon(Icons.save),
              tooltip: '保存脚本',
            ),
            IconButton(
              onPressed: () async {
                final shouldClose = await _onWillPop();
                if (shouldClose && mounted) {
                  // 只调用 onClose 回调，由父组件处理导航
                  widget.onClose?.call();
                }
              },
              icon: const Icon(Icons.close),
              tooltip: '关闭编辑器',
            ),
          ],
        ),
        body: Column(
          children: [
            // 工具栏
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Chip(
                    label: Text(widget.script.type.name),
                    backgroundColor: _getTypeColor(widget.script.type),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  if (widget.script.description.isNotEmpty)
                    Expanded(
                      child: Text(
                        widget.script.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Spacer(),
                  // 滚动控制按钮
                  IconButton(
                    onPressed: _scrollToTop,
                    icon: const Icon(Icons.vertical_align_top),
                    tooltip: '跳转到顶部',
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: _scrollToEnd,
                    icon: const Icon(Icons.vertical_align_bottom),
                    tooltip: '跳转到底部',
                    iconSize: 20,
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: widget.script.isEnabled
                        ? () {
                            // 运行脚本 - 使用新的响应式脚本管理器
                            widget.scriptManager.executeScript(
                              widget.script.id,
                            );
                          }
                        : null,
                    child: ListenableBuilder(
                      listenable: widget.scriptManager,
                      builder: (context, child) {
                        final status = widget.scriptManager.getScriptStatus(
                          widget.script.id,
                        );
                        final isRunning = status == ScriptStatus.running;

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isRunning) ...[
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('执行中'),
                            ] else ...[
                              const Icon(Icons.play_arrow, size: 16),
                              const SizedBox(width: 4),
                              const Text('运行'),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ), // 代码编辑器
            Expanded(
              child: Container(
                // 设置容器背景色与编辑器一致
                color: _isDarkTheme ? const Color(0xFF272822) : Colors.white,
                child: CodeTheme(
                  data: _isDarkTheme
                      ? CodeThemeData(styles: monokaiSublimeTheme)
                      : CodeThemeData(styles: githubTheme),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 计算需要的底部填充，使最后一行能够滚动到顶部
                      // 使用80%的高度作为底部填充，确保最后一行能滚动到可视区域顶部
                      final bottomPadding = constraints.maxHeight * 0.8;

                      return SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: bottomPadding),                          child: CodeField(
                            controller: _codeController,
                            textStyle: const TextStyle(
                              fontFamily: 'Consolas', // 使用更好的等宽字体
                              fontSize: 14,
                              height: 1.5, // 增加行高以改善可读性
                            ),
                            background: _isDarkTheme
                                ? const Color(0xFF272822)
                                : Colors.white,
                            gutterStyle: GutterStyle(
                              showLineNumbers: true,
                              showErrors: true,
                              showFoldingHandles: false,
                              margin: 8,
                              width: 80, // 增加行号区域宽度以支持更多位数
                              background: _isDarkTheme
                                  ? const Color(0xFF272822) // 与编辑器背景色保持一致
                                  : Colors.white,
                              textStyle: TextStyle(
                                fontFamily: 'Consolas', // 与编辑器使用相同字体
                                fontSize: 14, // 与编辑器使用相同字体大小
                                height: 1.5, // 与编辑器使用相同行高
                                color: _isDarkTheme
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                            wrap: false, // 禁用自动换行以支持水平滚动
                            expands: false, // 让内容决定高度
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取脚本类型对应的颜色
  Color _getTypeColor(ScriptType type) {
    switch (type) {
      case ScriptType.automation:
        return Colors.blue.withOpacity(0.2);
      case ScriptType.animation:
        return Colors.green.withOpacity(0.2);
      case ScriptType.filter:
        return Colors.orange.withOpacity(0.2);
      case ScriptType.statistics:
        return Colors.purple.withOpacity(0.2);
    }
  }
}
