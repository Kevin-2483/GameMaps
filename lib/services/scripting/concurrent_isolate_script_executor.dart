import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:hetu_script/hetu_script.dart';
import '../../models/script_data.dart';
import 'script_executor_base.dart';
import 'external_function_registry.dart';

/// 支持并发的Isolate脚本执行器
/// 基于现有的IsolateScriptExecutor，但支持真正的多任务并发执行
class ConcurrentIsolateScriptExecutor implements IScriptExecutor {
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  ReceivePort? _receivePort;

  final List<String> _executionLogs = [];
  final Map<String, Function> _externalFunctionHandlers = {};

  // 支持并发的执行任务映射
  final Map<String, Completer<ScriptExecutionResult>> _pendingExecutions = {};
  final Map<String, Timer> _timeoutTimers = {};

  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  Future<ScriptExecutionResult> execute(
    String code, {
    Map<String, dynamic>? context,
    Duration? timeout,
  }) async {
    if (_isDisposed) {
      throw StateError('Executor has been disposed');
    }

    // 生成唯一的执行ID
    final executionId =
        DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        math.Random().nextInt(1000).toString();

    final completer = Completer<ScriptExecutionResult>();
    _pendingExecutions[executionId] = completer;

    try {
      // 启动隔离（如果尚未启动）
      await _ensureIsolateStarted(); // 设置超时
      if (timeout != null) {
        debugPrint(
          'DEBUG: Setting timeout timer for execution: $executionId, timeout: ${timeout.inSeconds}s',
        );
        _timeoutTimers[executionId] = Timer(timeout, () {
          debugPrint(
            'DEBUG: Timeout timer triggered for execution: $executionId',
          );
          if (!completer.isCompleted) {
            _pendingExecutions.remove(executionId);
            _timeoutTimers.remove(executionId);
            debugPrint('ERROR: Script execution timeout for: $executionId');
            completer.complete(
              ScriptExecutionResult(
                success: false,
                error:
                    'Script execution timeout after ${timeout.inSeconds} seconds',
                executionTime: timeout,
              ),
            );
          } else {
            debugPrint(
              'DEBUG: Completer already completed for execution: $executionId',
            );
          }
        });
        debugPrint('DEBUG: Timeout timer created for execution: $executionId');
      }

      // 发送执行消息
      final message = ScriptMessage(
        type: ScriptMessageType.execute,
        data: {
          'code': code,
          'context': context ?? {},
          'executionId': executionId, // 添加执行ID以识别响应
        },
      );

      _isolateSendPort!.send(message.toJson());
      return await completer.future;
    } catch (e) {
      _pendingExecutions.remove(executionId);
      _timeoutTimers[executionId]?.cancel();
      _timeoutTimers.remove(executionId);

      return ScriptExecutionResult(
        success: false,
        error: e.toString(),
        executionTime: Duration.zero,
      );
    }
  }

  /// 确保Isolate已启动
  Future<void> _ensureIsolateStarted() async {
    if (_isInitialized || _isDisposed) return;

    try {
      _receivePort = ReceivePort();
      _isolate = await Isolate.spawn(
        _isolateEntryPoint,
        _receivePort!.sendPort,
      ); // 等待隔离准备就绪
      final completer = Completer<void>();
      bool isReady = false;

      _receivePort!.listen((data) {
        if (data is Map && data['type'] == 'ready' && !isReady) {
          _isolateSendPort = data['sendPort'];
          isReady = true;
          if (!completer.isCompleted) {
            completer.complete();
          }
        } else {
          // 处理其他消息（脚本执行结果等）
          _handleIsolateMessage(data);
        }
      });

      await completer.future;
      _isInitialized = true;
      debugPrint('ConcurrentIsolateScriptExecutor initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize ConcurrentIsolateScriptExecutor: $e');
      rethrow;
    }
  }

  /// 处理来自隔离的消息
  void _handleIsolateMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return;
    try {
      debugPrint('DEBUG: Received message: ${data.toString()}');
      final message = ScriptMessage.fromJson(data);
      final executionId = message.data['executionId'] as String?;
      debugPrint(
        'DEBUG: Message type: ${message.type}, executionId: $executionId',
      );
      switch (message.type) {
        case ScriptMessageType.started:
          // 脚本已开始执行，取消超时定时器
          debugPrint(
            'DEBUG: Processing started message for execution: $executionId',
          );
          debugPrint(
            'DEBUG: Available timeout timers: ${_timeoutTimers.keys.toList()}',
          );
          debugPrint(
            'DEBUG: Available pending executions: ${_pendingExecutions.keys.toList()}',
          );
          if (executionId != null && _timeoutTimers.containsKey(executionId)) {
            _timeoutTimers[executionId]?.cancel();
            _timeoutTimers.remove(executionId);
            debugPrint(
              'SUCCESS: Timeout timer cancelled for execution: $executionId',
            );
          } else {
            debugPrint(
              'WARNING: No timeout timer found for execution: $executionId',
            );
            debugPrint(
              'DEBUG: Available timers: ${_timeoutTimers.keys.toList()}',
            );
          }
          break;

        case ScriptMessageType.result:
          if (executionId != null &&
              _pendingExecutions.containsKey(executionId)) {
            final completer = _pendingExecutions.remove(executionId)!;
            _timeoutTimers[executionId]?.cancel();
            _timeoutTimers.remove(executionId);

            final result = ScriptExecutionResult(
              success: true,
              result: message.data['result'],
              executionTime: Duration(
                milliseconds: message.data['executionTime'] ?? 0,
              ),
            );
            completer.complete(result);
          }
          break;

        case ScriptMessageType.error:
          if (executionId != null &&
              _pendingExecutions.containsKey(executionId)) {
            final completer = _pendingExecutions.remove(executionId)!;
            _timeoutTimers[executionId]?.cancel();
            _timeoutTimers.remove(executionId);

            final result = ScriptExecutionResult(
              success: false,
              error: message.data['error'] ?? 'Unknown error',
              executionTime: Duration(
                milliseconds: message.data['executionTime'] ?? 0,
              ),
            );
            completer.complete(result);
          }
          break;

        case ScriptMessageType.log:
          final logMessage = message.data['message']?.toString() ?? '';
          _executionLogs.add('[${DateTime.now()}] $logMessage');
          if (kDebugMode) {
            debugPrint('[Script] $logMessage');
          }
          break;        case ScriptMessageType.externalFunctionCall:
          _handleExternalFunctionCall(message);
          break;

        case ScriptMessageType.fireAndForgetFunctionCall:
          _handleFireAndForgetFunctionCall(message);
          break;

        default:
          debugPrint('Unknown message type: ${message.type}');
      }
    } catch (e) {
      debugPrint('Error handling isolate message: $e');
    }
  }

  /// 处理外部函数调用
  void _handleExternalFunctionCall(ScriptMessage message) {
    final call = ExternalFunctionCall.fromJson(message.data);

    try {
      if (_externalFunctionHandlers.containsKey(call.functionName)) {
        final handler = _externalFunctionHandlers[call.functionName]!;
        final result = Function.apply(handler, call.arguments);

        // 发送响应
        final response = ExternalFunctionResponse(
          callId: call.callId,
          result: result,
        );

        final responseMessage = ScriptMessage(
          type: ScriptMessageType.externalFunctionResponse,
          data: response.toJson(),
        );

        _isolateSendPort?.send(responseMessage.toJson());
      } else {
        // 函数未找到，发送错误响应
        final response = ExternalFunctionResponse(
          callId: call.callId,
          error: 'Function ${call.functionName} not found',
        );

        final responseMessage = ScriptMessage(
          type: ScriptMessageType.externalFunctionResponse,
          data: response.toJson(),
        );

        _isolateSendPort?.send(responseMessage.toJson());
      }
    } catch (e) {
      // 函数执行错误，发送错误响应
      final response = ExternalFunctionResponse(
        callId: call.callId,
        error: e.toString(),
      );

      final responseMessage = ScriptMessage(
        type: ScriptMessageType.externalFunctionResponse,
        data: response.toJson(),
      );

      _isolateSendPort?.send(responseMessage.toJson());
    }
  }

  /// 处理不需要等待结果的外部函数调用（Fire and Forget）
  void _handleFireAndForgetFunctionCall(ScriptMessage message) {
    final call = ExternalFunctionCall.fromJson(message.data);

    try {
      if (_externalFunctionHandlers.containsKey(call.functionName)) {
        final handler = _externalFunctionHandlers[call.functionName]!;
        // Fire and Forget - 调用函数但不发送响应
        Function.apply(handler, call.arguments);
        debugPrint('Fire-and-forget function ${call.functionName} executed successfully');
      } else {
        debugPrint('Warning: Fire-and-forget function ${call.functionName} not found');
      }
    } catch (e) {
      debugPrint('Error in fire-and-forget function ${call.functionName}: $e');
      // 对于 Fire and Forget 函数，我们只记录错误，不影响脚本执行
    }
  }

  @override
  void stop() {
    // 清理所有待处理的执行
    for (final entry in _pendingExecutions.entries) {
      if (!entry.value.isCompleted) {
        entry.value.complete(
          ScriptExecutionResult(
            success: false,
            error: 'Script execution stopped',
            executionTime: Duration.zero,
          ),
        );
      }
    }
    _pendingExecutions.clear();

    // 取消所有超时定时器
    for (final timer in _timeoutTimers.values) {
      timer.cancel();
    }
    _timeoutTimers.clear();

    debugPrint('All concurrent script executions stopped');
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    stop();

    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    _receivePort?.close();
    _receivePort = null;

    _isolateSendPort = null;
    _executionLogs.clear();
    _externalFunctionHandlers.clear();

    _isInitialized = false;
    debugPrint('ConcurrentIsolateScriptExecutor disposed');
  }

  @override
  void registerExternalFunction(String name, Function handler) {
    _externalFunctionHandlers[name] = handler;
  }

  @override
  void clearExternalFunctions() {
    _externalFunctionHandlers.clear();
  }

  @override
  void sendMapDataUpdate(Map<String, dynamic> data) {
    if (_isolateSendPort != null) {
      final message = ScriptMessage(
        type: ScriptMessageType.mapDataUpdate,
        data: data,
      );
      _isolateSendPort!.send(message.toJson());
    }
  }

  @override
  List<String> getExecutionLogs() {
    return List.from(_executionLogs);
  }

  /// Isolate入口点 - 支持并发执行
  static void _isolateEntryPoint(SendPort mainSendPort) {
    final receivePort = ReceivePort();

    // 发送准备就绪消息
    mainSendPort.send({'type': 'ready', 'sendPort': receivePort.sendPort});

    // 存储外部函数的响应等待映射
    final Map<String, Completer<dynamic>> pendingExternalCalls = {};

    receivePort.listen((data) {
      if (data is! Map<String, dynamic>) return;

      try {
        final message = ScriptMessage.fromJson(data);

        switch (message.type) {
          case ScriptMessageType.execute:
            _handleExecuteInIsolate(
              message,
              mainSendPort,
              pendingExternalCalls,
            );
            break;

          case ScriptMessageType.externalFunctionResponse:
            _handleExternalFunctionResponseInIsolate(
              message,
              pendingExternalCalls,
            );
            break;

          case ScriptMessageType.mapDataUpdate:
            // 处理地图数据更新
            break;

          default:
            break;
        }
      } catch (e) {
        // 发送错误消息
        final errorMessage = ScriptMessage(
          type: ScriptMessageType.error,
          data: {'error': e.toString()},
        );
        mainSendPort.send(errorMessage.toJson());
      }
    });
  }
  /// 在隔离中处理脚本执行
  static void _handleExecuteInIsolate(
    ScriptMessage message,
    SendPort mainSendPort,
    Map<String, Completer<dynamic>> pendingExternalCalls,
  ) {
    final stopwatch = Stopwatch()..start();
    final executionId = message.data['executionId'] as String?;

    void sendResult(bool success, {dynamic result, String? error}) {
      stopwatch.stop();
      final responseMessage = ScriptMessage(
        type: success ? ScriptMessageType.result : ScriptMessageType.error,
        data: {
          if (success) 'result': result else 'error': error ?? 'Unknown error',
          'executionTime': stopwatch.elapsedMilliseconds,
          'executionId': executionId,
        },
      );
      mainSendPort.send(responseMessage.toJson());
    }

    try {
      final code = message.data['code'] as String;
      final context =
          message.data['context'] as Map<String, dynamic>? ?? {}; // 创建Hetu脚本解释器
      final hetu = Hetu();

      // 使用统一的外部函数注册器
      final externalFunctions =
          ExternalFunctionRegistry.createFunctionsForIsolate(
            (functionName, arguments) => _callExternalFunction(
              functionName,
              arguments,
              mainSendPort,
              pendingExternalCalls,
            ),
            (functionName, arguments) => _callFireAndForgetFunction(
              functionName,
              arguments,
              mainSendPort,
            ),
          );

      // 添加内部函数（直接在isolate内部执行，不需要跨线程通信）
      _addInternalFunctions(externalFunctions);

      // 初始化Hetu解释器
      hetu.init(externalFunctions: externalFunctions);

      // 设置上下文变量
      for (final entry in context.entries) {
        hetu.assign(entry.key, entry.value);
      }

      // 发送脚本已开始执行的消息
      debugPrint('DEBUG: Sending started message for execution: $executionId');
      final startedMessage = ScriptMessage(
        type: ScriptMessageType.started,
        data: {'executionId': executionId},
      );
      mainSendPort.send(startedMessage.toJson());
      debugPrint('DEBUG: Started message sent for execution: $executionId');

      // 执行脚本 - 处理同步和异步结果
      final result = hetu.eval(code);

      if (result is Future) {
        result
            .then((actualResult) {
              sendResult(true, result: actualResult);
            })
            .catchError((e) {
              sendResult(false, error: e.toString());
            });
      } else {
        sendResult(true, result: result);
      }
    } catch (e) {
      sendResult(false, error: e.toString());
    }
  }

  /// 调用外部函数（通过消息传递与主线程通信）
  static Future<dynamic> _callExternalFunction(
    String functionName,
    List<dynamic> arguments,
    SendPort mainSendPort,
    Map<String, Completer<dynamic>> pendingExternalCalls,
  ) async {
    final callId = ExternalFunctionRegistry.generateCallId();

    final call = ExternalFunctionCall(
      functionName: functionName,
      arguments: arguments,
      callId: callId,
    );

    // 创建 Completer 等待响应
    final completer = Completer<dynamic>();
    pendingExternalCalls[callId] = completer;

    // 发送函数调用消息到主线程
    final message = ScriptMessage(
      type: ScriptMessageType.externalFunctionCall,
      data: call.toJson(),
    );

    mainSendPort.send(message.toJson());

    // 等待主线程响应（最多10秒超时）
    try {
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          pendingExternalCalls.remove(callId);
          throw Exception('External function call timeout: $functionName');
        },
      );
    } catch (e) {
      pendingExternalCalls.remove(callId);
      rethrow;
    }
  }

  /// 调用不需要等待结果的外部函数（Fire and Forget）
  static void _callFireAndForgetFunction(
    String functionName,
    List<dynamic> arguments,
    SendPort mainSendPort,
  ) {
    final call = ExternalFunctionCall(
      functionName: functionName,
      arguments: arguments,
      callId: 'fire-and-forget-${DateTime.now().millisecondsSinceEpoch}',
    );

    // 发送函数调用消息到主线程，但不等待响应
    final message = ScriptMessage(
      type: ScriptMessageType.fireAndForgetFunctionCall,
      data: call.toJson(),
    );

    mainSendPort.send(message.toJson());
  }

  /// 在隔离中处理外部函数响应
  static void _handleExternalFunctionResponseInIsolate(
    ScriptMessage message,
    Map<String, Completer<dynamic>> pendingExternalCalls,
  ) {
    final response = ExternalFunctionResponse.fromJson(message.data);
    final callId = response.callId;

    if (pendingExternalCalls.containsKey(callId)) {
      final completer = pendingExternalCalls.remove(callId)!;

      if (response.error != null) {
        completer.completeError(Exception(response.error));
      } else {
        completer.complete(response.result);
      }
    }
  }

  /// 添加内部函数（直接在isolate内部执行，不需要跨线程通信）
  static void _addInternalFunctions(Map<String, Function> functions) {
    // 数学函数 - 直接在isolate内部执行
    functions['sin'] = (num x) => math.sin(x.toDouble());
    functions['cos'] = (num x) => math.cos(x.toDouble());
    functions['tan'] = (num x) => math.tan(x.toDouble());
    functions['sqrt'] = (num x) => math.sqrt(x.toDouble());
    functions['pow'] = (num x, num y) => math.pow(x.toDouble(), y.toDouble());
    functions['abs'] = (num x) => x.abs();
    functions['random'] = () => math.Random().nextDouble();
    functions['min'] = (num a, num b) => math.min(a, b);
    functions['max'] = (num a, num b) => math.max(a, b);
    functions['floor'] = (num x) => x.floor();
    functions['ceil'] = (num x) => x.ceil();
    functions['round'] = (num x) => x.round();

    // 获取当前时间戳
    functions['now'] = () => DateTime.now().millisecondsSinceEpoch;

    // 延迟函数 - 返回 Future
    functions['delay'] = (int milliseconds) => Future.delayed(
      Duration(milliseconds: milliseconds < 0 ? 0 : milliseconds),
    );

    // 带返回值的延迟函数 - 返回 Future
    functions['delayThen'] = (int milliseconds, dynamic value) => Future.delayed(
      Duration(milliseconds: milliseconds < 0 ? 0 : milliseconds),
      () => value,
    );
  }
}
