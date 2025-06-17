import 'dart:async';
import '../../models/script_data.dart';

/// 脚本执行器基础接口
abstract class IScriptExecutor {
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
  started,
  result,
  error,
  log,
  stop,
  mapDataUpdate,
  externalFunctionCall,
  externalFunctionResponse,
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
