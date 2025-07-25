import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_presence.dart';
import '../../services/websocket/websocket_client_manager.dart';
import '../../services/websocket/websocket_client_service.dart'; // 添加WebSocketMessage导入
import '../../utils/image_compression_utils.dart';
import '../../../services/user_preferences/user_preferences_service.dart';
// 注意：map_data_bloc 和 map_data_state 的导入已被移除
// 当前实现不再直接依赖 MapDataBloc
import 'presence_event.dart';
import 'presence_state.dart';

/// 用户在线状态管理Bloc
class PresenceBloc extends Bloc<PresenceEvent, PresenceState> {
  final WebSocketClientManager _webSocketManager;
  final UserPreferencesService _userPreferencesService;

  StreamSubscription<WebSocketMessage>? _messageSubscription;
  StreamSubscription? _mapDataSubscription; // 保留字段但不再使用
  Timer? _cleanupTimer;

  static const Duration _cleanupInterval = Duration(minutes: 2);
  static const Duration _offlineThreshold = Duration(minutes: 5);

  PresenceBloc({
    required WebSocketClientManager webSocketManager,
    UserPreferencesService? userPreferencesService,
  }) : _webSocketManager = webSocketManager,
       _userPreferencesService =
           userPreferencesService ?? UserPreferencesService(),
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
      // 根据WebSocket连接状态设置初始状态
      final isConnected = _webSocketManager.isConnected;
      final initialStatus = isConnected
          ? UserActivityStatus.idle
          : UserActivityStatus.offline;

      // 获取用户偏好设置中的displayName和avatar
      String? displayName;
      String? avatar;
      try {
        final userPreferences = await _userPreferencesService
            .getCurrentPreferences();
        displayName = userPreferences.displayName;

        // 处理头像数据
        if (userPreferences.avatarData != null &&
            userPreferences.avatarData!.isNotEmpty) {
          // 如果有本地头像数据，进行压缩并转换为base64
          final compressedData = await ImageCompressionUtils.adaptiveCompress(
            userPreferences.avatarData!,
            maxSizeKB: 50, // 限制头像大小为50KB
          );
          if (compressedData != null) {
            avatar = compressedData;
          }
        } else if (userPreferences.avatarPath != null &&
            userPreferences.avatarPath!.isNotEmpty) {
          // 如果有网络头像路径，直接使用
          avatar = userPreferences.avatarPath;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('获取用户偏好设置失败: $e');
        }
        // 使用默认值
        displayName = event.currentUserName;
      }

      final currentUser = UserPresence(
        clientId: event.currentClientId,
        userName: event.currentUserName,
        displayName: displayName,
        avatar: avatar,
        status: initialStatus,
        lastSeen: DateTime.now(),
        joinedAt: DateTime.now(),
        metadata: {'online_status': isConnected ? 'online' : 'offline'},
      );

      emit(
        PresenceLoaded(
          currentUser: currentUser,
          remoteUsers: {},
          lastUpdated: DateTime.now(),
        ),
      );

      // 只有在WebSocket连接时才广播当前用户加入
      if (isConnected) {
        await _broadcastPresenceUpdate(currentUser);
      } else {
        if (kDebugMode) {
          debugPrint('WebSocket未连接，跳过广播用户状态（离线模式）');
        }
      }
    } catch (error, stackTrace) {
      emit(
        PresenceError(
          message: '初始化用户状态失败',
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// 更新当前用户状态
  Future<void> _onUpdateCurrentUserStatus(
    UpdateCurrentUserStatus event,
    Emitter<PresenceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PresenceLoaded) return;

    final currentUser = currentState.currentUser;

    // 检查状态是否真正发生变化
    bool statusChanged = false;

    // 检查活动状态变化
    if (event.status != currentUser.status) {
      statusChanged = true;
    }

    // 检查元数据变化
    if (event.metadata != null) {
      // 比较关键的元数据字段
      final currentMetadata = currentUser.metadata;
      final newMetadata = event.metadata!;

      // 检查在线状态变化
      if (newMetadata['online_status'] != currentMetadata['online_status']) {
        statusChanged = true;
      }

      // 检查地图相关信息变化
      if (newMetadata['currentMapId'] != currentMetadata['currentMapId'] ||
          newMetadata['currentMapTitle'] !=
              currentMetadata['currentMapTitle'] ||
          newMetadata['currentMapCover'] !=
              currentMetadata['currentMapCover']) {
        statusChanged = true;
      }
    }

    final updatedUser = currentUser.copyWith(
      status: event.status,
      lastSeen: DateTime.now(),
      metadata: event.metadata,
    );

    emit(currentState.copyWithCurrentUser(updatedUser));

    // 只有状态真正变化时才广播
    if (statusChanged) {
      if (kDebugMode) {
        debugPrint('用户状态发生变化，准备广播: ${currentUser.status} -> ${event.status}');
      }
      await _broadcastPresenceUpdate(updatedUser);
    } else {
      if (kDebugMode) {
        debugPrint('用户状态无变化，跳过广播');
      }
    }
  }

  /// 更新当前编辑的地图信息
  Future<void> _onUpdateCurrentMapInfo(
    UpdateCurrentMapInfo event,
    Emitter<PresenceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PresenceLoaded) return;

    final currentUser = currentState.currentUser;
    final currentMetadata = currentUser.metadata;

    // 构建新的元数据
    final newMetadata = Map<String, dynamic>.from(currentMetadata);

    // 检查地图信息是否真正发生变化
    bool mapInfoChanged = false;

    // 处理mapId（包括清空操作）
    if (event.mapId != currentMetadata['currentMapId']) {
      mapInfoChanged = true;
      if (event.mapId != null) {
        newMetadata['currentMapId'] = event.mapId;
      } else {
        newMetadata.remove('currentMapId');
      }
    }

    // 处理mapTitle（包括清空操作）
    if (event.mapTitle != currentMetadata['currentMapTitle']) {
      mapInfoChanged = true;
      if (event.mapTitle != null) {
        newMetadata['currentMapTitle'] = event.mapTitle;
      } else {
        newMetadata.remove('currentMapTitle');
      }
    }

    // 处理mapCover（包括清空操作）
    if (event.mapCoverBase64 != currentMetadata['currentMapCover']) {
      mapInfoChanged = true;
      if (event.mapCoverBase64 != null) {
        newMetadata['currentMapCover'] = event.mapCoverBase64;
      } else {
        newMetadata.remove('currentMapCover');
      }
    }

    if (event.coverQuality != null) {
      final newQuality = event.coverQuality.toString();
      if (currentMetadata['mapCoverQuality'] != newQuality) {
        mapInfoChanged = true;
      }
      newMetadata['mapCoverQuality'] = newQuality;
    }

    final updatedUser = currentUser.copyWith(
      lastSeen: DateTime.now(),
      metadata: newMetadata,
    );

    emit(currentState.copyWithCurrentUser(updatedUser));

    // 只有地图信息真正变化时才广播
    if (mapInfoChanged) {
      if (kDebugMode) {
        debugPrint(
          '地图信息发生变化，准备广播: mapId=${event.mapId}, mapTitle=${event.mapTitle}',
        );
      }
      await _broadcastPresenceUpdate(updatedUser);
    } else {
      if (kDebugMode) {
        debugPrint('地图信息无变化，跳过广播');
      }
    }
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
    if (event.userPresence.clientId == currentState.currentUser.clientId) {
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
    if (event.clientId == currentState.currentUser.clientId) return;

    final newUser = UserPresence(
      clientId: event.clientId,
      userName: event.userName,
      displayName: event.userName, // 使用userName作为默认displayName
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

    emit(currentState.copyWithoutRemoteUser(event.clientId));
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
        .where(
          (message) =>
              message.type == 'presence' ||
              message.type == 'user_status_broadcast' ||
              message.type == 'online_status_list_response',
        )
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

      if (message.type == 'online_status_list_response') {
        // 处理在线状态列表响应
        _handleOnlineStatusListResponse(message.data);
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
          add(
            UserJoinedCollaboration(
              clientId: message.data['client_id'],
              userName: message.data['userName'],
              joinedAt: DateTime.parse(message.data['joinedAt']),
            ),
          );
          break;

        case 'user_left':
          add(
            UserLeftCollaboration(
              clientId: message.data['client_id'],
              leftAt: DateTime.parse(message.data['leftAt']),
            ),
          );
          break;
      }
    } catch (error) {
      // 记录错误但不中断处理
      debugPrint('处理WebSocket消息时出错: $error');
    }
  }

  /// 处理用户状态广播
  void _handleUserStatusBroadcast(Map<String, dynamic> data) {
    try {
      final clientId = data['client_id'] as String?;
      final onlineStatus = data['online_status'] as String?;
      final activityStatus = data['activity_status'] as String?;
      final spaceId = data['space_id'] as String?;
      final currentMapId = data['current_map_id'] as String?;
      final currentMapTitle = data['current_map_title'] as String?;
      final currentMapCover = data['current_map_cover'] as String?;
      final displayName = data['display_name'] as String?;
      final avatar = data['avatar'] as String?;

      if (clientId == null) return;

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

      // 获取当前状态以保留已存在用户的joinedAt时间
      final currentState = state;
      DateTime joinedAt = DateTime.now();
      String userName = clientId;

      // 如果用户已存在，保留其joinedAt时间和用户名
      if (currentState is PresenceLoaded) {
        final existingUser = currentState.remoteUsers[clientId];
        if (existingUser != null) {
          joinedAt = existingUser.joinedAt;
          userName = existingUser.userName;
        }
      }

      // 创建UserPresence对象
      final userPresence = UserPresence(
        clientId: clientId,
        userName: userName,
        displayName:
            displayName ?? userName, // 使用接收到的displayName，如果没有则使用userName
        avatar: avatar, // 使用接收到的avatar
        status: userActivityStatus,
        lastSeen: DateTime.now(),
        joinedAt: joinedAt,
        metadata: metadata,
      );

      add(ReceiveRemoteUserPresence(userPresence: userPresence));
    } catch (error) {
      debugPrint('处理用户状态广播时出错: $error');
    }
  }

  /// 处理在线状态列表响应
  void _handleOnlineStatusListResponse(Map<String, dynamic> data) {
    try {
      final success = data['success'] as bool? ?? false;

      if (!success) {
        debugPrint('获取在线状态列表失败: ${data['error'] ?? "未知错误"}');
        return;
      }

      final usersList = data['users'] as List<dynamic>? ?? [];

      // 处理每个用户的状态信息
      for (final userInfo in usersList) {
        if (userInfo is Map<String, dynamic>) {
          _handleUserStatusBroadcast(userInfo);
        }
      }

      debugPrint('成功处理在线状态列表，共 ${usersList.length} 个用户');
    } catch (error) {
      debugPrint('处理在线状态列表响应时出错: $error');
    }
  }

  /// 广播用户状态更新
  Future<void> _broadcastPresenceUpdate(UserPresence userPresence) async {
    // 检查WebSocket连接状态，如果未连接则不广播
    if (!_webSocketManager.isConnected) {
      if (kDebugMode) {
        debugPrint('WebSocket未连接，跳过广播用户状态更新（离线模式）');
      }
      return;
    }

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
      final onlineStatus =
          userPresence.metadata['online_status'] as String? ?? 'online';

      // 准备状态更新数据
      final statusData = <String, dynamic>{
        'online_status': onlineStatus,
        'activity_status': activityStatus,
        'display_name': userPresence.displayName,
        'avatar': userPresence.avatar,
      };

      // 添加地图信息字段（包括空值以确保清空操作能正确发送）
      statusData['current_map_id'] =
          userPresence.metadata['currentMapId'] ?? '';
      statusData['current_map_title'] =
          userPresence.metadata['currentMapTitle'] ?? '';

      final mapCover = userPresence.metadata['currentMapCover'] as String?;
      if (mapCover != null && mapCover.isNotEmpty) {
        // 检查地图封面大小是否超过限制
        final coverSizeBytes =
            mapCover.length * 0.75; // Base64编码大约增加33%，所以原始大小约为75%
        if (coverSizeBytes <= maxCoverSizeBytes) {
          statusData['current_map_cover'] = mapCover;
        } else {
          // 使用自适应压缩重新压缩地图封面
          try {
            final imageBytes = base64Decode(mapCover);
            final compressedBase64 =
                await ImageCompressionUtils.adaptiveCompress(
                  imageBytes,
                  maxSizeKB: maxCoverSizeBytes ~/ 1024, // 转换为KB
                );

            if (compressedBase64 != null) {
              statusData['current_map_cover'] = compressedBase64;
              final newSizeBytes = compressedBase64.length * 0.75;

              if (kDebugMode) {
                debugPrint(
                  '地图封面已重新压缩: ${(coverSizeBytes / 1024).toStringAsFixed(1)}KB -> ${(newSizeBytes / 1024).toStringAsFixed(1)}KB',
                );
              }
            } else {
              if (kDebugMode) {
                debugPrint('地图封面压缩失败，无法满足大小限制，跳过发送');
              }
            }
          } catch (compressionError) {
            if (kDebugMode) {
              debugPrint('地图封面压缩失败: $compressionError，跳过发送');
            }
          }
        }
      } else {
        // 确保即使封面为空也发送空值
        statusData['current_map_cover'] = '';
      }

      // 使用扩展的状态更新API
      await _webSocketManager.sendUserStatusUpdateWithData(statusData);
    } catch (error) {
      debugPrint('广播用户状态更新失败: $error');
    }
  }

  /// 启动定时任务
  void _startPeriodicTasks() {
    // 清理任务
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      add(const CleanupOfflineUsers(offlineThreshold: _offlineThreshold));
    });

    // 注意：心跳任务已移除，现在使用WebSocket客户端服务的ping机制来维持连接
    // 状态更新只在数据真正变化时发送
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

  /// 请求在线状态列表
  Future<void> requestOnlineStatusList() async {
    try {
      await _webSocketManager.requestOnlineStatusList();
    } catch (error) {
      debugPrint('请求在线状态列表失败: $error');
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _mapDataSubscription?.cancel();
    _cleanupTimer?.cancel();
    return super.close();
  }
}
