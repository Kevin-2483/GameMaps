// This file has been processed by AI for internationalization
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:async';
import '../providers/user_preferences_provider.dart';

import 'localization_service.dart';

/// 窗口管理服务
class WindowManagerService {
  static final WindowManagerService _instance =
      WindowManagerService._internal();
  factory WindowManagerService() => _instance;
  WindowManagerService._internal();

  UserPreferencesProvider? _userPreferencesProvider;

  /// 初始化窗口管理服务
  void initialize(UserPreferencesProvider userPreferencesProvider) {
    _userPreferencesProvider = userPreferencesProvider;
  }

  /// 应用保存的窗口大小（不控制位置，让系统决定）
  void applyWindowSize() {
    if (_userPreferencesProvider == null ||
        !_userPreferencesProvider!.isInitialized) {
      return;
    }

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        final layout = _userPreferencesProvider!.layout;

        // 设置最小窗口大小
        appWindow.minSize = Size(layout.minWindowWidth, layout.minWindowHeight);

        // 如果启用了记住最大化状态并且之前是最大化的，则最大化窗口
        if (layout.rememberMaximizedState && layout.isMaximized) {
          appWindow.maximize();
        } else {
          // 只有在非最大化状态下才设置窗口大小
          final size = Size(layout.windowWidth, layout.windowHeight);
          appWindow.size = size;
        }

        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.windowSizeApplied(
              layout.windowWidth,
              layout.windowHeight,
              layout.isMaximized,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.windowSizeError_7425(e),
          );
        }
      }
    }
  }

  /// 手动保存当前窗口大小（不保存位置）
  Future<bool> saveCurrentWindowSize() async {
    if (_userPreferencesProvider == null ||
        !_userPreferencesProvider!.isInitialized) {
      return false;
    }

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        final currentSize = appWindow.size;
        final currentMaximized = appWindow.isMaximized;

        // 只保存窗口大小，不保存位置
        final success = await _userPreferencesProvider!.updateWindowSize(
          width: currentSize.width,
          height: currentSize.height,
          isMaximized: currentMaximized,
        );

        if (kDebugMode) {
          if (success) {
            debugPrint(
              LocalizationService.instance.current.windowSizeSaved(
                currentSize.width,
                currentSize.height,
                currentMaximized,
              ),
            );
          } else {
            debugPrint(
              LocalizationService.instance.current.windowSizeSaveFailed_7281,
            );
          }
        }

        return success;
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.saveWindowSizeFailed_7285(e),
          );
        }
        return false;
      }
    }

    return false;
  }

  /// 重置窗口大小为默认值
  Future<void> resetToDefaultSize() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        const defaultSize = Size(1280, 720);
        appWindow.size = defaultSize;
        appWindow.minSize = const Size(800, 600);

        // 保存重置后的大小（不保存位置）
        if (_userPreferencesProvider != null) {
          await _userPreferencesProvider!.updateWindowSize(
            width: defaultSize.width,
            height: defaultSize.height,
            isMaximized: false,
          );
        }

        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.windowSizeResetToDefault_4821,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.resetWindowSizeFailed_4829(e),
          );
        }
      }
    }
  }

  /// 退出时保存窗口状态（确保完整的读取-保存流程）
  Future<bool> saveWindowStateOnExit() async {
    if (_userPreferencesProvider == null ||
        !_userPreferencesProvider!.isInitialized) {
      return false;
    }

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        // 1. 读取当前窗口状态
        final currentSize = appWindow.size;
        final currentMaximized = appWindow.isMaximized;
        final layout = _userPreferencesProvider!.layout;

        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.windowStateOnExit(
              currentSize.width,
              currentSize.height,
              currentMaximized,
            ),
          );
        }

        // 2. 检查是否启用了自动保存窗口大小
        if (!layout.autoSaveWindowSize) {
          if (kDebugMode) {
            debugPrint(
              LocalizationService
                  .instance
                  .current
                  .autoSaveWindowSizeDisabled_7281,
            );
          }
          return true; // 不保存但返回成功
        }

        // 3. 根据设置决定是否保存最大化状态
        bool shouldSaveMaximizedState = false;
        if (currentMaximized && layout.rememberMaximizedState) {
          // 如果当前是最大化状态且开启了记住最大化状态设置，则保存最大化状态
          shouldSaveMaximizedState = true;
          if (kDebugMode) {
            debugPrint(
              LocalizationService
                  .instance
                  .current
                  .saveMaximizeStatusEnabled_4821,
            );
          }
        } else if (!currentMaximized) {
          // 如果当前不是最大化状态，保存窗口大小
          shouldSaveMaximizedState = false;
          if (kDebugMode) {
            debugPrint(
              LocalizationService
                  .instance
                  .current
                  .saveWindowSizeNotMaximized_4821,
            );
          }
        } else {
          // 当前是最大化状态但未开启记住最大化状态设置，不保存
          if (kDebugMode) {
            debugPrint(
              LocalizationService
                  .instance
                  .current
                  .skipSaveMaximizedStateNotEnabled_4821,
            );
          }
          return true;
        }

        // 4. 强制立即保存到数据库（绕过防抖机制）
        final success = await _userPreferencesProvider!.updateWindowSize(
          width: currentSize.width,
          height: currentSize.height,
          isMaximized: shouldSaveMaximizedState ? currentMaximized : false,
        );

        // 5. 确保所有待处理的更改都已保存
        await _userPreferencesProvider!.flushPendingChanges();

        if (kDebugMode) {
          if (success) {
            debugPrint(
              LocalizationService
                  .instance
                  .current
                  .windowStateSavedSuccessfully_7281,
            );
          } else {
            debugPrint(
              LocalizationService.instance.current.windowStateSaveFailed_7281,
            );
          }
        }

        return success;
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            LocalizationService.instance.current.windowStateSaveError(e),
          );
        }
        return false;
      }
    }

    return true; // 非桌面平台返回成功
  }

  /// 销毁服务
  void dispose() {
    _userPreferencesProvider = null;
  }
}
