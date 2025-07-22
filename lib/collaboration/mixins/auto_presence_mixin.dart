import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/presence/presence_bloc.dart';
import '../blocs/presence/presence_event.dart';
import '../blocs/presence/presence_state.dart';
import '../services/websocket/websocket_client_manager.dart';
import '../services/websocket/websocket_client_service.dart';
import '../services/map_sync_service.dart';
import '../services/auto_presence_manager.dart';
import '../models/user_presence.dart';
import '../../models/map_item.dart';
import '../../models/map_item_summary.dart';
import '../global_collaboration_service.dart';

/// 自动在线状态管理Mixin
/// 
/// 为页面提供自动在线状态管理功能，包括：
/// - 自动初始化协作服务
/// - 自动管理用户状态
/// - 提供在线用户显示组件
/// - 自动清理资源
mixin AutoPresenceMixin<T extends StatefulWidget> on State<T> {
  // 协作服务实例
  late final PresenceBloc _presenceBloc;
  late final WebSocketClientManager _webSocketManager;
  late final MapSyncService _mapSyncService;
  late final AutoPresenceManager _autoPresenceManager;
  
  // 初始化标志
  bool _collaborationInitialized = false;
  
  /// 获取当前客户端ID（子类需要实现）
  String getCurrentClientId();
  
  /// 获取当前用户名（子类需要实现）
  String getCurrentUserName();
  
  /// 获取MapDataBloc实例（可选，地图编辑器页面需要实现）
  Bloc? getMapDataBloc() => null;
  
  /// 初始化协作服务
  Future<void> initializeCollaboration() async {
    if (_collaborationInitialized) return;
    
    try {
      // 使用全局协作服务
      final globalService = GlobalCollaborationService.instance;
      
      // 确保全局服务已初始化
      if (!globalService.isInitialized) {
        await globalService.initialize();
      }
      
      // 获取全局服务的实例
      _webSocketManager = globalService.webSocketManager;
      _presenceBloc = globalService.presenceBloc;
      
      // 不自动连接WebSocket，让用户手动决定是否连接
      debugPrint('协作服务已初始化，WebSocket连接状态: ${globalService.isConnected ? "已连接" : "未连接（离线模式）"}');
      
      // 初始化MapSyncService
      _mapSyncService = MapSyncService(_presenceBloc);
      
      // 初始化AutoPresenceManager
      _autoPresenceManager = AutoPresenceManager(
        presenceBloc: _presenceBloc,
        webSocketManager: _webSocketManager,
        mapSyncService: _mapSyncService,
      );
      
      // 启动自动状态管理
      _autoPresenceManager.initialize();
      
      // 初始化用户状态
      _presenceBloc.add(InitializePresence(
        currentClientId: getCurrentClientId(),
        currentUserName: getCurrentUserName(),
      ));
      
      _collaborationInitialized = true;
      debugPrint('协作服务初始化完成，WebSocket连接状态: ${_webSocketManager.connectionState}');
      
      // 如果WebSocket已连接，立即请求在线状态列表
      if (globalService.isConnected) {
        debugPrint('WebSocket已连接，请求在线状态列表');
        await _presenceBloc.requestOnlineStatusList();
      }
      
      // 监听WebSocket连接状态变化，在连接成功后请求在线状态列表
      _webSocketManager.connectionStateStream.listen((state) {
        if (state == WebSocketConnectionState.connected) {
          debugPrint('WebSocket连接成功，请求在线状态列表');
          _presenceBloc.requestOnlineStatusList();
        }
      });
    } catch (e) {
      debugPrint('协作服务初始化失败: $e');
    }
  }
  
  /// 清理协作服务
  void disposeCollaboration() async {
    if (!_collaborationInitialized) return;
    
    try {
      // 先退出地图编辑器，清理状态
      _autoPresenceManager.exitMapEditor();

      debugPrint('协作服务已清理');
    } catch (e) {
      debugPrint('协作服务清理失败: $e');
    }
  }
  
  /// 进入地图编辑器
  Future<void> enterMapEditor({
    required String mapId,
    required String mapTitle,
    Uint8List? mapCover,
  }) async {
    debugPrint('[AutoPresenceMixin] enterMapEditor called with mapId: $mapId, mapTitle: $mapTitle');
    
    if (!_collaborationInitialized) {
      debugPrint('[AutoPresenceMixin] 协作服务未初始化，跳过enterMapEditor');
      return;
    }
    
    debugPrint('[AutoPresenceMixin] 调用AutoPresenceManager.enterMapEditor');
    await _autoPresenceManager.enterMapEditor(
      mapId: mapId,
      mapTitle: mapTitle,
      mapCover: mapCover,
      mapDataBloc: getMapDataBloc(),
    );
    debugPrint('[AutoPresenceMixin] AutoPresenceManager.enterMapEditor 调用完成');
  }
  
  /// 退出地图编辑器
  void exitMapEditor() {
    if (!_collaborationInitialized) return;
    
    _autoPresenceManager.exitMapEditor();
  }
  
  /// 同步地图信息（从MapItem）
  void syncMapInfo(MapItem mapItem) {
    if (!_collaborationInitialized) return;
    
    _mapSyncService.syncFromMapItem(mapItem);
  }
  
  /// 同步地图信息（从MapItemSummary）
  void syncMapInfoFromSummary(MapItemSummary mapSummary) {
    if (!_collaborationInitialized) return;
    
    _mapSyncService.syncFromMapItemSummary(mapSummary);
  }
  
  /// 手动触发编辑状态
  void triggerEditingState() {
    if (!_collaborationInitialized) return;
    
    _autoPresenceManager.triggerEditingState();
  }
  
  /// 更新地图标题
  void updateMapTitle(String newTitle) {
    if (!_collaborationInitialized) return;
    
    _autoPresenceManager.updateMapTitle(newTitle);
  }
  
  /// 更新地图封面
  void updateMapCover(Uint8List newCover) {
    if (!_collaborationInitialized) return;
    
    _autoPresenceManager.updateMapCover(newCover);
  }
  
  /// 检查协作服务是否已初始化
  bool get isCollaborationInitialized => _collaborationInitialized;
  
  /// 获取PresenceBloc（用于UI组件）
  PresenceBloc get presenceBloc {
    if (!_collaborationInitialized) {
      throw StateError('协作服务未初始化，请先调用 initializeCollaboration()');
    }
    return _presenceBloc;
  }
  
  /// 构建在线用户按钮
  Widget buildOnlineUsersButton({
    VoidCallback? onPressed,
    bool mini = true,
  }) {
    if (!_collaborationInitialized) {
      return const SizedBox.shrink();
    }
    
    return BlocBuilder<PresenceBloc, PresenceState>(
      bloc: _presenceBloc,
      builder: (context, state) {
        if (state is! PresenceLoaded) return const SizedBox.shrink();
        final onlineCount = state.remoteUsers.length + 1;
        
        return FloatingActionButton(
          mini: mini,
          onPressed: onPressed ?? () => showOnlineUsersDialog(context),
          child: Badge(
            label: Text('$onlineCount'),
            child: const Icon(Icons.people),
          ),
        );
      },
    );
  }
  
  /// 显示在线用户对话框
  void showOnlineUsersDialog(BuildContext context) {
    if (!_collaborationInitialized) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('在线用户'),
        content: BlocBuilder<PresenceBloc, PresenceState>(
          bloc: _presenceBloc,
          builder: (context, state) {
            if (state is! PresenceLoaded) {
              return const SizedBox(
                width: 300,
                height: 100,
                child: Center(
                  child: Text('加载中...'),
                ),
              );
            }
            final allUsers = [
              state.currentUser,
              ...state.remoteUsers.values,
            ];
            
            if (allUsers.isEmpty) {
              return const SizedBox(
                width: 300,
                height: 100,
                child: Center(
                  child: Text('暂无在线用户'),
                ),
              );
            }
            
            return SizedBox(
              width: 300,
              height: 400,
              child: ListView.builder(
                itemCount: allUsers.length,
                itemBuilder: (context, index) {
                  final user = allUsers[index];
                  return _buildUserTile(user);
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  /// 构建用户列表项
  Widget _buildUserTile(UserPresence user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(user.status),
                  radius: 16,
                  child: Text(
                    user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getStatusText(user.status),
                        style: TextStyle(
                          color: _getStatusColor(user.status),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (user.hasMapCover)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(
                        user.currentMapCover!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 20,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            if (user.hasMapTitle) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '正在编辑: ${user.currentMapTitle}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 获取状态颜色
  Color _getStatusColor(UserActivityStatus status) {
    switch (status) {
      case UserActivityStatus.idle:
        return Colors.green;
      case UserActivityStatus.offline:
        return Colors.grey;
      case UserActivityStatus.viewing:
        return Colors.blue;
      case UserActivityStatus.editing:
        return Colors.orange;
    }
  }
  
  /// 获取状态文本
  String _getStatusText(UserActivityStatus status) {
    switch (status) {
      case UserActivityStatus.idle:
        return '在线';
      case UserActivityStatus.offline:
        return '离线';
      case UserActivityStatus.viewing:
        return '查看中';
      case UserActivityStatus.editing:
        return '编辑中';
    }
  }
  
  /// 构建状态指示器
  Widget buildStatusIndicator() {
    if (!_collaborationInitialized) {
      return const SizedBox.shrink();
    }
    
    return BlocBuilder<PresenceBloc, PresenceState>(
      bloc: _presenceBloc,
      builder: (context, state) {
        if (state is! PresenceLoaded) {
          return const SizedBox.shrink();
        }
        final currentUser = state.currentUser;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(currentUser.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(currentUser.status),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(currentUser.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _getStatusText(currentUser.status),
                style: TextStyle(
                  color: _getStatusColor(currentUser.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}