import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:async';
import '../providers/user_preferences_provider.dart';

/// 窗口管理服务
class WindowManagerService {
  static final WindowManagerService _instance = WindowManagerService._internal();
  factory WindowManagerService() => _instance;
  WindowManagerService._internal();

  UserPreferencesProvider? _userPreferencesProvider;
  Timer? _saveTimer;
  Size? _lastSize;
  Offset? _lastPosition;
  bool _isMaximized = false;
  
  /// 防抖延迟时间（毫秒）
  static const int _debounceDelay = 500;

  /// 初始化窗口管理服务
  void initialize(UserPreferencesProvider userPreferencesProvider) {
    _userPreferencesProvider = userPreferencesProvider;
    
    // 只在桌面平台初始化
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      _startListening();
    }
  }

  /// 开始监听窗口大小变化
  void _startListening() {
    // 使用定时器定期检查窗口大小变化
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_userPreferencesProvider?.isInitialized != true) return;
      
      try {
        final currentSize = appWindow.size;
        final currentPosition = appWindow.position;
        final currentMaximized = appWindow.isMaximized;
        
        // 检查窗口状态是否发生变化
        if (_lastSize != currentSize || _lastPosition != currentPosition || _isMaximized != currentMaximized) {
          _lastSize = currentSize;
          _lastPosition = currentPosition;
          _isMaximized = currentMaximized;
          
          // 防抖处理，避免频繁保存
          _scheduleAutoSave(currentSize, currentPosition, currentMaximized);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('检查窗口大小变化时出错: $e');
        }
      }
    });
  }

  /// 计划自动保存
  void _scheduleAutoSave(Size size, Offset position, bool isMaximized) {
    // 取消之前的定时器
    _saveTimer?.cancel();
    
    // 设置新的定时器
    _saveTimer = Timer(const Duration(milliseconds: _debounceDelay), () {
      _saveWindowSize(size, position, isMaximized);
    });
  }

  /// 保存窗口大小和位置
  void _saveWindowSize(Size size, Offset position, bool isMaximized) {
    if (_userPreferencesProvider == null || !_userPreferencesProvider!.isInitialized) {
      return;
    }
    
    // 检查是否启用了自动保存
    if (!_userPreferencesProvider!.layout.autoSaveWindowSize) {
      return;
    }
    
    try {
      _userPreferencesProvider!.updateWindowSize(
        width: size.width,
        height: size.height,
        isMaximized: isMaximized,
        x: position.dx,
        y: position.dy,
      );
      
      if (kDebugMode) {
        debugPrint('窗口大小和位置已保存: ${size.width}x${size.height} at (${position.dx}, ${position.dy}), 最大化: $isMaximized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('保存窗口大小和位置失败: $e');
      }
    }
  }

  /// 应用保存的窗口大小和位置
  void applyWindowSize() {
    if (_userPreferencesProvider == null || !_userPreferencesProvider!.isInitialized) {
      return;
    }
    
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        final layout = _userPreferencesProvider!.layout;
        
        // 设置窗口大小
        final size = Size(layout.windowWidth, layout.windowHeight);
        appWindow.size = size;
        
        // 设置最小窗口大小
        appWindow.minSize = Size(layout.minWindowWidth, layout.minWindowHeight);
        
        // 设置窗口位置（如果启用了记住位置且不是-1的话）
        if (layout.rememberWindowPosition && layout.windowX != -1 && layout.windowY != -1) {
          final position = Offset(layout.windowX, layout.windowY);
          appWindow.position = position;
          _lastPosition = position;
        }
        
        // 如果启用了记住最大化状态并且之前是最大化的，则最大化窗口
        if (layout.rememberMaximizedState && layout.isMaximized) {
          appWindow.maximize();
        }
        
        // 记录当前状态
        _lastSize = size;
        _isMaximized = layout.isMaximized;
        
        if (kDebugMode) {
          debugPrint('窗口大小和位置已应用: ${size.width}x${size.height} at (${layout.windowX}, ${layout.windowY}), 最大化: ${layout.isMaximized}');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('应用窗口大小失败: $e');
        }
      }
    }
  }

  /// 手动保存当前窗口大小
  void saveCurrentWindowSize() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        final currentSize = appWindow.size;
        final currentPosition = appWindow.position;
        final currentMaximized = appWindow.isMaximized;
        _saveWindowSize(currentSize, currentPosition, currentMaximized);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('手动保存窗口大小失败: $e');
        }
      }
    }
  }

  /// 重置窗口大小为默认值
  void resetToDefaultSize() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        const defaultSize = Size(1280, 720);
        appWindow.size = defaultSize;
        appWindow.minSize = const Size(800, 600);
        
        // 如果启用了自动保存，则保存重置后的大小
        if (_userPreferencesProvider?.layout.autoSaveWindowSize == true) {
          final currentPosition = appWindow.position;
          _saveWindowSize(defaultSize, currentPosition, false);
        }
        
        if (kDebugMode) {
          debugPrint('窗口大小已重置为默认值');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('重置窗口大小失败: $e');
        }
      }
    }
  }

  /// 销毁服务
  void dispose() {
    _saveTimer?.cancel();
    _saveTimer = null;
    _userPreferencesProvider = null;
  }
}
