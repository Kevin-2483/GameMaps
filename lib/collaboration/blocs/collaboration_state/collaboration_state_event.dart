import 'dart:ui';
import 'package:equatable/equatable.dart';
import '../../models/collaboration_state.dart';

/// 协作状态事件基类
abstract class CollaborationStateEvent extends Equatable {
  const CollaborationStateEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化协作状态
class InitializeCollaborationState extends CollaborationStateEvent {
  final String userId;
  final String displayName;
  final Color userColor;

  const InitializeCollaborationState({
    required this.userId,
    required this.displayName,
    required this.userColor,
  });

  @override
  List<Object?> get props => [userId, displayName, userColor];
}

/// 尝试锁定元素
class TryLockElement extends CollaborationStateEvent {
  final String elementId;
  final String elementType;
  final bool isHardLock;
  final int? timeoutSeconds;

  const TryLockElement({
    required this.elementId,
    required this.elementType,
    this.isHardLock = false,
    this.timeoutSeconds,
  });

  @override
  List<Object?> get props => [
    elementId,
    elementType,
    isHardLock,
    timeoutSeconds,
  ];
}

/// 释放元素锁定
class UnlockElement extends CollaborationStateEvent {
  final String elementId;

  const UnlockElement({required this.elementId});

  @override
  List<Object?> get props => [elementId];
}

/// 更新用户选择
class UpdateUserSelection extends CollaborationStateEvent {
  final List<String> selectedElementIds;
  final String? selectionType;

  const UpdateUserSelection({
    required this.selectedElementIds,
    this.selectionType,
  });

  @override
  List<Object?> get props => [selectedElementIds, selectionType];
}

/// 清除用户选择
class ClearUserSelection extends CollaborationStateEvent {
  const ClearUserSelection();
}

/// 更新用户指针位置
class UpdateUserCursor extends CollaborationStateEvent {
  final Offset position;
  final bool isVisible;

  const UpdateUserCursor({required this.position, this.isVisible = true});

  @override
  List<Object?> get props => [position, isVisible];
}

/// 隐藏用户指针
class HideUserCursor extends CollaborationStateEvent {
  const HideUserCursor();
}

/// 解决冲突
class ResolveConflict extends CollaborationStateEvent {
  final String conflictId;

  const ResolveConflict({required this.conflictId});

  @override
  List<Object?> get props => [conflictId];
}

/// 接收远程锁定状态
class ReceiveRemoteLockState extends CollaborationStateEvent {
  final ElementLockState lockState;

  const ReceiveRemoteLockState({required this.lockState});

  @override
  List<Object?> get props => [lockState];
}

/// 接收远程选择状态
class ReceiveRemoteSelectionState extends CollaborationStateEvent {
  final UserSelectionState selectionState;

  const ReceiveRemoteSelectionState({required this.selectionState});

  @override
  List<Object?> get props => [selectionState];
}

/// 接收远程指针状态
class ReceiveRemoteCursorState extends CollaborationStateEvent {
  final UserCursorState cursorState;

  const ReceiveRemoteCursorState({required this.cursorState});

  @override
  List<Object?> get props => [cursorState];
}

/// 移除用户状态（用户离线时）
class RemoveUserStates extends CollaborationStateEvent {
  final String userId;

  const RemoveUserStates({required this.userId});

  @override
  List<Object?> get props => [userId];
}
