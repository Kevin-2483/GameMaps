import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../widgets/key_capture_widget.dart';

class MapEditorSettingsSection extends StatelessWidget {
  final UserPreferences preferences;

  const MapEditorSettingsSection({super.key, required this.preferences});

  /// 获取快捷键显示名称
  String _getShortcutDisplayName(String shortcut) {
    switch (shortcut) {
      case 'prevLayer':
        return '选择上一个图层';
      case 'nextLayer':
        return '选择下一个图层';
      case 'prevLayerGroup':
        return '选择上一个图层组';
      case 'nextLayerGroup':
        return '选择下一个图层组';
      case 'prevLegendGroup':
        return '打开上一个图例组';
      case 'nextLegendGroup':
        return '打开下一个图例组';
      case 'openLegendDrawer':
        return '打开图例管理抽屉';
      case 'clearLayerSelection':
        return '清除图层/图层组选择';
      // 工具快捷键
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
      // 图层组选择快捷键
      case 'selectLayerGroup1':
        return '选择图层组 1';
      case 'selectLayerGroup2':
        return '选择图层组 2';
      case 'selectLayerGroup3':
        return '选择图层组 3';
      case 'selectLayerGroup4':
        return '选择图层组 4';
      case 'selectLayerGroup5':
        return '选择图层组 5';
      case 'selectLayerGroup6':
        return '选择图层组 6';
      case 'selectLayerGroup7':
        return '选择图层组 7';
      case 'selectLayerGroup8':
        return '选择图层组 8';
      case 'selectLayerGroup9':
        return '选择图层组 9';
      case 'selectLayerGroup10':
        return '选择图层组 10';
      // 图层选择快捷键
      case 'selectLayer1':
        return '选择图层 1';
      case 'selectLayer2':
        return '选择图层 2';
      case 'selectLayer3':
        return '选择图层 3';
      case 'selectLayer4':
        return '选择图层 4';
      case 'selectLayer5':
        return '选择图层 5';
      case 'selectLayer6':
        return '选择图层 6';
      case 'selectLayer7':
        return '选择图层 7';
      case 'selectLayer8':
        return '选择图层 8';
      case 'selectLayer9':
        return '选择图层 9';
      case 'selectLayer10':
        return '选择图层 10';
      case 'selectLayer11':
        return '选择图层 11';
      case 'selectLayer12':
        return '选择图层 12';
      default:
        return shortcut;
    }
  }

  /// 构建快捷键chip显示
  Widget _buildShortcutChips(List<String> shortcuts) {
    if (shortcuts.isEmpty) {
      return Text(
        '未设置',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
    }

    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: shortcuts.map((shortcut) {
        final keys = shortcut.split('+');
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue[200]!, width: 1),
          ),
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _buildKeyChips(keys),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildKeyChips(List<String> keys) {
    List<Widget> widgets = [];
    for (int i = 0; i < keys.length; i++) {
      if (i > 0) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.add,
              size: 12,
              color: Colors.grey[600],
            ),
          ),
        );
      }
      widgets.add(_buildKeyChip(keys[i]));
    }
    return widgets;
  }

  Widget _buildKeyChip(String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getKeyColor(key),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Text(
        _getKeyDisplayName(key),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Color _getKeyColor(String key) {
    switch (key.toLowerCase()) {
      case 'control':
      case 'shift':
      case 'alt':
      case 'meta':
        return Colors.orange[100]!;
      case 'f1':
      case 'f2':
      case 'f3':
      case 'f4':
      case 'f5':
      case 'f6':
      case 'f7':
      case 'f8':
      case 'f9':
      case 'f10':
      case 'f11':
      case 'f12':
        return Colors.purple[100]!;
      case 'arrowup':
      case 'arrowdown':
      case 'arrowleft':
      case 'arrowright':
        return Colors.green[100]!;
      case 'space':
      case 'enter':
      case 'tab':
      case 'escape':
      case 'backspace':
      case 'delete':
        return Colors.blue[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _getKeyDisplayName(String key) {
    switch (key.toLowerCase()) {
      case 'control':
        return 'Ctrl';
      case 'shift':
        return 'Shift';
      case 'alt':
        return 'Alt';
      case 'meta':
        return 'Win';
      case 'space':
        return 'Space';
      case 'enter':
        return 'Enter';
      case 'tab':
        return 'Tab';
      case 'escape':
        return 'Esc';
      case 'backspace':
        return 'Backspace';
      case 'delete':
        return 'Del';
      case 'arrowup':
        return '↑';
      case 'arrowdown':
        return '↓';
      case 'arrowleft':
        return '←';
      case 'arrowright':
        return '→';
      default:
        return key.toUpperCase();
    }
  }

  /// 检查快捷键冲突
  /// 返回冲突的动作名称，如果没有冲突返回null
  String? _checkShortcutConflict(String shortcut, String currentAction, Map<String, List<String>> allShortcuts) {
    // 定义受保护的快捷键（数字键1-0和F1-F12）
    final protectedShortcuts = {
      '1': 'selectLayerGroup1',
      '2': 'selectLayerGroup2', 
      '3': 'selectLayerGroup3',
      '4': 'selectLayerGroup4',
      '5': 'selectLayerGroup5',
      '6': 'selectLayerGroup6',
      '7': 'selectLayerGroup7',
      '8': 'selectLayerGroup8',
      '9': 'selectLayerGroup9',
      '0': 'selectLayerGroup10',
      'F1': 'selectLayer1',
      'F2': 'selectLayer2',
      'F3': 'selectLayer3',
      'F4': 'selectLayer4',
      'F5': 'selectLayer5',
      'F6': 'selectLayer6',
      'F7': 'selectLayer7',
      'F8': 'selectLayer8',
      'F9': 'selectLayer9',
      'F10': 'selectLayer10',
      'F11': 'selectLayer11',
      'F12': 'selectLayer12',
    };

    // 检查是否与受保护的快捷键冲突
    if (protectedShortcuts.containsKey(shortcut)) {
      final protectedAction = protectedShortcuts[shortcut]!;
      if (currentAction != protectedAction) {
        return protectedAction;
      }
    }

    // 检查是否与其他已设置的快捷键冲突
    for (final entry in allShortcuts.entries) {
      if (entry.key != currentAction && entry.value.contains(shortcut)) {
        return entry.key;
      }
    }

    return null;
  }

  /// 编辑快捷键
  void _editShortcut(
      BuildContext context,
      UserPreferencesProvider provider,
      String action,
      List<String> currentShortcuts) {
    List<String> newShortcuts = List.from(currentShortcuts);
    String tempShortcut = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('编辑快捷键'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('为 ${_getShortcutDisplayName(action)} 设置快捷键'),
                const SizedBox(height: 16),
                Text(
                  '当前快捷键:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (newShortcuts.isEmpty)
                  Text(
                    '未设置',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: newShortcuts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final shortcut = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue[200]!, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(shortcut, style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  newShortcuts.removeAt(index);
                                });
                              },
                              child: Icon(Icons.close, size: 16, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                Text(
                  '添加新快捷键:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击下方区域，然后按下您想要添加的快捷键组合',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                KeyCaptureWidget(
                  initialValue: '',
                  onKeyCaptured: (value) {
                    tempShortcut = value;
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                   onPressed: () {
                     if (tempShortcut.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('请先按下快捷键组合'),
                           backgroundColor: Colors.orange,
                           duration: Duration(seconds: 2),
                         ),
                       );
                       return;
                     }
                     
                     // 检查是否在当前列表中重复
                     if (newShortcuts.contains(tempShortcut)) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('快捷键重复: $tempShortcut 已在当前列表中'),
                           backgroundColor: Colors.orange,
                           duration: Duration(seconds: 2),
                         ),
                       );
                       return;
                     }
                     
                     // 检查快捷键冲突
                     final conflictResult = _checkShortcutConflict(tempShortcut, action, provider.currentPreferences!.mapEditor.shortcuts);
                     if (conflictResult != null) {
                       // 显示冲突警告
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('快捷键冲突: $tempShortcut 已被 "${_getShortcutDisplayName(conflictResult)}" 使用'),
                           backgroundColor: Colors.red,
                           duration: Duration(seconds: 3),
                         ),
                       );
                       return;
                     }
                     
                     setState(() {
                       newShortcuts.add(tempShortcut);
                       tempShortcut = '';
                     });
                   },
                   child: Text('添加快捷键'),
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
                  // 检查列表内是否有重复快捷键
                  final duplicates = <String>{};
                  final seen = <String>{};
                  for (final shortcut in newShortcuts) {
                    if (seen.contains(shortcut)) {
                      duplicates.add(shortcut);
                    } else {
                      seen.add(shortcut);
                    }
                  }
                  
                  if (duplicates.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('列表中存在重复快捷键: ${duplicates.join(", ")}'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  
                  // 检查所有快捷键是否与其他功能冲突
                  bool hasConflict = false;
                  String? conflictMessage;
                  
                  for (final shortcut in newShortcuts) {
                    final conflictResult = _checkShortcutConflict(shortcut, action, provider.currentPreferences!.mapEditor.shortcuts);
                    if (conflictResult != null) {
                      hasConflict = true;
                      conflictMessage = '快捷键冲突: $shortcut 已被 "${_getShortcutDisplayName(conflictResult)}" 使用';
                      break;
                    }
                  }
                  
                  if (hasConflict) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(conflictMessage!),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  
                  provider.updateMapEditorShortcut(action, newShortcuts);
                  Navigator.of(context).pop();
                },
                child: Text('保存'),
              ),
          ],
        ),
      ),
    );
  }



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

            const SizedBox(height: 16),

            // 快捷键设置标题
            Text(
              '快捷键设置',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 快捷键列表
            ...mapEditor.shortcuts.entries.map(
              (entry) => ListTile(
                title: Text(_getShortcutDisplayName(entry.key)),
                subtitle: _buildShortcutChips(entry.value),
                trailing: IconButton(
                  onPressed: () =>
                      _editShortcut(context, provider, entry.key, entry.value),
                  icon: Icon(Icons.edit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
