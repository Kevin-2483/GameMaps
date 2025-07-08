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

            const SizedBox(height: 16),

            // 轮盘菜单设置标题
            Text(
              '轮盘菜单设置',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 轮盘菜单触发按键
            ListTile(
              title: Text('触发按键'),
              subtitle: DropdownButtonFormField<int>(
                value: mapEditor.radialMenuButton,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 2,
                    child: Text('右键'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('中键'),
                  ),
                ],
                onChanged: (button) {
                  if (button != null) {
                    provider.updateMapEditor(radialMenuButton: button);
                  }
                },
              ),
            ),

            const SizedBox(height: 8),

            // 轮盘菜单半径
            ListTile(
              title: Text('菜单半径'),
              subtitle: Slider(
                value: mapEditor.radialMenuRadius,
                min: 60.0,
                max: 200.0,
                divisions: 14,
                label: '${mapEditor.radialMenuRadius.round()}px',
                onChanged: (value) =>
                    provider.updateMapEditor(radialMenuRadius: value),
              ),
            ),

            const SizedBox(height: 8),

            // 轮盘菜单中心区域半径
            ListTile(
              title: Text('中心区域半径'),
              subtitle: Slider(
                value: mapEditor.radialMenuCenterRadius,
                min: 15.0,
                max: 60.0,
                divisions: 9,
                label: '${mapEditor.radialMenuCenterRadius.round()}px',
                onChanged: (value) =>
                    provider.updateMapEditor(radialMenuCenterRadius: value),
              ),
            ),

            const SizedBox(height: 8),

            // 轮盘菜单背景透明度
            ListTile(
              title: Text('背景透明度'),
              subtitle: Slider(
                value: mapEditor.radialMenuBackgroundOpacity,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label: '${(mapEditor.radialMenuBackgroundOpacity * 100).round()}%',
                onChanged: (value) =>
                    provider.updateMapEditor(radialMenuBackgroundOpacity: value),
              ),
            ),

            const SizedBox(height: 8),

            // 轮盘菜单对象透明度
            ListTile(
              title: Text('对象透明度'),
              subtitle: Slider(
                value: mapEditor.radialMenuObjectOpacity,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label: '${(mapEditor.radialMenuObjectOpacity * 100).round()}%',
                onChanged: (value) =>
                    provider.updateMapEditor(radialMenuObjectOpacity: value),
              ),
            ),

            const SizedBox(height: 8),

            // 轮盘菜单返回延迟
            ListTile(
              title: Text('返回延迟'),
              subtitle: Slider(
                value: mapEditor.radialMenuReturnDelay.toDouble(),
                min: 50.0,
                max: 500.0,
                divisions: 9,
                label: '${mapEditor.radialMenuReturnDelay}ms',
                onChanged: (value) =>
                    provider.updateMapEditor(radialMenuReturnDelay: value.round()),
              ),
            ),

            const SizedBox(height: 8),

            // 轮盘菜单动画持续时间
            ListTile(
              title: Text('动画持续时间'),
              subtitle: Slider(
                value: mapEditor.radialMenuAnimationDuration.toDouble(),
                min: 100.0,
                max: 800.0,
                divisions: 14,
                label: '${mapEditor.radialMenuAnimationDuration}ms',
                onChanged: (value) =>
                    provider.updateMapEditor(radialMenuAnimationDuration: value.round()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
