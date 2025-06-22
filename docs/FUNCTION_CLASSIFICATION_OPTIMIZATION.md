# 主线程函数分类优化 - 实现总结

## 概述
根据您的需求，将主线程的函数调用分为两类：
1. **需要等待结果的函数**：主要是数据读取、查找类函数
2. **不关心结果的函数**：主要是修改、更新、日志类函数

## 实现的改动

### 1. 函数分类定义 (`external_function_registry.dart`)

#### 需要等待结果的函数（读取类）：
- `getLayers`, `getLayerById`, `getElementsInLayer`, `getAllElements`
- `countElements`, `calculateTotalArea`
- `getTextElements`, `findTextElementsByContent`
- `readjson`
- `getStickyNotes`, `getStickyNoteById`, `getElementsInStickyNote`
- `filterStickyNotesByTags`, `filterStickyNoteElementsByTags`
- `getLegendGroups`, `getLegendGroupById`, `getLegendItems`, `getLegendItemById`
- `filterLegendGroupsByTags`, `filterLegendItemsByTags`

#### 不需要等待结果的函数（Fire and Forget）：
- `log`, `print`
- `updateElementProperty`, `moveElement`
- `createTextElement`, `updateTextContent`, `updateTextSize`, `say`
- `writetext`
- `updateLegendGroup`, `updateLegendGroupVisibility`, `updateLegendGroupOpacity`, `updateLegendItem`

### 2. Worker 端改动 (`hetu_script_worker.dart`)

- 在函数绑定时检查函数类型，区别处理
- 对于需要等待结果的函数：使用 `_callExternalFunction`，等待主线程响应
- 对于不需要等待结果的函数：使用 `_callFireAndForgetFunction`，立即返回 null
- 新增消息类型：`fireAndForgetFunctionCall`

### 3. 主线程改动

#### Web Worker 执行器 (`concurrent_web_worker_script_executor.dart`, `web_worker_script_executor.dart`)
- 新增 `_handleFireAndForgetFunctionCall` 方法
- 处理 `fireAndForgetFunctionCall` 消息类型
- Fire and Forget 函数只执行，不发送响应

#### Isolate 执行器 (`isolated_script_executor.dart`, `concurrent_isolate_script_executor.dart`)
- 更新 `createFunctionsForIsolate` 调用，提供两个函数参数
- 新增 `_callFireAndForgetFunction` 方法
- 更新消息处理，支持 `fireAndForgetFunctionCall` 类型

### 4. 消息类型扩展 (`script_executor_base.dart`)
- 在 `ScriptMessageType` 枚举中添加 `fireAndForgetFunctionCall`

## 性能优化效果

### 1. 减少不必要的等待
- 日志、更新类函数不再阻塞脚本执行
- 减少跨线程通信的往返时间
- 提高脚本执行效率

### 2. 异步执行优化
- Fire and Forget 函数立即返回，脚本可以继续执行
- 主线程可以异步处理这些函数调用
- 减少内存中的 Completer 对象数量

### 3. 错误处理优化
- Fire and Forget 函数的错误不会影响脚本执行
- 错误只记录日志，不传播到脚本层

## 使用示例

```hetu
fun main() {
  // 需要等待结果的函数
  var layers = getLayers();           // 等待返回
  var count = countElements();        // 等待返回
  
  // 不需要等待结果的函数
  log('开始处理...');                 // 立即返回 null
  updateElementProperty('id', 'color', '#FF0000');  // 立即返回 null
  
  // 混合使用
  var elements = getAllElements();    // 等待返回
  log('处理了 ${elements.length} 个元素');  // 立即返回 null
}
```

## 测试

可以使用 `test_function_classification.ht` 脚本来测试函数分类的正确性和性能差异。

## 向后兼容性

- 所有现有脚本无需修改
- 函数调用方式保持不变
- 只是内部实现优化，外部接口不变
