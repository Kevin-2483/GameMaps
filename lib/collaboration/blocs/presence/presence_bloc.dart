import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_presence.dart';
import '../../services/websocket/websocket_client_manager.dart';
import '../../services/websocket/websocket_client_service.dart'; // 添加WebSocketMessage导入
import '../../utils/image_compression_utils.dart';
// 注意：map_data_bloc 和 map_data_state 的导入已被移除
// 当前实现不再直接依赖 MapDataBloc
import 'presence_event.dart';
import 'presence_state.dart';

/// 用户在线状态管理Bloc
class PresenceBloc extends Bloc<PresenceEvent, PresenceState> {
  final WebSocketClientManager _webSocketManager;
  
  StreamSubscription<WebSocketMessage>? _messageSubscription;
  StreamSubscription? _mapDataSubscription; // 保留字段但不再使用
  Timer? _heartbeatTimer;
  Timer? _cleanupTimer;
  
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _cleanupInterval = Duration(minutes: 2);
  static const Duration _offlineThreshold = Duration(minutes: 5);

  PresenceBloc({
    required WebSocketClientManager webSocketManager,
  }) : _webSocketManager = webSocketManager,
       super(const PresenceInitial()) {
    
    // 注册事件处理器
    on<InitializePresence>(_onInitializePresence);
    on<UpdateCurrentUserStatus>(_onUpdateCurrentUserStatus);
    on<UpdateCurrentMapInfo>(_onUpdateCurrentMapInfo);
    on<ReceiveRemoteUserPresence>(_onReceiveRemoteUserPresence);
    on<UserJoinedCollaboration>(_onUserJoinedCollaboration);
    on<UserLeftCollaboration>(_onUserLeftCollaboration);
    on<CleanupOfflineUsers>(_onCleanupOfflineUsers);
    on<ResetAllPresence>(_onResetAllPresence);
    
    // 监听WebSocket消息
    _setupWebSocketListener();
    
    // 注意：_setupMapDataListener() 调用已被移除
    
    // 启动定时任务
    _startPeriodicTasks();
  }

  /// 初始化用户在线状态
  Future<void> _onInitializePresence(
    InitializePresence event,
    Emitter<PresenceState> emit,
  ) async {
    emit(const PresenceLoading());
    
    try {
      final currentUser = UserPresence(
        userId: event.currentUserId,
        userName: event.currentUserName,
        status: UserActivityStatus.idle,
        lastSeen: DateTime.now(),
        joinedAt: DateTime.now(),
      );
      
      emit(PresenceLoaded(
        currentUser: currentUser,
        remoteUsers: {},
        lastUpdated: DateTime.now(),
      ));
      
      // 广播当前用户加入
      await _broadcastPresenceUpdate(currentUser);
      
    } catch (error, stackTrace) {
      emit(PresenceError(
        message: '初始化用户状态失败',
        error: error,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 更新当前用户状态
  Future<void> _onUpdateCurrentUserStatus(
    UpdateCurrentUserStatus event,
    Emitter<PresenceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PresenceLoaded) return;
    
    final updatedUser = currentState.currentUser.copyWith(
      status: event.status,
      lastSeen: DateTime.now(),
      metadata: event.metadata,
    );
    
    emit(currentState.copyWithCurrentUser(updatedUser));
    
    // 广播状态更新
    await _broadcastPresenceUpdate(updatedUser);
  }

  /// 更新当前编辑的地图信息
  Future<void> _onUpdateCurrentMapInfo(
    UpdateCurrentMapInfo event,
    Emitter<PresenceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PresenceLoaded) return;
    
    // 构建新的元数据
    final newMetadata = Map<String, dynamic>.from(currentState.currentUser.metadata);
    
    if (event.mapId != null) {
      newMetadata['currentMapId'] = event.mapId;
    }
    
    if (event.mapTitle != null) {
      newMetadata['currentMapTitle'] = event.mapTitle;
    }
    
    if (event.mapCoverBase64 != null) {
      newMetadata['currentMapCover'] = event.mapCoverBase64;
    }
    
    if (event.coverQuality != null) {
      newMetadata['mapCoverQuality'] = event.coverQuality.toString();
    }
    
    final updatedUser = currentState.currentUser.copyWith(
      lastSeen: DateTime.now(),
      metadata: newMetadata,
    );
    
    emit(currentState.copyWithCurrentUser(updatedUser));
    
    // 广播地图信息更新
    await _broadcastPresenceUpdate(updatedUser);
  }

  // 注意：根据简化需求，移除了光标位置和选中元素相关的处理逻辑
  // 如果将来需要这些功能，可以通过WebRTC实现

  /// 接收远程用户状态更新
  Future<void> _onReceiveRemoteUserPresence(
    ReceiveRemoteUserPresence event,
    Emitter<PresenceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PresenceLoaded) return;
    
    // 不处理自己的状态更新
    if (event.userPresence.userId == currentState.currentUser.userId) {
      return;
    }
    
    emit(currentState.copyWithRemoteUser(event.userPresence));
  }

  /// 用户加入协作
  Future<void> _onUserJoinedCollaboration(
    UserJoinedCollaboration event,
    Emitter<PresenceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PresenceLoaded) return;
    
    // 不处理自己的加入事件
    if (event.userId == currentState.currentUser.userId) return;
    
    final newUser = UserPresence(
      userId: event.userId,
      userName: event.userName,
      status: UserActivityStatus.idle,
      lastSeen: event.joinedAt,
      joinedAt: event.joinedAt,
    );
    
    emit(currentState.copyWithRemoteUser(newUser));
  }

  /// 用户离开协作
  Future<void> _onUserLeftCollaboration(
    UserLeftCollaboration event,
    Emitter<PresenceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PresenceLoaded) return;
    
    emit(currentState.copyWithoutRemoteUser(event.userId));
  }

  /// 清理离线用户
  Future<void> _onCleanupOfflineUsers(
    CleanupOfflineUsers event,
    Emitter<PresenceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PresenceLoaded) return;
    
    emit(currentState.copyWithCleanup(event.offlineThreshold));
  }

  /// 重置所有用户状态
  Future<void> _onResetAllPresence(
    ResetAllPresence event,
    Emitter<PresenceState> emit,
  ) async {
    emit(const PresenceInitial());
  }

  // 注意：_onSyncFromMapDataBloc 方法已被移除
  // 当前实现通过直接调用 UpdateCurrentUserStatus 来更新状态

  /// 设置WebSocket消息监听
  void _setupWebSocketListener() {
    _messageSubscription = _webSocketManager.messageStream
        .where((message) => 
            message.type == 'presence' || 
            message.type == 'user_status_broadcast')
        .listen((message) {
      _handleWebSocketMessage(message);
    });
  }



  /// 处理WebSocket消息
  void _handleWebSocketMessage(WebSocketMessage message) {
    try {
      if (message.type == 'user_status_broadcast') {
        // 处理用户状态广播
        _handleUserStatusBroadcast(message.data);
        return;
      }
      
      // 处理传统的presence消息
      final action = message.data['action'] as String?;
      
      switch (action) {
        case 'user_presence_update':
          final userPresence = UserPresence.fromJson(message.data['user']);
          add(ReceiveRemoteUserPresence(userPresence: userPresence));
          break;
          
        case 'user_joined':
          add(UserJoinedCollaboration(
            userId: message.data['userId'],
            userName: message.data['userName'],
            joinedAt: DateTime.parse(message.data['joinedAt']),
          ));
          break;
          
        case 'user_left':
          add(UserLeftCollaboration(
            userId: message.data['userId'],
            leftAt: DateTime.parse(message.data['leftAt']),
          ));
          break;
      }
    } catch (error) {
      // 记录错误但不中断处理
      print('处理WebSocket消息时出错: $error');
    }
  }

  /// 处理用户状态广播
  void _handleUserStatusBroadcast(Map<String, dynamic> data) {
    try {
      final userId = data['user_id'] as String?;
      final ownerId = data['owner_id'] as String?;
      final onlineStatus = data['online_status'] as String?;
      final activityStatus = data['activity_status'] as String?;
      final spaceId = data['space_id'] as String?;
      final currentMapId = data['current_map_id'] as String?;
      final currentMapTitle = data['current_map_title'] as String?;
      final currentMapCover = data['current_map_cover'] as String?;
      
      if (userId == null || ownerId == null) return;
      
      // 转换状态
      UserActivityStatus? userActivityStatus;
      switch (activityStatus) {
        case 'viewing':
          userActivityStatus = UserActivityStatus.viewing;
          break;
        case 'editing':
          userActivityStatus = UserActivityStatus.editing;
          break;
        case 'idle':
        default:
          userActivityStatus = UserActivityStatus.idle;
          break;
      }
      
      // 准备metadata
      final metadata = <String, dynamic>{
        'online_status': onlineStatus ?? 'online',
        'space_id': spaceId ?? '',
      };
      
      // 添加地图信息（如果存在）
      if (currentMapId != null && currentMapId.isNotEmpty) {
        metadata['currentMapId'] = currentMapId;
      }
      if (currentMapTitle != null && currentMapTitle.isNotEmpty) {
        metadata['currentMapTitle'] = currentMapTitle;
      }
      if (currentMapCover != null && currentMapCover.isNotEmpty) {
        metadata['currentMapCover'] = currentMapCover;
      }
      
      // 创建UserPresence对象
      final userPresence = UserPresence(
        userId: userId,
        userName: ownerId, // 使用ownerId作为用户名，实际应用中可能需要查询用户信息
        status: userActivityStatus,
        lastSeen: DateTime.now(),
        joinedAt: DateTime.now(), // 添加必需的joinedAt参数
        metadata: metadata,
      );
      
      add(ReceiveRemoteUserPresence(userPresence: userPresence));
    } catch (error) {
      print('处理用户状态广播时出错: $error');
    }
  }



  /// 广播用户状态更新
  Future<void> _broadcastPresenceUpdate(UserPresence userPresence) async {
    try {
      // TODO: 将压缩限制大小添加到配置列表中，允许用户自定义设置
      const int maxCoverSizeBytes = 1000 * 1024; // 1000KB 压缩限制
      
      // 转换活动状态
      String activityStatus;
      switch (userPresence.status) {
        case UserActivityStatus.viewing:
          activityStatus = 'viewing';
          break;
        case UserActivityStatus.editing:
          activityStatus = 'editing';
          break;
        case UserActivityStatus.idle:
        default:
          activityStatus = 'idle';
          break;
      }
      
      // 获取在线状态
      final onlineStatus = userPresence.metadata['online_status'] as String? ?? 'online';
      
      // 准备状态更新数据
      final statusData = <String, dynamic>{
        'online_status': onlineStatus,
        'activity_status': activityStatus,
      };
      
      // 添加地图信息字段（如果存在）
      if (userPresence.metadata.containsKey('currentMapId')) {
        statusData['current_map_id'] = userPresence.metadata['currentMapId'];
      }
      if (userPresence.metadata.containsKey('currentMapTitle')) {
        statusData['current_map_title'] = userPresence.metadata['currentMapTitle'];
      }
      if (userPresence.metadata.containsKey('currentMapCover')) {
        final mapCover = userPresence.metadata['currentMapCover'] as String?;
        if (mapCover != null && mapCover.isNotEmpty) {
          // 检查地图封面大小是否超过限制
          final coverSizeBytes = mapCover.length * 0.75; // Base64编码大约增加33%，所以原始大小约为75%
          if (coverSizeBytes <= maxCoverSizeBytes) {
            statusData['current_map_cover'] = mapCover;
          } else {
            // 使用自适应压缩重新压缩地图封面
             try {
               final imageBytes = base64Decode(mapCover);
               final compressedBase64 = await ImageCompressionUtils.adaptiveCompress(
                 imageBytes,
                 maxSizeKB: maxCoverSizeBytes ~/ 1024, // 转换为KB
               );
               
               if (compressedBase64 != null) {
                 statusData['current_map_cover'] = compressedBase64;
                 final newSizeBytes = compressedBase64.length * 0.75;
                 
                 if (kDebugMode) {
                   print('地图封面已重新压缩: ${(coverSizeBytes / 1024).toStringAsFixed(1)}KB -> ${(newSizeBytes / 1024).toStringAsFixed(1)}KB');
                 }
               } else {
                 if (kDebugMode) {
                   print('地图封面压缩失败，无法满足大小限制，跳过发送');
                 }
               }
             } catch (compressionError) {
               if (kDebugMode) {
                 print('地图封面压缩失败: $compressionError，跳过发送');
               }
             }
          }
        }
      }
      
      // 使用扩展的状态更新API
      await _webSocketManager.sendUserStatusUpdateWithData(statusData);
    } catch (error) {
      print('广播用户状态更新失败: $error');
    }
  }

  /// 启动定时任务
  void _startPeriodicTasks() {
    // 心跳任务
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      final currentState = state;
      if (currentState is PresenceLoaded) {
        add(UpdateCurrentUserStatus(
          status: currentState.currentUser.status,
        ));
      }
    });
    
    // 清理任务
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      add(const CleanupOfflineUsers(offlineThreshold: _offlineThreshold));
    });
  }

  /// 获取当前用户状态
  UserPresence? get currentUser {
    final currentState = state;
    if (currentState is PresenceLoaded) {
      return currentState.currentUser;
    }
    return null;
  }

  /// 获取所有远程用户
  List<UserPresence> get remoteUsers {
    final currentState = state;
    if (currentState is PresenceLoaded) {
      return currentState.allRemoteUsers;
    }
    return [];
  }

  /// 获取在线用户数量
  int get onlineUserCount {
    final currentState = state;
    if (currentState is PresenceLoaded) {
      return currentState.onlineUserCount;
    }
    return 0;
  }

  /// 检查是否有其他用户正在编辑
  bool get hasOtherEditingUsers {
    final currentState = state;
    if (currentState is PresenceLoaded) {
      return currentState.hasOtherEditingUsers;
    }
    return false;
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _mapDataSubscription?.cancel();
    _heartbeatTimer?.cancel();
    _cleanupTimer?.cancel();
    return super.close();
  }
}