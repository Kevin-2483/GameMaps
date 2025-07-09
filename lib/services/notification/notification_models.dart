import 'package:flutter/material.dart';

/// 消息类型枚举
enum NotificationType { success, error, warning, info }

/// 消息通知位置
enum NotificationPosition {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// 通知边框效果
enum NotificationBorderEffect {
  /// 无特殊效果
  none,

  /// 常亮边框
  glow,

  /// 旋转加载边框
  loading,
}

/// 消息通知模型
class NotificationMessage {
  final String id;
  final String message;
  final NotificationType type;
  final NotificationPosition? position;
  final Duration? duration;
  final bool? showCloseButton;
  final bool? allowStacking;
  final bool isPersistent; // 🔑 新增：是否常驻显示
  final NotificationBorderEffect borderEffect; // 🔑 新增：边框效果
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final DateTime createdAt;

  NotificationMessage({
    required this.id,
    required this.message,
    required this.type,
    this.position,
    this.duration,
    this.showCloseButton,
    this.allowStacking,
    this.isPersistent = false, // 默认不常驻
    this.borderEffect = NotificationBorderEffect.none, // 默认无边框效果
    this.onTap,
    this.onClose,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  NotificationMessage copyWith({
    String? id,
    String? message,
    NotificationType? type,
    NotificationPosition? position,
    Duration? duration,
    bool? showCloseButton,
    bool? allowStacking,
    bool? isPersistent,
    NotificationBorderEffect? borderEffect,
    VoidCallback? onTap,
    VoidCallback? onClose,
    DateTime? createdAt,
  }) {
    return NotificationMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      showCloseButton: showCloseButton ?? this.showCloseButton,
      allowStacking: allowStacking ?? this.allowStacking,
      isPersistent: isPersistent ?? this.isPersistent,
      borderEffect: borderEffect ?? this.borderEffect,
      onTap: onTap ?? this.onTap,
      onClose: onClose ?? this.onClose,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationMessage &&
        other.id == id &&
        other.message == message &&
        other.type == type &&
        other.position == position &&
        other.duration == duration &&
        other.showCloseButton == showCloseButton &&
        other.allowStacking == allowStacking &&
        other.isPersistent == isPersistent &&
        other.borderEffect == borderEffect;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      message,
      type,
      position,
      duration,
      showCloseButton,
      allowStacking,
      isPersistent,
      borderEffect,
    );
  }
}

/// 消息通知配置
class NotificationConfig {
  final NotificationPosition defaultPosition;
  final Duration defaultDuration;
  final bool defaultShowCloseButton;
  final bool defaultAllowStacking;
  final int maxQueueSize;
  final int maxStackSize;
  final Duration animationDuration;
  final Curve animationCurve;
  final EdgeInsets margin;
  final double borderRadius;
  final double elevation;
  final double stackOffset;
  final double stackScale;
  final double notificationWidth;
  final double notificationHeight;
  final int maxLines;
  final TextOverflow textOverflow;

  const NotificationConfig({
    this.defaultPosition = NotificationPosition.bottomCenter,
    this.defaultDuration = const Duration(seconds: 4),
    this.defaultShowCloseButton = true,
    this.defaultAllowStacking = true,
    this.maxQueueSize = 5,
    this.maxStackSize = 3,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.margin = const EdgeInsets.all(16),
    this.borderRadius = 8.0,
    this.elevation = 6.0,
    this.stackOffset = 8.0,
    this.stackScale = 0.95,
    this.notificationWidth = 320.0,
    this.notificationHeight = 80.0,
    this.maxLines = 2,
    this.textOverflow = TextOverflow.ellipsis,
  });

  NotificationConfig copyWith({
    NotificationPosition? defaultPosition,
    Duration? defaultDuration,
    bool? defaultShowCloseButton,
    int? maxQueueSize,
    Duration? animationDuration,
    Curve? animationCurve,
    EdgeInsets? margin,
    double? borderRadius,
    double? elevation,
  }) {
    return NotificationConfig(
      defaultPosition: defaultPosition ?? this.defaultPosition,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      defaultShowCloseButton:
          defaultShowCloseButton ?? this.defaultShowCloseButton,
      maxQueueSize: maxQueueSize ?? this.maxQueueSize,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
    );
  }
}

/// 消息样式主题
class NotificationTheme {
  final Color backgroundColor;
  final double backgroundOpacity;
  final Color successColor;
  final Color errorColor;
  final Color warningColor;
  final Color infoColor;
  final Color textColor;
  final Color closeButtonColor;
  final TextStyle textStyle;
  final IconData successIcon;
  final IconData errorIcon;
  final IconData warningIcon;
  final IconData infoIcon;
  final bool useTypeColors;

  const NotificationTheme({
    this.backgroundColor = const Color(0xFF2D2D2D),
    this.backgroundOpacity = 1.0,
    this.successColor = Colors.green,
    this.errorColor = Colors.red,
    this.warningColor = Colors.orange,
    this.infoColor = Colors.blue,
    this.textColor = Colors.white,
    this.closeButtonColor = Colors.white70,
    this.textStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    this.successIcon = Icons.check_circle,
    this.errorIcon = Icons.error,
    this.warningIcon = Icons.warning,
    this.infoIcon = Icons.info,
    this.useTypeColors = false,
  });

  /// 根据通知类型获取颜色
  Color getColorForType(NotificationType type, [BuildContext? context]) {
    if (!useTypeColors) {
      // 如果提供了context，根据系统主题自动调整背景色
      if (context != null) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final autoBackgroundColor = isDark
            ? const Color(0xFF2D2D2D) // 深色主题背景
            : const Color(0xFFF5F5F5); // 浅色主题背景
        return autoBackgroundColor.withOpacity(backgroundOpacity);
      }
      return backgroundColor.withOpacity(backgroundOpacity);
    }

    switch (type) {
      case NotificationType.success:
        return successColor;
      case NotificationType.error:
        return errorColor;
      case NotificationType.warning:
        return warningColor;
      case NotificationType.info:
        return infoColor;
    }
  }

  /// 获取适应主题的文字颜色
  Color getTextColorForTheme(BuildContext? context) {
    if (context != null) {
      final brightness = Theme.of(context).brightness;
      return brightness == Brightness.dark ? Colors.white : Colors.black87;
    }
    return textColor;
  }

  Color getIconColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return successColor;
      case NotificationType.error:
        return errorColor;
      case NotificationType.warning:
        return warningColor;
      case NotificationType.info:
        return infoColor;
    }
  }

  IconData getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return successIcon;
      case NotificationType.error:
        return errorIcon;
      case NotificationType.warning:
        return warningIcon;
      case NotificationType.info:
        return infoIcon;
    }
  }
}
