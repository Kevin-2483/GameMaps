import 'package:flutter/material.dart';
import '../../../models/script_data.dart';
import '../../../data/reactive_script_manager.dart';
import 'script_editor_window_reactive.dart';

/// 响应式脚本管理面板
/// 使用新的响应式脚本管理器
class ReactiveScriptPanel extends StatefulWidget {
  final ReactiveScriptManager scriptManager;
  final VoidCallback? onNewScript;

  const ReactiveScriptPanel({
    super.key,
    required this.scriptManager,
    this.onNewScript,
  });

  @override
  State<ReactiveScriptPanel> createState() => _ReactiveScriptPanelState();
}

class _ReactiveScriptPanelState extends State<ReactiveScriptPanel> {
  ScriptType _selectedType = ScriptType.automation;
  String? _selectedScriptId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeSelector(),
          Expanded(child: _buildScriptList()),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SegmentedButton<ScriptType>(
        segments: const [
          ButtonSegment(
            value: ScriptType.automation,
            label: Text('自动化'),
            icon: Icon(Icons.auto_mode, size: 14),
          ),
          ButtonSegment(
            value: ScriptType.animation,
            label: Text('动画'),
            icon: Icon(Icons.animation, size: 14),
          ),
          ButtonSegment(
            value: ScriptType.filter,
            label: Text('过滤'),
            icon: Icon(Icons.filter_list, size: 14),
          ),
          ButtonSegment(
            value: ScriptType.statistics,
            label: Text('统计'),
            icon: Icon(Icons.analytics, size: 14),
          ),
        ],
        selected: {_selectedType},
        onSelectionChanged: (Set<ScriptType> selected) {
          setState(() {
            _selectedType = selected.first;
            _selectedScriptId = null;
          });
        },
        style: SegmentedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          textStyle: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildScriptList() {
    return ListenableBuilder(
      listenable: widget.scriptManager,
      builder: (context, child) {
        final scriptsByType = widget.scriptManager.getScriptsByType();
        final scripts = scriptsByType[_selectedType] ?? [];

        if (scripts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.code_off,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  '暂无${_getTypeDisplayName(_selectedType)}脚本',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _showNewScriptDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('创建脚本'),
                  style: FilledButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 11),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: scripts.length,
          itemBuilder: (context, index) {
            final script = scripts[index];
            return _buildScriptCard(script);
          },
        );
      },
    );
  }

  Widget _buildScriptCard(ScriptData script) {
    final isSelected = _selectedScriptId == script.id;
    final status =
        widget.scriptManager.scriptStatuses[script.id] ?? ScriptStatus.idle;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedScriptId = isSelected ? null : script.id;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(status),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      script.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Switch(
                    value: script.isEnabled,
                    onChanged: (value) {
                      widget.scriptManager.toggleScriptEnabled(script.id);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              if (script.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  script.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (isSelected) ...[
                const SizedBox(height: 8),
                _buildScriptActions(script),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ScriptStatus status) {
    switch (status) {
      case ScriptStatus.idle:
        return Icon(Icons.circle, size: 8, color: Colors.grey.shade400);
      case ScriptStatus.running:
        return Icon(
          Icons.play_circle,
          size: 8,
          color: Theme.of(context).colorScheme.primary,
        );
      case ScriptStatus.paused:
        return Icon(
          Icons.pause_circle,
          size: 8,
          color: Theme.of(context).colorScheme.tertiary,
        );
      case ScriptStatus.error:
        return Icon(
          Icons.error,
          size: 8,
          color: Theme.of(context).colorScheme.error,
        );
    }
  }

  Widget _buildScriptActions(ScriptData script) {
    return Wrap(
      spacing: 4,
      children: [
        _buildActionButton(
          onPressed: () => _executeScript(script),
          icon: Icons.play_arrow,
          label: '运行',
          color: Theme.of(context).colorScheme.primary,
        ),
        _buildActionButton(
          onPressed: () => _editScript(script),
          icon: Icons.edit,
          label: '编辑',
          color: Theme.of(context).colorScheme.secondary,
        ),
        _buildActionButton(
          onPressed: () => _duplicateScript(script),
          icon: Icons.copy,
          label: '复制',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        _buildActionButton(
          onPressed: () => _deleteScript(script),
          icon: Icons.delete,
          label: '删除',
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      height: 24,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 12),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          textStyle: const TextStyle(fontSize: 9),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          minimumSize: Size.zero,
        ),
      ),
    );
  }

  void _showNewScriptDialog() {
    showDialog(
      context: context,
      builder: (context) => _ReactiveScriptEditDialog(
        type: _selectedType,
        scriptManager: widget.scriptManager,
        onSaved: (script) {
          widget.scriptManager.addScript(script);
        },
      ),
    );
  }

  void _editScript(ScriptData script) {
    // 使用响应式脚本编辑器窗口
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: ReactiveScriptEditorWindow(
          script: script,
          scriptManager: widget.scriptManager,
          onClose: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  void _executeScript(ScriptData script) {
    widget.scriptManager.executeScript(script.id).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('脚本执行失败: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    });
  }

  void _duplicateScript(ScriptData script) {
    widget.scriptManager.duplicateScript(script.id);
  }

  void _deleteScript(ScriptData script) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除脚本'),
        content: Text('确定要删除脚本 "${script.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              widget.scriptManager.deleteScript(script.id);
              Navigator.of(context).pop();
              setState(() {
                _selectedScriptId = null;
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(ScriptType type) {
    switch (type) {
      case ScriptType.automation:
        return '自动化';
      case ScriptType.animation:
        return '动画';
      case ScriptType.filter:
        return '过滤';
      case ScriptType.statistics:
        return '统计';
    }
  }

  String _getDefaultScriptContent(ScriptType type) {
    switch (type) {
      case ScriptType.automation:
        return '''// 自动化脚本示例
var layers = getLayers();
log('共有 ' + layers.length.toString() + ' 个图层');

// 遍历所有元素
var elements = getAllElements();
for (var element in elements) {
    log('元素 ' + element['id'] + ' 类型: ' + element['type']);
}''';
      case ScriptType.animation:
        return '''// 动画脚本示例
var elements = getAllElements();
if (elements.length > 0) {
    var element = elements[0];
    
    // 动画改变颜色
    animate(element['id'], 'color', 0xFF00FF00, 1000);
    delay(1000);
    
    // 动画移动元素
    animate(element['id'], 'x', 0.5, 1000);
}''';
      case ScriptType.filter:
        return '''// 过滤脚本示例
var allElements = getAllElements();
var filteredElements = filterElements(allElements, {
    'type': 'rectangle',
    'color': 0xFF0000FF
});

log('找到 ' + filteredElements.length.toString() + ' 个蓝色矩形');''';
      case ScriptType.statistics:
        return '''// 统计脚本示例
var layers = getLayers();
var totalElements = 0;

for (var layer in layers) {
    var elementCount = layer['elementCount'];
    totalElements += elementCount;
    log('图层 ' + layer['name'] + ': ' + elementCount.toString() + ' 个元素');
}

log('总计: ' + totalElements.toString() + ' 个元素');''';
    }
  }
}

/// 响应式脚本编辑对话框
class _ReactiveScriptEditDialog extends StatefulWidget {
  final ScriptType type;
  final ReactiveScriptManager scriptManager;
  final Function(ScriptData) onSaved;

  const _ReactiveScriptEditDialog({
    required this.type,
    required this.scriptManager,
    required this.onSaved,
  });

  @override
  State<_ReactiveScriptEditDialog> createState() =>
      _ReactiveScriptEditDialogState();
}

class _ReactiveScriptEditDialogState extends State<_ReactiveScriptEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late ScriptType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _descriptionController = TextEditingController(text: '');
    _selectedType = widget.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建脚本'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '脚本名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ScriptType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: '脚本类型',
                border: OutlineInputBorder(),
              ),
              items: ScriptType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _saveScript, child: const Text('保存')),
      ],
    );
  }

  void _saveScript() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入脚本名称')));
      return;
    }

    final now = DateTime.now();
    final script = ScriptData(
      id: now.millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      content: _getDefaultScriptContent(_selectedType),
      parameters: {},
      isEnabled: true,
      createdAt: now,
      updatedAt: now,
    );

    widget.onSaved(script);
    Navigator.of(context).pop();
  }

  String _getTypeDisplayName(ScriptType type) {
    switch (type) {
      case ScriptType.automation:
        return '自动化';
      case ScriptType.animation:
        return '动画';
      case ScriptType.filter:
        return '过滤';
      case ScriptType.statistics:
        return '统计';
    }
  }

  String _getDefaultScriptContent(ScriptType type) {
    // 使用相同的默认内容生成逻辑
    final panel = _ReactiveScriptPanelState();
    return panel._getDefaultScriptContent(type);
  }
}
