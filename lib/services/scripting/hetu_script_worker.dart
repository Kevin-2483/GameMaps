import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math' as math;
import 'package:hetu_script/hetu_script.dart';
import 'package:hetu_script/values.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'package:web/web.dart' show MessageEvent;

/// Web Worker 入口函数
/// 使用 setRawMessageHandler 进行消息处理，避免复杂的 JS 互操作
@pragma('vm:entry-point')
@isolateManagerCustomWorker
void hetuScriptWorkerFunction(dynamic params) {
  IsolateManagerFunction.customFunction<String, String>(
    params,
    autoHandleResult: false,
    onInit: (controller) async {
      // 使用 setRawMessageHandler 来处理原始消息
      controller.setRawMessageHandler((event) {
        try {
          // 提取消息数据 - isolate_manager发送的是字符串
          dynamic rawData;
          try {
            // 使用 JS interop 安全访问 MessageEvent.data
            if (event is MessageEvent) {
              rawData = event.data.dartify();
            } else {
              // 回退方案：直接使用反射访问 data 属性
              try {
                rawData = (event as dynamic).data;
                if (rawData != null && rawData.dartify != null) {
                  rawData = rawData.dartify();
                }
              } catch (e2) {
                _addWorkerLog('回退方案也失败: $e2');
                return false;
              }
            }

            // isolate_manager发送的消息总是字符串，我们需要处理这种情况
            if (rawData is String) {
              _addWorkerLog(
                '收到字符串消息，尝试JSON解析: ${rawData.length > 200 ? rawData.substring(0, 200) + '...' : rawData}',
              );
            } else {
              _addWorkerLog('收到非字符串消息: ${rawData.runtimeType}');
            }
          } catch (e) {
            _addWorkerLog('无法访问event.data: $e');
            return false;
          }
          var data = rawData;

          // isolate_manager总是发送字符串，我们需要解析JSON
          if (data is String) {
            try {
              data = json.decode(data);
              _addWorkerLog('JSON解析成功，数据类型: ${data.runtimeType}');
            } catch (e) {
              _addWorkerLog(
                'JSON解析失败: $e, 原始数据: ${data.length > 100 ? data.substring(0, 100) + '...' : data}',
              );
              // 如果解析失败，发送错误消息
              _sendCustomErrorMessage(controller, 'unknown', 'JSON解析失败: $e');
              return false;
            }
          }

          _addWorkerLog('处理数据类型: ${data.runtimeType}');

          if (data is Map) {
            final dataMap = Map<String, dynamic>.from(data);
            final executionId = dataMap['executionId'] as String? ?? 'unknown';
            final messageType = dataMap['type'] as String? ?? 'unknown';
            _addWorkerLog('处理任务ID: $executionId, 消息类型: $messageType');

            // 异步处理消息
            Future(() async {
              await _handleCustomMessage(controller, dataMap, executionId);
            }).catchError((e) {
              _addWorkerLog('异步消息处理错误: $e');
              _sendCustomErrorMessage(controller, executionId, '异步消息处理错误: $e');
            });
          } else {
            _addWorkerLog('JSON解析后仍非Map类型: ${data.runtimeType}, 内容: $data');
            _sendCustomErrorMessage(
              controller,
              'unknown',
              '消息格式错误: 期望Map类型，实际: ${data.runtimeType}',
            );
          }
        } catch (e, stackTrace) {
          _addWorkerLog('原始消息处理错误: $e');
          _addWorkerLog('错误堆栈: $stackTrace');
          _sendCustomErrorMessage(controller, 'unknown', '原始消息处理错误: $e');
        }

        return false; // 阻止进一步的默认处理
      });

      // 初始化 Hetu 脚本引擎
      await _initializeHetuEngine(controller);
    },
    onEvent: (controller, message) async {
      // 这个不会被调用，因为我们重写了 onmessage
      _addWorkerLog('备用onEvent被调用: $message');
      return "fallback";
    },
    onDispose: (controller) {
      // 清理资源
      _disposeHetuEngine(controller);
    },
  );
}

// Worker 内部的全局变量
Hetu? _hetuEngine;
Map<String, dynamic> _currentMapData = {};
final Map<String, Completer<dynamic>> _externalFunctionCalls = {};
final List<String> _workerLogs = [];

// Worker内部函数实现（不需要跨线程通信）
final Map<String, Function> _internalFunctions = {
  // 数学函数 - 直接在Worker内部执行
  'sin': (num x) => math.sin(x.toDouble()),
  'cos': (num x) => math.cos(x.toDouble()),
  'tan': (num x) => math.tan(x.toDouble()),
  'sqrt': (num x) => math.sqrt(x.toDouble()),
  'pow': (num x, num y) => math.pow(x.toDouble(), y.toDouble()),
  'abs': (num x) => x.abs(),
  'random': () => math.Random().nextDouble(),
  'min': (num a, num b) => math.min(a, b),
  'max': (num a, num b) => math.max(a, b),
  'floor': (num x) => x.floor(),
  'ceil': (num x) => x.ceil(),
  'round': (num x) => x.round(),

  // 延迟函数 - 异步但不需要主线程
  'delay': (int milliseconds) async {
    if (milliseconds < 0) milliseconds = 0;
    await Future.delayed(Duration(milliseconds: milliseconds));
    return null;
  },

  // 带返回值的延迟函数
  'delayThen': (int milliseconds, dynamic value) async {
    if (milliseconds < 0) milliseconds = 0;
    await Future.delayed(Duration(milliseconds: milliseconds));
    return value;
  },

  // 获取当前时间戳
  'now': () => DateTime.now().millisecondsSinceEpoch,
};

/// 检查函数是否为内部函数
bool _isInternalFunction(String functionName) {
  return _internalFunctions.containsKey(functionName);
}

/// 处理自定义消息
Future<void> _handleCustomMessage(
  IsolateManagerController controller,
  Map<String, dynamic> data,
  String executionId,
) async {
  try {
    final type = data['type'] as String? ?? 'unknown';
    final startTime = DateTime.now();

    _addWorkerLog('处理自定义消息类型: $type, 任务ID: $executionId');

    switch (type) {
      case 'execute':
        _addWorkerLog('执行脚本请求，任务ID: $executionId');
        await _executeScript(controller, data, startTime);
        break;

      case 'mapDataUpdate':
        _currentMapData = data['data'] as Map<String, dynamic>? ?? {};
        _addWorkerLog('地图数据更新，任务ID: $executionId');
        _sendCustomMessage(controller, {
          'type': 'ack',
          'message': 'Map data updated',
          'executionId': executionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        break;

      case 'stop':
        _addWorkerLog('收到停止信号，任务ID: $executionId');
        _sendCustomMessage(controller, {
          'type': 'stopped',
          'executionId': executionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        break;
      case 'externalFunctionResult':
        _handleExternalFunctionResult(controller, data);
        break;

      case 'externalFunctionError':
        _handleExternalFunctionError(controller, data);
        break;

      case 'externalFunctionResponse':
        // 处理主线程发送的外部函数响应
        if (data['error'] != null) {
          _handleExternalFunctionError(controller, data);
        } else {
          _handleExternalFunctionResult(controller, data);
        }
        break;

      case 'ping':
        // 立即回复 pong
        _sendCustomMessage(controller, {
          'type': 'pong',
          'executionId': executionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        break;

      default:
        _addWorkerLog('未知消息类型: $type, 任务ID: $executionId');
        _sendCustomErrorMessage(controller, executionId, '未知消息类型: $type');
    }
  } catch (e, stackTrace) {
    _addWorkerLog('自定义消息处理错误: $e');
    _addWorkerLog('错误堆栈: $stackTrace');
    _sendCustomErrorMessage(controller, executionId, '自定义消息处理错误: $e');
  }
}

/// 发送自定义消息到主线程
void _sendCustomMessage(
  IsolateManagerController controller,
  Map<String, dynamic> data,
) {
  try {
    // 先将数据转换为JSON字符串，然后再发送
    // 这样可以避免jsify()方法的问题
    final jsonString = json.encode(data);
    controller.sendResult(jsonString);
    _addWorkerLog(
      '发送自定义消息: ${data['type']} 任务ID: ${data['executionId'] ?? 'unknown'}',
    );
  } catch (e) {
    _addWorkerLog('发送自定义消息错误: $e');
    // 如果JSON序列化失败，尝试发送简化的错误消息
    try {
      final errorMessage = json.encode({
        'type': 'error',
        'error': 'Failed to serialize message: $e',
        'executionId': data['executionId'] ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      controller.sendResult(errorMessage);
    } catch (e2) {
      _addWorkerLog('发送错误消息也失败: $e2');
    }
  }
}

/// 发送自定义错误消息
void _sendCustomErrorMessage(
  IsolateManagerController controller,
  String executionId,
  String error,
) {
  _sendCustomMessage(controller, {
    'type': 'error',
    'error': error,
    'executionId': executionId,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
}

/// 发送错误消息（使用自定义方式）
void _sendErrorMessage(
  IsolateManagerController controller,
  String? executionId,
  String error,
) {
  _sendCustomErrorMessage(controller, executionId ?? 'unknown', error);
}

/// 初始化 Hetu 脚本引擎
Future<void> _initializeHetuEngine(IsolateManagerController controller) async {
  try {
    _hetuEngine = Hetu();
    _hetuEngine!.init();
    _addWorkerLog('Hetu script engine initialized successfully');

    // 记录可用的内部函数
    final internalFunctionNames = _internalFunctions.keys.toList();
    _addWorkerLog('Available internal functions: $internalFunctionNames');

    // 发送初始化完成信号
    _sendCustomMessage(controller, {
      'type': 'initialized',
      'message': 'Hetu engine ready',
      'executionId': 'init',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  } catch (e) {
    _addWorkerLog('Failed to initialize Hetu engine: $e');
    _sendErrorMessage(
      controller,
      'init',
      'Failed to initialize Hetu engine: $e',
    );
    rethrow;
  }
}

/// 执行脚本
Future<void> _executeScript(
  IsolateManagerController controller,
  Map<String, dynamic> message,
  DateTime startTime,
) async {
  final code = message['code'] as String? ?? '';
  final context = message['context'] as Map<String, dynamic>? ?? {};
  final executionId = message['executionId'] as String? ?? 'unknown';

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

    // 合并内部函数和外部函数列表
    final allFunctions = <String>{};

    // 添加所有内部函数
    allFunctions.addAll(_internalFunctions.keys);

    // 添加外部函数，但排除已经在内部实现的
    final uniqueExternalFunctions = externalFunctions.where(
      (name) => !_internalFunctions.containsKey(name),
    );
    allFunctions.addAll(uniqueExternalFunctions);

    _addWorkerLog('注册函数总数: ${allFunctions.length}');
    _addWorkerLog('内部函数: ${_internalFunctions.keys.toList()}');
    _addWorkerLog('外部函数: ${uniqueExternalFunctions.toList()}'); // 注册所有函数
    for (final functionName in allFunctions) {
      if (_isInternalFunction(functionName)) {
        // 内部函数直接绑定，不需要异步包装
        final dartFunction = _internalFunctions[functionName]!;
        _hetuEngine!.interpreter.bindExternalFunction(functionName, (
          HTEntity entity, {
          List<dynamic> positionalArgs = const [],
          Map<String, dynamic> namedArgs = const {},
          List<HTType> typeArgs = const [],
        }) {
          _addWorkerLog('调用内部函数: $functionName, 参数: $positionalArgs');

          // 直接调用 Dart 函数，不包装成异步
          try {
            switch (positionalArgs.length) {
              case 0:
                return dartFunction();
              case 1:
                return dartFunction(positionalArgs[0]);
              case 2:
                return dartFunction(positionalArgs[0], positionalArgs[1]);
              case 3:
                return dartFunction(
                  positionalArgs[0],
                  positionalArgs[1],
                  positionalArgs[2],
                );
              default:
                return Function.apply(dartFunction, positionalArgs);
            }
          } catch (e) {
            _addWorkerLog('内部函数 $functionName 执行失败: $e');
            rethrow;
          }
        });
      } else {
        // 外部函数使用异步调用
        _hetuEngine!.interpreter.bindExternalFunction(functionName, (
          HTEntity entity, {
          List<dynamic> positionalArgs = const [],
          Map<String, dynamic> namedArgs = const {},
          List<HTType> typeArgs = const [],
        }) async {
          return await _callExternalFunction(
            controller,
            functionName,
            positionalArgs,
            executionId,
          );
        });
      }
    } // 发送脚本已开始执行的信号
    _addWorkerLog('发送开始信号，任务ID: $executionId');
    _sendCustomMessage(controller, {
      'type': 'started',
      'executionId': executionId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // 执行脚本
    final result = _hetuEngine!.eval(code);
    final executionTime = DateTime.now().difference(startTime).inMilliseconds;

    _addWorkerLog('脚本执行成功，用时 ${executionTime}ms，任务ID: $executionId');

    // 发送执行结果
    _sendCustomMessage(controller, {
      'type': 'result',
      'result': _serializeResult(result),
      'executionTime': executionTime,
      'executionId': executionId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  } catch (e) {
    final executionTime = DateTime.now().difference(startTime).inMilliseconds;
    _addWorkerLog('脚本执行失败，任务ID $executionId: $e');

    // 发送执行错误
    _sendCustomMessage(controller, {
      'type': 'error',
      'error': e.toString(),
      'executionTime': executionTime,
      'executionId': executionId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
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

  _addWorkerLog(
    'Calling external function: $functionName for task: $executionId',
  );
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
  // 发送外部函数调用请求到主线程
  _sendCustomMessage(controller, {
    'type': 'externalFunctionCall',
    'functionName': functionName,
    'arguments': argumentsToSend,
    'callId': callId,
    'executionId': executionId,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });

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
void _handleExternalFunctionResult(
  IsolateManagerController controller,
  Map<String, dynamic> message,
) {
  final callId = message['callId'] as String? ?? '';
  final result = message['result'];
  final executionId = message['executionId'] as String? ?? 'unknown';

  _addWorkerLog(
    'Received external function result for callId: $callId, task: $executionId',
  );

  final completer = _externalFunctionCalls.remove(callId);
  if (completer != null && !completer.isCompleted) {
    completer.complete(result);
    _addWorkerLog('External function result processed for callId: $callId');
  } else {
    _addWorkerLog('Warning: No completer found for callId: $callId');
  }
  // 发送确认消息
  _sendCustomMessage(controller, {
    'type': 'ack',
    'message': 'External function result processed',
    'callId': callId,
    'executionId': executionId,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
}

/// 处理外部函数调用错误
void _handleExternalFunctionError(
  IsolateManagerController controller,
  Map<String, dynamic> message,
) {
  final callId = message['callId'] as String? ?? '';
  final error = message['error'] as String? ?? 'Unknown error';
  final executionId = message['executionId'] as String? ?? 'unknown';

  _addWorkerLog(
    'Received external function error for callId: $callId, task: $executionId, error: $error',
  );

  final completer = _externalFunctionCalls.remove(callId);
  if (completer != null && !completer.isCompleted) {
    completer.completeError(Exception(error));
    _addWorkerLog('External function error processed for callId: $callId');
  } else {
    _addWorkerLog('Warning: No completer found for error callId: $callId');
  }
  // 发送确认消息
  _sendCustomMessage(controller, {
    'type': 'ack',
    'message': 'External function error processed',
    'callId': callId,
    'executionId': executionId,
    'error': error,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
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
void _disposeHetuEngine(IsolateManagerController controller) {
  _addWorkerLog('Disposing Hetu engine...');

  // 取消所有待处理的外部函数调用
  for (final completer in _externalFunctionCalls.values) {
    if (!completer.isCompleted) {
      completer.completeError(Exception('Worker is being disposed'));
    }
  }

  _hetuEngine = null;
  _currentMapData.clear();
  _externalFunctionCalls.clear();
  _workerLogs.clear();

  _addWorkerLog('Hetu engine disposed');
  // 发送清理完成信号
  _sendCustomMessage(controller, {
    'type': 'disposed',
    'message': 'Worker resources cleaned up',
    'executionId': 'dispose',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
}
