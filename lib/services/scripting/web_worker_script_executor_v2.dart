import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'isolated_script_executor.dart';
import '../../models/script_data.dart';
import 'hetu_script_worker.dart';

/// Web Worker版本的脚本执行器
/// 使用 isolate_manager 在 Web 平台上实现真正的多线程脚本执行
class WebWorkerScriptExecutor implements IsolatedScriptExecutor {
  IsolateManager<Map<String, dynamic>, Map<String, dynamic>>? _isolateManager;
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
        workerName: 'hetu_script_worker',
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
      'externalFunctions': _externalFunctions.keys.toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _addLog('Sending execute request to worker...');

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
      }

      // 监听 isolate 消息流以处理外部函数调用
      late StreamSubscription subscription;
      subscription = _isolateManager!.stream.listen((response) {
        _addLog('Received response from worker: ${response['type']}');
        
        final responseType = response['type'] as String?;
        
        if (responseType == 'externalFunctionCall') {
          // 处理外部函数调用
          _handleExternalFunctionCall(response);
        } else if (!completer.isCompleted) {
          // 处理脚本执行结果
          timeoutTimer?.cancel();
          subscription.cancel();
          
          final result = _parseExecutionResult(response);
          completer.complete(result);
        }
      });

      // 发送执行请求
      await _isolateManager!.sendMessage(requestData);
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
    final type = response['type'] as String?;

    switch (type) {
      case 'result':
        _addLog('Script executed successfully');
        return ScriptExecutionResult(
          success: true,
          result: response['result'],
          error: null,
          executionTime: Duration(milliseconds: response['executionTime'] ?? 0),
        );

      case 'error':
        final error = response['error'] as String;
        _addLog('Script execution error: $error');
        return ScriptExecutionResult(
          success: false,
          result: null,
          error: error,
          executionTime: Duration(milliseconds: response['executionTime'] ?? 0),
        );

      default:
        throw Exception('Unknown response type: $type');
    }
  }
  /// 处理外部函数调用
  void _handleExternalFunctionCall(
    Map<String, dynamic> response,
  ) {
    final functionName = response['functionName'] as String;
    final arguments = response['arguments'] as List<dynamic>;
    final callId = response['callId'] as String;

    try {
      final function = _externalFunctions[functionName];
      if (function == null) {
        throw Exception('External function not found: $functionName');
      }

      // 调用外部函数
      final result = Function.apply(function, arguments);

      // 发送结果回 Worker
      final responseData = {
        'type': 'externalFunctionResult',
        'callId': callId,
        'result': result,
      };

      _isolateManager!.sendMessage(responseData);
    } catch (e) {
      // 发送错误回 Worker
      final errorData = {
        'type': 'externalFunctionError',
        'callId': callId,
        'error': e.toString(),
      };

      _isolateManager!.sendMessage(errorData);
    }
  }

  @override
  void stop() {
    if (_isolateManager != null) {
      _isolateManager!.sendMessage({'type': 'stop'});
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
      _isolateManager!.sendMessage({'type': 'mapDataUpdate', 'data': data});
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
