import 'dart:ui';
import 'package:equatable/equatable.dart';

/// 协作元素锁定状态
class ElementLockState extends Equatable {
  /// 元素ID
  final String elementId;
  
  /// 元素类型 (layer, legend, drawing_element, sticky_note)
  final String elementType;
  
  /// 锁定该元素的用户ID
  final String lockedByUserId;
  
  /// 锁定时间
  final DateTime lockedAt;
  
  /// 锁定超时时间（秒）
  final int timeoutSeconds;
  
  /// 是否为强制锁定（不可被其他用户抢占）
  final bool isHardLock;
  
  // 添加userId getter以保持兼容性
  String get userId => lockedByUserId;

  const ElementLockState({
    required this.elementId,
    required this.elementType,
    required this.lockedByUserId,
    required this.lockedAt,
    this.timeoutSeconds = 30,
    this.isHardLock = false,
  });

  @override
  List<Object?> get props => [
    elementId,
    elementType,
    lockedByUserId,
    lockedAt,
    timeoutSeconds,
    isHardLock,
  ];

  /// 检查锁定是否已过期
  bool get isExpired {
    final now = DateTime.now();
    return now.difference(lockedAt).inSeconds > timeoutSeconds;
  }

  /// 获取剩余锁定时间（秒）
  int get remainingSeconds {
    final now = DateTime.now();
    final elapsed = now.difference(lockedAt).inSeconds;
    return (timeoutSeconds - elapsed).clamp(0, timeoutSeconds);
  }

  Map<String, dynamic> toJson() {
    return {
      'elementId': elementId,
      'elementType': elementType,
      'lockedByUserId': lockedByUserId,
      'lockedAt': lockedAt.toIso8601String(),
      'timeoutSeconds': timeoutSeconds,
      'isHardLock': isHardLock,
    };
  }

  factory ElementLockState.fromJson(Map<String, dynamic> json) {
    return ElementLockState(
      elementId: json['elementId'],
      elementType: json['elementType'],
      lockedByUserId: json['lockedByUserId'],
      lockedAt: DateTime.parse(json['lockedAt']),
      timeoutSeconds: json['timeoutSeconds'] ?? 30,
      isHardLock: json['isHardLock'] ?? false,
    );
  }

  ElementLockState copyWith({
    String? elementId,
    String? elementType,
    String? lockedByUserId,
    DateTime? lockedAt,
    int? timeoutSeconds,
    bool? isHardLock,
  }) {
    return ElementLockState(
      elementId: elementId ?? this.elementId,
      elementType: elementType ?? this.elementType,
      lockedByUserId: lockedByUserId ?? this.lockedByUserId,
      lockedAt: lockedAt ?? this.lockedAt,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      isHardLock: isHardLock ?? this.isHardLock,
    );
  }
}

/// 用户选择状态
class UserSelectionState extends Equatable {
  /// 用户ID
  final String userId;
  
  /// 选中的元素ID列表
  final List<String> selectedElementIds;
  
  /// 选择的元素类型
  final String selectionType;
  
  /// 最后更新时间
  final DateTime lastUpdated;
  
  // 添加兼容性getter
  String get userDisplayName => userId;
  Color get userColor => const Color(0xFF2196F3);

  const UserSelectionState({
    required this.userId,
    required this.selectedElementIds,
    required this.selectionType,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    userId,
    selectedElementIds,
    selectionType,
    lastUpdated,
  ];

  /// 检查是否选中了指定元素
  bool isElementSelected(String elementId) {
    return selectedElementIds.contains(elementId);
  }

  /// 检查是否有选中的元素
  bool get hasSelection => selectedElementIds.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'selectedElementIds': selectedElementIds,
      'selectionType': selectionType,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserSelectionState.fromJson(Map<String, dynamic> json) {
    return UserSelectionState(
      userId: json['userId'],
      selectedElementIds: List<String>.from(json['selectedElementIds'] ?? []),
      selectionType: json['selectionType'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  UserSelectionState copyWith({
    String? userId,
    List<String>? selectedElementIds,
    String? selectionType,
    DateTime? lastUpdated,
  }) {
    return UserSelectionState(
      userId: userId ?? this.userId,
      selectedElementIds: selectedElementIds ?? this.selectedElementIds,
      selectionType: selectionType ?? this.selectionType,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// 用户指针位置状态
class UserCursorState extends Equatable {
  /// 用户ID
  final String userId;
  
  /// 指针位置（相对于地图的归一化坐标 0.0-1.0）
  final Offset position;
  
  /// 是否可见
  final bool isVisible;
  
  /// 最后更新时间
  final DateTime lastUpdated;
  
  /// 用户显示名称（用于显示标签）
  final String displayName;
  
  /// 用户颜色（用于区分不同用户）
  final Color userColor;
  
  // 添加兼容性getter
  String get userDisplayName => displayName;
  Color get color => userColor;

  const UserCursorState({
    required this.userId,
    required this.position,
    required this.isVisible,
    required this.lastUpdated,
    required this.displayName,
    required this.userColor,
  });

  @override
  List<Object?> get props => [
    userId,
    position,
    isVisible,
    lastUpdated,
    displayName,
    userColor,
  ];

  /// 检查指针是否过期（超过一定时间未更新）
  bool isExpired(Duration threshold) {
    return DateTime.now().difference(lastUpdated) > threshold;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'position': {'x': position.dx, 'y': position.dy},
      'isVisible': isVisible,
      'lastUpdated': lastUpdated.toIso8601String(),
      'displayName': displayName,
      'userColor': userColor.toARGB32(),
    };
  }

  factory UserCursorState.fromJson(Map<String, dynamic> json) {
    final positionData = json['position'] as Map<String, dynamic>;
    return UserCursorState(
      userId: json['userId'],
      position: Offset(positionData['x'], positionData['y']),
      isVisible: json['isVisible'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      displayName: json['displayName'],
      userColor: Color(json['userColor']),
    );
  }

  UserCursorState copyWith({
    String? userId,
    Offset? position,
    bool? isVisible,
    DateTime? lastUpdated,
    String? displayName,
    Color? userColor,
  }) {
    return UserCursorState(
      userId: userId ?? this.userId,
      position: position ?? this.position,
      isVisible: isVisible ?? this.isVisible,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      displayName: displayName ?? this.displayName,
      userColor: userColor ?? this.userColor,
    );
  }
}

/// 协作冲突信息
class CollaborationConflict extends Equatable {
  /// 冲突ID
  final String conflictId;
  
  /// 冲突的元素ID
  final String elementId;
  
  /// 冲突类型
  final ConflictType conflictType;
  
  /// 涉及的用户ID列表
  final List<String> involvedUserIds;
  
  /// 冲突发生时间
  final DateTime occurredAt;
  
  /// 冲突描述
  final String description;
  
  /// 是否已解决
  final bool isResolved;
  
  /// 元素类型
  final String elementType;
  
  /// 解决方法
  final String? resolutionMethod;
  
  /// 元数据
  final Map<String, dynamic> metadata;
  
  // 添加兼容性getter
  String get id => conflictId;
  ConflictType get type => conflictType;
  DateTime get timestamp => occurredAt;
  DateTime get createdAt => occurredAt;

  const CollaborationConflict({
    required this.conflictId,
    required this.elementId,
    required this.conflictType,
    required this.involvedUserIds,
    required this.occurredAt,
    required this.description,
    this.isResolved = false,
    required this.elementType,
    this.resolutionMethod,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    conflictId,
    elementId,
    conflictType,
    involvedUserIds,
    occurredAt,
    description,
    isResolved,
    elementType,
    resolutionMethod,
    metadata,
  ];

  Map<String, dynamic> toJson() {
    return {
      'conflictId': conflictId,
      'elementId': elementId,
      'conflictType': conflictType.name,
      'involvedUserIds': involvedUserIds,
      'occurredAt': occurredAt.toIso8601String(),
      'description': description,
      'isResolved': isResolved,
      'elementType': elementType,
      'resolutionMethod': resolutionMethod,
      'metadata': metadata,
    };
  }

  factory CollaborationConflict.fromJson(Map<String, dynamic> json) {
    return CollaborationConflict(
      conflictId: json['conflictId'],
      elementId: json['elementId'],
      conflictType: ConflictType.values.firstWhere(
        (type) => type.name == json['conflictType'],
        orElse: () => ConflictType.editConflict,
      ),
      involvedUserIds: List<String>.from(json['involvedUserIds'] ?? []),
      occurredAt: DateTime.parse(json['occurredAt']),
      description: json['description'],
      isResolved: json['isResolved'] ?? false,
      elementType: json['elementType'],
      resolutionMethod: json['resolutionMethod'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

/// 冲突类型枚举
enum ConflictType {
  /// 编辑冲突（多用户同时编辑同一元素）
  editConflict,
  
  /// 锁定冲突（尝试锁定已被锁定的元素）
  lockConflict,
  
  /// 删除冲突（尝试删除被其他用户使用的元素）
  deleteConflict,
  
  /// 权限冲突（权限不足）
  permissionConflict,
  
  /// 元素锁定冲突
  elementLockConflict,
  
  /// 同时编辑
  simultaneousEdit,
  
  /// 版本不匹配
  versionMismatch,
  
  /// 权限被拒绝
  permissionDenied,
  
  /// 网络错误
  networkError,
  
  /// 其他
  other,
}