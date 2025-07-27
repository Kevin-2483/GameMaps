import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../models/collaboration_state.dart';
import '../../services/collaboration_state_manager.dart';
import 'collaboration_state_event.dart';
import 'collaboration_state_state.dart';

/// 协作状态Bloc
/// 管理协作相关的UI状态和用户交互
class CollaborationStateBloc
    extends Bloc<CollaborationStateEvent, CollaborationStateBlocState> {
  final CollaborationStateManager _stateManager;

  // 订阅管理
  StreamSubscription? _lockStateSubscription;
  StreamSubscription? _selectionStateSubscription;
  StreamSubscription? _cursorStateSubscription;
  StreamSubscription? _conflictSubscription;

  CollaborationStateBloc({CollaborationStateManager? stateManager})
    : _stateManager = stateManager ?? CollaborationStateManager(),
      super(const CollaborationStateInitial()) {
    // 注册事件处理器
    on<InitializeCollaborationState>(_onInitializeCollaborationState);
    on<TryLockElement>(_onTryLockElement);
    on<UnlockElement>(_onUnlockElement);
    on<UpdateUserSelection>(_onUpdateUserSelection);
    on<ClearUserSelection>(_onClearUserSelection);
    on<UpdateUserCursor>(_onUpdateUserCursor);
    on<HideUserCursor>(_onHideUserCursor);
    on<ResolveConflict>(_onResolveConflict);
    on<ReceiveRemoteLockState>(_onReceiveRemoteLockState);
    on<ReceiveRemoteSelectionState>(_onReceiveRemoteSelectionState);
    on<ReceiveRemoteCursorState>(_onReceiveRemoteCursorState);
    on<RemoveUserStates>(_onRemoveUserStates);
    on<_InternalStateUpdate>(_onInternalStateUpdate);

    // 订阅状态管理器的变更
    _subscribeToStateManager();
  }

  @override
  Future<void> close() {
    _lockStateSubscription?.cancel();
    _selectionStateSubscription?.cancel();
    _cursorStateSubscription?.cancel();
    _conflictSubscription?.cancel();
    return super.close();
  }

  /// 订阅状态管理器的变更
  void _subscribeToStateManager() {
    _lockStateSubscription = _stateManager.lockStateStream.listen((locks) {
      add(_InternalStateUpdate());
    });

    _selectionStateSubscription = _stateManager.selectionStateStream.listen((
      selections,
    ) {
      add(_InternalStateUpdate());
    });

    _cursorStateSubscription = _stateManager.cursorStateStream.listen((
      cursors,
    ) {
      add(_InternalStateUpdate());
    });

    _conflictSubscription = _stateManager.conflictStream.listen((conflicts) {
      add(_InternalStateUpdate());
    });
  }

  /// 初始化协作状态
  Future<void> _onInitializeCollaborationState(
    InitializeCollaborationState event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    try {
      emit(const CollaborationStateLoading());

      _stateManager.initialize(
        userId: event.userId,
        displayName: event.displayName,
        userColor: event.userColor,
      );

      emit(
        CollaborationStateLoaded(
          elementLocks: _stateManager.elementLocks,
          userSelections: _stateManager.userSelections,
          userCursors: _stateManager.userCursors,
          conflicts: _stateManager.conflicts.values.toList(),
          currentUserId: _stateManager.currentUserId ?? 'unknown',
          currentUserDisplayName:
              _stateManager.currentUserDisplayName ?? 'Unknown User',
          currentUserColor: _stateManager.currentUserColor ?? Colors.grey,
        ),
      );

      debugPrint('[CollaborationStateBloc] 协作状态初始化完成');
    } catch (e, stackTrace) {
      emit(
        CollaborationStateError(
          message: '初始化协作状态失败: ${e.toString()}',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// 尝试锁定元素
  Future<void> _onTryLockElement(
    TryLockElement event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    final success = _stateManager.tryLockElement(
      elementId: event.elementId,
      elementType: event.elementType,
      isHardLock: event.isHardLock,
      timeoutSeconds: event.timeoutSeconds ?? 30,
    );

    if (!success) {
      debugPrint('[CollaborationStateBloc] 元素锁定失败: ${event.elementId}');
      // 状态会通过内部更新事件自动更新
    }
  }

  /// 释放元素锁定
  Future<void> _onUnlockElement(
    UnlockElement event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    _stateManager.unlockElement(event.elementId);
  }

  /// 更新用户选择
  Future<void> _onUpdateUserSelection(
    UpdateUserSelection event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    _stateManager.updateCurrentUserSelection(
      selectedElementIds: event.selectedElementIds,
      selectionType: event.selectionType ?? 'default',
    );
  }

  /// 清除用户选择
  Future<void> _onClearUserSelection(
    ClearUserSelection event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    _stateManager.clearCurrentUserSelection();
  }

  /// 更新用户指针位置
  Future<void> _onUpdateUserCursor(
    UpdateUserCursor event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    _stateManager.updateCurrentUserCursor(
      position: event.position,
      isVisible: event.isVisible,
    );
  }

  /// 隐藏用户指针
  Future<void> _onHideUserCursor(
    HideUserCursor event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    _stateManager.hideCurrentUserCursor();
  }

  /// 解决冲突
  Future<void> _onResolveConflict(
    ResolveConflict event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    _stateManager.resolveConflict(event.conflictId);
  }

  /// 接收远程锁定状态
  Future<void> _onReceiveRemoteLockState(
    ReceiveRemoteLockState event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    _stateManager.receiveRemoteLockState(event.lockState);
  }

  /// 接收远程选择状态
  Future<void> _onReceiveRemoteSelectionState(
    ReceiveRemoteSelectionState event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    _stateManager.receiveRemoteSelectionState(event.selectionState);
  }

  /// 接收远程指针状态
  Future<void> _onReceiveRemoteCursorState(
    ReceiveRemoteCursorState event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    _stateManager.receiveRemoteCursorState(event.cursorState);
  }

  /// 移除用户状态
  Future<void> _onRemoveUserStates(
    RemoveUserStates event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    _stateManager.removeUserStates(event.userId);
  }

  /// 内部状态更新
  Future<void> _onInternalStateUpdate(
    _InternalStateUpdate event,
    Emitter<CollaborationStateBlocState> emit,
  ) async {
    final currentState = state;
    if (currentState is CollaborationStateLoaded) {
      emit(
        currentState.copyWith(
          elementLocks: _stateManager.elementLocks,
          userSelections: _stateManager.userSelections,
          userCursors: _stateManager.userCursors,
          conflicts: _stateManager.conflicts.values.toList(),
        ),
      );
    }
  }

  // ==================== 便捷方法 ====================

  /// 检查元素是否被锁定
  bool isElementLocked(String elementId) {
    return _stateManager.isElementLocked(elementId);
  }

  /// 检查元素是否被当前用户锁定
  bool isElementLockedByCurrentUser(String elementId) {
    return _stateManager.isElementLockedByCurrentUser(elementId);
  }

  /// 获取元素的锁定状态
  ElementLockState? getElementLockState(String elementId) {
    return _stateManager.getElementLockState(elementId);
  }

  /// 获取用户的选择状态
  UserSelectionState? getUserSelection(String userId) {
    return _stateManager.getUserSelection(userId);
  }

  /// 获取选中指定元素的用户列表
  List<String> getUsersSelectingElement(String elementId) {
    return _stateManager.getUsersSelectingElement(elementId);
  }

  /// 获取其他用户的可见指针
  List<UserCursorState> getOtherUsersCursors() {
    return _stateManager.getOtherUsersCursors();
  }

  /// 获取未解决的冲突
  List<CollaborationConflict> getUnresolvedConflicts() {
    return _stateManager.getUnresolvedConflicts();
  }

  /// 获取当前用户信息
  String? get currentUserId => _stateManager.currentUserId;
  String? get currentUserDisplayName => _stateManager.currentUserDisplayName;
  Color? get currentUserColor => _stateManager.currentUserColor;
}

/// 内部状态更新事件（私有）
class _InternalStateUpdate extends CollaborationStateEvent {
  const _InternalStateUpdate();
}
