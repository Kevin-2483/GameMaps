import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/script_data.dart';
import '../../../services/script_manager_vfs.dart' as script_service;
import 'script_editor_window.dart';

/// 脚本管理面板
class ScriptPanel extends StatefulWidget {
  const ScriptPanel({super.key});

  @override
  State<ScriptPanel> createState() => _ScriptPanelState();
}

class _ScriptPanelState extends State<ScriptPanel> {
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
          _buildHeader(),
          _buildTypeSelector(),
          Expanded(child: _buildScriptList()),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.code,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '脚本管理',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _showNewScriptDialog,
            icon: const Icon(Icons.add),
            iconSize: 16,
            tooltip: '新建脚本',
          ),
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
  }  Widget _buildScriptList() {
    return Consumer<script_service.ScriptManager>(
      builder: (context, scriptManager, child) {
        final scriptsByType = scriptManager.getScriptsByType();
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
                FilledButton.tonal(
                  onPressed: _showNewScriptDialog,
                  child: const Text('创建脚本'),
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
            return _buildScriptItem(script, scriptManager);
          },
        );
      },
    );
  }
  Widget _buildScriptItem(ScriptData script, script_service.ScriptManager scriptManager) {
    final status = scriptManager.getScriptStatus(script.id);
    final isSelected = _selectedScriptId == script.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
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
                      scriptManager.toggleScriptEnabled(script.id);
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
                _buildScriptActions(script, scriptManager),
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
        return Icon(
          Icons.circle,
          size: 8,
          color: Theme.of(context).colorScheme.outline,
        );
      case ScriptStatus.running:
        return SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      case ScriptStatus.paused:
        return Icon(
          Icons.pause_circle_filled,
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

  Widget _buildScriptActions(ScriptData script, script_service.ScriptManager scriptManager) {
    return Wrap(
      spacing: 4,
      children: [
        _buildActionButton(
          onPressed: () => _executeScript(script, scriptManager),
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
          onPressed: () => _duplicateScript(script, scriptManager),
          icon: Icons.copy,
          label: '复制',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        _buildActionButton(
          onPressed: () => _deleteScript(script, scriptManager),
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
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        foregroundColor: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.tonal(
              onPressed: _showImportDialog,
              child: const Text('导入', style: TextStyle(fontSize: 11)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.tonal(
              onPressed: _selectedScriptId != null ? _exportSelectedScript : null,
              child: const Text('导出', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewScriptDialog() {
    showDialog(
      context: context,
      builder: (context) => _ScriptEditDialog(
        type: _selectedType,        onSaved: (script) {
          context.read<script_service.ScriptManager>().addScript(script);
        },
      ),
    );
  }
  void _editScript(ScriptData script) {
    // 使用脚本编辑器窗口
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(        child: ScriptEditorWindow(
          script: script,
          scriptManager: context.read<script_service.ScriptManager>(),
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _executeScript(ScriptData script, script_service.ScriptManager scriptManager) {
    scriptManager.executeScript(script.id).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('脚本执行失败: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    });
  }

  void _duplicateScript(ScriptData script, script_service.ScriptManager scriptManager) {
    scriptManager.duplicateScript(script.id);
  }

  void _deleteScript(ScriptData script, script_service.ScriptManager scriptManager) {
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
              scriptManager.deleteScript(script.id);
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

  void _showImportDialog() {
    // TODO: 实现导入对话框
  }  void _exportSelectedScript() {
    if (_selectedScriptId != null) {
      try {
        // TODO: 实现导出功能（复制到剪贴板或保存文件）
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('脚本已导出')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
}

/// 脚本编辑对话框
class _ScriptEditDialog extends StatefulWidget {
  final ScriptType type;
  final Function(ScriptData) onSaved;

  const _ScriptEditDialog({
    required this.type,
    required this.onSaved,
  });

  @override
  State<_ScriptEditDialog> createState() => _ScriptEditDialogState();
}

class _ScriptEditDialogState extends State<_ScriptEditDialog> {
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
        FilledButton(
          onPressed: _saveScript,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _saveScript() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入脚本名称')),
      );
      return;
    }    final now = DateTime.now();
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
    moveElement(element['id'], 0.1, 0.1);
}''';
      case ScriptType.filter:
        return '''// 过滤脚本示例
var redElements = filterElements(fun(element) {
    return element['color'] == 0xFFFF0000;
});

log('找到 ' + redElements.length.toString() + ' 个红色元素');''';
      case ScriptType.statistics:
        return '''// 统计脚本示例
var totalElements = countElements();
var rectangles = countElements('rectangle');
var totalArea = calculateTotalArea();

log('总元素数: ' + totalElements.toString());
log('矩形数量: ' + rectangles.toString());
log('总面积: ' + totalArea.toString());''';
    }
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
}
