import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/timer_data.dart';
import '../data/map_data_bloc.dart';
import '../data/map_data_event.dart';

/// 计时器管理器
/// 负责管理所有计时器的运行状态和时间更新
class TimerManager {
  static TimerManager? _instance;
  static TimerManager get instance => _instance ??= TimerManager._();
  
  TimerManager._();

  // 计时器映射表
  final Map<String, Timer> _activeTimers = {};
  final Map<String, DateTime> _startTimes = {};
  final Map<String, Duration> _pausedDurations = {};
  
  // 更新间隔（毫秒）
  static const int _updateIntervalMs = 10;
  
  MapDataBloc? _mapDataBloc;

  /// 初始化计时器管理器
  void initialize(MapDataBloc mapDataBloc) {
    _mapDataBloc = mapDataBloc;
  }

  /// 启动计时器
  void startTimer(String timerId, TimerData timerData) {
    // 停止现有的计时器（如果有）
    stopTimer(timerId);
    
    final now = DateTime.now();
    _startTimes[timerId] = now;
    
    // 如果是从暂停状态恢复，需要考虑之前暂停的时长
    if (timerData.state == TimerState.paused && timerData.pauseTime != null) {
      final pausedDuration = timerData.currentTime;
      _pausedDurations[timerId] = pausedDuration;
    } else {
      _pausedDurations[timerId] = timerData.currentTime;
    }
    
    // 创建定时器
    _activeTimers[timerId] = Timer.periodic(
      const Duration(milliseconds: _updateIntervalMs),
      (timer) => _updateTimer(timerId, timerData),
    );
    
    debugPrint('计时器已启动: $timerId');
  }

  /// 暂停计时器
  void pauseTimer(String timerId) {
    final timer = _activeTimers[timerId];
    if (timer != null) {
      timer.cancel();
      _activeTimers.remove(timerId);
      debugPrint('计时器已暂停: $timerId');
    }
  }

  /// 停止计时器
  void stopTimer(String timerId) {
    final timer = _activeTimers[timerId];
    if (timer != null) {
      timer.cancel();
      _activeTimers.remove(timerId);
      _startTimes.remove(timerId);
      _pausedDurations.remove(timerId);
      debugPrint('计时器已停止: $timerId');
    }
  }

  /// 停止所有计时器
  void stopAllTimers() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    _startTimes.clear();
    _pausedDurations.clear();
    debugPrint('所有计时器已停止');
  }

  /// 更新计时器时间
  void _updateTimer(String timerId, TimerData timerData) {
    final startTime = _startTimes[timerId];
    final pausedDuration = _pausedDurations[timerId];
    
    if (startTime == null || pausedDuration == null || _mapDataBloc == null) {
      return;
    }

    final now = DateTime.now();
    final elapsed = now.difference(startTime);
    
    Duration currentTime;
    bool shouldComplete = false;
    
    switch (timerData.mode) {
      case TimerMode.countdown:
        // 倒计时：从暂停的时间减去经过的时间
        currentTime = pausedDuration - elapsed;
        if (currentTime.isNegative) {
          currentTime = Duration.zero;
          shouldComplete = true;
        }
        break;
        
      case TimerMode.stopwatch:
        // 正计时：从暂停的时间加上经过的时间
        currentTime = pausedDuration + elapsed;
        // 检查是否达到目标时间
        if (timerData.targetTime != null && currentTime >= timerData.targetTime!) {
          currentTime = timerData.targetTime!;
          shouldComplete = true;
        }
        break;
    }
    
    // 发送时间更新事件
    _mapDataBloc!.add(TimerTick(
      timerId: timerId,
      currentTime: currentTime,
    ));
    
    // 如果计时器完成，停止它
    if (shouldComplete) {
      stopTimer(timerId);
      debugPrint('计时器已完成: $timerId');
    }
  }

  /// 检查计时器是否正在运行
  bool isTimerRunning(String timerId) {
    return _activeTimers.containsKey(timerId);
  }

  /// 获取所有运行中的计时器ID
  List<String> get runningTimerIds => _activeTimers.keys.toList();

  /// 获取运行中的计时器数量
  int get runningTimerCount => _activeTimers.length;

  /// 清理资源
  void dispose() {
    stopAllTimers();
    _mapDataBloc = null;
    debugPrint('计时器管理器已清理');
  }

  /// 获取调试信息
  Map<String, dynamic> getDebugInfo() {
    return {
      'runningTimers': runningTimerCount,
      'activeTimerIds': runningTimerIds,
      'startTimes': _startTimes.map((k, v) => MapEntry(k, v.toIso8601String())),
      'pausedDurations': _pausedDurations.map((k, v) => MapEntry(k, v.inMilliseconds)),
    };
  }
}

/// 计时器管理器扩展
extension TimerManagerExtension on TimerManager {
  /// 批量启动计时器
  void startTimers(Map<String, TimerData> timers) {
    for (final entry in timers.entries) {
      if (entry.value.state == TimerState.running) {
        startTimer(entry.key, entry.value);
      }
    }
  }

  /// 批量停止计时器
  void stopTimers(List<String> timerIds) {
    for (final timerId in timerIds) {
      stopTimer(timerId);
    }
  }

  /// 重启计时器（停止后重新启动）
  void restartTimer(String timerId, TimerData timerData) {
    stopTimer(timerId);
    startTimer(timerId, timerData);
  }
}