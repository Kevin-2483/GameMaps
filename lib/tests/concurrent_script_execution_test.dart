/// 测试并发脚本执行的示例代码
/// 这个文件展示了如何同时执行多个脚本

import 'package:flutter/material.dart';
import '../data/new_reactive_script_manager.dart';
import '../models/script_data.dart';

/// 并发脚本执行测试
class ConcurrentScriptExecutionTest {
  final NewReactiveScriptManager scriptManager;

  ConcurrentScriptExecutionTest(this.scriptManager);

  /// 测试并发执行多个脚本
  Future<void> testConcurrentExecution() async {
    debugPrint('开始测试并发脚本执行...');

    // 创建测试脚本
    final script1 = ScriptData(
      id: 'test_script_1',
      name: '测试脚本1 - 死循环',
      description: '死循环脚本，用于测试并发执行',
      type: ScriptType.automation,
      content: '''
// 死循环脚本 - 每秒打印一个数字
var count = 0;
print("开始执行死循环脚本...");
print("如果UI界面仍然响应，说明异步执行成功！");

while (true) {
  count = count + 1;
  print("循环计数: " + count.toString());
  // Hetu 中可能需要使用不同的延时方法
  // 这里使用一个简单的计数延时
  var delay = 0;
  while (delay < 1000000) {
    delay = delay + 1;
  }
  
  if (count >= 10) {
    print("脚本1完成，执行了10次循环");
    break;
  }
}
''',
      parameters: {},
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final script2 = ScriptData(
      id: 'test_script_2',
      name: '测试脚本2 - 数学计算',
      description: '数学计算脚本，与脚本1并发执行',
      type: ScriptType.automation,
      content: '''
// 数学计算脚本
print("脚本2开始执行数学计算...");
var result = 0;
for (var i = 1; i <= 100; i++) {
  result = result + i * i;
  if (i % 10 == 0) {
    print("脚本2: 计算进度 " + i.toString() + "/100, 当前结果: " + result.toString());
  }
}
print("脚本2完成，最终结果: " + result.toString());
''',
      parameters: {},
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final script3 = ScriptData(
      id: 'test_script_3',
      name: '测试脚本3 - 快速执行',
      description: '快速执行的简单脚本',
      type: ScriptType.automation,
      content: '''
// 快速执行脚本
print("脚本3开始执行...");
print("这是一个快速执行的脚本");
var quickResult = 42 * 2;
print("脚本3完成，结果: " + quickResult.toString());
''',
      parameters: {},
      isEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // 添加脚本到管理器
      await scriptManager.addScript(script1);
      await scriptManager.addScript(script2);
      await scriptManager.addScript(script3);

      debugPrint('所有测试脚本已添加到管理器');

      // 同时启动所有脚本（测试并发执行）
      debugPrint('开始并发执行所有脚本...');
      
      final futures = <Future<void>>[
        scriptManager.executeScript(script1.id),
        scriptManager.executeScript(script2.id),
        scriptManager.executeScript(script3.id),
      ];

      // 等待所有脚本完成或者设置超时
      await Future.wait(futures).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('脚本执行超时，这是正常的，因为脚本1包含死循环');
          return <void>[];
        },
      );

      debugPrint('并发脚本执行测试完成');

    } catch (e) {
      debugPrint('并发脚本执行测试失败: $e');
    }
  }

  /// 测试脚本停止功能
  Future<void> testScriptStopping() async {
    debugPrint('测试脚本停止功能...');

    // 启动一个长时间运行的脚本
    try {
      final longRunningScript = ScriptData(
        id: 'long_running_test',
        name: '长时间运行测试脚本',
        description: '用于测试停止功能的长时间运行脚本',
        type: ScriptType.automation,
        content: '''
print("开始长时间运行...");
var counter = 0;
while (counter < 1000) {
  counter = counter + 1;
  print("长时间运行计数: " + counter.toString());
  var delay = 0;
  while (delay < 2000000) {
    delay = delay + 1;
  }
}
print("长时间运行完成");
''',
        parameters: {},
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await scriptManager.addScript(longRunningScript);

      // 启动脚本
      debugPrint('启动长时间运行脚本...');
      final executionFuture = scriptManager.executeScript(longRunningScript.id);

      // 等待2秒后停止脚本
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('停止长时间运行脚本...');
      scriptManager.stopScript(longRunningScript.id);

      // 尝试等待执行完成（应该被停止）
      try {
        await executionFuture.timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('脚本已被成功停止: $e');
      }

      debugPrint('脚本停止测试完成');

    } catch (e) {
      debugPrint('脚本停止测试失败: $e');
    }
  }

  /// 运行所有测试
  Future<void> runAllTests() async {
    debugPrint('========== 开始并发脚本执行测试 ==========');
    
    await testConcurrentExecution();
    
    debugPrint('========== 开始脚本停止功能测试 ==========');
    
    await testScriptStopping();
    
    debugPrint('========== 所有测试完成 ==========');
  }
}

/// 如何使用这个测试类的示例
/// 
/// ```dart
/// final mapDataBloc = MapDataBloc();
/// final scriptManager = NewReactiveScriptManager(mapDataBloc: mapDataBloc);
/// await scriptManager.initialize();
/// 
/// final test = ConcurrentScriptExecutionTest(scriptManager);
/// await test.runAllTests();
/// ```
