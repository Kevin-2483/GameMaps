import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:squadron/squadron.dart';
import 'package:hetu_script/hetu_script.dart';
import 'script_worker_service.activator.g.dart';

part 'script_worker_service.worker.g.dart';

/// Squadron脚本执行服务 - 支持双向通信的外部函数调用
@SquadronService(baseUrl: '~/workers', targetPlatform: TargetPlatform.web)
base class ScriptWorkerService {
  /// Hetu脚本引擎实例
  Hetu? _hetuEngine;
  
  /// 当前地图数据
  Map<String, dynamic> _currentMapData = {};
  
  /// 等待外部函数响应的映射
  final Map<String, Completer<dynamic>> _pendingExternalCalls = {};
  
  /// 外部函数调用的Stream控制器
  final StreamController<String> _externalCallController = StreamController<String>.broadcast();
  /// 获取外部函数调用的Stream
  @SquadronMethod()
  Stream<String> getExternalFunctionCalls() async* {
    yield* _externalCallController.stream;
  }

  /// 初始化Worker
  @SquadronMethod()
  Future<bool> initialize() async {
    try {
      _hetuEngine = Hetu();
      _hetuEngine!.init();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 更新地图数据 - 使用JSON字符串
  @SquadronMethod()
  Future<void> updateMapData(String mapDataJson) async {
    try {
      _currentMapData = jsonDecode(mapDataJson) as Map<String, dynamic>;
    } catch (e) {
      _currentMapData = {};
    }
  }

  /// 执行脚本 - 输入输出都使用JSON字符串
  @SquadronMethod()
  Stream<String> executeScript(String requestJson) async* {
    final stopwatch = Stopwatch()..start();
    
    try {
      // 解析请求
      final requestData = jsonDecode(requestJson) as Map<String, dynamic>;
      final executionId = requestData['executionId'] as String;
      final code = requestData['code'] as String;
      final context = requestData['context'] as Map<String, dynamic>? ?? {};
      final externalFunctions = List<String>.from(requestData['externalFunctions'] as List? ?? []);
      
      if (_hetuEngine == null) {
        yield jsonEncode({
          'type': 'error',
          'executionId': executionId,
          'error': 'Hetu engine not initialized',
          'executionTime': stopwatch.elapsedMilliseconds,
        });
        return;
      }

      // 设置上下文变量
      for (final entry in context.entries) {
        _hetuEngine!.define(entry.key, entry.value);
      }

      // 设置地图数据
      _hetuEngine!.define('mapData', _currentMapData);      // 注册外部函数代理
      for (final functionName in externalFunctions) {
        _hetuEngine!.interpreter.bindExternalFunction(functionName, (
          dynamic positionalArgs, {
          Map<String, dynamic> namedArgs = const {},
          List<HTType> typeArgs = const [],
        }) async {
          // 确保 positionalArgs 是正确的 List 类型
          List<dynamic> args;
          if (positionalArgs is List<dynamic>) {
            args = positionalArgs;
          } else if (positionalArgs is List) {
            args = List<dynamic>.from(positionalArgs);
          } else if (positionalArgs != null) {
            args = [positionalArgs];
          } else {
            args = [];
          }
          
          return await _callExternalFunction(
            executionId,
            functionName,
            args,
          );
        });
      }

      // 发送started信号
      yield jsonEncode({
        'type': 'started',
        'executionId': executionId,
      });

      // 执行脚本
      final result = _hetuEngine!.eval(code);
      stopwatch.stop();

      // 发送结果
      yield jsonEncode({
        'type': 'result',
        'executionId': executionId,
        'result': _serializeResult(result),
        'executionTime': stopwatch.elapsedMilliseconds,
      });

    } catch (e) {
      stopwatch.stop();
      
      // 尝试从requestJson中获取executionId
      String executionId = 'unknown';
      try {
        final requestData = jsonDecode(requestJson) as Map<String, dynamic>;
        executionId = requestData['executionId'] as String? ?? 'unknown';
      } catch (_) {}
      
      yield jsonEncode({
        'type': 'error',
        'executionId': executionId,
        'error': e.toString(),
        'executionTime': stopwatch.elapsedMilliseconds,
      });
    }
  }

  /// 处理外部函数响应 - 使用JSON字符串
  @SquadronMethod()
  Future<void> handleExternalFunctionResponse(String responseJson) async {
    try {
      final responseData = jsonDecode(responseJson) as Map<String, dynamic>;
      final callId = responseData['callId'] as String;
      final result = responseData['result'];
      final error = responseData['error'] as String?;
      
      final completer = _pendingExternalCalls.remove(callId);
      if (completer != null) {
        if (error != null) {
          completer.completeError(Exception(error));
        } else {
          completer.complete(result);
        }
      }
    } catch (e) {
      // 忽略解析错误
    }
  }
  /// 停止Worker
  @SquadronMethod()
  Future<void> stopWorker() async {
    // 清理所有待处理的外部函数调用
    for (final completer in _pendingExternalCalls.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Worker stopped'));
      }
    }
    _pendingExternalCalls.clear();
    
    // 关闭Stream控制器
    await _externalCallController.close();
    
    // 清理Hetu引擎
    _hetuEngine = null;
    _currentMapData.clear();
  }  /// 调用外部函数 - 实现真正的双向通信
  Future<dynamic> _callExternalFunction(
    String executionId,
    String functionName,
    List<dynamic> arguments,
  ) async {
    // 调试信息
    print('[ScriptWorkerService] Calling external function: $functionName');
    print('[ScriptWorkerService] Arguments type: ${arguments.runtimeType}');
    print('[ScriptWorkerService] Arguments: $arguments');
    
    // 生成唯一的调用ID
    final callId = DateTime.now().millisecondsSinceEpoch.toString() + 
                   '_' + 
                   math.Random().nextInt(1000).toString();
      // 创建Completer等待响应
    final completer = Completer<dynamic>();
    _pendingExternalCalls[callId] = completer;
      // 直接使用传入的参数列表
    final argumentsToSend = arguments;
    print('[ScriptWorkerService] Arguments to send: $argumentsToSend (type: ${argumentsToSend.runtimeType})');
      // 构造外部函数调用请求
    final requestData = {
      'type': 'externalFunctionCall',
      'functionName': functionName,
      'arguments': argumentsToSend,
      'callId': callId,
      'executionId': executionId,
    };
    
    print('[ScriptWorkerService] Request data: $requestData');
    
    // 通过Stream发送外部函数调用请求
    final requestJson = jsonEncode(requestData);
    print('[ScriptWorkerService] Request JSON: $requestJson');
    _externalCallController.add(requestJson);
    
    try {
      // 等待响应，设置超时防止死锁
      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _pendingExternalCalls.remove(callId);
          throw Exception('External function call timeout: $functionName');
        },
      );
    } catch (e) {
      _pendingExternalCalls.remove(callId);
      rethrow;
    }
  }
  /// 序列化结果
  dynamic _serializeResult(dynamic result) {
    if (result == null ||
        result is String ||
        result is num ||
        result is bool ||
        result is List ||
        result is Map) {
      return result;
    }
    return result.toString();
  }
}
