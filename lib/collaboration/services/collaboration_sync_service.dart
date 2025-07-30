// This file has been processed by AI for internationalization
import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/collaboration_state.dart';
import 'collaboration_state_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// 协作状态同步服务
/// 负责与远程服务器同步协作状态数据
/// 独立于WebSocket的在线状态管理
class CollaborationSyncService {
  static CollaborationSyncService? _instance;
  static CollaborationSyncService get instance =>
      _instance ??= CollaborationSyncService._();

  CollaborationSyncService._();

  final CollaborationStateManager _stateManager = CollaborationStateManager();

  // 同步状态
  bool _isInitialized = false;
  bool _isSyncEnabled = false;

  // 同步配置
  Duration _syncInterval = const Duration(milliseconds: 500);
  Duration _batchDelay = const Duration(milliseconds: 100);

  // 定时器和批处理
  Timer? _syncTimer;
  Timer? _batchTimer;
  final List<_PendingSyncData> _pendingSyncQueue = [];

  // 回调函数
  Function(Map<String, dynamic>)? _onSendToRemote;
  Function(String, String)? _onUserJoined;
  Function(String)? _onUserLeft;

  // 流控制器
  final StreamController<CollaborationSyncEvent> _eventController =
      StreamController<CollaborationSyncEvent>.broadcast();

  /// 同步事件流
  Stream<CollaborationSyncEvent> get eventStream => _eventController.stream;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 是否启用同步
  bool get isSyncEnabled => _isSyncEnabled;

  /// 初始化同步服务
  Future<void> initialize({
    required String userId,
    required String displayName,
    required Color userColor,
    required Function(Map<String, dynamic>) onSendToRemote,
    Function(String, String)? onUserJoined,
    Function(String)? onUserLeft,
    Duration? syncInterval,
    Duration? batchDelay,
  }) async {
    if (_isInitialized) {
      debugPrint(
        '[CollaborationSyncService] ${LocalizationService.instance.current.serviceInitialized_7421}',
      );
      return;
    }

    try {
      // 初始化状态管理器
      _stateManager.initialize(
        userId: userId,
        displayName: displayName,
        userColor: userColor,
      );

      // 设置回调函数
      _onSendToRemote = onSendToRemote;
      _onUserJoined = onUserJoined;
      _onUserLeft = onUserLeft;

      // 设置同步配置
      if (syncInterval != null) _syncInterval = syncInterval;
      if (batchDelay != null) _batchDelay = batchDelay;

      // 订阅状态变更
      _subscribeToStateChanges();

      _isInitialized = true;
      _eventController.add(const CollaborationSyncInitialized());

      debugPrint(
        '[CollaborationSyncService] ' +
            LocalizationService.instance.current.syncServiceInitialized,
      );
    } catch (e, stackTrace) {
      _eventController.add(
        CollaborationSyncError(
          message: LocalizationService.instance.current.syncServiceInitFailed(
            e.toString(),
          ),
          error: e,
          stackTrace: stackTrace,
        ),
      );
      rethrow;
    }
  }

  /// 启用同步
  void enableSync() {
    if (!_isInitialized) {
      throw StateError(
        LocalizationService.instance.current.syncServiceNotInitialized_7281,
      );
    }

    if (_isSyncEnabled) return;

    _isSyncEnabled = true;
    _startSyncTimer();
    _eventController.add(const CollaborationSyncEnabled());

    debugPrint(
      '[CollaborationSyncService] ${LocalizationService.instance.current.syncEnabled_7421}',
    );
  }

  /// 禁用同步
  void disableSync() {
    if (!_isSyncEnabled) return;

    _isSyncEnabled = false;
    _stopSyncTimer();
    _eventController.add(const CollaborationSyncDisabled());

    debugPrint(
      '[CollaborationSyncService] ${LocalizationService.instance.current.syncDisabled_7421}',
    );
  }

  /// 处理接收到的远程数据
  Future<void> handleRemoteData(Map<String, dynamic> data) async {
    if (!_isInitialized) {
      debugPrint(
        '[CollaborationSyncService] ' +
            LocalizationService
                .instance
                .current
                .serviceNotInitializedIgnoreData_7283,
      );
      return;
    }

    try {
      final type = data['type'] as String?;
      final payload = data['payload'] as Map<String, dynamic>?;

      if (type == null || payload == null) {
        debugPrint(
          '[CollaborationSyncService] ' +
              LocalizationService.instance.current.invalidRemoteDataFormat_7281,
        );
        return;
      }

      switch (type) {
        case 'element_lock':
          await _handleRemoteElementLock(payload);
          break;
        case 'user_selection':
          await _handleRemoteUserSelection(payload);
          break;
        case 'user_cursor':
          await _handleRemoteUserCursor(payload);
          break;
        case 'user_joined':
          await _handleRemoteUserJoined(payload);
          break;
        case 'user_left':
          await _handleRemoteUserLeft(payload);
          break;
        case 'conflict':
          await _handleRemoteConflict(payload);
          break;
        default:
          debugPrint(
            '[CollaborationSyncService] ' +
                LocalizationService.instance.current.unknownRemoteDataType_4721(
                  type,
                ),
          );
      }
    } catch (e, stackTrace) {
      _eventController.add(
        CollaborationSyncError(
          message: LocalizationService.instance.current
              .remoteDataProcessingFailed_7421(e.toString()),
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// 手动触发同步
  Future<void> triggerSync() async {
    if (!_isInitialized || !_isSyncEnabled) return;

    await _processPendingSync();
  }

  /// 清理资源
  Future<void> dispose() async {
    _stopSyncTimer();
    _stopBatchTimer();
    _pendingSyncQueue.clear();

    await _eventController.close();

    _isInitialized = false;
    _isSyncEnabled = false;

    debugPrint(
      '[CollaborationSyncService] ${LocalizationService.instance.current.syncServiceCleanedUp_7421}',
    );
  }

  // ==================== 私有方法 ====================

  /// 订阅状态变更
  void _subscribeToStateChanges() {
    // 订阅锁定状态变更
    _stateManager.lockStateStream.listen((locks) {
      _queueSyncData(
        _PendingSyncData(
          type: 'element_lock_batch',
          data: {'locks': locks.map((k, v) => MapEntry(k, v.toJson()))},
        ),
      );
    });

    // 订阅选择状态变更
    _stateManager.selectionStateStream.listen((selections) {
      final currentUserSelection = selections[_stateManager.currentUserId];
      if (currentUserSelection != null) {
        _queueSyncData(
          _PendingSyncData(
            type: 'user_selection',
            data: currentUserSelection.toJson(),
          ),
        );
      }
    });

    // 订阅指针状态变更
    _stateManager.cursorStateStream.listen((cursors) {
      final currentUserCursor = cursors[_stateManager.currentUserId];
      if (currentUserCursor != null) {
        _queueSyncData(
          _PendingSyncData(
            type: 'user_cursor',
            data: currentUserCursor.toJson(),
          ),
        );
      }
    });

    // 订阅冲突变更
    _stateManager.conflictStream.listen((conflicts) {
      for (final conflict in conflicts.values) {
        if (!conflict.isResolved) {
          _queueSyncData(
            _PendingSyncData(type: 'conflict', data: conflict.toJson()),
          );
        }
      }
    });
  }

  /// 将数据加入同步队列
  void _queueSyncData(_PendingSyncData syncData) {
    if (!_isSyncEnabled) return;

    _pendingSyncQueue.add(syncData);
    _startBatchTimer();
  }

  /// 启动同步定时器
  void _startSyncTimer() {
    _stopSyncTimer();
    _syncTimer = Timer.periodic(_syncInterval, (_) => _processPendingSync());
  }

  /// 停止同步定时器
  void _stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// 启动批处理定时器
  void _startBatchTimer() {
    _stopBatchTimer();
    _batchTimer = Timer(_batchDelay, _processPendingSync);
  }

  /// 停止批处理定时器
  void _stopBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = null;
  }

  /// 处理待同步数据
  Future<void> _processPendingSync() async {
    if (_pendingSyncQueue.isEmpty || _onSendToRemote == null) return;

    final syncData = List<_PendingSyncData>.from(_pendingSyncQueue);
    _pendingSyncQueue.clear();
    _stopBatchTimer();

    try {
      // 批量发送数据
      final batchData = {
        'type': 'collaboration_batch',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'userId': _stateManager.currentUserId,
        'items': syncData
            .map((item) => {'type': item.type, 'data': item.data})
            .toList(),
      };

      _onSendToRemote!(batchData);

      _eventController.add(
        CollaborationSyncDataSent(itemCount: syncData.length),
      );
    } catch (e, stackTrace) {
      _eventController.add(
        CollaborationSyncError(
          message: LocalizationService.instance.current.syncDataFailed_7285(
            e.toString(),
          ),
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// 处理远程元素锁定
  Future<void> _handleRemoteElementLock(Map<String, dynamic> data) async {
    try {
      final lockState = ElementLockState.fromJson(data);
      _stateManager.receiveRemoteLockState(lockState);
    } catch (e) {
      debugPrint('[CollaborationSyncService] 处理远程元素锁定失败: $e');
    }
  }

  /// 处理远程用户选择
  Future<void> _handleRemoteUserSelection(Map<String, dynamic> data) async {
    try {
      final selectionState = UserSelectionState.fromJson(data);
      _stateManager.receiveRemoteSelectionState(selectionState);
    } catch (e) {
      debugPrint(
        '[CollaborationSyncService] ${LocalizationService.instance.current.remoteUserSelectionFailed_7421}: $e',
      );
    }
  }

  /// 处理远程用户指针
  Future<void> _handleRemoteUserCursor(Map<String, dynamic> data) async {
    try {
      final cursorState = UserCursorState.fromJson(data);
      _stateManager.receiveRemoteCursorState(cursorState);
    } catch (e) {
      debugPrint(
        '[CollaborationSyncService] ${LocalizationService.instance.current.remotePointerError_4821}: $e',
      );
    }
  }

  /// 处理远程用户加入
  Future<void> _handleRemoteUserJoined(Map<String, dynamic> data) async {
    try {
      final userId = data['userId'] as String;
      final displayName = data['displayName'] as String;

      _onUserJoined?.call(userId, displayName);

      _eventController.add(
        CollaborationUserJoined(userId: userId, displayName: displayName),
      );
    } catch (e) {
      debugPrint(
        '[CollaborationSyncService] ${LocalizationService.instance.current.remoteUserJoinFailure_4821}: $e',
      );
    }
  }

  /// 处理远程用户离开
  Future<void> _handleRemoteUserLeft(Map<String, dynamic> data) async {
    try {
      final userId = data['userId'] as String;

      _stateManager.removeUserStates(userId);
      _onUserLeft?.call(userId);

      _eventController.add(CollaborationUserLeft(userId: userId));
    } catch (e) {
      debugPrint('[CollaborationSyncService] 处理远程用户离开失败: $e');
    }
  }

  /// 处理远程冲突
  Future<void> _handleRemoteConflict(Map<String, dynamic> data) async {
    try {
      final conflict = CollaborationConflict.fromJson(data);
      // 冲突处理逻辑可以在这里实现
      _eventController.add(CollaborationConflictDetected(conflict: conflict));
    } catch (e) {
      debugPrint('[CollaborationSyncService] 处理远程冲突失败: $e');
    }
  }

  // ==================== 公共访问方法 ====================

  /// 获取状态管理器（用于Bloc集成）
  CollaborationStateManager get stateManager => _stateManager;
}

/// 待同步数据
class _PendingSyncData {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _PendingSyncData({required this.type, required this.data})
    : timestamp = DateTime.now();
}

// ==================== 同步事件定义 ====================

/// 协作同步事件基类
abstract class CollaborationSyncEvent {
  const CollaborationSyncEvent();
}

/// 同步服务已初始化
class CollaborationSyncInitialized extends CollaborationSyncEvent {
  const CollaborationSyncInitialized();
}

/// 同步已启用
class CollaborationSyncEnabled extends CollaborationSyncEvent {
  const CollaborationSyncEnabled();
}

/// 同步已禁用
class CollaborationSyncDisabled extends CollaborationSyncEvent {
  const CollaborationSyncDisabled();
}

/// 同步数据已发送
class CollaborationSyncDataSent extends CollaborationSyncEvent {
  final int itemCount;

  const CollaborationSyncDataSent({required this.itemCount});
}

/// 用户加入协作
class CollaborationUserJoined extends CollaborationSyncEvent {
  final String userId;
  final String displayName;

  const CollaborationUserJoined({
    required this.userId,
    required this.displayName,
  });
}

/// 用户离开协作
class CollaborationUserLeft extends CollaborationSyncEvent {
  final String userId;

  const CollaborationUserLeft({required this.userId});
}

/// 检测到协作冲突
class CollaborationConflictDetected extends CollaborationSyncEvent {
  final CollaborationConflict conflict;

  const CollaborationConflictDetected({required this.conflict});
}

/// 同步错误
class CollaborationSyncError extends CollaborationSyncEvent {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const CollaborationSyncError({
    required this.message,
    this.error,
    this.stackTrace,
  });
}
