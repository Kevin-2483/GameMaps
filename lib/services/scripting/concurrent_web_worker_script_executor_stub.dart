import 'dart:async';
import 'script_executor_base.dart';
import '../../models/script_data.dart';

/// 并发Web Worker脚本执行器的桌面端占位符实现
/// 这个类不应该在非Web平台上被实例化
class ConcurrentWebWorkerScriptExecutor implements IScriptExecutor {
  ConcurrentWebWorkerScriptExecutor({int? workerPoolSize}) {
    throw UnsupportedError(
      'ConcurrentWebWorkerScriptExecutor is only supported on web platform'
    );
  }

  @override
  Future<ScriptExecutionResult> execute(
    String code, {
    Map<String, dynamic>? context,
    Duration? timeout,
  }) async {
    throw UnsupportedError(
      'ConcurrentWebWorkerScriptExecutor is only supported on web platform'
    );
  }

  @override
  void stop() {
    throw UnsupportedError(
      'ConcurrentWebWorkerScriptExecutor is only supported on web platform'
    );
  }

  @override
  void dispose() {
    throw UnsupportedError(
      'ConcurrentWebWorkerScriptExecutor is only supported on web platform'
    );
  }

  @override
  void registerExternalFunction(String name, Function handler) {
    throw UnsupportedError(
      'ConcurrentWebWorkerScriptExecutor is only supported on web platform'
    );
  }

  @override
  void clearExternalFunctions() {
    throw UnsupportedError(
      'ConcurrentWebWorkerScriptExecutor is only supported on web platform'
    );
  }

  @override
  void sendMapDataUpdate(Map<String, dynamic> data) {
    throw UnsupportedError(
      'ConcurrentWebWorkerScriptExecutor is only supported on web platform'
    );
  }

  @override
  List<String> getExecutionLogs() {
    throw UnsupportedError(
      'ConcurrentWebWorkerScriptExecutor is only supported on web platform'
    );
  }
}
