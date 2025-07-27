import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/user_preferences.dart';
import '../widgets/shortcuts_dialog.dart';

/// 地图编辑器键盘快捷键管理器
class KeyboardShortcutsManager {
  /// 处理键盘事件的主入口
  static KeyEventResult handleKeyEvent(
    FocusNode node,
    RawKeyEvent event,
    BuildContext context,
    MapEditorPreferences mapEditorPrefs,
    bool isInputFieldFocused,
    KeyboardShortcutCallbacks callbacks,
  ) {
    // 只处理按键按下事件
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // 如果输入框正在被编辑，忽略快捷键
    if (isInputFieldFocused) {
      debugPrint(
        'DEBUG: Ignoring shortcut because _isInputFieldFocused is true',
      );
      return KeyEventResult.ignored;
    }
    debugPrint(
      'DEBUG: Processing shortcut because _isInputFieldFocused is false',
    );

    final copyShortcuts =
        mapEditorPrefs.shortcuts['copy'] ?? ['Ctrl+C', 'Win+C'];
    final undoShortcuts =
        mapEditorPrefs.shortcuts['undo'] ?? ['Ctrl+Z', 'Win+Z'];
    final redoShortcuts =
        mapEditorPrefs.shortcuts['redo'] ?? ['Ctrl+Y', 'Win+Y'];

    // 检查撤销快捷键
    if (_isAnyShortcutPressed(event, undoShortcuts)) {
      if (callbacks.canUndo()) {
        callbacks.undo();
        return KeyEventResult.handled;
      }
    }

    // 检查重做快捷键
    if (_isAnyShortcutPressed(event, redoShortcuts)) {
      if (callbacks.canRedo()) {
        callbacks.redo();
        return KeyEventResult.handled;
      }
    }

    // 检查复制快捷键
    if (_isAnyShortcutPressed(event, copyShortcuts)) {
      callbacks.handleCopySelection();
      return KeyEventResult.handled;
    }

    // 检查地图编辑器快捷键
    if (_handleMapEditorShortcuts(event, mapEditorPrefs, context, callbacks)) {
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// 处理地图编辑器快捷键
  static bool _handleMapEditorShortcuts(
    RawKeyEvent event,
    MapEditorPreferences mapEditorPrefs,
    BuildContext context,
    KeyboardShortcutCallbacks callbacks,
  ) {
    // 检查选择上一个图层
    final prevLayerShortcuts = mapEditorPrefs.shortcuts['prevLayer'] ?? ['P'];
    if (_isAnyShortcutPressed(event, prevLayerShortcuts)) {
      callbacks.selectPreviousLayer();
      return true;
    }

    // 检查选择下一个图层
    final nextLayerShortcuts = mapEditorPrefs.shortcuts['nextLayer'] ?? ['N'];
    if (_isAnyShortcutPressed(event, nextLayerShortcuts)) {
      callbacks.selectNextLayer();
      return true;
    }

    // 检查选择上一个图层组
    final prevLayerGroupShortcuts =
        mapEditorPrefs.shortcuts['prevLayerGroup'] ?? ['Left'];
    if (_isAnyShortcutPressed(event, prevLayerGroupShortcuts)) {
      callbacks.selectPreviousLayerGroup();
      return true;
    }

    // 检查选择下一个图层组
    final nextLayerGroupShortcuts =
        mapEditorPrefs.shortcuts['nextLayerGroup'] ?? ['Right'];
    if (_isAnyShortcutPressed(event, nextLayerGroupShortcuts)) {
      callbacks.selectNextLayerGroup();
      return true;
    }

    // 检查打开上一个图例组
    final prevLegendGroupShortcuts =
        mapEditorPrefs.shortcuts['prevLegendGroup'] ?? ['Up'];
    if (_isAnyShortcutPressed(event, prevLegendGroupShortcuts)) {
      callbacks.openPreviousLegendGroup();
      return true;
    }

    // 检查打开下一个图例组
    final nextLegendGroupShortcuts =
        mapEditorPrefs.shortcuts['nextLegendGroup'] ?? ['Down'];
    if (_isAnyShortcutPressed(event, nextLegendGroupShortcuts)) {
      callbacks.openNextLegendGroup();
      return true;
    }

    // 检查打开图例管理抽屉
    final openLegendDrawerShortcuts =
        mapEditorPrefs.shortcuts['openLegendDrawer'] ?? ['L'];
    if (_isAnyShortcutPressed(event, openLegendDrawerShortcuts)) {
      callbacks.toggleLegendGroupManagementDrawer();
      return true;
    }

    // 检查清除图层/图层组选择
    final clearLayerSelectionShortcuts =
        mapEditorPrefs.shortcuts['clearLayerSelection'] ?? ['Escape'];
    if (_isAnyShortcutPressed(event, clearLayerSelectionShortcuts)) {
      callbacks.clearLayerSelection();
      return true;
    }

    // 保存地图
    final saveShortcuts =
        mapEditorPrefs.shortcuts['save'] ?? ['Ctrl+S', 'Win+S'];
    if (_isAnyShortcutPressed(event, saveShortcuts)) {
      callbacks.saveMap();
      return true;
    }

    // 检查数字键1-0选择图层组
    for (int i = 1; i <= 10; i++) {
      final key = i == 10 ? '0' : i.toString();
      final shortcutKey = 'selectLayerGroup$i';
      final shortcuts = mapEditorPrefs.shortcuts[shortcutKey] ?? [key];
      if (_isAnyShortcutPressed(event, shortcuts)) {
        callbacks.selectLayerGroupByIndex(i - 1); // 索引从0开始
        return true;
      }
    }

    // 检查F1-F12选择图层
    for (int i = 1; i <= 12; i++) {
      final shortcutKey = 'selectLayer$i';
      final shortcuts = mapEditorPrefs.shortcuts[shortcutKey] ?? ['F$i'];
      if (_isAnyShortcutPressed(event, shortcuts)) {
        callbacks.selectLayerByIndex(i - 1); // 索引从0开始
        return true;
      }
    }

    // 检查切换左侧边栏
    final toggleSidebarShortcuts =
        mapEditorPrefs.shortcuts['toggleSidebar'] ?? ['Ctrl+B', 'Win+B'];
    if (_isAnyShortcutPressed(event, toggleSidebarShortcuts)) {
      callbacks.toggleSidebar();
      return true;
    }

    // 检查打开Z元素检视器
    final openZInspectorShortcuts =
        mapEditorPrefs.shortcuts['openZInspector'] ?? ['Z'];
    if (_isAnyShortcutPressed(event, openZInspectorShortcuts)) {
      callbacks.openZInspector();
      return true;
    }

    // 检查切换图例组绑定抽屉
    final toggleLegendGroupDrawerShortcuts =
        mapEditorPrefs.shortcuts['toggleLegendGroupDrawer'] ?? ['G'];
    if (_isAnyShortcutPressed(event, toggleLegendGroupDrawerShortcuts)) {
      callbacks.toggleLegendGroupBindingDrawer();
      return true;
    }

    // 检查隐藏其他图层
    final hideOtherLayersShortcuts =
        mapEditorPrefs.shortcuts['hideOtherLayers'] ?? ['H'];
    if (_isAnyShortcutPressed(event, hideOtherLayersShortcuts)) {
      callbacks.hideOtherLayers();
      return true;
    }

    // 检查隐藏其他图层组
    final hideOtherLayerGroupsShortcuts =
        mapEditorPrefs.shortcuts['hideOtherLayerGroups'] ?? ['Alt+H'];
    if (_isAnyShortcutPressed(event, hideOtherLayerGroupsShortcuts)) {
      callbacks.hideOtherLayerGroups();
      return true;
    }

    // 检查显示当前图层
    final showCurrentLayerShortcuts =
        mapEditorPrefs.shortcuts['showCurrentLayer'] ?? ['S'];
    if (_isAnyShortcutPressed(event, showCurrentLayerShortcuts)) {
      callbacks.showCurrentLayer();
      return true;
    }

    // 检查显示当前图层组
    final showCurrentLayerGroupShortcuts =
        mapEditorPrefs.shortcuts['showCurrentLayerGroup'] ?? ['Alt+S'];
    if (_isAnyShortcutPressed(event, showCurrentLayerGroupShortcuts)) {
      callbacks.showCurrentLayerGroup();
      return true;
    }

    // 检查隐藏其他图例组
    final hideOtherLegendGroupsShortcuts =
        mapEditorPrefs.shortcuts['hideOtherLegendGroups'] ?? ['Ctrl+Alt+H'];
    if (_isAnyShortcutPressed(event, hideOtherLegendGroupsShortcuts)) {
      callbacks.hideOtherLegendGroups();
      return true;
    }

    // 检查显示当前图例组
    final showCurrentLegendGroupShortcuts =
        mapEditorPrefs.shortcuts['showCurrentLegendGroup'] ?? ['Ctrl+Alt+S'];
    if (_isAnyShortcutPressed(event, showCurrentLegendGroupShortcuts)) {
      callbacks.showCurrentLegendGroup();
      return true;
    }

    // 检查切换到上一个版本
    final prevVersionShortcuts =
        mapEditorPrefs.shortcuts['prevVersion'] ?? ['Ctrl+Left', 'Win+Left'];
    if (_isAnyShortcutPressed(event, prevVersionShortcuts)) {
      callbacks.switchToPreviousVersion();
      return true;
    }

    // 检查切换到下一个版本
    final nextVersionShortcuts =
        mapEditorPrefs.shortcuts['nextVersion'] ?? ['Ctrl+Right', 'Win+Right'];
    if (_isAnyShortcutPressed(event, nextVersionShortcuts)) {
      callbacks.switchToNextVersion();
      return true;
    }

    // 检查新增版本
    final createNewVersionShortcuts =
        mapEditorPrefs.shortcuts['createNewVersion'] ?? ['Ctrl+N', 'Win+N'];
    if (_isAnyShortcutPressed(event, createNewVersionShortcuts)) {
      callbacks.createNewVersionWithShortcut();
      return true;
    }

    // 检查显示快捷键列表
    final showShortcutsShortcuts =
        mapEditorPrefs.shortcuts['showShortcuts'] ?? ['/', '/'];
    if (_isAnyShortcutPressed(event, showShortcutsShortcuts)) {
      ShortcutsDialog.show(context);
      return true;
    }

    return false;
  }

  /// 检查是否按下了指定的快捷键
  static bool _isShortcutPressed(RawKeyEvent event, String shortcut) {
    final parts = shortcut.toLowerCase().split('+');
    final key = parts.last;
    final modifiers = parts.take(parts.length - 1).toList();

    // 动态获取按键对应的LogicalKeyboardKey
    LogicalKeyboardKey? targetKey = _getLogicalKeyFromString(key);
    if (targetKey == null) {
      debugPrint('不支持的按键: $key');
      return false;
    }

    // 检查主键是否匹配
    bool keyMatch = event.logicalKey == targetKey;
    if (!keyMatch) {
      return false;
    }

    // 检查修饰键（统一使用不分左右的名称，支持多种格式）
    bool ctrlRequired =
        modifiers.contains('control') || modifiers.contains('ctrl');
    bool shiftRequired = modifiers.contains('shift');
    bool altRequired = modifiers.contains('alt');
    bool winRequired =
        modifiers.contains('super') ||
        modifiers.contains('win') ||
        modifiers.contains('meta') ||
        modifiers.contains('command');

    bool ctrlPressed = event.isControlPressed;
    bool shiftPressed = event.isShiftPressed;
    bool altPressed = event.isAltPressed;
    bool winPressed = event.isMetaPressed;

    // 严格检查修饰键状态：所有修饰键都必须匹配
    // 如果快捷键不要求修饰键，那么当前也不能有修饰键按下
    // 如果快捷键要求修饰键，那么对应的修饰键必须按下，其他修饰键不能按下
    bool result =
        keyMatch &&
        (ctrlRequired == ctrlPressed) &&
        (shiftRequired == shiftPressed) &&
        (altRequired == altPressed) &&
        (winRequired == winPressed);

    debugPrint(
      '快捷键检查: $shortcut, 主键匹配: $keyMatch, 修饰键匹配: ${(ctrlRequired == ctrlPressed) && (shiftRequired == shiftPressed) && (altRequired == altPressed) && (winRequired == winPressed)}, 最终结果: $result',
    );
    return result;
  }

  /// 检查是否按下了任意一个指定的快捷键
  static bool _isAnyShortcutPressed(RawKeyEvent event, List<String> shortcuts) {
    for (final shortcut in shortcuts) {
      if (_isShortcutPressed(event, shortcut)) {
        return true;
      }
    }
    return false;
  }

  /// 根据字符串获取对应的LogicalKeyboardKey
  static LogicalKeyboardKey? _getLogicalKeyFromString(String key) {
    switch (key) {
      // 字母键
      case 'a':
        return LogicalKeyboardKey.keyA;
      case 'b':
        return LogicalKeyboardKey.keyB;
      case 'c':
        return LogicalKeyboardKey.keyC;
      case 'd':
        return LogicalKeyboardKey.keyD;
      case 'e':
        return LogicalKeyboardKey.keyE;
      case 'f':
        return LogicalKeyboardKey.keyF;
      case 'g':
        return LogicalKeyboardKey.keyG;
      case 'h':
        return LogicalKeyboardKey.keyH;
      case 'i':
        return LogicalKeyboardKey.keyI;
      case 'j':
        return LogicalKeyboardKey.keyJ;
      case 'k':
        return LogicalKeyboardKey.keyK;
      case 'l':
        return LogicalKeyboardKey.keyL;
      case 'm':
        return LogicalKeyboardKey.keyM;
      case 'n':
        return LogicalKeyboardKey.keyN;
      case 'o':
        return LogicalKeyboardKey.keyO;
      case 'p':
        return LogicalKeyboardKey.keyP;
      case 'q':
        return LogicalKeyboardKey.keyQ;
      case 'r':
        return LogicalKeyboardKey.keyR;
      case 's':
        return LogicalKeyboardKey.keyS;
      case 't':
        return LogicalKeyboardKey.keyT;
      case 'u':
        return LogicalKeyboardKey.keyU;
      case 'v':
        return LogicalKeyboardKey.keyV;
      case 'w':
        return LogicalKeyboardKey.keyW;
      case 'x':
        return LogicalKeyboardKey.keyX;
      case 'y':
        return LogicalKeyboardKey.keyY;
      case 'z':
        return LogicalKeyboardKey.keyZ;

      // 数字键
      case '0':
        return LogicalKeyboardKey.digit0;
      case '1':
        return LogicalKeyboardKey.digit1;
      case '2':
        return LogicalKeyboardKey.digit2;
      case '3':
        return LogicalKeyboardKey.digit3;
      case '4':
        return LogicalKeyboardKey.digit4;
      case '5':
        return LogicalKeyboardKey.digit5;
      case '6':
        return LogicalKeyboardKey.digit6;
      case '7':
        return LogicalKeyboardKey.digit7;
      case '8':
        return LogicalKeyboardKey.digit8;
      case '9':
        return LogicalKeyboardKey.digit9;

      // 方向键
      case 'up':
        return LogicalKeyboardKey.arrowUp;
      case 'down':
        return LogicalKeyboardKey.arrowDown;
      case 'left':
        return LogicalKeyboardKey.arrowLeft;
      case 'right':
        return LogicalKeyboardKey.arrowRight;

      // 功能键
      case 'f1':
        return LogicalKeyboardKey.f1;
      case 'f2':
        return LogicalKeyboardKey.f2;
      case 'f3':
        return LogicalKeyboardKey.f3;
      case 'f4':
        return LogicalKeyboardKey.f4;
      case 'f5':
        return LogicalKeyboardKey.f5;
      case 'f6':
        return LogicalKeyboardKey.f6;
      case 'f7':
        return LogicalKeyboardKey.f7;
      case 'f8':
        return LogicalKeyboardKey.f8;
      case 'f9':
        return LogicalKeyboardKey.f9;
      case 'f10':
        return LogicalKeyboardKey.f10;
      case 'f11':
        return LogicalKeyboardKey.f11;
      case 'f12':
        return LogicalKeyboardKey.f12;

      // 特殊键
      case 'escape':
        return LogicalKeyboardKey.escape;
      case 'tab':
        return LogicalKeyboardKey.tab;
      case 'space':
        return LogicalKeyboardKey.space;
      case 'enter':
        return LogicalKeyboardKey.enter;
      case 'backspace':
        return LogicalKeyboardKey.backspace;
      case 'delete':
        return LogicalKeyboardKey.delete;
      case 'home':
        return LogicalKeyboardKey.home;
      case 'end':
        return LogicalKeyboardKey.end;
      case 'pageup':
        return LogicalKeyboardKey.pageUp;
      case 'pagedown':
        return LogicalKeyboardKey.pageDown;
      case 'insert':
        return LogicalKeyboardKey.insert;

      // 符号键
      case '-':
        return LogicalKeyboardKey.minus;
      case '=':
        return LogicalKeyboardKey.equal;
      case '[':
        return LogicalKeyboardKey.bracketLeft;
      case ']':
        return LogicalKeyboardKey.bracketRight;
      case '\\':
        return LogicalKeyboardKey.backslash;
      case ';':
        return LogicalKeyboardKey.semicolon;
      case '\'':
        return LogicalKeyboardKey.quote;
      case '`':
        return LogicalKeyboardKey.backquote;
      case ',':
        return LogicalKeyboardKey.comma;
      case '.':
        return LogicalKeyboardKey.period;
      case '/':
        return LogicalKeyboardKey.slash;

      default:
        return null;
    }
  }
}

/// 快捷键回调接口
abstract class KeyboardShortcutCallbacks {
  // 撤销/重做相关
  bool canUndo();
  bool canRedo();
  void undo();
  void redo();
  void handleCopySelection();

  // 图层相关
  void selectPreviousLayer();
  void selectNextLayer();
  void selectPreviousLayerGroup();
  void selectNextLayerGroup();
  void selectLayerGroupByIndex(int index);
  void selectLayerByIndex(int index);
  void clearLayerSelection();
  void hideOtherLayers();
  void hideOtherLayerGroups();
  void showCurrentLayer();
  void showCurrentLayerGroup();

  // 图例相关
  void openPreviousLegendGroup();
  void openNextLegendGroup();
  void toggleLegendGroupManagementDrawer();
  void toggleLegendGroupBindingDrawer();
  void hideOtherLegendGroups();
  void showCurrentLegendGroup();

  // UI相关
  void toggleSidebar();
  void openZInspector();

  // 地图相关
  void saveMap();

  // 版本相关
  void switchToPreviousVersion();
  void switchToNextVersion();
  void createNewVersionWithShortcut();
}
