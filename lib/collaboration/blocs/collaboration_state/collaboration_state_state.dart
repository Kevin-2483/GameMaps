import 'dart:ui';
import 'package:equatable/equatable.dart';
import '../../models/collaboration_state.dart';

/// 协作状态Bloc状态基类
abstract class CollaborationStateBlocState extends Equatable {
  const CollaborationStateBlocState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class CollaborationStateInitial extends CollaborationStateBlocState {
  const CollaborationStateInitial();
}

/// 加载中状态
class CollaborationStateLoading extends CollaborationStateBlocState {
  const CollaborationStateLoading();
}

/// 已加载状态
class CollaborationStateLoaded extends CollaborationStateBlocState {
  /// 元素锁定状态映射 (elementId -> ElementLockState)
  final Map<String, ElementLockState> elementLocks;

  /// 用户选择状态映射 (userId -> UserSelectionState)
  final Map<String, UserSelectionState> userSelections;

  /// 用户指针状态映射 (userId -> UserCursorState)
  final Map<String, UserCursorState> userCursors;

  /// 协作冲突列表
  final List<CollaborationConflict> conflicts;

  /// 当前用户信息
  final String currentUserId;
  final String currentUserDisplayName;
  final Color currentUserColor;

  const CollaborationStateLoaded({
    required this.elementLocks,
    required this.userSelections,
    required this.userCursors,
    required this.conflicts,
    required this.currentUserId,
    required this.currentUserDisplayName,
    required this.currentUserColor,
  });

  @override
  List<Object?> get props => [
    elementLocks,
    userSelections,
    userCursors,
    conflicts,
    currentUserId,
    currentUserDisplayName,
    currentUserColor,
  ];

  /// 复制状态并更新部分字段
  CollaborationStateLoaded copyWith({
    Map<String, ElementLockState>? elementLocks,
    Map<String, UserSelectionState>? userSelections,
    Map<String, UserCursorState>? userCursors,
    List<CollaborationConflict>? conflicts,
    String? currentUserId,
    String? currentUserDisplayName,
    Color? currentUserColor,
  }) {
    return CollaborationStateLoaded(
      elementLocks: elementLocks ?? this.elementLocks,
      userSelections: userSelections ?? this.userSelections,
      userCursors: userCursors ?? this.userCursors,
      conflicts: conflicts ?? this.conflicts,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUserDisplayName:
          currentUserDisplayName ?? this.currentUserDisplayName,
      currentUserColor: currentUserColor ?? this.currentUserColor,
    );
  }

  // ==================== 便捷查询方法 ====================

  /// 检查元素是否被锁定
  bool isElementLocked(String elementId) {
    final lockState = elementLocks[elementId];
    return lockState != null && !lockState.isExpired;
  }

  /// 检查元素是否被当前用户锁定
  bool isElementLockedByCurrentUser(String elementId) {
    final lockState = elementLocks[elementId];
    return lockState != null &&
        lockState.userId == currentUserId &&
        !lockState.isExpired;
  }

  /// 检查元素是否被其他用户锁定
  bool isElementLockedByOtherUser(String elementId) {
    final lockState = elementLocks[elementId];
    return lockState != null &&
        lockState.userId != currentUserId &&
        !lockState.isExpired;
  }

  /// 获取元素的锁定状态
  ElementLockState? getElementLockState(String elementId) {
    final lockState = elementLocks[elementId];
    return (lockState != null && !lockState.isExpired) ? lockState : null;
  }

  /// 获取当前用户锁定的元素列表
  List<String> getCurrentUserLockedElements() {
    return elementLocks.entries
        .where(
          (entry) =>
              entry.value.userId == currentUserId && !entry.value.isExpired,
        )
        .map((entry) => entry.key)
        .toList();
  }

  /// 获取其他用户锁定的元素列表
  List<String> getOtherUsersLockedElements() {
    return elementLocks.entries
        .where(
          (entry) =>
              entry.value.userId != currentUserId && !entry.value.isExpired,
        )
        .map((entry) => entry.key)
        .toList();
  }

  /// 获取用户的选择状态
  UserSelectionState? getUserSelection(String userId) {
    return userSelections[userId];
  }

  /// 获取当前用户的选择状态
  UserSelectionState? getCurrentUserSelection() {
    return userSelections[currentUserId];
  }

  /// 获取其他用户的选择状态列表
  List<UserSelectionState> getOtherUsersSelections() {
    return userSelections.entries
        .where((entry) => entry.key != currentUserId)
        .map((entry) => entry.value)
        .toList();
  }

  /// 获取选中指定元素的用户列表
  List<String> getUsersSelectingElement(String elementId) {
    return userSelections.entries
        .where((entry) => entry.value.selectedElementIds.contains(elementId))
        .map((entry) => entry.key)
        .toList();
  }

  /// 获取用户的指针状态
  UserCursorState? getUserCursor(String userId) {
    return userCursors[userId];
  }

  /// 获取当前用户的指针状态
  UserCursorState? getCurrentUserCursor() {
    return userCursors[currentUserId];
  }

  /// 获取其他用户的可见指针列表
  List<UserCursorState> getOtherUsersCursors() {
    return userCursors.entries
        .where((entry) => entry.key != currentUserId && entry.value.isVisible)
        .map((entry) => entry.value)
        .toList();
  }

  /// 获取未解决的冲突
  List<CollaborationConflict> getUnresolvedConflicts() {
    return conflicts.where((conflict) => !conflict.isResolved).toList();
  }

  /// 获取指定类型的冲突
  List<CollaborationConflict> getConflictsByType(ConflictType type) {
    return conflicts.where((conflict) => conflict.type == type).toList();
  }

  /// 获取涉及指定元素的冲突
  List<CollaborationConflict> getConflictsForElement(String elementId) {
    return conflicts
        .where((conflict) => conflict.elementId == elementId)
        .toList();
  }

  /// 检查是否有未解决的冲突
  bool get hasUnresolvedConflicts =>
      conflicts.any((conflict) => !conflict.isResolved);

  /// 获取在线用户数量（有活动状态的用户）
  int get activeUsersCount {
    final activeUserIds = <String>{};

    // 从选择状态中获取活跃用户
    activeUserIds.addAll(userSelections.keys);

    // 从指针状态中获取活跃用户
    activeUserIds.addAll(
      userCursors.keys.where((userId) => userCursors[userId]!.isVisible),
    );

    // 从锁定状态中获取活跃用户
    activeUserIds.addAll(
      elementLocks.values
          .where((lock) => !lock.isExpired)
          .map((lock) => lock.userId),
    );

    return activeUserIds.length;
  }

  /// 获取活跃用户ID列表
  List<String> get activeUserIds {
    final activeUserIds = <String>{};

    // 从选择状态中获取活跃用户
    activeUserIds.addAll(userSelections.keys);

    // 从指针状态中获取活跃用户
    activeUserIds.addAll(
      userCursors.keys.where((userId) => userCursors[userId]!.isVisible),
    );

    // 从锁定状态中获取活跃用户
    activeUserIds.addAll(
      elementLocks.values
          .where((lock) => !lock.isExpired)
          .map((lock) => lock.userId),
    );

    return activeUserIds.toList();
  }
}

/// 错误状态
class CollaborationStateError extends CollaborationStateBlocState {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const CollaborationStateError({
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, error, stackTrace];
}
