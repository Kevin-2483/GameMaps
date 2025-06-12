import 'package:flutter/foundation.dart';

import '../models/map_item.dart';

/// 版本会话状态
class VersionSessionState {
  final String versionId;
  final MapItem? modifiedData;
  final bool hasUnsavedChanges;
  final DateTime lastModified;
  final List<MapItem> undoHistory;
  final List<MapItem> redoHistory;

  const VersionSessionState({
    required this.versionId,
    this.modifiedData,
    this.hasUnsavedChanges = false,
    required this.lastModified,
    this.undoHistory = const [],
    this.redoHistory = const [],
  });

  VersionSessionState copyWith({
    String? versionId,
    MapItem? modifiedData,
    bool? hasUnsavedChanges,
    DateTime? lastModified,
    List<MapItem>? undoHistory,
    List<MapItem>? redoHistory,
  }) {
    return VersionSessionState(
      versionId: versionId ?? this.versionId,
      modifiedData: modifiedData ?? this.modifiedData,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      lastModified: lastModified ?? this.lastModified,
      undoHistory: undoHistory ?? this.undoHistory,
      redoHistory: redoHistory ?? this.redoHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versionId': versionId,
      'modifiedData': modifiedData?.toJson(),
      'hasUnsavedChanges': hasUnsavedChanges,
      'lastModified': lastModified.toIso8601String(),
      'undoHistory': undoHistory.map((item) => item.toJson()).toList(),
      'redoHistory': redoHistory.map((item) => item.toJson()).toList(),
    };
  }

  factory VersionSessionState.fromJson(Map<String, dynamic> json) {
    return VersionSessionState(
      versionId: json['versionId'] as String,
      modifiedData: json['modifiedData'] != null
          ? MapItem.fromJson(json['modifiedData'] as Map<String, dynamic>)
          : null,
      hasUnsavedChanges: json['hasUnsavedChanges'] as bool? ?? false,
      lastModified: DateTime.parse(json['lastModified'] as String),
      undoHistory:
          (json['undoHistory'] as List<dynamic>?)
              ?.map((item) => MapItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      redoHistory:
          (json['redoHistory'] as List<dynamic>?)
              ?.map((item) => MapItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 版本会话管理器
/// 负责管理多个版本在会话中的修改状态
class VersionSessionManager {
  final String mapTitle;
  final Map<String, VersionSessionState> _sessionStates = {};
  String? _currentVersionId;
  final int maxUndoHistory;

  VersionSessionManager({required this.mapTitle, this.maxUndoHistory = 50});

  /// 获取当前版本ID
  String? get currentVersionId => _currentVersionId;

  /// 获取所有会话状态
  List<VersionSessionState> get allSessionStates =>
      _sessionStates.values.toList();

  /// 获取指定版本的会话状态
  VersionSessionState? getSessionState(String versionId) {
    return _sessionStates[versionId];
  }

  /// 检查版本是否有未保存的更改
  bool hasUnsavedChanges(String versionId) {
    return _sessionStates[versionId]?.hasUnsavedChanges ?? false;
  }

  /// 检查是否有任何版本有未保存的更改
  bool get hasAnyUnsavedChanges {
    return _sessionStates.values.any((state) => state.hasUnsavedChanges);
  }

  /// 获取版本的修改数据
  MapItem? getModifiedData(String versionId) {
    return _sessionStates[versionId]?.modifiedData;
  }

  /// 获取版本的撤销历史
  List<MapItem> getUndoHistory(String versionId) {
    return _sessionStates[versionId]?.undoHistory ?? [];
  }

  /// 获取版本的重做历史
  List<MapItem> getRedoHistory(String versionId) {
    return _sessionStates[versionId]?.redoHistory ?? [];
  }

  /// 初始化版本会话状态
  void initializeVersionSession(String versionId, MapItem initialData) {
    if (!_sessionStates.containsKey(versionId)) {
      _sessionStates[versionId] = VersionSessionState(
        versionId: versionId,
        modifiedData: initialData,
        hasUnsavedChanges: false,
        lastModified: DateTime.now(),
      );
    }
  }

  /// 更新版本数据
  void updateVersionData(
    String versionId,
    MapItem newData, {
    bool markAsChanged = true,
  }) {
    final currentState = _sessionStates[versionId];
    if (currentState != null) {
      _sessionStates[versionId] = currentState.copyWith(
        modifiedData: newData,
        hasUnsavedChanges: markAsChanged,
        lastModified: DateTime.now(),
      );
    } else {
      _sessionStates[versionId] = VersionSessionState(
        versionId: versionId,
        modifiedData: newData,
        hasUnsavedChanges: markAsChanged,
        lastModified: DateTime.now(),
      );
    }
  }

  /// 标记版本已保存
  void markVersionSaved(String versionId) {
    final currentState = _sessionStates[versionId];
    if (currentState != null) {
      _sessionStates[versionId] = currentState.copyWith(
        hasUnsavedChanges: false,
        lastModified: DateTime.now(),
      );
    }
  }

  /// 标记所有版本已保存
  void markAllVersionsSaved() {
    for (final versionId in _sessionStates.keys) {
      markVersionSaved(versionId);
    }
  }

  /// 添加到撤销历史
  void addToUndoHistory(String versionId, MapItem state) {
    final currentState = _sessionStates[versionId];
    if (currentState != null) {
      final newUndoHistory = List<MapItem>.from(currentState.undoHistory);
      newUndoHistory.add(state);

      // 限制历史记录数量
      if (newUndoHistory.length > maxUndoHistory) {
        newUndoHistory.removeAt(0);
      }

      _sessionStates[versionId] = currentState.copyWith(
        undoHistory: newUndoHistory,
        redoHistory: [], // 清空重做历史
        lastModified: DateTime.now(),
      );
    }
  }

  /// 撤销操作
  MapItem? undo(String versionId) {
    final currentState = _sessionStates[versionId];
    if (currentState == null || currentState.undoHistory.isEmpty) {
      return null;
    }

    final newUndoHistory = List<MapItem>.from(currentState.undoHistory);
    final previousState = newUndoHistory.removeLast();

    final newRedoHistory = List<MapItem>.from(currentState.redoHistory);
    if (currentState.modifiedData != null) {
      newRedoHistory.add(currentState.modifiedData!);

      // 限制重做历史记录数量
      if (newRedoHistory.length > maxUndoHistory) {
        newRedoHistory.removeAt(0);
      }
    }

    _sessionStates[versionId] = currentState.copyWith(
      modifiedData: previousState,
      undoHistory: newUndoHistory,
      redoHistory: newRedoHistory,
      hasUnsavedChanges: true,
      lastModified: DateTime.now(),
    );

    return previousState;
  }

  /// 重做操作
  MapItem? redo(String versionId) {
    final currentState = _sessionStates[versionId];
    if (currentState == null || currentState.redoHistory.isEmpty) {
      return null;
    }

    final newRedoHistory = List<MapItem>.from(currentState.redoHistory);
    final nextState = newRedoHistory.removeLast();

    final newUndoHistory = List<MapItem>.from(currentState.undoHistory);
    if (currentState.modifiedData != null) {
      newUndoHistory.add(currentState.modifiedData!);

      // 限制撤销历史记录数量
      if (newUndoHistory.length > maxUndoHistory) {
        newUndoHistory.removeAt(0);
      }
    }

    _sessionStates[versionId] = currentState.copyWith(
      modifiedData: nextState,
      undoHistory: newUndoHistory,
      redoHistory: newRedoHistory,
      hasUnsavedChanges: true,
      lastModified: DateTime.now(),
    );

    return nextState;
  }

  /// 切换当前版本
  void switchToVersion(String versionId) {
    _currentVersionId = versionId;
  }

  /// 删除版本会话状态
  void removeVersionSession(String versionId) {
    _sessionStates.remove(versionId);
    if (_currentVersionId == versionId) {
      _currentVersionId = null;
    }
  }

  /// 清空所有会话状态
  void clearAllSessions() {
    _sessionStates.clear();
    _currentVersionId = null;
  }

  /// 清理过期的会话状态（超过指定天数的状态）
  void cleanupExpiredSessions({int expireDays = 7}) {
    final expireTime = DateTime.now().subtract(Duration(days: expireDays));
    final expiredVersions = <String>[];

    for (final entry in _sessionStates.entries) {
      if (entry.value.lastModified.isBefore(expireTime)) {
        expiredVersions.add(entry.key);
      }
    }

    for (final versionId in expiredVersions) {
      _sessionStates.remove(versionId);
    }

    if (expiredVersions.isNotEmpty) {
      debugPrint('清理了 ${expiredVersions.length} 个过期的版本会话状态');
    }
  }

  /// 获取版本会话摘要信息
  String getSessionSummary() {
    final totalVersions = _sessionStates.length;
    final unsavedCount = _sessionStates.values
        .where((state) => state.hasUnsavedChanges)
        .length;
    return '总版本: $totalVersions, 未保存: $unsavedCount, 当前: $_currentVersionId';
  }
}
