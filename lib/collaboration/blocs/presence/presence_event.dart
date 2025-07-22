import 'package:equatable/equatable.dart';
import '../../models/user_presence.dart';

/// 用户在线状态事件基类
abstract class PresenceEvent extends Equatable {
  const PresenceEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化用户在线状态
class InitializePresence extends PresenceEvent {
  final String currentClientId;
  final String currentUserName;

  const InitializePresence({
    required this.currentClientId,
    required this.currentUserName,
  });

  @override
  List<Object?> get props => [currentClientId, currentUserName];
}

/// 更新当前用户状态
class UpdateCurrentUserStatus extends PresenceEvent {
  final UserActivityStatus status;
  final Map<String, dynamic>? metadata;

  const UpdateCurrentUserStatus({required this.status, this.metadata});

  @override
  List<Object?> get props => [status, metadata];
}

/// 更新当前编辑的地图信息（标题和封面）
class UpdateCurrentMapInfo extends PresenceEvent {
  final String? mapId;
  final String? mapTitle;
  final String? mapCoverBase64; // 压缩后的base64封面数据
  final int? coverQuality; // 压缩质量 (1-100)

  const UpdateCurrentMapInfo({
    this.mapId,
    this.mapTitle,
    this.mapCoverBase64,
    this.coverQuality,
  });

  @override
  List<Object?> get props => [mapId, mapTitle, mapCoverBase64, coverQuality];
}

// 注意：根据简化需求，移除了光标位置和选中元素相关的事件
// 如果将来需要这些功能，可以通过WebRTC实现

/// 接收远程用户状态更新
class ReceiveRemoteUserPresence extends PresenceEvent {
  final UserPresence userPresence;

  const ReceiveRemoteUserPresence({required this.userPresence});

  @override
  List<Object?> get props => [userPresence];
}

/// 用户加入协作
class UserJoinedCollaboration extends PresenceEvent {
  final String clientId;
  final String userName;
  final DateTime joinedAt;

  const UserJoinedCollaboration({
    required this.clientId,
    required this.userName,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [clientId, userName, joinedAt];
}

/// 用户离开协作
class UserLeftCollaboration extends PresenceEvent {
  final String clientId;
  final DateTime leftAt;

  const UserLeftCollaboration({required this.clientId, required this.leftAt});

  @override
  List<Object?> get props => [clientId, leftAt];
}

/// 清理离线用户
class CleanupOfflineUsers extends PresenceEvent {
  final Duration offlineThreshold;

  const CleanupOfflineUsers({
    this.offlineThreshold = const Duration(minutes: 5),
  });

  @override
  List<Object?> get props => [offlineThreshold];
}

/// 重置所有用户状态
class ResetAllPresence extends PresenceEvent {
  const ResetAllPresence();
}

// 注意：SyncFromMapDataBloc 事件已被移除
// 当前实现通过直接调用 UpdateCurrentUserStatus 来更新状态
