import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/script_data.dart';
import '../models/map_layer.dart';
import '../services/virtual_file_system/virtual_file_system.dart';
import '../services/scripting/script_executor_base.dart';
import '../services/scripting/script_executor_factory.dart';
import '../services/scripting/external_function_handler.dart';
import 'map_data_bloc.dart';
import 'map_data_state.dart';

/// 重构后的响应式脚本引擎
/// 使用消息传递机制，支持异步隔离执行和并发脚本执行
/// 在Web平台上使用Web Worker，在桌面平台上使用Isolate
/// 支持真正的多任务并发执行，适用于长时间运行的脚本
class NewReactiveScriptEngine {
  final MapDataBloc _mapDataBloc;
  StreamSubscription<MapDataState>? _mapDataSubscription;
  bool _isListening = false;
  // 执行器池 - 支持并发执行多个脚本
  final Map<String, IScriptExecutor> _executorPool = {};
  final int _maxConcurrentExecutors;
  // 统一的外部函数处理器
  late final ExternalFunctionHandler _functionHandler;

  NewReactiveScriptEngine({
    required MapDataBloc mapDataBloc,
    int maxConcurrentExecutors = 5, // 默认最多支持5个并发脚本
  }) : _mapDataBloc = mapDataBloc,
       _maxConcurrentExecutors = maxConcurrentExecutors {
    _functionHandler = ExternalFunctionHandler(mapDataBloc: _mapDataBloc);
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
  }

  /// 设置 VFS 访问器
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
        // 如果执行失败，清理该脚本的执行器以避免状态污染
        _cleanupExecutor(script.id);
      }

      return result;
    } catch (e) {
      debugPrint('脚本执行异常: $e');
      // 发生异常时也清理执行器
      _cleanupExecutor(script.id);
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
      // 获取或创建专用的脚本执行器
      final executor = await _getOrCreateExecutor(script.id);

      // 使用专用执行器执行脚本
      final result = await executor.execute(
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

  /// 获取或创建脚本执行器
  Future<IScriptExecutor> _getOrCreateExecutor(String scriptId) async {
    // 如果已存在该脚本的执行器，直接返回
    if (_executorPool.containsKey(scriptId)) {
      return _executorPool[scriptId]!;
    }

    // 检查是否达到最大并发数
    if (_executorPool.length >= _maxConcurrentExecutors) {
      throw Exception('达到最大并发脚本数限制 ($_maxConcurrentExecutors)');
    }

    // 创建新的执行器（根据平台和需求选择合适的类型）
    final executor = _createAppropriateExecutor();

    // 注册外部函数
    _registerExternalFunctions(executor);

    // 加入执行器池
    _executorPool[scriptId] = executor;

    debugPrint('为脚本 $scriptId 创建新的执行器 (当前池大小: ${_executorPool.length})');

    return executor;
  }

  /// 注册外部函数到指定执行器
  void _registerExternalFunctions(IScriptExecutor executor) {
    // 基础函数
    executor.registerExternalFunction('log', _functionHandler.handleLog);
    executor.registerExternalFunction('print', _functionHandler.handleLog);

    // 数学函数
    executor.registerExternalFunction('sin', _functionHandler.handleSin);
    executor.registerExternalFunction('cos', _functionHandler.handleCos);
    executor.registerExternalFunction('tan', _functionHandler.handleTan);
    executor.registerExternalFunction('sqrt', _functionHandler.handleSqrt);
    executor.registerExternalFunction('pow', _functionHandler.handlePow);
    executor.registerExternalFunction('abs', _functionHandler.handleAbs);
    executor.registerExternalFunction('random', _functionHandler.handleRandom);

    // 地图数据访问函数
    executor.registerExternalFunction(
      'getLayers',
      _functionHandler.handleGetLayers,
    );
    executor.registerExternalFunction(
      'getLayerById',
      _functionHandler.handleGetLayerById,
    );
    executor.registerExternalFunction(
      'getAllElements',
      _functionHandler.handleGetAllElements,
    );
    executor.registerExternalFunction(
      'countElements',
      _functionHandler.handleCountElements,
    );
    executor.registerExternalFunction(
      'calculateTotalArea',
      _functionHandler.handleCalculateTotalArea,
    );

    // 文件操作函数
    executor.registerExternalFunction(
      'readjson',
      _functionHandler.handleReadJson,
    );
    executor.registerExternalFunction(
      'writetext',
      _functionHandler.handleWriteText,
    );

    // 便签相关函数
    executor.registerExternalFunction(
      'getStickyNotes',
      _functionHandler.handleGetStickyNotes,
    );
    executor.registerExternalFunction(
      'getStickyNoteById',
      _functionHandler.handleGetStickyNoteById,
    );

    // 图例相关函数
    executor.registerExternalFunction(
      'getLegendGroups',
      _functionHandler.handleGetLegendGroups,
    );
    executor.registerExternalFunction(
      'getLegendGroupById',
      _functionHandler.handleGetLegendGroupById,
    );    // 语音合成函数
    executor.registerExternalFunction(
      'say',
      _functionHandler.handleSay,
    );
    executor.registerExternalFunction(
      'ttsStop',
      _functionHandler.handleTtsStop,
    );
    executor.registerExternalFunction(
      'ttsGetLanguages',
      _functionHandler.handleTtsGetLanguages,
    );
    executor.registerExternalFunction(
      'ttsGetVoices',
      _functionHandler.handleTtsGetVoices,
    );
    executor.registerExternalFunction(
      'ttsIsLanguageAvailable',
      _functionHandler.handleTtsIsLanguageAvailable,
    );
    executor.registerExternalFunction(
      'ttsGetSpeechRateRange',
      _functionHandler.handleTtsGetSpeechRateRange,
    );

    debugPrint('已注册所有外部函数到Isolate执行器');
  }

  /// 处理获取图层函数  /// 清空执行日志
  void clearExecutionLogs() {
    _functionHandler.clearExecutionLogs();
    debugPrint('清空脚本执行日志');
  }

  /// 重置脚本引擎
  void reset() {
    _clearDataAccessor();
    _functionHandler.clearExecutionLogs();
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
    debugPrint('初始化新响应式脚本引擎 (支持 $_maxConcurrentExecutors 个并发脚本)');
  }

  /// 清理指定脚本的执行器
  void _cleanupExecutor(String scriptId) {
    if (_executorPool.containsKey(scriptId)) {
      debugPrint('清理脚本执行器: $scriptId');
      _executorPool[scriptId]!.dispose();
      _executorPool.remove(scriptId);
    }
  }

  /// 释放资源
  void dispose() {
    debugPrint('释放新响应式脚本引擎资源');

    _isListening = false;
    _mapDataSubscription?.cancel();
    _mapDataSubscription = null;

    // 释放所有脚本执行器
    for (final entry in _executorPool.entries) {
      entry.value.dispose();
    }
    _executorPool.clear();

    // 从MapDataBloc中移除监听器
    _mapDataBloc.removeDataChangeListener(_onMapDataChanged); // 清空数据访问器
    _clearDataAccessor();
    _functionHandler.clearExecutionLogs();
  }

  /// 添加执行日志
  void addExecutionLog(String message) {
    _functionHandler.addExecutionLog(message);
  }

  /// 停止脚本执行
  void stopScript(String scriptId) {
    if (_executorPool.containsKey(scriptId)) {
      _executorPool[scriptId]!.stop();
      debugPrint('停止脚本: $scriptId');
      // 停止后清理执行器，确保下次执行时使用全新的状态
      _cleanupExecutor(scriptId);
    }
  }

  /// 获取脚本执行日志
  List<String> getExecutionLogs() {
    return _functionHandler.getExecutionLogs();
  }

  /// 获取执行器池统计信息
  Map<String, dynamic> getExecutorPoolStats() {
    final stats = {
      'activeExecutors': _executorPool.length,
      'maxConcurrentExecutors': _maxConcurrentExecutors,
      'platform': kIsWeb ? 'web' : 'desktop',
      'executorType': kIsWeb ? 'concurrentWebWorker' : 'concurrent',
      'executorIds': _executorPool.keys.toList(),
    };

    // 如果是Squadron并发Web Worker执行器，添加基本统计信息
    if (kIsWeb) {
      for (final entry in _executorPool.entries) {
        final executor = entry.value;
        // 简单检查Squadron执行器
        final executorTypeName = executor.runtimeType.toString();
        if (executorTypeName.contains('Squadron')) {
          stats['concurrency_${entry.key}'] = {
            'executorType': 'concurrentWebWorker',
            'status': 'active',
            'platform': 'web',
          };
        }
      }
    }

    return stats;
  }

  /// 根据平台和配置创建合适的脚本执行器
  IScriptExecutor _createAppropriateExecutor() {
    if (kIsWeb) {
      // Web平台总是使用Squadron并发Web Worker执行器以支持双向通信
      return ScriptExecutorFactory.create(
        type: ScriptExecutorType.concurrentWebWorker,
        workerPoolSize: 4, // Squadron Worker池大小
      );
    } else {
      // 非Web平台使用Isolate执行器
      return ScriptExecutorFactory.create(enableConcurrency: true);
    }
  }
}
