import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';

class ToolSettingsSection extends StatelessWidget {
  final UserPreferences preferences;

  const ToolSettingsSection({
    super.key,
    required this.preferences,
  });
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 最近使用的颜色
            Text(
              '最近使用的颜色',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
                            onPressed: () => _removeRecentColor(provider, index),
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
                ),            ],
            ),
            
            const SizedBox(height: 16),
            
            // 自定义颜色
            Text(
              '自定义颜色',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
                      onTap: () => _showCustomColorOptions(context, provider, index),
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
                            onPressed: () => _removeCustomColor(provider, index),
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
            
            const SizedBox(height: 16),
            
            // 常用线条宽度
            Text(
              '常用线条宽度',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: tools.favoriteStrokeWidths.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final width = entry.value;
                  return Chip(
                    label: Text('${width.round()}px'),
                    deleteIcon: Icon(Icons.close, size: 16),
                    onDeleted: () => _removeFavoriteStrokeWidth(provider, index),
                  );
                },
              ).toList(),
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
              onChanged: (value) => provider.updateTools(showAdvancedTools: value),
            ),
            
            const SizedBox(height: 16),
            
            // 快捷键设置
            Text(
              '快捷键设置',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            ...tools.shortcuts.entries.map(
              (entry) => ListTile(
                title: Text(_getShortcutDisplayName(entry.key)),
                subtitle: Text(entry.value),
                trailing: IconButton(
                  onPressed: () => _editShortcut(context, provider, entry.key, entry.value),
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
          ],
        ),
      ),
    );
  }

  void _showColorOptions(BuildContext context, UserPreferencesProvider provider, int index) {
    // 显示颜色选项对话框的实现
  }

  void _removeRecentColor(UserPreferencesProvider provider, int index) {
    final newColors = List<int>.from(preferences.tools.recentColors);
    newColors.removeAt(index);
    provider.updateTools(recentColors: newColors);
  }

  void _addNewColor(BuildContext context, UserPreferencesProvider provider) {
    // 添加新颜色的实现
  }

  void _clearRecentColors(BuildContext context, UserPreferencesProvider provider) {
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
                final newWidths = List<double>.from(preferences.tools.favoriteStrokeWidths);
                if (!newWidths.contains(newWidth)) {
                  newWidths.add(newWidth);
                  newWidths.sort();
                  provider.updateTools(favoriteStrokeWidths: newWidths);
                }
                Navigator.of(context).pop();
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
      case 'rectangle':
        return Icons.crop_square;
      case 'circle':
        return Icons.circle_outlined;
      case 'text':
        return Icons.text_fields;
      case 'eraser':
        return Icons.cleaning_services;
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
      case 'rectangle':
        return '矩形';
      case 'circle':
        return '圆形';
      case 'text':
        return '文本';
      case 'eraser':
        return '橡皮擦';
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

  void _editShortcut(BuildContext context, UserPreferencesProvider provider, String action, String currentShortcut) {
    // 编辑快捷键的实现
  }

  void _resetToolSettings(BuildContext context, UserPreferencesProvider provider) {
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
            onPressed: () {              final defaultTools = ToolPreferences.createDefault();
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
        ],      ),
    );
  }

  void _showCustomColorOptions(BuildContext context, UserPreferencesProvider provider, int index) {
    // 显示自定义颜色选项对话框的实现
  }

  void _removeCustomColor(UserPreferencesProvider provider, int index) {
    final newColors = List<int>.from(preferences.tools.customColors);
    newColors.removeAt(index);
    provider.updateTools(customColors: newColors);
  }

  void _addNewCustomColor(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择自定义颜色'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _predefinedColors.length,
            itemBuilder: (context, index) {
              final color = _predefinedColors[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  provider.addCustomColor(color.value);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _clearCustomColors(BuildContext context, UserPreferencesProvider provider) {
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

  static const List<Color> _predefinedColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Color(0xFF8E24AA),
    Color(0xFF5E35B1),
    Color(0xFF3949AB),
    Color(0xFF1E88E5),
    Color(0xFF039BE5),
    Color(0xFF00ACC1),
    Color(0xFF00897B),
    Color(0xFF43A047),
    Color(0xFF7CB342),
    Color(0xFFC0CA33),
    Color(0xFFFFB300),
    Color(0xFFFF8F00),
    Color(0xFFFF5722),
    Color(0xFF6D4C41),
    Color(0xFF546E7A),
    Color(0xFF37474F),
  ];
}
