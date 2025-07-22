import 'package:flutter/material.dart';

/// 工作状态操作控件类型
enum WorkStatusActionType {
  /// 取消/关闭操作
  cancel,

  /// 暂停操作
  pause,

  /// 重试操作
  retry,

  /// 自定义操作
  custom,
}

/// 工作状态操作控件
class WorkStatusAction {
  /// 操作类型
  final WorkStatusActionType type;

  /// 操作图标
  final IconData icon;

  /// 操作提示文本
  final String tooltip;

  /// 操作回调函数
  final VoidCallback onPressed;

  /// 是否为危险操作（使用红色样式）
  final bool isDangerous;

  /// 是否启用（默认为true）
  final bool enabled;

  const WorkStatusAction({
    required this.type,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isDangerous = false,
    this.enabled = true,
  });

  /// 创建取消操作
  factory WorkStatusAction.cancel({
    required VoidCallback onPressed,
    String tooltip = '取消操作',
    bool enabled = true,
  }) {
    return WorkStatusAction(
      type: WorkStatusActionType.cancel,
      icon: Icons.close,
      tooltip: tooltip,
      onPressed: onPressed,
      isDangerous: true,
      enabled: enabled,
    );
  }

  /// 创建暂停操作
  factory WorkStatusAction.pause({
    required VoidCallback onPressed,
    String tooltip = '暂停操作',
    bool enabled = true,
  }) {
    return WorkStatusAction(
      type: WorkStatusActionType.pause,
      icon: Icons.pause,
      tooltip: tooltip,
      onPressed: onPressed,
      enabled: enabled,
    );
  }

  /// 创建重试操作
  factory WorkStatusAction.retry({
    required VoidCallback onPressed,
    String tooltip = '重试操作',
    bool enabled = true,
  }) {
    return WorkStatusAction(
      type: WorkStatusActionType.retry,
      icon: Icons.refresh,
      tooltip: tooltip,
      onPressed: onPressed,
      enabled: enabled,
    );
  }
}
