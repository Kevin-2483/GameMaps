import 'package:flutter/widgets.dart';
import 'reactive_version_manager.dart';
import '../../data/map_data_bloc.dart';
import '../../data/map_data_state.dart';
import '../../data/map_editor_integration_adapter.dart';
import '../../models/map_item.dart';
import '../../models/map_layer.dart';
import '../../models/sticky_note.dart';
import '../legend_session_manager.dart';
import 'dart:async';

/// 响应式版本管理适配器
/// 将响应式版本管理器与地图数据BLoC系统集成
/// 负责版本间的数据隔离和状态同步
/// 【重构后】：通过 MapEditorIntegrationAdapter 统一数据操作，避免直接操作 MapDataBloc
class ReactiveVersionAdapter {
  final ReactiveVersionManager _versionManager;
  final MapEditorIntegrationAdapter _integrationAdapter;
  final LegendSessionManager _legendSessionManager = LegendSessionManager();

  StreamSubscription<MapDataState>? _mapDataSubscription;
  bool _isUpdating = false; // 防止循环更新的标志

  ReactiveVersionAdapter({
    required ReactiveVersionManager versionManager,
    required MapEditorIntegrationAdapter integrationAdapter,
  }) : _versionManager = versionManager,
       _integrationAdapter = integrationAdapter {
    _setupListeners();
    
    // 如果当前已经有地图数据，立即初始化图例会话
    _initializeExistingMapData();
  }

  /// 获取版本管理器
  ReactiveVersionManager get versionManager => _versionManager;

  /// 获取集成适配器
  MapEditorIntegrationAdapter get integrationAdapter => _integrationAdapter;

  /// 获取地图数据BLoC（通过集成适配器访问）
  MapDataBloc get mapDataBloc => _integrationAdapter.mapDataBloc;

  /// 获取图例会话管理器
  LegendSessionManager get legendSessionManager => _legendSessionManager;

  /// 设置监听器
  void _setupListeners() {
    // 监听地图数据变化，同步到当前编辑版本
    _mapDataSubscription = _integrationAdapter.mapDataStream.listen(
      _onMapDataChanged,
    );

    // 监听版本管理器变化，同步到地图数据BLoC
    _versionManager.addListener(_onVersionManagerChanged);
  }

  /// 初始化已存在的地图数据（如果有的话）
  void _initializeExistingMapData() {
    final currentState = _integrationAdapter.currentState;
    if (currentState is MapDataLoaded) {
      // 异步初始化图例会话，不阻塞构造函数
      Future.microtask(() async {
        final mapItem = currentState.mapItem.copyWith(
          layers: currentState.layers,
          legendGroups: currentState.legendGroups,
          stickyNotes: currentState.mapItem.stickyNotes,
        );
        await _initializeLegendSession(mapItem);
        debugPrint('已为现有地图数据初始化图例会话');
      });
    }
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
          '同步地图数据到版本 [$activeVersionId], 图层数: ${newMapItem.layers.length}, 便签数: ${newMapItem.stickyNotes.length}, 图例组数: ${newMapItem.legendGroups.length}',
        );

        // 详细日志：便签绘画元素数量
        for (int i = 0; i < newMapItem.stickyNotes.length; i++) {
          final note = newMapItem.stickyNotes[i];
          debugPrint('  便签[$i] ${note.title}: ${note.elements.length}个绘画元素');
        }

        // 详细日志：图例组和图例项数量
        for (int i = 0; i < newMapItem.legendGroups.length; i++) {
          final group = newMapItem.legendGroups[i];
          debugPrint(
            '  图例组[$i] ${group.name}: ${group.legendItems.length}个图例项',
          );
        }

        // 异步初始化图例会话（不阻塞版本更新）
        Future.microtask(() async {
          await _initializeLegendSession(newMapItem);
        });
      } finally {
        _isUpdating = false;
      }
    }
  }

  /// 初始化图例会话（异步）
  Future<void> _initializeLegendSession(MapItem mapItem) async {
    try {
      // 从集成适配器获取地图绝对路径
      final mapAbsolutePath = _integrationAdapter.mapAbsolutePath;
      await _legendSessionManager.initializeSession(mapItem, mapAbsolutePath: mapAbsolutePath);
      debugPrint(
        '图例会话初始化完成，图例数量: ${_legendSessionManager.sessionData.loadedLegends.length}',
      );
    } catch (e) {
      debugPrint('图例会话初始化失败: $e');
    }
  }

  /// 检查两个MapItem是否相同（避免无意义更新）
  bool _isSameMapData(MapItem data1, MapItem data2) {
    if (data1.layers.length != data2.layers.length) return false;
    if (data1.legendGroups.length != data2.legendGroups.length) return false;
    if (data1.stickyNotes.length != data2.stickyNotes.length) return false;

    // 检查图层ID和所有属性（包括背景图片相关属性）
    for (int i = 0; i < data1.layers.length; i++) {
      final layer1 = data1.layers[i];
      final layer2 = data2.layers[i];
      if (layer1.id != layer2.id ||
          layer1.name != layer2.name ||
          layer1.order != layer2.order ||
          layer1.isVisible != layer2.isVisible ||
          layer1.opacity != layer2.opacity ||
          layer1.imageFit != layer2.imageFit || // 背景图片适应方式比较
          layer1.xOffset != layer2.xOffset || // X轴偏移比较
          layer1.yOffset != layer2.yOffset || // Y轴偏移比较
          layer1.imageScale !=
              layer2
                  .imageScale || // 缩放比例比较          layer1.isLinkedToNext != layer2.isLinkedToNext || // 链接状态比较
          layer1.legendGroupIds.length != layer2.legendGroupIds.length ||
          layer1.elements.length != layer2.elements.length ||
          layer1.tags?.length != layer2.tags?.length || // 图层标签数量比较
          layer1.updatedAt != layer2.updatedAt) {
        return false;
      }

      // 检查图层背景图片数据变化
      if ((layer1.imageData == null) != (layer2.imageData == null)) {
        return false;
      }
      if (layer1.imageData != null && layer2.imageData != null) {
        // 比较图片数据长度和内容
        if (layer1.imageData!.length != layer2.imageData!.length) {
          return false;
        }
        // 对于大图片，只比较前100字节作为快速检查
        final length = layer1.imageData!.length;
        final checkLength = length > 100 ? 100 : length;
        for (int k = 0; k < checkLength; k++) {
          if (layer1.imageData![k] != layer2.imageData![k]) {
            return false;
          }
        }
      } // 检查图层关联的图例组ID列表
      for (int j = 0; j < layer1.legendGroupIds.length; j++) {
        if (layer1.legendGroupIds[j] != layer2.legendGroupIds[j]) {
          return false;
        }
      }

      // 检查图层标签内容的变化
      if (layer1.tags != null && layer2.tags != null) {
        for (int j = 0; j < layer1.tags!.length; j++) {
          if (layer1.tags![j] != layer2.tags![j]) {
            return false;
          }
        }
      } else if (layer1.tags != layer2.tags) {
        // 一个为null，另一个不为null
        return false;
      }

      // 检查图层元素的详细变化（包括tags属性）
      for (int j = 0; j < layer1.elements.length; j++) {
        final element1 = layer1.elements[j];
        final element2 = layer2.elements[j];
        if (element1.id != element2.id ||
            element1.type != element2.type ||
            element1.color != element2.color ||
            element1.strokeWidth != element2.strokeWidth ||
            element1.density != element2.density ||
            element1.curvature != element2.curvature ||
            element1.triangleCut != element2.triangleCut ||
            element1.zIndex != element2.zIndex ||
            element1.text != element2.text ||
            element1.fontSize != element2.fontSize ||
            element1.points.length != element2.points.length ||
            element1.tags?.length != element2.tags?.length) {
          return false;
        }

        // 检查tags数组内容的变化
        if (element1.tags != null && element2.tags != null) {
          for (int k = 0; k < element1.tags!.length; k++) {
            if (element1.tags![k] != element2.tags![k]) {
              return false;
            }
          }
        } else if (element1.tags != element2.tags) {
          // 一个为null，另一个不为null
          return false;
        }

        // 检查points数组的变化
        for (int k = 0; k < element1.points.length; k++) {
          if (element1.points[k] != element2.points[k]) {
            return false;
          }
        }
      }
    } // 检查图例组变化（包括图例组内容和标签）
    for (int i = 0; i < data1.legendGroups.length; i++) {
      final group1 = data1.legendGroups[i];
      final group2 = data2.legendGroups[i];
      if (group1.id != group2.id ||
          group1.name != group2.name ||
          group1.isVisible != group2.isVisible ||
          group1.opacity != group2.opacity ||
          group1.legendItems.length != group2.legendItems.length ||
          group1.tags?.length != group2.tags?.length || // 图例组标签数量比较
          group1.updatedAt != group2.updatedAt) {
        return false;
      }

      // 检查图例组标签内容的变化
      if (group1.tags != null && group2.tags != null) {
        for (int j = 0; j < group1.tags!.length; j++) {
          if (group1.tags![j] != group2.tags![j]) {
            return false;
          }
        }
      } else if (group1.tags != group2.tags) {
        // 一个为null，另一个不为null
        return false;
      }

      // 检查图例组中的图例项变化（包括标签）
      for (int j = 0; j < group1.legendItems.length; j++) {
        final item1 = group1.legendItems[j];
        final item2 = group2.legendItems[j];
        if (item1.id != item2.id ||
            item1.legendPath != item2.legendPath || // 主要比较路径
            // 兼容性比较：如果两者都有legendId且路径相同，则比较legendId
            (item1.legendPath == item2.legendPath &&
                item1.legendId != null &&
                item2.legendId != null &&
                item1.legendId != item2.legendId) ||
            item1.position != item2.position ||
            item1.size != item2.size ||
            item1.rotation != item2.rotation ||
            item1.opacity != item2.opacity ||
            item1.isVisible != item2.isVisible ||
            item1.url != item2.url ||
            item1.tags?.length != item2.tags?.length) {
          // 图例项标签数量比较
          return false;
        }

        // 检查图例项标签内容的变化
        if (item1.tags != null && item2.tags != null) {
          for (int k = 0; k < item1.tags!.length; k++) {
            if (item1.tags![k] != item2.tags![k]) {
              return false;
            }
          }
        } else if (item1.tags != item2.tags) {
          // 一个为null，另一个不为null
          return false;
        }
      }
    } // 检查便签ID和所有属性（包括背景样式和标签）
    for (int i = 0; i < data1.stickyNotes.length; i++) {
      final note1 = data1.stickyNotes[i];
      final note2 = data2.stickyNotes[i]; // 修复：使用data2而不是data1
      if (note1.id != note2.id ||
          note1.title != note2.title ||
          note1.content != note2.content ||
          note1.position != note2.position ||
          note1.size != note2.size || // 尺寸比较
          note1.opacity != note2.opacity || // 透明度比较
          note1.isVisible != note2.isVisible || // 可见性比较
          note1.isCollapsed != note2.isCollapsed || // 折叠状态比较
          note1.zIndex != note2.zIndex || // 层级比较
          note1.backgroundColor != note2.backgroundColor || // 背景颜色比较
          note1.titleBarColor != note2.titleBarColor || // 标题栏颜色比较
          note1.textColor != note2.textColor || // 文字颜色比较
          note1.backgroundImageFit != note2.backgroundImageFit || // 背景图片适应方式比较
          note1.backgroundImageOpacity !=
              note2.backgroundImageOpacity || // 背景图片透明度比较
          note1.backgroundImageHash != note2.backgroundImageHash || // 背景图片哈希比较
          note1.elements.length != note2.elements.length || // 绘画元素数量检查
          note1.tags?.length != note2.tags?.length) {
        // 便签标签数量比较
        return false;
      }

      // 检查便签标签内容的变化
      if (note1.tags != null && note2.tags != null) {
        for (int j = 0; j < note1.tags!.length; j++) {
          if (note1.tags![j] != note2.tags![j]) {
            return false;
          }
        }
      } else if (note1.tags != note2.tags) {
        // 一个为null，另一个不为null
        return false;
      } // 检查背景图片数据变化（用于兼容性和即时显示）
      // 当便签同时有哈希引用和直接数据时，优先比较哈希引用
      if (note1.backgroundImageHash != null &&
          note2.backgroundImageHash != null &&
          note1.backgroundImageHash!.isNotEmpty &&
          note2.backgroundImageHash!.isNotEmpty) {
        // 两个便签都有哈希引用，直接比较哈希（已在上面处理）
      } else if ((note1.backgroundImageData == null) !=
          (note2.backgroundImageData == null)) {
        // 一个有直接数据，一个没有
        return false;
      } else if (note1.backgroundImageData != null &&
          note2.backgroundImageData != null) {
        // 两个便签都有直接数据，比较数据长度和内容
        if (note1.backgroundImageData!.length !=
            note2.backgroundImageData!.length) {
          return false;
        }
        // 对于大图片，只比较前100字节作为快速检查
        final length = note1.backgroundImageData!.length;
        final checkLength = length > 100 ? 100 : length;
        for (int k = 0; k < checkLength; k++) {
          if (note1.backgroundImageData![k] != note2.backgroundImageData![k]) {
            return false;
          }
        }
      } // 检查便签上的绘画元素变化（包括标签）
      for (int j = 0; j < note1.elements.length; j++) {
        final element1 = note1.elements[j];
        final element2 = note2.elements[j];
        if (element1.id != element2.id ||
            element1.type != element2.type ||
            element1.points.length != element2.points.length ||
            element1.color != element2.color ||
            element1.strokeWidth != element2.strokeWidth ||
            element1.tags?.length != element2.tags?.length || // 便签绘制元素标签数量比较
            element1.createdAt != element2.createdAt) {
          return false;
        }

        // 检查便签绘制元素标签内容的变化
        if (element1.tags != null && element2.tags != null) {
          for (int k = 0; k < element1.tags!.length; k++) {
            if (element1.tags![k] != element2.tags![k]) {
              return false;
            }
          }
        } else if (element1.tags != element2.tags) {
          // 一个为null，另一个不为null
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
      _versionManager.switchToVersionWithCacheManagement(versionId);

      // 2. 获取版本的会话数据
      final versionData = _versionManager.getVersionSessionData(versionId);
      if (versionData != null) {
        // 3. 将版本数据加载到地图数据BLoC（通过集成适配器）
        await _integrationAdapter.initializeMap(versionData);
        debugPrint(
          '切换并加载版本数据 [$versionId] 到响应式系统，图层数: ${versionData.layers.length}, 便签数: ${versionData.stickyNotes.length}',
        );

        // 详细日志：便签绘画元素数量
        for (int i = 0; i < versionData.stickyNotes.length; i++) {
          final note = versionData.stickyNotes[i];
          debugPrint('  加载便签[$i] ${note.title}: ${note.elements.length}个绘画元素');
        }

        // 初始化图例会话（等待完成，确保图例状态同步）
        await _initializeLegendSession(versionData);
      } else {
        // 4. 如果没有会话数据，从VFS加载指定版本（通过集成适配器）
        await _integrationAdapter.loadMap(
          _versionManager.mapTitle,
          version: versionId,
          folderPath: _versionManager.folderPath,
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
      if (initialData == null &&
          _integrationAdapter.currentState is MapDataLoaded) {
        final currentState = _integrationAdapter.currentState as MapDataLoaded;
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
      // 触发地图数据保存（通过集成适配器）
      await _integrationAdapter.saveMapData();

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

  // ==================== 图层操作支持 ====================

  /// 更新图层（响应式版本管理支持，通过集成适配器）
  void updateLayer(MapLayer layer) {
    debugPrint('响应式版本管理器: 更新图层 ${layer.name}');
    _integrationAdapter.updateLayer(layer);
  }

  /// 批量更新图层（响应式版本管理支持，通过集成适配器）
  void updateLayers(List<MapLayer> layers) {
    debugPrint('响应式版本管理器: 批量更新图层，数量: ${layers.length}');
    _integrationAdapter.updateLayers(layers);
  }

  /// 添加图层（响应式版本管理支持，通过集成适配器）
  void addLayer(MapLayer layer) {
    debugPrint('响应式版本管理器: 添加图层 ${layer.name}');
    _integrationAdapter.addLayer(layer);
  }

  /// 删除图层（响应式版本管理支持，通过集成适配器）
  void deleteLayer(String layerId) {
    debugPrint('响应式版本管理器: 删除图层 $layerId');
    _integrationAdapter.deleteLayer(layerId);
  }

  /// 设置图层可见性（响应式版本管理支持，通过集成适配器）
  void setLayerVisibility(String layerId, bool isVisible) {
    debugPrint('响应式版本管理器: 设置图层可见性 $layerId = $isVisible');
    _integrationAdapter.setLayerVisibility(layerId, isVisible);
  }

  /// 设置图层透明度（响应式版本管理支持，通过集成适配器）
  void setLayerOpacity(String layerId, double opacity) {
    debugPrint('响应式版本管理器: 设置图层透明度 $layerId = $opacity');
    _integrationAdapter.setLayerOpacity(layerId, opacity);
  }

  /// 重新排序图层（响应式版本管理支持，通过集成适配器）
  void reorderLayers(int oldIndex, int newIndex) {
    debugPrint('响应式版本管理器: 重新排序图层 $oldIndex -> $newIndex');
    _integrationAdapter.reorderLayers(oldIndex, newIndex);
  }

  /// 组内重排序图层（同时处理链接状态和顺序）
  void reorderLayersInGroup(
    int oldIndex,
    int newIndex,
    List<MapLayer> layersToUpdate,
  ) {
    debugPrint(
      '响应式版本管理器: 组内重排序图层 $oldIndex -> $newIndex，更新图层数量: ${layersToUpdate.length}',
    );
    _integrationAdapter.reorderLayersInGroup(
      oldIndex,
      newIndex,
      layersToUpdate,
    );
  }

  // ==================== 便签操作支持 ====================

  /// 添加便签（响应式版本管理支持，通过集成适配器）
  void addStickyNote(StickyNote note) {
    debugPrint('响应式版本管理器: 添加便签 ${note.title}');
    _integrationAdapter.addStickyNote(note);
  }

  /// 更新便签（响应式版本管理支持，通过集成适配器）
  void updateStickyNote(StickyNote note) {
    debugPrint('响应式版本管理器: 更新便签 ${note.title}');
    _integrationAdapter.updateStickyNote(note);
  }

  /// 删除便签（响应式版本管理支持，通过集成适配器）
  void deleteStickyNote(String noteId) {
    debugPrint('响应式版本管理器: 删除便签 $noteId');
    _integrationAdapter.deleteStickyNote(noteId);
  }

  /// 重新排序便签（响应式版本管理支持，通过集成适配器）
  void reorderStickyNotes(int oldIndex, int newIndex) {
    debugPrint('响应式版本管理器: 重新排序便签 $oldIndex -> $newIndex');
    _integrationAdapter.reorderStickyNotes(oldIndex, newIndex);
  }

  /// 根据拖拽重新排序便签（响应式版本管理支持，通过集成适配器）
  void reorderStickyNotesByDrag(List<StickyNote> reorderedNotes) {
    debugPrint('响应式版本管理器: 拖拽重新排序便签，数量: ${reorderedNotes.length}');
    _integrationAdapter.reorderStickyNotesByDrag(reorderedNotes);
  }

  /// 根据ID获取便签（响应式版本管理支持，通过集成适配器）
  StickyNote? getStickyNoteById(String noteId) {
    return _integrationAdapter.getStickyNoteById(noteId);
  }

  /// 获取所有便签（响应式版本管理支持，通过集成适配器）
  List<StickyNote> getStickyNotes() {
    return _integrationAdapter.getStickyNotes();
  }

  // ==================== 图例组操作支持 ====================

  /// 添加图例组（响应式版本管理支持，通过集成适配器）
  void addLegendGroup(LegendGroup legendGroup) {
    debugPrint('响应式版本管理器: 添加图例组 ${legendGroup.name}');
    _integrationAdapter.addLegendGroup(legendGroup);
  }

  /// 更新图例组（响应式版本管理支持，通过集成适配器）
  void updateLegendGroup(LegendGroup legendGroup) {
    debugPrint('响应式版本管理器: 更新图例组 ${legendGroup.name}');
    _integrationAdapter.updateLegendGroup(legendGroup);
  }

  /// 删除图例组（响应式版本管理支持，通过集成适配器）
  void deleteLegendGroup(String legendGroupId) {
    debugPrint('响应式版本管理器: 删除图例组 $legendGroupId');
    _integrationAdapter.deleteLegendGroup(legendGroupId);
  }

  /// 设置图例组可见性（响应式版本管理支持，通过集成适配器）
  void setLegendGroupVisibility(String groupId, bool isVisible) {
    debugPrint('响应式版本管理器: 设置图例组可见性 $groupId = $isVisible');
    _integrationAdapter.setLegendGroupVisibility(groupId, isVisible);
  }

  /// 根据ID获取图例组（响应式版本管理支持，通过集成适配器）
  LegendGroup? getLegendGroupById(String groupId) {
    return _integrationAdapter.getLegendGroupById(groupId);
  }

  /// 获取所有图例组（响应式版本管理支持，通过集成适配器）
  List<LegendGroup> getLegendGroups() {
    return _integrationAdapter.getLegendGroups();
  }

  // ==================== 状态查询支持 ====================

  /// 根据ID获取图层（响应式版本管理支持，通过集成适配器）
  MapLayer? getLayerById(String layerId) {
    return _integrationAdapter.getLayerById(layerId);
  }

  /// 获取所有图层（响应式版本管理支持，通过集成适配器）
  List<MapLayer> getLayers() {
    return _integrationAdapter.getLayers();
  }

  // ==================== 资源管理 ====================

  /// 获取适配器状态信息
  Map<String, dynamic> getAdapterStatus() {
    return {
      'isUpdating': _isUpdating,
      'hasMapDataSubscription': _mapDataSubscription != null,
      'currentMapDataState': _integrationAdapter.currentState.runtimeType
          .toString(),
      'versionManagerInfo': _versionManager.getDebugInfo(),
      'legendSessionInfo': {
        'loadedLegendsCount':
            _legendSessionManager.sessionData.loadedLegends.length,
        'loadingStatesCount':
            _legendSessionManager.sessionData.loadingStates.length,
        'failedPathsCount':
            _legendSessionManager.sessionData.failedPaths.length,
      },
    };
  }

  /// 诊断图例会话管理器状态
  Map<String, dynamic> diagnoseLegendSessionManager() {
    final sessionData = _legendSessionManager.sessionData;
    final stats = sessionData.getStats();

    return {
      'session_manager_initialized': true,
      'loaded_legends_count': stats['loaded'] ?? 0,
      'loading_legends_count': stats['loading'] ?? 0,
      'failed_legends_count': stats['failed'] ?? 0,
      'total_legends_count': stats['total'] ?? 0,
      'loaded_legend_paths': sessionData.loadedLegends.keys.toList(),
      'failed_legend_paths': sessionData.failedPaths.toList(),
      'loading_states': sessionData.loadingStates.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
    };
  }

  /// 释放资源
  void dispose() {
    _mapDataSubscription?.cancel();
    _mapDataSubscription = null;
    _versionManager.removeListener(_onVersionManagerChanged);
    _legendSessionManager.dispose();

    debugPrint('响应式版本管理适配器已释放资源');
  }
}

/// 响应式版本管理混入
/// 为页面或组件提供版本管理功能
mixin ReactiveVersionMixin<T extends StatefulWidget> on State<T> {
  ReactiveVersionAdapter? _versionAdapter;

  /// 获取版本适配器
  ReactiveVersionAdapter? get versionAdapter => _versionAdapter;

  /// 初始化版本管理（重构后通过集成适配器）
  void initializeVersionManagement({
    required String mapTitle,
    required MapEditorIntegrationAdapter integrationAdapter,
    String? folderPath,
  }) {
    final versionManager = ReactiveVersionManager(
      mapTitle: mapTitle,
      folderPath: folderPath,
    );
    _versionAdapter = ReactiveVersionAdapter(
      versionManager: versionManager,
      integrationAdapter: integrationAdapter,
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
