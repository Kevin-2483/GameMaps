import 'dart:async';
import 'dart:convert';
import 'package:hetu_script/hetu_script.dart';
import 'package:isolate_manager/isolate_manager.dart';

/// Web Worker 入口函数
/// 这个函数将在 Web Worker 中运行
/// 不能依赖任何 Flutter 特定的包，因为它会在独立的 Web Worker 环境中执行
/// 使用自定义 Worker 注解，因为需要手动控制生命周期和复杂的消息处理
@pragma('vm:entry-point')
@isolateManagerCustomWorker
void hetuScriptWorkerFunction(dynamic params) {
  IsolateManagerFunction.customFunction<String, String>(
    params,
    onInit: (controller) async {
      // 初始化 Hetu 脚本引擎
      await _initializeHetuEngine(controller);
    },
    onEvent: (controller, jsonMessage) async {
      return await _handleWorkerMessage(controller, jsonMessage);
    },
    onDispose: (controller) {
      // 清理资源
      _disposeHetuEngine();
    },
  );
}

// Worker 内部的全局变量
Hetu? _hetuEngine;
Map<String, dynamic> _currentMapData = {};
final Map<String, Completer<dynamic>> _externalFunctionCalls = {};
final List<String> _workerLogs = [];

/// 初始化 Hetu 脚本引擎
Future<void> _initializeHetuEngine(IsolateManagerController controller) async {
  try {
    _hetuEngine = Hetu();
    _hetuEngine!.init();
    _addWorkerLog('Hetu script engine initialized successfully');

    // 发送初始化完成信号 - 使用 JSON 字符串
    // controller.sendResult(jsonEncode({
    //   'type': 'initialized',
    //   'message': 'Hetu engine ready',
    // }));
  } catch (e) {
    _addWorkerLog('Failed to initialize Hetu engine: $e');

    // 发送初始化失败信号 - 使用 JSON 字符串
    // controller.sendResult(jsonEncode({'type': 'initError', 'error': e.toString()}));

    rethrow;
  }
}

/// 处理来自主线程的消息
Future<String> _handleWorkerMessage(
  IsolateManagerController controller,
  String jsonMessage,
) async {
  _addWorkerLog('Received JSON message: $jsonMessage');

  try {
    // 解析 JSON 消息
    final message = jsonDecode(jsonMessage) as Map<String, dynamic>;
    final type = message['type'] as String? ?? 'unknown';
    final startTime = DateTime.now();

    _addWorkerLog('Received message type: $type');

    Map<String, dynamic> result;

    switch (type) {
      case 'execute':
        _addWorkerLog('Processing execute request...');
        result = await _executeScript(controller, message, startTime);
        break;

      case 'mapDataUpdate':
        _currentMapData = message['data'] as Map<String, dynamic>? ?? {};
        _addWorkerLog('Map data updated');
        result = {'type': 'ack', 'message': 'Map data updated'};
        break;

      case 'stop':
        _addWorkerLog('Received stop signal');
        result = {'type': 'stopped'};
        break;

      case 'externalFunctionResult':
        result = _handleExternalFunctionResult(message);
        break;

      case 'externalFunctionError':
        result = _handleExternalFunctionError(message);
        break;

      default:
        _addWorkerLog('Unknown message type: $type');
        result = {'type': 'error', 'error': 'Unknown message type: $type'};
    }

    return jsonEncode(result);
  } catch (e, stackTrace) {
    _addWorkerLog('Error handling message: $e');
    _addWorkerLog('Stack trace: $stackTrace');

    final errorResult = {
      'type': 'error',
      'error': e.toString(),
      'executionTime': DateTime.now().millisecondsSinceEpoch,
    };

    return jsonEncode(errorResult);
  }
}

/// 执行脚本
Future<Map<String, dynamic>> _executeScript(
  IsolateManagerController controller,
  Map<String, dynamic> message,
  DateTime startTime,
) async {
  final code = message['code'] as String? ?? '';
  final context = message['context'] as Map<String, dynamic>? ?? {};
  final executionId = message['executionId'] as String? ?? '';

  // 安全地转换外部函数列表
  final externalFunctionsObj = message['externalFunctions'];
  final externalFunctions = <String>[];

  if (externalFunctionsObj is List) {
    for (final item in externalFunctionsObj) {
      if (item is String) {
        externalFunctions.add(item);
      } else if (item != null) {
        externalFunctions.add(item.toString());
      }
    }
  }

  try {
    if (_hetuEngine == null) {
      throw Exception('Hetu engine not initialized');
    }

    // 设置上下文变量
    for (final entry in context.entries) {
      _hetuEngine!.define(entry.key, entry.value);
    } // 设置地图数据
    _hetuEngine!.define('mapData', _currentMapData);

    // 注册外部函数代理
    for (final functionName in externalFunctions) {
      _hetuEngine!.interpreter.bindExternalFunction(functionName, (
        List<dynamic> positionalArgs, {
        Map<String, dynamic> namedArgs = const {},
        List<HTType> typeArgs = const [],
      }) async {
        return await _callExternalFunction(
          controller,
          functionName,
          positionalArgs,
          executionId, // 传递executionId
        );
      });
    }

    // 发送脚本已开始执行的信号
    _addWorkerLog('Sending started signal for execution: $executionId');
    final startedSignal = {'type': 'started', 'executionId': executionId};
    controller.sendResult(jsonEncode(startedSignal));
    _addWorkerLog('Started signal sent for execution: $executionId');

    // 执行脚本
    final result = _hetuEngine!.eval(code);
    final executionTime = DateTime.now().difference(startTime).inMilliseconds;

    _addWorkerLog('Script executed successfully in ${executionTime}ms');

    return {
      'type': 'result',
      'result': _serializeResult(result),
      'executionTime': executionTime,
    };
  } catch (e) {
    final executionTime = DateTime.now().difference(startTime).inMilliseconds;
    _addWorkerLog('Script execution failed: $e');

    return {
      'type': 'error',
      'error': e.toString(),
      'executionTime': executionTime,
    };
  }
}

/// 调用外部函数
Future<dynamic> _callExternalFunction(
  IsolateManagerController controller,
  String functionName,
  List<dynamic> arguments,
  String executionId,
) async {
  final callId = DateTime.now().millisecondsSinceEpoch.toString();
  final completer = Completer<dynamic>();

  _externalFunctionCalls[callId] = completer;

  _addWorkerLog('Calling external function: $functionName');
  _addWorkerLog('Arguments type: ${arguments.runtimeType}');
  _addWorkerLog('Arguments value: $arguments');

  // 处理参数 - 如果只有一个参数且为简单类型，直接发送该值
  dynamic argumentsToSend;
  if (arguments.length == 1) {
    final arg = arguments.first;
    // 对于简单类型（字符串、数字、布尔值），直接发送值
    if (arg is String || arg is num || arg is bool || arg == null) {
      argumentsToSend = arg;
    } else {
      argumentsToSend = arguments;
    }
  } else {
    argumentsToSend = arguments;
  }

  // 发送外部函数调用请求到主线程 - 使用 JSON 字符串
  final requestData = {
    'type': 'externalFunctionCall',
    'functionName': functionName,
    'arguments': argumentsToSend,
    'callId': callId,
    'executionId': executionId, // 添加executionId
  };

  final jsonRequest = jsonEncode(requestData);
  _addWorkerLog('Sending JSON request: $jsonRequest');

  controller.sendResult(jsonRequest);

  // 等待结果，设置超时以防止死锁
  try {
    return await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException(
        'External function call timeout: $functionName',
      ),
    );
  } finally {
    _externalFunctionCalls.remove(callId);
  }
}

/// 处理外部函数调用结果
Map<String, dynamic> _handleExternalFunctionResult(
  Map<String, dynamic> message,
) {
  final callId = message['callId'] as String? ?? '';
  final result = message['result'];

  final completer = _externalFunctionCalls.remove(callId);
  if (completer != null && !completer.isCompleted) {
    completer.complete(result);
  }

  return {'type': 'ack', 'message': 'External function result processed'};
}

/// 处理外部函数调用错误
Map<String, dynamic> _handleExternalFunctionError(
  Map<String, dynamic> message,
) {
  final callId = message['callId'] as String? ?? '';
  final error = message['error'] as String? ?? 'Unknown error';

  final completer = _externalFunctionCalls.remove(callId);
  if (completer != null && !completer.isCompleted) {
    completer.completeError(Exception(error));
  }

  return {'type': 'ack', 'message': 'External function error processed'};
}

/// 序列化执行结果
dynamic _serializeResult(dynamic result) {
  try {
    // 尝试 JSON 序列化以确保可以传输
    json.encode(result);
    return result;
  } catch (e) {
    // 如果无法序列化，返回字符串表示
    return result.toString();
  }
}

/// 添加 Worker 日志
void _addWorkerLog(String message) {
  final timestamp = DateTime.now().toIso8601String();
  final logMessage = '[$timestamp] [Worker] $message';
  _workerLogs.add(logMessage);

  // 保持日志数量在合理范围内
  if (_workerLogs.length > 100) {
    _workerLogs.removeAt(0);
  }

  // 在 Web 环境中输出到浏览器控制台
  print(logMessage);
}

/// 清理 Hetu 引擎
void _disposeHetuEngine() {
  _hetuEngine = null;
  _currentMapData.clear();
  _externalFunctionCalls.clear();
  _workerLogs.clear();
  _addWorkerLog('Hetu engine disposed');
}
