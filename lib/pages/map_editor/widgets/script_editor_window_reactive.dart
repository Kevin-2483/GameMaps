import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/languages/dart.dart';
import '../../../data/reactive_script_manager.dart';
import '../../../models/script_data.dart';

/// 响应式脚本编辑器窗口
/// 基于响应式脚本管理器的脚本编辑器
class ReactiveScriptEditorWindow extends StatefulWidget {
  final ScriptData script;
  final ReactiveScriptManager scriptManager;
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
  bool _isDarkTheme = true;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.script.content,
      language: dart,
    );

    _codeController.addListener(() {
      if (!_hasUnsavedChanges) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 保存脚本
  Future<void> _saveScript() async {
    try {
      await widget.scriptManager.updateScriptContent(
        widget.script.id,
        _codeController.text,
      );
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
                  FilledButton.tonal(
                    onPressed: () {
                      // 运行脚本 - 使用响应式脚本管理器
                      widget.scriptManager.executeScript(widget.script.id);
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, size: 16),
                        SizedBox(width: 4),
                        Text('运行'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 代码编辑器
            Expanded(
              child: CodeTheme(
                data: _isDarkTheme
                    ? CodeThemeData(styles: monokaiSublimeTheme)
                    : CodeThemeData(styles: githubTheme),
                child: CodeField(
                  controller: _codeController,
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
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
