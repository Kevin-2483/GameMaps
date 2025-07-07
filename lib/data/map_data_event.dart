import 'package:equatable/equatable.dart';
import '../models/map_layer.dart';
import '../models/map_item.dart';
import '../models/sticky_note.dart';

/// 地图数据事件基类
abstract class MapDataEvent extends Equatable {
  const MapDataEvent();

  @override
  List<Object?> get props => [];
}

/// 加载地图数据
class LoadMapData extends MapDataEvent {
  final String mapTitle;
  final String? version;
  final String? folderPath;

  const LoadMapData({
    required this.mapTitle,
    this.version = 'default',
    this.folderPath,
  });

  @override
  List<Object?> get props => [mapTitle, version, folderPath];
}

/// 初始化地图数据（从已有的MapItem）
class InitializeMapData extends MapDataEvent {
  final MapItem mapItem;

  const InitializeMapData({required this.mapItem});

  @override
  List<Object?> get props => [mapItem];
}

/// 更新图层
class UpdateLayer extends MapDataEvent {
  final MapLayer layer;

  const UpdateLayer({required this.layer});

  @override
  List<Object?> get props => [layer];
}

/// 批量更新图层
class UpdateLayers extends MapDataEvent {
  final List<MapLayer> layers;

  const UpdateLayers({required this.layers});

  @override
  List<Object?> get props => [layers];
}

/// 添加图层
class AddLayer extends MapDataEvent {
  final MapLayer layer;

  const AddLayer({required this.layer});

  @override
  List<Object?> get props => [layer];
}

/// 删除图层
class DeleteLayer extends MapDataEvent {
  final String layerId;

  const DeleteLayer({required this.layerId});

  @override
  List<Object?> get props => [layerId];
}

/// 重新排序图层
class ReorderLayers extends MapDataEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderLayers({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

/// 组内重排序图层（同时处理链接状态和顺序）
class ReorderLayersInGroup extends MapDataEvent {
  final int oldIndex;
  final int newIndex;
  final List<MapLayer> layersToUpdate; // 需要更新链接状态的图层

  const ReorderLayersInGroup({
    required this.oldIndex,
    required this.newIndex,
    required this.layersToUpdate,
  });

  @override
  List<Object?> get props => [oldIndex, newIndex, layersToUpdate];
}

/// 更新图例组
class UpdateLegendGroup extends MapDataEvent {
  final LegendGroup legendGroup;

  const UpdateLegendGroup({required this.legendGroup});

  @override
  List<Object?> get props => [legendGroup];
}

/// 添加图例组
class AddLegendGroup extends MapDataEvent {
  final LegendGroup legendGroup;

  const AddLegendGroup({required this.legendGroup});

  @override
  List<Object?> get props => [legendGroup];
}

/// 删除图例组
class DeleteLegendGroup extends MapDataEvent {
  final String groupId;

  const DeleteLegendGroup({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// 更新绘制元素
class UpdateDrawingElement extends MapDataEvent {
  final String layerId;
  final MapDrawingElement element;

  const UpdateDrawingElement({required this.layerId, required this.element});

  @override
  List<Object?> get props => [layerId, element];
}

/// 添加绘制元素
class AddDrawingElement extends MapDataEvent {
  final String layerId;
  final MapDrawingElement element;

  const AddDrawingElement({required this.layerId, required this.element});

  @override
  List<Object?> get props => [layerId, element];
}

/// 删除绘制元素
class DeleteDrawingElement extends MapDataEvent {
  final String layerId;
  final String elementId;

  const DeleteDrawingElement({required this.layerId, required this.elementId});

  @override
  List<Object?> get props => [layerId, elementId];
}

/// 批量更新绘制元素
class UpdateDrawingElements extends MapDataEvent {
  final String layerId;
  final List<MapDrawingElement> elements;

  const UpdateDrawingElements({required this.layerId, required this.elements});

  @override
  List<Object?> get props => [layerId, elements];
}

/// 保存地图数据
class SaveMapData extends MapDataEvent {
  final bool forceUpdate;

  const SaveMapData({this.forceUpdate = false});

  @override
  List<Object?> get props => [forceUpdate];
}

/// 重置地图数据
class ResetMapData extends MapDataEvent {
  const ResetMapData();
}

/// 撤销操作
class UndoMapData extends MapDataEvent {
  const UndoMapData();
}

/// 重做操作
class RedoMapData extends MapDataEvent {
  const RedoMapData();
}

/// 脚本引擎更新事件
class ScriptEngineUpdate extends MapDataEvent {
  final List<MapLayer> updatedLayers;
  final String scriptId;
  final String? description;

  const ScriptEngineUpdate({
    required this.updatedLayers,
    required this.scriptId,
    this.description,
  });

  @override
  List<Object?> get props => [updatedLayers, scriptId, description];
}

/// 更新元数据
class UpdateMapMetadata extends MapDataEvent {
  final Map<String, dynamic> metadata;

  const UpdateMapMetadata({required this.metadata});

  @override
  List<Object?> get props => [metadata];
}

/// 设置图层可见性
class SetLayerVisibility extends MapDataEvent {
  final String layerId;
  final bool isVisible;

  const SetLayerVisibility({required this.layerId, required this.isVisible});

  @override
  List<Object?> get props => [layerId, isVisible];
}

/// 设置图层透明度
class SetLayerOpacity extends MapDataEvent {
  final String layerId;
  final double opacity;

  const SetLayerOpacity({required this.layerId, required this.opacity});

  @override
  List<Object?> get props => [layerId, opacity];
}

/// 设置图例组可见性
class SetLegendGroupVisibility extends MapDataEvent {
  final String groupId;
  final bool isVisible;

  const SetLegendGroupVisibility({
    required this.groupId,
    required this.isVisible,
  });

  @override
  List<Object?> get props => [groupId, isVisible];
}

// 便签相关事件

/// 添加便签
class AddStickyNote extends MapDataEvent {
  final StickyNote stickyNote;

  const AddStickyNote({required this.stickyNote});

  @override
  List<Object?> get props => [stickyNote];
}

/// 更新便签
class UpdateStickyNote extends MapDataEvent {
  final StickyNote stickyNote;

  const UpdateStickyNote({required this.stickyNote});

  @override
  List<Object?> get props => [stickyNote];
}

/// 删除便签
class DeleteStickyNote extends MapDataEvent {
  final String stickyNoteId;

  const DeleteStickyNote({required this.stickyNoteId});

  @override
  List<Object?> get props => [stickyNoteId];
}

/// 重新排序便签
class ReorderStickyNotes extends MapDataEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderStickyNotes({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

/// 通过拖拽重新排序便签
class ReorderStickyNotesByDrag extends MapDataEvent {
  final List<StickyNote> reorderedNotes;

  const ReorderStickyNotesByDrag({required this.reorderedNotes});

  @override
  List<Object?> get props => [reorderedNotes];
}
