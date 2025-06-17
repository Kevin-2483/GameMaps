import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:hetu_script/hetu_script.dart';
import '../../models/script_data.dart';
import 'isolated_script_executor.dart';

/// 支持并发的Isolate脚本执行器
/// 基于现有的IsolateScriptExecutor，但支持真正的多任务并发执行
class ConcurrentIsolateScriptExecutor implements IsolatedScriptExecutor {
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
    final executionId = DateTime.now().millisecondsSinceEpoch.toString() + 
        '_' + math.Random().nextInt(1000).toString();

    final completer = Completer<ScriptExecutionResult>();
    _pendingExecutions[executionId] = completer;

    try {
      // 启动隔离（如果尚未启动）
      await _ensureIsolateStarted();

      // 设置超时
      if (timeout != null) {
        _timeoutTimers[executionId] = Timer(timeout, () {
          if (!completer.isCompleted) {
            _pendingExecutions.remove(executionId);
            _timeoutTimers.remove(executionId);
            completer.complete(
              ScriptExecutionResult(
                success: false,
                error: 'Script execution timeout after ${timeout.inSeconds} seconds',
                executionTime: timeout,
              ),
            );
          }
        });
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
      _isolate = await Isolate.spawn(_isolateEntryPoint, _receivePort!.sendPort);      // 等待隔离准备就绪
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
    if (data is! Map<String, dynamic>) return;    try {
      debugPrint('DEBUG: Received message: ${data.toString()}');
      final message = ScriptMessage.fromJson(data);
      final executionId = message.data['executionId'] as String?;
      debugPrint('DEBUG: Message type: ${message.type}, executionId: $executionId');

      switch (message.type) {
        case ScriptMessageType.started:
          // 脚本已开始执行，取消超时定时器
          debugPrint('DEBUG: Processing started message for execution: $executionId');
          if (executionId != null && _timeoutTimers.containsKey(executionId)) {
            _timeoutTimers[executionId]?.cancel();
            _timeoutTimers.remove(executionId);
            debugPrint('Script started, timeout timer cancelled for execution: $executionId');
          } else {
            debugPrint('DEBUG: No timeout timer found for execution: $executionId, available timers: ${_timeoutTimers.keys}');
          }
          break;

        case ScriptMessageType.result:
          if (executionId != null && _pendingExecutions.containsKey(executionId)) {
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
          if (executionId != null && _pendingExecutions.containsKey(executionId)) {
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
          break;

        case ScriptMessageType.externalFunctionCall:
          _handleExternalFunctionCall(message);
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
    mainSendPort.send({
      'type': 'ready',
      'sendPort': receivePort.sendPort,
    });

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
        },      );
      mainSendPort.send(responseMessage.toJson());
    }

    try {
      final code = message.data['code'] as String;
      final context = message.data['context'] as Map<String, dynamic>? ?? {};

      // 创建Hetu脚本解释器
      final hetu = Hetu();

      // 准备外部函数映射
      final externalFunctions = <String, Function>{};

      // 注册所有外部函数（基于现有的IsolateScriptExecutor实现）
      _registerAllExternalFunctions(externalFunctions, mainSendPort, pendingExternalCalls);

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
        result.then((actualResult) {
          sendResult(true, result: actualResult);
        }).catchError((e) {
          sendResult(false, error: e.toString());
        });
      } else {
        sendResult(true, result: result);
      }

    } catch (e) {
      sendResult(false, error: e.toString());
    }
  }

  /// 注册所有外部函数
  static void _registerAllExternalFunctions(
    Map<String, Function> functions,
    SendPort mainSendPort,
    Map<String, Completer<dynamic>> pendingExternalCalls,
  ) {
    // 日志函数
    functions['log'] = (dynamic message) async {
      return await _callExternalFunction('log', [message], mainSendPort, pendingExternalCalls);
    };

    functions['print'] = (dynamic message) async {
      return await _callExternalFunction('print', [message], mainSendPort, pendingExternalCalls);
    };

    // 数学函数
    functions['sin'] = (num x) async {
      return await _callExternalFunction('sin', [x], mainSendPort, pendingExternalCalls);
    };

    functions['cos'] = (num x) async {
      return await _callExternalFunction('cos', [x], mainSendPort, pendingExternalCalls);
    };

    functions['tan'] = (num x) async {
      return await _callExternalFunction('tan', [x], mainSendPort, pendingExternalCalls);
    };

    functions['sqrt'] = (num x) async {
      return await _callExternalFunction('sqrt', [x], mainSendPort, pendingExternalCalls);
    };

    functions['pow'] = (num x, num y) async {
      return await _callExternalFunction('pow', [x, y], mainSendPort, pendingExternalCalls);
    };

    functions['abs'] = (num x) async {
      return await _callExternalFunction('abs', [x], mainSendPort, pendingExternalCalls);
    };

    functions['random'] = () async {
      return await _callExternalFunction('random', [], mainSendPort, pendingExternalCalls);
    };

    // 地图数据访问函数
    functions['getLayers'] = () async {
      return await _callExternalFunction('getLayers', [], mainSendPort, pendingExternalCalls);
    };

    functions['getLayerById'] = (String id) async {
      return await _callExternalFunction('getLayerById', [id], mainSendPort, pendingExternalCalls);
    };

    functions['getAllElements'] = () async {
      return await _callExternalFunction('getAllElements', [], mainSendPort, pendingExternalCalls);
    };

    functions['countElements'] = ([String? type]) async {
      return await _callExternalFunction('countElements', [type], mainSendPort, pendingExternalCalls);
    };

    functions['calculateTotalArea'] = () async {
      return await _callExternalFunction('calculateTotalArea', [], mainSendPort, pendingExternalCalls);
    };

    // 文件操作函数
    functions['readjson'] = (String filename) async {
      return await _callExternalFunction('readjson', [filename], mainSendPort, pendingExternalCalls);
    };

    functions['writetext'] = (String filename, String content) async {
      return await _callExternalFunction('writetext', [filename, content], mainSendPort, pendingExternalCalls);
    };

    // 便签相关函数
    functions['getStickyNotes'] = () async {
      return await _callExternalFunction('getStickyNotes', [], mainSendPort, pendingExternalCalls);
    };

    functions['getStickyNoteById'] = (String id) async {
      return await _callExternalFunction('getStickyNoteById', [id], mainSendPort, pendingExternalCalls);
    };

    // 图例相关函数
    functions['getLegendGroups'] = () async {
      return await _callExternalFunction('getLegendGroups', [], mainSendPort, pendingExternalCalls);
    };

    functions['getLegendGroupById'] = (String id) async {
      return await _callExternalFunction('getLegendGroupById', [id], mainSendPort, pendingExternalCalls);
    };
  }

  /// 调用外部函数（通过消息传递与主线程通信）
  static Future<dynamic> _callExternalFunction(
    String functionName,
    List<dynamic> arguments,
    SendPort mainSendPort,
    Map<String, Completer<dynamic>> pendingExternalCalls,
  ) async {
    final callId = DateTime.now().millisecondsSinceEpoch.toString() +
        '_' + math.Random().nextInt(1000).toString();

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
}
