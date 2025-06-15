import 'package:json_annotation/json_annotation.dart';

part 'script_data.g.dart';

/// 脚本类型
enum ScriptType {
  automation, // 自动化脚本
  animation, // 动画脚本
  filter, // 过滤脚本
  statistics, // 统计脚本
}

/// 脚本状态
enum ScriptStatus {
  idle, // 空闲
  running, // 运行中
  paused, // 暂停
  error, // 错误
}

/// 脚本数据模型
@JsonSerializable()
class ScriptData {
  final String id;
  final String name;
  final String description;
  final ScriptType type;
  final String content; // 脚本内容
  final Map<String, dynamic> parameters; // 脚本参数
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastError; // 最后的错误信息
  final DateTime? lastRunAt; // 最后运行时间

  const ScriptData({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    required this.content,
    this.parameters = const {},
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastError,
    this.lastRunAt,
  });

  factory ScriptData.fromJson(Map<String, dynamic> json) =>
      _$ScriptDataFromJson(json);

  Map<String, dynamic> toJson() => _$ScriptDataToJson(this);

  ScriptData copyWith({
    String? id,
    String? name,
    String? description,
    ScriptType? type,
    String? content,
    Map<String, dynamic>? parameters,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastError,
    DateTime? lastRunAt,
    bool clearLastError = false,
  }) {
    return ScriptData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      content: content ?? this.content,
      parameters: parameters ?? this.parameters,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      lastRunAt: lastRunAt ?? this.lastRunAt,
    );
  }
}

/// 脚本执行结果
class ScriptExecutionResult {
  final bool success;
  final String? error;
  final dynamic result;
  final Duration executionTime;

  const ScriptExecutionResult({
    required this.success,
    this.error,
    this.result,
    required this.executionTime,
  });
  static ScriptExecutionResult createSuccess(
    dynamic result,
    Duration executionTime,
  ) {
    return ScriptExecutionResult(
      success: true,
      result: result,
      executionTime: executionTime,
    );
  }

  static ScriptExecutionResult createFailure(
    String error,
    Duration executionTime,
  ) {
    return ScriptExecutionResult(
      success: false,
      error: error,
      executionTime: executionTime,
    );
  }
}
