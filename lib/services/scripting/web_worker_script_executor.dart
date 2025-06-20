import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'script_executor_base.dart';
import 'external_function_registry.dart';
import '../../models/script_data.dart';
import 'hetu_script_worker.dart';

/// Web Worker版本的脚本执行器
/// 使用 isolate_manager 在 Web 平台上实现真正的多线程脚本执行
class WebWorkerScriptExecutor implements IScriptExecutor {
  IsolateManager<String, String>? _isolateManager;
  final Map<String, Function> _externalFunctions = {};
  final List<String> _executionLogs = [];
  final StreamController<String> _logController =
      StreamController<String>.broadcast();

  bool _isInitialized = false;
  bool _isDisposed = false;

  /// 初始化 Web Worker
  Future<void> _ensureInitialized() async {
    if (_isInitialized || _isDisposed) return;

    try {
      _addLog('Creating isolate manager...');

      _isolateManager = IsolateManager.createCustom(
        hetuScriptWorkerFunction,
        workerName: 'hetuScriptWorkerFunction',
        concurrent: 1,
        isDebug: kDebugMode,
      );

      _addLog('Starting isolate manager...');
      await _isolateManager!.start();
      _isInitialized = true;
      _addLog('Isolate manager started successfully');

      // 监听日志
      _logController.stream.listen((log) {
        _executionLogs.add(log);
        if (kDebugMode) {
          print('[WebWorkerScriptExecutor] $log');
        }
      });
    } catch (e) {
      _addLog('Failed to initialize WebWorker: $e');
      rethrow;
    }
  }

  @override
  Future<ScriptExecutionResult> execute(
    String code, {
    Map<String, dynamic>? context,
    Duration? timeout,
  }) async {
    _addLog('Starting script execution...');
    await _ensureInitialized();

    if (_isDisposed || _isolateManager == null) {
      throw StateError('WebWorkerScriptExecutor has been disposed');
    }
    final requestData = {
      'type': 'execute',
      'code': code,
      'context': context ?? {},
      'externalFunctions':
          ExternalFunctionRegistry.getAllFunctionNamesWithInternal(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _addLog('Sending execute request to worker...');

    // 转换为 JSON 字符串
    final jsonRequest = jsonEncode(requestData);
    _addLog('Request JSON: $jsonRequest');

    try {
      final completer = Completer<ScriptExecutionResult>();
      Timer? timeoutTimer;

      // 设置超时
      if (timeout != null) {
        timeoutTimer = Timer(timeout, () {
          if (!completer.isCompleted) {
            _addLog('Script execution timeout');
            completer.completeError(
              TimeoutException('Script execution timeout', timeout),
            );
          }
        });
      } // 监听 isolate 消息流以处理外部函数调用
      late StreamSubscription subscription;
      subscription = _isolateManager!.stream.listen((jsonResponse) {
        try {
          _addLog('Raw JSON response: $jsonResponse');

          // 解析 JSON 响应
          final response = jsonDecode(jsonResponse) as Map<String, dynamic>;
          _addLog('Parsed response: $response');
          _addLog('Received response from worker: ${response['type']}');

          final responseType = response['type'] as String?;

          if (responseType == 'externalFunctionCall') {
            _addLog(
              'Processing external function call: ${response['functionName']}',
            );
            _addLog('Arguments type: ${response['arguments'].runtimeType}');
            _addLog('Arguments value: ${response['arguments']}');

            // 处理外部函数调用
            _handleExternalFunctionCall(response);
          } else if (!completer.isCompleted) {
            // 处理脚本执行结果
            timeoutTimer?.cancel();
            subscription.cancel();

            final result = _parseExecutionResult(response);
            completer.complete(result);
          }
        } catch (e, stackTrace) {
          _addLog('Error parsing JSON response: $e');
          _addLog('Stack trace: $stackTrace');
          if (!completer.isCompleted) {
            timeoutTimer?.cancel();
            subscription.cancel();
            completer.completeError(e);
          }
        }
      }); // 发送执行请求
      await _isolateManager!.sendMessage(jsonRequest);
      _addLog('Execute request sent to worker');

      return await completer.future;
    } catch (e) {
      _addLog('Script execution failed: $e');
      return ScriptExecutionResult(
        success: false,
        result: null,
        error: e.toString(),
        executionTime: Duration.zero,
      );
    }
  }

  /// 解析执行结果
  ScriptExecutionResult _parseExecutionResult(Map<String, dynamic> response) {
    // 安全地获取类型，处理可能的类型转换问题
    final type = _safeGetString(response, 'type');

    switch (type) {
      case 'result':
        _addLog('Script executed successfully');
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
        _addLog('Script execution error: $error');
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

  /// 安全地从 Map 中获取 String 值
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

  /// 安全地从 Map 中获取 int 值
  int _safeGetInt(
    Map<String, dynamic> map,
    String key, [
    int defaultValue = 0,
  ]) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return defaultValue;
  }

  /// 处理外部函数调用
  void _handleExternalFunctionCall(Map<String, dynamic> response) {
    final functionName = _safeGetString(response, 'functionName');
    final callId = _safeGetString(response, 'callId');

    if (functionName.isEmpty || callId.isEmpty) {
      _addLog('Invalid external function call: missing functionName or callId');
      return;
    }

    // 智能解析参数，支持多种格式
    List<dynamic> arguments;
    final rawArguments = response['arguments'];

    _addLog('Processing external function call: $functionName');
    _addLog('Raw arguments type: ${rawArguments.runtimeType}');
    _addLog('Raw arguments value: $rawArguments');

    if (rawArguments == null) {
      arguments = [];
    } else if (rawArguments is List) {
      // 如果已经是列表，直接使用
      arguments = rawArguments;
    } else if (rawArguments is String) {
      // 如果是字符串，尝试解析为JSON数组，失败则作为单个参数
      try {
        final decoded = jsonDecode(rawArguments);
        if (decoded is List) {
          arguments = decoded;
        } else {
          // 如果解析出来不是数组，作为单个参数
          arguments = [decoded];
        }
      } catch (e) {
        // JSON解析失败，直接作为单个字符串参数
        arguments = [rawArguments];
      }
    } else {
      // 其他类型，作为单个参数
      arguments = [rawArguments];
    }

    _addLog('Processed arguments: $arguments (${arguments.length} items)');

    try {
      final function = _externalFunctions[functionName];
      if (function == null) {
        throw Exception('External function not found: $functionName');
      }

      // 调用外部函数
      final result = Function.apply(function, arguments);
      _addLog('External function result: $result');

      // 发送结果回 Worker
      final responseData = {
        'type': 'externalFunctionResult',
        'callId': callId,
        'result': result,
      };

      _isolateManager!.sendMessage(jsonEncode(responseData));
    } catch (e) {
      _addLog('External function call failed: $e');
      // 发送错误回 Worker
      final errorData = {
        'type': 'externalFunctionError',
        'callId': callId,
        'error': e.toString(),
      };

      _isolateManager!.sendMessage(jsonEncode(errorData));
    }
  }

  @override
  void stop() {
    if (_isolateManager != null) {
      _isolateManager!.sendMessage(jsonEncode({'type': 'stop'}));
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _isolateManager?.stop();
    _isolateManager = null;
    _logController.close();
    _executionLogs.clear();
    _externalFunctions.clear();
  }

  @override
  void registerExternalFunction(String name, Function handler) {
    _externalFunctions[name] = handler;
    _addLog('Registered external function: $name');
  }

  @override
  void clearExternalFunctions() {
    _externalFunctions.clear();
    _addLog('Cleared all external functions');
  }

  @override
  void sendMapDataUpdate(Map<String, dynamic> data) {
    if (_isolateManager != null) {
      final updateData = {'type': 'mapDataUpdate', 'data': data};
      _addLog('Sending map data update: ${updateData.runtimeType}');
      _isolateManager!.sendMessage(jsonEncode(updateData));
    }
  }

  @override
  List<String> getExecutionLogs() {
    return List.from(_executionLogs);
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';
    _logController.add(logMessage);
  }
}
