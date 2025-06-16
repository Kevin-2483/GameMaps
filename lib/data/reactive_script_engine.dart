import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/script_engine.dart';
import '../models/script_data.dart';
import '../models/map_layer.dart';
import '../models/sticky_note.dart';
import 'map_data_bloc.dart';
import 'map_data_event.dart';
import 'map_data_state.dart';

/// 响应式脚本引擎适配器
/// 负责连接脚本引擎和地图数据管理系统，确保数据一致性
class ReactiveScriptEngine {
  final ScriptEngine _scriptEngine;
  final MapDataBloc _mapDataBloc;

  StreamSubscription<MapDataState>? _mapDataSubscription;
  bool _isListening = false;

  ReactiveScriptEngine({
    required ScriptEngine scriptEngine,
    required MapDataBloc mapDataBloc,
  }) : _scriptEngine = scriptEngine,
       _mapDataBloc = mapDataBloc {
    _initialize();
  }

  /// 初始化响应式连接
  void _initialize() {
    if (_isListening) return;

    _isListening = true;

    // 监听地图数据状态变化，实时更新脚本引擎的数据访问器
    _mapDataSubscription = _mapDataBloc.stream.listen(_onMapDataStateChanged);

    // 如果当前已有数据，立即更新脚本引擎
    if (_mapDataBloc.state is MapDataLoaded) {
      _updateScriptEngineDataAccessor(_mapDataBloc.state as MapDataLoaded);
    }

    // 添加数据变更监听器，确保脚本引擎始终获得最新数据
    _mapDataBloc.addDataChangeListener(_onMapDataChanged);
  }

  /// 处理地图数据状态变化
  void _onMapDataStateChanged(MapDataState state) {
    if (state is MapDataLoaded) {
      _updateScriptEngineDataAccessor(state);
    } else if (state is MapDataInitial || state is MapDataError) {
      // 清空脚本引擎的数据访问器
      _clearScriptEngineDataAccessor();
    }
  }

  /// 处理地图数据变更
  void _onMapDataChanged(MapDataLoaded data) {
    _updateScriptEngineDataAccessor(data);
  }  /// 更新脚本引擎的地图数据访问器
  void _updateScriptEngineDataAccessor(MapDataLoaded mapData) {
    debugPrint('更新脚本引擎数据访问器，图层数量: ${mapData.layers.length}，便签数量: ${mapData.mapItem.stickyNotes.length}，图例组数量: ${mapData.legendGroups.length}');

    _scriptEngine.setMapDataAccessor(
      mapData.layers,
      _onScriptEngineLayersChanged,
      mapData.mapItem.stickyNotes,
      _onScriptEngineStickyNotesChanged,
      mapData.legendGroups,
      _onScriptEngineLegendGroupsChanged,
    );
  }

  /// 清空脚本引擎的数据访问器
  void _clearScriptEngineDataAccessor() {
    debugPrint('清空脚本引擎数据访问器');
    _scriptEngine.setMapDataAccessor([], (_) {}, [], (_) {}, [], (_) {});
  }

  /// 处理脚本引擎修改图层数据的回调
  void _onScriptEngineLayersChanged(List<MapLayer> updatedLayers) {
    debugPrint('脚本引擎修改了图层数据，更新图层数量: ${updatedLayers.length}');

    // 通过Bloc事件更新地图数据，确保响应式流的一致性
    _mapDataBloc.add(
      ScriptEngineUpdate(
        updatedLayers: updatedLayers,
        scriptId: 'script_engine_update',
        description: '脚本引擎更新图层数据',
      ),
    );
  }

  /// 处理脚本引擎修改便签数据的回调
  void _onScriptEngineStickyNotesChanged(List<StickyNote> updatedStickyNotes) {
    debugPrint('脚本引擎修改了便签数据，更新便签数量: ${updatedStickyNotes.length}');

    // 目前暂时通过批量更新便签来处理
    // TODO: 考虑添加专门的脚本引擎便签更新事件
    for (final note in updatedStickyNotes) {
      _mapDataBloc.add(UpdateStickyNote(stickyNote: note));
    }
  }

  /// 处理脚本引擎修改图例组数据的回调
  void _onScriptEngineLegendGroupsChanged(List<LegendGroup> updatedLegendGroups) {
    debugPrint('脚本引擎修改了图例组数据，更新图例组数量: ${updatedLegendGroups.length}');

    // 通过Bloc事件更新地图数据，确保响应式流的一致性
    for (final group in updatedLegendGroups) {
      _mapDataBloc.add(UpdateLegendGroup(legendGroup: group));
    }
  }

  /// 执行脚本
  Future<ScriptExecutionResult> executeScript(ScriptData script) async {
    try {
      // 确保脚本引擎有最新的地图数据
      if (_mapDataBloc.state is MapDataLoaded) {
        _updateScriptEngineDataAccessor(_mapDataBloc.state as MapDataLoaded);
      }

      // 执行脚本
      final result = await _scriptEngine.executeScript(script);

      debugPrint('脚本执行${result.success ? '成功' : '失败'}: ${script.name}');
      if (!result.success) {
        debugPrint('脚本错误: ${result.error}');
      }

      return result;
    } catch (e) {
      debugPrint('脚本执行异常: $e');
      return ScriptExecutionResult(
        success: false,
        error: e.toString(),
        executionTime: Duration.zero,
      );
    }
  }

  /// 停止脚本执行
  void stopScript(String scriptId) {
    _scriptEngine.stopScript(scriptId);
  }

  /// 获取脚本执行日志
  List<String> getExecutionLogs() {
    return _scriptEngine.getExecutionLogs();
  }

  /// 清空执行日志
  void clearExecutionLogs() {
    // ScriptEngine内部会在每次执行脚本时自动清空日志
    debugPrint('清空脚本执行日志');
  }

  /// 重置脚本引擎
  void reset() {
    _scriptEngine.reset();
    _clearScriptEngineDataAccessor();
  }

  /// 获取当前地图图层数据（用于脚本访问）
  List<MapLayer> getCurrentLayers() {
    if (_mapDataBloc.state is MapDataLoaded) {
      return (_mapDataBloc.state as MapDataLoaded).layers;
    }
    return [];
  }

  /// 获取可见图层
  List<MapLayer> getVisibleLayers() {
    if (_mapDataBloc.state is MapDataLoaded) {
      return (_mapDataBloc.state as MapDataLoaded).visibleLayers;
    }
    return [];
  }

  /// 获取按顺序排列的图层
  List<MapLayer> getSortedLayers() {
    if (_mapDataBloc.state is MapDataLoaded) {
      return (_mapDataBloc.state as MapDataLoaded).sortedLayers;
    }
    return [];
  }

  /// 根据ID获取图层
  MapLayer? getLayerById(String layerId) {
    if (_mapDataBloc.state is MapDataLoaded) {
      return (_mapDataBloc.state as MapDataLoaded).getLayerById(layerId);
    }
    return null;
  }

  /// 检查是否有数据
  bool get hasData => _mapDataBloc.state is MapDataLoaded;

  /// 获取当前地图状态
  MapDataState get currentState => _mapDataBloc.state;

  /// 初始化脚本引擎
  Future<void> initializeScriptEngine() async {
    await _scriptEngine.initialize();
  }

  /// 获取脚本引擎实例
  ScriptEngine get scriptEngine => _scriptEngine;

  /// 释放资源
  void dispose() {
    debugPrint('释放响应式脚本引擎资源');

    _isListening = false;
    _mapDataSubscription?.cancel();
    _mapDataSubscription = null;

    // 从MapDataBloc中移除监听器
    _mapDataBloc.removeDataChangeListener(_onMapDataChanged);

    // 清空脚本引擎数据访问器
    _clearScriptEngineDataAccessor();
  }
}
