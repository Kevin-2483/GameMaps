# WebWorkerScriptExecutor 使用说明

## 概述

`WebWorkerScriptExecutor` 是为 R6Box 项目开发的 Web 平台脚本执行器，基于 `isolate_manager` 包实现，在 Web 平台上提供真正的多线程脚本执行能力。

## 主要特性

### 🚀 多线程执行
- 使用 Web Worker 在独立线程中执行 Hetu 脚本
- 避免阻塞主 UI 线程
- 支持并发脚本执行

### 🔧 完整的 API 兼容性
- 与桌面端 `IsolateScriptExecutor` 完全兼容的 API
- 支持外部函数调用
- 支持上下文变量传递
- 支持超时控制

### 💬 跨线程通信
- 主线程与 Worker 线程的双向消息传递
- 异步外部函数调用支持
- 实时日志传输

### 🛡️ 错误处理
- 健壮的异常处理机制
- 详细的错误信息和堆栈跟踪
- 优雅的资源清理

## 架构设计

### 整体架构
```
主线程 (Main Thread)              Worker 线程 (Web Worker)
┌─────────────────────┐           ┌─────────────────────┐
│ WebWorkerScript     │ 消息传递   │ hetuScriptWorker    │
│ Executor            │◄─────────►│ Function            │
├─────────────────────┤           ├─────────────────────┤
│ • 外部函数注册      │           │ • Hetu 脚本引擎     │
│ • 脚本执行控制      │           │ • 脚本代码执行      │
│ • 结果处理          │           │ • 外部函数代理      │
│ • 错误处理          │           │ • 日志记录          │
└─────────────────────┘           └─────────────────────┘
```

### 消息流程
1. **脚本执行请求**
   - 主线程发送脚本代码和上下文
   - Worker 线程接收并初始化 Hetu 引擎
   - 执行脚本并返回结果

2. **外部函数调用**
   - Worker 线程检测到外部函数调用
   - 发送函数调用请求到主线程
   - 主线程执行函数并返回结果
   - Worker 线程接收结果并继续执行

## 使用方法

### 基本使用

```dart
import 'package:your_project/services/scripting/script_executor_factory.dart';

// 创建执行器
final executor = ScriptExecutorFactory.create();

// 注册外部函数
executor.registerExternalFunction('showAlert', (String message) {
  print('Alert: $message');
});

// 执行脚本
final result = await executor.execute('''
  external fun showAlert
  
  fun main() {
    showAlert('Hello from Hetu Script!')
    return 'Script executed successfully'
  }
  
  main()
''');

print('Result: ${result.result}');
print('Success: ${result.success}');
print('Execution time: ${result.executionTime}');
```

### 高级使用

```dart
// 带上下文变量的执行
final result = await executor.execute(
  '''
  fun calculate() {
    return inputA + inputB * 2
  }
  
  calculate()
  ''',
  context: {
    'inputA': 10,
    'inputB': 20,
  },
  timeout: Duration(seconds: 30),
);

// 地图数据更新
executor.sendMapDataUpdate({
  'layers': [...],
  'markers': [...],
});

// 获取执行日志
final logs = executor.getExecutionLogs();
for (final log in logs) {
  print(log);
}

// 清理资源
executor.dispose();
```

## 技术实现细节

### isolate_manager 集成

#### Worker 函数定义
```dart
@pragma('vm:entry-point')
void hetuScriptWorkerFunction(dynamic params) {
  IsolateManagerFunction.customFunction<Map<String, dynamic>, Map<String, dynamic>>(
    params,
    onInit: (controller) async {
      await _initializeHetuEngine(controller);
    },
    onEvent: (controller, message) async {
      return await _handleWorkerMessage(controller, message);
    },
    onDispose: (controller) {
      _disposeHetuEngine();
    },
  );
}
```

#### 数据传输安全
- 所有数据通过 JSON 序列化传输
- 自动处理不可序列化的对象
- 保证线程间数据一致性

### Hetu Script 集成

#### 引擎初始化
```dart
Future<void> _initializeHetuEngine(IsolateManagerController controller) async {
  _hetuEngine = Hetu();
  _hetuEngine!.init();
  // 设置外部函数代理
  // 配置全局变量
}
```

#### 外部函数绑定
```dart
// 在 Worker 中注册函数代理
_hetuEngine!.interpreter.bindExternalFunction(
  functionName,
  (List<dynamic> positionalArgs, 
   {Map<String, dynamic> namedArgs = const {},
   List<HTType> typeArgs = const {}}) async {
    return await _callExternalFunction(controller, functionName, positionalArgs);
  },
);
```

### 错误处理机制

#### 异常捕获
- Worker 线程中的所有异常都会被捕获
- 异常信息通过消息传递到主线程
- 提供详细的错误上下文

#### 资源清理
- 自动清理 Worker 资源
- 取消未完成的异步操作
- 防止内存泄漏

## 性能优化

### 内存管理
- 限制日志数量（最多100条）
- 及时清理完成的外部函数调用
- 适时销毁不活跃的 Worker

### 执行优化
- 脚本代码预编译
- 上下文变量缓存
- 批量消息处理

## 浏览器兼容性

### 支持的浏览器
- ✅ Chrome 80+
- ✅ Firefox 75+
- ✅ Safari 13.1+
- ✅ Edge 80+

### Web Worker 支持
- ✅ Dedicated Workers
- ✅ Shared Workers（通过 isolate_manager 配置）
- ⚠️ Service Workers（不推荐用于脚本执行）

## 调试和监控

### 日志系统
```dart
// 启用调试模式
final executor = WebWorkerScriptExecutor();

// 监听日志
executor.getExecutionLogs().forEach(print);
```

### 性能监控
- 脚本执行时间统计
- Worker 线程状态监控
- 内存使用情况跟踪

## 常见问题

### Q: 脚本执行超时怎么办？
A: 设置合适的超时时间，并在脚本中避免无限循环。

### Q: 外部函数调用失败？
A: 检查函数名称是否正确注册，参数类型是否匹配。

### Q: Worker 初始化失败？
A: 确保 `isolate_manager` 正确配置，检查浏览器控制台错误信息。

### Q: 内存使用过高？
A: 定期调用 `dispose()` 清理资源，避免创建过多执行器实例。

## 未来扩展

### 计划中的功能
- [ ] WebAssembly 编译支持
- [ ] 脚本热重载
- [ ] 更多调试工具
- [ ] 性能分析器

### 贡献指南
1. Fork 项目
2. 创建功能分支
3. 提交 Pull Request
4. 等待代码审查

---

**注意**: 这是一个实验性实现，在生产环境中使用前请充分测试。
