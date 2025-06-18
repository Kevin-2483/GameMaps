import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'script_executor_base.dart';
import 'external_function_registry.dart';
import '../../models/script_data.dart';
import 'hetu_script_worker.dart';

/// Web平台支持并发执行的脚本执行器
/// 使用 isolate_manager 的多个 Web Worker 实现真正的并发脚本执行
class ConcurrentWebWorkerScriptExecutor implements IScriptExecutor {
  /// Worker池大小
  final int _workerPoolSize;

  /// Worker池
  final List<_WorkerInstance> _workerPool = [];

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

  /// 日志控制器
  final StreamController<String> _logController =
      StreamController<String>.broadcast();

  /// 构造函数
  ConcurrentWebWorkerScriptExecutor({int workerPoolSize = 4})
    : _workerPoolSize = workerPoolSize;

  /// 添加日志
  void _addLog(String message) {
    if (_isDisposed) return; // 防止在dispose后添加日志

    final timestamp = DateTime.now();
    final logMessage = '[$timestamp] $message';
    _executionLogs.add(logMessage);

    // 只有当StreamController没有关闭时才添加事件
    if (!_logController.isClosed) {
      try {
        _logController.add(logMessage);
      } catch (e) {
        // 忽略Stream已关闭的错误
        if (kDebugMode) {
          debugPrint(
            '[ConcurrentWebWorkerScriptExecutor] Warning: Cannot add log after stream closed: $e',
          );
        }
      }
    }

    if (kDebugMode) {
      debugPrint('[ConcurrentWebWorkerScriptExecutor] $message');
    }
  }

  /// 初始化Worker池
  Future<void> _ensureInitialized() async {
    if (_isInitialized || _isDisposed) return;

    try {
      _addLog(
        'Initializing concurrent web worker pool (size: $_workerPoolSize)...',
      );

      // 创建Worker池
      for (int i = 0; i < _workerPoolSize; i++) {
        final worker = await _createWorkerInstance(i);
        _workerPool.add(worker);
        _addLog('Worker $i created successfully');
      }

      _isInitialized = true;
      _addLog('Concurrent web worker pool initialized successfully');

      // 监听日志
      _logController.stream.listen((log) {
        if (kDebugMode) {
          print('[ConcurrentWebWorkerScriptExecutor] $log');
        }
      });
    } catch (e) {
      _addLog('Failed to initialize concurrent web worker pool: $e');
      rethrow;
    }
  }

  /// 创建Worker实例
  Future<_WorkerInstance> _createWorkerInstance(int workerId) async {
    final isolateManager = IsolateManager<String, String>.createCustom(
      hetuScriptWorkerFunction,
      workerName: 'hetuScriptWorkerFunction',
      concurrent: 1,
      isDebug: kDebugMode,
    );

    await isolateManager.start();

    return _WorkerInstance(id: workerId, isolateManager: isolateManager);
  }

  @override
  Future<ScriptExecutionResult> execute(
    String code, {
    Map<String, dynamic>? context,
    Duration? timeout,
  }) async {
    if (_isDisposed) {
      throw StateError('ConcurrentWebWorkerScriptExecutor has been disposed');
    }

    await _ensureInitialized();

    // 生成唯一的执行ID
    final executionId =
        DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        math.Random().nextInt(1000).toString();

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
      _addLog(
        'Task $executionId added to queue (queue size: ${_taskQueue.length})',
      );
    }

    return task.completer.future;
  }

  /// 获取可用的Worker
  _WorkerInstance? _getAvailableWorker() {
    for (final worker in _workerPool) {
      if (!worker.isBusy) {
        return worker;
      }
    }
    return null;
  }

  /// 执行任务
  Future<void> _executeTask(_ExecutionTask task, _WorkerInstance worker) async {
    _activeTasks[task.id] = task;
    worker.isBusy = true;
    worker.currentTaskId = task.id;

    _addLog('Executing task ${task.id} on worker ${worker.id}');

    try {
      final requestData = {
        'type': 'execute',
        'code': task.code,
        'context': task.context,
        'externalFunctions': ExternalFunctionRegistry.getAllFunctionNames(),
        'executionId': task.id,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final jsonRequest = jsonEncode(requestData);
      Timer? timeoutTimer;

      // 设置超时
      if (task.timeout != null) {
        timeoutTimer = Timer(task.timeout!, () {
          if (!task.completer.isCompleted) {
            _addLog('Task ${task.id} timeout on worker ${worker.id}');
            _completeTask(
              task.id,
              ScriptExecutionResult(
                success: false,
                error:
                    'Script execution timeout after ${task.timeout!.inSeconds} seconds',
                executionTime: task.timeout!,
              ),
            );
          }
        });
      } // 监听Worker响应
      late StreamSubscription subscription;
      subscription = worker.isolateManager.stream.listen((jsonResponse) {
        // 分析器是正确的，jsonResponse 的类型就是 String。
        // 我们直接在 try 块中处理。
        try {
          // 核心逻辑：尝试解码，如果失败，会被下面的 on FormatException 捕获
          final response = jsonDecode(jsonResponse) as Map<String, dynamic>;

          final responseExecutionId = response['executionId'] as String?;

          if (responseExecutionId == task.id) {
            final responseType = response['type'] as String?;

            switch (responseType) {
              case 'started':
                _addLog(
                  'Script started for task ${task.id}, cancelling timeout timer',
                );
                timeoutTimer?.cancel();
                break;

              case 'externalFunctionCall':
                _handleExternalFunctionCall(response);
                break;

              case 'result':
              case 'error':
                if (!task.completer.isCompleted) {
                  subscription.cancel();
                  final result = _parseExecutionResult(response);
                  _completeTask(task.id, result);
                }
                break;

              default:
                _addLog(
                  'Received unknown message type: $responseType from worker. Ignoring.',
                );
                break;
            }
          }
        } on FormatException catch (e) {
          // --- 这里是关键的修正 ---
          // 专门捕获JSON解析失败的异常。
          // 这很可能就是收到了 '[object Object]' 这样的坏数据。
          // 我们只记录日志，不中断任何事情，等待下一条正常消息。
          _addLog(
            'Worker sent a non-JSON message, ignoring. Content: "$jsonResponse"',
          );
        } catch (e) {
          // 对于其他所有未预料到的严重错误，我们才中断任务。
          _addLog(
            'An unexpected error occurred while processing worker response: $e',
          );
          if (!task.completer.isCompleted) {
            timeoutTimer?.cancel();
            subscription.cancel();
            _completeTask(
              task.id,
              ScriptExecutionResult(
                success: false,
                error:
                    'Unexpected error processing worker response: ${e.toString()}',
                executionTime: Duration.zero,
              ),
            );
          }
        }
      });

      // 发送执行请求
      await worker.isolateManager.sendMessage(jsonRequest);
      _addLog('Task ${task.id} sent to worker ${worker.id}');
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
      _addLog(
        'Task $taskId completed: ${result.success ? 'success' : 'error'}',
      );
    }

    // 释放Worker并处理队列中的下一个任务
    final worker = _workerPool.firstWhere(
      (w) => w.currentTaskId == taskId,
      orElse: () => _workerPool.first,
    );

    worker.isBusy = false;
    worker.currentTaskId = null;

    // 处理等待队列中的下一个任务
    if (_taskQueue.isNotEmpty) {
      final nextTask = _taskQueue.removeAt(0);
      _executeTask(nextTask, worker);
    }
  }

  /// 解析执行结果
  ScriptExecutionResult _parseExecutionResult(Map<String, dynamic> response) {
    final type = _safeGetString(response, 'type');

    switch (type) {
      case 'result':
        return ScriptExecutionResult(
          success: true,
          result: response['result'],
          error: null,
          executionTime: Duration(
            milliseconds: _safeGetInt(response, 'executionTime'),
          ),
        );

      case 'error':
        final error = _safeGetString(response, 'error', 'Unknown error');
        return ScriptExecutionResult(
          success: false,
          result: null,
          error: error,
          executionTime: Duration(
            milliseconds: _safeGetInt(response, 'executionTime'),
          ),
        );

      default:
        throw Exception('Unknown response type: $type');
    }
  }

  /// 处理外部函数调用
  void _handleExternalFunctionCall(Map<String, dynamic> response) {
    final functionName = _safeGetString(response, 'functionName');
    // 处理Worker发送的参数格式 - 可能是单个值或List
    final argumentsRaw = response['arguments'];
    final arguments = <dynamic>[];

    if (argumentsRaw != null) {
      if (argumentsRaw is List) {
        arguments.addAll(argumentsRaw);
      } else {
        // 如果是单个值，将其作为第一个参数
        arguments.add(argumentsRaw);
      }
    }
    final callId = _safeGetString(response, 'callId');
    // 现在Worker应该发送executionId了
    String executionId = _safeGetString(response, 'executionId');

    // 如果没有executionId，尝试从当前活跃任务中推断（fallback策略）
    if (executionId.isEmpty && _activeTasks.isNotEmpty) {
      // 假设是最近创建的任务（这是一个fallback策略）
      executionId = _activeTasks.keys.first;
      _addLog(
        'Warning: No executionId in external function call, using active task: $executionId',
      );
    }

    _addLog(
      'Handling external function call: $functionName with args: $arguments (callId: $callId, executionId: $executionId)',
    );

    try {
      if (_externalFunctions.containsKey(functionName)) {
        final handler = _externalFunctions[functionName]!;
        final result = Function.apply(handler, arguments);

        // 找到对应的Worker并发送响应
        _sendExternalFunctionResponse(executionId, callId, result, null);
      } else {
        _sendExternalFunctionResponse(
          executionId,
          callId,
          null,
          'Function $functionName not found',
        );
      }
    } catch (e) {
      _sendExternalFunctionResponse(executionId, callId, null, e.toString());
    }
  }

  /// 发送外部函数响应
  void _sendExternalFunctionResponse(
    String executionId,
    String callId,
    dynamic result,
    String? error,
  ) {
    // 找到处理该执行任务的Worker
    _WorkerInstance? worker;

    // 首先尝试通过currentTaskId找到Worker
    try {
      worker = _workerPool.firstWhere((w) => w.currentTaskId == executionId);
    } catch (e) {
      // 如果找不到，可能任务已经完成或超时，记录日志并尝试使用第一个Worker
      _addLog(
        'Warning: Cannot find worker for executionId: $executionId, using first available worker',
      );
      worker = _workerPool.isNotEmpty ? _workerPool.first : null;
    }

    if (worker == null) {
      _addLog(
        'Error: No worker available to send external function response for call: $callId',
      );
      return;
    }

    try {
      final responseData = {
        'type': 'externalFunctionResponse',
        'callId': callId,
        'result': result,
        'error': error,
        'executionId': executionId,
      };

      final jsonResponse = jsonEncode(responseData);
      worker.isolateManager.sendMessage(jsonResponse);
      _addLog(
        'External function response sent for call: $callId to worker ${worker.id}',
      );
    } catch (e) {
      _addLog('Error sending external function response: $e');
    }
  }

  /// 安全地从Map中获取String值
  String _safeGetString(
    Map<String, dynamic> map,
    String key, [
    String defaultValue = '',
  ]) {
    final value = map[key];
    if (value is String) return value;
    if (value != null) return value.toString();
    return defaultValue;
  }

  /// 安全地从Map中获取int值
  int _safeGetInt(
    Map<String, dynamic> map,
    String key, [
    int defaultValue = 0,
  ]) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return defaultValue;
  }

  @override
  void stop() {
    _addLog('Stopping all concurrent script executions...');

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

    _addLog('All concurrent script executions stopped');
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;

    if (kDebugMode) {
      debugPrint(
        '[ConcurrentWebWorkerScriptExecutor] Disposing concurrent web worker script executor...',
      );
    }

    // 首先停止所有脚本执行
    stop();

    // 等待一小段时间确保所有Worker消息处理完成
    Future.delayed(Duration(milliseconds: 100), () {
      // 停止所有Worker
      for (final worker in _workerPool) {
        try {
          worker.isolateManager.stop();
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[ConcurrentWebWorkerScriptExecutor] Error stopping worker ${worker.id}: $e',
            );
          }
        }
      }
      _workerPool.clear();

      // 最后关闭StreamController
      if (!_logController.isClosed) {
        _logController.close();
      }

      _executionLogs.clear();
      _externalFunctions.clear();
      _isInitialized = false;

      if (kDebugMode) {
        debugPrint(
          '[ConcurrentWebWorkerScriptExecutor] Concurrent web worker script executor disposed',
        );
      }
    });
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
    // 向所有Worker发送地图数据更新
    for (final worker in _workerPool) {
      try {
        final updateData = {'type': 'mapDataUpdate', 'data': data};
        final jsonUpdate = jsonEncode(updateData);
        worker.isolateManager.sendMessage(jsonUpdate);
      } catch (e) {
        _addLog('Error sending map data update to worker ${worker.id}: $e');
      }
    }
    _addLog('Map data update sent to all workers');
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
    };
  }
}

/// Worker实例
class _WorkerInstance {
  final int id;
  final IsolateManager<String, String> isolateManager;
  bool isBusy = false;
  String? currentTaskId;

  _WorkerInstance({required this.id, required this.isolateManager});
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
