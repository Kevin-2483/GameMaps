import 'package:flutter/foundation.dart';
import '../models/map_item.dart';
import '../models/map_layer.dart';

/// 版本会话状态（响应式）
class ReactiveVersionState {
  final String versionId;
  final String versionName;
  final MapItem? sessionData; // 会话中的地图数据
  final bool hasUnsavedChanges;
  final DateTime createdAt;
  final DateTime lastModified;
  final Map<String, dynamic> metadata;

  const ReactiveVersionState({
    required this.versionId,
    required this.versionName,
    this.sessionData,
    this.hasUnsavedChanges = false,
    required this.createdAt,
    required this.lastModified,
    this.metadata = const {},
  });

  ReactiveVersionState copyWith({
    String? versionId,
    String? versionName,
    MapItem? sessionData,
    bool? hasUnsavedChanges,
    DateTime? createdAt,
    DateTime? lastModified,
    Map<String, dynamic>? metadata,
    bool clearSessionData = false,
  }) {
    return ReactiveVersionState(
      versionId: versionId ?? this.versionId,
      versionName: versionName ?? this.versionName,
      sessionData: clearSessionData ? null : (sessionData ?? this.sessionData),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versionId': versionId,
      'versionName': versionName,
      'sessionData': sessionData?.toJson(),
      'hasUnsavedChanges': hasUnsavedChanges,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ReactiveVersionState.fromJson(Map<String, dynamic> json) {
    return ReactiveVersionState(
      versionId: json['versionId'] as String,
      versionName: json['versionName'] as String? ?? json['versionId'] as String,
      sessionData: json['sessionData'] != null
          ? MapItem.fromJson(json['sessionData'] as Map<String, dynamic>)
          : null,
      hasUnsavedChanges: json['hasUnsavedChanges'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// 响应式版本管理器
/// 专门负责在会话内存中管理版本状态，与VFS地图服务协同工作
/// 只处理会话状态，不涉及数据持久化
class ReactiveVersionManager extends ChangeNotifier {
  final String mapTitle;
  
  // 版本会话状态管理
  final Map<String, ReactiveVersionState> _versionStates = {};
  String? _currentVersionId;
  String? _activeEditingVersionId; // 当前正在编辑的版本
  
  // 版本隔离的数据管理
  final Map<String, MapItem> _versionDataCache = {};
  
  ReactiveVersionManager({required this.mapTitle});

  /// 获取所有版本状态
  List<ReactiveVersionState> get allVersionStates => 
      _versionStates.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  /// 获取当前版本ID
  String? get currentVersionId => _currentVersionId;

  /// 获取当前正在编辑的版本ID
  String? get activeEditingVersionId => _activeEditingVersionId;

  /// 获取当前版本状态
  ReactiveVersionState? get currentVersionState => 
      _currentVersionId != null ? _versionStates[_currentVersionId] : null;

  /// 获取当前正在编辑的版本状态
  ReactiveVersionState? get activeEditingVersionState =>
      _activeEditingVersionId != null ? _versionStates[_activeEditingVersionId] : null;

  /// 获取指定版本的状态
  ReactiveVersionState? getVersionState(String versionId) {
    return _versionStates[versionId];
  }

  /// 获取指定版本的会话数据
  MapItem? getVersionSessionData(String versionId) {
    return _versionStates[versionId]?.sessionData ?? _versionDataCache[versionId];
  }

  /// 检查版本是否存在
  bool versionExists(String versionId) {
    return _versionStates.containsKey(versionId);
  }

  /// 检查版本是否有未保存的更改
  bool hasUnsavedChanges(String versionId) {
    return _versionStates[versionId]?.hasUnsavedChanges ?? false;
  }

  /// 检查是否有任何版本有未保存的更改
  bool get hasAnyUnsavedChanges {
    return _versionStates.values.any((state) => state.hasUnsavedChanges);
  }

  /// 获取有未保存更改的版本列表
  List<String> get unsavedVersions {
    return _versionStates.entries
        .where((entry) => entry.value.hasUnsavedChanges)
        .map((entry) => entry.key)
        .toList();
  }

  /// 初始化版本（从存储加载或创建新版本）
  ReactiveVersionState initializeVersion(
    String versionId, {
    String? versionName,
    MapItem? initialData,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final state = ReactiveVersionState(
      versionId: versionId,
      versionName: versionName ?? versionId,
      sessionData: initialData,
      hasUnsavedChanges: false,
      createdAt: now,
      lastModified: now,
      metadata: metadata ?? {},
    );

    _versionStates[versionId] = state;
    
    if (initialData != null) {
      _versionDataCache[versionId] = initialData;
    }

    // 如果是第一个版本，设为当前版本
    if (_currentVersionId == null) {
      _currentVersionId = versionId;
    }

    debugPrint('初始化版本会话 [$mapTitle/$versionId]: ${versionName ?? versionId}');
    notifyListeners();
    return state;
  }

  /// 创建新版本（仅在内存中创建会话状态）
  ReactiveVersionState createVersion(
    String versionId, {
    required String versionName,
    String? sourceVersionId,
    Map<String, dynamic>? metadata,
  }) {
    if (_versionStates.containsKey(versionId)) {
      throw ArgumentError('版本已存在: $versionId');
    }    MapItem? initialData;
    
    // 如果指定了源版本，复制其会话数据
    if (sourceVersionId != null && _versionStates.containsKey(sourceVersionId)) {
      initialData = _versionStates[sourceVersionId]?.sessionData;
      debugPrint('从版本 $sourceVersionId 复制数据: ${initialData != null ? '有数据(图层数: ${initialData.layers.length})' : '无数据'}');
    }

    final state = initializeVersion(
      versionId,
      versionName: versionName,
      initialData: initialData,
      metadata: metadata,
    );

    debugPrint('创建新版本会话 [$mapTitle/$versionId]: $versionName' +
        (sourceVersionId != null ? ' (从 $sourceVersionId 复制)' : ''));
    
    return state;
  }

  /// 删除版本（仅从内存中删除会话状态）
  void deleteVersion(String versionId) {
    if (versionId == 'default') {
      throw ArgumentError('无法删除默认版本');
    }

    if (!_versionStates.containsKey(versionId)) {
      debugPrint('版本不存在，无需删除: $versionId');
      return;
    }

    _versionStates.remove(versionId);
    _versionDataCache.remove(versionId);

    // 如果删除的是当前版本，切换到其他版本
    if (_currentVersionId == versionId) {
      _currentVersionId = _versionStates.keys.isNotEmpty 
          ? _versionStates.keys.first 
          : null;
    }

    // 如果删除的是正在编辑的版本，清除编辑状态
    if (_activeEditingVersionId == versionId) {
      _activeEditingVersionId = null;
    }

    debugPrint('删除版本会话 [$mapTitle/$versionId]');
    notifyListeners();
  }

  /// 切换到指定版本
  void switchToVersion(String versionId) {
    if (!_versionStates.containsKey(versionId)) {
      throw ArgumentError('版本不存在: $versionId');
    }

    final previousVersionId = _currentVersionId;
    _currentVersionId = versionId;

    debugPrint('切换版本 [$mapTitle]: $previousVersionId -> $versionId');
    notifyListeners();
  }

  /// 开始编辑指定版本
  void startEditingVersion(String versionId) {
    if (!_versionStates.containsKey(versionId)) {
      throw ArgumentError('版本不存在: $versionId');
    }

    _activeEditingVersionId = versionId;
    debugPrint('开始编辑版本 [$mapTitle/$versionId]');
    notifyListeners();
  }

  /// 停止编辑当前版本
  void stopEditingVersion() {
    if (_activeEditingVersionId != null) {
      debugPrint('停止编辑版本 [$mapTitle/$_activeEditingVersionId]');
      _activeEditingVersionId = null;
      notifyListeners();
    }
  }

  /// 更新版本的会话数据
  void updateVersionData(
    String versionId,
    MapItem newData, {
    bool markAsChanged = true,
  }) {
    final currentState = _versionStates[versionId];
    if (currentState == null) {
      debugPrint('版本不存在，无法更新数据: $versionId');
      return;
    }

    _versionStates[versionId] = currentState.copyWith(
      sessionData: newData,
      hasUnsavedChanges: markAsChanged,
      lastModified: DateTime.now(),
    );    _versionDataCache[versionId] = newData;

    debugPrint('更新版本会话数据 [$mapTitle/$versionId], 标记为${markAsChanged ? '已修改' : '未修改'}, 图层数: ${newData.layers.length}');
    notifyListeners();
  }
  /// 更新版本层数据（专门用于图层操作）
  void updateVersionLayers(
    String versionId,
    List<MapLayer> layers, {
    bool markAsChanged = true,
  }) {
    final currentState = _versionStates[versionId];
    final sessionData = currentState?.sessionData;
    if (sessionData == null) {
      debugPrint('版本或会话数据不存在，无法更新图层: $versionId');
      return;
    }

    final updatedMapItem = sessionData.copyWith(
      layers: layers,
      updatedAt: DateTime.now(),
    );

    updateVersionData(versionId, updatedMapItem, markAsChanged: markAsChanged);
  }

  /// 更新版本图例组数据
  void updateVersionLegendGroups(
    String versionId,
    List<LegendGroup> legendGroups, {
    bool markAsChanged = true,
  }) {
    final currentState = _versionStates[versionId];
    final sessionData = currentState?.sessionData;
    if (sessionData == null) {
      debugPrint('版本或会话数据不存在，无法更新图例组: $versionId');
      return;
    }

    final updatedMapItem = sessionData.copyWith(
      legendGroups: legendGroups,
      updatedAt: DateTime.now(),
    );

    updateVersionData(versionId, updatedMapItem, markAsChanged: markAsChanged);
  }

  /// 标记版本已保存
  void markVersionSaved(String versionId) {
    final currentState = _versionStates[versionId];
    if (currentState != null) {
      _versionStates[versionId] = currentState.copyWith(
        hasUnsavedChanges: false,
        lastModified: DateTime.now(),
      );

      debugPrint('标记版本已保存 [$mapTitle/$versionId]');
      notifyListeners();
    }
  }

  /// 标记所有版本已保存
  void markAllVersionsSaved() {
    bool hasChanges = false;
    for (final versionId in _versionStates.keys) {
      final currentState = _versionStates[versionId]!;
      if (currentState.hasUnsavedChanges) {
        _versionStates[versionId] = currentState.copyWith(
          hasUnsavedChanges: false,
          lastModified: DateTime.now(),
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      debugPrint('标记所有版本已保存 [$mapTitle]');
      notifyListeners();
    }
  }

  /// 更新版本名称
  void updateVersionName(String versionId, String newName) {
    final currentState = _versionStates[versionId];
    if (currentState != null) {
      _versionStates[versionId] = currentState.copyWith(
        versionName: newName,
        lastModified: DateTime.now(),
      );

      debugPrint('更新版本名称 [$mapTitle/$versionId]: $newName');
      notifyListeners();
    }
  }

  /// 更新版本元数据
  void updateVersionMetadata(String versionId, Map<String, dynamic> metadata) {
    final currentState = _versionStates[versionId];
    if (currentState != null) {
      _versionStates[versionId] = currentState.copyWith(
        metadata: {...currentState.metadata, ...metadata},
        lastModified: DateTime.now(),
      );

      debugPrint('更新版本元数据 [$mapTitle/$versionId]');
      notifyListeners();
    }
  }

  /// 复制版本（仅复制会话状态和数据）
  ReactiveVersionState duplicateVersion(
    String sourceVersionId,
    String newVersionId, {
    String? newVersionName,
  }) {
    final sourceState = _versionStates[sourceVersionId];
    if (sourceState == null) {
      throw ArgumentError('源版本不存在: $sourceVersionId');
    }

    if (_versionStates.containsKey(newVersionId)) {
      throw ArgumentError('目标版本已存在: $newVersionId');
    }

    final newState = ReactiveVersionState(
      versionId: newVersionId,
      versionName: newVersionName ?? '${sourceState.versionName} (副本)',
      sessionData: sourceState.sessionData,
      hasUnsavedChanges: true, // 副本标记为已修改，需要保存
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      metadata: Map.from(sourceState.metadata),
    );    _versionStates[newVersionId] = newState;
    
    final sourceSessionData = sourceState.sessionData;
    if (sourceSessionData != null) {
      _versionDataCache[newVersionId] = sourceSessionData;
    }

    debugPrint('复制版本会话 [$mapTitle]: $sourceVersionId -> $newVersionId');
    notifyListeners();
    return newState;
  }

  /// 获取版本会话摘要信息
  String getSessionSummary() {
    final totalVersions = _versionStates.length;
    final unsavedCount = _versionStates.values
        .where((state) => state.hasUnsavedChanges)
        .length;
    final editingInfo = _activeEditingVersionId != null 
        ? ', 编辑中: $_activeEditingVersionId' 
        : '';
    
    return '地图: $mapTitle, 版本: $totalVersions, 未保存: $unsavedCount, 当前: $_currentVersionId$editingInfo';
  }

  /// 清理所有会话状态
  void clearAllSessions() {
    _versionStates.clear();
    _versionDataCache.clear();
    _currentVersionId = null;
    _activeEditingVersionId = null;

    debugPrint('清理所有版本会话状态 [$mapTitle]');
    notifyListeners();
  }

  /// 清理指定版本的会话数据（保留状态信息）
  void clearVersionSessionData(String versionId) {
    final currentState = _versionStates[versionId];
    if (currentState != null) {
      _versionStates[versionId] = currentState.copyWith(clearSessionData: true);
      _versionDataCache.remove(versionId);

      debugPrint('清理版本会话数据 [$mapTitle/$versionId]');
      notifyListeners();
    }
  }

  /// 版本状态验证
  bool validateVersionStates() {
    bool isValid = true;
    
    // 检查当前版本是否存在
    if (_currentVersionId != null && !_versionStates.containsKey(_currentVersionId)) {
      debugPrint('警告：当前版本ID无效: $_currentVersionId');
      isValid = false;
    }

    // 检查正在编辑的版本是否存在
    if (_activeEditingVersionId != null && !_versionStates.containsKey(_activeEditingVersionId)) {
      debugPrint('警告：正在编辑的版本ID无效: $_activeEditingVersionId');
      isValid = false;
    }

    // 检查数据缓存一致性
    for (final entry in _versionStates.entries) {
      if (entry.value.sessionData != null && !_versionDataCache.containsKey(entry.key)) {
        debugPrint('警告：版本 ${entry.key} 的会话数据缓存丢失');
        isValid = false;
      }
    }

    return isValid;
  }

  /// 获取调试信息
  Map<String, dynamic> getDebugInfo() {
    return {
      'mapTitle': mapTitle,
      'currentVersionId': _currentVersionId,
      'activeEditingVersionId': _activeEditingVersionId,
      'totalVersions': _versionStates.length,
      'versionsWithData': _versionDataCache.length,
      'unsavedVersions': unsavedVersions,
      'versionStates': _versionStates.map((k, v) => MapEntry(k, {
        'versionName': v.versionName,
        'hasUnsavedChanges': v.hasUnsavedChanges,
        'hasSessionData': v.sessionData != null,
        'lastModified': v.lastModified.toIso8601String(),
      })),
    };
  }

  @override
  void dispose() {
    clearAllSessions();
    super.dispose();
  }
}
