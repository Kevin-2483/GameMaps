import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_preferences_provider.dart';

/// 快捷键列表对话框组件
class ShortcutsDialog extends StatelessWidget {
  const ShortcutsDialog({super.key});

  /// 显示快捷键对话框
  static void show(BuildContext context) {
    showDialog(context: context, builder: (context) => const ShortcutsDialog());
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = context.read<UserPreferencesProvider>();
    final shortcuts = userPrefs.mapEditor.shortcuts;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.keyboard, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('快捷键列表'),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本操作
              _buildShortcutCategory(
                '基本操作',
                {
                  'undo': '撤销',
                  'redo': '重做',
                  'save': '保存',
                  'clearLayerSelection': '清除选择',
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 界面控制
              _buildShortcutCategory(
                '界面控制',
                {
                  'toggleSidebar': '切换侧边栏',
                  'openZInspector': '打开Z层级检视器',
                  'toggleLegendGroupDrawer': '切换图例组抽屉',
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 图层操作
              _buildShortcutCategory(
                '图层操作',
                {
                  'prevLayer': '上一个图层',
                  'nextLayer': '下一个图层',
                  'hideOtherLayers': '隐藏其他图层',
                  'hideOtherLayerGroups': '隐藏其他图层组',
                  'showCurrentLayer': '显示当前图层',
                  'showCurrentLayerGroup': '显示当前图层组',
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 图例操作
              _buildShortcutCategory(
                '图例操作',
                {
                  'prevLegendGroup': '上一个图例组',
                  'nextLegendGroup': '下一个图例组',
                  'openLegendDrawer': '打开图例组绑定抽屉',
                  'hideOtherLegendGroups': '隐藏其他图例组',
                  'showCurrentLegendGroup': '显示当前图例组',
                },
                shortcuts,
                context,
              ),
              _buildShortcutCategory(
                '帮助',
                {'showShortcuts': '显示快捷键列表'},
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 版本管理
              _buildShortcutCategory(
                '版本管理',
                {
                  'prevVersion': '上一个版本',
                  'nextVersion': '下一个版本',
                  'createNewVersion': '创建新版本',
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 快速选择
              _buildShortcutCategory(
                '快速选择 (图层组)',
                {
                  'selectLayerGroup1': '选择图层组 1',
                  'selectLayerGroup2': '选择图层组 2',
                  'selectLayerGroup3': '选择图层组 3',
                  'selectLayerGroup4': '选择图层组 4',
                  'selectLayerGroup5': '选择图层组 5',
                  'selectLayerGroup6': '选择图层组 6',
                  'selectLayerGroup7': '选择图层组 7',
                  'selectLayerGroup8': '选择图层组 8',
                  'selectLayerGroup9': '选择图层组 9',
                  'selectLayerGroup10': '选择图层组 10',
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 快速选择图层
              _buildShortcutCategory(
                '快速选择 (图层)',
                {
                  'selectLayer1': '选择图层 1',
                  'selectLayer2': '选择图层 2',
                  'selectLayer3': '选择图层 3',
                  'selectLayer4': '选择图层 4',
                  'selectLayer5': '选择图层 5',
                  'selectLayer6': '选择图层 6',
                  'selectLayer7': '选择图层 7',
                  'selectLayer8': '选择图层 8',
                  'selectLayer9': '选择图层 9',
                  'selectLayer10': '选择图层 10',
                  'selectLayer11': '选择图层 11',
                  'selectLayer12': '选择图层 12',
                },
                shortcuts,
                context,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  /// 构建快捷键分类
  Widget _buildShortcutCategory(
    String categoryName,
    Map<String, String> categoryShortcuts,
    Map<String, List<String>> allShortcuts,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...categoryShortcuts.entries.map((entry) {
          final shortcutKey = entry.key;
          final description = entry.value;
          final keys = allShortcuts[shortcutKey] ?? [];

          return _buildShortcutRow(description, keys, context);
        }).toList(),
      ],
    );
  }

  /// 构建快捷键行
  Widget _buildShortcutRow(
    String description,
    List<String> shortcuts,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(child: _buildShortcutChips(shortcuts, context)),
        ],
      ),
    );
  }

  /// 构建快捷键芯片（使用与设置页面相同的样式）
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

  /// 构建按键芯片列表
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

  /// 构建单个按键芯片
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

  /// 构建按键内容（图标或文本）
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

  /// 获取按键颜色
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

  /// 获取按键显示名称
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
}
