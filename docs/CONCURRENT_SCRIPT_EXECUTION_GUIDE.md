# 🚀 R6Box 并发脚本执行系统使用指南

## 📋 概述

R6Box 现在支持真正的并发脚本执行！您可以同时运行多个脚本，而不再受到"Script is already running"错误的限制。

## 🏗️ 新架构特性

### 1. 执行器池设计
- **多执行器**: 每个脚本使用独立的执行器实例
- **并发限制**: 默认支持最多5个并发脚本（可配置）
- **资源管理**: 自动清理完成的脚本执行器

### 2. 真正的异步执行
- **非阻塞**: 脚本在独立的Isolate/Worker中运行
- **UI响应**: 主界面保持完全响应
- **错误隔离**: 单个脚本错误不影响其他脚本

### 3. 智能资源管理
- **按需创建**: 只为运行中的脚本创建执行器
- **自动清理**: 脚本完成后自动释放资源
- **内存优化**: 避免资源泄漏

## 💻 使用方法

### 基本并发执行

```dart
// 创建脚本管理器
final scriptManager = NewReactiveScriptManager(
  mapDataBloc: mapDataBloc,
  maxConcurrentExecutors: 5, // 可选：设置最大并发数
);

// 添加多个脚本
await scriptManager.addScript(script1);
await scriptManager.addScript(script2);
await scriptManager.addScript(script3);

// 并发执行所有脚本
final futures = [
  scriptManager.executeScript(script1.id),
  scriptManager.executeScript(script2.id),
  scriptManager.executeScript(script3.id),
];

// 等待所有脚本完成
await Future.wait(futures);
```

### 监听执行状态

```dart
// 监听脚本状态变化
scriptManager.addListener(() {
  for (final script in scriptManager.scripts) {
    final status = scriptManager.getScriptStatus(script.id);
    final result = scriptManager.getLastResult(script.id);
    
    print('脚本 ${script.name}: $status');
    if (result != null) {
      print('  结果: ${result.success ? "成功" : "失败"}');
      if (!result.success) {
        print('  错误: ${result.error}');
      }
    }
  }
});
```

### 脚本停止和错误处理

```dart
try {
  // 启动脚本
  final executionFuture = scriptManager.executeScript(scriptId);
  
  // 设置超时或手动停止
  Timer(Duration(seconds: 30), () {
    scriptManager.stopScript(scriptId);
  });
  
  await executionFuture;
} catch (e) {
  print('脚本执行失败: $e');
}
```

## 🔧 配置选项

### 并发执行器配置

```dart
final scriptManager = NewReactiveScriptManager(
  mapDataBloc: mapDataBloc,
  maxConcurrentExecutors: 10, // 最大并发数（默认：5）
);
```

### 脚本超时设置

```dart
final script = ScriptData(
  // ... 其他属性
  timeout: Duration(seconds: 60), // 设置脚本超时时间
);
```

## 📊 性能监控

### 获取执行统计

```dart
// 获取当前运行中的脚本数量
final runningCount = scriptManager.scriptStatuses.values
    .where((status) => status == ScriptStatus.running)
    .length;

print('当前运行中的脚本: $runningCount');

// 获取执行日志
final logs = scriptManager.getExecutionLogs();
for (final log in logs) {
  print('执行日志: $log');
}
```

### 监控资源使用

```dart
// 检查执行器池状态
final engineLogs = scriptManager.reactiveEngine.getExecutionLogs();
print('引擎状态: ${engineLogs.join("\\n")}');
```

## ⚡ 最佳实践

### 1. 脚本设计
```dart
// 推荐：在循环中添加适当的延时
while (condition) {
  // 执行逻辑
  doSomething();
  
  // 添加小延时，让出CPU时间
  await sleep(10); // 毫秒
}

// 推荐：定期检查停止信号
while (condition && !shouldStop()) {
  doSomething();
}
```

### 2. 错误处理
```dart
try {
  await scriptManager.executeScript(scriptId);
} catch (e) {
  if (e.toString().contains('达到最大并发数限制')) {
    // 等待其他脚本完成
    await Future.delayed(Duration(seconds: 1));
    // 重试
    await scriptManager.executeScript(scriptId);
  } else {
    // 其他错误处理
    handleError(e);
  }
}
```

### 3. 资源管理
```dart
// 在应用关闭时清理资源
@override
void dispose() {
  scriptManager.dispose(); // 自动清理所有执行器
  super.dispose();
}
```

## 🔍 故障排除

### 常见问题

#### 1. "达到最大并发数限制"
```dart
// 解决方案1：增加并发数限制
final scriptManager = NewReactiveScriptManager(
  mapDataBloc: mapDataBloc,
  maxConcurrentExecutors: 10, // 增加到10
);

// 解决方案2：等待其他脚本完成
final runningScripts = scriptManager.scriptStatuses.entries
    .where((entry) => entry.value == ScriptStatus.running)
    .map((entry) => entry.key)
    .toList();

if (runningScripts.length >= maxConcurrentExecutors) {
  // 停止最老的脚本
  scriptManager.stopScript(runningScripts.first);
}
```

#### 2. 脚本无响应
```dart
// 设置执行超时
final script = ScriptData(
  // ... 其他属性
  content: '''
// 在脚本中添加定期检查
while (condition) {
  if (shouldTimeout()) {
    print("脚本主动退出");
    break;
  }
  doSomething();
}
''',
);
```

#### 3. 内存使用过高
```dart
// 定期清理完成的脚本
Timer.periodic(Duration(minutes: 5), (timer) {
  scriptManager.cleanupCompletedExecutors();
});
```

## 🎯 示例场景

### 场景1：批量数据处理
```dart
// 同时处理多个数据集
final dataFiles = ['data1.json', 'data2.json', 'data3.json'];
final futures = dataFiles.map((file) {
  final script = createDataProcessingScript(file);
  return scriptManager.executeScript(script.id);
});

await Future.wait(futures);
print('所有数据处理完成');
```

### 场景2：实时监控多个指标
```dart
// 同时监控不同的地图指标
final monitoringScripts = [
  'layer_count_monitor',
  'performance_monitor', 
  'user_activity_monitor',
];

for (final scriptId in monitoringScripts) {
  scriptManager.executeScript(scriptId); // 不等待完成
}

print('所有监控脚本已启动');
```

### 场景3：渐进式数据更新
```dart
// 分批更新地图数据
final batches = splitDataIntoBatches(largeDataSet);
for (int i = 0; i < batches.length; i++) {
  final script = createUpdateScript(batches[i], i);
  scriptManager.executeScript(script.id);
  
  // 控制并发数，避免过载
  if (i % 3 == 0) {
    await Future.delayed(Duration(seconds: 1));
  }
}
```

## 🎉 升级说明

### 从旧版本升级

如果您之前使用的是单线程脚本执行，现在可以：

1. **直接替换**: 新的管理器完全向后兼容
2. **移除等待**: 不再需要等待前一个脚本完成
3. **添加并发**: 可以同时执行多个脚本

```dart
// 旧版本（串行执行）
await scriptManager.executeScript(script1.id);
await scriptManager.executeScript(script2.id);
await scriptManager.executeScript(script3.id);

// 新版本（并发执行）
await Future.wait([
  scriptManager.executeScript(script1.id),
  scriptManager.executeScript(script2.id),
  scriptManager.executeScript(script3.id),
]);
```

## 📚 技术细节

### 架构组件

1. **NewReactiveScriptEngine**: 管理执行器池
2. **ConcurrentIsolateScriptExecutor**: 支持并发的Isolate执行器
3. **ScriptExecutorFactory**: 根据平台创建适当的执行器
4. **消息传递系统**: 主线程与Worker线程通信

### 消息流程

```
主线程              Worker线程
   |                    |
   |-- 执行请求 -->      |
   |                    |-- 初始化Hetu引擎
   |                    |-- 执行脚本代码
   |                    |-- 调用外部函数
   |<- 函数调用请求 --    |
   |-- 函数结果 -->      |
   |                    |-- 继续执行
   |<- 执行结果 --       |
```

现在您可以充分利用R6Box的并发脚本执行能力，提高工作效率！🚀
