// This file has been processed by AI for internationalization
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
import '../services/localization_service.dart';

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
  // 外部函数处理器池 - 每个脚本有独立的处理器实例
  final Map<String, ExternalFunctionHandler> _functionHandlerPool = {};
  final int _maxConcurrentExecutors;

  NewReactiveScriptEngine({
    required MapDataBloc mapDataBloc,
    int maxConcurrentExecutors = 5, // 默认最多支持5个并发脚本
  }) : _mapDataBloc = mapDataBloc,
       _maxConcurrentExecutors = maxConcurrentExecutors {
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
      LocalizationService.instance.current.scriptEngineDataUpdater(
        mapData.layers.length,
        mapData.mapItem.stickyNotes.length,
        mapData.legendGroups.length,
      ),
    );

    // 在新架构中，脚本通过消息传递直接访问最新数据
    // 不需要缓存数据，因为总是通过 _mapDataBloc.state 获取最新状态
  }

  /// 清空数据访问器
  void _clearDataAccessor() {
    debugPrint(
      LocalizationService.instance.current.clearScriptEngineDataAccessor_7281,
    );
    // 在新架构中不需要清空缓存字段
  }

  /// 设置 VFS 访问器
  void setVfsAccessor(VirtualFileSystem vfsService, String mapTitle) {
    // 在新架构中，VFS访问通过消息传递机制实现
    // 这里保留接口以便将来扩展文件操作外部函数
    debugPrint(
      LocalizationService.instance.current.setVfsAccessorWithMapTitle(mapTitle),
    );
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
      debugPrint(
        '${LocalizationService.instance.current.scriptExecutionResult_7421} ${result.success ? LocalizationService.instance.current.success_7422 : LocalizationService.instance.current.failure_7423}: ${script.name}',
      );
      if (!result.success) {
        debugPrint(
          LocalizationService.instance.current.scriptError_7284(
            result.error ?? '',
          ),
        );
        // 如果执行失败，清理该脚本的执行器以避免状态污染
        _cleanupExecutor(script.id);
      }

      return result;
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.scriptExecutionError_7284(e),
      );
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
      throw Exception(
        LocalizationService.instance.current.maxConcurrentScriptsReached(
          _maxConcurrentExecutors,
        ),
      );
    }

    // 为该脚本创建独立的外部函数处理器
    final functionHandler = ExternalFunctionHandler(
      mapDataBloc: _mapDataBloc,
      scriptId: scriptId,
    );
    _functionHandlerPool[scriptId] = functionHandler;

    // 创建新的执行器（根据平台和需求选择合适的类型）
    final executor = _createAppropriateExecutor();

    // 注册外部函数
    _registerExternalFunctions(executor, functionHandler);

    // 加入执行器池
    _executorPool[scriptId] = executor;

    debugPrint(
      LocalizationService.instance.current.scriptExecutorCreation_7281(
        scriptId,
        _executorPool.length,
      ),
    );

    return executor;
  }

  /// 注册外部函数到指定执行器
  void _registerExternalFunctions(
    IScriptExecutor executor,
    ExternalFunctionHandler functionHandler,
  ) {
    // 基础函数
    executor.registerExternalFunction('log', functionHandler.handleLog);

    // 数学函数
    executor.registerExternalFunction('sin', functionHandler.handleSin);
    executor.registerExternalFunction('cos', functionHandler.handleCos);
    executor.registerExternalFunction('tan', functionHandler.handleTan);
    executor.registerExternalFunction('sqrt', functionHandler.handleSqrt);
    executor.registerExternalFunction('pow', functionHandler.handlePow);
    executor.registerExternalFunction('abs', functionHandler.handleAbs);
    executor.registerExternalFunction('random', functionHandler.handleRandom);

    // 地图数据访问函数
    executor.registerExternalFunction(
      'getLayers',
      functionHandler.handleGetLayers,
    );
    executor.registerExternalFunction(
      'getLayerById',
      functionHandler.handleGetLayerById,
    );
    executor.registerExternalFunction(
      'getAllElements',
      functionHandler.handleGetAllElements,
    );
    executor.registerExternalFunction(
      'getElementsInLayer',
      functionHandler.handleGetElementsInLayer,
    );

    // 文本元素函数
    executor.registerExternalFunction(
      'createTextElement',
      functionHandler.handleCreateTextElement,
    );
    executor.registerExternalFunction(
      'updateTextContent',
      functionHandler.handleUpdateTextContent,
    );
    executor.registerExternalFunction(
      'updateTextSize',
      functionHandler.handleUpdateTextSize,
    );
    executor.registerExternalFunction(
      'getTextElements',
      functionHandler.handleGetTextElements,
    );
    executor.registerExternalFunction(
      'findTextElementsByContent',
      functionHandler.handleFindTextElementsByContent,
    );

    // 文件操作函数
    executor.registerExternalFunction(
      'readjson',
      functionHandler.handleReadJson,
    );
    executor.registerExternalFunction(
      'writetext',
      functionHandler.handleWriteText,
    );

    // 便签相关函数
    executor.registerExternalFunction(
      'getStickyNotes',
      functionHandler.handleGetStickyNotes,
    );
    executor.registerExternalFunction(
      'getStickyNoteById',
      functionHandler.handleGetStickyNoteById,
    );
    executor.registerExternalFunction(
      'getElementsInStickyNote',
      functionHandler.handleGetElementsInStickyNote,
    );
    executor.registerExternalFunction(
      'filterStickyNotesByTags',
      functionHandler.handleFilterStickyNotesByTags,
    );
    executor.registerExternalFunction(
      'filterStickyNoteElementsByTags',
      functionHandler.handleFilterStickyNoteElementsByTags,
    );

    // 图例相关函数
    executor.registerExternalFunction(
      'getLegendGroups',
      functionHandler.handleGetLegendGroups,
    );
    executor.registerExternalFunction(
      'getLegendGroupById',
      functionHandler.handleGetLegendGroupById,
    );
    executor.registerExternalFunction(
      'getLegendItems',
      functionHandler.handleGetLegendItems,
    );
    executor.registerExternalFunction(
      'getLegendItemById',
      functionHandler.handleGetLegendItemById,
    );
    executor.registerExternalFunction(
      'filterLegendGroupsByTags',
      functionHandler.handleFilterLegendGroupsByTags,
    );
    executor.registerExternalFunction(
      'filterLegendItemsByTags',
      functionHandler.handleFilterLegendItemsByTags,
    );

    // 标签筛选函数
    executor.registerExternalFunction(
      'filterElementsByTags',
      functionHandler.handleFilterElementsByTags,
    );
    executor.registerExternalFunction(
      'filterElementsInStickyNotesByTags',
      functionHandler.handleFilterElementsInStickyNotesByTags,
    );
    executor.registerExternalFunction(
      'filterLegendItemsInGroupByTags',
      functionHandler.handleFilterLegendItemsInGroupByTags,
    );

    // 元素操作函数
    executor.registerExternalFunction(
      'updateElementProperty',
      functionHandler.handleUpdateElementProperty,
    );
    executor.registerExternalFunction(
      'moveElement',
      functionHandler.handleMoveElement,
    );

    // 图例操作函数
    executor.registerExternalFunction(
      'updateLegendGroup',
      functionHandler.handleUpdateLegendGroup,
    );
    executor.registerExternalFunction(
      'updateLegendGroupVisibility',
      functionHandler.handleUpdateLegendGroupVisibility,
    );
    executor.registerExternalFunction(
      'updateLegendGroupOpacity',
      functionHandler.handleUpdateLegendGroupOpacity,
    );
    executor.registerExternalFunction(
      'updateLegendItem',
      functionHandler.handleUpdateLegendItem,
    );

    // 语音合成函数
    executor.registerExternalFunction('say', functionHandler.handleSay);
    executor.registerExternalFunction('ttsStop', functionHandler.handleTtsStop);
    executor.registerExternalFunction(
      'ttsGetLanguages',
      functionHandler.handleTtsGetLanguages,
    );
    executor.registerExternalFunction(
      'ttsGetVoices',
      functionHandler.handleTtsGetVoices,
    );
    executor.registerExternalFunction(
      'ttsIsLanguageAvailable',
      functionHandler.handleTtsIsLanguageAvailable,
    );
    executor.registerExternalFunction(
      'ttsGetSpeechRateRange',
      functionHandler.handleTtsGetSpeechRateRange,
    );

    debugPrint(
      LocalizationService
          .instance
          .current
          .externalFunctionsRegisteredToIsolateExecutor_7281,
    );
  }

  /// 处理获取图层函数  /// 清空执行日志
  void clearExecutionLogs() {
    for (final handler in _functionHandlerPool.values) {
      handler.clearExecutionLogs();
    }
    debugPrint(LocalizationService.instance.current.clearAllScriptLogs_7281);
  }

  /// 重置脚本引擎
  void reset() {
    _clearDataAccessor();
    for (final handler in _functionHandlerPool.values) {
      handler.clearExecutionLogs();
    }
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
    debugPrint(
      LocalizationService.instance.current.initializingScriptEngine(
        _maxConcurrentExecutors,
      ),
    );
  }

  /// 清理指定脚本的执行器
  void _cleanupExecutor(String scriptId) {
    if (_executorPool.containsKey(scriptId)) {
      debugPrint(
        LocalizationService.instance.current.scriptExecutorCleanup_7421(
          scriptId,
        ),
      );
      _executorPool[scriptId]!.dispose();
      _executorPool.remove(scriptId);
    }

    // 同时清理对应的函数处理器
    if (_functionHandlerPool.containsKey(scriptId)) {
      debugPrint('清理脚本函数处理器: $scriptId');
      _functionHandlerPool.remove(scriptId);
    }
  }

  /// 释放资源
  void dispose() {
    debugPrint(
      LocalizationService.instance.current.releaseScriptEngineResources_4821,
    );

    _isListening = false;
    _mapDataSubscription?.cancel();
    _mapDataSubscription = null;

    // 释放所有脚本执行器
    for (final entry in _executorPool.entries) {
      entry.value.dispose();
    }
    _executorPool.clear();

    // 清理所有函数处理器
    _functionHandlerPool.clear();

    // 从MapDataBloc中移除监听器
    _mapDataBloc.removeDataChangeListener(_onMapDataChanged); // 清空数据访问器
    _clearDataAccessor();
    for (final handler in _functionHandlerPool.values) {
      handler.clearExecutionLogs();
    }
  }

  /// 添加执行日志（添加到所有活跃的函数处理器）
  void addExecutionLog(String message) {
    for (final handler in _functionHandlerPool.values) {
      handler.addExecutionLog(message);
    }
  }

  /// 停止脚本执行
  void stopScript(String scriptId) {
    if (_executorPool.containsKey(scriptId)) {
      _executorPool[scriptId]!.stop();
      debugPrint(
        LocalizationService.instance.current.stopScript_7285(scriptId),
      );
      // 停止后清理执行器，确保下次执行时使用全新的状态
      _cleanupExecutor(scriptId);
    }
  }

  /// 获取脚本执行日志（合并所有函数处理器的日志）
  List<String> getExecutionLogs() {
    final allLogs = <String>[];
    for (final handler in _functionHandlerPool.values) {
      allLogs.addAll(handler.getExecutionLogs());
    }
    return allLogs;
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
