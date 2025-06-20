import 'package:flutter/foundation.dart';
import 'script_executor_base.dart';
import 'isolated_script_executor.dart';
import 'concurrent_isolate_script_executor.dart';

// 条件导入：只在 Web 平台导入这些依赖 web 包的文件
import 'web_worker_script_executor_stub.dart'
    if (dart.library.html) 'web_worker_script_executor.dart'
    if (dart.library.js_interop) 'web_worker_script_executor.dart';

import 'concurrent_web_worker_script_executor_stub.dart'
    if (dart.library.html) 'concurrent_web_worker_script_executor.dart'
    if (dart.library.js_interop) 'concurrent_web_worker_script_executor.dart';

// import 'squadron/squadron_concurrent_web_worker_script_executor.dart';

/// 脚本执行器类型
enum ScriptExecutorType {
  /// 标准 Isolate 执行器（单任务）
  isolate,

  /// Web Worker 执行器（Web 平台）
  webWorker,

  /// 并发 Isolate 执行器（多任务）
  concurrent,

  /// 并发 Web Worker 执行器（Web 平台多任务）
  concurrentWebWorker,

  /// Squadron 并发 Web Worker 执行器（Web 平台多任务，支持双向通信）
  squadronConcurrentWebWorker,
}

/// 脚本执行器工厂类
///
/// 根据平台和配置自动选择最合适的脚本执行器实现
/// 支持桌面端的Isolate执行器和Web平台的Worker执行器
class ScriptExecutorFactory {
  /// 创建适合当前平台的脚本执行器
  static IScriptExecutor create({
    ScriptExecutorType? type,
    bool enableConcurrency = false,
    int? workerPoolSize,
  }) {
    // 如果未指定类型，自动选择
    type ??= _getDefaultType(enableConcurrency);
    switch (type) {
      case ScriptExecutorType.isolate:
        if (kIsWeb) {
          throw UnsupportedError(
            'Isolate executor is not supported on web platform',
          );
        }
        return IsolateScriptExecutor();

      case ScriptExecutorType.webWorker:
        if (!kIsWeb) {
          throw UnsupportedError(
            'WebWorker executor is only supported on web platform',
          );
        }
        return WebWorkerScriptExecutor();

      case ScriptExecutorType.concurrent:
        if (kIsWeb) {
          throw UnsupportedError(
            'Concurrent isolate executor is not supported on web platform',
          );
        }
        return ConcurrentIsolateScriptExecutor();

      case ScriptExecutorType.concurrentWebWorker:
        if (!kIsWeb) {
          throw UnsupportedError(
            'Concurrent web worker executor is only supported on web platform',
          );
        }
        return ConcurrentWebWorkerScriptExecutor(
          workerPoolSize: workerPoolSize ?? 4,
        );

      case ScriptExecutorType.squadronConcurrentWebWorker:
        if (!kIsWeb) {
          throw UnsupportedError(
            'Squadron concurrent web worker executor is only supported on web platform',
          );
        }
        throw UnsupportedError(
          'Squadron concurrent web worker executor is no longer supported',
        );
    }
  }

  /// 获取平台默认的执行器类型
  static ScriptExecutorType _getDefaultType(bool enableConcurrency) {
    if (kIsWeb) {
      return enableConcurrency
          ? ScriptExecutorType.concurrentWebWorker
          : ScriptExecutorType.webWorker;
    } else {
      return enableConcurrency
          ? ScriptExecutorType.concurrent
          : ScriptExecutorType.isolate;
    }
  }

  /// 创建Web Worker执行器（明确指定）
  static WebWorkerScriptExecutor createWebWorker() {
    if (!kIsWeb) {
      throw UnsupportedError(
        'WebWorker executor is only supported on web platform',
      );
    }
    return WebWorkerScriptExecutor();
  }

  /// 创建Isolate执行器（明确指定，用于桌面端）
  static IsolateScriptExecutor createIsolate() {
    if (kIsWeb) {
      throw UnsupportedError(
        'Isolate executor is not supported on web platform',
      );
    }
    return IsolateScriptExecutor();
  }

  /// 创建并发Isolate执行器（明确指定，用于桌面端）
  static ConcurrentIsolateScriptExecutor createConcurrentIsolate() {
    if (kIsWeb) {
      throw UnsupportedError(
        'Concurrent isolate executor is not supported on web platform',
      );
    }
    return ConcurrentIsolateScriptExecutor();
  }

  /// 创建并发Web Worker执行器（明确指定，用于Web端）
  static ConcurrentWebWorkerScriptExecutor createConcurrentWebWorker({
    int workerPoolSize = 4,
  }) {
    if (!kIsWeb) {
      throw UnsupportedError(
        'Concurrent web worker executor is only supported on web platform',
      );
    }
    return ConcurrentWebWorkerScriptExecutor(workerPoolSize: workerPoolSize);
  }

  /// 检查指定类型是否在当前平台可用
  static bool isTypeSupported(ScriptExecutorType type) {
    switch (type) {
      case ScriptExecutorType.isolate:
      case ScriptExecutorType.concurrent:
        return !kIsWeb;
      case ScriptExecutorType.webWorker:
      case ScriptExecutorType.concurrentWebWorker:
      case ScriptExecutorType.squadronConcurrentWebWorker:
        return kIsWeb;
    }
  }

  /// 获取当前平台支持的所有执行器类型
  static List<ScriptExecutorType> getSupportedTypes() {
    if (kIsWeb) {
      return [
        ScriptExecutorType.webWorker,
        ScriptExecutorType.concurrentWebWorker,
      ];
    } else {
      return [ScriptExecutorType.isolate, ScriptExecutorType.concurrent];
    }
  }

  /// 获取执行器类型的描述信息
  static String getTypeDescription(ScriptExecutorType type) {
    switch (type) {
      case ScriptExecutorType.isolate:
        return 'Standard Isolate Executor (single task, native platforms)';
      case ScriptExecutorType.webWorker:
        return 'Web Worker Executor (single task, web platform only)';
      case ScriptExecutorType.concurrent:
        return 'Concurrent Isolate Executor (multiple tasks, native platforms)';
      case ScriptExecutorType.concurrentWebWorker:
        return 'Concurrent Web Worker Executor (multiple tasks, web platform only)';
      case ScriptExecutorType.squadronConcurrentWebWorker:
        return 'Squadron Concurrent Web Worker Executor (multiple tasks with bidirectional communication, web platform only)';
    }
  }

  /// 获取当前平台信息
  static PlatformInfo getPlatformInfo() {
    return PlatformInfo(
      isWeb: kIsWeb,
      isDebugMode: kDebugMode,
      supportedExecutors: getSupportedTypes(),
      recommendedExecutor: _getDefaultType(false),
    );
  }
}

/// 平台信息类
class PlatformInfo {
  /// 是否为Web平台
  final bool isWeb;

  /// 是否为调试模式
  final bool isDebugMode;

  /// 支持的执行器类型列表
  final List<ScriptExecutorType> supportedExecutors;

  /// 推荐的执行器类型
  final ScriptExecutorType recommendedExecutor;

  const PlatformInfo({
    required this.isWeb,
    required this.isDebugMode,
    required this.supportedExecutors,
    required this.recommendedExecutor,
  });

  @override
  String toString() {
    return 'PlatformInfo(isWeb: $isWeb, isDebugMode: $isDebugMode, '
        'supportedExecutors: $supportedExecutors, recommendedExecutor: $recommendedExecutor)';
  }
}
