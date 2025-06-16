import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/script_data.dart';
import '../models/map_layer.dart';
import '../models/sticky_note.dart';
import '../services/virtual_file_system/virtual_file_system.dart';
import '../services/scripting/isolated_script_executor.dart';
import 'map_data_bloc.dart';
import 'map_data_state.dart';

/// 重构后的响应式脚本引擎
/// 使用消息传递机制，支持异步隔离执行
class NewReactiveScriptEngine {
  final MapDataBloc _mapDataBloc;
  StreamSubscription<MapDataState>? _mapDataSubscription;
  bool _isListening = false;

  // 脚本执行器（根据平台选择）
  IsolatedScriptExecutor? _scriptExecutor;

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
    
    // 在新架构中，脚本通过消息传递直接访问最新数据
    // 不需要缓存数据，因为总是通过 _mapDataBloc.state 获取最新状态
  }

  /// 清空数据访问器
  void _clearDataAccessor() {
    debugPrint('清空脚本引擎数据访问器');
    // 在新架构中不需要清空缓存字段
  }  /// 设置 VFS 访问器
  void setVfsAccessor(VirtualFileSystem vfsService, String mapTitle) {
    // 在新架构中，VFS访问通过消息传递机制实现
    // 这里保留接口以便将来扩展文件操作外部函数
    debugPrint('设置VFS访问器，地图标题: $mapTitle');
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
        // 如果执行失败，重置执行器以避免状态污染
        _resetScriptExecutor();
      }

      return result;
    } catch (e) {
      debugPrint('脚本执行异常: $e');
      // 发生异常时也重置执行器
      _resetScriptExecutor();
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
      // 确保脚本执行器已初始化
      await _ensureScriptExecutorInitialized();

      // 使用真实的异步执行器执行脚本
      final result = await _scriptExecutor!.execute(
        script.content,
        timeout: const Duration(seconds: 30),
      );

      stopwatch.stop();
      return result;
    } catch (e) {
      stopwatch.stop();

      return ScriptExecutionResult(
        success: false,
        error: e.toString(),
        executionTime: stopwatch.elapsed,
      );
    }
  }
  /// 确保脚本执行器已初始化
  Future<void> _ensureScriptExecutorInitialized() async {
    if (_scriptExecutor != null) return;

    // 根据平台创建执行器
    if (kIsWeb) {
      // Web平台暂时使用占位符实现，避免编译错误
      _scriptExecutor = IsolateScriptExecutor(); // 这里将返回错误，但不会导致编译失败
    } else {
      _scriptExecutor = IsolateScriptExecutor();
    }

    // 注册外部函数
    _registerExternalFunctions();
  }
  /// 注册外部函数
  void _registerExternalFunctions() {
    if (_scriptExecutor == null) return;

    // 基础函数
    _scriptExecutor!.registerExternalFunction('log', _handleLog);
    _scriptExecutor!.registerExternalFunction('print', _handleLog);
    
    // 数学函数
    _scriptExecutor!.registerExternalFunction('sin', _handleSin);
    _scriptExecutor!.registerExternalFunction('cos', _handleCos);
    _scriptExecutor!.registerExternalFunction('tan', _handleTan);
    _scriptExecutor!.registerExternalFunction('sqrt', _handleSqrt);
    _scriptExecutor!.registerExternalFunction('pow', _handlePow);
    _scriptExecutor!.registerExternalFunction('abs', _handleAbs);
    _scriptExecutor!.registerExternalFunction('random', _handleRandom);
    
    // 地图数据访问函数
    _scriptExecutor!.registerExternalFunction('getLayers', _handleGetLayers);
    _scriptExecutor!.registerExternalFunction('getLayerById', _handleGetLayerById);
    _scriptExecutor!.registerExternalFunction('getAllElements', _handleGetAllElements);
    _scriptExecutor!.registerExternalFunction('countElements', _handleCountElements);
    _scriptExecutor!.registerExternalFunction('calculateTotalArea', _handleCalculateTotalArea);
    
    // 文件操作函数
    _scriptExecutor!.registerExternalFunction('readjson', _handleReadJson);
    _scriptExecutor!.registerExternalFunction('writetext', _handleWriteText);
    
    // 便签相关函数
    _scriptExecutor!.registerExternalFunction('getStickyNotes', _handleGetStickyNotes);
    _scriptExecutor!.registerExternalFunction('getStickyNoteById', _handleGetStickyNoteById);
    
    // 图例相关函数
    _scriptExecutor!.registerExternalFunction('getLegendGroups', _handleGetLegendGroups);
    _scriptExecutor!.registerExternalFunction('getLegendGroupById', _handleGetLegendGroupById);
    
    debugPrint('已注册所有外部函数到Isolate执行器');
  }

  /// 处理获取图层函数
  List<Map<String, dynamic>> _handleGetLayers() {
    return getCurrentLayers()
        .map((layer) => _layerToMap(layer))
        .toList();
  }  /// 处理日志函数
  dynamic _handleLog(dynamic message) {
    final logMessage = message?.toString() ?? '';
    addExecutionLog(logMessage);
    debugPrint('[Script Log] $logMessage');
    return logMessage;
  }

  /// 处理获取所有元素函数
  List<Map<String, dynamic>> _handleGetAllElements() {
    final layers = getCurrentLayers();
    final allElements = <Map<String, dynamic>>[];
    
    for (final layer in layers) {
      for (final element in layer.elements) {
        allElements.add(_elementToMap(element));
      }
    }
    
    return allElements;
  }

  /// 处理读取JSON函数
  Future<Map<String, dynamic>?> _handleReadJson(String path) async {
    // 这里应该通过VFS读取JSON文件
    debugPrint('读取JSON文件: $path');
    return null; // 暂时返回null
  }
  /// 处理写入文本函数
  Future<void> _handleWriteText(String path, String content) async {
    // 应该通过VFS写入文本文件
    debugPrint('写入文本文件: $path, 内容长度: ${content.length}');
  }

  // 数学函数处理器
  dynamic _handleSin(num x) {
    return math.sin(x.toDouble());
  }

  dynamic _handleCos(num x) {
    return math.cos(x.toDouble());
  }

  dynamic _handleTan(num x) {
    return math.tan(x.toDouble());
  }

  dynamic _handleSqrt(num x) {
    return math.sqrt(x.toDouble());
  }

  dynamic _handlePow(num x, num y) {
    return math.pow(x.toDouble(), y.toDouble());
  }

  dynamic _handleAbs(num x) {
    return x.abs();
  }

  dynamic _handleRandom() {
    return math.Random().nextDouble();
  }

  /// 处理根据ID获取图层
  Map<String, dynamic>? _handleGetLayerById(String layerId) {
    final layer = getLayerById(layerId);
    return layer != null ? _layerToMap(layer) : null;
  }

  /// 处理统计元素
  int _handleCountElements([String? type]) {
    final layers = getCurrentLayers();
    int count = 0;
    
    for (final layer in layers) {
      for (final element in layer.elements) {
        if (type == null || element.type.name == type) {
          count++;
        }
      }
    }
    
    return count;
  }

  /// 处理计算总面积
  double _handleCalculateTotalArea() {
    final layers = getCurrentLayers();
    double totalArea = 0.0;
    
    for (final layer in layers) {
      for (final element in layer.elements) {
        if (element.type == DrawingElementType.rectangle ||
            element.type == DrawingElementType.hollowRectangle) {
          if (element.points.length >= 2) {
            final width = (element.points[1].dx - element.points[0].dx).abs();
            final height = (element.points[1].dy - element.points[0].dy).abs();
            totalArea += width * height;
          }
        }
      }
    }
    
    return totalArea;
  }

  /// 处理获取便签
  List<Map<String, dynamic>> _handleGetStickyNotes() {
    // 这里应该从MapDataBloc获取便签数据
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      return state.mapItem.stickyNotes.map((note) => _stickyNoteToMap(note)).toList();
    }
    return [];
  }

  /// 处理根据ID获取便签
  Map<String, dynamic>? _handleGetStickyNoteById(String noteId) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      for (final note in state.mapItem.stickyNotes) {
        if (note.id == noteId) {
          return _stickyNoteToMap(note);
        }
      }
    }
    return null;
  }
  /// 处理获取图例组
  List<Map<String, dynamic>> _handleGetLegendGroups() {
    // 这里应该从MapDataBloc获取图例组数据
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      return state.legendGroups.map((group) => _legendGroupToMap(group)).toList();
    }
    return [];
  }

  /// 处理根据ID获取图例组
  Map<String, dynamic>? _handleGetLegendGroupById(String groupId) {
    if (_mapDataBloc.state is MapDataLoaded) {
      final state = _mapDataBloc.state as MapDataLoaded;
      for (final group in state.legendGroups) {
        if (group.id == groupId) {
          return _legendGroupToMap(group);
        }
      }
    }
    return null;
  }
  /// 便签转换为Map
  Map<String, dynamic> _stickyNoteToMap(StickyNote note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'position': {'x': note.position.dx, 'y': note.position.dy},
      'size': {'width': note.size.width, 'height': note.size.height},
      'backgroundColor': note.backgroundColor.value,
      'isVisible': note.isVisible,
      'isCollapsed': note.isCollapsed,
      'tags': note.tags ?? [],
    };
  }
  /// 图例组转换为Map  
  Map<String, dynamic> _legendGroupToMap(LegendGroup group) {
    return {
      'id': group.id,
      'name': group.name,
      'isVisible': group.isVisible,
      'opacity': group.opacity,
      'legendItems': group.legendItems.map((item) => _legendItemToMap(item)).toList(),
      'tags': group.tags ?? [],
    };
  }

  /// 图例项转换为Map
  Map<String, dynamic> _legendItemToMap(LegendItem item) {
    return {
      'id': item.id,
      'legendId': item.legendId,
      'position': {'x': item.position.dx, 'y': item.position.dy},
      'size': item.size,
      'rotation': item.rotation,
      'opacity': item.opacity,
      'isVisible': item.isVisible,
      'url': item.url,
      'tags': item.tags ?? [],
    };
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
    await _ensureScriptExecutorInitialized();
    debugPrint('初始化新响应式脚本引擎完成');
  }

  /// 重置脚本执行器
  void _resetScriptExecutor() {
    if (_scriptExecutor != null) {
      debugPrint('重置脚本执行器');
      _scriptExecutor!.dispose();
      _scriptExecutor = null;
    }
  }

  /// 释放资源
  void dispose() {
    debugPrint('释放新响应式脚本引擎资源');

    _isListening = false;
    _mapDataSubscription?.cancel();
    _mapDataSubscription = null;

    // 释放脚本执行器
    _scriptExecutor?.dispose();
    _scriptExecutor = null;

    // 从MapDataBloc中移除监听器
    _mapDataBloc.removeDataChangeListener(_onMapDataChanged);

    // 清空数据访问器
    _clearDataAccessor();    _executionLogs.clear();
  }

  /// 添加执行日志
  void addExecutionLog(String message) {
    _executionLogs.add(message);
    debugPrint('[Script] $message');
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
  /// 停止脚本执行
  void stopScript(String scriptId) {
    _scriptExecutor?.stop();
    debugPrint('停止脚本: $scriptId');
    // 停止后重置执行器，确保下次执行时使用全新的状态
    _resetScriptExecutor();
  }

  /// 获取脚本执行日志
  List<String> getExecutionLogs() {
    return List.from(_executionLogs);
  }
}
