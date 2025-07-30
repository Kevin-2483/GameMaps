// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/user_preferences_provider.dart';
import '../../services/window_manager_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// 通用窗口控制组件
/// 提供最小化、最大化/还原、全屏等窗口控制功能
class WindowControls extends StatefulWidget {
  /// 按钮样式配置
  final WindowControlsStyle style;

  /// 是否显示关闭按钮
  final bool showCloseButton;

  /// 关闭按钮回调
  final VoidCallback? onClose;

  /// 按钮间距
  final double spacing;

  const WindowControls({
    super.key,
    this.style = const WindowControlsStyle(),
    this.showCloseButton = false,
    this.onClose,
    this.spacing = 4.0,
  });

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls>
    with FullScreenListener {
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    // 初始化全屏监听器
    FullScreen.addListener(this);
    _updateFullScreenState();
  }

  @override
  void dispose() {
    // 清理全屏监听器
    FullScreen.removeListener(this);
    super.dispose();
  }

  /// 全屏状态变化回调
  @override
  void onFullScreenChanged(bool isFullScreen, dynamic systemUiMode) {
    if (mounted) {
      setState(() {
        _isFullScreen = isFullScreen;
      });
    }
  }

  /// 更新全屏状态
  void _updateFullScreenState() async {
    try {
      final isFullScreen = await FullScreen.isFullScreen;
      if (mounted) {
        setState(() {
          _isFullScreen = isFullScreen;
        });
      }
    } catch (e) {
      debugPrint(LocalizationService.instance.current.fullScreenStatusError(e));
    }
  }

  /// 如果启用了自动保存窗口大小，则保存当前窗口大小（仅在非最大化状态下）
  void _saveWindowSizeIfEnabled(BuildContext context) {
    try {
      final userPrefsProvider = context.read<UserPreferencesProvider>();
      if (userPrefsProvider.isInitialized &&
          userPrefsProvider.layout.autoSaveWindowSize &&
          !appWindow.isMaximized) {
        WindowManagerService().saveCurrentWindowSize();
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.windowSizeSaveRequestSent_7281,
          );
        }
      } else if (kDebugMode && appWindow.isMaximized) {
        debugPrint(LocalizationService.instance.current.skipSaveMaximizedState);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          LocalizationService.instance.current.saveWindowSizeFailed_7285(e),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 只在桌面平台显示窗口控制按钮
    if (kIsWeb ||
        !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return const SizedBox.shrink();
    }

    final buttons = <Widget>[
      // 最小化按钮
      _buildWindowButton(
        icon: Icons.minimize,
        onPressed: () {
          _saveWindowSizeIfEnabled(context);
          appWindow.minimize();
        },
        tooltip: LocalizationService.instance.current.minimizeButton_7281,
      ),

      SizedBox(width: widget.spacing),

      // 最大化/还原按钮
      _buildWindowButton(
        icon: Icons.crop_square,
        onPressed: () {
          _saveWindowSizeIfEnabled(context);
          appWindow.maximizeOrRestore();
        },
        tooltip: LocalizationService.instance.current.maximizeOrRestore_7281,
      ),

      // 在Windows平台上不显示全屏按钮
      if (!Platform.isWindows) ...[
        SizedBox(width: widget.spacing),

        // 全屏按钮
        _buildWindowButton(
          icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
          onPressed: () async {
            try {
              if (!_isFullScreen) {
                // 进入全屏时保存窗口大小
                _saveWindowSizeIfEnabled(context);
              }
              // 切换全屏状态
              FullScreen.setFullScreen(!_isFullScreen);
            } catch (e) {
              debugPrint(
                LocalizationService.instance.current.fullscreenToggleFailed(e),
              );
            }
          },
          tooltip: _isFullScreen ? '退出全屏' : '全屏',
        ),
      ],
    ];

    // 如果显示关闭按钮，添加关闭按钮
    if (widget.showCloseButton) {
      buttons.addAll([
        SizedBox(width: widget.spacing),
        _buildWindowButton(
          icon: Icons.close,
          onPressed: widget.onClose ?? () => appWindow.close(),
          tooltip: LocalizationService.instance.current.closeButton_4821,
          isCloseButton: true,
        ),
      ]);
    }

    return Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }

  /// 构建窗口控制按钮
  Widget _buildWindowButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isCloseButton = false,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(widget.style.borderRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(widget.style.borderRadius),
        hoverColor: isCloseButton
            ? Colors.red.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        child: Tooltip(
          message: tooltip,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontSize: 12,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.style.buttonSize,
            height: widget.style.buttonSize,
            padding: EdgeInsets.all(widget.style.padding),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.style.borderRadius),
            ),
            child: Icon(
              icon,
              size: widget.style.iconSize,
              color: isCloseButton
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// 窗口控制按钮样式配置
class WindowControlsStyle {
  /// 按钮大小
  final double buttonSize;

  /// 图标大小
  final double iconSize;

  /// 内边距
  final double padding;

  /// 圆角半径
  final double borderRadius;

  const WindowControlsStyle({
    this.buttonSize = 36.0,
    this.iconSize = 18.0,
    this.padding = 6.0,
    this.borderRadius = 12.0,
  });

  /// 小尺寸样式
  const WindowControlsStyle.small()
    : buttonSize = 32.0,
      iconSize = 16.0,
      padding = 4.0,
      borderRadius = 8.0;

  /// 大尺寸样式
  const WindowControlsStyle.large()
    : buttonSize = 48.0,
      iconSize = 24.0,
      padding = 8.0,
      borderRadius = 16.0;
}
