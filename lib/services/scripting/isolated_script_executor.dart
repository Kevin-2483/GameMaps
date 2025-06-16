import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:hetu_script/hetu_script.dart';
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
  }  /// 启动隔离
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
    try {
      // 创建Hetu脚本解释器
      final hetu = Hetu();
      
      // 准备外部函数映射
      final externalFunctions = <String, Function>{};
      
      // 注册基础外部函数
      _registerBasicExternalFunctions(externalFunctions);
      
      // 注册地图数据访问函数
      _registerMapDataFunctions(externalFunctions);
      
      // 注册便签和图例函数
      _registerStickyNoteAndLegendFunctions(externalFunctions);
      
      // 初始化Hetu解释器
      hetu.init(externalFunctions: externalFunctions);
      
      // 设置初始上下文
      if (context != null) {
        for (final entry in context.entries) {
          hetu.assign(entry.key, entry.value);
        }
      }
      
      // 执行脚本（Hetu支持异步外部函数）
      final result = await hetu.eval(code);
      return result;
    } catch (e) {
      throw Exception('Script execution failed: $e');
    }
  }

  /// 注册基础外部函数（日志、数学等）
  void _registerBasicExternalFunctions(Map<String, Function> functions) {
    // 日志函数
    functions['log'] = (dynamic message) async {
      return await _callExternalFunction('log', [message]);
    };
    
    functions['print'] = (dynamic message) async {
      return await _callExternalFunction('print', [message]);
    };

    // 数学函数
    functions['sin'] = (num x) async {
      return await _callExternalFunction('sin', [x]);
    };
    
    functions['cos'] = (num x) async {
      return await _callExternalFunction('cos', [x]);
    };
    
    functions['tan'] = (num x) async {
      return await _callExternalFunction('tan', [x]);
    };
    
    functions['sqrt'] = (num x) async {
      return await _callExternalFunction('sqrt', [x]);
    };
    
    functions['pow'] = (num x, num y) async {
      return await _callExternalFunction('pow', [x, y]);
    };
    
    functions['abs'] = (num x) async {
      return await _callExternalFunction('abs', [x]);
    };
    
    functions['random'] = () async {
      return await _callExternalFunction('random', []);
    };
  }

  /// 注册地图数据访问函数
  void _registerMapDataFunctions(Map<String, Function> functions) {
    // 图层相关
    functions['getLayers'] = () async {
      return await _callExternalFunction('getLayers', []);
    };
    
    functions['getLayerById'] = (String id) async {
      return await _callExternalFunction('getLayerById', [id]);
    };
    
    functions['getElementsInLayer'] = (String layerId) async {
      return await _callExternalFunction('getElementsInLayer', [layerId]);
    };
    
    functions['getAllElements'] = () async {
      return await _callExternalFunction('getAllElements', []);
    };
    
    functions['countElements'] = ([String? type]) async {
      return await _callExternalFunction('countElements', [type]);
    };
    
    functions['calculateTotalArea'] = () async {
      return await _callExternalFunction('calculateTotalArea', []);
    };

    // 元素修改函数
    functions['updateElementProperty'] = (String elementId, String property, dynamic value) async {
      return await _callExternalFunction('updateElementProperty', [elementId, property, value]);
    };
    
    functions['moveElement'] = (String elementId, Map<String, dynamic> newPosition) async {
      return await _callExternalFunction('moveElement', [elementId, newPosition]);
    };

    // 文本元素函数
    functions['createTextElement'] = (Map<String, dynamic> params) async {
      return await _callExternalFunction('createTextElement', [params]);
    };
    
    functions['updateTextContent'] = (String elementId, String content) async {
      return await _callExternalFunction('updateTextContent', [elementId, content]);
    };
    
    functions['updateTextSize'] = (String elementId, double size) async {
      return await _callExternalFunction('updateTextSize', [elementId, size]);
    };
    
    functions['getTextElements'] = () async {
      return await _callExternalFunction('getTextElements', []);
    };
    
    functions['findTextElementsByContent'] = (String content) async {
      return await _callExternalFunction('findTextElementsByContent', [content]);
    };
    
    functions['say'] = (dynamic tagFilter, String filterType, String text) async {
      return await _callExternalFunction('say', [tagFilter, filterType, text]);
    };

    // 文件操作函数
    functions['readjson'] = (String filename) async {
      return await _callExternalFunction('readjson', [filename]);
    };
    
    functions['writetext'] = (String filename, String content) async {
      return await _callExternalFunction('writetext', [filename, content]);
    };
  }

  /// 注册便签和图例函数
  void _registerStickyNoteAndLegendFunctions(Map<String, Function> functions) {
    // 便签相关函数
    functions['getStickyNotes'] = () async {
      return await _callExternalFunction('getStickyNotes', []);
    };
    
    functions['getStickyNoteById'] = (String id) async {
      return await _callExternalFunction('getStickyNoteById', [id]);
    };
    
    functions['getElementsInStickyNote'] = (String id) async {
      return await _callExternalFunction('getElementsInStickyNote', [id]);
    };
    
    functions['filterStickyNotesByTags'] = (List<String> tags) async {
      return await _callExternalFunction('filterStickyNotesByTags', [tags]);
    };
    
    functions['filterStickyNoteElementsByTags'] = (List<String> tags) async {
      return await _callExternalFunction('filterStickyNoteElementsByTags', [tags]);
    };

    // 图例相关函数
    functions['getLegendGroups'] = () async {
      return await _callExternalFunction('getLegendGroups', []);
    };
    
    functions['getLegendGroupById'] = (String id) async {
      return await _callExternalFunction('getLegendGroupById', [id]);
    };
    
    functions['updateLegendGroup'] = (String id, Map<String, dynamic> params) async {
      return await _callExternalFunction('updateLegendGroup', [id, params]);
    };
    
    functions['updateLegendGroupVisibility'] = (String id, bool visible) async {
      return await _callExternalFunction('updateLegendGroupVisibility', [id, visible]);
    };
    
    functions['updateLegendGroupOpacity'] = (String id, double opacity) async {
      return await _callExternalFunction('updateLegendGroupOpacity', [id, opacity]);
    };
    
    functions['getLegendItems'] = () async {
      return await _callExternalFunction('getLegendItems', []);
    };
    
    functions['getLegendItemById'] = (String id) async {
      return await _callExternalFunction('getLegendItemById', [id]);
    };
    
    functions['updateLegendItem'] = (String id, Map<String, dynamic> params) async {
      return await _callExternalFunction('updateLegendItem', [id, params]);
    };
    
    functions['filterLegendGroupsByTags'] = (List<String> tags) async {
      return await _callExternalFunction('filterLegendGroupsByTags', [tags]);
    };
    
    functions['filterLegendItemsByTags'] = (List<String> tags) async {
      return await _callExternalFunction('filterLegendItemsByTags', [tags]);
    };
  }

  /// 调用外部函数（通过消息传递与主线程通信）
  Future<dynamic> _callExternalFunction(String functionName, List<dynamic> arguments) async {
    final callId = DateTime.now().millisecondsSinceEpoch.toString() + 
                   math.Random().nextInt(1000).toString();
    
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
          throw TimeoutException('External function call timeout: $functionName', const Duration(seconds: 10));
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
