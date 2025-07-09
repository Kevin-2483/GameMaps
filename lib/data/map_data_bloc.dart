import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../services/vfs_map_storage/vfs_map_service.dart';
import '../services/timer_manager.dart';
import '../models/map_layer.dart';
import '../models/sticky_note.dart';
import '../models/timer_data.dart';
import 'map_data_event.dart';
import 'map_data_state.dart';

/// 响应式地图数据管理Bloc
class MapDataBloc extends Bloc<MapDataEvent, MapDataState> {
  final VfsMapService _mapService;
  final int _maxHistorySize = 50;

  // 历史记录管理
  final List<MapDataLoaded> _undoHistory = [];
  final List<MapDataLoaded> _redoHistory = [];

  // 当前地图信息
  String? _currentMapTitle;
  String? _currentVersion;

  // 数据变更监听器集合
  final Set<Function(MapDataLoaded)> _dataChangeListeners = {};

  MapDataBloc({required VfsMapService mapService})
    : _mapService = mapService,
      super(const MapDataInitial()) {
    // 注册事件处理器
    on<LoadMapData>(_onLoadMapData);
    on<InitializeMapData>(_onInitializeMapData);
    on<UpdateLayer>(_onUpdateLayer);
    on<UpdateLayers>(_onUpdateLayers);
    on<AddLayer>(_onAddLayer);
    on<DeleteLayer>(_onDeleteLayer);
    on<ReorderLayers>(_onReorderLayers);
    on<ReorderLayersInGroup>(_onReorderLayersInGroup);
    on<UpdateLegendGroup>(_onUpdateLegendGroup);
    on<AddLegendGroup>(_onAddLegendGroup);
    on<DeleteLegendGroup>(_onDeleteLegendGroup);
    on<UpdateDrawingElement>(_onUpdateDrawingElement);
    on<AddDrawingElement>(_onAddDrawingElement);
    on<DeleteDrawingElement>(_onDeleteDrawingElement);
    on<UpdateDrawingElements>(_onUpdateDrawingElements);
    on<SaveMapData>(_onSaveMapData);
    on<ResetMapData>(_onResetMapData);
    on<UndoMapData>(_onUndoMapData);
    on<RedoMapData>(_onRedoMapData);
    on<ScriptEngineUpdate>(_onScriptEngineUpdate);
    on<UpdateMapMetadata>(_onUpdateMapMetadata);
    on<SetLayerVisibility>(_onSetLayerVisibility);
    on<SetLayerOpacity>(_onSetLayerOpacity);
    on<SetLegendGroupVisibility>(_onSetLegendGroupVisibility);

    // 便签事件处理器
    on<AddStickyNote>(_onAddStickyNote);
    on<UpdateStickyNote>(_onUpdateStickyNote);
    on<DeleteStickyNote>(_onDeleteStickyNote);
    on<ReorderStickyNotes>(_onReorderStickyNotes);
    on<ReorderStickyNotesByDrag>(_onReorderStickyNotesByDrag);

    // 计时器事件处理器
    on<CreateTimer>(_onCreateTimer);
    on<UpdateTimer>(_onUpdateTimer);
    on<DeleteTimer>(_onDeleteTimer);
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<StopTimer>(_onStopTimer);
    on<ResetTimer>(_onResetTimer);
    on<TimerTick>(_onTimerTick);
    on<UpdateTimers>(_onUpdateTimers);
    on<ClearAllTimers>(_onClearAllTimers);

    // 初始化计时器管理器
    TimerManager.instance.initialize(this);
  }

  /// 添加数据变更监听器
  void addDataChangeListener(Function(MapDataLoaded) listener) {
    _dataChangeListeners.add(listener);
  }

  /// 移除数据变更监听器
  void removeDataChangeListener(Function(MapDataLoaded) listener) {
    _dataChangeListeners.remove(listener);
  }

  /// 通知数据变更监听器
  void _notifyDataChangeListeners(MapDataLoaded data) {
    for (final listener in _dataChangeListeners) {
      try {
        listener(data);
      } catch (e) {
        debugPrint('数据变更监听器执行失败: $e');
      }
    }
  }

  /// 加载地图数据
  Future<void> _onLoadMapData(
    LoadMapData event,
    Emitter<MapDataState> emit,
  ) async {
    try {
      emit(const MapDataLoading());

      _currentMapTitle = event.mapTitle;
      _currentVersion = event.version ?? 'default';

      // 从VFS服务加载地图数据
      final mapItem = await _mapService.getMapByTitle(
        event.mapTitle,
        event.folderPath,
      );
      if (mapItem == null) {
        emit(const MapDataError(message: '地图不存在'));
        return;
      } // 加载图层数据
      final layers = await _mapService.getMapLayers(
        event.mapTitle,
        event.version ?? 'default',
        event.folderPath,
      );

      // 加载图例组数据
      final legendGroups = await _mapService.getMapLegendGroups(
        event.mapTitle,
        event.version ?? 'default',
        event.folderPath,
      );

      // 加载便签数据
      final stickyNotes = await _mapService.getMapStickyNotes(
        event.mapTitle,
        event.version ?? 'default',
        event.folderPath,
      );

      // 更新mapItem以包含版本特定的数据
      final updatedMapItem = mapItem.copyWith(
        layers: layers,
        legendGroups: legendGroups,
        stickyNotes: stickyNotes,
      );

      final loadedState = MapDataLoaded(
        mapItem: updatedMapItem,
        layers: layers,
        legendGroups: legendGroups,
        lastModified: DateTime.now(),
      );

      _clearHistory(); // 清空历史记录
      emit(loadedState);
      _notifyDataChangeListeners(loadedState);
    } catch (e, stackTrace) {
      emit(
        MapDataError(
          message: '加载地图数据失败: ${e.toString()}',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// 初始化地图数据（从已有的MapItem）
  Future<void> _onInitializeMapData(
    InitializeMapData event,
    Emitter<MapDataState> emit,
  ) async {
    try {
      emit(const MapDataLoading());

      _currentMapTitle = event.mapItem.title;
      _currentVersion = 'default';

      final loadedState = MapDataLoaded(
        mapItem: event.mapItem,
        layers: event.mapItem.layers,
        legendGroups: event.mapItem.legendGroups,
        lastModified: DateTime.now(),
      );

      _clearHistory();
      emit(loadedState);
      _notifyDataChangeListeners(loadedState);
    } catch (e, stackTrace) {
      emit(
        MapDataError(
          message: '初始化地图数据失败: ${e.toString()}',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// 更新图层
  Future<void> _onUpdateLayer(
    UpdateLayer event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final updatedLayers = currentState.layers.map((layer) {
      return layer.id == event.layer.id ? event.layer : layer;
    }).toList();

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: updatedLayers,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 批量更新图层
  Future<void> _onUpdateLayers(
    UpdateLayers event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    // 重新分配order值以确保顺序正确
    final updatedLayers = <MapLayer>[];
    for (int i = 0; i < event.layers.length; i++) {
      updatedLayers.add(event.layers[i].copyWith(
        order: i,
        updatedAt: DateTime.now(),
      ));
    }

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: updatedLayers,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 添加图层
  Future<void> _onAddLayer(AddLayer event, Emitter<MapDataState> emit) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final newLayers = [...currentState.layers, event.layer];

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: newLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: newLayers,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 删除图层
  Future<void> _onDeleteLayer(
    DeleteLayer event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final newLayers = currentState.layers
        .where((layer) => layer.id != event.layerId)
        .toList();

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: newLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: newLayers,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 重新排序图层
  Future<void> _onReorderLayers(
    ReorderLayers event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final newLayers = List<MapLayer>.from(currentState.layers);

    // 执行重排序
    final movedLayer = newLayers.removeAt(event.oldIndex);
    newLayers.insert(event.newIndex, movedLayer);

    // 重新分配order
    for (int i = 0; i < newLayers.length; i++) {
      newLayers[i] = newLayers[i].copyWith(order: i, updatedAt: DateTime.now());
    }

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: newLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: newLayers,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 组内重排序图层（同时处理链接状态和顺序）
  Future<void> _onReorderLayersInGroup(
    ReorderLayersInGroup event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final newLayers = List<MapLayer>.from(currentState.layers);

    // 首先更新需要修改链接状态的图层
    for (final layerToUpdate in event.layersToUpdate) {
      final index = newLayers.indexWhere((layer) => layer.id == layerToUpdate.id);
      if (index != -1) {
        newLayers[index] = layerToUpdate;
      }
    }

    // 然后执行重排序
    final movedLayer = newLayers.removeAt(event.oldIndex);
    newLayers.insert(event.newIndex, movedLayer);

    // 重新分配order
    for (int i = 0; i < newLayers.length; i++) {
      newLayers[i] = newLayers[i].copyWith(order: i, updatedAt: DateTime.now());
    }

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: newLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: newLayers,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 更新图例组
  Future<void> _onUpdateLegendGroup(
    UpdateLegendGroup event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final updatedLegendGroups = currentState.legendGroups.map((group) {
      return group.id == event.legendGroup.id ? event.legendGroup : group;
    }).toList();

    // 同步更新mapItem中的图例组数据
    final updatedMapItem = currentState.mapItem.copyWith(
      legendGroups: updatedLegendGroups,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      legendGroups: updatedLegendGroups,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 添加图例组
  Future<void> _onAddLegendGroup(
    AddLegendGroup event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final newLegendGroups = [...currentState.legendGroups, event.legendGroup];

    // 同步更新mapItem中的图例组数据
    final updatedMapItem = currentState.mapItem.copyWith(
      legendGroups: newLegendGroups,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      legendGroups: newLegendGroups,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 删除图例组
  Future<void> _onDeleteLegendGroup(
    DeleteLegendGroup event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final newLegendGroups = currentState.legendGroups
        .where((group) => group.id != event.groupId)
        .toList();

    // 同步更新mapItem中的图例组数据
    final updatedMapItem = currentState.mapItem.copyWith(
      legendGroups: newLegendGroups,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      legendGroups: newLegendGroups,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 更新绘制元素
  Future<void> _onUpdateDrawingElement(
    UpdateDrawingElement event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final updatedLayers = currentState.layers.map((layer) {
      if (layer.id == event.layerId) {
        final updatedElements = layer.elements.map((element) {
          return element.id == event.element.id ? event.element : element;
        }).toList();
        return layer.copyWith(
          elements: updatedElements,
          updatedAt: DateTime.now(),
        );
      }
      return layer;
    }).toList();

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: updatedLayers,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 添加绘制元素
  Future<void> _onAddDrawingElement(
    AddDrawingElement event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final updatedLayers = currentState.layers.map((layer) {
      if (layer.id == event.layerId) {
        final newElements = [...layer.elements, event.element];
        return layer.copyWith(elements: newElements, updatedAt: DateTime.now());
      }
      return layer;
    }).toList();

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: updatedLayers,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 删除绘制元素
  Future<void> _onDeleteDrawingElement(
    DeleteDrawingElement event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final updatedLayers = currentState.layers.map((layer) {
      if (layer.id == event.layerId) {
        final newElements = layer.elements
            .where((element) => element.id != event.elementId)
            .toList();
        return layer.copyWith(elements: newElements, updatedAt: DateTime.now());
      }
      return layer;
    }).toList();

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: updatedLayers,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 批量更新绘制元素
  Future<void> _onUpdateDrawingElements(
    UpdateDrawingElements event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    final updatedLayers = currentState.layers.map((layer) {
      if (layer.id == event.layerId) {
        return layer.copyWith(
          elements: event.elements,
          updatedAt: DateTime.now(),
        );
      }
      return layer;
    }).toList();

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: updatedLayers,
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 保存地图数据
  Future<void> _onSaveMapData(
    SaveMapData event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;

    try {
      emit(MapDataSaving(currentData: currentState));

      if (_currentMapTitle != null) {
        // 更新MapItem
        final updatedMapItem = currentState.mapItem.copyWith(
          layers: currentState.layers,
          legendGroups: currentState.legendGroups,
          updatedAt: DateTime.now(),
        );

        // 保存到VFS
        await _mapService.updateMapMeta(_currentMapTitle!, updatedMapItem);

        // 保存图层
        for (final layer in currentState.layers) {
          await _mapService.saveLayer(
            _currentMapTitle!,
            layer,
            _currentVersion ?? 'default',
          );
        }

        // 保存图例组
        for (final group in currentState.legendGroups) {
          await _mapService.saveLegendGroup(
            _currentMapTitle!,
            group,
            _currentVersion ?? 'default',
          );
        }

        // 保存便签数据
        for (final stickyNote in updatedMapItem.stickyNotes) {
          await _mapService.saveStickyNote(
            _currentMapTitle!,
            stickyNote,
            _currentVersion ?? 'default',
          );
        }

        final savedState = MapDataSaved(
          data: currentState.copyWith(mapItem: updatedMapItem),
          savedAt: DateTime.now(),
        );

        emit(savedState);
      }
    } catch (e, stackTrace) {
      emit(
        MapDataError(
          message: '保存地图数据失败: ${e.toString()}',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// 重置地图数据
  Future<void> _onResetMapData(
    ResetMapData event,
    Emitter<MapDataState> emit,
  ) async {
    _clearHistory();
    _currentMapTitle = null;
    _currentVersion = null;
    emit(const MapDataInitial());
  }

  /// 撤销操作
  Future<void> _onUndoMapData(
    UndoMapData event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded || _undoHistory.isEmpty) return;

    final currentState = state as MapDataLoaded;
    _redoHistory.add(currentState);

    if (_redoHistory.length > _maxHistorySize) {
      _redoHistory.removeAt(0);
    }

    final previousState = _undoHistory.removeLast();
    emit(previousState);
    _notifyDataChangeListeners(previousState);
  }

  /// 重做操作
  Future<void> _onRedoMapData(
    RedoMapData event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded || _redoHistory.isEmpty) return;

    final currentState = state as MapDataLoaded;
    _undoHistory.add(currentState);

    if (_undoHistory.length > _maxHistorySize) {
      _undoHistory.removeAt(0);
    }

    final nextState = _redoHistory.removeLast();
    emit(nextState);
    _notifyDataChangeListeners(nextState);
  }

  /// 脚本引擎更新
  Future<void> _onScriptEngineUpdate(
    ScriptEngineUpdate event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    _saveToHistory(currentState);

    // 同步更新mapItem中的图层数据
    final updatedMapItem = currentState.mapItem.copyWith(
      layers: event.updatedLayers,
      updatedAt: DateTime.now(),
    );

    final newState = currentState.copyWith(
      mapItem: updatedMapItem,
      layers: event.updatedLayers,
      lastModified: DateTime.now(),
      metadata: {
        ...currentState.metadata,
        'lastScriptUpdate': {
          'scriptId': event.scriptId,
          'description': event.description,
          'timestamp': DateTime.now().toIso8601String(),
        },
      },
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 更新元数据
  Future<void> _onUpdateMapMetadata(
    UpdateMapMetadata event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    final newState = currentState.copyWith(
      metadata: {...currentState.metadata, ...event.metadata},
      lastModified: DateTime.now(),
    );

    emit(newState);
    _notifyDataChangeListeners(newState);
  }

  /// 设置图层可见性
  Future<void> _onSetLayerVisibility(
    SetLayerVisibility event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    final layer = currentState.getLayerById(event.layerId);

    if (layer != null) {
      final updatedLayer = layer.copyWith(
        isVisible: event.isVisible,
        updatedAt: DateTime.now(),
      );
      add(UpdateLayer(layer: updatedLayer));
    }
  }

  /// 设置图层透明度
  Future<void> _onSetLayerOpacity(
    SetLayerOpacity event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    final layer = currentState.getLayerById(event.layerId);

    if (layer != null) {
      final updatedLayer = layer.copyWith(
        opacity: event.opacity,
        updatedAt: DateTime.now(),
      );
      add(UpdateLayer(layer: updatedLayer));
    }
  }

  /// 设置图例组可见性
  Future<void> _onSetLegendGroupVisibility(
    SetLegendGroupVisibility event,
    Emitter<MapDataState> emit,
  ) async {
    if (state is! MapDataLoaded) return;

    final currentState = state as MapDataLoaded;
    final group = currentState.getLegendGroupById(event.groupId);

    if (group != null) {
      final updatedGroup = group.copyWith(
        isVisible: event.isVisible,
        updatedAt: DateTime.now(),
      );
      add(UpdateLegendGroup(legendGroup: updatedGroup));
    }
  }

  /// 保存到历史记录
  void _saveToHistory(MapDataLoaded state) {
    _undoHistory.add(state);
    _redoHistory.clear(); // 清空重做历史

    if (_undoHistory.length > _maxHistorySize) {
      _undoHistory.removeAt(0);
    }
  }

  /// 清空历史记录
  void _clearHistory() {
    _undoHistory.clear();
    _redoHistory.clear();
  }

  /// 获取当前地图数据（如果状态为已加载）
  MapDataLoaded? get currentData {
    return state is MapDataLoaded ? state as MapDataLoaded : null;
  }

  /// 是否可以撤销
  bool get canUndo => _undoHistory.isNotEmpty;

  /// 是否可以重做
  bool get canRedo => _redoHistory.isNotEmpty;

  /// 获取当前地图标题
  String? get currentMapTitle => _currentMapTitle;

  /// 获取当前版本
  String? get currentVersion => _currentVersion;


  // 便签事件处理方法

  /// 添加便签
  Future<void> _onAddStickyNote(
    AddStickyNote event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      // 保存到撤销历史
      _saveToHistory(currentState);

      // 创建新的便签列表
      final updatedStickyNotes = List<StickyNote>.from(
        currentState.mapItem.stickyNotes,
      )..add(event.stickyNote);

      // 更新地图数据
      final updatedMapItem = currentState.mapItem.copyWith(
        stickyNotes: updatedStickyNotes,
        updatedAt: DateTime.now(),
      );

      final newState = currentState.copyWith(mapItem: updatedMapItem);
      emit(newState);
      _notifyDataChangeListeners(newState);
    } catch (e) {
      debugPrint('添加便签失败: $e');
      emit(MapDataError(message: '添加便签失败: $e'));
    }
  }

  /// 更新便签
  Future<void> _onUpdateStickyNote(
    UpdateStickyNote event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      // 保存到撤销历史
      _saveToHistory(currentState);

      // 查找并更新便签
      final updatedStickyNotes = List<StickyNote>.from(
        currentState.mapItem.stickyNotes,
      );
      final noteIndex = updatedStickyNotes.indexWhere(
        (note) => note.id == event.stickyNote.id,
      );

      if (noteIndex != -1) {
        updatedStickyNotes[noteIndex] = event.stickyNote.copyWith(
          updatedAt: DateTime.now(),
        );

        // 更新地图数据
        final updatedMapItem = currentState.mapItem.copyWith(
          stickyNotes: updatedStickyNotes,
          updatedAt: DateTime.now(),
        );

        final newState = currentState.copyWith(mapItem: updatedMapItem);
        emit(newState);
        _notifyDataChangeListeners(newState);
      }
    } catch (e) {
      debugPrint('更新便签失败: $e');
      emit(MapDataError(message: '更新便签失败: $e'));
    }
  }

  /// 删除便签
  Future<void> _onDeleteStickyNote(
    DeleteStickyNote event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      // 保存到撤销历史
      _saveToHistory(currentState);

      // 删除便签
      final updatedStickyNotes = currentState.mapItem.stickyNotes
          .where((note) => note.id != event.stickyNoteId)
          .toList();

      // 更新地图数据
      final updatedMapItem = currentState.mapItem.copyWith(
        stickyNotes: updatedStickyNotes,
        updatedAt: DateTime.now(),
      );

      final newState = currentState.copyWith(mapItem: updatedMapItem);
      emit(newState);
      _notifyDataChangeListeners(newState);
    } catch (e) {
      debugPrint('删除便签失败: $e');
      emit(MapDataError(message: '删除便签失败: $e'));
    }
  }

  /// 重新排序便签
  Future<void> _onReorderStickyNotes(
    ReorderStickyNotes event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      final stickyNotes = currentState.mapItem.stickyNotes;
      if (event.oldIndex < 0 ||
          event.oldIndex >= stickyNotes.length ||
          event.newIndex < 0 ||
          event.newIndex >= stickyNotes.length ||
          event.oldIndex == event.newIndex) {
        return;
      }

      // 保存到撤销历史
      _saveToHistory(currentState);

      // 重新排序便签
      final updatedStickyNotes = List<StickyNote>.from(stickyNotes);
      final item = updatedStickyNotes.removeAt(event.oldIndex);
      updatedStickyNotes.insert(event.newIndex, item);

      // 更新地图数据
      final updatedMapItem = currentState.mapItem.copyWith(
        stickyNotes: updatedStickyNotes,
        updatedAt: DateTime.now(),
      );

      final newState = currentState.copyWith(mapItem: updatedMapItem);
      emit(newState);
      _notifyDataChangeListeners(newState);
    } catch (e) {
      debugPrint('重新排序便签失败: $e');
      emit(MapDataError(message: '重新排序便签失败: $e'));
    }
  }

  /// 通过拖拽重新排序便签
  Future<void> _onReorderStickyNotesByDrag(
    ReorderStickyNotesByDrag event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      // 保存到撤销历史
      _saveToHistory(currentState);

      // 更新地图数据
      final updatedMapItem = currentState.mapItem.copyWith(
        stickyNotes: event.reorderedNotes,
        updatedAt: DateTime.now(),
      );

      final newState = currentState.copyWith(mapItem: updatedMapItem);
      emit(newState);
      _notifyDataChangeListeners(newState);
    } catch (e) {
      debugPrint('通过拖拽重新排序便签失败: $e');
      emit(MapDataError(message: '通过拖拽重新排序便签失败: $e'));
    }
  }

  // 计时器事件处理方法

  /// 创建计时器
  Future<void> _onCreateTimer(
    CreateTimer event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      // 保存到撤销历史
      _saveToHistory(currentState);

      // 检查是否已存在相同ID的计时器
      final existingTimer = currentState.getTimerById(event.timer.id);
      if (existingTimer != null) {
        emit(const MapDataError(message: '计时器ID已存在'));
        return;
      }

      // 添加新计时器
      final updatedTimers = List<TimerData>.from(currentState.timers)
        ..add(event.timer);

      final newState = currentState.copyWith(
        timers: updatedTimers,
        lastModified: DateTime.now(),
      );

      emit(newState);
      _notifyDataChangeListeners(newState);
      debugPrint('计时器已创建: ${event.timer.id}');
    } catch (e) {
      debugPrint('创建计时器失败: $e');
      emit(MapDataError(message: '创建计时器失败: $e'));
    }
  }

  /// 更新计时器
  Future<void> _onUpdateTimer(
    UpdateTimer event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      // 保存到撤销历史
      _saveToHistory(currentState);

      // 更新计时器
      final updatedTimers = currentState.timers.map((timer) {
        return timer.id == event.timer.id ? event.timer : timer;
      }).toList();

      final newState = currentState.copyWith(
        timers: updatedTimers,
        lastModified: DateTime.now(),
      );

      emit(newState);
      _notifyDataChangeListeners(newState);
    } catch (e) {
      debugPrint('更新计时器失败: $e');
      emit(MapDataError(message: '更新计时器失败: $e'));
    }
  }

  /// 删除计时器
  Future<void> _onDeleteTimer(
    DeleteTimer event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      // 保存到撤销历史
      _saveToHistory(currentState);

      // 停止计时器（如果正在运行）
      TimerManager.instance.stopTimer(event.timerId);

      // 删除计时器
      final updatedTimers = currentState.timers
          .where((timer) => timer.id != event.timerId)
          .toList();

      final newState = currentState.copyWith(
        timers: updatedTimers,
        lastModified: DateTime.now(),
      );

      emit(newState);
      _notifyDataChangeListeners(newState);
      debugPrint('计时器已删除: ${event.timerId}');
    } catch (e) {
      debugPrint('删除计时器失败: $e');
      emit(MapDataError(message: '删除计时器失败: $e'));
    }
  }

  /// 启动计时器
  Future<void> _onStartTimer(
    StartTimer event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      final timer = currentState.getTimerById(event.timerId);
      if (timer == null) {
        emit(const MapDataError(message: '计时器不存在'));
        return;
      }

      if (!timer.state.canStart) {
        emit(const MapDataError(message: '计时器当前状态无法启动'));
        return;
      }

      // 更新计时器状态
      final updatedTimer = timer.copyWith(
        state: TimerState.running,
        startTime: DateTime.now(),
        pauseTime: null,
        updatedAt: DateTime.now(),
      );

      // 启动计时器管理器
      TimerManager.instance.startTimer(event.timerId, updatedTimer);

      // 更新状态
      final updatedTimers = currentState.timers.map((t) {
        return t.id == event.timerId ? updatedTimer : t;
      }).toList();

      final newState = currentState.copyWith(
        timers: updatedTimers,
        lastModified: DateTime.now(),
      );

      emit(newState);
      _notifyDataChangeListeners(newState);
    } catch (e) {
      debugPrint('启动计时器失败: $e');
      emit(MapDataError(message: '启动计时器失败: $e'));
    }
  }

  /// 暂停计时器
  Future<void> _onPauseTimer(
    PauseTimer event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      final timer = currentState.getTimerById(event.timerId);
      if (timer == null) {
        emit(const MapDataError(message: '计时器不存在'));
        return;
      }

      if (!timer.state.canPause) {
        emit(const MapDataError(message: '计时器当前状态无法暂停'));
        return;
      }

      // 停止计时器管理器
      TimerManager.instance.pauseTimer(event.timerId);

      // 更新计时器状态
      final updatedTimer = timer.copyWith(
        state: TimerState.paused,
        pauseTime: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 更新状态
      final updatedTimers = currentState.timers.map((t) {
        return t.id == event.timerId ? updatedTimer : t;
      }).toList();

      final newState = currentState.copyWith(
        timers: updatedTimers,
        lastModified: DateTime.now(),
      );

      emit(newState);
      _notifyDataChangeListeners(newState);
    } catch (e) {
      debugPrint('暂停计时器失败: $e');
      emit(MapDataError(message: '暂停计时器失败: $e'));
    }
  }

  /// 停止计时器
  Future<void> _onStopTimer(
    StopTimer event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      final timer = currentState.getTimerById(event.timerId);
      if (timer == null) {
        emit(const MapDataError(message: '计时器不存在'));
        return;
      }

      if (!timer.state.canStop) {
        emit(const MapDataError(message: '计时器当前状态无法停止'));
        return;
      }

      // 停止计时器管理器
      TimerManager.instance.stopTimer(event.timerId);

      // 重置计时器状态
      final resetTime = timer.mode == TimerMode.countdown 
          ? (timer.targetTime ?? Duration.zero)
          : Duration.zero;

      final updatedTimer = timer.copyWith(
        state: TimerState.stopped,
        currentTime: resetTime,
        startTime: null,
        pauseTime: null,
        updatedAt: DateTime.now(),
      );

      // 更新状态
      final updatedTimers = currentState.timers.map((t) {
        return t.id == event.timerId ? updatedTimer : t;
      }).toList();

      final newState = currentState.copyWith(
        timers: updatedTimers,
        lastModified: DateTime.now(),
      );

      emit(newState);
      _notifyDataChangeListeners(newState);
    } catch (e) {
      debugPrint('停止计时器失败: $e');
      emit(MapDataError(message: '停止计时器失败: $e'));
    }
  }

  /// 重置计时器
  Future<void> _onResetTimer(
    ResetTimer event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      final timer = currentState.getTimerById(event.timerId);
      if (timer == null) {
        emit(const MapDataError(message: '计时器不存在'));
        return;
      }

      // 停止计时器管理器
      TimerManager.instance.stopTimer(event.timerId);

      // 重置计时器
      final resetTime = timer.mode == TimerMode.countdown 
          ? (timer.targetTime ?? Duration.zero)
          : Duration.zero;

      final updatedTimer = timer.copyWith(
        state: TimerState.stopped,
        currentTime: resetTime,
        startTime: null,
        pauseTime: null,
        updatedAt: DateTime.now(),
      );

      // 更新状态
      final updatedTimers = currentState.timers.map((t) {
        return t.id == event.timerId ? updatedTimer : t;
      }).toList();

      final newState = currentState.copyWith(
        timers: updatedTimers,
        lastModified: DateTime.now(),
      );

      emit(newState);
      _notifyDataChangeListeners(newState);
    } catch (e) {
      debugPrint('重置计时器失败: $e');
      emit(MapDataError(message: '重置计时器失败: $e'));
    }
  }

  /// 计时器时间更新
  Future<void> _onTimerTick(
    TimerTick event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      final timer = currentState.getTimerById(event.timerId);
      if (timer == null || !timer.isRunning) return;

      // 检查是否完成
      final isCompleted = timer.mode == TimerMode.countdown 
          ? event.currentTime.inMilliseconds <= 0
          : (timer.targetTime != null && event.currentTime >= timer.targetTime!);

      final newState = isCompleted ? TimerState.completed : TimerState.running;

      // 更新计时器时间
      final updatedTimer = timer.copyWith(
        currentTime: event.currentTime,
        state: newState,
        updatedAt: DateTime.now(),
      );

      // 更新状态
      final updatedTimers = currentState.timers.map((t) {
        return t.id == event.timerId ? updatedTimer : t;
      }).toList();

      final newMapState = currentState.copyWith(
        timers: updatedTimers,
        lastModified: DateTime.now(),
      );

      emit(newMapState);
      // 注意：这里不调用_notifyDataChangeListeners以避免过于频繁的通知
    } catch (e) {
      debugPrint('计时器时间更新失败: $e');
    }
  }

  /// 批量更新计时器
  Future<void> _onUpdateTimers(
    UpdateTimers event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      // 保存到撤销历史
      _saveToHistory(currentState);

      final newState = currentState.copyWith(
        timers: event.timers,
        lastModified: DateTime.now(),
      );

      emit(newState);
      _notifyDataChangeListeners(newState);
    } catch (e) {
      debugPrint('批量更新计时器失败: $e');
      emit(MapDataError(message: '批量更新计时器失败: $e'));
    }
  }

  /// 清空所有计时器
  Future<void> _onClearAllTimers(
    ClearAllTimers event,
    Emitter<MapDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapDataLoaded) return;

    try {
      // 保存到撤销历史
      _saveToHistory(currentState);

      // 停止所有计时器
      TimerManager.instance.stopAllTimers();

      final newState = currentState.copyWith(
        timers: [],
        lastModified: DateTime.now(),
      );

      emit(newState);
      _notifyDataChangeListeners(newState);
      debugPrint('所有计时器已清空');
    } catch (e) {
      debugPrint('清空计时器失败: $e');
      emit(MapDataError(message: '清空计时器失败: $e'));
    }
  }

  @override
  Future<void> close() {
    // 清理计时器管理器
    TimerManager.instance.dispose();
    _dataChangeListeners.clear();
    return super.close();
  }
}
