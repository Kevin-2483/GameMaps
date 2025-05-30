import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';

class MapEditorSettingsSection extends StatelessWidget {
  final UserPreferences preferences;

  const MapEditorSettingsSection({
    super.key,
    required this.preferences,
  });
  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserPreferencesProvider>();
    final mapEditor = preferences.mapEditor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '地图编辑器设置',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 默认绘制工具
            ListTile(
              title: Text('默认绘制工具'),
              subtitle: Text(mapEditor.defaultDrawingTool ?? '无'),
              trailing: DropdownButton<String>(
                value: mapEditor.defaultDrawingTool,
                hint: Text('选择工具'),
                items: const [
                  DropdownMenuItem(value: 'pen', child: Text('钢笔')),
                  DropdownMenuItem(value: 'brush', child: Text('画笔')),
                  DropdownMenuItem(value: 'line', child: Text('直线')),
                  DropdownMenuItem(value: 'rectangle', child: Text('矩形')),
                  DropdownMenuItem(value: 'circle', child: Text('圆形')),
                  DropdownMenuItem(value: 'text', child: Text('文本')),
                ],
                onChanged: (value) => provider.updateMapEditor(
                  defaultDrawingTool: value,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 默认颜色
            ListTile(
              title: Text('默认颜色'),
              leading: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(mapEditor.defaultColor),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.palette),
                onPressed: () => _showColorPicker(context, provider),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 默认线条宽度
            ListTile(
              title: Text('默认线条宽度'),
              subtitle: Slider(
                value: mapEditor.defaultStrokeWidth,
                min: 1.0,
                max: 20.0,
                divisions: 19,
                label: '${mapEditor.defaultStrokeWidth.round()}px',
                onChanged: (value) => provider.updateMapEditor(
                  defaultStrokeWidth: value,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 自动保存设置
            SwitchListTile(
              title: Text('自动保存'),
              subtitle: Text('定期自动保存编辑内容'),
              value: mapEditor.autoSave,
              onChanged: (value) => provider.updateMapEditor(autoSave: value),
            ),
            
            if (mapEditor.autoSave) ...[
              const SizedBox(height: 8),
              ListTile(
                title: Text('自动保存间隔'),
                subtitle: Slider(
                  value: mapEditor.autoSaveInterval.toDouble(),
                  min: 1.0,
                  max: 30.0,
                  divisions: 29,
                  label: '${mapEditor.autoSaveInterval} 分钟',
                  onChanged: (value) => provider.updateMapEditor(
                    autoSaveInterval: value.round(),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 8),
            
            // 撤销历史记录数量
            ListTile(
              title: Text('撤销历史记录数量'),
              subtitle: Slider(
                value: mapEditor.undoHistoryLimit.toDouble(),
                min: 5.0,
                max: 100.0,
                divisions: 19,
                label: '${mapEditor.undoHistoryLimit} 步',
                onChanged: (value) => provider.updateMapEditor(
                  undoHistoryLimit: value.round(),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 网格设置
            SwitchListTile(
              title: Text('显示网格'),
              subtitle: Text('在编辑器中显示网格线'),
              value: mapEditor.showGrid,
              onChanged: (value) => provider.updateMapEditor(showGrid: value),
            ),
            
            if (mapEditor.showGrid) ...[
              const SizedBox(height: 8),
              ListTile(
                title: Text('网格大小'),
                subtitle: Slider(
                  value: mapEditor.gridSize,
                  min: 5.0,
                  max: 50.0,
                  divisions: 9,
                  label: '${mapEditor.gridSize.round()}px',
                  onChanged: (value) => provider.updateMapEditor(
                    gridSize: value,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text('吸附到网格'),
                subtitle: Text('绘制时自动对齐到网格'),
                value: mapEditor.snapToGrid,
                onChanged: (value) => provider.updateMapEditor(snapToGrid: value),
              ),
            ],
            
            const SizedBox(height: 8),
            
            // 缩放敏感度
            ListTile(
              title: Text('缩放敏感度'),
              subtitle: Slider(
                value: mapEditor.zoomSensitivity,
                min: 0.5,
                max: 3.0,
                divisions: 10,
                label: '${mapEditor.zoomSensitivity.toStringAsFixed(1)}x',
                onChanged: (value) => provider.updateMapEditor(
                  zoomSensitivity: value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择颜色'),
        content: Container(
          width: 300,
          height: 300,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _predefinedColors.length,
            itemBuilder: (context, index) {
              final color = _predefinedColors[index];
              return GestureDetector(
                onTap: () {
                  provider.updateMapEditor(defaultColor: color.value);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
        ],
      ),
    );
  }

  static const List<Color> _predefinedColors = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.blueGrey,
  ];
}
