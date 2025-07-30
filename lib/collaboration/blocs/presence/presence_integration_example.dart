// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
// 注意：map_data_bloc 和 websocket_client_service 的导入已更新
import '../../services/websocket/websocket_client_manager.dart';
import '../../services/map_sync_service.dart';
import 'presence.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

/// PresenceBloc与MapDataBloc集成示例
///
/// 这个示例展示了如何在应用中正确设置和使用PresenceBloc，
/// 以及如何与现有的MapDataBloc系统集成。
class PresenceIntegrationExample extends StatelessWidget {
  const PresenceIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 假设MapDataBloc已经在更高层级提供
        // BlocProvider<MapDataBloc>(...),

        // 提供PresenceBloc
        BlocProvider<PresenceBloc>(
          create: (context) {
            final webSocketManager = WebSocketClientManager();

            return PresenceBloc(webSocketManager: webSocketManager);
          },
        ),
      ],
      child: const PresenceAwareMapView(),
    );
  }
}

/// 具有用户在线状态感知的地图视图
class PresenceAwareMapView extends StatefulWidget {
  const PresenceAwareMapView({super.key});

  @override
  State<PresenceAwareMapView> createState() => _PresenceAwareMapViewState();
}

class _PresenceAwareMapViewState extends State<PresenceAwareMapView> {
  MapSyncService? _mapSyncService;

  @override
  void initState() {
    super.initState();

    // 初始化用户在线状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PresenceBloc>().add(
        InitializePresence(
          currentClientId: 'client123', // 实际应用中从WebSocket客户端管理器获取
          currentUserName: LocalizationService
              .instance
              .current
              .userName_7284, // 实际应用中从用户配置获取
        ),
      );

      // 初始化MapSyncService
      setState(() {
        _mapSyncService = MapSyncService(context.read<PresenceBloc>());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.instance.current.collaborativeMap_4271),
        actions: [
          // 在线用户指示器
          BlocBuilder<PresenceBloc, PresenceState>(
            builder: (context, state) {
              if (state is PresenceLoaded) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people,
                        color: state.onlineUserCount > 1
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text('${state.onlineUserCount}'),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 协作状态栏
          const CollaborationStatusBar(),

          // 主要地图视图
          Expanded(
            child: Stack(
              children: [
                // 地图内容
                MapContent(mapSyncService: _mapSyncService),
              ],
            ),
          ),
        ],
      ),
      drawer: const OnlineUsersDrawer(),
    );
  }
}

/// 协作状态栏
class CollaborationStatusBar extends StatelessWidget {
  const CollaborationStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PresenceBloc, PresenceState>(
      builder: (context, state) {
        if (state is! PresenceLoaded) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              // 当前用户状态
              _buildStatusChip(
                LocalizationService.instance.current.userStatusWithName(
                  _getStatusText(state.currentUser.status),
                ),
                _getStatusColor(state.currentUser.status),
              ),

              const SizedBox(width: 16),

              // 其他用户状态
              if (state.hasOtherEditingUsers)
                _buildStatusChip(
                  LocalizationService.instance.current.usersEditingCount(
                    state.editingUserCount -
                        (state.currentUser.isEditing ? 1 : 0),
                  ),
                  Colors.orange,
                ),

              const Spacer(),

              // 连接状态 - 注意：WebSocketClientService 已更新为 WebSocketClientManager
              // 此部分需要根据新的连接状态管理方式进行调整
              Icon(
                Icons.cloud_done, // 简化为静态图标，实际应用中需要监听连接状态
                color: Colors.green,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51), // 替换 withOpacity(0.2) 为 withAlpha(51)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  String _getStatusText(UserActivityStatus status) {
    switch (status) {
      case UserActivityStatus.editing:
        return LocalizationService.instance.current.editingStatus_4821;
      case UserActivityStatus.viewing:
        return LocalizationService.instance.current.viewingStatus_7532;
      case UserActivityStatus.idle:
        return LocalizationService.instance.current.idleStatus_6194;
      case UserActivityStatus.offline:
        return LocalizationService.instance.current.offlineStatus_3087;
    }
  }

  Color _getStatusColor(UserActivityStatus status) {
    switch (status) {
      case UserActivityStatus.editing:
        return Colors.orange;
      case UserActivityStatus.viewing:
        return Colors.blue;
      case UserActivityStatus.idle:
        return Colors.green;
      case UserActivityStatus.offline:
        return Colors.grey;
    }
  }
}

/// 地图内容（占位符）
class MapContent extends StatelessWidget {
  final MapSyncService? mapSyncService;

  const MapContent({super.key, this.mapSyncService});

  @override
  Widget build(BuildContext context) {
    // 注意：MapDataBloc 监听已被移除，状态同步现在通过应用层处理
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(LocalizationService.instance.current.mapContentArea_7281),
          const SizedBox(height: 20),

          // 地图信息同步演示按钮
          if (mapSyncService != null)
            MapSyncDemoButtons(mapSyncService: mapSyncService!),
        ],
      ),
    );
  }
}

/// 地图同步演示按钮
class MapSyncDemoButtons extends StatelessWidget {
  final MapSyncService mapSyncService;

  const MapSyncDemoButtons({super.key, required this.mapSyncService});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          LocalizationService.instance.current.mapSyncDemoTitle_7281,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton(
              onPressed: () => _syncDemoMap1(context),
              child: Text(LocalizationService.instance.current.syncMap1_1234),
            ),
            ElevatedButton(
              onPressed: () => _syncDemoMap2(context),
              child: Text(LocalizationService.instance.current.syncMap2_7421),
            ),
            ElevatedButton(
              onPressed: () => _updateMapTitle(context),
              child: Text(
                LocalizationService.instance.current.updateTitle_4271,
              ),
            ),
            ElevatedButton(
              onPressed: () => _clearMapInfo(context),
              child: Text(
                LocalizationService.instance.current.clearMapInfo_4821,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _syncDemoMap1(BuildContext context) {
    // 创建模拟的地图封面数据（简单的彩色方块）
    final demoImageData = _createDemoImageData(Colors.blue);

    mapSyncService.syncCurrentMapInfo(
      mapId: 'demo_map_1',
      mapTitle: LocalizationService.instance.current.demoMapBlueTheme_4821,
      mapCover: demoImageData,
      coverQuality: 70,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationService.instance.current.demoMapSynced_7281),
      ),
    );
  }

  void _syncDemoMap2(BuildContext context) {
    // 创建模拟的地图封面数据（简单的彩色方块）
    final demoImageData = _createDemoImageData(Colors.green);

    mapSyncService.syncCurrentMapInfo(
      mapId: 'demo_map_2',
      mapTitle: LocalizationService.instance.current.demoMapGreenTheme_7281,
      mapCover: demoImageData,
      coverQuality: 80,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationService.instance.current.demoMapSynced_7421),
      ),
    );
  }

  void _updateMapTitle(BuildContext context) {
    mapSyncService.updateMapTitle(
      'demo_map_1',
      LocalizationService.instance.current.renamedDemoMap(
        DateTime.now().millisecondsSinceEpoch,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LocalizationService.instance.current.mapTitleUpdated_7281,
        ),
      ),
    );
  }

  void _clearMapInfo(BuildContext context) {
    mapSyncService.clearCurrentMapInfo();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LocalizationService.instance.current.mapClearedMessage_4827,
        ),
      ),
    );
  }

  /// 创建演示用的图片数据（简单的彩色方块）
  Uint8List _createDemoImageData(Color color) {
    // 创建一个简单的PNG图片数据（实际应用中会使用真实的地图封面）
    // 这里使用简化的方式创建一个小的彩色方块
    final List<int> pngData = [
      // PNG文件头
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      // IHDR chunk
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x10,
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x91, 0x68,
      0x36,
      // IDAT chunk (简化的图片数据)
      0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, 0x54,
      0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05,
      0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4,
      // IEND chunk
      0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44,
      0xAE, 0x42, 0x60, 0x82,
    ];

    return Uint8List.fromList(pngData);
  }
}

// 注意：当前实现专注于基本的在线状态和活动状态同步
// 复杂的协作功能（如光标位置、选中元素）已被简化

/// 在线用户抽屉
class OnlineUsersDrawer extends StatelessWidget {
  const OnlineUsersDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              LocalizationService.instance.current.onlineUsers_4821,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          Expanded(
            child: BlocBuilder<PresenceBloc, PresenceState>(
              builder: (context, state) {
                if (state is! PresenceLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: [
                    // 当前用户
                    _buildUserTile(state.currentUser, isCurrentUser: true),

                    if (state.allRemoteUsers.isNotEmpty) ...[
                      const Divider(),
                      ...state.allRemoteUsers.map(
                        (user) => _buildUserTile(user),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserPresence user, {bool isCurrentUser = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(user.status),
                child: Text(
                  user.userName.isNotEmpty
                      ? user.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                isCurrentUser
                    ? '${user.userName} ' +
                          LocalizationService
                              .instance
                              .current
                              .currentUserSuffix_7281
                    : user.userName,
                style: TextStyle(
                  fontWeight: isCurrentUser
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text(_getStatusText(user.status)),
              trailing: user.isOnline
                  ? const Icon(Icons.circle, color: Colors.green, size: 12)
                  : const Icon(Icons.circle, color: Colors.grey, size: 12),
            ),

            // 显示当前编辑的地图信息
            if (user.hasMapTitle || user.hasMapCover) ...[
              const Divider(height: 8),
              _buildMapInfo(user),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapInfo(UserPresence user) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 地图封面缩略图
          if (user.hasMapCover)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: user.currentMapCover != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(
                        user.currentMapCover!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.map, size: 20);
                        },
                      ),
                    )
                  : const Icon(Icons.map, size: 20),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade200,
              ),
              child: const Icon(Icons.map, size: 20, color: Colors.grey),
            ),

          const SizedBox(width: 8),

          // 地图标题和状态
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationService.instance.current.editingLabel_7421,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  user.currentMapTitle ??
                      LocalizationService.instance.current.unknownMap_4821,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(UserActivityStatus status) {
    switch (status) {
      case UserActivityStatus.editing:
        return LocalizationService.instance.current.editingStatus_4821;
      case UserActivityStatus.viewing:
        return LocalizationService.instance.current.viewingStatus_5723;
      case UserActivityStatus.idle:
        return LocalizationService.instance.current.idleStatus_6934;
      case UserActivityStatus.offline:
        return LocalizationService.instance.current.offlineStatus_7845;
    }
  }

  Color _getStatusColor(UserActivityStatus status) {
    switch (status) {
      case UserActivityStatus.editing:
        return Colors.orange;
      case UserActivityStatus.viewing:
        return Colors.blue;
      case UserActivityStatus.idle:
        return Colors.green;
      case UserActivityStatus.offline:
        return Colors.grey;
    }
  }
}

/// 使用示例的辅助方法
class PresenceHelper {
  /// 开始编辑模式
  static void startEditing(BuildContext context) {
    context.read<PresenceBloc>().add(
      const UpdateCurrentUserStatus(status: UserActivityStatus.editing),
    );
  }

  /// 停止编辑模式
  static void stopEditing(BuildContext context) {
    context.read<PresenceBloc>().add(
      const UpdateCurrentUserStatus(status: UserActivityStatus.viewing),
    );
  }

  /// 设置用户为空闲状态
  static void setIdle(BuildContext context) {
    context.read<PresenceBloc>().add(
      const UpdateCurrentUserStatus(status: UserActivityStatus.idle),
    );
  }
}
