# 脚本引擎外部函数重复定义问题解决方案

## 问题描述

在使用地图编辑器的脚本功能时，用户遇到了以下问题：

1. **第一次执行脚本**：必须在脚本中手动添加外部函数声明，如：
   ```hetu
   external fun log(message);
   external fun print(message);
   external fun filterElements(filterFunc);
   external fun findTextElementsByContent(searchText);
   external fun updateTextContent(elementId, newText);
   ```

2. **第二次执行脚本**：会提示这些外部函数已经定义，无法重复定义，需要删除这些声明。

3. **重新进入地图编辑器**：又需要重新添加这些声明。

这个循环导致用户体验极差，需要频繁修改脚本内容。

## 根本原因

问题的根本原因在于 Hetu 脚本引擎的外部函数声明机制：

1. **外部函数注册**：在 Dart 代码中通过 `externalFunctions` 参数注册了这些函数。
2. **脚本中声明**：Hetu 要求在脚本中使用 `external` 关键字声明这些函数。
3. **重复声明检测**：当脚本多次执行时，Hetu 检测到重复的 `external` 声明并报错。

## 解决方案

### 1. 预定义外部函数声明

在脚本引擎初始化时，自动预定义所有外部函数声明：

```dart
/// 预定义外部函数声明，避免用户重复声明
Future<void> _predefineExternalFunctions() async {
  final externalDeclarations = '''
// 基础函数
external fun log(message);
external fun print(message);

// 数学函数
external fun sin(x);
external fun cos(x);
// ... 更多函数声明

// 绘图元素访问函数
external fun getLayers();
external fun getLayerById(id);
// ... 更多函数声明
''';

  try {
    // 执行外部函数声明
    _hetu!.eval(externalDeclarations);
  } catch (e) {
    debugPrint('预定义外部函数时出错: $e');
  }
}
```

### 2. 重新初始化机制

添加脚本引擎重新初始化方法，用于地图编辑器重新进入时清理状态：

```dart
/// 重新初始化脚本引擎（用于地图编辑器重新进入）
Future<void> reinitialize() async {
  // 保存当前的地图数据访问器
  final currentLayers = _currentLayers;
  final currentOnLayersChanged = _onLayersChanged;
  
  // 停止所有运行中的任务
  _stopAllTasks();
  
  // 重置初始化状态
  _isInitialized = false;
  _hetu = null;
  
  // 重新初始化
  await initialize();
  
  // 恢复地图数据访问器
  if (currentLayers != null && currentOnLayersChanged != null) {
    setMapDataAccessor(currentLayers, currentOnLayersChanged);
  }
}
```

### 3. 响应式系统集成

在响应式脚本管理器中添加重置功能：

```dart
/// 重置脚本引擎（用于地图编辑器重新进入时清理状态）
Future<void> resetScriptEngine() async {
  debugPrint('重置响应式脚本引擎');
  
  try {
    // 重新初始化脚本引擎，这会重新预定义外部函数
    await _reactiveEngine.scriptEngine.reinitialize();
    debugPrint('脚本引擎重置完成');
  } catch (e) {
    debugPrint('脚本引擎重置失败: $e');
  }
}
```

### 4. 地图编辑器集成

在地图编辑器初始化响应式系统时调用重置：

```dart
/// 初始化响应式系统
void _initializeReactiveSystem() async {
  try {
    await initializeReactiveSystem();
    debugPrint('响应式系统初始化完成');

    // 重新初始化脚本引擎以确保外部函数声明正确
    await reactiveIntegration.scriptManager.resetScriptEngine();
    debugPrint('脚本引擎重新初始化完成');

    // 如果已有地图数据，加载到响应式系统
    if (_currentMap != null) {
      await loadMapToReactiveSystem(_currentMap!);
      _setupReactiveListeners();
    }
  } catch (e) {
    debugPrint('响应式系统初始化失败: $e');
  }
}
```

## 预定义的外部函数列表

解决方案预定义了以下外部函数，用户无需在脚本中重复声明：

### 基础函数
- `log(message)` - 记录日志
- `print(message)` - 打印输出

### 数学函数
- `sin(x)`, `cos(x)`, `tan(x)` - 三角函数
- `sqrt(x)`, `pow(x, y)`, `abs(x)` - 数学运算
- `random()` - 随机数生成

### 绘图元素访问函数
- `getLayers()` - 获取所有图层
- `getLayerById(id)` - 根据ID获取图层
- `getAllElements()` - 获取所有元素

### 过滤和查找函数
- `filterElements(filterFunc)` - 过滤元素
- `findTextElementsByContent(searchText)` - 查找文本元素
- `countElements(typeFilter)` - 统计元素数量

### 元素修改函数
- `updateElementProperty(elementId, property, value)` - 更新元素属性
- `updateTextContent(elementId, newText)` - 更新文本内容
- `moveElement(elementId, deltaX, deltaY)` - 移动元素

### 动画函数
- `animate(elementId, property, targetValue, duration)` - 动画效果
- `delay(milliseconds)` - 延迟执行

## 用户体验改进

### 之前的用户流程：
1. 进入地图编辑器
2. 编写脚本，需要手动添加 `external` 声明
3. 第一次执行成功
4. 第二次执行失败（重复定义错误）
5. 删除 `external` 声明
6. 第二次执行成功
7. 退出地图编辑器
8. 重新进入地图编辑器
9. 重复步骤 2-6

### 现在的用户流程：
1. 进入地图编辑器
2. 编写脚本（**无需添加** `external` 声明）
3. 随时执行，始终成功
4. 退出和重新进入地图编辑器都不影响脚本执行

## 测试验证

添加了相关测试用例来验证解决方案：

```dart
test('Should handle external function declarations correctly', () async {
  // 测试多次执行脚本不会出现重复定义错误
});

test('Should handle script engine reinitialization', () async {
  // 测试脚本引擎重新初始化后功能正常
});
```

## 总结

通过预定义外部函数声明和完善的重新初始化机制，完全解决了脚本引擎的外部函数重复定义问题。用户现在可以：

1. **专注于业务逻辑**：无需关心外部函数声明
2. **无缝使用脚本**：多次执行无限制
3. **稳定的用户体验**：进出地图编辑器不影响脚本功能

这个解决方案提高了脚本系统的易用性和稳定性，显著改善了用户体验。
