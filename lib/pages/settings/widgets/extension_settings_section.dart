import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../services/notification/notification_service.dart';

class ExtensionSettingsSection extends StatefulWidget {
  final UserPreferences preferences;

  const ExtensionSettingsSection({super.key, required this.preferences});

  @override
  State<ExtensionSettingsSection> createState() =>
      _ExtensionSettingsSectionState();
}

class _ExtensionSettingsSectionState extends State<ExtensionSettingsSection> {
  final TextEditingController _jsonController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _updateJsonController();
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _updateJsonController() {
    final provider = context.read<UserPreferencesProvider>();
    final jsonString = provider.getExtensionSettingsJson();
    _jsonController.text = _formatJson(jsonString);
  }

  String _formatJson(String jsonString) {
    try {
      final dynamic obj = jsonDecode(jsonString);
      return const JsonEncoder.withIndent('  ').convert(obj);
    } catch (e) {
      return jsonString;
    }
  }

  Future<void> _toggleExtensionStorage() async {
    final provider = context.read<UserPreferencesProvider>();
    final currentValue = provider.layout.enableExtensionStorage;

    await provider.updateLayout(enableExtensionStorage: !currentValue);

    if (!provider.layout.enableExtensionStorage) {
      // 如果禁用扩展储存，清空设置
      await provider.clearExtensionSettings();
      _updateJsonController();
    }
  }

  Future<void> _clearSettings() async {
    final confirmed = await _showConfirmDialog(
      title: '清空扩展设置',
      content: '确定要清空所有扩展设置吗？此操作不可撤销。',
    );

    if (confirmed) {
      final provider = context.read<UserPreferencesProvider>();
      await provider.clearExtensionSettings();
      _updateJsonController();

      if (mounted) {
        context.showSuccessSnackBar('扩展设置已清空');
      }
    }
  }

  Future<void> _saveJsonSettings() async {
    try {
      final provider = context.read<UserPreferencesProvider>();
      await provider.updateExtensionSettingsFromJson(_jsonController.text);

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        context.showSuccessSnackBar('扩展设置已保存');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('保存失败: ${e.toString()}');
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
    _updateJsonController();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _jsonController.text));
    context.showInfoSnackBar('已复制到剪贴板');
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserPreferencesProvider>();
    final settingsSize = provider.getExtensionSettingsSize();
    final hasSettings = provider.extensionSettings.isNotEmpty;
    final isEnabled = provider.layout.enableExtensionStorage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                Expanded(
                  child: Text(
                    '扩展设置存储',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: (_) => _toggleExtensionStorage(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 说明文字
            Text(
              '用于存储临时的地图相关偏好设置，如图例组智能隐藏状态等。这些设置不会影响地图数据本身。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            if (isEnabled) ...[
              // 统计信息
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '存储大小: ${(settingsSize / 1024).toStringAsFixed(2)} KB | '
                        '键值对数量: ${provider.extensionSettings.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 操作按钮
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!_isEditing && hasSettings) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('编辑JSON'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('复制'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _clearSettings,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('清空'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ],
                  if (_isEditing) ...[
                    ElevatedButton.icon(
                      onPressed: _saveJsonSettings,
                      icon: const Icon(Icons.save, size: 16),
                      label: const Text('保存'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _cancelEditing,
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('取消'),
                    ),
                  ],
                  if (!hasSettings && !_isEditing)
                    Text(
                      '当前没有扩展设置数据',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // JSON编辑器
              if (hasSettings || _isEditing) ...[
                Text(
                  'JSON数据',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _jsonController,
                    readOnly: !_isEditing,
                    maxLines: 10,
                    style: const TextStyle(fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      hintText: '{}',
                    ),
                  ),
                ),
              ],
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '扩展设置存储已禁用',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
