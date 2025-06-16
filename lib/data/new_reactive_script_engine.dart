import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/script_data.dart';
import '../models/map_layer.dart';
import '../models/sticky_note.dart';
import '../services/virtual_file_system/virtual_file_system.dart';
import 'map_data_bloc.dart';
import 'map_data_event.dart';
import 'map_data_state.dart';

/// 重构后的响应式脚本引擎
/// 使用消息传递机制，支持异步隔离执行
class NewReactiveScriptEngine {
  final MapDataBloc _mapDataBloc;
  StreamSubscription<MapDataState>? _mapDataSubscription;
  bool _isListening = false;

  // 地图数据访问器
  List<MapLayer>? _currentLayers;
  Function(List<MapLayer>)? _onLayersChanged;
  List<StickyNote>? _currentStickyNotes;
  Function(List<StickyNote>)? _onStickyNotesChanged;
  List<LegendGroup>? _currentLegendGroups;
  Function(List<LegendGroup>)? _onLegendGroupsChanged;

  // VFS 存储服务和地图信息
  VirtualFileSystem? _vfsStorageService;
  String? _currentMapTitle;

  // 消息监听器
  final List<String> _executionLogs = [];

  NewReactiveScriptEngine({required MapDataBloc mapDataBloc})
    : _mapDataBloc = mapDataBloc {
    _initialize();
  }

  /// 初始化响应式连接
  void _initialize() {
    if (_isListening) return;

    _isListening = true;

    // 监听地图数据状态变化，实时更新数据访问器
    _mapDataSubscription = _mapDataBloc.stream.listen(_onMapDataStateChanged);

    // 如果当前已有数据，立即更新数据访问器
    if (_mapDataBloc.state is MapDataLoaded) {
      _updateDataAccessor(_mapDataBloc.state as MapDataLoaded);
    }

    // 添加数据变更监听器，确保始终获得最新数据
    _mapDataBloc.addDataChangeListener(_onMapDataChanged);
  }

  /// 处理地图数据状态变化
  void _onMapDataStateChanged(MapDataState state) {
    if (state is MapDataLoaded) {
      _updateDataAccessor(state);
    } else if (state is MapDataInitial || state is MapDataError) {
      // 清空数据访问器
      _clearDataAccessor();
    }
  }

  /// 处理地图数据变更
  void _onMapDataChanged(MapDataLoaded data) {
    _updateDataAccessor(data);
  }

  /// 更新数据访问器
  void _updateDataAccessor(MapDataLoaded mapData) {
    debugPrint(
      '更新脚本引擎数据访问器，图层数量: ${mapData.layers.length}，便签数量: ${mapData.mapItem.stickyNotes.length}，图例组数量: ${mapData.legendGroups.length}',
    );

    _currentLayers = mapData.layers;
    _onLayersChanged = (layers) => _handleLayersChanged(layers);
    _currentStickyNotes = mapData.mapItem.stickyNotes;
    _onStickyNotesChanged = (notes) => _handleStickyNotesChanged(notes);
    _currentLegendGroups = mapData.legendGroups;
    _onLegendGroupsChanged = (groups) => _handleLegendGroupsChanged(groups);
  }

  /// 清空数据访问器
  void _clearDataAccessor() {
    debugPrint('清空脚本引擎数据访问器');
    _currentLayers = null;
    _onLayersChanged = null;
    _currentStickyNotes = null;
    _onStickyNotesChanged = null;
    _currentLegendGroups = null;
    _onLegendGroupsChanged = null;
  }

  /// 设置 VFS 访问器
  void setVfsAccessor(VirtualFileSystem vfsService, String mapTitle) {
    _vfsStorageService = vfsService;
    _currentMapTitle = mapTitle;
  }

  /// 处理图层数据变更的回调
  void _handleLayersChanged(List<MapLayer> updatedLayers) {
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

  /// 处理便签数据变更的回调
  void _handleStickyNotesChanged(List<StickyNote> updatedStickyNotes) {
    debugPrint('脚本引擎修改了便签数据，更新便签数量: ${updatedStickyNotes.length}');

    // 目前暂时通过批量更新便签来处理
    for (final note in updatedStickyNotes) {
      _mapDataBloc.add(UpdateStickyNote(stickyNote: note));
    }
  }

  /// 处理图例组数据变更的回调
  void _handleLegendGroupsChanged(List<LegendGroup> updatedLegendGroups) {
    debugPrint('脚本引擎修改了图例组数据，更新图例组数量: ${updatedLegendGroups.length}');

    // 通过Bloc事件更新地图数据，确保响应式流的一致性
    for (final group in updatedLegendGroups) {
      _mapDataBloc.add(UpdateLegendGroup(legendGroup: group));
    }
  }

  /// 执行脚本（使用消息传递机制）
  Future<ScriptExecutionResult> executeScript(ScriptData script) async {
    try {
      // 确保有最新的地图数据
      if (_mapDataBloc.state is MapDataLoaded) {
        _updateDataAccessor(_mapDataBloc.state as MapDataLoaded);
      }

      // 使用消息传递机制执行脚本
      final result = await _executeScriptWithMessagePassing(script);

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

  /// 使用消息传递机制执行脚本
  Future<ScriptExecutionResult> _executeScriptWithMessagePassing(
    ScriptData script,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 创建消息处理器
      final messageHandler = _ScriptMessageHandler(this);

      // 模拟脚本执行（在实际实现中，这里会启动Worker/Isolate）
      final result = await messageHandler.executeScript(script);

      stopwatch.stop();

      return ScriptExecutionResult(
        success: true,
        result: result,
        executionTime: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();

      return ScriptExecutionResult(
        success: false,
        error: e.toString(),
        executionTime: stopwatch.elapsed,
      );
    }
  }

  /// 停止脚本执行
  void stopScript(String scriptId) {
    // 实际实现中会向Worker/Isolate发送停止消息
    debugPrint('停止脚本: $scriptId');
  }

  /// 获取脚本执行日志
  List<String> getExecutionLogs() {
    return List.from(_executionLogs);
  }

  /// 添加执行日志
  void addExecutionLog(String message) {
    _executionLogs.add(message);
    debugPrint('[Script] $message');
  }

  /// 清空执行日志
  void clearExecutionLogs() {
    _executionLogs.clear();
    debugPrint('清空脚本执行日志');
  }

  /// 重置脚本引擎
  void reset() {
    _clearDataAccessor();
    _executionLogs.clear();
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
    // 实际实现中会初始化Worker/Isolate
    debugPrint('初始化新响应式脚本引擎');
  }

  /// 释放资源
  void dispose() {
    debugPrint('释放新响应式脚本引擎资源');

    _isListening = false;
    _mapDataSubscription?.cancel();
    _mapDataSubscription = null;

    // 从MapDataBloc中移除监听器
    _mapDataBloc.removeDataChangeListener(_onMapDataChanged);

    // 清空数据访问器
    _clearDataAccessor();
    _executionLogs.clear();
  }
}

/// 脚本消息处理器
/// 负责处理脚本执行过程中的消息传递
class _ScriptMessageHandler {
  final NewReactiveScriptEngine _engine;

  _ScriptMessageHandler(this._engine);

  /// 执行脚本
  Future<dynamic> executeScript(ScriptData script) async {
    // 模拟消息传递的脚本执行
    // 在实际实现中，这里会：
    // 1. 将脚本代码发送给Worker/Isolate
    // 2. 监听执行结果消息
    // 3. 处理外部函数调用请求

    _engine.addExecutionLog('开始执行脚本: ${script.name}');

    try {
      // 模拟脚本执行逻辑
      final result = await _simulateScriptExecution(script);

      _engine.addExecutionLog('脚本执行完成: ${script.name}');

      return result;
    } catch (e) {
      _engine.addExecutionLog('脚本执行失败: ${script.name}, 错误: $e');
      rethrow;
    }
  }

  /// 模拟脚本执行
  Future<dynamic> _simulateScriptExecution(ScriptData script) async {
    // 这里是模拟实现，实际应该通过消息传递机制
    // 与Worker/Isolate中的脚本执行器进行通信

    // 延迟模拟异步执行
    await Future.delayed(const Duration(milliseconds: 100));

    // 模拟一些基本的脚本操作
    if (script.content.contains('getLayers')) {
      final layers = _engine.getCurrentLayers();
      _engine.addExecutionLog('获取到 ${layers.length} 个图层');
    }

    if (script.content.contains('log')) {
      _engine.addExecutionLog('脚本输出日志信息');
    }

    return 'Script executed successfully (simulated)';
  }

  /// 处理外部函数调用
  Future<dynamic> handleExternalFunctionCall(
    String functionName,
    List<dynamic> arguments,
  ) async {
    _engine.addExecutionLog('调用外部函数: $functionName');

    // 根据函数名执行相应的操作
    switch (functionName) {
      case 'getLayers':
        return _engine
            .getCurrentLayers()
            .map((layer) => _layerToMap(layer))
            .toList();

      case 'log':
      case 'print':
        final message = arguments.isNotEmpty
            ? arguments[0]?.toString() ?? ''
            : '';
        _engine.addExecutionLog(message);
        return message;

      // 其他外部函数的实现...
      default:
        throw Exception('Unknown external function: $functionName');
    }
  }

  /// 将图层转换为Map
  Map<String, dynamic> _layerToMap(MapLayer layer) {
    return {
      'id': layer.id,
      'name': layer.name,
      'isVisible': layer.isVisible,
      'opacity': layer.opacity,
      'elements': layer.elements.map((e) => _elementToMap(e)).toList(),
      'tags': layer.tags ?? [],
    };
  }

  /// 将绘图元素转换为Map
  Map<String, dynamic> _elementToMap(MapDrawingElement element) {
    return {
      'id': element.id,
      'type': element.type.name,
      'points': element.points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': element.color.value,
      'strokeWidth': element.strokeWidth,
      'text': element.text,
      'fontSize': element.fontSize,
      'tags': element.tags ?? [],
    };
  }
}
