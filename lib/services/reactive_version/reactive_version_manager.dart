// This file has been processed by AI for internationalization
import 'package:flutter/foundation.dart';
import '../../models/map_item.dart';
import '../../models/map_layer.dart';
import '../../services/legend_cache_manager.dart';
import '../legend_vfs/legend_vfs_service.dart';
import '../localization_service.dart';

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
      versionName:
          json['versionName'] as String? ?? json['versionId'] as String,
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
  final String? folderPath;

  // 版本会话状态管理
  final Map<String, ReactiveVersionState> _versionStates = {};
  String? _currentVersionId;
  String? _activeEditingVersionId; // 当前正在编辑的版本

  // 版本隔离的数据管理
  final Map<String, MapItem> _versionDataCache = {};

  // 版本隔离的图例路径选择管理
  final Map<String, Map<String, Set<String>>> _versionPathSelections = {};

  ReactiveVersionManager({required this.mapTitle, this.folderPath});

  /// 获取所有版本状态
  List<ReactiveVersionState> get allVersionStates =>
      _versionStates.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  /// 获取当前版本ID
  String? get currentVersionId => _currentVersionId;

  /// 获取当前正在编辑的版本ID
  String? get activeEditingVersionId => _activeEditingVersionId;

  /// 获取当前版本状态
  ReactiveVersionState? get currentVersionState =>
      _currentVersionId != null ? _versionStates[_currentVersionId] : null;

  /// 获取当前正在编辑的版本状态
  ReactiveVersionState? get activeEditingVersionState =>
      _activeEditingVersionId != null
      ? _versionStates[_activeEditingVersionId]
      : null;

  /// 获取指定版本的状态
  ReactiveVersionState? getVersionState(String versionId) {
    return _versionStates[versionId];
  }

  /// 获取指定版本的会话数据
  MapItem? getVersionSessionData(String versionId) {
    return _versionStates[versionId]?.sessionData ??
        _versionDataCache[versionId];
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

    debugPrint(
      LocalizationService.instance.current.initVersionSession(
        mapTitle,
        versionId,
        versionName ?? versionId,
      ),
    );
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
      throw ArgumentError(
        LocalizationService.instance.current.versionExists_7285(versionId),
      );
    }
    MapItem? initialData;

    // 如果指定了源版本，复制其会话数据
    if (sourceVersionId != null &&
        _versionStates.containsKey(sourceVersionId)) {
      initialData = _versionStates[sourceVersionId]?.sessionData;
      debugPrint(
        LocalizationService.instance.current.copyDataFromVersion(
          sourceVersionId,
          initialData != null
              ? LocalizationService.instance.current.dataWithLayers_5729(
                  initialData.layers.length,
                )
              : LocalizationService.instance.current.noData_6943,
        ),
      );
    }

    // 复制源版本的路径选择状态（如果存在）
    if (sourceVersionId != null &&
        _versionPathSelections.containsKey(sourceVersionId)) {
      final Map<String, Set<String>> newVersionPathSelections = {};
      final sourcePathSelections = _versionPathSelections[sourceVersionId]!;

      for (final entry in sourcePathSelections.entries) {
        newVersionPathSelections[entry.key] = Set<String>.from(entry.value);
      }

      _versionPathSelections[versionId] = newVersionPathSelections;
      debugPrint(
        LocalizationService.instance.current.copyPathSelectionStatus(
          sourceVersionId,
          versionId,
        ),
      );
    } else {
      // 创建空的路径选择状态
      _versionPathSelections[versionId] = <String, Set<String>>{};
    }

    final state = initializeVersion(
      versionId,
      versionName: versionName,
      initialData: initialData,
      metadata: metadata,
    );

    debugPrint(
      LocalizationService.instance.current.createVersionSession_4821(
            mapTitle,
            versionId,
            versionName,
          ) +
          (sourceVersionId != null
              ? LocalizationService.instance.current.copiedFrom_5729(
                  sourceVersionId,
                )
              : ''),
    );

    return state;
  }

  /// 删除版本（仅从内存中删除会话状态）
  void deleteVersion(String versionId) {
    if (versionId == 'default') {
      throw ArgumentError(
        LocalizationService.instance.current.cannotDeleteDefaultVersion_4271,
      );
    }

    if (!_versionStates.containsKey(versionId)) {
      debugPrint(
        LocalizationService.instance.current.versionNotExistNeedDelete(
          versionId,
        ),
      );
      return;
    }

    _versionStates.remove(versionId);
    _versionDataCache.remove(versionId);
    _versionPathSelections.remove(versionId); // 删除路径选择数据

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

    debugPrint(
      LocalizationService.instance.current.deleteVersionSession(
        mapTitle,
        versionId,
      ),
    );
    notifyListeners();
  }

  /// 切换到指定版本
  void switchToVersion(String versionId) {
    if (!_versionStates.containsKey(versionId)) {
      throw ArgumentError(
        LocalizationService.instance.current.versionNotFoundError_4821(
          versionId,
        ),
      );
    }

    final previousVersionId = _currentVersionId;
    _currentVersionId = versionId;

    debugPrint(
      LocalizationService.instance.current.versionSwitchLog_7421(
        mapTitle,
        previousVersionId ?? 'null',
        versionId,
      ),
    );
    notifyListeners();
  }

  /// 比较两个版本的路径选择差异并执行相应的缓存操作
  /// [fromVersionId] 源版本ID
  /// [toVersionId] 目标版本ID
  /// [onPathAdded] 当路径被添加时的回调（加载到缓存）
  /// [onPathRemoved] 当路径被移除时的回调（从缓存清理）
  void compareVersionPathsAndUpdateCache(
    String fromVersionId,
    String toVersionId, {
    Function(String legendGroupId, String path)? onPathAdded,
    Function(String legendGroupId, String path)? onPathRemoved,
  }) {
    debugPrint(
      LocalizationService.instance.current.compareVersionPathDiff_4827(
        fromVersionId,
        toVersionId,
      ),
    );

    // 确保两个版本的路径选择数据存在
    _ensureVersionPathSelectionExists(fromVersionId);
    _ensureVersionPathSelectionExists(toVersionId);

    final fromPaths = _getVersionAllPaths(fromVersionId);
    final toPaths = _getVersionAllPaths(toVersionId);

    // 验证路径数据
    if (fromPaths.isEmpty && toPaths.isEmpty) {
      debugPrint(LocalizationService.instance.current.versionWarning_4821);
      return;
    }

    // 找出新增的路径（目标版本有，源版本没有）
    final addedPaths = <String, Set<String>>{};
    for (final entry in toPaths.entries) {
      final legendGroupId = entry.key;
      final paths = entry.value;
      final previousPaths = fromPaths[legendGroupId] ?? <String>{};

      final newPaths = paths.difference(previousPaths);
      if (newPaths.isNotEmpty) {
        addedPaths[legendGroupId] = newPaths;
      }
    }

    // 找出移除的路径（源版本有，目标版本没有）
    final removedPaths = <String, Set<String>>{};
    for (final entry in fromPaths.entries) {
      final legendGroupId = entry.key;
      final paths = entry.value;
      final currentPaths = toPaths[legendGroupId] ?? <String>{};

      final deletedPaths = paths.difference(currentPaths);
      if (deletedPaths.isNotEmpty) {
        removedPaths[legendGroupId] = deletedPaths;
      }
    }

    debugPrint(
      LocalizationService.instance.current.pathDiffAnalysisComplete_7281,
    );
    debugPrint(
      LocalizationService.instance.current.addedPathsCount(
        addedPaths.values.fold(0, (sum, set) => (sum as int) + set.length),
      ),
    );
    debugPrint(
      LocalizationService.instance.current.removedPathsCount_7421(
        removedPaths.values.fold(0, (sum, set) => (sum as int) + set.length),
      ),
    );

    // 处理新增的路径（加载到缓存）
    for (final entry in addedPaths.entries) {
      final legendGroupId = entry.key;
      for (final path in entry.value) {
        debugPrint(
          LocalizationService.instance.current.loadingPathToCache(
            legendGroupId,
            path,
          ),
        );
        onPathAdded?.call(legendGroupId, path);
        _loadPathToCache(path);
      }
    }

    // 处理移除的路径（从缓存清理）
    for (final entry in removedPaths.entries) {
      final legendGroupId = entry.key;
      for (final path in entry.value) {
        // 检查该路径是否还被目标版本的其他图例组使用
        final stillUsed = toPaths.values.any((paths) => paths.contains(path));
        if (!stillUsed) {
          debugPrint(
            LocalizationService.instance.current.cacheCleanPath(
              legendGroupId,
              path,
            ),
          );
          onPathRemoved?.call(legendGroupId, path);
          _clearPathFromCache(path);
        } else {
          debugPrint(LocalizationService.instance.current.pathStillInUse(path));
        }
      }
    }
  }

  /// 获取指定版本的所有路径选择
  Map<String, Set<String>> _getVersionAllPaths(String versionId) {
    _ensureVersionPathSelectionExists(versionId);
    final versionData = _versionPathSelections[versionId]!;

    // 返回深拷贝以避免修改原数据
    final result = <String, Set<String>>{};
    for (final entry in versionData.entries) {
      result[entry.key] = Set<String>.from(entry.value);
    }

    return result;
  }

  /// 将路径加载到缓存
  Future<void> _loadPathToCache(String path) async {
    try {
      debugPrint(
        LocalizationService.instance.current.loadingPathToCache_7281(path),
      );

      final cacheManager = LegendCacheManager();
      final legendService = LegendVfsService();

      // 获取目录下的所有图例文件
      final legendFiles = await legendService.getLegendsInFolder(path);

      debugPrint(
        LocalizationService.instance.current.legendFilesFound_7281(
          path,
          legendFiles.length,
        ),
      );

      // 逐个加载图例到缓存
      for (final legendFile in legendFiles) {
        try {
          final legendPath = path.isEmpty ? legendFile : '$path/$legendFile';

          // 使用缓存管理器的异步加载方法
          await cacheManager.getLegendData(legendPath);
          debugPrint(
            LocalizationService.instance.current.loadedToCache_7281(legendPath),
          );
        } catch (e) {
          debugPrint(
            LocalizationService.instance.current.legendLoadFailed_7281(
              legendFile,
              e,
            ),
          );
        }
      }

      debugPrint(
        LocalizationService.instance.current.pathLoadedComplete_728(path),
      );
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.loadPathToCacheFailed(path, e),
      );
    }
  }

  /// 从缓存清理路径
  void _clearPathFromCache(String path) {
    try {
      final cacheManager = LegendCacheManager();

      // 使用已有的步进型清理方法
      cacheManager.clearCacheByFolderStepwise(path);
      debugPrint(
        LocalizationService.instance.current.cacheCleanedPath_7281(path),
      );
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.cacheCleanFailed(path, e),
      );
    }
  }

  /// 智能版本切换（包含缓存管理）
  void switchToVersionWithCacheManagement(String versionId) {
    if (!_versionStates.containsKey(versionId)) {
      throw ArgumentError(
        LocalizationService.instance.current.versionNotFoundError_7284(
          versionId,
        ),
      );
    }

    final previousVersionId = _currentVersionId;
    debugPrint(
      LocalizationService.instance.current.versionSwitchStart(
        previousVersionId ?? 'null',
        versionId,
      ),
    );

    // 如果有之前的版本，比较路径差异并更新缓存
    if (previousVersionId != null && previousVersionId != versionId) {
      debugPrint(
        LocalizationService.instance.current.compareVersionPathDiff(
          previousVersionId,
          versionId,
        ),
      );

      // 输出当前版本的路径选择状态
      final fromPaths = _getVersionAllPaths(previousVersionId);
      final toPaths = _getVersionAllPaths(versionId);

      debugPrint(
        LocalizationService.instance.current.sourceVersionPathSelection_7281(
          previousVersionId,
        ),
      );
      for (final entry in fromPaths.entries) {
        debugPrint(
          '  ${LocalizationService.instance.current.legendGroup_7421} ${entry.key}: ${entry.value.join(", ")}',
        );
      }

      debugPrint(
        LocalizationService.instance.current.versionPathSelection_7281(
          versionId,
        ),
      );
      for (final entry in toPaths.entries) {
        debugPrint(
          LocalizationService.instance.current.legendGroup_7421(
            entry.key,
            entry.value.join(", "),
          ),
        );
      }

      compareVersionPathsAndUpdateCache(
        previousVersionId,
        versionId,
        onPathAdded: (legendGroupId, path) {
          debugPrint(
            LocalizationService.instance.current.versionSwitchPath_4821(
              legendGroupId,
              path,
            ),
          );
        },
        onPathRemoved: (legendGroupId, path) {
          debugPrint(
            LocalizationService.instance.current.versionSwitchCleanPath(
              legendGroupId,
              path,
            ),
          );
        },
      );
    } else {
      debugPrint(
        LocalizationService.instance.current.noNeedComparePathDiff(
          previousVersionId ?? 'null',
          versionId,
        ),
      );
    }

    // 执行版本切换
    switchToVersion(versionId);

    debugPrint(
      LocalizationService.instance.current.versionSwitchComplete(
        previousVersionId ?? 'null',
        versionId,
      ),
    );
  }

  /// 开始编辑指定版本
  void startEditingVersion(String versionId) {
    if (!_versionStates.containsKey(versionId)) {
      throw ArgumentError(
        LocalizationService.instance.current.versionNotFoundError_4821(
          versionId,
        ),
      );
    }

    _activeEditingVersionId = versionId;
    debugPrint(
      LocalizationService.instance.current.startEditingVersion(
        mapTitle,
        versionId,
      ),
    );
    notifyListeners();
  }

  /// 停止编辑当前版本
  void stopEditingVersion() {
    if (_activeEditingVersionId != null) {
      debugPrint(
        LocalizationService.instance.current.stopEditingVersion(
          mapTitle,
          _activeEditingVersionId ?? 'null',
        ),
      );
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
      debugPrint(
        LocalizationService.instance.current.versionNotFoundCannotUpdate(
          versionId,
        ),
      );
      return;
    }

    _versionStates[versionId] = currentState.copyWith(
      sessionData: newData,
      hasUnsavedChanges: markAsChanged,
      lastModified: DateTime.now(),
    );
    _versionDataCache[versionId] = newData;

    debugPrint(
      LocalizationService.instance.current.updateVersionSessionData_4821(
        mapTitle,
        versionId,
        markAsChanged
            ? LocalizationService.instance.current.modified_5732
            : LocalizationService.instance.current.notModified_6843,
        newData.layers.length,
      ),
    );
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
      debugPrint(
        LocalizationService.instance.current.versionOrSessionNotFound(
          versionId,
        ),
      );
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
      debugPrint(
        LocalizationService.instance.current.versionOrSessionNotFound(
          versionId,
        ),
      );
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

      debugPrint(
        LocalizationService.instance.current.versionSavedLog(
          '$mapTitle',
          '$versionId',
        ),
      );
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
      debugPrint(
        LocalizationService.instance.current.allVersionsSaved_7281(mapTitle),
      );
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

      debugPrint(
        LocalizationService.instance.current.updateVersionName(
          mapTitle,
          versionId,
          newName,
        ),
      );
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

      debugPrint(
        LocalizationService.instance.current.updateVersionMetadata_7421(
          mapTitle,
          versionId,
        ),
      );
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
      throw ArgumentError(
        LocalizationService.instance.current.sourceVersionNotFound_4821(
          sourceVersionId,
        ),
      );
    }

    if (_versionStates.containsKey(newVersionId)) {
      throw ArgumentError(
        LocalizationService.instance.current.targetVersionExists_4821(
          newVersionId,
        ),
      );
    }

    final newState = ReactiveVersionState(
      versionId: newVersionId,
      versionName:
          newVersionName ??
          '${sourceState.versionName} ' +
              LocalizationService.instance.current.copySuffix_4821,
      sessionData: sourceState.sessionData,
      hasUnsavedChanges: true, // 副本标记为已修改，需要保存
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      metadata: Map.from(sourceState.metadata),
    );
    _versionStates[newVersionId] = newState;

    final sourceSessionData = sourceState.sessionData;
    if (sourceSessionData != null) {
      _versionDataCache[newVersionId] = sourceSessionData;
    }

    debugPrint(
      LocalizationService.instance.current.copyVersionSession(
        mapTitle,
        sourceVersionId,
        newVersionId,
      ),
    );
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
        ? ', ' +
              LocalizationService.instance.current.editingVersion_7421(
                _activeEditingVersionId!,
              )
        : '';

    return LocalizationService.instance.current.mapSessionSummary_1589(
          mapTitle,
          totalVersions,
          unsavedCount,
          _currentVersionId ?? 'null',
        ) +
        editingInfo;
  }

  /// 清理所有会话状态
  void clearAllSessions() {
    _versionStates.clear();
    _versionDataCache.clear();
    _versionPathSelections.clear(); // 清理路径选择数据
    _currentVersionId = null;
    _activeEditingVersionId = null;

    debugPrint(
      LocalizationService.instance.current.clearSessionState_7421(mapTitle),
    );
    notifyListeners();
  }

  /// 清理指定版本的会话数据（保留状态信息）
  void clearVersionSessionData(String versionId) {
    final currentState = _versionStates[versionId];
    if (currentState != null) {
      _versionStates[versionId] = currentState.copyWith(clearSessionData: true);
      _versionDataCache.remove(versionId);

      debugPrint(
        LocalizationService.instance.current.cleanVersionSessionData(
          mapTitle,
          versionId,
        ),
      );
      notifyListeners();
    }
  }

  /// 版本状态验证
  bool validateVersionStates() {
    bool isValid = true;

    // 检查当前版本是否存在
    if (_currentVersionId != null &&
        !_versionStates.containsKey(_currentVersionId)) {
      debugPrint(
        LocalizationService.instance.current.invalidVersionIdWarning(
          _currentVersionId ?? 'null',
        ),
      );
      isValid = false;
    }

    // 检查正在编辑的版本是否存在
    if (_activeEditingVersionId != null &&
        !_versionStates.containsKey(_activeEditingVersionId)) {
      debugPrint(
        LocalizationService.instance.current.invalidVersionIdWarning(
          _activeEditingVersionId ?? 'null',
        ),
      );
      isValid = false;
    }

    // 检查数据缓存一致性
    for (final entry in _versionStates.entries) {
      if (entry.value.sessionData != null &&
          !_versionDataCache.containsKey(entry.key)) {
        debugPrint(
          LocalizationService.instance.current.versionSessionCacheMissing_7421(
            entry.key,
          ),
        );
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
      'versionStates': _versionStates.map(
        (k, v) => MapEntry(k, {
          'versionName': v.versionName,
          'hasUnsavedChanges': v.hasUnsavedChanges,
          'hasSessionData': v.sessionData != null,
          'lastModified': v.lastModified.toIso8601String(),
        }),
      ),
    };
  }

  /// 获取指定版本下指定图例组选中的路径
  Set<String> getVersionSelectedPaths(String versionId, String legendGroupId) {
    _ensureVersionPathSelectionExists(versionId, legendGroupId);
    return _versionPathSelections[versionId]![legendGroupId]!;
  }

  /// 获取当前版本下指定图例组选中的路径
  Set<String> getSelectedPaths(String legendGroupId) {
    final versionId = _currentVersionId ?? 'default';
    return getVersionSelectedPaths(versionId, legendGroupId);
  }

  /// 获取当前版本下所有图例组选中的路径
  Set<String> getAllSelectedPaths() {
    final versionId = _currentVersionId ?? 'default';
    _ensureVersionPathSelectionExists(versionId);

    final Set<String> allPaths = {};
    final versionData = _versionPathSelections[versionId]!;

    for (final paths in versionData.values) {
      allPaths.addAll(paths);
    }

    return allPaths;
  }

  /// 检查路径是否被其他图例组选中
  bool isPathSelectedByOtherGroups(String path, String currentGroupId) {
    final versionId = _currentVersionId ?? 'default';
    _ensureVersionPathSelectionExists(versionId);

    final versionData = _versionPathSelections[versionId]!;

    for (final entry in versionData.entries) {
      final groupId = entry.key;
      final paths = entry.value;

      // 如果不是当前组，但包含该路径，则返回true
      if (groupId != currentGroupId && paths.contains(path)) {
        return true;
      }
    }

    return false;
  }

  /// 设置路径选中状态
  void setPathSelected(String legendGroupId, String path, bool selected) {
    final versionId = _currentVersionId ?? 'default';
    _ensureVersionPathSelectionExists(versionId, legendGroupId);

    if (selected) {
      _versionPathSelections[versionId]![legendGroupId]!.add(path);
    } else {
      _versionPathSelections[versionId]![legendGroupId]!.remove(path);
    }

    debugPrint(
      LocalizationService.instance.current.versionLegendGroupStatusPath(
        versionId,
        legendGroupId,
        selected
            ? LocalizationService.instance.current.selected_3632
            : LocalizationService.instance.current.unselected_3633,
        path,
      ),
    );
    notifyListeners();
  }

  /// 获取当前版本下所有图例组ID
  Set<String> getCurrentVersionLegendGroupIds() {
    final versionId = _currentVersionId ?? 'default';
    _ensureVersionPathSelectionExists(versionId);
    return Set.from(_versionPathSelections[versionId]!.keys);
  }

  /// 重置图例组选择
  void resetLegendGroupSelections(String legendGroupId) {
    final versionId = _currentVersionId ?? 'default';
    _ensureVersionPathSelectionExists(versionId, legendGroupId);

    // 清空当前图例组在当前版本的选择
    _versionPathSelections[versionId]![legendGroupId]!.clear();

    debugPrint(
      LocalizationService.instance.current.resetVersionLegendSelection(
        versionId,
        legendGroupId,
      ),
    );
    notifyListeners();
  }

  /// 清除缓存 - 步进型清理（只清理直接路径，不递归清理子路径）
  void clearUnusedCache(
    String legendGroupId,
    String folderPath,
    Function(String) onClearCache,
  ) {
    // 只检查精确路径匹配，不检查父子关系
    if (isPathSelectedByOtherGroups(folderPath, legendGroupId) ||
        getSelectedPaths(legendGroupId).contains(folderPath)) {
      // 路径仍在使用中，不清理
      debugPrint(
        LocalizationService.instance.current.steppedCleanupSkip_4827(
          folderPath,
        ),
      );
      return;
    }

    // 通知清理缓存（只清理该路径本身，不递归清理子路径）
    debugPrint(
      LocalizationService.instance.current.steppedCleanupLog(folderPath),
    );
    onClearCache(folderPath);
  }

  /// 步进型检查路径是否被其他组选中（只检查精确匹配）
  bool isPathSelectedByOtherGroupsStepwise(String path, String currentGroupId) {
    final versionId = _currentVersionId ?? 'default';
    _ensureVersionPathSelectionExists(versionId);

    final versionData = _versionPathSelections[versionId]!;

    for (final entry in versionData.entries) {
      final groupId = entry.key;
      final paths = entry.value;

      // 只检查精确路径匹配，不检查父子关系
      if (groupId != currentGroupId && paths.contains(path)) {
        return true;
      }
    }

    return false;
  }

  /// 确保版本的路径选择数据结构存在
  void _ensureVersionPathSelectionExists(
    String versionId, [
    String? legendGroupId,
  ]) {
    _versionPathSelections.putIfAbsent(
      versionId,
      () => <String, Set<String>>{},
    );

    if (legendGroupId != null) {
      _versionPathSelections[versionId]!.putIfAbsent(
        legendGroupId,
        () => <String>{},
      );
    }
  }

  @override
  void dispose() {
    clearAllSessions();
    super.dispose();
  }

  /// 获取选择了指定路径的图例组ID列表
  List<String> getGroupsSelectingPath(String path) {
    final versionId = _currentVersionId ?? 'default';
    _ensureVersionPathSelectionExists(versionId);

    final versionData = _versionPathSelections[versionId]!;
    final groups = <String>[];

    for (final entry in versionData.entries) {
      final groupId = entry.key;
      final paths = entry.value;

      if (paths.contains(path)) {
        groups.add(groupId);
      }
    }

    return groups;
  }

  /// 获取选择了指定路径的其他图例组ID列表（排除当前图例组）
  List<String> getOtherGroupsSelectingPath(String path, String currentGroupId) {
    final allGroups = getGroupsSelectingPath(path);
    return allGroups.where((groupId) => groupId != currentGroupId).toList();
  }

  /// 获取图例组名称
  String? getLegendGroupName(String groupId) {
    final versionId = _currentVersionId ?? 'default';
    final versionState = _versionStates[versionId];
    final sessionData = versionState?.sessionData;

    if (sessionData == null) return null;

    // 在图例组列表中查找对应的图例组
    for (final group in sessionData.legendGroups) {
      if (group.id == groupId) {
        return group.name;
      }
    }

    return null; // 如果找不到图例组，返回null
  }

  /// 获取选择了指定路径的其他图例组名称列表（排除当前图例组）
  List<String> getOtherGroupNamesSelectingPath(
    String path,
    String currentGroupId,
  ) {
    final otherGroupIds = getOtherGroupsSelectingPath(path, currentGroupId);
    final groupNames = <String>[];

    for (final groupId in otherGroupIds) {
      final groupName = getLegendGroupName(groupId);
      if (groupName != null) {
        groupNames.add(groupName);
      } else {
        // 如果找不到名称，使用ID作为后备
        groupNames.add(groupId);
      }
    }

    return groupNames;
  }
}
