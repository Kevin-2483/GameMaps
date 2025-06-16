import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../../models/script_data.dart';

/// 跨平台异步脚本执行器接口
abstract class IsolatedScriptExecutor {
  /// 执行脚本代码
  Future<ScriptExecutionResult> execute(
    String code, {
    Map<String, dynamic>? context,
    Duration? timeout,
  });

  /// 停止脚本执行
  void stop();

  /// 释放资源
  void dispose();

  /// 注册外部函数处理器
  void registerExternalFunction(String name, Function handler);

  /// 清空所有外部函数处理器
  void clearExternalFunctions();

  /// 发送地图数据更新
  void sendMapDataUpdate(Map<String, dynamic> data);

  /// 获取执行日志
  List<String> getExecutionLogs();
}

/// 脚本执行消息类型
enum ScriptMessageType {
  execute,
  result,
  error,
  log,
  stop,
  mapDataUpdate,
  externalFunctionCall,
}

/// 脚本执行消息
class ScriptMessage {
  final ScriptMessageType type;
  final Map<String, dynamic> data;

  const ScriptMessage({required this.type, required this.data});

  Map<String, dynamic> toJson() => {'type': type.name, 'data': data};

  factory ScriptMessage.fromJson(Map<String, dynamic> json) {
    return ScriptMessage(
      type: ScriptMessageType.values.firstWhere((e) => e.name == json['type']),
      data: Map<String, dynamic>.from(json['data']),
    );
  }
}

/// 外部函数调用请求
class ExternalFunctionCall {
  final String functionName;
  final List<dynamic> arguments;
  final String callId;

  const ExternalFunctionCall({
    required this.functionName,
    required this.arguments,
    required this.callId,
  });

  Map<String, dynamic> toJson() => {
    'functionName': functionName,
    'arguments': arguments,
    'callId': callId,
  };

  factory ExternalFunctionCall.fromJson(Map<String, dynamic> json) {
    return ExternalFunctionCall(
      functionName: json['functionName'],
      arguments: List.from(json['arguments']),
      callId: json['callId'],
    );
  }
}

/// 外部函数调用响应
class ExternalFunctionResponse {
  final String callId;
  final dynamic result;
  final String? error;

  const ExternalFunctionResponse({
    required this.callId,
    this.result,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'callId': callId,
    'result': result,
    'error': error,
  };

  factory ExternalFunctionResponse.fromJson(Map<String, dynamic> json) {
    return ExternalFunctionResponse(
      callId: json['callId'],
      result: json['result'],
      error: json['error'],
    );
  }
}

/// 桌面平台隔离执行器（使用 dart:isolate）
class IsolateScriptExecutor implements IsolatedScriptExecutor {
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  ReceivePort? _receivePort;

  final List<String> _executionLogs = [];
  final Map<String, Function> _externalFunctionHandlers = {};

  Completer<ScriptExecutionResult>? _currentExecution;
  Timer? _timeoutTimer;

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

    // 监听隔离消息
    _receivePort!.listen(_handleIsolateMessage);

    // 等待隔离准备就绪
    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = _receivePort!.listen((data) {
      if (data is Map && data['type'] == 'ready') {
        _isolateSendPort = data['sendPort'];
        completer.complete();
        subscription.cancel();
      }
    });

    await completer.future;
  }

  /// 处理隔离消息
  void _handleIsolateMessage(dynamic data) {
    try {
      final message = ScriptMessage.fromJson(data);

      switch (message.type) {
        case ScriptMessageType.result:
          final success = message.data['success'] as bool;
          final error = message.data['error'] as String?;
          final result = message.data['result'];
          final executionTimeMs = message.data['executionTimeMs'] as int?;

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
    // 在隔离中执行脚本代码
    // 暂时返回一个占位符结果
    return 'Script executed in isolate: ${code.length} characters';
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
