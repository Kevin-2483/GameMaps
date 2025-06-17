import 'package:flutter/foundation.dart';
import 'isolated_script_executor.dart';
import 'concurrent_isolate_script_executor_new.dart';
import 'web_worker_script_executor.dart';

/// 脚本执行器工厂类
///
/// 根据平台和配置自动选择最合适的脚本执行器实现
/// 支持桌面端的Isolate执行器和Web平台的Worker执行器
class ScriptExecutorFactory {  /// 创建适合当前平台的脚本执行器
  static IsolatedScriptExecutor create() {
    if (kIsWeb) {
      return WebWorkerScriptExecutor();
    } else {
      return ConcurrentIsolateScriptExecutor();
    }
  }

  /// 创建Web Worker执行器（明确指定）
  static WebWorkerScriptExecutor createWebWorker() {
    return WebWorkerScriptExecutor();
  }
  /// 创建Isolate执行器（明确指定，用于桌面端）
  static ConcurrentIsolateScriptExecutor createIsolate() {
    return ConcurrentIsolateScriptExecutor();
  }

  /// 检测当前平台支持的执行器类型
  static List<ScriptExecutorType> getSupportedExecutors() {
    final supported = <ScriptExecutorType>[];

    if (kIsWeb) {
      supported.add(ScriptExecutorType.webWorker);
    } else {
      supported.add(ScriptExecutorType.isolate);
    }

    return supported;
  }

  /// 获取推荐的执行器类型
  static ScriptExecutorType getRecommendedExecutor() {
    if (kIsWeb) {
      return ScriptExecutorType.webWorker;
    } else {
      return ScriptExecutorType.isolate;
    }
  }

  /// 获取当前平台信息
  static PlatformInfo getPlatformInfo() {
    return PlatformInfo(
      isWeb: kIsWeb,
      isDebugMode: kDebugMode,
      supportedExecutors: getSupportedExecutors(),
      recommendedExecutor: getRecommendedExecutor(),
    );
  }
}

/// 脚本执行器类型
enum ScriptExecutorType {
  /// Dart Isolate执行器（桌面端）
  isolate,

  /// Web Worker执行器（Web平台）
  webWorker,
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
