import 'package:flutter/foundation.dart';
import '../data/map_data_bloc.dart';
import '../data/new_reactive_script_manager.dart';
import '../models/script_data.dart';

/// 新脚本系统使用示例
/// 展示如何使用重构后的异步脚本执行架构
class NewScriptSystemExample {
  late final NewReactiveScriptManager _scriptManager;
  late final MapDataBloc _mapDataBloc;

  /// 初始化示例
  Future<void> initialize(MapDataBloc mapDataBloc) async {
    _mapDataBloc = mapDataBloc;

    // 创建新的脚本管理器
    _scriptManager = NewReactiveScriptManager(mapDataBloc: mapDataBloc);

    // 初始化管理器
    await _scriptManager.initialize();

    debugPrint('新脚本系统示例初始化完成');
  }

  /// 示例1：创建和执行一个简单的日志脚本
  Future<void> exampleSimpleLogScript() async {
    debugPrint('=== 示例1：简单日志脚本 ===');

    // 创建脚本
    final script = ScriptData(
      id: 'example_log_${DateTime.now().millisecondsSinceEpoch}',
      name: '示例日志脚本',
      description: '一个简单的日志输出脚本',
      type: ScriptType.automation,
      content: '''
// 简单的日志脚本
log("Hello from async script!");
log("Current time: " + Date.now().toString());
log("Script is running in isolated environment");
return "Log script completed";
''',
      parameters: {},
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // 添加脚本
      await _scriptManager.addScript(script);
      debugPrint('脚本已添加: ${script.name}');

      // 执行脚本
      await _scriptManager.executeScript(script.id);

      // 检查执行结果
      final result = _scriptManager.getLastResult(script.id);
      if (result != null) {
        debugPrint('脚本执行结果: ${result.success ? "成功" : "失败"}');
        if (result.success) {
          debugPrint('返回值: ${result.result}');
        } else {
          debugPrint('错误: ${result.error}');
        }
        debugPrint('执行时间: ${result.executionTime.inMilliseconds}ms');
      }

      // 获取执行日志
      final logs = _scriptManager.getExecutionLogs();
      debugPrint('执行日志 (${logs.length} 条):');
      for (final log in logs) {
        debugPrint('  $log');
      }
    } catch (e) {
      debugPrint('脚本执行失败: $e');
    }
  }

  /// 示例2：创建一个地图数据查询脚本
  Future<void> exampleMapDataScript() async {
    debugPrint('=== 示例2：地图数据查询脚本 ===');

    final script = ScriptData(
      id: 'example_map_${DateTime.now().millisecondsSinceEpoch}',
      name: '地图数据查询脚本',
      description: '查询当前地图的图层和元素信息',
      type: ScriptType.statistics,
      content: '''
// 地图数据查询脚本
log("开始查询地图数据...");

// 获取所有图层
var layers = getLayers();
log("找到 " + layers.length + " 个图层");

// 获取所有绘图元素
var elements = getAllElements();
log("找到 " + elements.length + " 个绘图元素");

// 统计元素类型
var typeCount = {};
for (var i = 0; i < elements.length; i++) {
    var element = elements[i];
    var type = element.type;
    if (typeCount[type]) {
        typeCount[type]++;
    } else {
        typeCount[type] = 1;
    }
}

log("元素类型统计:");
for (var type in Object.keys(typeCount)) {
    log("  " + type + ": " + typeCount[type] + " 个");
}

return {
    "layerCount": layers.length,
    "elementCount": elements.length,
    "typeCount": typeCount
};
''',
      parameters: {},
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _scriptManager.addScript(script);
      await _scriptManager.executeScript(script.id);

      final result = _scriptManager.getLastResult(script.id);
      if (result != null && result.success) {
        debugPrint('地图数据查询结果: ${result.result}');
      }
    } catch (e) {
      debugPrint('地图数据脚本执行失败: $e');
    }
  }

  /// 示例3：并发执行多个脚本
  Future<void> exampleConcurrentExecution() async {
    debugPrint('=== 示例3：并发脚本执行 ===');

    final scripts = <ScriptData>[];

    // 创建3个不同的脚本
    for (int i = 1; i <= 3; i++) {
      final script = ScriptData(
        id: 'concurrent_$i${DateTime.now().millisecondsSinceEpoch}',
        name: '并发脚本 $i',
        description: '第$i个并发执行的脚本',
        type: ScriptType.automation,
        content:
            '''
log("脚本 $i 开始执行");

// 模拟一些异步工作
for (var j = 0; j < 5; j++) {
    log("脚本 $i - 步骤 " + (j + 1));
    // 这里在实际实现中会有延迟
}

log("脚本 $i 执行完成");
return "Script $i completed";
''',
        parameters: {},
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      scripts.add(script);
      await _scriptManager.addScript(script);
    }

    try {
      // 并发执行所有脚本
      final futures = scripts
          .map((script) => _scriptManager.executeScript(script.id))
          .toList();

      await Future.wait(futures);

      debugPrint('所有并发脚本执行完成');

      // 检查所有结果
      for (final script in scripts) {
        final result = _scriptManager.getLastResult(script.id);
        final status = _scriptManager.getScriptStatus(script.id);
        debugPrint('${script.name}: $status - ${result?.success}');
      }
    } catch (e) {
      debugPrint('并发执行失败: $e');
    }
  }

  /// 示例4：脚本状态监听
  void exampleScriptStatusListening() {
    debugPrint('=== 示例4：脚本状态监听 ===');

    // 监听脚本管理器状态变化
    _scriptManager.addListener(() {
      final allScripts = _scriptManager.scripts;
      debugPrint('脚本状态更新: 共${allScripts.length}个脚本');

      for (final script in allScripts) {
        final status = _scriptManager.getScriptStatus(script.id);
        debugPrint('  ${script.name}: $status');
      }
    });
  }

  /// 示例5：脚本错误处理
  Future<void> exampleErrorHandling() async {
    debugPrint('=== 示例5：脚本错误处理 ===');

    final script = ScriptData(
      id: 'error_test_${DateTime.now().millisecondsSinceEpoch}',
      name: '错误测试脚本',
      description: '故意产生错误的脚本',
      type: ScriptType.automation,
      content: '''
log("开始错误测试脚本");

// 故意调用不存在的函数
nonExistentFunction();

log("这行不会被执行");
return "Should not reach here";
''',
      parameters: {},
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _scriptManager.addScript(script);
      await _scriptManager.executeScript(script.id);

      final result = _scriptManager.getLastResult(script.id);
      if (result != null) {
        if (result.success) {
          debugPrint('意外：错误脚本执行成功了');
        } else {
          debugPrint('预期的错误: ${result.error}');
          debugPrint('错误处理工作正常');
        }
      }
    } catch (e) {
      debugPrint('错误处理示例执行失败: $e');
    }
  }

  /// 运行所有示例
  Future<void> runAllExamples() async {
    debugPrint('🚀 开始运行新脚本系统示例...');

    try {
      await exampleSimpleLogScript();
      await Future.delayed(const Duration(milliseconds: 500));

      await exampleMapDataScript();
      await Future.delayed(const Duration(milliseconds: 500));

      await exampleConcurrentExecution();
      await Future.delayed(const Duration(milliseconds: 500));

      exampleScriptStatusListening();
      await Future.delayed(const Duration(milliseconds: 500));

      await exampleErrorHandling();

      debugPrint('✅ 所有示例执行完成！');
    } catch (e) {
      debugPrint('❌ 示例执行失败: $e');
    }
  }

  /// 清理资源
  void dispose() {
    _scriptManager.dispose();
    debugPrint('新脚本系统示例已清理');
  }

  /// 获取系统状态信息
  Map<String, dynamic> getSystemStatus() {
    final scripts = _scriptManager.scripts;
    final statuses = <String, int>{};

    for (final script in scripts) {
      final status = _scriptManager.getScriptStatus(script.id).name;
      statuses[status] = (statuses[status] ?? 0) + 1;
    }

    return {
      'totalScripts': scripts.length,
      'statusCount': statuses,
      'hasMapData': _scriptManager.hasMapData,
      'platform': kIsWeb ? 'web' : 'desktop',
      'executionEngine': kIsWeb ? 'WebWorker' : 'Isolate',
    };
  }
}

/// 快速启动示例的便捷函数
Future<void> quickStartNewScriptSystem(MapDataBloc mapDataBloc) async {
  final example = NewScriptSystemExample();

  try {
    await example.initialize(mapDataBloc);
    await example.runAllExamples();

    final status = example.getSystemStatus();
    debugPrint('系统状态: $status');
  } finally {
    example.dispose();
  }
}
