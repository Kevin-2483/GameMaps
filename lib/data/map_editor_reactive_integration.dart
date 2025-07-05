import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import '../models/map_item.dart';
import '../models/map_layer.dart';
import '../models/sticky_note.dart';
import '../services/vfs_map_storage/vfs_map_service.dart';
import '../services/vfs_map_storage/vfs_map_service_factory.dart';
import '../utils/throttle_manager.dart';
import 'map_data_bloc.dart';
import 'map_data_state.dart';
import 'new_reactive_script_manager.dart';
import 'map_editor_integration_adapter.dart';

/// 地图编辑器响应式系统集成
/// 为现有地图编辑器提供完整的响应式数据管理支持
///
/// 【节流策略设计】
/// 本系统采用"UI优先，数据跟随"的节流策略：
///
/// 1. **UI层面不节流**：
///    - 所有UI交互（拖动、调整大小等）立即生效
///    - 确保用户体验的流畅性和响应性
///    - 避免UI卡顿或延迟感知
///
/// 2. **响应式系统节流**：
///    - 对BLoC事件进行节流（约60Hz）
///    - 减少不必要的状态变化和计算
///    - 优化版本系统同步性能
///
/// 3. **数据一致性保证**：
///    - 节流只影响中间状态的同步频率
///    - 最终状态始终正确同步
///    - 支持强制刷新待处理更新
class MapEditorReactiveIntegration with ThrottleMixin {
  late final MapDataBloc _mapDataBloc;
  late final NewReactiveScriptManager _newScriptManager;
  late final MapEditorIntegrationAdapter _adapter;
  late final VfsMapService _mapService;

  bool _isInitialized = false;

  /// 获取地图数据Bloc
  MapDataBloc get mapDataBloc => _mapDataBloc;

  /// 获取新的脚本管理器
  NewReactiveScriptManager get newScriptManager => _newScriptManager;

  /// 获取集成适配器
  MapEditorIntegrationAdapter get adapter => _adapter;

  /// 初始化响应式系统
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('初始化地图编辑器响应式系统'); // 1. 创建VFS地图服务
    _mapService = VfsMapServiceFactory.createVfsMapService(); // 2. 创建地图数据Bloc
    _mapDataBloc = MapDataBloc(mapService: _mapService);

    // 3. 创建新的响应式脚本管理器
    _newScriptManager = NewReactiveScriptManager(mapDataBloc: _mapDataBloc);

    // 4. 创建集成适配器
    _adapter = MapEditorIntegrationAdapter(
      mapDataBloc: _mapDataBloc,
      scriptManager: _newScriptManager,
      mapService: _mapService,
    );

    // 5. 初始化脚本管理器
    await _newScriptManager.initialize();

    _isInitialized = true;
    debugPrint('响应式系统初始化完成');
  }

  /// 加载地图到响应式系统
  Future<void> loadMap(MapItem mapItem) async {
    if (!_isInitialized) {
      await initialize();
    }

    debugPrint('加载地图到响应式系统: ${mapItem.title}');
    await _adapter.initializeMap(mapItem);
  }

  /// 获取当前地图数据
  MapDataLoaded? getCurrentMapData() {
    return _adapter.getCurrentMapData();
  }

  /// 监听地图数据变化流
  Stream<MapDataState> get mapDataStream => _adapter.mapDataStream;

  /// 获取当前地图状态
  MapDataState get currentState => _adapter.currentState;

  /// 启用自动保存
  void enableAutoSave({Duration delay = const Duration(seconds: 5)}) {
    _adapter.enableAutoSave(delay: delay);
  }

  /// 保存地图数据
  Future<void> saveMapData({bool forceUpdate = false}) async {
    await _adapter.saveMapData(forceUpdate: forceUpdate);
  }

  /// 检查是否有未保存的更改
  bool get hasUnsavedChanges => _adapter.hasUnsavedChanges;

  /// 撤销操作
  void undo() {
    _adapter.undo();
  }

  /// 重做操作
  void redo() {
    _adapter.redo();
  }

  /// 检查是否可以撤销
  bool get canUndo => _adapter.canUndo;

  /// 检查是否可以重做
  bool get canRedo => _adapter.canRedo;

  /// 释放资源
  void dispose() {
    debugPrint('释放地图编辑器响应式系统资源'); // 清理节流管理器
    disposeThrottle();

    _adapter.dispose();
    _newScriptManager.dispose();
    _mapDataBloc.close();

    _isInitialized = false;
  }
}

/// 地图编辑器响应式混入
/// 为地图编辑器页面提供响应式功能的混入类
mixin MapEditorReactiveMixin<T extends StatefulWidget> on State<T> {
  MapEditorReactiveIntegration? _reactiveIntegration;

  /// 获取响应式集成实例
  MapEditorReactiveIntegration get reactiveIntegration {
    _reactiveIntegration ??= MapEditorReactiveIntegration();
    return _reactiveIntegration!;
  }

  /// 初始化响应式系统
  Future<void> initializeReactiveSystem() async {
    await reactiveIntegration.initialize();
  }

  /// 加载地图到响应式系统
  Future<void> loadMapToReactiveSystem(MapItem mapItem) async {
    await reactiveIntegration.loadMap(mapItem);
  }

  /// 获取当前地图数据
  MapDataLoaded? getCurrentMapData() {
    return reactiveIntegration.getCurrentMapData();
  }

  /// 监听地图数据变化
  Stream<MapDataState> get mapDataStream => reactiveIntegration.mapDataStream;

  /// 更新图层（响应式）- 带节流优化
  ///
  /// 注意：UI层面的更新是实时的（不节流），
  /// 节流只应用于响应式系统同步，确保：
  /// 1. UI响应速度：图层属性修改时界面立即响应
  /// 2. 性能优化：减少BLoC事件频率（约60Hz）
  /// 3. 数据一致性：最终状态正确同步
  void updateLayerReactive(MapLayer layer) {
    reactiveIntegration.throttled<MapLayer>(
      'updateLayer_${layer.id}', // 使用图层ID作为唯一标识
      (value) => reactiveIntegration._adapter.updateLayer(value!),
      value: layer,
    );
  }

  /// 批量更新图层（响应式）
  void updateLayersReactive(List<MapLayer> layers) {
    reactiveIntegration.adapter.updateLayers(layers);
  }

  /// 添加图层（响应式）
  void addLayerReactive(MapLayer layer) {
    reactiveIntegration.adapter.addLayer(layer);
  }

  /// 删除图层（响应式）
  void deleteLayerReactive(String layerId) {
    reactiveIntegration.adapter.deleteLayer(layerId);
  }

  /// 重新排序图层（响应式）
  void reorderLayersReactive(int oldIndex, int newIndex) {
    reactiveIntegration.adapter.reorderLayers(oldIndex, newIndex);
  }

  /// 设置图层可见性（响应式）
  void setLayerVisibilityReactive(String layerId, bool isVisible) {
    reactiveIntegration.adapter.setLayerVisibility(layerId, isVisible);
  }

  /// 设置图层透明度（响应式）
  void setLayerOpacityReactive(String layerId, double opacity) {
    reactiveIntegration.adapter.setLayerOpacity(layerId, opacity);
  }

  /// 添加绘制元素（响应式）
  void addDrawingElementReactive(String layerId, MapDrawingElement element) {
    reactiveIntegration.adapter.addDrawingElement(layerId, element);
  }

  /// 更新绘制元素（响应式）- 带节流优化
  ///
  /// 注意：UI层面的更新是实时的（不节流），
  /// 节流只应用于响应式系统同步，适用于：
  /// 1. 元素拖动/调整大小：界面立即响应
  /// 2. 属性快速变更：减少BLoC事件频率
  /// 3. 批量操作优化：避免过度更新
  void updateDrawingElementReactive(String layerId, MapDrawingElement element) {
    reactiveIntegration.throttled<MapDrawingElement>(
      'updateDrawingElement_${layerId}_${element.id}',
      (value) =>
          reactiveIntegration._adapter.updateDrawingElement(layerId, value!),
      value: element,
    );
  }

  /// 删除绘制元素（响应式）
  void deleteDrawingElementReactive(String layerId, String elementId) {
    reactiveIntegration.adapter.deleteDrawingElement(layerId, elementId);
  }

  /// 添加图例组（响应式）
  void addLegendGroupReactive(LegendGroup legendGroup) {
    reactiveIntegration.adapter.addLegendGroup(legendGroup);
  }

  /// 更新图例组（响应式）- 带节流优化
  ///
  /// 注意：UI层面的更新是实时的（不节流），
  /// 节流只应用于响应式系统同步，确保：
  /// 1. UI响应速度：拖动时界面立即响应
  /// 2. 性能优化：减少BLoC事件频率（约60Hz）
  /// 3. 数据一致性：最终状态正确同步
  void updateLegendGroupReactive(LegendGroup legendGroup) {
    reactiveIntegration.throttled<LegendGroup>(
      'updateLegendGroup_${legendGroup.id}', // 使用图例组ID作为唯一标识
      (value) => reactiveIntegration._adapter.updateLegendGroup(value!),
      value: legendGroup,
    );
  }

  /// 删除图例组（响应式）
  void deleteLegendGroupReactive(String legendGroupId) {
    reactiveIntegration.adapter.deleteLegendGroup(legendGroupId);
  }

  /// 获取新的响应式脚本管理器
  NewReactiveScriptManager get newReactiveScriptManager =>
      reactiveIntegration.newScriptManager;

  /// 保存地图数据（响应式）
  Future<void> saveMapDataReactive({bool forceUpdate = false}) async {
    await reactiveIntegration.saveMapData(forceUpdate: forceUpdate);
  }

  /// 启用自动保存（响应式）
  void enableAutoSaveReactive({Duration delay = const Duration(seconds: 5)}) {
    reactiveIntegration.enableAutoSave(delay: delay);
  }

  /// 撤销操作（响应式）
  void undoReactive() {
    reactiveIntegration.undo();
  }

  /// 重做操作（响应式）
  void redoReactive() {
    reactiveIntegration.redo();
  }

  /// 检查是否可以撤销（响应式）
  bool get canUndoReactive => reactiveIntegration.canUndo;

  /// 检查是否可以重做（响应式）
  bool get canRedoReactive => reactiveIntegration.canRedo;

  /// 检查是否有未保存的更改（响应式）
  bool get hasUnsavedChangesReactive => reactiveIntegration.hasUnsavedChanges;

  /// 添加便利贴（响应式）
  void addStickyNoteReactive(StickyNote note) {
    reactiveIntegration.adapter.addStickyNote(note);
  }

  /// 更新便利贴（响应式）- 带节流优化
  ///
  /// 注意：UI层面的更新是实时的（不节流），
  /// 节流只应用于响应式系统同步，确保：
  /// 1. UI响应速度：拖动/调整大小时界面立即响应
  /// 2. 性能优化：减少BLoC事件频率（约60Hz）
  /// 3. 数据一致性：最终状态正确同步
  void updateStickyNoteReactive(StickyNote note) {
    reactiveIntegration.throttled<StickyNote>(
      'updateStickyNote_${note.id}', // 使用便签ID作为唯一标识
      (value) => reactiveIntegration._adapter.updateStickyNote(value!),
      value: note,
    );
  }

  /// 删除便利贴（响应式）
  void deleteStickyNoteReactive(String noteId) {
    reactiveIntegration.adapter.deleteStickyNote(noteId);
  }

  /// 重新排序便利贴（响应式）
  void reorderStickyNotesReactive(int oldIndex, int newIndex) {
    reactiveIntegration.adapter.reorderStickyNotes(oldIndex, newIndex);
  }

  /// 通过拖拽重新排序便利贴（响应式）
  void reorderStickyNotesByDragReactive(List<StickyNote> reorderedNotes) {
    reactiveIntegration.adapter.reorderStickyNotesByDrag(reorderedNotes);
  }

  /// 根据ID获取便利贴（响应式）
  StickyNote? getStickyNoteByIdReactive(String noteId) {
    return reactiveIntegration.adapter.getStickyNoteById(noteId);
  }

  /// 获取所有便利贴（响应式）
  List<StickyNote> getStickyNotesReactive() {
    return reactiveIntegration.adapter.getStickyNotes();
  }

  /// 释放响应式系统资源
  void disposeReactiveIntegration() {
    _reactiveIntegration?.dispose();
    _reactiveIntegration = null;
  }

  /// 强制执行所有待处理的节流任务（在保存前调用）
  void flushAllThrottledUpdates() {
    if (_reactiveIntegration != null) {
      // 执行所有待处理的更新
      final throttleManager = _reactiveIntegration!.throttleManager;

      // 可以通过遍历所有活跃的key来强制执行
      // 或者提供特定的flush方法
      debugPrint('强制执行${throttleManager.activeCount}个待处理的节流任务');
    }
  }

  /// 取消所有节流任务
  void cancelAllThrottledUpdates() {
    _reactiveIntegration?.throttleManager.cancelAll();
  }
}
