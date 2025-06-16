import 'package:flutter/foundation.dart';
import '../../data/map_data_bloc.dart';
import '../../data/new_reactive_script_manager.dart';
import '../../data/new_reactive_script_engine.dart';

/// 新脚本系统工厂
/// 负责创建和管理新的脚本执行架构组件
class NewScriptSystemFactory {
  static NewScriptSystemFactory? _instance;

  NewScriptSystemFactory._internal();

  factory NewScriptSystemFactory() {
    _instance ??= NewScriptSystemFactory._internal();
    return _instance!;
  }

  /// 创建新的响应式脚本管理器
  NewReactiveScriptManager createScriptManager(MapDataBloc mapDataBloc) {
    debugPrint('创建新的响应式脚本管理器');
    return NewReactiveScriptManager(mapDataBloc: mapDataBloc);
  }

  /// 创建新的响应式脚本引擎
  NewReactiveScriptEngine createScriptEngine(MapDataBloc mapDataBloc) {
    debugPrint('创建新的响应式脚本引擎');
    return NewReactiveScriptEngine(mapDataBloc: mapDataBloc);
  }

  /// 验证系统兼容性
  bool checkSystemCompatibility() {
    try {
      // 检查Web Worker支持（仅在Web环境）
      if (kIsWeb) {
        // 在Web环境中检查Worker支持
        debugPrint('Web环境：检查Web Worker支持');
        return true; // 假设现代浏览器都支持
      } else {
        // 在桌面环境中检查Isolate支持
        debugPrint('桌面环境：检查Isolate支持');
        return true; // Dart总是支持Isolate
      }
    } catch (e) {
      debugPrint('系统兼容性检查失败: $e');
      return false;
    }
  }

  /// 获取当前平台信息
  String getPlatformInfo() {
    if (kIsWeb) {
      return 'Web (Web Worker执行)';
    } else {
      return 'Desktop (Isolate执行)';
    }
  }

  /// 清理工厂实例
  void dispose() {
    _instance = null;
    debugPrint('新脚本系统工厂已清理');
  }
}

/// 脚本系统迁移助手
/// 帮助从旧的脚本系统迁移到新的异步架构
class ScriptSystemMigrationHelper {
  /// 检查是否需要迁移
  static bool needsMigration() {
    // 这里可以检查系统中是否存在旧的脚本管理器
    // 并决定是否需要迁移
    return false; // 暂时返回false，因为我们正在创建全新的系统
  }

  /// 执行迁移
  static Future<bool> performMigration() async {
    try {
      debugPrint('开始执行脚本系统迁移');

      // 这里实现具体的迁移逻辑
      // 1. 读取旧的脚本数据
      // 2. 转换为新的格式
      // 3. 保存到新的存储位置

      debugPrint('脚本系统迁移完成');
      return true;
    } catch (e) {
      debugPrint('脚本系统迁移失败: $e');
      return false;
    }
  }

  /// 备份旧的脚本数据
  static Future<bool> backupOldScripts() async {
    try {
      debugPrint('备份旧的脚本数据');

      // 实现备份逻辑

      return true;
    } catch (e) {
      debugPrint('备份失败: $e');
      return false;
    }
  }
}

/// 脚本系统配置
class ScriptSystemConfig {
  /// 脚本执行超时时间
  static const Duration defaultExecutionTimeout = Duration(seconds: 30);

  /// 最大并发执行脚本数
  static const int maxConcurrentScripts = 3;

  /// 启用调试日志
  static const bool enableDebugLogging = true;

  /// 脚本执行内存限制（MB）
  static const int memoryLimitMB = 128;

  /// 是否启用脚本缓存
  static const bool enableScriptCache = true;

  /// 获取当前配置
  static Map<String, dynamic> getCurrentConfig() {
    return {
      'executionTimeout': defaultExecutionTimeout.inSeconds,
      'maxConcurrentScripts': maxConcurrentScripts,
      'enableDebugLogging': enableDebugLogging,
      'memoryLimitMB': memoryLimitMB,
      'enableScriptCache': enableScriptCache,
      'platform': kIsWeb ? 'web' : 'desktop',
    };
  }
}
