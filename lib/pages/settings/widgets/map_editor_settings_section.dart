import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../widgets/key_capture_widget.dart';
import '../../../services/notification/notification_service.dart';

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
      // 新增的快捷键功能
      case 'toggleSidebar':
        return '切换左侧边栏';
      case 'openZInspector':
        return '打开Z元素检视器';
      case 'toggleLegendGroupDrawer':
        return '切换图例组绑定抽屉';
      case 'hideOtherLayers':
        return '隐藏其他图层';
      case 'hideOtherLayerGroups':
        return '隐藏其他图层组';
      case 'showCurrentLayer':
        return '显示当前图层';
      case 'showCurrentLayerGroup':
        return '显示当前图层组';
      case 'hideOtherLegendGroups':
        return '隐藏其他图例组';
      case 'showCurrentLegendGroup':
        return '显示当前图例组';
      // 版本管理快捷键
      case 'prevVersion':
        return '切换到上一个版本';
      case 'nextVersion':
        return '切换到下一个版本';
      case 'createNewVersion':
        return '新增版本';
      default:
        return shortcut;
    }
  }

  /// 构建快捷键chip显示
  Widget _buildShortcutChips(List<String> shortcuts, BuildContext context) {
    if (shortcuts.isEmpty) {
      return Text(
        '未设置',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
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
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _buildKeyChips(keys, context),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildKeyChips(List<String> keys, BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < keys.length; i++) {
      if (i > 0) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.add,
              size: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
      widgets.add(_buildKeyChip(keys[i], context));
    }
    return widgets;
  }

  Widget _buildKeyChip(String key, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getKeyColor(key, context),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: _buildKeyContent(key, context),
    );
  }

  Widget _buildKeyContent(String key, BuildContext context) {
    // 为特殊键显示图标
    switch (key.toLowerCase()) {
      case 'meta':
      case 'win':
        if (Platform.isMacOS) {
          return Icon(
            Icons.keyboard_command_key,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface,
          );
        }
        break;
      case 'control':
      case 'ctrl':
        if (Platform.isMacOS) {
          return Icon(
            Icons.keyboard_control_key,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface,
          );
        }
        break;
      case 'alt':
        if (Platform.isMacOS) {
          return Icon(
            Icons.keyboard_option_key,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface,
          );
        }
        break;
      case 'shift':
        return Icon(
          Icons.north,
          size: 12,
          color: Theme.of(context).colorScheme.onSurface,
        );
      case 'capslock':
        return Icon(
          Icons.upgrade,
          size: 12,
          color: Theme.of(context).colorScheme.onSurface,
        );
      case 'tab':
        return Icon(
          Icons.keyboard_tab,
          size: 12,
          color: Theme.of(context).colorScheme.onSurface,
        );
      case 'space':
        return Icon(
          Icons.space_bar,
          size: 12,
          color: Theme.of(context).colorScheme.onSurface,
        );
      case 'escape':
        return Icon(
          Icons.keyboard_return,
          size: 12,
          color: Theme.of(context).colorScheme.onSurface,
        );
    }
    
    // 对于其他键，显示文本
    return Text(
      _getKeyDisplayName(key),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Color _getKeyColor(String key, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (key.toLowerCase()) {
      case 'control':
      case 'ctrl':
      case 'shift':
      case 'alt':
      case 'meta':
      case 'win':
      case 'capslock':
        return colorScheme.tertiaryContainer;
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
        return colorScheme.secondaryContainer;
      case 'arrowup':
      case 'arrowdown':
      case 'arrowleft':
      case 'arrowright':
        return colorScheme.primaryContainer;
      case 'space':
      case 'enter':
      case 'tab':
      case 'escape':
      case 'backspace':
      case 'delete':
        return colorScheme.surfaceVariant;
      default:
        return colorScheme.surface;
    }
  }

  String _getKeyDisplayName(String key) {
    switch (key.toLowerCase()) {
      case 'control':
      case 'ctrl':
        return Platform.isMacOS ? 'Control' : 'Ctrl';
      case 'shift':
        return 'Shift';
      case 'alt':
        return Platform.isMacOS ? 'Option' : 'Alt';
      case 'meta':
      case 'win':
        if (Platform.isMacOS) {
          return 'Command';
        } else if (Platform.isLinux) {
          return 'Super';
        } else {
          return 'Win';
        }
      case 'capslock':
        return 'CapsLock';
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

  /// 标准化快捷键字符串，统一处理修饰键的不同表示
  String _normalizeShortcut(String shortcut) {
    return shortcut.replaceAll('Control', 'Ctrl').replaceAll('Meta', 'Win');
  }

  /// 检查快捷键冲突
  /// 返回冲突的动作名称，如果没有冲突返回null
  String? _checkShortcutConflict(
    String shortcut,
    String currentAction,
    Map<String, List<String>> allShortcuts,
  ) {
    final normalizedShortcut = _normalizeShortcut(shortcut);
    // 定义受保护的快捷键（数字键1-0和F1-F12）
    // final protectedShortcuts = {
    //   '1': 'selectLayerGroup1',
    //   '2': 'selectLayerGroup2',
    //   '3': 'selectLayerGroup3',
    //   '4': 'selectLayerGroup4',
    //   '5': 'selectLayerGroup5',
    //   '6': 'selectLayerGroup6',
    //   '7': 'selectLayerGroup7',
    //   '8': 'selectLayerGroup8',
    //   '9': 'selectLayerGroup9',
    //   '0': 'selectLayerGroup10',
    //   'F1': 'selectLayer1',
    //   'F2': 'selectLayer2',
    //   'F3': 'selectLayer3',
    //   'F4': 'selectLayer4',
    //   'F5': 'selectLayer5',
    //   'F6': 'selectLayer6',
    //   'F7': 'selectLayer7',
    //   'F8': 'selectLayer8',
    //   'F9': 'selectLayer9',
    //   'F10': 'selectLayer10',
    //   'F11': 'selectLayer11',
    //   'F12': 'selectLayer12',
    // };

    // // 检查是否与受保护的快捷键冲突
    // if (protectedShortcuts.containsKey(shortcut)) {
    //   final protectedAction = protectedShortcuts[shortcut]!;
    //   if (currentAction != protectedAction) {
    //     return protectedAction;
    //   }
    // }

    // 检查是否与其他已设置的快捷键冲突
    for (final entry in allShortcuts.entries) {
      if (entry.key != currentAction) {
        for (final existingShortcut in entry.value) {
          if (_normalizeShortcut(existingShortcut) == normalizedShortcut) {
            return entry.key;
          }
        }
      }
    }

    return null;
  }

  /// 显示快捷键管理弹窗
  void _showShortcutManagementDialog(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('快捷键管理'),
        content: SizedBox(
          width: 600,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '点击编辑按钮可以修改对应功能的快捷键',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ...provider.currentPreferences!.mapEditor.shortcuts.entries.map(
                  (entry) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(_getShortcutDisplayName(entry.key)),
                      subtitle: _buildShortcutChips(entry.value, context),
                      trailing: IconButton(
                        onPressed: () => _editShortcut(
                          context,
                          provider,
                          entry.key,
                          entry.value,
                        ),
                        icon: Icon(Icons.edit),
                        tooltip: '编辑快捷键',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 编辑快捷键
  void _editShortcut(
    BuildContext context,
    UserPreferencesProvider provider,
    String action,
    List<String> currentShortcuts,
  ) {
    List<String> newShortcuts = List.from(currentShortcuts);
    String tempShortcut = '';
    final GlobalKey<KeyCaptureWidgetState> keyCaptureKey =
        GlobalKey<KeyCaptureWidgetState>();

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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (newShortcuts.isEmpty)
                  Text(
                    '未设置',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: newShortcuts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final shortcut = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              shortcut,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  newShortcuts.removeAt(index);
                                });
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                Text(
                  '添加新快捷键:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击下方区域，然后按下您想要添加的快捷键组合',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                KeyCaptureWidget(
                  key: keyCaptureKey,
                  initialValue: '',
                  onKeyCaptured: (value) {
                    tempShortcut = value;
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (tempShortcut.isEmpty) {
                      context.showInfoSnackBar('请先按下快捷键组合');
                      return;
                    }

                    // 检查是否在当前列表中重复
                    final normalizedTemp = _normalizeShortcut(tempShortcut);
                    bool isDuplicate = false;
                    for (final existing in newShortcuts) {
                      if (_normalizeShortcut(existing) == normalizedTemp) {
                        isDuplicate = true;
                        break;
                      }
                    }
                    if (isDuplicate) {
                      context.showInfoSnackBar('快捷键重复: $tempShortcut 已在当前列表中');
                      return;
                    }

                    // 检查快捷键冲突
                    final conflictResult = _checkShortcutConflict(
                      tempShortcut,
                      action,
                      provider.currentPreferences!.mapEditor.shortcuts,
                    );
                    if (conflictResult != null) {
                      // 显示冲突警告
                      context.showErrorSnackBar(
                        '快捷键冲突: $tempShortcut 已被 "${_getShortcutDisplayName(conflictResult)}" 使用',
                      );
                      return;
                    }

                    setState(() {
                      newShortcuts.add(tempShortcut);
                      tempShortcut = '';
                    });
                    // 清空KeyCaptureWidget的预览框
                    keyCaptureKey.currentState?.clearCapturedKeys();
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
                  final normalized = _normalizeShortcut(shortcut);
                  if (seen.contains(normalized)) {
                    duplicates.add(shortcut);
                  } else {
                    seen.add(normalized);
                  }
                }

                if (duplicates.isNotEmpty) {
                  context.showInfoSnackBar(
                    '列表中存在重复快捷键: ${duplicates.join(", ")}',
                  );
                  return;
                }

                // 检查所有快捷键是否与其他功能冲突
                bool hasConflict = false;
                String? conflictMessage;

                for (final shortcut in newShortcuts) {
                  final conflictResult = _checkShortcutConflict(
                    shortcut,
                    action,
                    provider.currentPreferences!.mapEditor.shortcuts,
                  );
                  if (conflictResult != null) {
                    hasConflict = true;
                    conflictMessage =
                        '快捷键冲突: $shortcut 已被 "${_getShortcutDisplayName(conflictResult)}" 使用';
                    break;
                  }
                }

                if (hasConflict) {
                  context.showErrorSnackBar(conflictMessage!);
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
                  DropdownMenuItem(value: 2, child: Text('右键')),
                  DropdownMenuItem(value: 4, child: Text('中键')),
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
              title: Text('背景不透明度'),
              subtitle: Slider(
                value: mapEditor.radialMenuBackgroundOpacity,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label:
                    '${(mapEditor.radialMenuBackgroundOpacity * 100).round()}%',
                onChanged: (value) => provider.updateMapEditor(
                  radialMenuBackgroundOpacity: value,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 轮盘菜单对象透明度
            ListTile(
              title: Text('对象不透明度'),
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
                onChanged: (value) => provider.updateMapEditor(
                  radialMenuReturnDelay: value.round(),
                ),
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
                onChanged: (value) => provider.updateMapEditor(
                  radialMenuAnimationDuration: value.round(),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 轮盘菜单子菜单延迟
            ListTile(
              title: Text('子菜单延迟'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    value: mapEditor.radialMenuSubMenuDelay.toDouble(),
                    min: 0.0,
                    max: 200.0,
                    divisions: 20,
                    label: mapEditor.radialMenuSubMenuDelay == 0 
                        ? '立即进入' 
                        : '${mapEditor.radialMenuSubMenuDelay}ms',
                    onChanged: (value) => provider.updateMapEditor(
                      radialMenuSubMenuDelay: value.round(),
                    ),
                  ),
                  Text(
                    mapEditor.radialMenuSubMenuDelay == 0 
                        ? '立即进入子菜单' 
                        : '鼠标停止移动${mapEditor.radialMenuSubMenuDelay}ms后进入子菜单',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
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

            // 快捷键设置按钮
            ListTile(
              title: Text('管理快捷键'),
              subtitle: Text('点击查看和编辑所有快捷键设置'),
              trailing: Icon(Icons.keyboard),
              onTap: () => _showShortcutManagementDialog(context, provider),
            ),
          ],
        ),
      ),
    );
  }
}
