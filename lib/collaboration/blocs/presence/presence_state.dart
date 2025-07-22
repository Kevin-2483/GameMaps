import 'package:equatable/equatable.dart';
import '../../models/user_presence.dart';

/// 用户在线状态基类
abstract class PresenceState extends Equatable {
  const PresenceState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class PresenceInitial extends PresenceState {
  const PresenceInitial();
}

/// 加载中状态
class PresenceLoading extends PresenceState {
  const PresenceLoading();
}

/// 已加载状态
class PresenceLoaded extends PresenceState {
  final UserPresence currentUser;
  final Map<String, UserPresence> remoteUsers;
  final DateTime lastUpdated;

  const PresenceLoaded({
    required this.currentUser,
    required this.remoteUsers,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [currentUser, remoteUsers, lastUpdated];

  /// 获取所有在线用户（包括当前用户）
  List<UserPresence> get allUsers => [currentUser, ...remoteUsers.values];

  /// 获取所有远程用户
  List<UserPresence> get allRemoteUsers => remoteUsers.values.toList();

  /// 获取正在查看地图的用户
  List<UserPresence> get viewingUsers => allUsers
      .where((user) => user.status == UserActivityStatus.viewing)
      .toList();

  /// 获取正在编辑地图的用户
  List<UserPresence> get editingUsers => allUsers
      .where((user) => user.status == UserActivityStatus.editing)
      .toList();

  /// 获取在线但空闲的用户
  List<UserPresence> get idleUsers =>
      allUsers.where((user) => user.status == UserActivityStatus.idle).toList();

  /// 获取离线用户
  List<UserPresence> get offlineUsers => allUsers
      .where((user) => user.status == UserActivityStatus.offline)
      .toList();

  /// 根据客户端ID获取用户状态
  UserPresence? getUserByClientId(String clientId) {
    if (currentUser.clientId == clientId) {
      return currentUser;
    }
    return remoteUsers[clientId];
  }

  /// 检查用户是否在线
  bool isUserOnline(String clientId) {
    final user = getUserByClientId(clientId);
    return user != null && user.status != UserActivityStatus.offline;
  }

  /// 检查用户是否正在编辑
  bool isUserEditing(String clientId) {
    final user = getUserByClientId(clientId);
    return user != null && user.status == UserActivityStatus.editing;
  }

  /// 检查用户是否正在查看
  bool isUserViewing(String clientId) {
    final user = getUserByClientId(clientId);
    return user != null && user.status == UserActivityStatus.viewing;
  }

  /// 获取在线用户数量
  int get onlineUserCount => allUsers
      .where((user) => user.status != UserActivityStatus.offline)
      .length;

  /// 获取正在编辑的用户数量
  int get editingUserCount => editingUsers.length;

  /// 获取正在查看的用户数量
  int get viewingUserCount => viewingUsers.length;

  /// 检查是否有其他用户正在编辑
  bool get hasOtherEditingUsers =>
      editingUsers.any((user) => user.clientId != currentUser.clientId);

  /// 检查是否有其他用户在线
  bool get hasOtherOnlineUsers => allUsers
      .where((user) => user.clientId != currentUser.clientId)
      .any((user) => user.status != UserActivityStatus.offline);

  // 注意：选中元素和光标位置相关的方法已被移除
  // 当前实现专注于基本的在线状态和活动状态管理

  /// 复制状态并更新当前用户
  PresenceLoaded copyWithCurrentUser(UserPresence newCurrentUser) {
    return PresenceLoaded(
      currentUser: newCurrentUser,
      remoteUsers: remoteUsers,
      lastUpdated: DateTime.now(),
    );
  }

  /// 复制状态并更新远程用户
  PresenceLoaded copyWithRemoteUser(UserPresence remoteUser) {
    final newRemoteUsers = Map<String, UserPresence>.from(remoteUsers);
    newRemoteUsers[remoteUser.clientId] = remoteUser;

    return PresenceLoaded(
      currentUser: currentUser,
      remoteUsers: newRemoteUsers,
      lastUpdated: DateTime.now(),
    );
  }

  /// 复制状态并移除远程用户
  PresenceLoaded copyWithoutRemoteUser(String clientId) {
    final newRemoteUsers = Map<String, UserPresence>.from(remoteUsers);
    newRemoteUsers.remove(clientId);

    return PresenceLoaded(
      currentUser: currentUser,
      remoteUsers: newRemoteUsers,
      lastUpdated: DateTime.now(),
    );
  }

  /// 复制状态并清理离线用户
  PresenceLoaded copyWithCleanup(Duration offlineThreshold) {
    final now = DateTime.now();
    final newRemoteUsers = Map<String, UserPresence>.from(remoteUsers);

    newRemoteUsers.removeWhere((clientId, user) {
      return user.status == UserActivityStatus.offline ||
          now.difference(user.lastSeen).compareTo(offlineThreshold) > 0;
    });

    return PresenceLoaded(
      currentUser: currentUser,
      remoteUsers: newRemoteUsers,
      lastUpdated: now,
    );
  }
}

/// 错误状态
class PresenceError extends PresenceState {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  const PresenceError({required this.message, this.error, this.stackTrace});

  @override
  List<Object?> get props => [message, error, stackTrace];
}
