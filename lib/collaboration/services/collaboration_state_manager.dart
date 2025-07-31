// This file has been processed by AI for internationalization
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/collaboration_state.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// 协作状态管理器
/// 独立于WebSocket的协作状态管理，为WebRTC做准备
class CollaborationStateManager {
  static final CollaborationStateManager _instance =
      CollaborationStateManager._internal();
  factory CollaborationStateManager() => _instance;
  CollaborationStateManager._internal();

  // 当前用户信息
  String? _currentUserId;
  String? _currentUserDisplayName;
  Color? _currentUserColor;

  // 状态存储
  final Map<String, ElementLockState> _elementLocks = {};
  final Map<String, UserSelectionState> _userSelections = {};
  final Map<String, UserCursorState> _userCursors = {};
  final Map<String, CollaborationConflict> _conflicts = {};

  // 流控制器
  final StreamController<Map<String, ElementLockState>> _lockStateController =
      StreamController<Map<String, ElementLockState>>.broadcast();
  final StreamController<Map<String, UserSelectionState>>
  _selectionStateController =
      StreamController<Map<String, UserSelectionState>>.broadcast();
  final StreamController<Map<String, UserCursorState>> _cursorStateController =
      StreamController<Map<String, UserCursorState>>.broadcast();
  final StreamController<Map<String, CollaborationConflict>>
  _conflictController =
      StreamController<Map<String, CollaborationConflict>>.broadcast();

  // 定时器
  Timer? _cleanupTimer;
  Timer? _lockTimeoutTimer;

  // 配置
  static const Duration _cursorTimeout = Duration(seconds: 5);
  static const Duration _cleanupInterval = Duration(seconds: 10);

  // Getters
  String? get currentUserId => _currentUserId;
  String? get currentUserDisplayName => _currentUserDisplayName;
  Color? get currentUserColor => _currentUserColor;

  Map<String, ElementLockState> get elementLocks =>
      Map.unmodifiable(_elementLocks);
  Map<String, UserSelectionState> get userSelections =>
      Map.unmodifiable(_userSelections);
  Map<String, UserCursorState> get userCursors =>
      Map.unmodifiable(_userCursors);
  Map<String, CollaborationConflict> get conflicts =>
      Map.unmodifiable(_conflicts);

  // 流
  Stream<Map<String, ElementLockState>> get lockStateStream =>
      _lockStateController.stream;
  Stream<Map<String, UserSelectionState>> get selectionStateStream =>
      _selectionStateController.stream;
  Stream<Map<String, UserCursorState>> get cursorStateStream =>
      _cursorStateController.stream;
  Stream<Map<String, CollaborationConflict>> get conflictStream =>
      _conflictController.stream;

  /// 初始化协作状态管理器
  void initialize({
    required String userId,
    required String displayName,
    Color? userColor,
  }) {
    _currentUserId = userId;
    _currentUserDisplayName = displayName;
    _currentUserColor = userColor ?? _generateUserColor(userId);

    // 启动定时清理
    _startCleanupTimer();
    _startLockTimeoutTimer();

    debugPrint(
      '[CollaborationStateManager] ${LocalizationService.instance.current.initializationComplete_7421}: userId=$userId, displayName=$displayName',
    );
  }

  /// 销毁管理器
  void dispose() {
    _cleanupTimer?.cancel();
    _lockTimeoutTimer?.cancel();
    _lockStateController.close();
    _selectionStateController.close();
    _cursorStateController.close();
    _conflictController.close();
  }

  // ==================== 元素锁定管理 ====================

  /// 尝试锁定元素
  bool tryLockElement({
    required String elementId,
    required String elementType,
    bool isHardLock = false,
    int timeoutSeconds = 30,
  }) {
    if (_currentUserId == null) return false;

    // 检查是否已被其他用户锁定
    final existingLock = _elementLocks[elementId];
    if (existingLock != null) {
      if (existingLock.lockedByUserId != _currentUserId) {
        if (existingLock.isHardLock || !existingLock.isExpired) {
          // 创建锁定冲突
          _createConflict(
            elementId: elementId,
            conflictType: ConflictType.lockConflict,
            involvedUserIds: [_currentUserId!, existingLock.lockedByUserId],
            description: LocalizationService.instance.current
                .lockConflictDescription(_currentUserDisplayName ?? 'unknown'),
            elementType: elementType,
          );
          return false;
        }
      }
    }

    // 创建锁定状态
    final lockState = ElementLockState(
      elementId: elementId,
      elementType: elementType,
      lockedByUserId: _currentUserId!,
      lockedAt: DateTime.now(),
      timeoutSeconds: timeoutSeconds,
      isHardLock: isHardLock,
    );

    _elementLocks[elementId] = lockState;
    _notifyLockStateChanged();

    debugPrint(
      LocalizationService.instance.current.elementLockedSuccessfully_7281(
        _currentUserId ?? 'unknown',
        elementId,
      ),
    );
    return true;
  }

  /// 释放元素锁定
  bool unlockElement(String elementId) {
    if (_currentUserId == null) return false;

    final existingLock = _elementLocks[elementId];
    if (existingLock == null) return false;

    // 只能释放自己的锁定
    if (existingLock.lockedByUserId != _currentUserId) {
      debugPrint(
        '[CollaborationStateManager] ${LocalizationService.instance.current.cannotReleaseLock(elementId)}',
      );
      return false;
    }

    _elementLocks.remove(elementId);
    _notifyLockStateChanged();

    debugPrint(
      '[CollaborationStateManager] ${LocalizationService.instance.current.elementLockReleased_7425}: $elementId',
    );
    return true;
  }

  /// 检查元素是否被锁定
  bool isElementLocked(String elementId) {
    final lock = _elementLocks[elementId];
    return lock != null && !lock.isExpired;
  }

  /// 检查元素是否被当前用户锁定
  bool isElementLockedByCurrentUser(String elementId) {
    final lock = _elementLocks[elementId];
    return lock != null &&
        lock.lockedByUserId == _currentUserId &&
        !lock.isExpired;
  }

  /// 获取元素的锁定状态
  ElementLockState? getElementLockState(String elementId) {
    final lock = _elementLocks[elementId];
    return (lock != null && !lock.isExpired) ? lock : null;
  }

  // ==================== 用户选择管理 ====================

  /// 更新当前用户的选择状态
  void updateCurrentUserSelection({
    required List<String> selectedElementIds,
    required String selectionType,
  }) {
    if (_currentUserId == null) return;

    final selectionState = UserSelectionState(
      userId: _currentUserId!,
      selectedElementIds: selectedElementIds,
      selectionType: selectionType,
      lastUpdated: DateTime.now(),
    );

    _userSelections[_currentUserId!] = selectionState;
    _notifySelectionStateChanged();

    debugPrint(
      '[CollaborationStateManager] ' +
          LocalizationService.instance.current.selectedElementsUpdated(
            selectedElementIds.length,
          ),
    );
  }

  /// 清除当前用户的选择
  void clearCurrentUserSelection() {
    updateCurrentUserSelection(selectedElementIds: [], selectionType: 'none');
  }

  /// 获取用户的选择状态
  UserSelectionState? getUserSelection(String userId) {
    return _userSelections[userId];
  }

  /// 获取选中指定元素的用户列表
  List<String> getUsersSelectingElement(String elementId) {
    return _userSelections.values
        .where((selection) => selection.isElementSelected(elementId))
        .map((selection) => selection.userId)
        .toList();
  }

  // ==================== 用户指针位置管理 ====================

  /// 更新当前用户的指针位置
  void updateCurrentUserCursor({
    required Offset position,
    bool isVisible = true,
  }) {
    if (_currentUserId == null) return;

    final cursorState = UserCursorState(
      userId: _currentUserId!,
      position: position,
      isVisible: isVisible,
      lastUpdated: DateTime.now(),
      displayName: _currentUserDisplayName!,
      userColor: _currentUserColor!,
    );

    _userCursors[_currentUserId!] = cursorState;
    _notifyCursorStateChanged();
  }

  /// 隐藏当前用户的指针
  void hideCurrentUserCursor() {
    if (_currentUserId == null) return;

    final existingCursor = _userCursors[_currentUserId!];
    if (existingCursor != null) {
      _userCursors[_currentUserId!] = existingCursor.copyWith(isVisible: false);
      _notifyCursorStateChanged();
    }
  }

  /// 获取其他用户的可见指针
  List<UserCursorState> getOtherUsersCursors() {
    return _userCursors.values
        .where(
          (cursor) =>
              cursor.userId != _currentUserId &&
              cursor.isVisible &&
              !cursor.isExpired(_cursorTimeout),
        )
        .toList();
  }

  // ==================== 冲突管理 ====================

  /// 创建冲突
  void _createConflict({
    required String elementId,
    required ConflictType conflictType,
    required List<String> involvedUserIds,
    required String description,
    String? elementType,
  }) {
    final conflictId = _generateConflictId();
    final conflict = CollaborationConflict(
      conflictId: conflictId,
      elementId: elementId,
      conflictType: conflictType,
      involvedUserIds: involvedUserIds,
      occurredAt: DateTime.now(),
      description: description,
      elementType: elementType ?? 'unknown',
    );

    _conflicts[conflictId] = conflict;
    _notifyConflictChanged();

    debugPrint(
      '[CollaborationStateManager] ${LocalizationService.instance.current.conflictCreated_7425}: \$conflictId - \$description',
    );
  }

  /// 解决冲突
  void resolveConflict(String conflictId) {
    final conflict = _conflicts[conflictId];
    if (conflict != null) {
      _conflicts[conflictId] = CollaborationConflict(
        conflictId: conflict.conflictId,
        elementId: conflict.elementId,
        conflictType: conflict.conflictType,
        involvedUserIds: conflict.involvedUserIds,
        occurredAt: conflict.occurredAt,
        description: conflict.description,
        isResolved: true,
        elementType: conflict.elementType,
      );
      _notifyConflictChanged();

      debugPrint(
        '[CollaborationStateManager] ${LocalizationService.instance.current.conflictResolved_7421}: $conflictId',
      );
    }
  }

  /// 获取未解决的冲突
  List<CollaborationConflict> getUnresolvedConflicts() {
    return _conflicts.values.where((conflict) => !conflict.isResolved).toList();
  }

  // ==================== 用户在线状态管理 ====================

  /// 模拟方法：检查用户是否离线
  /// 为WebRTC协议准备，当前始终返回离线状态
  ///
  /// [userId] 要检查的用户ID，如果为null则检查当前用户
  /// 返回true表示用户离线，false表示在线
  bool isUserOffline([String? userId]) {
    // TODO: 将来集成WebRTC协议时，这里将实现真实的在线状态检测
    // 当前为模拟实现，始终返回离线状态
    debugPrint(
      '[CollaborationStateManager] ${LocalizationService.instance.current.simulateCheckUserOfflineStatus_4821}: ${userId ?? _currentUserId} - ${LocalizationService.instance.current.offline_4821}',
    );
    return true;
  }

  /// 模拟方法：检查当前用户是否离线
  /// 为WebRTC协议准备，当前始终返回离线状态
  bool isCurrentUserOffline() {
    return isUserOffline(_currentUserId);
  }

  // ==================== 远程状态同步 ====================

  /// 接收远程用户的锁定状态
  void receiveRemoteLockState(ElementLockState lockState) {
    _elementLocks[lockState.elementId] = lockState;
    _notifyLockStateChanged();
  }

  /// 接收远程用户的选择状态
  void receiveRemoteSelectionState(UserSelectionState selectionState) {
    _userSelections[selectionState.userId] = selectionState;
    _notifySelectionStateChanged();
  }

  /// 接收远程用户的指针状态
  void receiveRemoteCursorState(UserCursorState cursorState) {
    _userCursors[cursorState.userId] = cursorState;
    _notifyCursorStateChanged();
  }

  /// 移除用户的所有状态（用户离线时调用）
  void removeUserStates(String userId) {
    // 移除用户的锁定
    _elementLocks.removeWhere((_, lock) => lock.lockedByUserId == userId);

    // 移除用户的选择
    _userSelections.remove(userId);

    // 移除用户的指针
    _userCursors.remove(userId);

    // 通知状态变更
    _notifyLockStateChanged();
    _notifySelectionStateChanged();
    _notifyCursorStateChanged();

    debugPrint(
      '[CollaborationStateManager] ${LocalizationService.instance.current.userStateRemoved_4821}: $userId',
    );
  }

  // ==================== 私有方法 ====================

  /// 生成用户颜色
  Color _generateUserColor(String userId) {
    final hash = userId.hashCode;
    final random = Random(hash);
    return Color.fromARGB(
      255,
      100 + random.nextInt(156), // 100-255
      100 + random.nextInt(156), // 100-255
      100 + random.nextInt(156), // 100-255
    );
  }

  /// 生成冲突ID
  String _generateConflictId() {
    return 'conflict_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  /// 启动清理定时器
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      _cleanupExpiredStates();
    });
  }

  /// 启动锁定超时定时器
  void _startLockTimeoutTimer() {
    _lockTimeoutTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkLockTimeouts();
    });
  }

  /// 清理过期状态
  void _cleanupExpiredStates() {
    bool hasChanges = false;

    // 清理过期的指针状态
    final expiredCursors = _userCursors.keys
        .where((userId) => _userCursors[userId]!.isExpired(_cursorTimeout))
        .toList();

    for (final userId in expiredCursors) {
      _userCursors.remove(userId);
      hasChanges = true;
    }

    // 清理已解决的旧冲突
    final oldConflicts = _conflicts.keys.where((conflictId) {
      final conflict = _conflicts[conflictId]!;
      return conflict.isResolved &&
          DateTime.now().difference(conflict.occurredAt).inMinutes > 5;
    }).toList();

    for (final conflictId in oldConflicts) {
      _conflicts.remove(conflictId);
      hasChanges = true;
    }

    if (hasChanges) {
      _notifyCursorStateChanged();
      _notifyConflictChanged();
    }
  }

  /// 检查锁定超时
  void _checkLockTimeouts() {
    final expiredLocks = _elementLocks.keys
        .where((elementId) => _elementLocks[elementId]!.isExpired)
        .toList();

    if (expiredLocks.isNotEmpty) {
      for (final elementId in expiredLocks) {
        _elementLocks.remove(elementId);
      }
      _notifyLockStateChanged();
      debugPrint(
        '[CollaborationStateManager] ${LocalizationService.instance.current.expiredLocksCleaned_4821(expiredLocks.length)}',
      );
    }
  }

  /// 通知锁定状态变更
  void _notifyLockStateChanged() {
    _lockStateController.add(Map.from(_elementLocks));
  }

  /// 通知选择状态变更
  void _notifySelectionStateChanged() {
    _selectionStateController.add(Map.from(_userSelections));
  }

  /// 通知指针状态变更
  void _notifyCursorStateChanged() {
    _cursorStateController.add(Map.from(_userCursors));
  }

  /// 通知冲突状态变更
  void _notifyConflictChanged() {
    _conflictController.add(Map.from(_conflicts));
  }
}
