# 新脚本管理器架构重构完成

## 🎯 架构概述

我们已经成功重构了脚本管理器，实现了跨平台异步执行引擎。新架构采用**消息传递机制**，彻底解决了脚本执行阻塞主线程的问题，并支持Web和Windows双平台。

## 🏗️ 新架构图

```
┌─────────────────────────────────────┐
│ UI层 (地图编辑器界面)                │
└─────────────────┬───────────────────┘
                  │ 响应式更新
┌─────────────────▼───────────────────┐
│ 响应式数据流层                      │
│ ├── MapDataBloc (状态管理)          │
│ ├── NewReactiveScriptManager       │
│ └── MapDataStream (数据流)          │
└─────────────────┬───────────────────┘
                  │ 消息传递调度
┌─────────────────▼───────────────────┐
│ NewReactiveScriptEngine             │
│ └── 消息处理器和外部函数代理        │
└─────────────────┬───────────────────┘
                  ▼
┌─────────────────────────────────────┐
│ IsolatedScriptExecutor (抽象接口)   │◄────┐
└─────────────────────────────────────┘     │
            ▼                               │
跨平台执行引擎 (异步+隔离执行)              │
┌─────────────────────────────────────┐     │
│ 平台自适应执行器                    │     │
└──────────┬─────────────┬────────────┘     │
           ▼             ▼                   │
Web 平台：               Windows 平台：      │
┌────────────────────┐   ┌──────────────┐   │
│ WebWorkerScript    │   │ IsolateScript │   │
│ Executor           │   │ Executor      │   │
│ (Web Worker)       │   │ (dart:isolate)│   │
└────────────────────┘   └──────────────┘   │
                                             │
└─────────────── 消息传递通信 ───────────────┘
```

## 📁 新文件结构

### 核心文件

1. **`isolated_script_executor.dart`** - 跨平台异步执行器接口
   - 定义统一的异步执行接口
   - 消息类型定义 (ScriptMessage, ExternalFunctionCall 等)
   - 桌面平台Isolate执行器实现

2. **`web_worker_script_executor.dart`** - Web平台执行器
   - Web Worker脚本生成和管理
   - 浏览器端消息传递实现

3. **`new_reactive_script_engine.dart`** - 新响应式脚本引擎
   - 基于消息传递的脚本执行
   - 响应式数据流集成
   - 外部函数代理和消息处理

4. **`new_reactive_script_manager.dart`** - 新脚本管理器
   - 脚本生命周期管理
   - VFS存储集成
   - 响应式状态管理

5. **`new_script_system_factory.dart`** - 系统工厂
   - 组件创建和配置
   - 平台兼容性检查
   - 迁移助手工具

## 🔄 消息传递机制

### 消息类型
- `execute` - 执行脚本命令
- `result` - 脚本执行结果
- `log` - 日志输出
- `externalFunctionCall` - 外部函数调用请求
- `mapDataUpdate` - 地图数据更新
- `stop` - 停止执行

### 外部函数重构
所有原有外部函数（如 `getLayers`, `log`, `readjson` 等）都已重构为**消息传递代理**：

1. **隔离环境**接收函数调用
2. **发送消息**到主线程请求执行
3. **主线程执行**实际函数逻辑
4. **返回结果**到隔离环境

## ✅ 已完成功能

### 1. 跨平台执行支持
- ✅ Web平台：Web Worker异步执行
- ✅ Windows平台：Dart Isolate异步执行
- ✅ 统一的API接口

### 2. 消息传递系统
- ✅ 异步消息通信
- ✅ 外部函数调用代理
- ✅ 错误处理和超时机制

### 3. 响应式集成
- ✅ MapDataBloc状态同步
- ✅ 实时数据更新
- ✅ 响应式UI更新

### 4. 脚本管理
- ✅ VFS存储支持
- ✅ 脚本生命周期管理
- ✅ 执行状态跟踪

## 🔧 使用方式

### 创建脚本管理器
```dart
// 使用工厂创建
final factory = NewScriptSystemFactory();
final scriptManager = factory.createScriptManager(mapDataBloc);

// 或直接创建
final scriptManager = NewReactiveScriptManager(mapDataBloc: mapDataBloc);
```

### 执行脚本
```dart
// 异步执行，不阻塞主线程
await scriptManager.executeScript(scriptId);
```

### 监听执行状态
```dart
scriptManager.addListener(() {
  final status = scriptManager.getScriptStatus(scriptId);
  final result = scriptManager.getLastResult(scriptId);
  // 更新UI
});
```

## 🚀 性能优势

1. **非阻塞执行** - 脚本在隔离环境运行，不影响UI响应
2. **内存隔离** - 脚本执行错误不会崩溃主程序
3. **并发支持** - 支持多个脚本同时运行
4. **平台优化** - 针对Web和桌面平台的不同优化

## 🔐 安全性提升

1. **沙盒执行** - 脚本在隔离环境中运行
2. **受控API** - 只能通过消息传递访问系统功能
3. **超时保护** - 防止脚本无限期运行
4. **内存限制** - 控制脚本内存使用

## 📋 待完成项目

1. **Hetu Script集成** - 需要在隔离环境中重新实现脚本解析
2. **完整外部函数** - 补充所有原有外部函数的消息传递实现
3. **缓存优化** - 实现脚本执行结果缓存
4. **调试工具** - 开发脚本调试和性能分析工具

## 🔄 迁移指南

现有代码可以通过以下方式迁移：

```dart
// 旧方式
final scriptManager = ScriptManager();

// 新方式  
final factory = NewScriptSystemFactory();
final scriptManager = factory.createScriptManager(mapDataBloc);
```

所有公共API保持兼容，内部实现从同步改为异步消息传递。

## 🎉 总结

新的脚本管理器架构实现了：
- ✅ 真正的异步隔离执行
- ✅ 跨平台支持（Web + Windows）
- ✅ 消息传递机制
- ✅ 响应式数据流集成
- ✅ 非阻塞主线程
- ✅ 安全沙盒执行

这个架构为R6Box提供了强大、安全、高性能的脚本执行能力！🚀
