import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/map_item.dart';
import '../models/map_layer.dart';
import '../services/vfs_map_storage/vfs_map_service.dart';
import '../services/vfs_map_storage/vfs_map_service_factory.dart';
import 'map_data_bloc.dart';
import 'map_data_state.dart';
import 'reactive_script_manager.dart';
import 'map_editor_integration_adapter.dart';

/// 地图编辑器响应式系统集成
/// 为现有地图编辑器提供完整的响应式数据管理支持
class MapEditorReactiveIntegration {
  late final MapDataBloc _mapDataBloc;
  late final ReactiveScriptManager _scriptManager;
  late final MapEditorIntegrationAdapter _adapter;
  late final VfsMapService _mapService;

  bool _isInitialized = false;

  /// 获取地图数据Bloc
  MapDataBloc get mapDataBloc => _mapDataBloc;

  /// 获取脚本管理器
  ReactiveScriptManager get scriptManager => _scriptManager;

  /// 获取集成适配器
  MapEditorIntegrationAdapter get adapter => _adapter;

  /// 初始化响应式系统
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('初始化地图编辑器响应式系统');    // 1. 创建VFS地图服务
    _mapService = VfsMapServiceFactory.createVfsMapService();

    // 2. 创建地图数据Bloc
    _mapDataBloc = MapDataBloc(mapService: _mapService);

    // 3. 创建响应式脚本管理器
    _scriptManager = ReactiveScriptManager(mapDataBloc: _mapDataBloc);

    // 4. 创建集成适配器
    _adapter = MapEditorIntegrationAdapter(
      mapDataBloc: _mapDataBloc,
      scriptManager: _scriptManager,
      mapService: _mapService,
    );

    // 5. 初始化脚本管理器
    await _scriptManager.initialize();

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
    debugPrint('释放地图编辑器响应式系统资源');
    
    _adapter.dispose();
    _scriptManager.dispose();
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

  /// 更新图层（响应式）
  void updateLayerReactive(MapLayer layer) {
    reactiveIntegration.adapter.updateLayer(layer);
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

  /// 更新绘制元素（响应式）
  void updateDrawingElementReactive(String layerId, MapDrawingElement element) {
    reactiveIntegration.adapter.updateDrawingElement(layerId, element);
  }

  /// 删除绘制元素（响应式）
  void deleteDrawingElementReactive(String layerId, String elementId) {
    reactiveIntegration.adapter.deleteDrawingElement(layerId, elementId);
  }

  /// 添加图例组（响应式）
  void addLegendGroupReactive(LegendGroup legendGroup) {
    reactiveIntegration.adapter.addLegendGroup(legendGroup);
  }

  /// 更新图例组（响应式）
  void updateLegendGroupReactive(LegendGroup legendGroup) {
    reactiveIntegration.adapter.updateLegendGroup(legendGroup);
  }

  /// 删除图例组（响应式）
  void deleteLegendGroupReactive(String legendGroupId) {
    reactiveIntegration.adapter.deleteLegendGroup(legendGroupId);
  }

  /// 获取响应式脚本管理器
  ReactiveScriptManager get reactiveScriptManager => reactiveIntegration.scriptManager;

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

  /// 释放响应式系统资源
  void disposeReactiveIntegration() {
    _reactiveIntegration?.dispose();
    _reactiveIntegration = null;
  }
}
