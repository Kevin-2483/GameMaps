import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../../models/script_data.dart';
import 'isolated_script_executor.dart';

/// Web平台脚本执行器（使用 Web Worker）
class WebWorkerScriptExecutor implements IsolatedScriptExecutor {
  html.Worker? _worker;
  final Map<String, Completer<dynamic>> _pendingCalls = {};
  final List<String> _executionLogs = [];

  // 外部函数处理器
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
      // 启动 Web Worker
      await _startWorker();

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

      _worker!.postMessage(message.toJson());

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

  /// 启动 Web Worker
  Future<void> _startWorker() async {
    if (_worker != null) return;

    // 创建内联 Web Worker
    final workerScript = _generateWorkerScript();
    final blob = html.Blob([workerScript], 'application/javascript');
    final url = html.Url.createObjectUrlFromBlob(blob);

    _worker = html.Worker(url);

    // 监听 Worker 消息
    _worker!.onMessage.listen(_handleWorkerMessage);

    // 监听 Worker 错误
    _worker!.onError.listen((event) {
      debugPrint('Worker error: $event');
      if (_currentExecution != null && !_currentExecution!.isCompleted) {
        _currentExecution!.complete(
          ScriptExecutionResult(
            success: false,
            error: 'Worker error: $event',
            executionTime: Duration.zero,
          ),
        );
      }
    });

    // 清理 URL
    html.Url.revokeObjectUrl(url);
  }

  /// 生成 Web Worker 脚本
  String _generateWorkerScript() {
    return '''
    // 脚本消息类型
    const ScriptMessageType = {
      execute: 'execute',
      result: 'result',
      error: 'error',
      log: 'log',
      stop: 'stop',
      mapDataUpdate: 'mapDataUpdate',
      externalFunctionCall: 'externalFunctionCall',
    };

    // 地图数据缓存
    let mapDataCache = {};
    
    // 待处理的外部函数调用
    const pendingExternalCalls = new Map();

    // 监听主线程消息
    self.onmessage = function(e) {
      const message = e.data;
      
      switch (message.type) {
        case ScriptMessageType.execute:
          executeScript(message.data);
          break;
          
        case ScriptMessageType.stop:
          // 处理停止信号
          break;
          
        case ScriptMessageType.externalFunctionCall:
          handleExternalFunctionResponse(message.data);
          break;
          
        case ScriptMessageType.mapDataUpdate:
          mapDataCache = { ...mapDataCache, ...message.data };
          break;
      }
    };

    // 执行脚本
    async function executeScript(data) {
      const startTime = Date.now();
      
      try {
        const code = data.code;
        const context = data.context || {};
        
        // 创建脚本执行环境
        const scriptContext = createScriptContext(context);
        
        // 执行脚本代码
        const result = await executeInContext(code, scriptContext);
        
        const executionTime = Date.now() - startTime;
        
        sendResult({
          type: ScriptMessageType.result,
          data: {
            success: true,
            result: result,
            executionTimeMs: executionTime,
          }
        });
      } catch (error) {
        const executionTime = Date.now() - startTime;
        
        sendResult({
          type: ScriptMessageType.result,
          data: {
            success: false,
            error: error.toString(),
            executionTimeMs: executionTime,
          }
        });
      }
    }

    // 创建脚本执行上下文
    function createScriptContext(context) {
      return {
        ...context,
        
        // 基础函数
        log: (message) => {
          const logMsg = message?.toString() || '';
          sendLog(logMsg);
          return message;
        },
        
        print: (message) => {
          const logMsg = message?.toString() || '';
          sendLog(logMsg);
          return message;
        },
        
        // 数学函数
        sin: Math.sin,
        cos: Math.cos,
        tan: Math.tan,
        sqrt: Math.sqrt,
        pow: Math.pow,
        abs: Math.abs,
        random: Math.random,
        
        // 地图数据访问函数（通过消息传递）
        getLayers: () => callExternalFunction('getLayers', []),
        getLayerById: (id) => callExternalFunction('getLayerById', [id]),
        getAllElements: () => callExternalFunction('getAllElements', []),
        
        // 其他外部函数代理
        readjson: (filePath) => callExternalFunction('readjson', [filePath]),
        writetext: (filePath, content) => callExternalFunction('writetext', [filePath, content]),
        
        // 便签相关函数
        getStickyNotes: () => callExternalFunction('getStickyNotes', []),
        getStickyNoteById: (id) => callExternalFunction('getStickyNoteById', [id]),
        
        // 图例相关函数
        getLegendGroups: () => callExternalFunction('getLegendGroups', []),
        getLegendGroupById: (id) => callExternalFunction('getLegendGroupById', [id]),
      };
    }

    // 在上下文中执行代码
    async function executeInContext(code, context) {
      const func = new Function(...Object.keys(context), code);
      return await func(...Object.values(context));
    }

    // 调用外部函数
    async function callExternalFunction(functionName, args) {
      return new Promise((resolve, reject) => {
        const callId = Date.now().toString() + Math.random().toString(36);
        
        pendingExternalCalls.set(callId, { resolve, reject });
        
        sendMessage({
          type: ScriptMessageType.externalFunctionCall,
          data: {
            functionName: functionName,
            arguments: args,
            callId: callId,
          }
        });
        
        // 设置超时
        setTimeout(() => {
          if (pendingExternalCalls.has(callId)) {
            pendingExternalCalls.delete(callId);
            reject(new Error('External function call timeout'));
          }
        }, 10000); // 10秒超时
      });
    }

    // 处理外部函数响应
    function handleExternalFunctionResponse(data) {
      const callId = data.callId;
      const pending = pendingExternalCalls.get(callId);
      
      if (pending) {
        pendingExternalCalls.delete(callId);
        
        if (data.error) {
          pending.reject(new Error(data.error));
        } else {
          pending.resolve(data.result);
        }
      }
    }

    // 发送消息到主线程
    function sendMessage(message) {
      self.postMessage(message);
    }

    // 发送结果
    function sendResult(result) {
      sendMessage(result);
    }

    // 发送日志
    function sendLog(message) {
      sendMessage({
        type: ScriptMessageType.log,
        data: { message: message }
      });
    }
    ''';
  }

  /// 处理 Worker 消息
  void _handleWorkerMessage(html.MessageEvent event) {
    try {
      final data = event.data as Map<String, dynamic>;
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
      debugPrint('Error handling worker message: $e');
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

      _worker?.postMessage(message.toJson());
    } catch (e) {
      final response = ExternalFunctionResponse(
        callId: call.callId,
        error: e.toString(),
      );

      final message = ScriptMessage(
        type: ScriptMessageType.externalFunctionCall,
        data: response.toJson(),
      );

      _worker?.postMessage(message.toJson());
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
    if (_worker != null) {
      final message = ScriptMessage(
        type: ScriptMessageType.mapDataUpdate,
        data: data,
      );
      _worker!.postMessage(message.toJson());
    }
  }

  @override
  List<String> getExecutionLogs() {
    return List.from(_executionLogs);
  }

  @override
  void stop() {
    if (_worker != null) {
      final message = ScriptMessage(type: ScriptMessageType.stop, data: {});
      _worker!.postMessage(message.toJson());
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
    _worker?.terminate();
    _worker = null;
    _pendingCalls.clear();
    _externalFunctionHandlers.clear();
  }
}
