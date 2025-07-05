import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'script_executor_base.dart';
import 'external_function_registry.dart';
import '../../models/script_data.dart';
import 'hetu_script_worker.dart';

/// 任务状态枚举
enum TaskStatus {
  /// 任务已创建，等待执行
  pending,

  /// 任务已分配给Worker，正在准备
  assigned,

  /// 任务已开始执行
  running,

  /// 任务执行完成（成功）
  completed,

  /// 任务执行失败
  failed,

  /// 任务被取消
  cancelled,

  /// 任务超时
  timeout,
}

/// 任务状态信息
class TaskStatusInfo {
  final String taskId;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? workerIndex;
  final String? error;
  final Duration? timeout;

  TaskStatusInfo({
    required this.taskId,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.workerIndex,
    this.error,
    this.timeout,
  });

  /// 计算任务运行时长
  Duration get runningDuration {
    if (startedAt == null) return Duration.zero;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  /// 计算任务等待时长
  Duration get pendingDuration {
    final endTime = startedAt ?? completedAt ?? DateTime.now();
    return endTime.difference(createdAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'workerIndex': workerIndex,
      'error': error,
      'timeout': timeout?.inMilliseconds,
      'runningDuration': runningDuration.inMilliseconds,
      'pendingDuration': pendingDuration.inMilliseconds,
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
  Timer? timeoutTimer;

  _ExecutionTask({
    required this.id,
    required this.code,
    required this.context,
    this.timeout,
    required this.completer,
  });
}

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

  /// 任务状态信息映射
  final Map<String, TaskStatusInfo> _taskStatusMap = {};

  /// 任务ID到worker索引的映射
  final Map<String, int> _taskToWorkerMap = {};

  /// worker索引到任务ID的映射
  final Map<int, String?> _workerToTaskMap = {};

  /// 等待队列
  final List<_ExecutionTask> _taskQueue = [];

  /// 底层消息流订阅
  StreamSubscription<String>? _rawMessageSubscription;

  /// 初始化状态
  bool _isInitialized = false;
  bool _isDisposed = false;

  /// 日志控制器
  final StreamController<String> _logController =
      StreamController<String>.broadcast();

  /// 任务状态变化控制器
  final StreamController<TaskStatusInfo> _taskStatusController =
      StreamController<TaskStatusInfo>.broadcast();

  /// 构造函数
  ConcurrentWebWorkerScriptExecutor({int workerPoolSize = 4})
    : _workerPoolSize = workerPoolSize;

  /// 任务状态变化流
  Stream<TaskStatusInfo> get taskStatusStream => _taskStatusController.stream;

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

  /// 更新任务状态
  void _updateTaskStatus(
    String taskId,
    TaskStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
    int? workerIndex,
    String? error,
  }) {
    final existingStatus = _taskStatusMap[taskId];
    if (existingStatus == null) return;

    final updatedStatus = TaskStatusInfo(
      taskId: taskId,
      status: status,
      createdAt: existingStatus.createdAt,
      startedAt: startedAt ?? existingStatus.startedAt,
      completedAt: completedAt ?? existingStatus.completedAt,
      workerIndex: workerIndex ?? existingStatus.workerIndex,
      error: error ?? existingStatus.error,
      timeout: existingStatus.timeout,
    );

    _taskStatusMap[taskId] = updatedStatus;

    // 发送状态更新事件
    if (!_taskStatusController.isClosed) {
      _taskStatusController.add(updatedStatus);
    }

    _addLog('Task $taskId status updated to: ${status.name}');
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
        _workerToTaskMap[i] = null; // 初始化worker映射
        _addLog('Worker $i created successfully');
      }

      // 设置底层消息流监听
      _setupRawMessageListener();

      _isInitialized = true;
      _addLog('Concurrent web worker pool initialized successfully');

      // 监听日志
      _logController.stream.listen((log) {
        if (kDebugMode) {
          debugPrint('[ConcurrentWebWorkerScriptExecutor] $log');
        }
      });
    } catch (e) {
      _addLog('Failed to initialize concurrent web worker pool: $e');
      rethrow;
    }
  }

  /// 设置底层消息流监听
  void _setupRawMessageListener() {
    if (_workerPool.isEmpty) return;

    // 使用第一个worker的isolateManager获取rawMessageStream
    // 因为所有worker都会发送消息到同一个stream
    final isolateManager = _workerPool.first.isolateManager;

    _rawMessageSubscription = isolateManager.rawMessageStream.listen(
      _handleRawMessage,
      onError: (error) {
        _addLog('Error in raw message stream: $error');
      },
    );

    _addLog('Raw message listener set up successfully');
  }

  /// 处理来自worker的原始消息
  void _handleRawMessage(dynamic rawMessage) {
    try {
      Map<String, dynamic> response;

      // 处理不同类型的消息
      if (rawMessage is Map<String, dynamic>) {
        // 如果已经是Map，直接使用
        response = rawMessage;
      } else if (rawMessage is Map) {
        // 如果是其他类型的Map，转换为Map<String, dynamic>
        response = Map<String, dynamic>.from(rawMessage);
      } else if (rawMessage is String) {
        // 如果是字符串，尝试JSON解析
        try {
          response = jsonDecode(rawMessage) as Map<String, dynamic>;
        } catch (e) {
          _addLog('Failed to parse JSON message: $e. Content: "$rawMessage"');
          return;
        }
      } else {
        _addLog(
          'Received unsupported message type: ${rawMessage.runtimeType}. Content: "$rawMessage"',
        );
        return;
      }

      final responseExecutionId = response['executionId'] as String?;

      if (responseExecutionId == null) {
        _addLog('Received message without executionId, ignoring');
        return;
      }
      final responseType = response['type'] as String?;

      // 对于 fire-and-forget 函数调用，即使任务已完成也要处理
      if (responseType == 'fireAndForgetFunctionCall') {
        _addLog(
          'Received message type: $responseType for task: $responseExecutionId, content: $response',
        );
        _handleFireAndForgetFunctionCall(response);
        return;
      }

      // 查找对应的任务
      final task = _activeTasks[responseExecutionId];
      if (task == null) {
        _addLog(
          'Received message for unknown task $responseExecutionId, ignoring, content: $response',
        );
        return;
      }

      _addLog(
        'Received message type: $responseType for task: $responseExecutionId, content: $response',
      );
      switch (responseType) {
        case 'started':
          _handleTaskStarted(responseExecutionId);
          break;

        case 'externalFunctionCall':
          _handleExternalFunctionCall(response);
          break;

        case 'result':
        case 'error':
          if (!task.completer.isCompleted) {
            final result = _parseExecutionResult(response);
            _completeTask(responseExecutionId, result);
          }
          break;

        default:
          _addLog('Received unknown message type: $responseType, ignoring');
          break;
      }
    } catch (e) {
      _addLog('Error processing worker response: $e');
    }
  }

  /// 处理任务开始信号
  void _handleTaskStarted(String taskId) {
    _addLog('Script started for task $taskId');

    // 取消超时计时器
    final task = _activeTasks[taskId];
    if (task != null && task.timeoutTimer != null) {
      task.timeoutTimer!.cancel();
      task.timeoutTimer = null;
      _addLog('Timeout timer cancelled for task $taskId');
    }

    // 更新任务状态为运行中
    _updateTaskStatus(taskId, TaskStatus.running, startedAt: DateTime.now());
  }

  /// 创建Worker实例
  Future<_WorkerInstance> _createWorkerInstance(int workerId) async {
    final isolateManager = IsolateManager<String, String>.createCustom(
      hetuScriptWorkerFunction,
      workerName: 'hetuScriptWorkerFunction',
      concurrent: 4,
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

    // 创建任务状态信息
    _taskStatusMap[executionId] = TaskStatusInfo(
      taskId: executionId,
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
      timeout: timeout,
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
    final workerIndex = _workerPool.indexOf(worker);

    // 更新映射关系
    _activeTasks[task.id] = task;
    _taskToWorkerMap[task.id] = workerIndex;
    _workerToTaskMap[workerIndex] = task.id;

    worker.isBusy = true;
    worker.currentTaskId = task.id;

    // 更新任务状态为已分配
    _updateTaskStatus(task.id, TaskStatus.assigned, workerIndex: workerIndex);

    _addLog(
      'Executing task ${task.id} on worker ${worker.id} (index: $workerIndex)',
    );

    try {
      final requestData = {
        'type': 'execute',
        'code': task.code,
        'context': task.context,
        'externalFunctions':
            ExternalFunctionRegistry.getAllFunctionNamesWithInternal(),
        'executionId': task.id,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final jsonRequest = jsonEncode(requestData);

      // 设置超时处理
      if (task.timeout != null) {
        task.timeoutTimer = Timer(task.timeout!, () {
          if (!task.completer.isCompleted) {
            _addLog('Task ${task.id} timeout on worker ${worker.id}');
            _updateTaskStatus(
              task.id,
              TaskStatus.timeout,
              completedAt: DateTime.now(),
              error:
                  'Script execution timeout after ${task.timeout!.inSeconds} seconds',
            );
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
      }

      // 使用底层接口发送请求到指定的worker
      worker.isolateManager.sendRawMessageFireAndForget(
        jsonRequest,
        isolateIndex: 0,
      );
      _addLog(
        'Task ${task.id} sent to worker ${worker.id} using raw interface',
      );
    } catch (e) {
      _addLog('Error executing task ${task.id}: $e');
      _updateTaskStatus(
        task.id,
        TaskStatus.failed,
        completedAt: DateTime.now(),
        error: e.toString(),
      );
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
      // 取消超时计时器
      task.timeoutTimer?.cancel();

      task.completer.complete(result);

      // 更新任务状态
      _updateTaskStatus(
        taskId,
        result.success ? TaskStatus.completed : TaskStatus.failed,
        completedAt: DateTime.now(),
        error: result.error,
      );

      _addLog(
        'Task $taskId completed: ${result.success ? 'success' : 'error'}',
      );
    }

    // 获取worker索引并清理映射关系
    final workerIndex = _taskToWorkerMap.remove(taskId);
    if (workerIndex != null) {
      _workerToTaskMap[workerIndex] = null;

      // 释放Worker
      if (workerIndex < _workerPool.length) {
        final worker = _workerPool[workerIndex];
        worker.isBusy = false;
        worker.currentTaskId = null;

        _addLog('Released worker $workerIndex (id: ${worker.id})');

        // 处理等待队列中的下一个任务
        if (_taskQueue.isNotEmpty) {
          final nextTask = _taskQueue.removeAt(0);
          _executeTask(nextTask, worker);
        }
      }
    } else {
      _addLog('Warning: Could not find worker for completed task $taskId');
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

  /// 处理不需要等待结果的外部函数调用（Fire and Forget）
  void _handleFireAndForgetFunctionCall(Map<String, dynamic> response) {
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
    final executionId = _safeGetString(response, 'executionId');

    _addLog(
      'Handling fire-and-forget function call: $functionName with args: $arguments (executionId: $executionId)',
    );

    try {
      if (_externalFunctions.containsKey(functionName)) {
        final handler = _externalFunctions[functionName]!;
        // Fire and Forget - 调用函数但不等待结果，也不发送响应
        Function.apply(handler, arguments);
        _addLog('Fire-and-forget function $functionName executed successfully');
      } else {
        _addLog('Warning: Fire-and-forget function $functionName not found');
      }
    } catch (e) {
      _addLog('Error in fire-and-forget function $functionName: $e');
      // 对于 Fire and Forget 函数，我们只记录错误，不影响脚本执行
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
      // 修复：使用 sendRawMessageFireAndForget 而不是 sendMessage
      // 因为 Worker 只设置了 setRawMessageHandler 来处理原始消息
      worker.isolateManager.sendRawMessageFireAndForget(
        jsonResponse,
        isolateIndex: 0,
      );
      _addLog(
        'External function response sent for call: $callId to worker ${worker.id} using raw interface',
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
        // 取消超时计时器
        task.timeoutTimer?.cancel();

        // 更新任务状态
        _updateTaskStatus(
          task.id,
          TaskStatus.cancelled,
          completedAt: DateTime.now(),
        );

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
        // 取消超时计时器
        task.timeoutTimer?.cancel();

        // 更新任务状态
        _updateTaskStatus(
          task.id,
          TaskStatus.cancelled,
          completedAt: DateTime.now(),
        );

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

    // 取消底层消息流订阅
    _rawMessageSubscription?.cancel();
    _rawMessageSubscription = null;

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

      // 清理映射关系
      _taskToWorkerMap.clear();
      _workerToTaskMap.clear();
      _taskStatusMap.clear();

      // 关闭StreamController
      if (!_logController.isClosed) {
        _logController.close();
      }
      if (!_taskStatusController.isClosed) {
        _taskStatusController.close();
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
        // 修复：使用 sendRawMessageFireAndForget 而不是 sendMessage
        // 因为 Worker 只设置了 setRawMessageHandler 来处理原始消息
        worker.isolateManager.sendRawMessageFireAndForget(
          jsonUpdate,
          isolateIndex: 0,
        );
      } catch (e) {
        _addLog('Error sending map data update to worker ${worker.id}: $e');
      }
    }
    _addLog('Map data update sent to all workers using raw interface');
  }

  @override
  List<String> getExecutionLogs() {
    return List.from(_executionLogs);
  }

  /// 获取指定任务的状态信息
  TaskStatusInfo? getTaskStatus(String taskId) {
    return _taskStatusMap[taskId];
  }

  /// 获取所有任务的状态信息
  Map<String, TaskStatusInfo> getAllTaskStatuses() {
    return Map.from(_taskStatusMap);
  }

  /// 获取指定状态的任务列表
  List<TaskStatusInfo> getTasksWithStatus(TaskStatus status) {
    return _taskStatusMap.values
        .where((task) => task.status == status)
        .toList();
  }

  /// 获取活动任务数量
  int get activeTaskCount => _activeTasks.length;

  /// 获取等待队列任务数量
  int get queuedTaskCount => _taskQueue.length;

  /// 获取可用Worker数量
  int get availableWorkerCount => _workerPool.where((w) => !w.isBusy).length;

  /// 获取繁忙Worker数量
  int get busyWorkerCount => _workerPool.where((w) => w.isBusy).length;

  /// 获取并发统计信息
  Map<String, dynamic> getConcurrencyStats() {
    final busyWorkers = _workerPool.where((w) => w.isBusy).length;
    final statusCounts = <String, int>{};

    for (final status in TaskStatus.values) {
      statusCounts[status.name] = getTasksWithStatus(status).length;
    }

    return {
      'totalWorkers': _workerPool.length,
      'busyWorkers': busyWorkers,
      'availableWorkers': _workerPool.length - busyWorkers,
      'activeTasks': _activeTasks.length,
      'queuedTasks': _taskQueue.length,
      'totalTrackedTasks': _taskStatusMap.length,
      'taskStatusBreakdown': statusCounts,
      'isInitialized': _isInitialized,
      'isDisposed': _isDisposed,
    };
  }

  /// 获取指定任务的worker索引
  int? getTaskWorkerIndex(String taskId) {
    return _taskToWorkerMap[taskId];
  }

  /// 获取指定worker的当前任务ID
  String? getWorkerCurrentTask(int workerIndex) {
    return _workerToTaskMap[workerIndex];
  }

  /// 获取所有活动任务的映射信息
  Map<String, Map<String, dynamic>> getTaskMappingInfo() {
    final info = <String, Map<String, dynamic>>{};

    for (final entry in _taskToWorkerMap.entries) {
      final taskId = entry.key;
      final workerIndex = entry.value;
      final task = _activeTasks[taskId];
      final statusInfo = _taskStatusMap[taskId];

      info[taskId] = {
        'workerIndex': workerIndex,
        'workerId': workerIndex < _workerPool.length
            ? _workerPool[workerIndex].id
            : null,
        'isCompleted': task?.completer.isCompleted ?? true,
        'hasTask': task != null,
        'status': statusInfo?.status.name,
        'createdAt': statusInfo?.createdAt.toIso8601String(),
        'startedAt': statusInfo?.startedAt?.toIso8601String(),
        'completedAt': statusInfo?.completedAt?.toIso8601String(),
        'runningDuration': statusInfo?.runningDuration.inMilliseconds,
        'pendingDuration': statusInfo?.pendingDuration.inMilliseconds,
      };
    }

    return info;
  }

  /// 获取Worker池状态信息
  Map<String, dynamic> getWorkerPoolStatus() {
    final workers = <Map<String, dynamic>>[];

    for (int i = 0; i < _workerPool.length; i++) {
      final worker = _workerPool[i];
      final currentTaskId = _workerToTaskMap[i];
      final taskStatus = currentTaskId != null
          ? _taskStatusMap[currentTaskId]
          : null;

      workers.add({
        'index': i,
        'id': worker.id,
        'isBusy': worker.isBusy,
        'currentTaskId': worker.currentTaskId,
        'mappedTaskId': currentTaskId,
        'taskStatus': taskStatus?.status.name,
        'taskStartedAt': taskStatus?.startedAt?.toIso8601String(),
        'taskRunningDuration': taskStatus?.runningDuration.inMilliseconds,
      });
    }

    return {
      'workerCount': _workerPool.length,
      'activeTaskCount': _activeTasks.length,
      'queuedTaskCount': _taskQueue.length,
      'workers': workers,
      'taskToWorkerMap': Map.from(_taskToWorkerMap),
      'workerToTaskMap': Map.from(_workerToTaskMap),
    };
  }

  /// 取消指定任务
  bool cancelTask(String taskId) {
    final task = _activeTasks.remove(taskId);
    if (task != null && !task.completer.isCompleted) {
      // 取消超时计时器
      task.timeoutTimer?.cancel();

      // 更新任务状态
      _updateTaskStatus(
        taskId,
        TaskStatus.cancelled,
        completedAt: DateTime.now(),
      );

      task.completer.complete(
        ScriptExecutionResult(
          success: false,
          error: 'Task cancelled',
          executionTime: Duration.zero,
        ),
      );

      // 释放Worker
      final workerIndex = _taskToWorkerMap.remove(taskId);
      if (workerIndex != null) {
        _workerToTaskMap[workerIndex] = null;
        if (workerIndex < _workerPool.length) {
          final worker = _workerPool[workerIndex];
          worker.isBusy = false;
          worker.currentTaskId = null;

          _addLog('Task $taskId cancelled, worker $workerIndex released');

          // 处理等待队列中的下一个任务
          if (_taskQueue.isNotEmpty) {
            final nextTask = _taskQueue.removeAt(0);
            _executeTask(nextTask, worker);
          }
        }
      }

      return true;
    }

    // 检查是否在等待队列中
    final queueIndex = _taskQueue.indexWhere((t) => t.id == taskId);
    if (queueIndex >= 0) {
      final queuedTask = _taskQueue.removeAt(queueIndex);
      queuedTask.timeoutTimer?.cancel();

      // 更新任务状态
      _updateTaskStatus(
        taskId,
        TaskStatus.cancelled,
        completedAt: DateTime.now(),
      );

      if (!queuedTask.completer.isCompleted) {
        queuedTask.completer.complete(
          ScriptExecutionResult(
            success: false,
            error: 'Task cancelled while in queue',
            executionTime: Duration.zero,
          ),
        );
      }

      _addLog('Queued task $taskId cancelled');
      return true;
    }

    return false;
  }
}
