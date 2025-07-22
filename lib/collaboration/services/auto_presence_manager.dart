import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/presence/presence_bloc.dart';
import '../blocs/presence/presence_event.dart';
import '../models/user_presence.dart';
import 'websocket/websocket_client_manager.dart';
import 'websocket/websocket_client_service.dart';
import 'map_sync_service.dart';

/// 自动在线状态管理器
///
/// 负责监听各种事件并自动更新用户的在线状态：
/// - WebSocket连接时：设置为在线状态
/// - 进入地图编辑器时：设置为查看状态
/// - MapDataBloc发生变化时：设置为编辑状态
/// - 退出编辑器时：回归在线状态
class AutoPresenceManager {
  final PresenceBloc _presenceBloc;
  final WebSocketClientManager _webSocketManager;
  final MapSyncService _mapSyncService;

  // 订阅管理
  StreamSubscription? _webSocketSubscription;
  StreamSubscription? _mapDataSubscription;

  // 状态跟踪
  bool _isInEditor = false;
  bool _isEditingMap = false;
  Timer? _editingTimer;

  // 配置
  static const Duration _editingTimeout = Duration(
    seconds: 30,
  ); // 30秒无操作后从编辑状态回到查看状态

  AutoPresenceManager({
    required PresenceBloc presenceBloc,
    required WebSocketClientManager webSocketManager,
    required MapSyncService mapSyncService,
  }) : _presenceBloc = presenceBloc,
       _webSocketManager = webSocketManager,
       _mapSyncService = mapSyncService;

  /// 初始化自动状态管理
  void initialize() {
    _setupWebSocketListener();
  }

  /// 销毁管理器，清理资源
  void dispose() {
    _webSocketSubscription?.cancel();
    _mapDataSubscription?.cancel();
    _editingTimer?.cancel();
  }

  /// 设置WebSocket连接监听
  void _setupWebSocketListener() {
    _webSocketSubscription = _webSocketManager.connectionStateStream.listen((
      state,
    ) {
      if (state == WebSocketConnectionState.connected) {
        // WebSocket连接成功，设置为在线状态
        _updateStatus(UserActivityStatus.idle);
      } else {
        // WebSocket断开连接，设置为离线状态
        _updateStatus(UserActivityStatus.offline);
      }
    });
  }

  /// 进入地图编辑器
  ///
  /// [mapId] 地图ID
  /// [mapTitle] 地图标题
  /// [mapCover] 地图封面（可选）
  /// [mapDataBloc] 地图数据Bloc，用于监听编辑操作
  Future<void> enterMapEditor({
    required String mapId,
    required String mapTitle,
    Uint8List? mapCover,
    Bloc? mapDataBloc,
  }) async {
    debugPrint(
      '[AutoPresenceManager] enterMapEditor called with mapId: $mapId, mapTitle: $mapTitle, mapCover length: ${mapCover?.length}',
    );

    _isInEditor = true;
    _isEditingMap = false;
    _currentMapId = mapId; // 保存当前地图ID

    debugPrint('[AutoPresenceManager] 保存当前地图ID: $_currentMapId');

    // 同步地图信息
    await _mapSyncService.syncCurrentMapInfo(
      mapId: mapId,
      mapTitle: mapTitle,
      mapCover: mapCover,
    );

    debugPrint('[AutoPresenceManager] 地图信息同步完成');

    // 设置为查看状态
    _updateStatus(UserActivityStatus.viewing);

    // 如果提供了mapDataBloc，监听其状态变化
    if (mapDataBloc != null) {
      _setupMapDataListener(mapDataBloc);
    }
  }

  /// 退出地图编辑器
  void exitMapEditor() {
    _isInEditor = false;
    _isEditingMap = false;
    _currentMapId = null; // 清除当前地图ID

    // 清理地图数据监听
    _mapDataSubscription?.cancel();
    _mapDataSubscription = null;

    // 清理编辑计时器
    _editingTimer?.cancel();
    _editingTimer = null;

    // 清除地图信息
    _mapSyncService.clearCurrentMapInfo();

    // 根据WebSocket连接状态设置用户状态
    if (_webSocketManager.isConnected) {
      _updateStatus(UserActivityStatus.idle);
    } else {
      _updateStatus(UserActivityStatus.offline);
    }
  }

  /// 手动触发编辑状态（用于无法监听MapDataBloc的情况）
  void triggerEditingState() {
    if (!_isInEditor) return;

    _isEditingMap = true;
    _updateStatus(UserActivityStatus.editing);
    _resetEditingTimer();
  }

  // 当前地图信息
  String? _currentMapId;

  /// 更新地图标题
  void updateMapTitle(String newTitle) {
    debugPrint('[AutoPresenceManager] updateMapTitle called: $newTitle');
    debugPrint(
      '[AutoPresenceManager] _isInEditor: $_isInEditor, _currentMapId: $_currentMapId',
    );

    if (!_isInEditor || _currentMapId == null) {
      debugPrint('[AutoPresenceManager] 跳过更新地图标题：不在编辑器中或mapId为空');
      return;
    }

    _mapSyncService.updateMapTitle(_currentMapId!, newTitle);
    triggerEditingState();
  }

  /// 更新地图封面
  void updateMapCover(Uint8List newCover) {
    debugPrint(
      '[AutoPresenceManager] updateMapCover called, 封面大小: ${(newCover.length / 1024).toStringAsFixed(1)}KB',
    );
    debugPrint(
      '[AutoPresenceManager] _isInEditor: $_isInEditor, _currentMapId: $_currentMapId',
    );

    if (!_isInEditor || _currentMapId == null) {
      debugPrint('[AutoPresenceManager] 跳过更新地图封面：不在编辑器中或mapId为空');
      return;
    }

    _mapSyncService.updateMapCover(_currentMapId!, newCover);
    triggerEditingState();
  }

  /// 设置MapDataBloc监听
  void _setupMapDataListener(Bloc mapDataBloc) {
    _mapDataSubscription?.cancel();

    _mapDataSubscription = mapDataBloc.stream.listen((_) {
      // MapDataBloc状态发生变化，说明用户在编辑地图
      if (_isInEditor) {
        _isEditingMap = true;
        _updateStatus(UserActivityStatus.editing);
        _resetEditingTimer();
      }
    });
  }

  /// 重置编辑计时器
  void _resetEditingTimer() {
    _editingTimer?.cancel();
    _editingTimer = Timer(_editingTimeout, () {
      // 编辑超时，回到查看状态
      if (_isInEditor && _isEditingMap) {
        _isEditingMap = false;
        _updateStatus(UserActivityStatus.viewing);
      }
    });
  }

  /// 更新用户状态
  void _updateStatus(UserActivityStatus status) {
    _presenceBloc.add(UpdateCurrentUserStatus(status: status));
  }

  /// 获取当前状态信息
  Map<String, dynamic> get currentState => {
    'isInEditor': _isInEditor,
    'isEditingMap': _isEditingMap,
    'hasEditingTimer': _editingTimer?.isActive ?? false,
  };
}
