import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// 用户活动状态枚举
enum UserActivityStatus {
  /// 离线
  offline,

  /// 在线但空闲
  idle,

  /// 正在查看地图
  viewing,

  /// 正在编辑地图
  editing,
}

/// 用户在线状态信息
class UserPresence extends Equatable {
  /// 客户端ID
  final String clientId;

  /// 用户名（用于显示，不需要唯一）
  final String userName;

  /// 用户显示名称（从用户偏好设置获取）
  final String displayName;

  /// 用户头像（base64编码或网络链接）
  final String? avatar;

  /// 用户活动状态
  final UserActivityStatus status;

  /// 最后活跃时间
  final DateTime lastSeen;

  /// 加入协作的时间
  final DateTime joinedAt;

  // 注意：根据简化需求，移除了光标位置和选中元素字段
  // 如果将来需要这些功能，可以通过WebRTC实现

  /// 额外的元数据信息
  final Map<String, dynamic> metadata;

  const UserPresence({
    required this.clientId,
    required this.userName,
    required this.displayName,
    this.avatar,
    required this.status,
    required this.lastSeen,
    required this.joinedAt,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    clientId,
    userName,
    displayName,
    avatar,
    status,
    lastSeen,
    joinedAt,
    metadata,
  ];

  /// 检查用户是否在线
  bool get isOnline => status != UserActivityStatus.offline;

  /// 检查用户是否正在编辑
  bool get isEditing => status == UserActivityStatus.editing;

  /// 检查用户是否正在查看
  bool get isViewing => status == UserActivityStatus.viewing;

  /// 检查用户是否空闲
  bool get isIdle => status == UserActivityStatus.idle;

  /// 获取在线时长
  Duration get onlineDuration => DateTime.now().difference(joinedAt);

  /// 获取最后活跃时长
  Duration get lastSeenDuration => DateTime.now().difference(lastSeen);

  /// 检查用户是否长时间未活跃
  bool isInactive(Duration threshold) {
    return lastSeenDuration.compareTo(threshold) > 0;
  }

  // 注意：根据简化需求，移除了选中元素相关的方法
  // 如果将来需要这些功能，可以通过WebRTC实现

  /// 获取元数据中的值
  T? getMetadata<T>(String key) {
    final value = metadata[key];
    return value is T ? value : null;
  }

  /// 获取当前地图ID（从元数据中）
  String? get currentMapId => getMetadata<String>('currentMapId');

  /// 获取当前活跃图层ID（从元数据中）
  String? get activeLayerId => getMetadata<String>('activeLayerId');

  /// 获取当前编辑的地图标题（从元数据中）
  String? get currentMapTitle => getMetadata<String>('currentMapTitle');

  /// 获取当前地图封面的base64数据
  String? get currentMapCoverBase64 => getMetadata<String>('currentMapCover');

  /// 获取当前编辑的地图封面（压缩后的图片数据）
  Uint8List? get currentMapCover {
    final base64String = currentMapCoverBase64;
    if (base64String == null) return null;

    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  /// 获取地图封面的压缩质量设置
  int get mapCoverQuality {
    final qualityString = getMetadata<String>('mapCoverQuality');
    if (qualityString == null) return 70;
    return int.tryParse(qualityString) ?? 70;
  }

  /// 检查是否有地图封面数据
  bool get hasMapCover =>
      currentMapCoverBase64 != null && currentMapCoverBase64!.isNotEmpty;

  /// 检查是否有地图标题
  bool get hasMapTitle =>
      currentMapTitle != null && currentMapTitle!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'userName': userName,
      'displayName': displayName,
      'avatar': avatar,
      'status': status.name,
      'lastSeen': lastSeen.toIso8601String(),
      'joinedAt': joinedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory UserPresence.fromJson(Map<String, dynamic> json) {
    return UserPresence(
      clientId: json['client_id'],
      userName: json['userName'],
      displayName: json['displayName'] ?? json['userName'], // 向后兼容
      avatar: json['avatar'],
      status: UserActivityStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => UserActivityStatus.offline,
      ),
      lastSeen: DateTime.parse(json['lastSeen']),
      joinedAt: DateTime.parse(json['joinedAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  UserPresence copyWith({
    String? clientId,
    String? userName,
    String? displayName,
    String? avatar,
    UserActivityStatus? status,
    DateTime? lastSeen,
    DateTime? joinedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserPresence(
      clientId: clientId ?? this.clientId,
      userName: userName ?? this.userName,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      joinedAt: joinedAt ?? this.joinedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'UserPresence(clientId: $clientId, userName: $userName, displayName: $displayName, '
        'avatar: ${avatar != null ? "[有头像]" : "[无头像]"}, status: $status, '
        'lastSeen: $lastSeen, isOnline: $isOnline)';
  }
}

/// 用户在线状态统计信息
class PresenceStats extends Equatable {
  final int totalUsers;
  final int onlineUsers;
  final int editingUsers;
  final int viewingUsers;
  final int idleUsers;
  final int offlineUsers;
  final DateTime lastUpdated;

  const PresenceStats({
    required this.totalUsers,
    required this.onlineUsers,
    required this.editingUsers,
    required this.viewingUsers,
    required this.idleUsers,
    required this.offlineUsers,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    onlineUsers,
    editingUsers,
    viewingUsers,
    idleUsers,
    offlineUsers,
    lastUpdated,
  ];

  /// 在线用户百分比
  double get onlinePercentage {
    if (totalUsers == 0) return 0.0;
    return (onlineUsers / totalUsers) * 100;
  }

  /// 编辑用户百分比
  double get editingPercentage {
    if (onlineUsers == 0) return 0.0;
    return (editingUsers / onlineUsers) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'onlineUsers': onlineUsers,
      'editingUsers': editingUsers,
      'viewingUsers': viewingUsers,
      'idleUsers': idleUsers,
      'offlineUsers': offlineUsers,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory PresenceStats.fromJson(Map<String, dynamic> json) {
    return PresenceStats(
      totalUsers: json['totalUsers'],
      onlineUsers: json['onlineUsers'],
      editingUsers: json['editingUsers'],
      viewingUsers: json['viewingUsers'],
      idleUsers: json['idleUsers'],
      offlineUsers: json['offlineUsers'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  @override
  String toString() {
    return 'PresenceStats(total: $totalUsers, online: $onlineUsers, '
        'editing: $editingUsers, viewing: $viewingUsers)';
  }
}
