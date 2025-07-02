import 'package:flutter/foundation.dart';
import '../models/map_item.dart';
import '../models/map_layer.dart';
import '../models/sticky_note.dart';
import '../services/vfs_map_storage/vfs_map_service.dart';
import 'map_data_bloc.dart';
import 'map_data_event.dart';
import 'map_data_state.dart';
import 'new_reactive_script_manager.dart';

/// Timer类的导入（如果需要）
import 'dart:async';

/// 地图编辑器集成适配器
/// 提供统一的API接口，将传统的地图编辑器操作转换为响应式事件
class MapEditorIntegrationAdapter {
  final MapDataBloc _mapDataBloc;
  final NewReactiveScriptManager _scriptManager;
  final VfsMapService _mapService;

  MapEditorIntegrationAdapter({
    required MapDataBloc mapDataBloc,
    required NewReactiveScriptManager scriptManager,
    required VfsMapService mapService,
  }) : _mapDataBloc = mapDataBloc,
       _scriptManager = scriptManager,
       _mapService = mapService;

  /// 获取VFS地图服务实例
  VfsMapService get mapService => _mapService;

  /// 初始化地图数据
  Future<void> initializeMap(MapItem mapItem) async {
    debugPrint('初始化地图: ${mapItem.title}');
    _mapDataBloc.add(InitializeMapData(mapItem: mapItem));
  }

  /// 加载地图数据
  Future<void> loadMap(
    String mapTitle, {
    String version = 'default',
    String? folderPath,
  }) async {
    debugPrint('加载地图: $mapTitle, 版本: $version, 文件夹: $folderPath');
    _mapDataBloc.add(
      LoadMapData(mapTitle: mapTitle, version: version, folderPath: folderPath),
    );
  }

  /// 获取当前地图数据
  MapDataLoaded? getCurrentMapData() {
    return _mapDataBloc.currentData;
  }

  /// 监听地图数据变化
  Stream<MapDataState> get mapDataStream => _mapDataBloc.stream;

  /// 获取当前地图状态
  MapDataState get currentState => _mapDataBloc.state;

  // ==================== 图层操作 ====================

  /// 更新图层
  void updateLayer(MapLayer layer) {
    debugPrint('更新图层: ${layer.name}');
    _mapDataBloc.add(UpdateLayer(layer: layer));
  }

  /// 批量更新图层
  void updateLayers(List<MapLayer> layers) {
    debugPrint('批量更新图层，数量: ${layers.length}');
    _mapDataBloc.add(UpdateLayers(layers: layers));
  }

  /// 添加图层
  void addLayer(MapLayer layer) {
    debugPrint('添加图层: ${layer.name}');
    _mapDataBloc.add(AddLayer(layer: layer));
  }

  /// 删除图层
  void deleteLayer(String layerId) {
    debugPrint('删除图层: $layerId');
    _mapDataBloc.add(DeleteLayer(layerId: layerId));
  }

  /// 重新排序图层
  void reorderLayers(int oldIndex, int newIndex) {
    debugPrint('重新排序图层: $oldIndex -> $newIndex');
    _mapDataBloc.add(ReorderLayers(oldIndex: oldIndex, newIndex: newIndex));
  }

  /// 设置图层可见性
  void setLayerVisibility(String layerId, bool isVisible) {
    debugPrint('设置图层可见性: $layerId = $isVisible');
    _mapDataBloc.add(
      SetLayerVisibility(layerId: layerId, isVisible: isVisible),
    );
  }

  /// 设置图层透明度
  void setLayerOpacity(String layerId, double opacity) {
    debugPrint('设置图层透明度: $layerId = $opacity');
    _mapDataBloc.add(SetLayerOpacity(layerId: layerId, opacity: opacity));
  }

  /// 根据ID获取图层
  MapLayer? getLayerById(String layerId) {
    return _mapDataBloc.currentData?.getLayerById(layerId);
  }

  /// 获取所有图层
  List<MapLayer> getLayers() {
    return _mapDataBloc.currentData?.layers ?? [];
  }

  /// 获取可见图层
  List<MapLayer> getVisibleLayers() {
    return _mapDataBloc.currentData?.visibleLayers ?? [];
  }

  /// 获取按顺序排列的图层
  List<MapLayer> getSortedLayers() {
    return _mapDataBloc.currentData?.sortedLayers ?? [];
  }

  // ==================== 绘制元素操作 ====================

  /// 更新绘制元素
  void updateDrawingElement(String layerId, MapDrawingElement element) {
    debugPrint('更新绘制元素: $layerId/${element.id}');
    _mapDataBloc.add(UpdateDrawingElement(layerId: layerId, element: element));
  }

  /// 添加绘制元素
  void addDrawingElement(String layerId, MapDrawingElement element) {
    debugPrint('添加绘制元素: $layerId/${element.id}');
    _mapDataBloc.add(AddDrawingElement(layerId: layerId, element: element));
  }

  /// 删除绘制元素
  void deleteDrawingElement(String layerId, String elementId) {
    debugPrint('删除绘制元素: $layerId/$elementId');
    _mapDataBloc.add(
      DeleteDrawingElement(layerId: layerId, elementId: elementId),
    );
  }

  /// 批量更新绘制元素
  void updateDrawingElements(String layerId, List<MapDrawingElement> elements) {
    debugPrint('批量更新绘制元素: $layerId, 数量: ${elements.length}');
    _mapDataBloc.add(
      UpdateDrawingElements(layerId: layerId, elements: elements),
    );
  }

  // ==================== 图例组操作 ====================

  /// 更新图例组
  void updateLegendGroup(LegendGroup legendGroup) {
    debugPrint('更新图例组: ${legendGroup.name}');
    _mapDataBloc.add(UpdateLegendGroup(legendGroup: legendGroup));
  }

  /// 添加图例组
  void addLegendGroup(LegendGroup legendGroup) {
    debugPrint('添加图例组: ${legendGroup.name}');
    _mapDataBloc.add(AddLegendGroup(legendGroup: legendGroup));
  }

  /// 删除图例组
  void deleteLegendGroup(String groupId) {
    debugPrint('删除图例组: $groupId');
    _mapDataBloc.add(DeleteLegendGroup(groupId: groupId));
  }

  /// 设置图例组可见性
  void setLegendGroupVisibility(String groupId, bool isVisible) {
    debugPrint('设置图例组可见性: $groupId = $isVisible');
    _mapDataBloc.add(
      SetLegendGroupVisibility(groupId: groupId, isVisible: isVisible),
    );
  }

  /// 根据ID获取图例组
  LegendGroup? getLegendGroupById(String groupId) {
    return _mapDataBloc.currentData?.getLegendGroupById(groupId);
  }

  /// 获取所有图例组
  List<LegendGroup> getLegendGroups() {
    return _mapDataBloc.currentData?.legendGroups ?? [];
  }

  /// 获取可见图例组
  List<LegendGroup> getVisibleLegendGroups() {
    return _mapDataBloc.currentData?.visibleLegendGroups ?? [];
  }
  // ==================== 便利贴操作 ====================

  /// 更新便利贴
  void updateStickyNote(StickyNote note) {
    debugPrint('更新便利贴: ${note.id}');
    _mapDataBloc.add(UpdateStickyNote(stickyNote: note));
  }

  /// 添加便利贴
  void addStickyNote(StickyNote note) {
    debugPrint('添加便利贴: ${note.id}');
    _mapDataBloc.add(AddStickyNote(stickyNote: note));
  }

  /// 删除便利贴
  void deleteStickyNote(String noteId) {
    debugPrint('删除便利贴: $noteId');
    _mapDataBloc.add(DeleteStickyNote(stickyNoteId: noteId));
  }

  /// 重新排序便利贴
  void reorderStickyNotes(int oldIndex, int newIndex) {
    debugPrint('重新排序便利贴: $oldIndex -> $newIndex');
    _mapDataBloc.add(
      ReorderStickyNotes(oldIndex: oldIndex, newIndex: newIndex),
    );
  }

  /// 通过拖拽重新排序便利贴
  void reorderStickyNotesByDrag(List<StickyNote> reorderedNotes) {
    debugPrint('通过拖拽重新排序便利贴，数量: ${reorderedNotes.length}');
    _mapDataBloc.add(ReorderStickyNotesByDrag(reorderedNotes: reorderedNotes));
  }

  /// 根据ID获取便利贴
  StickyNote? getStickyNoteById(String noteId) {
    final stickyNotes = _mapDataBloc.currentData?.mapItem.stickyNotes ?? [];
    try {
      return stickyNotes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有便利贴
  List<StickyNote> getStickyNotes() {
    return _mapDataBloc.currentData?.mapItem.stickyNotes ?? [];
  }

  // ==================== 历史记录操作 ====================

  /// 撤销操作
  void undo() {
    if (_mapDataBloc.canUndo) {
      debugPrint('执行撤销操作');
      _mapDataBloc.add(const UndoMapData());
    }
  }

  /// 重做操作
  void redo() {
    if (_mapDataBloc.canRedo) {
      debugPrint('执行重做操作');
      _mapDataBloc.add(const RedoMapData());
    }
  }

  /// 检查是否可以撤销
  bool get canUndo => _mapDataBloc.canUndo;

  /// 检查是否可以重做
  bool get canRedo => _mapDataBloc.canRedo;

  // ==================== 保存操作 ====================

  /// 保存地图数据
  Future<void> saveMapData({bool forceUpdate = false}) async {
    debugPrint('保存地图数据，强制更新: $forceUpdate');
    _mapDataBloc.add(SaveMapData(forceUpdate: forceUpdate));
  }

  /// 自动保存（在数据变更后延迟保存）
  Timer? _autoSaveTimer;
  void enableAutoSave({Duration delay = const Duration(seconds: 5)}) {
    _mapDataBloc.stream.listen((state) {
      if (state is MapDataLoaded) {
        // 取消之前的自动保存计时器
        _autoSaveTimer?.cancel();

        // 设置新的自动保存计时器
        _autoSaveTimer = Timer(delay, () {
          if (_mapDataBloc.state is MapDataLoaded) {
            saveMapData();
          }
        });
      }
    });
  }

  // ==================== 脚本管理操作 ====================
  /// 获取脚本管理器
  NewReactiveScriptManager get scriptManager => _scriptManager;

  /// 重置脚本引擎（当地图数据发生重大变更时调用）
  Future<void> resetScriptEngine() async {
    debugPrint('重置脚本引擎');
    await _scriptManager.resetScriptEngine();
  }

  // ==================== 实用方法 ====================

  /// 检查是否有未保存的更改
  bool get hasUnsavedChanges {
    final state = _mapDataBloc.state;
    return state is MapDataLoaded && state != _mapDataBloc.state;
  }

  /// 获取当前地图标题
  String? get currentMapTitle => _mapDataBloc.currentMapTitle;

  /// 获取当前版本
  String? get currentVersion => _mapDataBloc.currentVersion;

  /// 获取最后修改时间
  DateTime? get lastModified => _mapDataBloc.currentData?.lastModified;

  /// 更新元数据
  void updateMetadata(Map<String, dynamic> metadata) {
    debugPrint('更新元数据: $metadata');
    _mapDataBloc.add(UpdateMapMetadata(metadata: metadata));
  }

  /// 重置地图数据
  void resetMapData() {
    debugPrint('重置地图数据');
    _mapDataBloc.add(const ResetMapData());
  }

  /// 检查是否已加载地图数据
  bool get hasMapData => _mapDataBloc.state is MapDataLoaded;

  /// 检查是否正在加载
  bool get isLoading => _mapDataBloc.state is MapDataLoading;

  /// 检查是否正在保存
  bool get isSaving => _mapDataBloc.state is MapDataSaving;

  /// 检查是否有错误
  bool get hasError => _mapDataBloc.state is MapDataError;

  /// 获取错误信息
  String? get errorMessage {
    final state = _mapDataBloc.state;
    return state is MapDataError ? state.message : null;
  }

  /// 释放资源
  void dispose() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    debugPrint('释放地图编辑器集成适配器资源');
  }
}
