import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../models/script_data.dart';
import '../../../data/new_reactive_script_manager.dart';
import '../../../components/dialogs/script_parameters_dialog.dart';
import 'script_editor_window_reactive.dart';

/// 响应式脚本管理面板
/// 使用新的异步响应式脚本管理器
class ReactiveScriptPanel extends StatefulWidget {
  final NewReactiveScriptManager scriptManager;
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
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSystemStatusHeader(),
          _buildTypeSelector(),
          Expanded(child: _buildScriptList()),
        ],
      ),
    );
  }

  /// 构建系统状态头部
  Widget _buildSystemStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: ListenableBuilder(
        listenable: widget.scriptManager,
        builder: (context, child) {
          return Row(
            children: [
              // 脚本引擎状态指示器
              _buildEngineStatusIndicator(),
              const SizedBox(width: 12),

              // 脚本统计信息
              Expanded(child: _buildScriptStats()),

              // 系统控制按钮
              _buildSystemControls(),
            ],
          );
        },
      ),
    );
  }

  /// 构建引擎状态指示器
  Widget _buildEngineStatusIndicator() {
    final hasMapData = widget.scriptManager.hasMapData;
    final isWeb = kIsWeb;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasMapData ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '脚本引擎',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              isWeb ? 'Web Worker' : 'Isolate',
              style: TextStyle(
                fontSize: 8,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建脚本统计信息
  Widget _buildScriptStats() {
    final scripts = widget.scriptManager.scripts;
    final statuses = widget.scriptManager.scriptStatuses;

    final runningCount = statuses.values
        .where((s) => s == ScriptStatus.running)
        .length;
    final enabledCount = scripts.where((s) => s.isEnabled).length;
    final totalCount = scripts.length;

    return Row(
      children: [
        _buildStatChip(
          label: '总数',
          value: '$totalCount',
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 6),
        _buildStatChip(
          label: '启用',
          value: '$enabledCount',
          color: Colors.green,
        ),
        const SizedBox(width: 6),
        if (runningCount > 0)
          _buildStatChip(
            label: '运行中',
            value: '$runningCount',
            color: Colors.orange,
            isAnimated: true,
          ),
      ],
    );
  }

  /// 构建统计芯片
  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
    bool isAnimated = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAnimated) ...[
            SizedBox(
              width: 8,
              height: 8,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建系统控制按钮
  Widget _buildSystemControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 刷新按钮
        IconButton(
          onPressed: () {
            setState(() {
              // 触发重新构建以刷新状态
            });
          },
          icon: const Icon(Icons.refresh, size: 16),
          tooltip: '刷新状态',
          style: IconButton.styleFrom(
            minimumSize: const Size(24, 24),
            padding: EdgeInsets.zero,
          ),
        ),
        // 日志按钮
        IconButton(
          onPressed: _showExecutionLogs,
          icon: const Icon(Icons.list_alt, size: 16),
          tooltip: '查看执行日志',
          style: IconButton.styleFrom(
            minimumSize: const Size(24, 24),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  /// 显示执行日志
  void _showExecutionLogs() {
    showDialog(
      context: context,
      builder: (context) =>
          _ExecutionLogsDialog(scriptManager: widget.scriptManager),
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
    final status = widget.scriptManager.getScriptStatus(script.id);
    final lastResult = widget.scriptManager.getLastResult(script.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
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
              // 主要信息行
              Row(
                children: [
                  _buildAdvancedStatusIndicator(status, lastResult),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          script.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (status == ScriptStatus.running) ...[
                          const SizedBox(height: 2),
                          _buildRunningIndicator(),
                        ] else if (lastResult != null) ...[
                          const SizedBox(height: 2),
                          _buildLastExecutionInfo(lastResult),
                        ],
                      ],
                    ),
                  ),
                  // 执行控制按钮
                  _buildExecutionControls(script, status),
                  const SizedBox(width: 8),
                  // 启用/禁用开关
                  Switch(
                    value: script.isEnabled,
                    onChanged: (value) {
                      widget.scriptManager.toggleScriptEnabled(script.id);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),

              // 描述信息
              if (script.description.isNotEmpty) ...[
                const SizedBox(height: 6),
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

              // 执行结果详情（仅在选中时显示）
              if (isSelected && lastResult != null) ...[
                const SizedBox(height: 8),
                _buildExecutionResultDetails(lastResult),
              ],

              // 操作按钮（仅在选中时显示）
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

  /// 构建高级状态指示器
  Widget _buildAdvancedStatusIndicator(
    ScriptStatus status,
    ScriptExecutionResult? lastResult,
  ) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor(status).withValues(alpha: 0.2),
        border: Border.all(color: _getStatusColor(status), width: 2),
      ),
      child: Center(
        child: status == ScriptStatus.running
            ? SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(status),
                  ),
                ),
              )
            : Icon(
                _getStatusIcon(status, lastResult),
                size: 12,
                color: _getStatusColor(status),
              ),
      ),
    );
  }

  /// 构建运行中指示器
  Widget _buildRunningIndicator() {
    return Row(
      children: [
        SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '执行中...',
          style: TextStyle(
            fontSize: 9,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 构建最后执行信息
  Widget _buildLastExecutionInfo(ScriptExecutionResult result) {
    return Row(
      children: [
        Icon(
          result.success ? Icons.check_circle : Icons.error_outline,
          size: 10,
          color: result.success ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          result.success
              ? '执行成功 (${result.executionTime.inMilliseconds}ms)'
              : '执行失败',
          style: TextStyle(
            fontSize: 9,
            color: result.success ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  /// 构建执行控制按钮
  Widget _buildExecutionControls(ScriptData script, ScriptStatus status) {
    if (status == ScriptStatus.running) {
      return IconButton(
        onPressed: () => widget.scriptManager.stopScript(script.id),
        icon: const Icon(Icons.stop_circle, size: 18),
        tooltip: '停止执行',
        style: IconButton.styleFrom(
          foregroundColor: Colors.red,
          minimumSize: const Size(24, 24),
          padding: EdgeInsets.zero,
        ),
      );
    } else {
      return IconButton(
        onPressed: script.isEnabled ? () => _executeScript(script) : null,
        icon: const Icon(Icons.play_circle, size: 18),
        tooltip: '执行脚本',
        style: IconButton.styleFrom(
          foregroundColor: script.isEnabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).disabledColor,
          minimumSize: const Size(24, 24),
          padding: EdgeInsets.zero,
        ),
      );
    }
  }

  /// 构建执行结果详情
  Widget _buildExecutionResultDetails(ScriptExecutionResult result) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: result.success
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: result.success ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.error,
                size: 14,
                color: result.success ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                result.success ? '执行成功' : '执行失败',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: result.success ? Colors.green : Colors.red,
                ),
              ),
              const Spacer(),
              Text(
                '${result.executionTime.inMilliseconds}ms',
                style: TextStyle(
                  fontSize: 10,
                  color: result.success ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (!result.success && result.error != null) ...[
            const SizedBox(height: 4),
            Text(
              result.error!,
              style: const TextStyle(fontSize: 10, color: Colors.red),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (result.success && result.result != null) ...[
            const SizedBox(height: 4),
            Text(
              '返回值: ${result.result}',
              style: const TextStyle(fontSize: 10, color: Colors.green),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(ScriptStatus status) {
    switch (status) {
      case ScriptStatus.idle:
        return Colors.grey;
      case ScriptStatus.running:
        return Theme.of(context).colorScheme.primary;
      case ScriptStatus.paused:
        return Colors.orange;
      case ScriptStatus.error:
        return Colors.red;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(
    ScriptStatus status,
    ScriptExecutionResult? lastResult,
  ) {
    switch (status) {
      case ScriptStatus.idle:
        if (lastResult != null) {
          return lastResult.success ? Icons.check : Icons.error;
        }
        return Icons.circle;
      case ScriptStatus.running:
        return Icons.play_arrow;
      case ScriptStatus.paused:
        return Icons.pause;
      case ScriptStatus.error:
        return Icons.error;
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
          backgroundColor: color.withValues(alpha: 0.1),
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

  void _executeScript(ScriptData script) async {
    try {
      // 获取脚本参数定义
      final parameters = widget.scriptManager.getScriptParameters(script.id);
      
      Map<String, dynamic>? runtimeParameters;
      
      // 如果脚本有参数，显示参数输入对话框
      if (parameters.isNotEmpty) {
        runtimeParameters = await showDialog<Map<String, dynamic>>(
           context: context,
           builder: (context) => ScriptParametersDialog(
             scriptName: script.name,
             parameters: parameters,
             initialValues: const {},
           ),
         );
        
        // 如果用户取消了对话框，不执行脚本
        if (runtimeParameters == null) {
          return;
        }
      }
      
      // 执行脚本，传入运行时参数
      await widget.scriptManager.executeScript(script.id, runtimeParameters: runtimeParameters);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('脚本执行失败: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
  final NewReactiveScriptManager scriptManager;
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

/// 执行日志对话框组件
/// 支持实时刷新日志显示
class _ExecutionLogsDialog extends StatefulWidget {
  final NewReactiveScriptManager scriptManager;

  const _ExecutionLogsDialog({required this.scriptManager});

  @override
  State<_ExecutionLogsDialog> createState() => _ExecutionLogsDialogState();
}

class _ExecutionLogsDialogState extends State<_ExecutionLogsDialog> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // 启动定时刷新，每500ms刷新一次
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = widget.scriptManager.getExecutionLogs();

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.terminal, size: 20),
          const SizedBox(width: 8),
          const Text('脚本执行日志'),
          const Spacer(),
          Text(
            '共 ${logs.length} 条',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 400,
        child: logs.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('暂无执行日志'),
                    SizedBox(height: 8),
                    Text(
                      '执行脚本时的日志会显示在这里',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? Colors.grey.shade50
                            : Colors.white,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}.',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            widget.scriptManager.clearExecutionLogs();
            setState(() {});
          },
          icon: const Icon(Icons.clear_all, size: 16),
          label: const Text('清空日志'),
        ),
        TextButton.icon(
          onPressed: () {
            setState(() {});
          },
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('刷新'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
