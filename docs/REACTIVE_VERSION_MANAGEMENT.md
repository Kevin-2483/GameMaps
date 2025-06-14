# 响应式版本管理系统设计文档

## 概述

响应式版本管理系统是R6Box地图编辑器的新一代版本管理解决方案，专门为响应式数据管理系统设计。它只负责会话内存中的版本状态管理，不涉及数据持久化，与VFS地图服务的版本参数协同工作。

## 核心特性

### 🎯 会话内存管理
- 只在内存中管理版本状态
- 版本间数据完全隔离
- 支持随时切换版本
- 不会在会话中主动保存数据

### 🔄 响应式集成
- 完全集成响应式数据管理系统
- 与MapDataBloc无缝协作
- 自动同步版本状态变化
- 支持实时数据更新

### 📋 版本操作
- 创建、删除、切换版本
- 版本数据复制和隔离
- 版本状态追踪
- 未保存更改检测

## 系统架构

### 核心组件

#### 1. ReactiveVersionManager
版本状态管理核心，负责：
- 版本会话状态存储
- 版本数据缓存管理
- 版本切换逻辑
- 更改状态追踪

#### 2. ReactiveVersionAdapter  
版本管理与MapDataBloc的集成适配器，负责：
- 版本状态与地图数据同步
- 版本切换时的数据加载
- 保存操作的协调
- 循环更新防护

#### 3. ReactiveVersionMixin
为页面提供版本管理功能的混入类，提供：
- 简化的版本操作API
- 统一的错误处理
- 资源管理
- 状态查询

### 数据流设计

```
用户操作
    ↓
ReactiveVersionManager (版本状态管理)
    ↓
ReactiveVersionAdapter (数据同步适配)
    ↓
MapDataBloc (响应式数据管理)
    ↓
VFS地图服务 (持久化存储)
```

## 关键设计原则

### 1. 会话导向
- 版本管理只在当前会话中有效
- 不主动触发数据持久化
- 支持多版本并行编辑

### 2. 响应式优先
- 完全基于响应式数据流
- 状态变化自动通知
- 避免手动状态同步

### 3. 数据隔离
- 每个版本独立的数据空间
- 版本间操作不相互影响
- 切换版本时数据自动切换

### 4. 最小侵入
- 与现有系统无缝集成
- 不破坏原有架构
- 渐进式迁移支持

## 核心API

### ReactiveVersionManager

```dart
class ReactiveVersionManager extends ChangeNotifier {
  // 版本创建与管理
  ReactiveVersionState initializeVersion(String versionId, {...});
  ReactiveVersionState createVersion(String versionId, {...});
  void deleteVersion(String versionId);
  
  // 版本切换与编辑
  void switchToVersion(String versionId);
  void startEditingVersion(String versionId);
  void stopEditingVersion();
  
  // 数据更新
  void updateVersionData(String versionId, MapItem newData, {...});
  void updateVersionLayers(String versionId, List<MapLayer> layers, {...});
  void updateVersionLegendGroups(String versionId, List<LegendGroup> legendGroups, {...});
  
  // 状态管理
  void markVersionSaved(String versionId);
  void markAllVersionsSaved();
  bool hasUnsavedChanges(String versionId);
  bool get hasAnyUnsavedChanges;
}
```

### ReactiveVersionAdapter

```dart
class ReactiveVersionAdapter {
  // 版本操作与数据加载
  Future<void> switchToVersionAndLoad(String versionId);
  Future<ReactiveVersionState> createVersionAndSwitch(String versionId, {...});
  
  // 数据保存
  Future<void> saveCurrentVersion();
  Future<void> saveAllVersions();
  
  // 版本管理
  Future<void> deleteVersionCompletely(String versionId);
  Future<ReactiveVersionState> duplicateVersionCompletely(String sourceVersionId, String newVersionId, {...});
}
```

### ReactiveVersionMixin

```dart
mixin ReactiveVersionMixin<T extends StatefulWidget> on State<T> {
  // 初始化
  void initializeVersionManagement({required String mapTitle, required MapDataBloc mapDataBloc});
  
  // 版本操作
  Future<void> switchVersion(String versionId);
  Future<ReactiveVersionState?> createVersion(String versionId, {...});
  Future<void> deleteVersion(String versionId);
  Future<void> saveCurrentVersion();
  
  // 状态查询
  bool get hasUnsavedChanges;
  String? get currentVersionId;
  List<ReactiveVersionState> get allVersionStates;
}
```

## 使用场景

### 1. 地图编辑器集成

```dart
class _MapEditorPageState extends State<MapEditorPage> 
    with MapEditorReactiveMixin, ReactiveVersionMixin {
  
  @override
  void initState() {
    super.initState();
    // 初始化响应式系统
    await initializeReactiveSystem();
    
    // 初始化版本管理
    initializeVersionManagement(
      mapTitle: widget.mapTitle!,
      mapDataBloc: reactiveIntegration.mapDataBloc,
    );
  }
  
  // 版本操作示例
  void _createNewVersion() async {
    await createVersion(
      'version_${DateTime.now().millisecondsSinceEpoch}',
      versionName: '新建版本',
      sourceVersionId: currentVersionId,
    );
  }
}
```

### 2. 版本切换

```dart
// 用户选择切换版本
void _switchToVersion(String versionId) async {
  try {
    await switchVersion(versionId);
    _showSuccessMessage('已切换到版本: $versionId');
  } catch (e) {
    _showErrorMessage('切换版本失败: $e');
  }
}
```

### 3. 保存管理

```dart
// 退出前检查未保存更改
void _onWillPop() async {
  if (hasUnsavedChanges) {
    final result = await _showSaveDialog();
    if (result == SaveAction.save) {
      await saveCurrentVersion();
    }
  }
}
```

## 与VFS系统协作

### 版本参数传递
```dart
// 版本管理器只管理内存状态
versionManager.switchToVersion('version_1');

// 实际数据加载/保存通过VFS服务的version参数
await mapService.getMapLayers(mapTitle, 'version_1');
await mapService.saveLayer(mapTitle, layer, 'version_1');
```

### 保存时机
- 只有用户主动保存或退出时才保存数据
- 版本切换时自动加载对应版本数据
- 支持批量保存所有版本

## 性能优化

### 内存管理
- 版本数据智能缓存
- 长时间未使用版本自动清理
- 大数据对象引用共享

### 响应优化
- 防止循环更新机制
- 批量状态变更通知
- 异步操作队列管理

## 错误处理

### 版本状态验证
```dart
bool validateVersionStates() {
  // 检查版本ID有效性
  // 验证数据缓存一致性
  // 确认状态完整性
}
```

### 异常恢复
- 版本状态损坏时自动修复
- 数据丢失时从VFS重新加载
- 操作失败时状态回滚

## 调试支持

### 状态监控
```dart
Map<String, dynamic> getDebugInfo() {
  return {
    'mapTitle': mapTitle,
    'currentVersionId': currentVersionId,
    'totalVersions': _versionStates.length,
    'unsavedVersions': unsavedVersions,
    'versionStates': /* 详细状态信息 */,
  };
}
```

### 日志记录
- 版本操作日志
- 数据同步日志
- 错误恢复日志

## 迁移指南

### 从原版本管理器迁移

1. **保持API兼容性**
   - 现有版本管理代码无需大幅修改
   - 渐进式替换原有实现

2. **数据迁移**
   - 原有版本数据自动适配
   - 版本状态平滑过渡

3. **功能增强**
   - 更好的响应式集成
   - 更完善的错误处理
   - 更高的性能表现

### 集成步骤

1. 添加ReactiveVersionMixin到页面
2. 在initState中初始化版本管理
3. 替换版本操作调用
4. 在dispose中清理资源

## 最佳实践

### 1. 版本命名
- 使用有意义的版本名称
- 包含时间戳避免冲突
- 提供版本描述信息

### 2. 数据管理
- 及时标记已保存状态
- 定期清理无用版本
- 监控内存使用情况

### 3. 用户体验
- 版本切换前确认未保存更改
- 提供清晰的版本状态指示
- 支持版本操作撤销

### 4. 错误处理
- 捕获所有版本操作异常
- 提供用户友好的错误信息
- 实现自动错误恢复机制

## 总结

响应式版本管理系统为R6Box提供了现代化的版本管理能力，完美集成响应式数据管理架构，专注于会话内存管理，与VFS持久化系统协同工作。系统设计简洁高效，API友好易用，为用户提供流畅的版本管理体验。
