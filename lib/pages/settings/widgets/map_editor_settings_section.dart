import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';

class MapEditorSettingsSection extends StatelessWidget {
  final UserPreferences preferences;

  const MapEditorSettingsSection({super.key, required this.preferences});
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 撤销历史记录数量
            ListTile(
              title: Text('撤销历史记录数量'),
              subtitle: Slider(
                value: mapEditor.undoHistoryLimit.toDouble(),
                min: 5.0,
                max: 100.0,
                divisions: 19,
                label: '${mapEditor.undoHistoryLimit} 步',
                onChanged: (value) =>
                    provider.updateMapEditor(undoHistoryLimit: value.round()),
              ),
            ),
            const SizedBox(height: 8),

            // 背景图案设置
            ListTile(
              title: Text('背景图案'),
              subtitle: DropdownButtonFormField<BackgroundPattern>(
                value: mapEditor.backgroundPattern,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: BackgroundPattern.values.map((pattern) {
                  String displayText;
                  switch (pattern) {
                    case BackgroundPattern.blank:
                      displayText = '空白';
                      break;
                    case BackgroundPattern.grid:
                      displayText = '网格';
                      break;
                    case BackgroundPattern.checkerboard:
                      displayText = '棋盘格';
                      break;
                  }
                  return DropdownMenuItem(
                    value: pattern,
                    child: Text(displayText),
                  );
                }).toList(),
                onChanged: (pattern) {
                  if (pattern != null) {
                    provider.updateMapEditor(backgroundPattern: pattern);
                  }
                },
              ),
            ),

            const SizedBox(height: 8), // 缩放敏感度
            ListTile(
              title: Text('缩放敏感度'),
              subtitle: Slider(
                value: mapEditor.zoomSensitivity,
                min: 0.5,
                max: 3.0,
                divisions: 10,
                label: '${mapEditor.zoomSensitivity.toStringAsFixed(1)}x',
                onChanged: (value) =>
                    provider.updateMapEditor(zoomSensitivity: value),
              ),
            ),

            const SizedBox(height: 8),

            // 画布边距
            ListTile(
              title: Text('画布边距'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    value: mapEditor.canvasBoundaryMargin,
                    min: 20.0,
                    max: 1200.0,
                    divisions: 118, // (1200-20)/10 = 118
                    label: '${mapEditor.canvasBoundaryMargin.round()}px',
                    onChanged: (value) =>
                        provider.updateMapEditor(canvasBoundaryMargin: value),
                  ),
                  Text(
                    '控制画布内容与容器边缘的距离：${mapEditor.canvasBoundaryMargin.round()}px',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
