/// 计时器数据模型
class TimerData {
  final String id;
  final String name;
  final TimerMode mode;
  final TimerState state;
  final Duration currentTime;
  final Duration? targetTime; // 倒计时目标时间
  final DateTime? startTime;
  final DateTime? pauseTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TimerData({
    required this.id,
    required this.name,
    required this.mode,
    required this.state,
    required this.currentTime,
    this.targetTime,
    this.startTime,
    this.pauseTime,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建副本
  TimerData copyWith({
    String? id,
    String? name,
    TimerMode? mode,
    TimerState? state,
    Duration? currentTime,
    Duration? targetTime,
    DateTime? startTime,
    DateTime? pauseTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimerData(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      state: state ?? this.state,
      currentTime: currentTime ?? this.currentTime,
      targetTime: targetTime ?? this.targetTime,
      startTime: startTime ?? this.startTime,
      pauseTime: pauseTime ?? this.pauseTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mode': mode.name,
      'state': state.name,
      'currentTime': currentTime.inMilliseconds,
      'targetTime': targetTime?.inMilliseconds,
      'startTime': startTime?.millisecondsSinceEpoch,
      'pauseTime': pauseTime?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 从JSON创建
  factory TimerData.fromJson(Map<String, dynamic> json) {
    return TimerData(
      id: json['id'] as String,
      name: json['name'] as String,
      mode: TimerMode.values.firstWhere((e) => e.name == json['mode']),
      state: TimerState.values.firstWhere((e) => e.name == json['state']),
      currentTime: Duration(milliseconds: json['currentTime'] as int),
      targetTime: json['targetTime'] != null
          ? Duration(milliseconds: json['targetTime'] as int)
          : null,
      startTime: json['startTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int)
          : null,
      pauseTime: json['pauseTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['pauseTime'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  /// 检查是否已完成（倒计时到0或正计时达到目标）
  bool get isCompleted {
    switch (mode) {
      case TimerMode.countdown:
        return currentTime.inMilliseconds <= 0;
      case TimerMode.stopwatch:
        return targetTime != null && currentTime >= targetTime!;
    }
  }

  /// 检查是否正在运行
  bool get isRunning => state == TimerState.running;

  /// 检查是否已暂停
  bool get isPaused => state == TimerState.paused;

  /// 检查是否已停止
  bool get isStopped => state == TimerState.stopped;

  /// 获取格式化的时间显示
  String get formattedTime {
    final duration = currentTime;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final milliseconds = duration.inMilliseconds.remainder(1000);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimerData &&
        other.id == id &&
        other.name == name &&
        other.mode == mode &&
        other.state == state &&
        other.currentTime == currentTime &&
        other.targetTime == targetTime &&
        other.startTime == startTime &&
        other.pauseTime == pauseTime &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      mode,
      state,
      currentTime,
      targetTime,
      startTime,
      pauseTime,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'TimerData(id: $id, name: $name, mode: $mode, state: $state, currentTime: $formattedTime)';
  }
}

/// 计时器模式
enum TimerMode {
  countdown, // 倒计时
  stopwatch, // 正计时
}

/// 计时器状态
enum TimerState {
  stopped, // 停止
  running, // 运行中
  paused, // 暂停
  completed, // 完成
}

/// 计时器模式扩展
extension TimerModeExtension on TimerMode {
  String get displayName {
    switch (this) {
      case TimerMode.countdown:
        return '倒计时';
      case TimerMode.stopwatch:
        return '正计时';
    }
  }

  String get description {
    switch (this) {
      case TimerMode.countdown:
        return '从设定时间倒数到零';
      case TimerMode.stopwatch:
        return '从零开始正向计时';
    }
  }
}

/// 计时器状态扩展
extension TimerStateExtension on TimerState {
  String get displayName {
    switch (this) {
      case TimerState.stopped:
        return '已停止';
      case TimerState.running:
        return '运行中';
      case TimerState.paused:
        return '已暂停';
      case TimerState.completed:
        return '已完成';
    }
  }

  bool get canStart => this == TimerState.stopped || this == TimerState.paused;
  bool get canPause => this == TimerState.running;
  bool get canStop => this == TimerState.running || this == TimerState.paused;
  bool get canReset => this != TimerState.stopped;
}
