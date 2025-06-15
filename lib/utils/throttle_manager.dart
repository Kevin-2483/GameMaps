import 'dart:async';
import 'package:flutter/foundation.dart';

/// 通用节流管理器
/// 支持对任意函数进行节流控制，防止高频调用
class ThrottleManager {
  final Map<String, Timer> _timers = {};
  final Map<String, dynamic> _pendingValues = {};
  final Duration _defaultDuration;

  ThrottleManager({
    Duration defaultDuration = const Duration(milliseconds: 16), // 默认60Hz
  }) : _defaultDuration = defaultDuration;

  /// 节流执行函数
  ///
  /// [key] - 节流标识，相同key的调用会被节流
  /// [action] - 要执行的函数
  /// [value] - 要传递给函数的值（可选）
  /// [duration] - 节流间隔，如果不指定则使用默认值
  void throttle<T>(
    String key,
    void Function(T?) action, {
    T? value,
    Duration? duration,
  }) {
    // 保存最新的值
    _pendingValues[key] = value;

    // 如果已有定时器在运行，直接返回（更新了值但不立即执行）
    if (_timers.containsKey(key) && _timers[key]!.isActive) {
      return;
    }

    // 创建新的节流定时器
    _timers[key] = Timer(duration ?? _defaultDuration, () {
      // 执行动作，使用最新的值
      final latestValue = _pendingValues[key] as T?;
      try {
        action(latestValue);
      } catch (e) {
        debugPrint('节流执行出错 [$key]: $e');
      } finally {
        // 清理
        _pendingValues.remove(key);
        _timers.remove(key);
      }
    });
  }

  /// 立即执行指定key的待处理任务（如果有的话）
  void flush<T>(String key, void Function(T?) action) {
    final timer = _timers[key];
    if (timer != null && timer.isActive) {
      timer.cancel();
      final value = _pendingValues[key] as T?;
      try {
        action(value);
      } catch (e) {
        debugPrint('节流立即执行出错 [$key]: $e');
      } finally {
        _pendingValues.remove(key);
        _timers.remove(key);
      }
    }
  }

  /// 取消指定key的节流任务
  void cancel(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
    _pendingValues.remove(key);
  }

  /// 取消所有节流任务
  void cancelAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _pendingValues.clear();
  }

  /// 获取当前活跃的节流任务数量
  int get activeCount => _timers.length;

  /// 检查指定key是否有活跃的节流任务
  bool isActive(String key) {
    return _timers.containsKey(key) && _timers[key]!.isActive;
  }

  /// 释放所有资源
  void dispose() {
    cancelAll();
    debugPrint('ThrottleManager已释放，清理了${_timers.length}个定时器');
  }
}

/// 节流函数混入
/// 为类提供便捷的节流功能
mixin ThrottleMixin {
  ThrottleManager? _throttleManager;

  /// 获取节流管理器（懒加载）
  ThrottleManager get throttleManager {
    _throttleManager ??= ThrottleManager();
    return _throttleManager!;
  }

  /// 便捷的节流方法
  void throttled<T>(
    String key,
    void Function(T?) action, {
    T? value,
    Duration? duration,
  }) {
    throttleManager.throttle(key, action, value: value, duration: duration);
  }

  /// 立即执行节流任务
  void flushThrottled<T>(String key, void Function(T?) action) {
    throttleManager.flush(key, action);
  }

  /// 释放节流资源（在dispose中调用）
  void disposeThrottle() {
    _throttleManager?.dispose();
    _throttleManager = null;
  }
}

/// 全局节流工具函数
class GlobalThrottle {
  static final ThrottleManager _instance = ThrottleManager();

  /// 全局节流函数
  static void throttle<T>(
    String key,
    void Function(T?) action, {
    T? value,
    Duration? duration,
  }) {
    _instance.throttle(key, action, value: value, duration: duration);
  }

  /// 立即执行全局节流任务
  static void flush<T>(String key, void Function(T?) action) {
    _instance.flush(key, action);
  }

  /// 取消全局节流任务
  static void cancel(String key) {
    _instance.cancel(key);
  }

  /// 获取活跃任务数
  static int get activeCount => _instance.activeCount;
}
