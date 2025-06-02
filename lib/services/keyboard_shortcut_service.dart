import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../models/user_preferences.dart';

/// 键盘快捷键处理服务
class KeyboardShortcutService {
  /// 检查按键组合是否匹配指定的快捷键
  /// 
  /// [event] - 键盘事件
  /// [shortcut] - 快捷键字符串（如 'Ctrl+C', 'Ctrl+Shift+S'）
  static bool isShortcutPressed(KeyEvent event, String shortcut) {
    if (event is! KeyDownEvent) return false;
    
    final parts = shortcut.toLowerCase().split('+');
    final key = parts.last;
    final modifiers = parts.take(parts.length - 1).toList();
    
    // 检查主键
    bool keyMatch = false;
    switch (key) {
      case 'c':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyC;
        break;
      case 'v':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyV;
        break;
      case 'x':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyX;
        break;
      case 'z':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyZ;
        break;
      case 'y':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyY;
        break;
      case 's':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyS;
        break;
      case 'a':
        keyMatch = event.logicalKey == LogicalKeyboardKey.keyA;
        break;
      // 可以根据需要添加更多键
      default:
        return false;
    }
    
    if (!keyMatch) return false;
    
    // 检查修饰键
    bool ctrlRequired = modifiers.contains('ctrl');
    bool shiftRequired = modifiers.contains('shift');
    bool altRequired = modifiers.contains('alt');
    
    bool ctrlPressed = HardwareKeyboard.instance.isControlPressed;
    bool shiftPressed = HardwareKeyboard.instance.isShiftPressed;
    bool altPressed = HardwareKeyboard.instance.isAltPressed;
    
    return (ctrlRequired == ctrlPressed) &&
           (shiftRequired == shiftPressed) &&
           (altRequired == altPressed);
  }
  
  /// 从用户偏好设置获取快捷键配置
  static String? getShortcutForAction(ToolPreferences toolPrefs, String action) {
    return toolPrefs.shortcuts[action];
  }
  
  /// 检查是否按下了复制快捷键
  static bool isCopyPressed(KeyEvent event, ToolPreferences toolPrefs) {
    final copyShortcut = getShortcutForAction(toolPrefs, 'copy');
    if (copyShortcut == null) return false;
    return isShortcutPressed(event, copyShortcut);
  }
  
  /// 检查是否按下了撤销快捷键
  static bool isUndoPressed(KeyEvent event, ToolPreferences toolPrefs) {
    final undoShortcut = getShortcutForAction(toolPrefs, 'undo');
    if (undoShortcut == null) return false;
    return isShortcutPressed(event, undoShortcut);
  }
  
  /// 检查是否按下了重做快捷键
  static bool isRedoPressed(KeyEvent event, ToolPreferences toolPrefs) {
    final redoShortcut = getShortcutForAction(toolPrefs, 'redo');
    if (redoShortcut == null) return false;
    return isShortcutPressed(event, redoShortcut);
  }
}
