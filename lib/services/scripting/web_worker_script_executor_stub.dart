import 'dart:async';
import 'script_executor_base.dart';
import '../../models/script_data.dart';

/// Web Worker脚本执行器的桌面端占位符实现
/// 这个类不应该在非Web平台上被实例化
class WebWorkerScriptExecutor implements IScriptExecutor {
  WebWorkerScriptExecutor() {
    throw UnsupportedError(
      'WebWorkerScriptExecutor is only supported on web platform',
    );
  }

  @override
  Future<ScriptExecutionResult> execute(
    String code, {
    Map<String, dynamic>? context,
    Duration? timeout,
  }) async {
    throw UnsupportedError(
      'WebWorkerScriptExecutor is only supported on web platform',
    );
  }

  @override
  void stop() {
    throw UnsupportedError(
      'WebWorkerScriptExecutor is only supported on web platform',
    );
  }

  @override
  void dispose() {
    throw UnsupportedError(
      'WebWorkerScriptExecutor is only supported on web platform',
    );
  }

  @override
  void registerExternalFunction(String name, Function handler) {
    throw UnsupportedError(
      'WebWorkerScriptExecutor is only supported on web platform',
    );
  }

  @override
  void clearExternalFunctions() {
    throw UnsupportedError(
      'WebWorkerScriptExecutor is only supported on web platform',
    );
  }

  @override
  void sendMapDataUpdate(Map<String, dynamic> data) {
    throw UnsupportedError(
      'WebWorkerScriptExecutor is only supported on web platform',
    );
  }

  @override
  List<String> getExecutionLogs() {
    throw UnsupportedError(
      'WebWorkerScriptExecutor is only supported on web platform',
    );
  }
}
