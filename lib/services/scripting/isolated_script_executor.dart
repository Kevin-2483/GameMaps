import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:hetu_script/hetu_script.dart';
import '../../models/script_data.dart';
import 'script_executor_base.dart';
import 'external_function_registry.dart';

/// 桌面平台隔离执行器（使用 dart:isolate）
class IsolateScriptExecutor implements IScriptExecutor {
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  ReceivePort? _receivePort;
  Timer? _timeoutTimer;

  final List<String> _executionLogs = [];
  final Map<String, Function> _externalFunctionHandlers = {};

  Completer<ScriptExecutionResult>? _currentExecution;

  @override
  Future<ScriptExecutionResult> execute(
    String code, {
    Map<String, dynamic>? context,
    Duration? timeout,
  }) async {
    if (_currentExecution != null && !_currentExecution!.isCompleted) {
      throw Exception('Script is already running');
    }

    _currentExecution = Completer<ScriptExecutionResult>();
    _executionLogs.clear();

    try {
      // 启动隔离
      await _startIsolate();

      // 设置超时
      if (timeout != null) {
        _timeoutTimer = Timer(timeout, () {
          if (!_currentExecution!.isCompleted) {
            _currentExecution!.complete(
              ScriptExecutionResult(
                success: false,
                error: 'Script execution timeout',
                executionTime: timeout,
              ),
            );
          }
        });
      }

      // 发送执行消息
      final message = ScriptMessage(
        type: ScriptMessageType.execute,
        data: {'code': code, 'context': context ?? {}},
      );

      _isolateSendPort!.send(message.toJson());
      return await _currentExecution!.future;
    } catch (e) {
      return ScriptExecutionResult(
        success: false,
        error: e.toString(),
        executionTime: Duration.zero,
      );
    } finally {
      _timeoutTimer?.cancel();
      _timeoutTimer = null;
    }
  }

  /// 启动隔离
  Future<void> _startIsolate() async {
    if (_isolate != null) return;

    _receivePort = ReceivePort();

    _isolate = await Isolate.spawn(_isolateEntryPoint, _receivePort!.sendPort);

    // 等待隔离准备就绪
    final completer = Completer<void>();

    // 使用单一监听器处理所有消息
    _receivePort!.listen((data) {
      if (data is Map && data['type'] == 'ready' && !completer.isCompleted) {
        _isolateSendPort = data['sendPort'];
        completer.complete();
      } else {
        // 处理所有其他消息（包括ready之后的正常消息）
        _handleIsolateMessage(data);
      }
    });

    await completer.future;
  }

  /// 处理隔离消息
  void _handleIsolateMessage(dynamic data) {
    try {
      final message = ScriptMessage.fromJson(data);

      switch (message.type) {
        case ScriptMessageType.started:
          // 脚本开始执行时取消超时计时器
          _timeoutTimer?.cancel();
          _timeoutTimer = null;
          debugPrint('SUCCESS: Timeout timer cancelled - script started');
          break;

        case ScriptMessageType.result:
          final success = message.data['success'] as bool;
          final error = message.data['error'] as String?;
          final result = message.data['result'];
          final executionTimeMs = message.data['executionTimeMs'] as int?;

          // 取消计时器（如果还在运行）
          _timeoutTimer?.cancel();
          _timeoutTimer = null;

          if (_currentExecution != null && !_currentExecution!.isCompleted) {
            _currentExecution!.complete(
              ScriptExecutionResult(
                success: success,
                error: error,
                result: result,
                executionTime: Duration(milliseconds: executionTimeMs ?? 0),
              ),
            );
          }
          break;

        case ScriptMessageType.log:
          final logMessage = message.data['message'] as String;
          _executionLogs.add(logMessage);
          debugPrint('[Script] $logMessage');
          break;

        case ScriptMessageType.externalFunctionCall:
          _handleExternalFunctionCall(message.data);
          break;

        default:
          break;
      }
    } catch (e) {
      debugPrint('Error handling isolate message: $e');
    }
  }

  /// 处理外部函数调用
  void _handleExternalFunctionCall(Map<String, dynamic> data) async {
    final call = ExternalFunctionCall.fromJson(data);

    try {
      final handler = _externalFunctionHandlers[call.functionName];
      if (handler == null) {
        throw Exception('External function not found: ${call.functionName}');
      }

      final result = await Function.apply(handler, call.arguments);

      final response = ExternalFunctionResponse(
        callId: call.callId,
        result: result,
      );

      final message = ScriptMessage(
        type: ScriptMessageType.externalFunctionCall,
        data: response.toJson(),
      );

      _isolateSendPort?.send(message.toJson());
    } catch (e) {
      final response = ExternalFunctionResponse(
        callId: call.callId,
        error: e.toString(),
      );

      final message = ScriptMessage(
        type: ScriptMessageType.externalFunctionCall,
        data: response.toJson(),
      );

      _isolateSendPort?.send(message.toJson());
    }
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

  @override
  void stop() {
    if (_isolateSendPort != null) {
      final message = ScriptMessage(type: ScriptMessageType.stop, data: {});
      _isolateSendPort!.send(message.toJson());
    }

    if (_currentExecution != null && !_currentExecution!.isCompleted) {
      _currentExecution!.complete(
        ScriptExecutionResult(
          success: false,
          error: 'Script execution stopped',
          executionTime: Duration.zero,
        ),
      );
    }

    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  @override
  void dispose() {
    stop();
    _isolate?.kill();
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _isolateSendPort = null;
    _externalFunctionHandlers.clear();
  }

  /// 隔离入口点
  static void _isolateEntryPoint(SendPort mainSendPort) {
    final receivePort = ReceivePort();

    // 发送准备就绪消息
    mainSendPort.send({'type': 'ready', 'sendPort': receivePort.sendPort});

    final executor = _IsolateScriptRunner(mainSendPort);

    receivePort.listen((data) {
      executor.handleMessage(data);
    });
  }
}

/// 隔离内部的脚本运行器
class _IsolateScriptRunner {
  final SendPort _mainSendPort;
  final Map<String, Completer<dynamic>> _pendingExternalCalls = {};
  _IsolateScriptRunner(this._mainSendPort);

  void handleMessage(dynamic data) async {
    try {
      final message = ScriptMessage.fromJson(data);
      switch (message.type) {
        case ScriptMessageType.execute:
          await _executeScript(message.data);
          break;

        case ScriptMessageType.stop:
          // 处理停止信号
          break;

        case ScriptMessageType.externalFunctionCall:
          _handleExternalFunctionResponse(message.data);
          break;

        case ScriptMessageType.mapDataUpdate:
          // 更新隔离内的地图数据缓存
          break;

        default:
          break;
      }
    } catch (e) {
      _sendError('Message handling error: $e');
    }
  }

  Future<void> _executeScript(Map<String, dynamic> data) async {
    final stopwatch = Stopwatch()..start();

    try {
      final code = data['code'] as String;
      final context = data['context'] as Map<String, dynamic>?;

      // 在隔离内执行脚本
      final result = await _runScriptInIsolate(code, context);

      stopwatch.stop();

      _sendResult(
        ScriptExecutionResult(
          success: true,
          result: result,
          executionTime: stopwatch.elapsed,
        ),
      );
    } catch (e) {
      stopwatch.stop();

      _sendResult(
        ScriptExecutionResult(
          success: false,
          error: e.toString(),
          executionTime: stopwatch.elapsed,
        ),
      );
    }
  }

  Future<dynamic> _runScriptInIsolate(
    String code,
    Map<String, dynamic>? context,
  ) async {
    try {
      // 创建Hetu脚本解释器
      final hetu = Hetu();

      // 使用统一的外部函数注册器
      final externalFunctions =
          ExternalFunctionRegistry.createFunctionsForIsolate(
            (functionName, arguments) =>
                _callExternalFunction(functionName, arguments),
          );

      // 初始化Hetu解释器
      hetu.init(externalFunctions: externalFunctions);

      // 设置初始上下文
      if (context != null) {
        for (final entry in context.entries) {
          hetu.assign(entry.key, entry.value);
        }
      }

      // 发送脚本已开始执行的消息
      debugPrint('DEBUG: Sending started message');
      final startedMessage = ScriptMessage(
        type: ScriptMessageType.started,
        data: {'executionId': null},
      );
      _mainSendPort.send(startedMessage.toJson());
      debugPrint('DEBUG: Started message sent');

      // 执行脚本（Hetu支持异步外部函数）
      final result = await hetu.eval(code);
      return result;
    } catch (e) {
      throw Exception('Script execution failed: $e');
    }
  }

  /// 调用外部函数（通过消息传递与主线程通信）
  Future<dynamic> _callExternalFunction(
    String functionName,
    List<dynamic> arguments,
  ) async {
    final callId = ExternalFunctionRegistry.generateCallId();

    final call = ExternalFunctionCall(
      functionName: functionName,
      arguments: arguments,
      callId: callId,
    );

    // 创建 Completer 等待响应
    final completer = Completer<dynamic>();
    _pendingExternalCalls[callId] = completer;

    // 发送函数调用消息到主线程
    final message = ScriptMessage(
      type: ScriptMessageType.externalFunctionCall,
      data: call.toJson(),
    );

    _mainSendPort.send(message.toJson());

    // 等待主线程响应（最多10秒超时）
    try {
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _pendingExternalCalls.remove(callId);
          throw TimeoutException(
            'External function call timeout: $functionName',
            const Duration(seconds: 10),
          );
        },
      );
    } catch (e) {
      _pendingExternalCalls.remove(callId);
      rethrow;
    }
  }

  void _handleExternalFunctionResponse(Map<String, dynamic> data) {
    final response = ExternalFunctionResponse.fromJson(data);
    final completer = _pendingExternalCalls.remove(response.callId);

    if (completer != null && !completer.isCompleted) {
      if (response.error != null) {
        completer.completeError(Exception(response.error));
      } else {
        completer.complete(response.result);
      }
    }
  }

  void _sendResult(ScriptExecutionResult result) {
    final message = ScriptMessage(
      type: ScriptMessageType.result,
      data: {
        'success': result.success,
        'error': result.error,
        'result': result.result,
        'executionTimeMs': result.executionTime.inMilliseconds,
      },
    );

    _mainSendPort.send(message.toJson());
  }

  void _sendError(String error) {
    final result = ScriptExecutionResult(
      success: false,
      error: error,
      executionTime: Duration.zero,
    );
    _sendResult(result);
  }
}
