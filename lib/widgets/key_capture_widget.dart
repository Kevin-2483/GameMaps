import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyCaptureWidget extends StatefulWidget {
  final Function(String) onKeyCaptured;
  final String? initialValue;

  const KeyCaptureWidget({
    Key? key,
    required this.onKeyCaptured,
    this.initialValue,
  }) : super(key: key);

  @override
  KeyCaptureWidgetState createState() => KeyCaptureWidgetState();
}

class KeyCaptureWidgetState extends State<KeyCaptureWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isCapturing = false;
  List<String> _capturedKeys = [];
  Set<LogicalKeyboardKey> _pressedKeys = {};

  /// 清空预览框内容
  void clearCapturedKeys() {
    setState(() {
      _capturedKeys.clear();
      _isCapturing = false;
    });
    _focusNode.unfocus();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _capturedKeys = widget.initialValue!.split('+');
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// 将LogicalKeyboardKey转换为字符串表示
  String _getKeyString(LogicalKeyboardKey key) {
    // 字母键
    if (key == LogicalKeyboardKey.keyA) return 'A';
    if (key == LogicalKeyboardKey.keyB) return 'B';
    if (key == LogicalKeyboardKey.keyC) return 'C';
    if (key == LogicalKeyboardKey.keyD) return 'D';
    if (key == LogicalKeyboardKey.keyE) return 'E';
    if (key == LogicalKeyboardKey.keyF) return 'F';
    if (key == LogicalKeyboardKey.keyG) return 'G';
    if (key == LogicalKeyboardKey.keyH) return 'H';
    if (key == LogicalKeyboardKey.keyI) return 'I';
    if (key == LogicalKeyboardKey.keyJ) return 'J';
    if (key == LogicalKeyboardKey.keyK) return 'K';
    if (key == LogicalKeyboardKey.keyL) return 'L';
    if (key == LogicalKeyboardKey.keyM) return 'M';
    if (key == LogicalKeyboardKey.keyN) return 'N';
    if (key == LogicalKeyboardKey.keyO) return 'O';
    if (key == LogicalKeyboardKey.keyP) return 'P';
    if (key == LogicalKeyboardKey.keyQ) return 'Q';
    if (key == LogicalKeyboardKey.keyR) return 'R';
    if (key == LogicalKeyboardKey.keyS) return 'S';
    if (key == LogicalKeyboardKey.keyT) return 'T';
    if (key == LogicalKeyboardKey.keyU) return 'U';
    if (key == LogicalKeyboardKey.keyV) return 'V';
    if (key == LogicalKeyboardKey.keyW) return 'W';
    if (key == LogicalKeyboardKey.keyX) return 'X';
    if (key == LogicalKeyboardKey.keyY) return 'Y';
    if (key == LogicalKeyboardKey.keyZ) return 'Z';

    // 数字键
    if (key == LogicalKeyboardKey.digit0) return '0';
    if (key == LogicalKeyboardKey.digit1) return '1';
    if (key == LogicalKeyboardKey.digit2) return '2';
    if (key == LogicalKeyboardKey.digit3) return '3';
    if (key == LogicalKeyboardKey.digit4) return '4';
    if (key == LogicalKeyboardKey.digit5) return '5';
    if (key == LogicalKeyboardKey.digit6) return '6';
    if (key == LogicalKeyboardKey.digit7) return '7';
    if (key == LogicalKeyboardKey.digit8) return '8';
    if (key == LogicalKeyboardKey.digit9) return '9';

    // 方向键
    if (key == LogicalKeyboardKey.arrowUp) return 'ArrowUp';
    if (key == LogicalKeyboardKey.arrowDown) return 'ArrowDown';
    if (key == LogicalKeyboardKey.arrowLeft) return 'ArrowLeft';
    if (key == LogicalKeyboardKey.arrowRight) return 'ArrowRight';

    // 功能键
    if (key == LogicalKeyboardKey.f1) return 'F1';
    if (key == LogicalKeyboardKey.f2) return 'F2';
    if (key == LogicalKeyboardKey.f3) return 'F3';
    if (key == LogicalKeyboardKey.f4) return 'F4';
    if (key == LogicalKeyboardKey.f5) return 'F5';
    if (key == LogicalKeyboardKey.f6) return 'F6';
    if (key == LogicalKeyboardKey.f7) return 'F7';
    if (key == LogicalKeyboardKey.f8) return 'F8';
    if (key == LogicalKeyboardKey.f9) return 'F9';
    if (key == LogicalKeyboardKey.f10) return 'F10';
    if (key == LogicalKeyboardKey.f11) return 'F11';
    if (key == LogicalKeyboardKey.f12) return 'F12';

    // 修饰键
    if (key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight)
      return 'Ctrl';
    if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight)
      return 'Shift';
    if (key == LogicalKeyboardKey.altLeft || key == LogicalKeyboardKey.altRight)
      return 'Alt';
    if (key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight)
      return 'Win';

    // 特殊键
    if (key == LogicalKeyboardKey.space) return 'Space';
    if (key == LogicalKeyboardKey.enter) return 'Enter';
    if (key == LogicalKeyboardKey.escape) return 'Escape';
    if (key == LogicalKeyboardKey.tab) return 'Tab';
    if (key == LogicalKeyboardKey.backspace) return 'Backspace';
    if (key == LogicalKeyboardKey.delete) return 'Delete';
    if (key == LogicalKeyboardKey.insert) return 'Insert';
    if (key == LogicalKeyboardKey.home) return 'Home';
    if (key == LogicalKeyboardKey.end) return 'End';
    if (key == LogicalKeyboardKey.pageUp) return 'PageUp';
    if (key == LogicalKeyboardKey.pageDown) return 'PageDown';

    // 符号键
    if (key == LogicalKeyboardKey.minus) return '-';
    if (key == LogicalKeyboardKey.equal) return '=';
    if (key == LogicalKeyboardKey.bracketLeft) return '[';
    if (key == LogicalKeyboardKey.bracketRight) return ']';
    if (key == LogicalKeyboardKey.backslash) return '\\';
    if (key == LogicalKeyboardKey.semicolon) return ';';
    if (key == LogicalKeyboardKey.quote) return "'";
    if (key == LogicalKeyboardKey.comma) return ',';
    if (key == LogicalKeyboardKey.period) return '.';
    if (key == LogicalKeyboardKey.slash) return '/';
    if (key == LogicalKeyboardKey.backquote) return '`';

    // 如果没有匹配的键，返回键的调试名称
    return key.debugName ?? 'Unknown';
  }

  /// 处理按键事件
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_isCapturing) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      final String mainKey = _getKeyString(event.logicalKey);

      // 如果按下的是修饰键，不做任何处理，等待主键
      if (mainKey == 'Ctrl' ||
          mainKey == 'Shift' ||
          mainKey == 'Alt' ||
          mainKey == 'Win') {
        return KeyEventResult.handled;
      }

      final List<String> keys = [];

      // 检查修饰键状态（统一使用不分左右的名称）
      if (HardwareKeyboard.instance.isControlPressed) {
        keys.add('Ctrl');
      }
      if (HardwareKeyboard.instance.isShiftPressed) {
        keys.add('Shift');
      }
      if (HardwareKeyboard.instance.isAltPressed) {
        keys.add('Alt');
      }
      if (HardwareKeyboard.instance.isMetaPressed) {
        keys.add('Win');
      }

      // 添加主键
      keys.add(mainKey);

      setState(() {
        _capturedKeys = keys;
        _isCapturing = false;
      });

      // 构建快捷键字符串
      final String shortcut = keys.join('+');
      widget.onKeyCaptured(shortcut);
      _focusNode.unfocus();
    }

    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          setState(() {
            _isCapturing = true;
            _capturedKeys.clear();
            _pressedKeys.clear();
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isCapturing
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: _isCapturing ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _isCapturing
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          child: _capturedKeys.isEmpty
              ? Text(
                  _isCapturing ? '请按下按键组合...' : '点击开始录制按键',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                )
              : Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _buildKeyChips(),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildKeyChips() {
    List<Widget> widgets = [];
    for (int i = 0; i < _capturedKeys.length; i++) {
      if (i > 0) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.add,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
      widgets.add(_buildKeyChip(_capturedKeys[i]));
    }
    return widgets;
  }

  Widget _buildKeyChip(String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getKeyColor(key, context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Text(
        _getKeyDisplayName(key),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Color _getKeyColor(String key, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (key.toLowerCase()) {
      case 'control':
      case 'shift':
      case 'alt':
      case 'meta':
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
        return 'Ctrl';
      case 'shift':
        return 'Shift';
      case 'alt':
        return 'Alt';
      case 'meta':
      case 'win':
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
        return key;
    }
  }
}
