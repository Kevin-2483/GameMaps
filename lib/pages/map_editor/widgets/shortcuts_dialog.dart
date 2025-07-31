// This file has been processed by AI for internationalization
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

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
          Text(LocalizationService.instance.current.shortcutList_4821),
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
                LocalizationService.instance.current.basicOperations_4821,
                {
                  'undo': LocalizationService.instance.current.undo_4822,
                  'redo': LocalizationService.instance.current.redo_4823,
                  'save': LocalizationService.instance.current.save_4824,
                  'clearLayerSelection':
                      LocalizationService.instance.current.clearSelection_4825,
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 界面控制
              _buildShortcutCategory(
                LocalizationService.instance.current.uiControl_4821,
                {
                  'toggleSidebar':
                      LocalizationService.instance.current.toggleSidebar_4822,
                  'openZInspector':
                      LocalizationService.instance.current.openZInspector_4823,
                  'toggleLegendGroupDrawer': LocalizationService
                      .instance
                      .current
                      .toggleLegendGroupDrawer_4824,
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 图层操作
              _buildShortcutCategory(
                LocalizationService.instance.current.layerOperations_4821,
                {
                  'prevLayer':
                      LocalizationService.instance.current.previousLayer_4822,
                  'nextLayer':
                      LocalizationService.instance.current.nextLayer_4823,
                  'prevLayerGroup': LocalizationService
                      .instance
                      .current
                      .previousLayerGroup_4824,
                  'nextLayerGroup':
                      LocalizationService.instance.current.nextLayerGroup_4825,
                  'hideOtherLayers':
                      LocalizationService.instance.current.hideOtherLayers_4826,
                  'hideOtherLayerGroups': LocalizationService
                      .instance
                      .current
                      .hideOtherLayerGroups_4827,
                  'showCurrentLayer': LocalizationService
                      .instance
                      .current
                      .showCurrentLayer_4828,
                  'showCurrentLayerGroup': LocalizationService
                      .instance
                      .current
                      .showCurrentLayerGroup_4829,
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 图例操作
              _buildShortcutCategory(
                LocalizationService.instance.current.legendOperations_4821,
                {
                  'prevLegendGroup': LocalizationService
                      .instance
                      .current
                      .previousLegendGroup_4822,
                  'nextLegendGroup':
                      LocalizationService.instance.current.nextLegendGroup_4823,
                  'openLegendDrawer': LocalizationService
                      .instance
                      .current
                      .openLegendDrawer_4824,
                  'hideOtherLegendGroups': LocalizationService
                      .instance
                      .current
                      .hideOtherLegendGroups_4825,
                  'showCurrentLegendGroup': LocalizationService
                      .instance
                      .current
                      .showCurrentLegendGroup_4826,
                },
                shortcuts,
                context,
              ),
              _buildShortcutCategory(
                LocalizationService.instance.current.help_7282,
                {
                  'showShortcuts': LocalizationService
                      .instance
                      .current
                      .showShortcutsList_7281,
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 版本管理
              _buildShortcutCategory(
                LocalizationService.instance.current.versionManagement_4821,
                {
                  'prevVersion':
                      LocalizationService.instance.current.previousVersion_4822,
                  'nextVersion':
                      LocalizationService.instance.current.nextVersion_4823,
                  'createNewVersion': LocalizationService
                      .instance
                      .current
                      .createNewVersion_4824,
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 快速选择
              _buildShortcutCategory(
                LocalizationService.instance.current.quickSelectLayerGroup,
                {
                  'selectLayerGroup1':
                      LocalizationService.instance.current.selectLayerGroup1,
                  'selectLayerGroup2':
                      LocalizationService.instance.current.selectLayerGroup2,
                  'selectLayerGroup3':
                      LocalizationService.instance.current.selectLayerGroup3,
                  'selectLayerGroup4':
                      LocalizationService.instance.current.selectLayerGroup4,
                  'selectLayerGroup5':
                      LocalizationService.instance.current.selectLayerGroup5,
                  'selectLayerGroup6':
                      LocalizationService.instance.current.selectLayerGroup6,
                  'selectLayerGroup7':
                      LocalizationService.instance.current.selectLayerGroup7,
                  'selectLayerGroup8':
                      LocalizationService.instance.current.selectLayerGroup8,
                  'selectLayerGroup9':
                      LocalizationService.instance.current.selectLayerGroup9,
                  'selectLayerGroup10':
                      LocalizationService.instance.current.selectLayerGroup10,
                },
                shortcuts,
                context,
              ),
              const SizedBox(height: 16),

              // 快速选择图层
              _buildShortcutCategory(
                LocalizationService
                    .instance
                    .current
                    .quickSelectLayerCategory_4821,
                {
                  'selectLayer1':
                      LocalizationService.instance.current.selectLayer1_4822,
                  'selectLayer2':
                      LocalizationService.instance.current.selectLayer2_4823,
                  'selectLayer3':
                      LocalizationService.instance.current.selectLayer3_4824,
                  'selectLayer4':
                      LocalizationService.instance.current.selectLayer4_4825,
                  'selectLayer5':
                      LocalizationService.instance.current.selectLayer5_4826,
                  'selectLayer6':
                      LocalizationService.instance.current.selectLayer6_4827,
                  'selectLayer7':
                      LocalizationService.instance.current.selectLayer7_4828,
                  'selectLayer8':
                      LocalizationService.instance.current.selectLayer8_4829,
                  'selectLayer9':
                      LocalizationService.instance.current.selectLayer9_4830,
                  'selectLayer10':
                      LocalizationService.instance.current.selectLayer10_4831,
                  'selectLayer11':
                      LocalizationService.instance.current.selectLayer11_4832,
                  'selectLayer12':
                      LocalizationService.instance.current.selectLayer12_4833,
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
          child: Text(LocalizationService.instance.current.closeButton_7421),
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
        LocalizationService.instance.current.notSet_7281,
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
