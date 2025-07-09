import 'package:flutter/material.dart';
import 'notification_models.dart';
import 'notification_queue_manager.dart';

/// 通知服务 - 主要API入口
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  NotificationService._internal();

  /// 获取队列管理器
  NotificationQueueManager get _manager => NotificationQueueManager.instance;

  /// 初始化服务
  void initialize({NotificationConfig? config, NotificationTheme? theme}) {
    _manager.initialize(config: config, theme: theme);
  }

  /// 设置 Overlay state（通常在 MaterialApp 的 builder 中调用）
  void setOverlayState(OverlayState overlayState) {
    _manager.setOverlayState(overlayState);
  }

  /// 显示成功消息
  void showSuccess(
    String message, {
    NotificationPosition? position,
    Duration? duration,
    bool? showCloseButton,
    bool? allowStacking,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    _manager.showSuccess(
      message,
      position: position,
      duration: duration,
      showCloseButton: showCloseButton,
      allowStacking: allowStacking,
      onTap: onTap,
      onClose: onClose,
    );
  }

  /// 显示错误消息
  void showError(
    String message, {
    NotificationPosition? position,
    Duration? duration,
    bool? showCloseButton,
    bool? allowStacking,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    _manager.showError(
      message,
      position: position,
      duration: duration,
      showCloseButton: showCloseButton,
      allowStacking: allowStacking,
      onTap: onTap,
      onClose: onClose,
    );
  }

  /// 显示警告消息
  void showWarning(
    String message, {
    NotificationPosition? position,
    Duration? duration,
    bool? showCloseButton,
    bool? allowStacking,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    _manager.showWarning(
      message,
      position: position,
      duration: duration,
      showCloseButton: showCloseButton,
      allowStacking: allowStacking,
      onTap: onTap,
      onClose: onClose,
    );
  }

  /// 显示信息消息
  void showInfo(
    String message, {
    NotificationPosition? position,
    Duration? duration,
    bool? showCloseButton,
    bool? allowStacking,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    _manager.showInfo(
      message,
      position: position,
      duration: duration,
      showCloseButton: showCloseButton,
      allowStacking: allowStacking,
      onTap: onTap,
      onClose: onClose,
    );
  }

  /// 显示自定义消息
  void show({
    String? id, // 🔑 新增：通知ID，用于后续更新
    required String message,
    required NotificationType type,
    NotificationPosition? position,
    Duration? duration,
    bool? showCloseButton,
    bool? allowStacking,
    bool isPersistent = false, // 🔑 新增：是否常驻显示
    NotificationBorderEffect borderEffect =
        NotificationBorderEffect.none, // 🔑 新增：边框效果
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    _manager.show(
      id: id,
      message: message,
      type: type,
      position: position,
      duration: duration,
      showCloseButton: showCloseButton,
      allowStacking: allowStacking,
      isPersistent: isPersistent,
      borderEffect: borderEffect,
      onTap: onTap,
      onClose: onClose,
    );
  }

  /// 隐藏指定位置的所有通知
  void hideAllAtPosition(NotificationPosition position) {
    _manager.hideAllAtPosition(position);
  }

  /// 隐藏所有通知
  void hideAll() {
    _manager.hideAll();
  }

  /// 🔑 更新现有通知（不重新播放动画）
  void updateNotification({
    required String notificationId,
    String? message,
    NotificationType? type,
    NotificationPosition? position,
    Duration? duration,
    bool? showCloseButton,
    bool? isPersistent,
    NotificationBorderEffect? borderEffect,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    _manager.updateNotification(
      notificationId: notificationId,
      message: message,
      type: type,
      position: position,
      duration: duration,
      showCloseButton: showCloseButton,
      isPersistent: isPersistent,
      borderEffect: borderEffect,
      onTap: onTap,
      onClose: onClose,
    );
  }

  /// 获取指定位置的队列长度
  int getQueueLength(NotificationPosition position) {
    return _manager.getQueueLength(position);
  }

  /// 清理资源
  void dispose() {
    _manager.dispose();
  }
}

/// 全局便捷方法
class Notifications {
  static NotificationService get _service => NotificationService.instance;

  /// 显示成功消息
  static void showSuccess(String message, {NotificationPosition? position}) {
    _service.showSuccess(message, position: position);
  }

  /// 显示错误消息
  static void showError(String message, {NotificationPosition? position}) {
    _service.showError(message, position: position);
  }

  /// 显示警告消息
  static void showWarning(String message, {NotificationPosition? position}) {
    _service.showWarning(message, position: position);
  }

  /// 显示信息消息
  static void showInfo(String message, {NotificationPosition? position}) {
    _service.showInfo(message, position: position);
  }

  /// 隐藏所有通知
  static void hideAll() {
    _service.hideAll();
  }
}

/// 兼容旧的 SnackBar 方法的扩展
extension SnackBarCompatibility on BuildContext {
  /// 替代 _showSuccessSnackBar
  void showSuccessSnackBar(String message) {
    Notifications.showSuccess(message);
  }

  /// 替代 _showErrorSnackBar
  void showErrorSnackBar(String message) {
    Notifications.showError(message);
  }

  /// 替代 _showInfoSnackBar
  void showInfoSnackBar(String message) {
    Notifications.showInfo(message);
  }

  /// 替代一般的 SnackBar
  void showNotificationSnackBar(
    String message, {
    NotificationType type = NotificationType.info,
    NotificationPosition? position,
  }) {
    NotificationService.instance.show(
      message: message,
      type: type,
      position: position,
    );
  }
}
