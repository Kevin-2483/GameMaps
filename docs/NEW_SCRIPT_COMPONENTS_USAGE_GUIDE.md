# 🎯 新脚本系统组件使用指南

## 📋 组件概览

更新后的脚本系统包含以下增强组件，全部支持新的异步执行引擎：

### 1. 核心组件

#### `ReactiveScriptPanel` - 脚本管理面板
- **位置**: `lib/pages/map_editor/widgets/reactive_script_panel.dart`
- **功能**: 脚本列表、状态指示器、执行控制
- **特性**: 
  - ✅ 实时状态指示器（运行/停止/错误）
  - ✅ 动态执行控制按钮
  - ✅ 系统状态头部显示
  - ✅ 执行结果详情展示

#### `ReactiveScriptEditorWindow` - 脚本编辑器
- **位置**: `lib/pages/map_editor/widgets/script_editor_window_reactive.dart`
- **功能**: 代码编辑、语法高亮、执行状态
- **特性**:
  - ✅ 动态运行按钮（显示执行状态）
  - ✅ 实时状态监控
  - ✅ 自动保存检测

#### `ScriptStatusMonitor` - 状态监控器
- **位置**: `lib/pages/map_editor/widgets/script_status_monitor.dart`
- **功能**: 系统状态监控、执行统计、线程信息
- **特性**:
  - ✅ 紧凑/详细两种显示模式
  - ✅ 动态脉冲动画（运行中状态）
  - ✅ 执行历史记录
  - ✅ 系统指标显示

## 🚀 使用方式

### 基本集成

```dart
import 'package:flutter/material.dart';
import '../data/new_reactive_script_manager.dart';
import '../data/map_data_bloc.dart';
import '../pages/map_editor/widgets/reactive_script_panel.dart';
import '../pages/map_editor/widgets/script_status_monitor.dart';

class MyScriptInterface extends StatefulWidget {
  final MapDataBloc mapDataBloc;

  const MyScriptInterface({super.key, required this.mapDataBloc});

  @override
  State<MyScriptInterface> createState() => _MyScriptInterfaceState();
}

class _MyScriptInterfaceState extends State<MyScriptInterface> {
  late NewReactiveScriptManager _scriptManager;

  @override
  void initState() {
    super.initState();
    _scriptManager = NewReactiveScriptManager(mapDataBloc: widget.mapDataBloc);
    _scriptManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 系统状态监控（紧凑模式）
        ScriptStatusMonitor(
          scriptManager: _scriptManager,
          showDetailed: false,
        ),
        
        // 脚本管理面板
        Expanded(
          child: ReactiveScriptPanel(
            scriptManager: _scriptManager,
            onNewScript: () {
              // 处理新建脚本
            },
          ),
        ),
      ],
    );
  }
}
```

### 状态指示器特性

#### 1. 脚本状态指示器
每个脚本都有实时状态指示器：

- **空闲** (🟢): 脚本未运行，绿色圆点
- **运行中** (🟠): 脚本正在执行，橙色脉冲动画
- **暂停** (🟡): 脚本已暂停，黄色圆点  
- **错误** (🔴): 脚本执行出错，红色圆点

#### 2. 执行控制按钮
每个脚本卡片都有动态执行控制：

- **运行按钮** ▶️: 脚本空闲时显示，点击执行脚本
- **停止按钮** ⏹️: 脚本运行时显示，点击停止执行
- **按钮状态**: 根据脚本启用状态自动禁用/启用

#### 3. 系统状态头部
面板顶部显示系统整体状态：

```dart
// 系统状态头部内容
- 引擎状态指示器 (Web Worker/Isolate)
- 脚本统计信息 (总数/启用/运行中)
- 系统控制按钮 (刷新/日志/新建)
```

### 执行结果显示

#### 成功执行
```dart
// 绿色边框容器显示
✅ 执行成功 | 125ms
返回值: "Script completed successfully"
```

#### 执行失败
```dart
// 红色边框容器显示
❌ 执行失败 | 89ms
错误: ReferenceError: undefinedFunction is not defined
```

### 状态监控器使用

#### 紧凑模式（状态栏）
```dart
ScriptStatusMonitor(
  scriptManager: scriptManager,
  showDetailed: false, // 紧凑模式
)
```

显示内容：
- 系统状态指示器
- 运行中脚本数量（带脉冲动画）
- 脚本总数

#### 详细模式（面板）
```dart
ScriptStatusMonitor(
  scriptManager: scriptManager,  
  showDetailed: true, // 详细模式
)
```

显示内容：
- 完整系统指标
- 运行中脚本列表
- 最近执行历史
- 停止按钮控制

## 🎨 UI特性

### 动画效果

#### 1. 脉冲动画
运行中的脚本显示脉冲动画：
```dart
// 自动应用于：
- 状态指示器圆点
- 运行中脚本项
- 指标芯片
```

#### 2. 状态过渡
状态变化时的平滑过渡：
```dart
- 按钮状态切换
- 颜色渐变
- 尺寸变化
```

### 颜色主题

#### 状态颜色
- **空闲**: `Colors.grey` - 灰色
- **运行中**: `Theme.primaryColor` - 主题色
- **成功**: `Colors.green` - 绿色
- **错误**: `Colors.red` - 红色
- **暂停**: `Colors.orange` - 橙色

#### 类型颜色
- **自动化脚本**: `Colors.blue.withOpacity(0.2)`
- **动画脚本**: `Colors.green.withOpacity(0.2)`
- **过滤脚本**: `Colors.orange.withOpacity(0.2)`
- **统计脚本**: `Colors.purple.withOpacity(0.2)`

## 🔧 API说明

### NewReactiveScriptManager 关键方法

```dart
// 获取脚本状态
ScriptStatus getScriptStatus(String scriptId);

// 获取最后执行结果
ScriptExecutionResult? getLastResult(String scriptId);

// 执行脚本（异步，不阻塞UI）
Future<void> executeScript(String scriptId);

// 停止脚本执行
void stopScript(String scriptId);

// 获取执行日志
List<String> getExecutionLogs();

// 系统状态
bool get hasMapData;
List<ScriptData> get scripts;
Map<String, ScriptStatus> get scriptStatuses;
```

### 状态监听

```dart
// 监听脚本管理器状态变化
scriptManager.addListener(() {
  // 状态变化时的处理逻辑
  final runningCount = scriptManager.scriptStatuses.values
      .where((s) => s == ScriptStatus.running).length;
  
  if (runningCount > 0) {
    print('有 $runningCount 个脚本正在运行');
  }
});
```

## 📱 响应式特性

### 自动更新
所有组件都使用 `ListenableBuilder` 监听脚本管理器：

```dart
ListenableBuilder(
  listenable: widget.scriptManager,
  builder: (context, child) {
    // 当脚本状态变化时自动重建
    return _buildStatusIndicator();
  },
)
```

### 实时反馈
- **执行状态**: 实时显示脚本运行/停止状态
- **进度指示**: 运行中脚本显示动态进度指示器
- **结果显示**: 执行完成立即显示结果
- **错误提示**: 执行失败立即显示错误信息

## 🚨 线程安全

### 异步执行保证
1. **主线程不阻塞**: 所有脚本在隔离环境执行
2. **UI响应性**: 界面始终保持流畅响应
3. **状态同步**: 执行状态通过消息传递同步
4. **错误隔离**: 脚本错误不影响主程序

### 并发支持
- ✅ 多个脚本可同时运行
- ✅ 独立的执行状态跟踪
- ✅ 并发安全的状态更新
- ✅ 线程间通信机制

## 🎯 最佳实践

### 1. 组件集成
```dart
// 推荐的组件布局
Column(
  children: [
    // 顶部：紧凑状态监控
    ScriptStatusMonitor(showDetailed: false),
    
    // 中间：脚本管理面板
    Expanded(child: ReactiveScriptPanel()),
    
    // 底部：详细状态（可选）
    if (showDetailedStatus)
      ScriptStatusMonitor(showDetailed: true),
  ],
)
```

### 2. 状态监听
```dart
// 在需要响应脚本状态变化的地方
@override
void initState() {
  super.initState();
  scriptManager.addListener(_onScriptStateChanged);
}

void _onScriptStateChanged() {
  // 处理状态变化
  if (mounted) setState(() {});
}
```

### 3. 错误处理
```dart
// 监听执行结果
final result = scriptManager.getLastResult(scriptId);
if (result != null && !result.success) {
  // 显示错误信息
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('脚本执行失败: ${result.error}'),
      backgroundColor: Colors.red,
    ),
  );
}
```

## 🔄 迁移指南

### 从旧版本迁移

#### 1. 替换脚本管理器
```dart
// 旧版本
final scriptManager = ReactiveScriptManager();

// 新版本
final scriptManager = NewReactiveScriptManager(mapDataBloc: mapDataBloc);
await scriptManager.initialize();
```

#### 2. 更新组件导入
```dart
// 新的导入路径
import '../pages/map_editor/widgets/reactive_script_panel.dart';
import '../pages/map_editor/widgets/script_status_monitor.dart';
```

#### 3. 添加状态监控
```dart
// 添加状态监控器到现有界面
ScriptStatusMonitor(
  scriptManager: scriptManager,
  showDetailed: false,
)
```

## 🎉 新特性总结

✅ **实时状态指示器** - 动态显示脚本执行状态  
✅ **异步执行控制** - 不阻塞UI的脚本执行  
✅ **系统状态监控** - 完整的系统状态信息  
✅ **执行历史记录** - 脚本执行历史和结果  
✅ **线程安全** - 隔离执行环境  
✅ **错误隔离** - 脚本错误不影响主程序  
✅ **并发支持** - 多脚本同时运行  
✅ **响应式UI** - 状态变化实时反映  

新的脚本系统为R6Box提供了现代化、高性能、用户友好的脚本管理体验！🚀
