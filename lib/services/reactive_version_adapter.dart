import 'package:flutter/widgets.dart';
import '../services/reactive_version_manager.dart';
import '../data/map_data_bloc.dart';
import '../data/map_data_event.dart';
import '../data/map_data_state.dart';
import '../models/map_item.dart';
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
    if (activeVersionId == null) {
      debugPrint('没有正在编辑的版本，跳过数据同步');
      return;
    }
    if (state is MapDataLoaded) {
      // 检查数据是否真的有变化，避免无意义的更新
      final currentVersionData = _versionManager.getVersionSessionData(
        activeVersionId,
      );
      final newMapItem = state.mapItem.copyWith(
        layers: state.layers,
        legendGroups: state.legendGroups,
        // 确保便签数据也被复制到版本中
        stickyNotes: state.mapItem.stickyNotes,
        updatedAt: DateTime.now(),
      );

      // 如果数据没有实质性变化，不进行更新
      if (currentVersionData != null &&
          _isSameMapData(currentVersionData, newMapItem)) {
        return;
      }

      _isUpdating = true;
      try {
        _versionManager.updateVersionData(
          activeVersionId,
          newMapItem,
          markAsChanged: true,
        );

        debugPrint(
          '同步地图数据到版本 [$activeVersionId], 图层数: ${newMapItem.layers.length}, 便签数: ${newMapItem.stickyNotes.length}',
        );

        // 详细日志：便签绘画元素数量
        for (int i = 0; i < newMapItem.stickyNotes.length; i++) {
          final note = newMapItem.stickyNotes[i];
          debugPrint('  便签[$i] ${note.title}: ${note.elements.length}个绘画元素');
        }
      } finally {
        _isUpdating = false;
      }
    }
  }

  /// 检查两个MapItem是否相同（避免无意义更新）
  bool _isSameMapData(MapItem data1, MapItem data2) {
    if (data1.layers.length != data2.layers.length) return false;
    if (data1.legendGroups.length != data2.legendGroups.length) return false;
    if (data1.stickyNotes.length != data2.stickyNotes.length) return false;

    // 简单检查图层ID和基本属性
    for (int i = 0; i < data1.layers.length; i++) {
      final layer1 = data1.layers[i];
      final layer2 = data2.layers[i];
      if (layer1.id != layer2.id ||
          layer1.name != layer2.name ||
          layer1.isVisible != layer2.isVisible ||
          layer1.elements.length != layer2.elements.length) {
        return false;
      }
    }

    // 检查图例组变化（包括图例组内容）
    for (int i = 0; i < data1.legendGroups.length; i++) {
      final group1 = data1.legendGroups[i];
      final group2 = data2.legendGroups[i];
      if (group1.id != group2.id ||
          group1.name != group2.name ||
          group1.isVisible != group2.isVisible ||
          group1.opacity != group2.opacity ||
          group1.legendItems.length != group2.legendItems.length ||
          group1.updatedAt != group2.updatedAt) {
        return false;
      }

      // 检查图例组中的图例项变化
      for (int j = 0; j < group1.legendItems.length; j++) {
        final item1 = group1.legendItems[j];
        final item2 = group2.legendItems[j];
        if (item1.id != item2.id ||
            item1.legendId != item2.legendId ||
            item1.position != item2.position ||
            item1.size != item2.size ||
            item1.rotation != item2.rotation ||
            item1.opacity != item2.opacity ||
            item1.isVisible != item2.isVisible ||
            item1.url != item2.url) {
          return false;
        }
      }
    }    // 简单检查便签ID和基本属性
    for (int i = 0; i < data1.stickyNotes.length; i++) {
      final note1 = data1.stickyNotes[i];
      final note2 = data2.stickyNotes[i];  // 修复：使用data2而不是data1
      if (note1.id != note2.id ||
          note1.title != note2.title ||
          note1.content != note2.content ||
          note1.position != note2.position ||
          note1.size != note2.size ||  // 添加尺寸比较
          note1.opacity != note2.opacity ||  // 添加透明度比较
          note1.isVisible != note2.isVisible ||  // 添加可见性比较
          note1.isCollapsed != note2.isCollapsed ||  // 添加折叠状态比较
          note1.zIndex != note2.zIndex ||  // 添加层级比较
          note1.elements.length != note2.elements.length) {
        // 添加绘画元素数量检查
        return false;
      }

      // 检查便签上的绘画元素变化
      for (int j = 0; j < note1.elements.length; j++) {
        final element1 = note1.elements[j];
        final element2 = note2.elements[j];
        if (element1.id != element2.id ||
            element1.type != element2.type ||
            element1.points.length != element2.points.length ||
            element1.color != element2.color ||
            element1.strokeWidth != element2.strokeWidth ||
            element1.createdAt != element2.createdAt) {
          return false;
        }
      }
    }

    return true;
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

    debugPrint('开始切换版本: $versionId');

    _isUpdating = true;
    try {
      // 1. 切换版本管理器的当前版本
      _versionManager.switchToVersion(versionId);

      // 2. 获取版本的会话数据
      final versionData = _versionManager.getVersionSessionData(versionId);
      if (versionData != null) {
        // 3. 将版本数据加载到地图数据BLoC
        _mapDataBloc.add(InitializeMapData(mapItem: versionData));
        debugPrint(
          '切换并加载版本数据 [$versionId] 到响应式系统，图层数: ${versionData.layers.length}, 便签数: ${versionData.stickyNotes.length}',
        );

        // 详细日志：便签绘画元素数量
        for (int i = 0; i < versionData.stickyNotes.length; i++) {
          final note = versionData.stickyNotes[i];
          debugPrint('  加载便签[$i] ${note.title}: ${note.elements.length}个绘画元素');
        }
      } else {
        // 4. 如果没有会话数据，从VFS加载指定版本
        _mapDataBloc.add(
          LoadMapData(mapTitle: _versionManager.mapTitle, version: versionId),
        );
        debugPrint('从VFS加载版本数据 [$versionId] 到响应式系统');
      }

      // 5. 等待一个事件循环，确保BLoC状态更新完成
      await Future.delayed(const Duration(milliseconds: 50));

      // 6. 开始编辑该版本
      _versionManager.startEditingVersion(versionId);
      debugPrint('开始编辑版本 [$versionId]');
    } finally {
      // 延迟重置更新标志，确保数据加载完成
      await Future.delayed(const Duration(milliseconds: 100));
      _isUpdating = false;
      debugPrint('版本切换完成，重置更新标志 [$versionId]');
    }
  }

  /// 创建新版本并立即切换
  Future<ReactiveVersionState> createVersionAndSwitch(
    String versionId, {
    required String versionName,
    String? sourceVersionId,
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint('开始创建新版本: $versionId, 源版本: $sourceVersionId');

    _isUpdating = true;
    try {
      // 1. 获取源数据作为新版本的初始数据
      MapItem? initialData;

      if (sourceVersionId != null) {
        // 从指定源版本获取数据
        initialData = _versionManager.getVersionSessionData(sourceVersionId);
        debugPrint(
          '从源版本 [$sourceVersionId] 获取数据: ${initialData != null ? '成功(图层数: ${initialData.layers.length})' : '失败'}',
        );
      }

      // 如果没有源版本数据，使用当前BLoC的数据
      if (initialData == null && _mapDataBloc.state is MapDataLoaded) {
        final currentState = _mapDataBloc.state as MapDataLoaded;
        initialData = currentState.mapItem.copyWith(
          layers: List.from(currentState.layers), // 深度复制图层列表
          legendGroups: List.from(currentState.legendGroups), // 深度复制图例组列表
          updatedAt: DateTime.now(),
        );
        debugPrint('从当前BLoC状态获取数据: 图层数: ${initialData.layers.length}');
      }

      // 2. 创建新版本（不传递initialData，避免重复设置）
      final newVersionState = _versionManager.createVersion(
        versionId,
        versionName: versionName,
        sourceVersionId: sourceVersionId,
        metadata: metadata,
      );

      // 3. 如果有初始数据，立即设置到新版本
      if (initialData != null) {
        _versionManager.updateVersionData(
          versionId,
          initialData,
          markAsChanged: false, // 初始数据不标记为已修改
        );
        debugPrint('为新版本 [$versionId] 设置初始数据成功');
      } else {
        debugPrint('警告: 新版本 [$versionId] 没有初始数据');
      }

      // 4. 先重置更新标志，再切换版本
      _isUpdating = false;

      // 5. 切换到新版本并加载数据
      await switchToVersionAndLoad(versionId);

      debugPrint('新版本创建并切换完成: $versionId');
      return newVersionState;
    } catch (e) {
      _isUpdating = false;
      debugPrint('创建新版本失败 [$versionId]: $e');
      rethrow;
    }
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
  Map<String, dynamic> getVersionDifferences(
    String versionId1,
    String versionId2,
  ) {
    final data1 = _versionManager.getVersionSessionData(versionId1);
    final data2 = _versionManager.getVersionSessionData(versionId2);

    if (data1 == null || data2 == null) {
      return {'error': '版本数据不完整'};
    }

    return {
      'version1': versionId1,
      'version2': versionId2,
      'layerCountDiff': data1.layers.length - data2.layers.length,
      'legendGroupCountDiff':
          data1.legendGroups.length - data2.legendGroups.length,
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
