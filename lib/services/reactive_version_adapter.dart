import 'package:flutter/widgets.dart';
import '../services/reactive_version_manager.dart';
import '../data/map_data_bloc.dart';
import '../data/map_data_event.dart';
import '../data/map_data_state.dart';
import 'dart:async';

/// 响应式版本管理适配器
/// 将响应式版本管理器与地图数据BLoC系统集成
/// 负责版本间的数据隔离和状态同步
class ReactiveVersionAdapter {
  final ReactiveVersionManager _versionManager;
  final MapDataBloc _mapDataBloc;
  
  StreamSubscription<MapDataState>? _mapDataSubscription;
  bool _isUpdating = false; // 防止循环更新的标志
  
  ReactiveVersionAdapter({
    required ReactiveVersionManager versionManager,
    required MapDataBloc mapDataBloc,
  }) : _versionManager = versionManager,
       _mapDataBloc = mapDataBloc {
    _setupListeners();
  }

  /// 获取版本管理器
  ReactiveVersionManager get versionManager => _versionManager;

  /// 获取地图数据BLoC
  MapDataBloc get mapDataBloc => _mapDataBloc;

  /// 设置监听器
  void _setupListeners() {
    // 监听地图数据变化，同步到当前编辑版本
    _mapDataSubscription = _mapDataBloc.stream.listen(_onMapDataChanged);
    
    // 监听版本管理器变化，同步到地图数据BLoC
    _versionManager.addListener(_onVersionManagerChanged);
  }

  /// 处理地图数据变化
  void _onMapDataChanged(MapDataState state) {
    if (_isUpdating) return; // 防止循环更新
    
    final activeVersionId = _versionManager.activeEditingVersionId;
    if (activeVersionId == null) return;

    if (state is MapDataLoaded) {
      _isUpdating = true;
      try {
        // 同步地图数据到当前编辑版本
        final updatedMapItem = state.mapItem.copyWith(
          layers: state.layers,
          legendGroups: state.legendGroups,
          updatedAt: DateTime.now(),
        );
        
        _versionManager.updateVersionData(
          activeVersionId,
          updatedMapItem,
          markAsChanged: true,
        );
        
        debugPrint('同步地图数据到版本 [$activeVersionId]');
      } finally {
        _isUpdating = false;
      }
    }
  }

  /// 处理版本管理器变化
  void _onVersionManagerChanged() {
    if (_isUpdating) return; // 防止循环更新
    
    // 这里可以添加版本切换时需要的额外处理逻辑
    debugPrint('版本管理器状态变化: ${_versionManager.getSessionSummary()}');
  }

  /// 切换到指定版本并加载其数据到BLoC
  Future<void> switchToVersionAndLoad(String versionId) async {
    if (!_versionManager.versionExists(versionId)) {
      throw ArgumentError('版本不存在: $versionId');
    }

    _isUpdating = true;
    try {
      // 1. 切换版本管理器的当前版本
      _versionManager.switchToVersion(versionId);
      
      // 2. 开始编辑该版本
      _versionManager.startEditingVersion(versionId);
      
      // 3. 获取版本的会话数据
      final versionData = _versionManager.getVersionSessionData(versionId);
      
      if (versionData != null) {
        // 4. 将版本数据加载到地图数据BLoC
        _mapDataBloc.add(InitializeMapData(mapItem: versionData));
        debugPrint('切换并加载版本数据 [$versionId] 到响应式系统');
      } else {
        // 5. 如果没有会话数据，从VFS加载指定版本
        _mapDataBloc.add(LoadMapData(
          mapTitle: _versionManager.mapTitle,
          version: versionId,
        ));
        debugPrint('从VFS加载版本数据 [$versionId] 到响应式系统');
      }
      
    } finally {
      _isUpdating = false;
    }
  }

  /// 创建新版本并立即切换
  Future<ReactiveVersionState> createVersionAndSwitch(
    String versionId, {
    required String versionName,
    String? sourceVersionId,
    Map<String, dynamic>? metadata,
  }) async {
    // 1. 创建新版本
    final newVersionState = _versionManager.createVersion(
      versionId,
      versionName: versionName,
      sourceVersionId: sourceVersionId,
      metadata: metadata,
    );

    // 2. 切换到新版本并加载数据
    await switchToVersionAndLoad(versionId);

    return newVersionState;
  }

  /// 保存当前编辑版本的数据
  Future<void> saveCurrentVersion() async {
    final activeVersionId = _versionManager.activeEditingVersionId;
    if (activeVersionId == null) {
      debugPrint('没有正在编辑的版本，无需保存');
      return;
    }

    final versionData = _versionManager.getVersionSessionData(activeVersionId);
    if (versionData == null) {
      debugPrint('版本 [$activeVersionId] 没有会话数据，无法保存');
      return;
    }

    try {
      // 触发地图数据保存（会使用当前版本ID作为VFS版本参数）
      _mapDataBloc.add(const SaveMapData());
      
      // 标记版本已保存
      _versionManager.markVersionSaved(activeVersionId);
      
      debugPrint('保存版本数据 [$activeVersionId] 完成');
    } catch (e) {
      debugPrint('保存版本数据失败 [$activeVersionId]: $e');
      rethrow;
    }
  }

  /// 保存所有版本的数据
  Future<void> saveAllVersions() async {
    final unsavedVersions = _versionManager.unsavedVersions;
    
    for (final versionId in unsavedVersions) {
      try {
        // 切换到该版本
        await switchToVersionAndLoad(versionId);
        
        // 保存该版本
        await saveCurrentVersion();
        
      } catch (e) {
        debugPrint('保存版本数据失败 [$versionId]: $e');
        // 继续保存其他版本
      }
    }
    
    debugPrint('所有版本保存完成');
  }

  /// 删除版本及其数据
  Future<void> deleteVersionCompletely(String versionId) async {
    if (versionId == 'default') {
      throw ArgumentError('无法删除默认版本');
    }

    // 1. 从内存中删除版本状态
    _versionManager.deleteVersion(versionId);
    
    // 2. 如果需要，也可以从VFS中删除版本数据
    // 这里暂时不实现VFS删除，因为需求明确说明只做内存管理
    
    debugPrint('删除版本完成 [$versionId]');
  }

  /// 复制版本及其数据
  Future<ReactiveVersionState> duplicateVersionCompletely(
    String sourceVersionId,
    String newVersionId, {
    String? newVersionName,
  }) async {
    // 1. 复制版本状态和会话数据
    final newVersionState = _versionManager.duplicateVersion(
      sourceVersionId,
      newVersionId,
      newVersionName: newVersionName,
    );

    // 2. 切换到新版本以确保数据同步
    await switchToVersionAndLoad(newVersionId);

    return newVersionState;
  }

  /// 获取版本间的差异信息（用于调试）
  Map<String, dynamic> getVersionDifferences(String versionId1, String versionId2) {
    final data1 = _versionManager.getVersionSessionData(versionId1);
    final data2 = _versionManager.getVersionSessionData(versionId2);

    if (data1 == null || data2 == null) {
      return {'error': '版本数据不完整'};
    }

    return {
      'version1': versionId1,
      'version2': versionId2,
      'layerCountDiff': data1.layers.length - data2.layers.length,
      'legendGroupCountDiff': data1.legendGroups.length - data2.legendGroups.length,
      'lastModified1': data1.updatedAt.toIso8601String(),
      'lastModified2': data2.updatedAt.toIso8601String(),
    };
  }

  /// 验证版本数据完整性
  bool validateVersionData(String versionId) {
    final versionState = _versionManager.getVersionState(versionId);
    if (versionState == null) {
      debugPrint('版本状态不存在: $versionId');
      return false;
    }

    final sessionData = versionState.sessionData;
    if (sessionData == null) {
      debugPrint('版本会话数据不存在: $versionId');
      return false;
    }

    // 基本数据完整性检查
    if (sessionData.title.isEmpty) {
      debugPrint('版本数据标题为空: $versionId');
      return false;
    }

    return true;
  }

  /// 获取适配器状态信息
  Map<String, dynamic> getAdapterStatus() {
    return {
      'isUpdating': _isUpdating,
      'hasMapDataSubscription': _mapDataSubscription != null,
      'currentMapDataState': _mapDataBloc.state.runtimeType.toString(),
      'versionManagerInfo': _versionManager.getDebugInfo(),
    };
  }

  /// 释放资源
  void dispose() {
    _mapDataSubscription?.cancel();
    _mapDataSubscription = null;
    _versionManager.removeListener(_onVersionManagerChanged);
    
    debugPrint('响应式版本管理适配器已释放资源');
  }
}

/// 响应式版本管理混入
/// 为页面或组件提供版本管理功能
mixin ReactiveVersionMixin<T extends StatefulWidget> on State<T> {
  ReactiveVersionAdapter? _versionAdapter;

  /// 获取版本适配器
  ReactiveVersionAdapter? get versionAdapter => _versionAdapter;

  /// 初始化版本管理
  void initializeVersionManagement({
    required String mapTitle,
    required MapDataBloc mapDataBloc,
  }) {
    final versionManager = ReactiveVersionManager(mapTitle: mapTitle);
    _versionAdapter = ReactiveVersionAdapter(
      versionManager: versionManager,
      mapDataBloc: mapDataBloc,
    );
  }

  /// 切换版本
  Future<void> switchVersion(String versionId) async {
    await _versionAdapter?.switchToVersionAndLoad(versionId);
  }

  /// 创建版本
  Future<ReactiveVersionState?> createVersion(
    String versionId, {
    required String versionName,
    String? sourceVersionId,
  }) async {
    return await _versionAdapter?.createVersionAndSwitch(
      versionId,
      versionName: versionName,
      sourceVersionId: sourceVersionId,
    );
  }

  /// 保存当前版本
  Future<void> saveCurrentVersion() async {
    await _versionAdapter?.saveCurrentVersion();
  }

  /// 删除版本
  Future<void> deleteVersion(String versionId) async {
    await _versionAdapter?.deleteVersionCompletely(versionId);
  }

  /// 检查是否有未保存的更改
  bool get hasUnsavedChanges => 
      _versionAdapter?.versionManager.hasAnyUnsavedChanges ?? false;

  /// 获取当前版本ID
  String? get currentVersionId => 
      _versionAdapter?.versionManager.currentVersionId;

  /// 获取所有版本状态
  List<ReactiveVersionState> get allVersionStates => 
      _versionAdapter?.versionManager.allVersionStates ?? [];

  /// 释放版本管理资源
  void disposeVersionManagement() {
    _versionAdapter?.dispose();
    _versionAdapter = null;
  }
}
