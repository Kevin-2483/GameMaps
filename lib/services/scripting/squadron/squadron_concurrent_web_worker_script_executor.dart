import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../script_executor_base.dart';
import '../external_function_registry.dart';
import '../../../models/script_data.dart';
import 'script_worker_service.dart';

/// 基于Squadron的并发Web Worker脚本执行器 - 简化版本
/// 使用JSON字符串简化类型转换问题
class SquadronConcurrentWebWorkerScriptExecutor implements IScriptExecutor {
  /// Worker池大小
  final int _workerPoolSize;

  /// Worker池
  final List<_SquadronWorkerInstance> _workerPool = [];
  /// 外部函数处理器
  final Map<String, Function> _externalFunctions = {};

  /// 执行日志
  final List<String> _executionLogs = [];

  /// 正在执行的任务映射
  final Map<String, _ExecutionTask> _activeTasks = {};
  /// 等待队列
  final List<_ExecutionTask> _taskQueue = [];

  /// 初始化状态
  bool _isInitialized = false;
  bool _isDisposed = false;

  /// 构造函数
  SquadronConcurrentWebWorkerScriptExecutor({int workerPoolSize = 4})
      : _workerPoolSize = workerPoolSize;

  /// 添加日志
  void _addLog(String message) {
    if (_isDisposed) return;

    final timestamp = DateTime.now();
    final logMessage = '[$timestamp] $message';
    _executionLogs.add(logMessage);

    if (kDebugMode) {
      debugPrint('[SquadronConcurrentWebWorkerScriptExecutor] $message');
    }
  }

  /// 初始化Worker池
  Future<void> _ensureInitialized() async {
    if (_isInitialized || _isDisposed) return;

    try {
      _addLog('Initializing Squadron concurrent web worker pool (size: $_workerPoolSize)...');

      // 创建Worker池
      for (int i = 0; i < _workerPoolSize; i++) {
        final workerInstance = await _createWorkerInstance(i);
        _workerPool.add(workerInstance);
        _addLog('Squadron Worker $i created successfully');
      }

      _isInitialized = true;
      _addLog('Squadron concurrent web worker pool initialized successfully');
    } catch (e) {
      _addLog('Failed to initialize Squadron concurrent web worker pool: $e');
      rethrow;
    }
  }  /// 创建Worker实例
  Future<_SquadronWorkerInstance> _createWorkerInstance(int workerId) async {
    // 创建Squadron Worker实例
    final worker = ScriptWorkerServiceWorker();
    
    // 启动Worker
    await worker.start();
    
    // 初始化Worker中的Hetu引擎
    final initialized = await worker.initialize();
    if (!initialized) {
      throw Exception('Failed to initialize Hetu engine in worker $workerId');
    }

    // 创建Worker实例
    final instance = _SquadronWorkerInstance(
      id: workerId,
      worker: worker,
    );

    // 监听Worker的外部函数调用
    _listenToWorkerExternalFunctionCalls(instance);

    _addLog('Squadron Worker $workerId initialized successfully');
    return instance;
  }

  /// 监听Worker的外部函数调用
  void _listenToWorkerExternalFunctionCalls(_SquadronWorkerInstance workerInstance) {
    // 监听外部函数调用流
    workerInstance.worker.getExternalFunctionCalls().listen(
      (callRequestJson) {
        _handleExternalFunctionCall(callRequestJson, workerInstance);
      },
      onError: (error) {
        _addLog('Worker ${workerInstance.id} external function call stream error: $error');
      },
    );
  }
  /// 处理外部函数调用
  Future<void> _handleExternalFunctionCall(String callRequestJson, _SquadronWorkerInstance workerInstance) async {
    try {
      _addLog('Received external function call JSON: $callRequestJson');
      
      final callRequest = jsonDecode(callRequestJson) as Map<String, dynamic>;
      final callId = callRequest['callId'] as String?;
      final functionName = callRequest['functionName'] as String?;
      final arguments = callRequest['arguments'] as dynamic;

      if (callId == null || functionName == null) {
        _addLog('Invalid external function call: missing callId or functionName');
        return;
      }

      _addLog('Handling external function call: $functionName from worker ${workerInstance.id}');
      _addLog('Raw arguments from JSON: $arguments (type: ${arguments.runtimeType})');
      
      // 更严格的参数类型处理
      List<dynamic> argsList;
      
      if (arguments == null) {
        argsList = [];
        _addLog('No arguments provided');
      } else if (arguments is List) {
        argsList = List<dynamic>.from(arguments);
        _addLog('Arguments is List with ${argsList.length} items: $argsList');
      } else {
        // 单个参数的情况 - 包装到列表中
        argsList = [arguments];
        _addLog('Single argument wrapped in List: $argsList');
      }
      
      _addLog('Final arguments list: $argsList (types: ${argsList.map((a) => a.runtimeType).toList()})');

      dynamic result;
      String? error;try {
        // 检查本地函数
        final localFunction = _externalFunctions[functionName];
        if (localFunction != null) {
          _addLog('Calling registered external function: $functionName');
          result = await _callFunction(localFunction, argsList);
        } else {
          // 调用默认的外部函数处理器
          _addLog('Calling default external function: $functionName');
          result = await _callDefaultExternalFunction(functionName, argsList);
        }
      } catch (e, stackTrace) {
        error = e.toString();
        _addLog('Error calling external function $functionName: $error');
        _addLog('Stack trace: $stackTrace');
      }

      // 发送响应回Worker
      final response = {
        'callId': callId,
        'result': result,
        'error': error,
      };

      await workerInstance.worker.handleExternalFunctionResponse(jsonEncode(response));
      
    } catch (e) {
      _addLog('Error handling external function call: $e');
    }
  }
  /// 调用默认外部函数
  Future<dynamic> _callDefaultExternalFunction(String functionName, List<dynamic> arguments) async {
    _addLog('Calling default external function: $functionName with args: $arguments (type: ${arguments.runtimeType})');
    
    // 这里可以实现默认的外部函数处理逻辑
    // 例如：数学函数、日志函数等
    switch (functionName) {
      case 'log':
      case 'print':
        final message = arguments.isNotEmpty ? arguments.first.toString() : '';
        _addLog('Script log: $message');
        return null;
        
      case 'sin':
        if (arguments.isNotEmpty && arguments.first is num) {
          return math.sin(arguments.first as num);
        }
        throw Exception('Invalid arguments for sin function');
        
      case 'cos':
        if (arguments.isNotEmpty && arguments.first is num) {
          return math.cos(arguments.first as num);
        }
        throw Exception('Invalid arguments for cos function');
        
      case 'sqrt':
        if (arguments.isNotEmpty && arguments.first is num) {
          return math.sqrt(arguments.first as num);
        }
        throw Exception('Invalid arguments for sqrt function');
        
      case 'random':
        return math.Random().nextDouble();
        
      default:
        throw Exception('Unknown external function: $functionName');
    }
  }
  /// 调用函数（处理同步和异步函数）
  Future<dynamic> _callFunction(Function function, List<dynamic> args) async {
    try {
      _addLog('Calling function with ${args.length} arguments: $args');
      _addLog('Arguments types: ${args.map((a) => a.runtimeType).toList()}');
      
      // 根据参数数量调用函数
      dynamic result;
      switch (args.length) {
        case 0:
          result = function();
          break;
        case 1:
          _addLog('Calling function with single argument: ${args[0]} (type: ${args[0].runtimeType})');
          result = function(args[0]);
          break;
        case 2:
          result = function(args[0], args[1]);
          break;
        case 3:
          result = function(args[0], args[1], args[2]);
          break;
        case 4:
          result = function(args[0], args[1], args[2], args[3]);
          break;
        case 5:
          result = function(args[0], args[1], args[2], args[3], args[4]);
          break;
        default:
          result = Function.apply(function, args);
          break;
      }

      // 如果是Future，等待结果
      if (result is Future) {
        return await result;
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ScriptExecutionResult> execute(
    String code, {
    Map<String, dynamic>? context,
    Duration? timeout,
  }) async {
    if (_isDisposed) {
      throw StateError('SquadronConcurrentWebWorkerScriptExecutor has been disposed');
    }

    await _ensureInitialized();

    // 生成唯一的执行ID
    final executionId = '${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';

    final task = _ExecutionTask(
      id: executionId,
      code: code,
      context: context ?? {},
      timeout: timeout,
      completer: Completer<ScriptExecutionResult>(),
    );

    _addLog('Created execution task: $executionId');

    // 尝试立即分配Worker
    final worker = _getAvailableWorker();
    if (worker != null) {
      _executeTask(task, worker);
    } else {
      // 添加到等待队列
      _taskQueue.add(task);
      _addLog('Task $executionId added to queue (queue size: ${_taskQueue.length})');
    }

    return task.completer.future;
  }

  /// 获取可用的Worker
  _SquadronWorkerInstance? _getAvailableWorker() {
    for (final worker in _workerPool) {
      if (!worker.isBusy) {
        return worker;
      }
    }
    return null;
  }

  /// 执行任务
  Future<void> _executeTask(_ExecutionTask task, _SquadronWorkerInstance workerInstance) async {
    _activeTasks[task.id] = task;
    workerInstance.isBusy = true;
    workerInstance.currentTaskId = task.id;

    _addLog('Executing task ${task.id} on Squadron worker ${workerInstance.id}');

    try {
      // 创建脚本执行请求JSON
      final requestJson = jsonEncode({
        'executionId': task.id,
        'code': task.code,
        'context': task.context,
        'externalFunctions': ExternalFunctionRegistry.getAllFunctionNames(),
      });

      Timer? timeoutTimer;

      // 设置超时
      if (task.timeout != null) {
        timeoutTimer = Timer(task.timeout!, () {
          if (!task.completer.isCompleted) {
            _addLog('Task ${task.id} timeout on Squadron worker ${workerInstance.id}');
            _completeTask(
              task.id,
              ScriptExecutionResult(
                success: false,
                error: 'Script execution timeout after ${task.timeout!.inSeconds} seconds',
                executionTime: task.timeout!,
              ),
            );
          }
        });
      }

      // 执行脚本并监听结果流
      await for (final responseJson in workerInstance.worker.executeScript(requestJson)) {
        try {
          final response = jsonDecode(responseJson) as Map<String, dynamic>;
          final responseType = response['type'] as String?;
          final responseExecutionId = response['executionId'] as String?;

          if (responseExecutionId == task.id) {
            switch (responseType) {
              case 'started':
                _addLog('Script started for task ${task.id}, cancelling timeout timer');
                timeoutTimer?.cancel();
                break;

              case 'result':
                if (!task.completer.isCompleted) {
                  final result = ScriptExecutionResult(
                    success: true,
                    result: response['result'],
                    executionTime: Duration(
                      milliseconds: response['executionTime'] as int? ?? 0,
                    ),
                  );
                  _completeTask(task.id, result);
                }
                break;

              case 'error':
                if (!task.completer.isCompleted) {
                  final result = ScriptExecutionResult(
                    success: false,
                    error: response['error'] as String? ?? 'Unknown error',
                    executionTime: Duration(
                      milliseconds: response['executionTime'] as int? ?? 0,
                    ),
                  );
                  _completeTask(task.id, result);
                }
                break;

              default:
                _addLog('Received unknown response type: $responseType');
                break;
            }
          }
        } catch (e) {
          _addLog('Error parsing response JSON: $e');
          if (!task.completer.isCompleted) {
            _completeTask(
              task.id,
              ScriptExecutionResult(
                success: false,
                error: 'Error parsing response: $e',
                executionTime: Duration.zero,
              ),
            );
          }
        }
      }
    } catch (e) {
      _addLog('Error executing task ${task.id}: $e');
      _completeTask(
        task.id,
        ScriptExecutionResult(
          success: false,
          error: e.toString(),
          executionTime: Duration.zero,
        ),
      );
    }
  }

  /// 完成任务
  void _completeTask(String taskId, ScriptExecutionResult result) {
    final task = _activeTasks.remove(taskId);
    if (task != null && !task.completer.isCompleted) {
      task.completer.complete(result);
      _addLog('Task $taskId completed: ${result.success ? 'success' : 'error'}');
    }

    // 释放Worker并处理队列中的下一个任务
    final workerInstance = _workerPool.firstWhere(
      (w) => w.currentTaskId == taskId,
      orElse: () => _workerPool.first,
    );

    workerInstance.isBusy = false;
    workerInstance.currentTaskId = null;

    // 处理等待队列中的下一个任务
    if (_taskQueue.isNotEmpty) {
      final nextTask = _taskQueue.removeAt(0);
      _executeTask(nextTask, workerInstance);
    }
  }

  @override
  void stop() {
    _addLog('Stopping all Squadron script executions...');

    // 完成所有待处理的任务
    for (final task in _activeTasks.values) {
      if (!task.completer.isCompleted) {
        task.completer.complete(
          ScriptExecutionResult(
            success: false,
            error: 'Script execution stopped',
            executionTime: Duration.zero,
          ),
        );
      }
    }
    _activeTasks.clear();

    // 清空队列
    for (final task in _taskQueue) {
      if (!task.completer.isCompleted) {
        task.completer.complete(
          ScriptExecutionResult(
            success: false,
            error: 'Script execution stopped',
            executionTime: Duration.zero,
          ),
        );
      }
    }
    _taskQueue.clear();

    _addLog('All Squadron script executions stopped');
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;

    if (kDebugMode) {
      debugPrint('[SquadronConcurrentWebWorkerScriptExecutor] Disposing...');
    }

    // 首先停止所有脚本执行
    stop();

    // 停止所有Worker
    for (final workerInstance in _workerPool) {
      try {
        workerInstance.worker.stopWorker();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error stopping Squadron worker ${workerInstance.id}: $e');
        }
      }
    }
    _workerPool.clear();

    _executionLogs.clear();
    _externalFunctions.clear();
    _isInitialized = false;

    if (kDebugMode) {
      debugPrint('[SquadronConcurrentWebWorkerScriptExecutor] Disposed');
    }
  }

  @override
  void registerExternalFunction(String name, Function handler) {
    _externalFunctions[name] = handler;
    _addLog('External function registered: $name');
  }

  @override
  void clearExternalFunctions() {
    _externalFunctions.clear();
    _addLog('All external functions cleared');
  }

  @override
  void sendMapDataUpdate(Map<String, dynamic> data) {
    // 向所有Worker发送地图数据更新 - 转换为JSON字符串
    final dataJson = jsonEncode(data);
    for (final workerInstance in _workerPool) {
      try {
        workerInstance.worker.updateMapData(dataJson);
      } catch (e) {
        _addLog('Error sending map data update to Squadron worker ${workerInstance.id}: $e');
      }
    }
    _addLog('Map data update sent to all Squadron workers');
  }

  @override
  List<String> getExecutionLogs() {
    return List.from(_executionLogs);
  }

  /// 获取并发统计信息
  Map<String, dynamic> getConcurrencyStats() {
    final busyWorkers = _workerPool.where((w) => w.isBusy).length;

    return {
      'totalWorkers': _workerPool.length,
      'busyWorkers': busyWorkers,
      'availableWorkers': _workerPool.length - busyWorkers,
      'activeTasks': _activeTasks.length,
      'queuedTasks': _taskQueue.length,
      'isInitialized': _isInitialized,
      'isDisposed': _isDisposed,
      'executorType': 'SquadronConcurrentWebWorker',
    };
  }
}

/// Squadron Worker实例
class _SquadronWorkerInstance {
  final int id;
  final ScriptWorkerServiceWorker worker;
  bool isBusy = false;
  String? currentTaskId;

  _SquadronWorkerInstance({
    required this.id,
    required this.worker,
  });
}

/// 执行任务
class _ExecutionTask {
  final String id;
  final String code;
  final Map<String, dynamic> context;
  final Duration? timeout;
  final Completer<ScriptExecutionResult> completer;

  _ExecutionTask({
    required this.id,
    required this.code,
    required this.context,
    this.timeout,
    required this.completer,
  });
}
