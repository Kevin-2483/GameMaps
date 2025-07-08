import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../components/color_picker_dialog.dart';
import '../../../components/common/tags_manager.dart';
import '../../../services/tts_service.dart';

class ToolSettingsSection extends StatelessWidget {
  final UserPreferences preferences;

  const ToolSettingsSection({super.key, required this.preferences});
  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserPreferencesProvider>();
    final tools = preferences.tools;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '工具设置',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 最近使用的颜色
            Text(
              '最近使用的颜色',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tools.recentColors.length,
                itemBuilder: (context, index) {
                  final color = Color(tools.recentColors[index]);
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _showColorOptions(context, provider, index),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () =>
                                _removeRecentColor(provider, index),
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addNewColor(context, provider),
                  icon: Icon(Icons.add),
                  label: Text('添加颜色'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _clearRecentColors(context, provider),
                  icon: Icon(Icons.clear_all),
                  label: Text('清空'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 自定义颜色
            Text(
              '自定义颜色',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tools.customColors.length,
                itemBuilder: (context, index) {
                  final color = Color(tools.customColors[index]);
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          _showCustomColorOptions(context, provider, index),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () =>
                                _removeCustomColor(provider, index),
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addNewCustomColor(context, provider),
                  icon: Icon(Icons.add),
                  label: Text('添加自定义颜色'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _clearCustomColors(context, provider),
                  icon: Icon(Icons.clear_all),
                  label: Text('清空'),
                ),
              ],
            ),

            const SizedBox(height: 16), // 常用线条宽度
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '常用线条宽度',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${tools.favoriteStrokeWidths.length}/5',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: tools.favoriteStrokeWidths.asMap().entries.map((entry) {
                final index = entry.key;
                final width = entry.value;
                return Chip(
                  label: Text('${width.round()}px'),
                  deleteIcon: Icon(Icons.close, size: 16),
                  onDeleted: () => _removeFavoriteStrokeWidth(provider, index),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _addStrokeWidth(context, provider),
              icon: Icon(Icons.add),
              label: Text('添加线条宽度'),
            ),

            const SizedBox(height: 16),

            // 工具栏布局
            Text(
              '工具栏布局',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tools.toolbarLayout.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final newLayout = List<String>.from(tools.toolbarLayout);
                  final item = newLayout.removeAt(oldIndex);
                  newLayout.insert(newIndex, item);
                  provider.updateTools(toolbarLayout: newLayout);
                },
                itemBuilder: (context, index) {
                  final tool = tools.toolbarLayout[index];
                  return ListTile(
                    key: ValueKey(tool),
                    leading: Icon(_getToolIcon(tool)),
                    title: Text(_getToolDisplayName(tool)),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: Icon(Icons.drag_handle),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 显示高级工具
            SwitchListTile(
              title: Text('显示高级工具'),
              subtitle: Text('在工具栏中显示专业级工具'),
              value: tools.showAdvancedTools,
              onChanged: (value) =>
                  provider.updateTools(showAdvancedTools: value),
            ),

            const SizedBox(height: 16),

            // 拖动控制柄大小
            Text(
              '拖动控制柄大小',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text('控制柄大小'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('调整绘制元素控制柄的大小'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('4px'),
                      Expanded(
                        child: Slider(
                          value: tools.handleSize.clamp(4.0, 32.0),
                          min: 4.0,
                          max: 32.0,
                          divisions: 28,
                          label: '${tools.handleSize.round()}px',
                          onChanged: (value) =>
                              provider.updateTools(handleSize: value),
                        ),
                      ),
                      Text('32px'),
                    ],
                  ),
                  Text(
                    '当前: ${tools.handleSize.round()}px',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 快捷键设置
            Text(
              '快捷键设置',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            ...tools.shortcuts.entries.map(
              (entry) => ListTile(
                title: Text(_getShortcutDisplayName(entry.key)),
                subtitle: Text(entry.value),
                trailing: IconButton(
                  onPressed: () =>
                      _editShortcut(context, provider, entry.key, entry.value),
                  icon: Icon(Icons.edit),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 重置工具设置
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _resetToolSettings(context, provider),
                    icon: Icon(Icons.restore),
                    label: Text('重置工具设置'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 自定义标签管理
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '自定义标签',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${tools.customTags.length} 个标签',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 自定义标签预览
            if (tools.customTags.isNotEmpty) ...[
              Container(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tools.customTags.length,
                  itemBuilder: (context, index) {
                    final tag = tools.customTags[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => _removeCustomTag(provider, tag),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    '暂无自定义标签',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // 自定义标签操作按钮
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showTagsManager(context, provider),
                  icon: const Icon(Icons.label),
                  label: const Text('管理标签'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _addCustomTag(context, provider),
                  icon: const Icon(Icons.add),
                  label: const Text('添加标签'),
                ),
                const SizedBox(width: 8),
                if (tools.customTags.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _clearCustomTags(context, provider),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('清空'),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // TTS 设置
            Text(
              'TTS 语音合成设置',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // TTS 启用开关
            SwitchListTile(
              title: Text('启用语音合成'),
              subtitle: Text('开启后将支持语音朗读功能'),
              value: tools.tts.enabled,
              onChanged: (value) {
                provider.updateTools(tts: tools.tts.copyWith(enabled: value));
              },
            ),

            // 仅在 TTS 启用时显示其他设置
            if (tools.tts.enabled) ...[
              const SizedBox(height: 8),
              // 语言设置
              _TtsLanguageSelector(
                currentLanguage: tools.tts.language,
                onLanguageChanged: (value) {
                  provider.updateTools(
                    tts: tools.tts.copyWith(language: value),
                  );
                },
              ),

              // 语音速度
              ListTile(
                title: Text('语音速度'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('调整语音播放速度'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('慢'),
                        Expanded(
                          child: Slider(
                            value: tools.tts.speechRate.clamp(0.1, 1.0),
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            label: '${(tools.tts.speechRate * 100).round()}%',
                            onChanged: (value) {
                              provider.updateTools(
                                tts: tools.tts.copyWith(speechRate: value),
                              );
                            },
                          ),
                        ),
                        Text('快'),
                      ],
                    ),
                    Text(
                      '当前: ${(tools.tts.speechRate * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // 音量
              ListTile(
                title: Text('音量'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('调整语音播放音量'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.volume_mute, size: 16),
                        Expanded(
                          child: Slider(
                            value: tools.tts.volume.clamp(0.0, 1.0),
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label: '${(tools.tts.volume * 100).round()}%',
                            onChanged: (value) {
                              provider.updateTools(
                                tts: tools.tts.copyWith(volume: value),
                              );
                            },
                          ),
                        ),
                        Icon(Icons.volume_up, size: 16),
                      ],
                    ),
                    Text(
                      '当前: ${(tools.tts.volume * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // 音调
              ListTile(
                title: Text('音调'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('调整语音音调高低'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('低'),
                        Expanded(
                          child: Slider(
                            value: tools.tts.pitch.clamp(0.5, 2.0),
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label: '${tools.tts.pitch.toStringAsFixed(1)}',
                            onChanged: (value) {
                              provider.updateTools(
                                tts: tools.tts.copyWith(pitch: value),
                              );
                            },
                          ),
                        ),
                        Text('高'),
                      ],
                    ),
                    Text(
                      '当前: ${tools.tts.pitch.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // 语音选择
              _TtsVoiceSelector(
                currentVoice: tools.tts.voice,
                currentLanguage: tools.tts.language,
                onVoiceChanged: (value) {
                  provider.updateTools(tts: tools.tts.copyWith(voice: value));
                },
              ),

              // TTS 测试按钮
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _testTts(context),
                    icon: Icon(Icons.play_arrow),
                    label: Text('测试语音'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _resetTtsSettings(context, provider),
                    icon: Icon(Icons.restore),
                    label: Text('重置TTS设置'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showColorOptions(
    BuildContext context,
    UserPreferencesProvider provider,
    int index,
  ) {
    // 显示颜色选项对话框的实现
  }

  void _removeRecentColor(UserPreferencesProvider provider, int index) {
    final newColors = List<int>.from(preferences.tools.recentColors);
    newColors.removeAt(index);
    provider.updateTools(recentColors: newColors);
  }

  void _addNewColor(BuildContext context, UserPreferencesProvider provider) {
    ColorPicker.showColorPicker(
      context: context,
      initialColor: Colors.blue,
      title: '添加最近使用颜色',
      enableAlpha: true,
    ).then((selectedColor) {
      if (selectedColor != null) {
        provider.addRecentColor(selectedColor.value);
      }
    });
  }

  void _clearRecentColors(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('清空最近颜色'),
        content: Text('确定要清空所有最近使用的颜色吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateTools(recentColors: []);
              Navigator.of(context).pop();
            },
            child: Text('清空'),
          ),
        ],
      ),
    );
  }

  void _removeFavoriteStrokeWidth(UserPreferencesProvider provider, int index) {
    final newWidths = List<double>.from(preferences.tools.favoriteStrokeWidths);
    newWidths.removeAt(index);
    provider.updateTools(favoriteStrokeWidths: newWidths);
  }

  void _addStrokeWidth(BuildContext context, UserPreferencesProvider provider) {
    final currentWidths = preferences.tools.favoriteStrokeWidths;

    // 检查是否已达到最大数量限制
    if (currentWidths.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('最多只能添加5个常用线条宽度'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        double newWidth = 1.0;
        return AlertDialog(
          title: Text('添加线条宽度'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('宽度: ${newWidth.round()}px'),
                const SizedBox(height: 8),
                Text(
                  '当前数量: ${currentWidths.length}/5',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: newWidth,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  onChanged: (value) => setState(() => newWidth = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final newWidths = List<double>.from(currentWidths);
                if (!newWidths.contains(newWidth)) {
                  if (newWidths.length >= 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('最多只能添加5个常用线条宽度'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  newWidths.add(newWidth);
                  newWidths.sort();
                  provider.updateTools(favoriteStrokeWidths: newWidths);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已添加线条宽度 ${newWidth.round()}px'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('该线条宽度已存在'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Text('添加'),
            ),
          ],
        );
      },
    );
  }

  IconData _getToolIcon(String tool) {
    switch (tool) {
      case 'pen':
        return Icons.edit;
      case 'brush':
        return Icons.brush;
      case 'line':
        return Icons.remove;
      case 'dashedLine':
        return Icons.more_horiz;
      case 'arrow':
        return Icons.arrow_forward;
      case 'rectangle':
        return Icons.rectangle;
      case 'hollowRectangle':
        return Icons.rectangle_outlined;
      case 'diagonalLines':
        return Icons.line_style;
      case 'crossLines':
        return Icons.grid_3x3;
      case 'dotGrid':
        return Icons.grid_on;
      case 'freeDrawing':
        return Icons.gesture;
      case 'circle':
        return Icons.circle_outlined;
      case 'text':
        return Icons.text_fields;
      case 'eraser':
        return Icons.content_cut;
      case 'imageArea':
        return Icons.photo_size_select_actual;
      default:
        return Icons.build;
    }
  }

  String _getToolDisplayName(String tool) {
    switch (tool) {
      case 'pen':
        return '钢笔';
      case 'brush':
        return '画笔';
      case 'line':
        return '直线';
      case 'dashedLine':
        return '虚线';
      case 'arrow':
        return '箭头';
      case 'rectangle':
        return '实心矩形';
      case 'hollowRectangle':
        return '空心矩形';
      case 'diagonalLines':
        return '单斜线';
      case 'crossLines':
        return '交叉线';
      case 'dotGrid':
        return '点阵';
      case 'freeDrawing':
        return '像素笔';
      case 'circle':
        return '圆形';
      case 'text':
        return '文本';
      case 'eraser':
        return '橡皮擦';
      case 'imageArea':
        return '图片选区';
      default:
        return tool;
    }
  }

  String _getShortcutDisplayName(String shortcut) {
    switch (shortcut) {
      case 'undo':
        return '撤销';
      case 'redo':
        return '重做';
      case 'save':
        return '保存';
      case 'copy':
        return '复制';
      case 'paste':
        return '粘贴';
      case 'delete':
        return '删除';
      default:
        return shortcut;
    }
  }

  void _editShortcut(
    BuildContext context,
    UserPreferencesProvider provider,
    String action,
    String currentShortcut,
  ) {
    // 编辑快捷键的实现
  }

  void _resetToolSettings(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('重置工具设置'),
        content: Text('确定要将工具设置重置为默认值吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final defaultTools = ToolPreferences.createDefault();
              provider.updateTools(
                recentColors: defaultTools.recentColors,
                customColors: defaultTools.customColors,
                favoriteStrokeWidths: defaultTools.favoriteStrokeWidths,
                shortcuts: defaultTools.shortcuts,
                toolbarLayout: defaultTools.toolbarLayout,
                showAdvancedTools: defaultTools.showAdvancedTools,
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('工具设置已重置'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('重置'),
          ),
        ],
      ),
    );
  }

  void _showCustomColorOptions(
    BuildContext context,
    UserPreferencesProvider provider,
    int index,
  ) {
    // 显示自定义颜色选项对话框的实现
  }

  void _removeCustomColor(UserPreferencesProvider provider, int index) {
    final newColors = List<int>.from(preferences.tools.customColors);
    newColors.removeAt(index);
    provider.updateTools(customColors: newColors);
  }

  void _addNewCustomColor(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    ColorPicker.showColorPicker(
      context: context,
      initialColor: Colors.purple,
      title: '添加自定义颜色',
      enableAlpha: true,
    ).then((selectedColor) {
      if (selectedColor != null) {
        provider.addCustomColor(selectedColor.value);
      }
    });
  }

  void _clearCustomColors(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('清空自定义颜色'),
        content: Text('确定要清空所有自定义颜色吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateTools(customColors: []);
              Navigator.of(context).pop();
            },
            child: Text('清空'),
          ),
        ],
      ),
    );
  }

  // 自定义标签管理方法

  /// 移除自定义标签
  void _removeCustomTag(UserPreferencesProvider provider, String tag) {
    provider.removeCustomTag(tag);
  }

  /// 显示标签管理器
  void _showTagsManager(
    BuildContext context,
    UserPreferencesProvider provider,
  ) async {
    await TagsManagerUtils.showCustomTagsManagerDialog(context, provider);
  }

  /// 添加自定义标签
  void _addCustomTag(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _AddCustomTagDialog(provider: provider),
    );
  }

  /// 清空自定义标签
  void _clearCustomTags(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空自定义标签'),
        content: const Text('确定要清空所有自定义标签吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateCustomTags([]);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('清空', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 测试 TTS 功能
  void _testTts(BuildContext context) async {
    try {
      // 使用 TTS 服务
      final tts = TtsService();
      await tts.initialize();

      // 首先停止所有当前播放，包括测试播放
      await tts.stopBySource('settings_test');
      await tts.stop(); // 停止所有播放

      // 获取当前用户设置
      final ttsSettings = preferences.tools.tts;

      // 测试语音播放，使用当前设置的语言
      final currentLanguage = ttsSettings.language;
      String testText = '这是一个语音合成测试，当前设置已应用。';

      // 根据语言调整测试文本
      if (currentLanguage != null) {
        switch (currentLanguage.toLowerCase().split('-')[0]) {
          case 'en':
            testText =
                'This is a text-to-speech test. Current settings have been applied.';
            break;
          case 'ja':
            testText = 'これは音声合成のテストです。現在の設定が適用されています。';
            break;
          case 'ko':
            testText = '이것은 음성 합성 테스트입니다. 현재 설정이 적용되었습니다.';
            break;
          case 'fr':
            testText =
                'Ceci est un test de synthèse vocale. Les paramètres actuels ont été appliqués.';
            break;
          case 'de':
            testText =
                'Dies ist ein Text-zu-Sprache-Test. Die aktuellen Einstellungen wurden angewendet.';
            break;
          case 'es':
            testText =
                'Esta es una prueba de síntesis de voz. Se han aplicado los ajustes actuales.';
            break;
          case 'it':
            testText =
                'Questo è un test di sintesi vocale. Le impostazioni correnti sono state applicate.';
            break;
          case 'pt':
            testText =
                'Este é um teste de síntese de voz. As configurações atuais foram aplicadas.';
            break;
          case 'ru':
            testText = 'Это тест синтеза речи. Текущие настройки применены.';
            break;
          case 'ar':
            testText =
                'هذا اختبار لتحويل النص إلى كلام. تم تطبيق الإعدادات الحالية.';
            break;
          case 'th':
            testText =
                'นี่คือการทดสอบการสังเคราะห์เสียงพูด การตั้งค่าปัจจุบันได้ถูกนำไปใช้แล้ว';
            break;
          case 'vi':
            testText =
                'Đây là bài kiểm tra chuyển văn bản thành giọng nói. Các cài đặt hiện tại đã được áp dụng.';
            break;
          case 'hi':
            testText =
                'यह टेक्स्ट-टू-स्पीच परीक्षण है। वर्तमान सेटिंग्स लागू की गई हैं।';
            break;
          default:
            testText = '这是一个语音合成测试，当前设置已应用。';
        }
      }

      // 直接调用 TTS，使用当前设置的所有参数
      await tts.speak(
        testText,
        language: ttsSettings.language,
        speechRate: ttsSettings.speechRate,
        volume: ttsSettings.volume,
        pitch: ttsSettings.pitch,
        voice: ttsSettings.voice,
        sourceId: 'settings_test',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'TTS 测试已开始播放 (${_getLanguageDisplayName(currentLanguage ?? 'zh-CN')})',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TTS 测试失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 获取语言显示名称 (用于测试反馈)
  String _getLanguageDisplayName(String languageCode) {
    const languageMap = {
      'zh': '中文',
      'zh-CN': '中文 (简体)',
      'zh-TW': '中文 (繁体)',
      'en': '英语',
      'en-US': '英语 (美国)',
      'en-GB': '英语 (英国)',
      'ja': '日语',
      'ja-JP': '日语',
      'ko': '韩语',
      'ko-KR': '韩语',
      'fr': '法语',
      'fr-FR': '法语',
      'de': '德语',
      'de-DE': '德语',
      'es': '西班牙语',
      'es-ES': '西班牙语',
      'it': '意大利语',
      'it-IT': '意大利语',
      'pt': '葡萄牙语',
      'pt-BR': '葡萄牙语 (巴西)',
      'ru': '俄语',
      'ru-RU': '俄语',
      'ar': '阿拉伯语',
      'ar-SA': '阿拉伯语',
      'th': '泰语',
      'th-TH': '泰语',
      'vi': '越南语',
      'vi-VN': '越南语',
      'hi': '印地语',
      'hi-IN': '印地语',
    };
    return languageMap[languageCode] ?? languageCode;
  }

  /// 重置 TTS 设置
  void _resetTtsSettings(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置TTS设置'),
        content: const Text('确定要重置TTS设置为默认值吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.updateTools(tts: TtsPreferences.createDefault());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('TTS设置已重置'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }
}

/// 添加自定义标签对话框
class _AddCustomTagDialog extends StatefulWidget {
  final UserPreferencesProvider provider;

  const _AddCustomTagDialog({required this.provider});

  @override
  State<_AddCustomTagDialog> createState() => _AddCustomTagDialogState();
}

class _AddCustomTagDialogState extends State<_AddCustomTagDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() async {
    final tag = _controller.text.trim();

    // 验证标签
    final error = TagsManagerUtils.defaultTagValidator(tag);
    if (error != null) {
      setState(() {
        _errorText = error;
      });
      return;
    }

    // 检查是否已存在
    if (widget.provider.tools.customTags.contains(tag)) {
      setState(() {
        _errorText = '标签已存在';
      });
      return;
    }

    // 添加标签
    await widget.provider.addCustomTag(tag);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加自定义标签'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: '标签名称',
          hintText: '输入标签名称',
          border: const OutlineInputBorder(),
          errorText: _errorText,
        ),
        onChanged: (value) {
          if (_errorText != null) {
            setState(() {
              _errorText = null;
            });
          }
        },
        onSubmitted: (_) => _addTag(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _addTag, child: const Text('添加')),
      ],
    );
  }
}

/// TTS 语言选择器组件
class _TtsLanguageSelector extends StatefulWidget {
  final String? currentLanguage;
  final ValueChanged<String?> onLanguageChanged;

  const _TtsLanguageSelector({
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<_TtsLanguageSelector> createState() => _TtsLanguageSelectorState();
}

class _TtsLanguageSelectorState extends State<_TtsLanguageSelector> {
  List<dynamic>? _availableLanguages;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableLanguages();
  }

  Future<void> _loadAvailableLanguages() async {
    try {
      final tts = TtsService();
      await tts.initialize();
      setState(() {
        _availableLanguages = tts.availableLanguages;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getLanguageDisplayName(String languageCode) {
    // 将语言代码转换为显示名称
    const languageMap = {
      // 中文系列
      'zh': '中文',
      'zh-CN': '中文 (简体)',
      'zh-TW': '中文 (繁体)',
      'zh-HK': '中文 (香港)',
      'zh-SG': '中文 (新加坡)',

      // 英语系列
      'en': '英语',
      'en-US': '英语 (美国)',
      'en-GB': '英语 (英国)',
      'en-AU': '英语 (澳大利亚)',
      'en-CA': '英语 (加拿大)',
      'en-IN': '英语 (印度)',

      // 日语
      'ja': '日语',
      'ja-JP': '日语',

      // 韩语
      'ko': '韩语',
      'ko-KR': '韩语',

      // 欧洲语言
      'fr': '法语',
      'fr-FR': '法语 (法国)',
      'fr-CA': '法语 (加拿大)',
      'de': '德语',
      'de-DE': '德语',
      'es': '西班牙语',
      'es-ES': '西班牙语 (西班牙)',
      'es-MX': '西班牙语 (墨西哥)',
      'it': '意大利语',
      'it-IT': '意大利语',
      'pt': '葡萄牙语',
      'pt-BR': '葡萄牙语 (巴西)',
      'pt-PT': '葡萄牙语 (葡萄牙)',
      'ru': '俄语',
      'ru-RU': '俄语',
      'nl': '荷兰语',
      'nl-NL': '荷兰语',

      // 北欧语言
      'sv': '瑞典语',
      'sv-SE': '瑞典语',
      'da': '丹麦语',
      'da-DK': '丹麦语',
      'no': '挪威语',
      'no-NO': '挪威语',
      'fi': '芬兰语',
      'fi-FI': '芬兰语',

      // 东欧语言
      'pl': '波兰语',
      'pl-PL': '波兰语',
      'cs': '捷克语',
      'cs-CZ': '捷克语',
      'hu': '匈牙利语',
      'hu-HU': '匈牙利语',
      'ro': '罗马尼亚语',
      'ro-RO': '罗马尼亚语',
      'bg': '保加利亚语',
      'bg-BG': '保加利亚语',
      'hr': '克罗地亚语',
      'hr-HR': '克罗地亚语',
      'sk': '斯洛伐克语',
      'sk-SK': '斯洛伐克语',
      'sl': '斯洛文尼亚语',
      'sl-SI': '斯洛文尼亚语',
      'et': '爱沙尼亚语',
      'et-EE': '爱沙尼亚语',
      'lv': '拉脱维亚语',
      'lv-LV': '拉脱维亚语',
      'lt': '立陶宛语',
      'lt-LT': '立陶宛语',

      // 其他语言
      'ar': '阿拉伯语',
      'ar-SA': '阿拉伯语',
      'th': '泰语',
      'th-TH': '泰语',
      'vi': '越南语',
      'vi-VN': '越南语',
      'hi': '印地语',
      'hi-IN': '印地语',
      'tr': '土耳其语',
      'tr-TR': '土耳其语',
      'he': '希伯来语',
      'he-IL': '希伯来语',
      'id': '印尼语',
      'id-ID': '印尼语',
      'ms': '马来语',
      'ms-MY': '马来语',
      'tl': '菲律宾语',
      'tl-PH': '菲律宾语',
    };

    return languageMap[languageCode] ?? languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('语言'),
      subtitle: Text(
        widget.currentLanguage != null
            ? _getLanguageDisplayName(widget.currentLanguage!)
            : '默认',
      ),
      trailing: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : DropdownButton<String>(
              value: widget.currentLanguage,
              items: [
                const DropdownMenuItem(value: null, child: Text('默认')),
                if (_availableLanguages != null)
                  ..._availableLanguages!.map<DropdownMenuItem<String>>((lang) {
                    final languageCode = lang.toString();
                    return DropdownMenuItem<String>(
                      value: languageCode,
                      child: Text(_getLanguageDisplayName(languageCode)),
                    );
                  }).toList(),
              ],
              onChanged: widget.onLanguageChanged,
              isExpanded: false,
            ),
    );
  }
}

/// TTS 语音选择器组件
class _TtsVoiceSelector extends StatefulWidget {
  final Map<String, String>? currentVoice;
  final String? currentLanguage;
  final ValueChanged<Map<String, String>?> onVoiceChanged;

  const _TtsVoiceSelector({
    required this.currentVoice,
    required this.currentLanguage,
    required this.onVoiceChanged,
  });

  @override
  State<_TtsVoiceSelector> createState() => _TtsVoiceSelectorState();
}

class _TtsVoiceSelectorState extends State<_TtsVoiceSelector> {
  List<dynamic>? _availableVoices;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableVoices();
  }

  @override
  void didUpdateWidget(_TtsVoiceSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当语言改变时，重新加载语音选项
    if (oldWidget.currentLanguage != widget.currentLanguage) {
      _loadAvailableVoices();
    }
  }

  Future<void> _loadAvailableVoices() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final tts = TtsService();
      await tts.initialize();
      setState(() {
        _availableVoices = tts.availableVoices;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredVoices() {
    if (_availableVoices == null) return [];

    try {
      final voices = <Map<String, dynamic>>[];

      for (final voice in _availableVoices!) {
        if (voice is Map) {
          // 转换为 Map<String, dynamic>
          final voiceMap = <String, dynamic>{};
          voice.forEach((key, value) {
            voiceMap[key.toString()] = value;
          });
          voices.add(voiceMap);
        }
      }

      // 如果指定了语言，过滤匹配的语音
      if (widget.currentLanguage != null) {
        final targetLanguage = widget.currentLanguage!.toLowerCase();
        return voices.where((voice) {
          final voiceLocale = voice['locale']?.toString().toLowerCase();
          if (voiceLocale == null) return false;

          // 支持完全匹配或语言前缀匹配
          return voiceLocale == targetLanguage ||
              voiceLocale.startsWith('${targetLanguage.split('-')[0]}-');
        }).toList();
      }

      return voices;
    } catch (e) {
      return [];
    }
  }

  String _getVoiceDisplayName(Map<String, dynamic> voice) {
    final name = voice['name']?.toString() ?? '';
    final locale = voice['locale']?.toString() ?? '';

    if (name.isNotEmpty && locale.isNotEmpty) {
      return '$name ($locale)';
    } else if (name.isNotEmpty) {
      return name;
    } else if (locale.isNotEmpty) {
      return locale;
    }

    return '未知语音';
  }

  String _getCurrentVoiceDisplayName() {
    if (widget.currentVoice == null) return '默认';

    final name = widget.currentVoice!['name'] ?? '';
    final locale = widget.currentVoice!['locale'] ?? '';

    if (name.isNotEmpty && locale.isNotEmpty) {
      return '$name ($locale)';
    } else if (name.isNotEmpty) {
      return name;
    }

    return '自定义语音';
  }

  @override
  Widget build(BuildContext context) {
    final filteredVoices = _getFilteredVoices();
    final currentVoiceId = _getCurrentVoiceId();

    return ListTile(
      title: const Text('语音'),
      subtitle: Text(_getCurrentVoiceDisplayName()),
      trailing: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : DropdownButton<String>(
              value: currentVoiceId,
              items: [
                const DropdownMenuItem<String>(
                  value: 'default',
                  child: Text('默认'),
                ),
                ...filteredVoices.asMap().entries.map<DropdownMenuItem<String>>(
                  (entry) {
                    final index = entry.key;
                    final voice = entry.value;
                    final voiceId = 'voice_$index';
                    return DropdownMenuItem<String>(
                      value: voiceId,
                      child: Text(_getVoiceDisplayName(voice)),
                    );
                  },
                ).toList(),
              ],
              onChanged: (String? selectedVoiceId) {
                if (selectedVoiceId == null || selectedVoiceId == 'default') {
                  widget.onVoiceChanged(null);
                } else {
                  // 从 voice_1, voice_2 等格式中提取索引
                  final indexStr = selectedVoiceId.replaceFirst('voice_', '');
                  final index = int.tryParse(indexStr);
                  if (index != null && index < filteredVoices.length) {
                    final selectedVoice = filteredVoices[index];
                    final voiceMap = Map<String, String>.from(
                      selectedVoice.map(
                        (key, value) => MapEntry(key, value?.toString() ?? ''),
                      ),
                    );
                    widget.onVoiceChanged(voiceMap);
                  }
                }
              },
              isExpanded: false,
            ),
    );
  }

  // 获取当前语音的ID用于选择
  String? _getCurrentVoiceId() {
    if (widget.currentVoice == null) return 'default';

    final filteredVoices = _getFilteredVoices();
    final currentName = widget.currentVoice!['name'] ?? '';
    final currentLocale = widget.currentVoice!['locale'] ?? '';

    for (int i = 0; i < filteredVoices.length; i++) {
      final voice = filteredVoices[i];
      final voiceName = voice['name']?.toString() ?? '';
      final voiceLocale = voice['locale']?.toString() ?? '';

      if (voiceName == currentName && voiceLocale == currentLocale) {
        return 'voice_$i';
      }
    }

    return 'default';
  }
}
