import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'notification_models.dart';
import 'notification_overlay_widget.dart';

/// 消息队列管理器
class NotificationQueueManager {
  static NotificationQueueManager? _instance;
  static NotificationQueueManager get instance {
    _instance ??= NotificationQueueManager._internal();
    return _instance!;
  }

  NotificationQueueManager._internal();

  /// 全局配置
  NotificationConfig _config = const NotificationConfig();
  NotificationTheme _theme = const NotificationTheme();

  /// 消息队列（按位置分组）
  final Map<NotificationPosition, Queue<NotificationMessage>> _queues = {};

  /// 当前显示的消息堆叠（按位置分组）
  final Map<NotificationPosition, List<NotificationMessage>> _currentStacks =
      {};

  /// 定时器（按位置和消息ID分组）
  final Map<String, Timer?> _timers = {};

  /// 每个通知的独立 Overlay entries
  final Map<String, OverlayEntry> _overlayEntries = {};

  /// 位置到通知ID列表的映射
  final Map<NotificationPosition, List<String>> _positionToIds = {};

  /// 用于生成唯一ID的计数器
  static int _idCounter = 0;

  /// 每个位置的总数通知器
  final Map<NotificationPosition, ValueNotifier<int>?> _totalInStackNotifiers =
      {};

  /// 每个位置的队列状态通知器 - 存储所有通知ID的有序列表
  final Map<NotificationPosition, ValueNotifier<List<String>>>
  _queueStateNotifiers = {};

  /// 通知内容更新通知器 - 用于触发UI更新
  final Map<String, ValueNotifier<int>> _notificationUpdateNotifiers = {};

  /// 全局 Overlay state
  OverlayState? _overlayState;

  /// 初始化配置
  void initialize({NotificationConfig? config, NotificationTheme? theme}) {
    if (config != null) {
      _config = config;
    }
    if (theme != null) {
      _theme = theme;
    }
  }

  /// 设置 Overlay state
  void setOverlayState(OverlayState overlayState) {
    _overlayState = overlayState;
  }

  /// 显示消息
  void show({
    String? id, // 🔑 新增：自定义通知ID
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
    if (_overlayState == null) {
      debugPrint('NotificationQueueManager: OverlayState not set');
      return;
    }

    final effectivePosition = position ?? _config.defaultPosition;
    // 🔑 如果是常驻显示，忽略duration参数
    final effectiveDuration = isPersistent
        ? null
        : (duration ?? _config.defaultDuration);
    final effectiveShowCloseButton =
        showCloseButton ?? _config.defaultShowCloseButton;
    final effectiveAllowStacking =
        allowStacking ?? _config.defaultAllowStacking;

    final notificationId =
        id ??
        '${DateTime.now().millisecondsSinceEpoch}_${_generateUniqueCounter()}';
    final notification = NotificationMessage(
      id: notificationId, // 🔑 使用自定义ID或生成默认ID
      message: message,
      type: type,
      position: effectivePosition,
      duration: effectiveDuration,
      showCloseButton: effectiveShowCloseButton,
      allowStacking: effectiveAllowStacking,
      isPersistent: isPersistent,
      borderEffect: borderEffect,
      onTap: onTap,
      onClose: onClose,
    );

    _addToQueue(notification, effectivePosition);
    _processQueue(effectivePosition);
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
    // 查找现有通知
    NotificationMessage? existingNotification;
    NotificationPosition? existingPosition;

    for (final entry in _currentStacks.entries) {
      final stack = entry.value;
      final pos = entry.key;
      final index = stack.indexWhere((msg) => msg.id == notificationId);
      if (index != -1) {
        existingNotification = stack[index];
        existingPosition = pos;
        break;
      }
    }

    if (existingNotification == null || existingPosition == null) {
      debugPrint(
        'NotificationQueueManager: Notification with id $notificationId not found',
      );
      return;
    }

    // 创建更新后的通知
    final updatedNotification = existingNotification.copyWith(
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

    // 更新堆叠中的通知
    final stack = _currentStacks[existingPosition]!;
    final index = stack.indexWhere((msg) => msg.id == notificationId);
    stack[index] = updatedNotification;

    // 如果位置发生变化，需要移动通知
    if (position != null && position != existingPosition) {
      // 从原位置移除
      stack.removeAt(index);
      _positionToIds[existingPosition]?.remove(notificationId);
      _removeNotificationOverlay(notificationId);

      // 添加到新位置
      _currentStacks[position] ??= [];
      _positionToIds[position] ??= [];
      _currentStacks[position]!.insert(0, updatedNotification);
      _positionToIds[position]!.insert(0, notificationId);

      // 更新通知器
      _updatePositionNotifiers(existingPosition);
      _updatePositionNotifiers(position);

      // 在新位置创建overlay
      _addNotificationOverlayWithIndex(
        updatedNotification,
        position,
        0,
        _currentStacks[position]!.length,
      );
    } else {
      // 位置未变化，触发现有overlay的更新
      _triggerNotificationUpdate(existingPosition);
    }

    // 更新定时器
    _cancelTimer(notificationId);
    _setTimer(updatedNotification, position ?? existingPosition);
  }

  /// 触发通知更新（不重新创建overlay）
  void _triggerNotificationUpdate(NotificationPosition position) {
    // 获取该位置的所有通知ID并触发更新
    final ids = _positionToIds[position];
    if (ids != null) {
      for (final id in ids) {
        if (_notificationUpdateNotifiers[id] != null) {
          // 增加版本号来触发UI更新
          _notificationUpdateNotifiers[id]!.value++;
        }
      }
    }
  }

  /// 根据ID获取通知
  NotificationMessage? _getNotificationById(String notificationId) {
    for (final stack in _currentStacks.values) {
      try {
        final notification = stack.firstWhere(
          (msg) => msg.id == notificationId,
        );
        return notification;
      } catch (e) {
        // 如果在当前stack中没有找到，继续查找下一个stack
        continue;
      }
    }
    return null;
  }

  /// 更新位置通知器
  void _updatePositionNotifiers(NotificationPosition position) {
    final stack = _currentStacks[position] ?? [];
    final ids = _positionToIds[position] ?? [];

    if (_totalInStackNotifiers[position] != null) {
      _totalInStackNotifiers[position]!.value = stack.length;
    }

    if (_queueStateNotifiers[position] != null) {
      _queueStateNotifiers[position]!.value = List<String>.from(ids);
    }
  }

  /// 添加到队列
  void _addToQueue(
    NotificationMessage notification,
    NotificationPosition position,
  ) {
    _queues[position] ??= Queue<NotificationMessage>();

    // 检查队列大小限制
    if (_queues[position]!.length >= _config.maxQueueSize) {
      _queues[position]!.removeFirst();
    }

    _queues[position]!.addLast(notification);
  }

  /// 处理队列
  void _processQueue(NotificationPosition position) {
    _queues[position] ??= Queue<NotificationMessage>();
    if (_queues[position]!.isEmpty) {
      return;
    }

    final notification = _queues[position]!.removeFirst();

    // 检查是否允许堆叠
    if (notification.allowStacking ?? _config.defaultAllowStacking) {
      _addToStack(notification, position);
    } else {
      // 不允许堆叠，清除当前堆叠并显示新消息
      _clearStack(position);
      _showSingleNotification(notification, position);
    }
  }

  /// 添加到堆叠
  void _addToStack(
    NotificationMessage notification,
    NotificationPosition position,
  ) {
    _currentStacks[position] ??= [];
    _positionToIds[position] ??= [];

    // 检查堆叠大小限制
    if (_currentStacks[position]!.length >= _config.maxStackSize) {
      // 移除最旧的消息（最后一个）
      final oldestMessage = _currentStacks[position]!.removeLast();
      final oldestId = _positionToIds[position]!.removeLast();
      _removeNotificationOverlay(oldestId);
      _cancelTimer(oldestMessage.id);
    }

    // 新通知总是插入到队列开头（stackIndex=0）
    _currentStacks[position]!.insert(0, notification);
    _positionToIds[position]!.insert(0, notification.id);

    // 更新队列状态通知器
    _queueStateNotifiers[position] ??= ValueNotifier<List<String>>([]);
    _queueStateNotifiers[position]!.value = List<String>.from(
      _positionToIds[position]!,
    );

    // 新通知的stackIndex总是0（最前面）
    _addNotificationOverlayWithIndex(
      notification,
      position,
      0,
      _currentStacks[position]!.length,
    );

    _setTimer(notification, position);
  }

  /// 清除堆叠
  void _clearStack(NotificationPosition position) {
    _clearStackAtPosition(position);
  }

  /// 显示单个通知（非堆叠）
  void _showSingleNotification(
    NotificationMessage notification,
    NotificationPosition position,
  ) {
    // 清除当前位置的所有通知
    _clearStackAtPosition(position);

    _currentStacks[position] = [notification];
    _positionToIds[position] = [notification.id];
    _addNotificationOverlay(notification, position);
    _setTimer(notification, position);
  }

  /// 添加单个通知的overlay
  void _addNotificationOverlay(
    NotificationMessage notification,
    NotificationPosition position,
  ) {
    if (_overlayState == null) return;

    final stack = _currentStacks[position] ?? [];
    final stackIndex = stack.indexOf(notification);
    if (stackIndex == -1) return;

    _addNotificationOverlayWithIndex(
      notification,
      position,
      stackIndex,
      stack.length,
    );
  }

  /// 添加单个通知的overlay（指定索引）
  void _addNotificationOverlayWithIndex(
    NotificationMessage notification,
    NotificationPosition position,
    int stackIndex,
    int totalInStack,
  ) {
    if (_overlayState == null) return;

    // 确保通知器已初始化
    _totalInStackNotifiers[position] ??= ValueNotifier<int>(0);
    _totalInStackNotifiers[position]!.value = totalInStack;

    _queueStateNotifiers[position] ??= ValueNotifier<List<String>>([]);

    // 为该通知创建更新通知器
    _notificationUpdateNotifiers[notification.id] ??= ValueNotifier<int>(0);
    final updateNotifier = _notificationUpdateNotifiers[notification.id];

    // 确保队列状态通知器存在
    _queueStateNotifiers[position] ??= ValueNotifier<List<String>>([]);
    final queueStateNotifier = _queueStateNotifiers[position];

    // 防止空值错误
    if (updateNotifier == null || queueStateNotifier == null) {
      debugPrint(
        'Warning: Failed to create notifiers for ${notification.id} at position $position',
      );
      return;
    }

    final overlayEntry = OverlayEntry(
      builder: (context) => NotificationOverlayWidget.single(
        notification: notification,
        config: _config,
        theme: _theme,
        stackIndex: stackIndex,
        totalInStackNotifier: _totalInStackNotifiers[position],
        queueStateNotifier: queueStateNotifier,
        notificationUpdateNotifier: updateNotifier,
        onClose: () => _hideNotificationById(notification.id, position),
        getUpdatedNotification: () => _getNotificationById(notification.id),
      ),
    );

    _overlayEntries[notification.id] = overlayEntry;
    _overlayState!.insert(overlayEntry);
  }

  /// 移除单个通知的overlay
  void _removeNotificationOverlay(String notificationId) {
    final overlayEntry = _overlayEntries[notificationId];
    if (overlayEntry != null) {
      overlayEntry.remove();
      _overlayEntries.remove(notificationId);
    }

    // 清理更新通知器
    _notificationUpdateNotifiers[notificationId]?.dispose();
    _notificationUpdateNotifiers.remove(notificationId);
  }

  /// 清除指定位置的所有通知
  void _clearStackAtPosition(NotificationPosition position) {
    final ids = _positionToIds[position];
    if (ids != null) {
      for (final id in List.from(ids)) {
        _removeNotificationOverlay(id);
        _cancelTimer(id);
      }
      ids.clear();
    }
    _currentStacks[position]?.clear();

    // 重置totalInStack通知器
    if (_totalInStackNotifiers[position] != null) {
      _totalInStackNotifiers[position]!.value = 0;
    }
  }

  /// 设置定时器
  void _setTimer(
    NotificationMessage notification,
    NotificationPosition position,
  ) {
    // 🔑 常驻通知不设置定时器
    if (notification.isPersistent) {
      return;
    }

    if (notification.duration != null &&
        notification.duration! > Duration.zero) {
      _timers[notification.id] = Timer(notification.duration!, () {
        _hideNotificationById(notification.id, position);
      });
    }
  }

  /// 取消定时器
  void _cancelTimer(String messageId) {
    _timers[messageId]?.cancel();
    _timers.remove(messageId);
  }

  /// 按ID隐藏通知
  void _hideNotificationById(String messageId, NotificationPosition position) {
    final stack = _currentStacks[position];
    if (stack == null) return;

    // 找到并移除指定消息
    final messageIndex = stack.indexWhere((msg) => msg.id == messageId);
    if (messageIndex == -1) return;

    final message = stack.removeAt(messageIndex);
    _positionToIds[position]?.remove(messageId);
    _removeNotificationOverlay(messageId);
    message.onClose?.call();
    _cancelTimer(messageId);

    // 更新通知器
    if (_totalInStackNotifiers[position] != null) {
      _totalInStackNotifiers[position]!.value = stack.length;
    }

    // 更新队列状态通知器，让所有通知自动重新计算位置
    if (_queueStateNotifiers[position] != null) {
      _queueStateNotifiers[position]!.value = List<String>.from(
        _positionToIds[position] ?? [],
      );
    }

    // 只有当堆叠为空时才处理队列中的下一个消息
    if (stack.isEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _processQueue(position);
      });
    }
  }

  /// 隐藏位置的所有通知
  void _hideNotification(NotificationPosition position) {
    _clearStackAtPosition(position);

    // 处理队列中的下一个消息
    Future.delayed(const Duration(milliseconds: 100), () {
      _processQueue(position);
    });
  }

  /// 隐藏指定位置的所有通知
  void hideAllAtPosition(NotificationPosition position) {
    _queues[position]?.clear();
    _hideNotification(position);
  }

  /// 隐藏所有通知
  void hideAll() {
    for (final position in NotificationPosition.values) {
      hideAllAtPosition(position);
    }
  }

  /// 获取当前队列长度
  int getQueueLength(NotificationPosition position) {
    return (_queues[position]?.length ?? 0) +
        (_currentStacks[position]?.length ?? 0);
  }

  /// 生成唯一计数器
  static int _generateUniqueCounter() {
    return ++_idCounter;
  }

  /// 清理资源
  void dispose() {
    // 清理所有overlay entries
    for (final overlayEntry in _overlayEntries.values) {
      overlayEntry.remove();
    }
    _overlayEntries.clear();

    // 清理ValueNotifier
    for (final notifier in _totalInStackNotifiers.values) {
      notifier?.dispose();
    }
    _totalInStackNotifiers.clear();

    // 清理队列状态通知器资源
    for (final notifier in _queueStateNotifiers.values) {
      notifier.dispose();
    }
    _queueStateNotifiers.clear();

    // 清理通知更新通知器
    for (final notifier in _notificationUpdateNotifiers.values) {
      notifier.dispose();
    }
    _notificationUpdateNotifiers.clear();

    // 清理其他资源
    _queues.clear();
    _currentStacks.clear();
    _positionToIds.clear();
    for (final timer in _timers.values) {
      timer?.cancel();
    }
    _timers.clear();
    _overlayState = null;
  }
}

/// 便捷方法扩展
extension NotificationQueueManagerExtension on NotificationQueueManager {
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
    show(
      message: message,
      type: NotificationType.success,
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
    show(
      message: message,
      type: NotificationType.error,
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
    show(
      message: message,
      type: NotificationType.warning,
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
    show(
      message: message,
      type: NotificationType.info,
      position: position,
      duration: duration,
      showCloseButton: showCloseButton,
      allowStacking: allowStacking,
      onTap: onTap,
      onClose: onClose,
    );
  }
}
