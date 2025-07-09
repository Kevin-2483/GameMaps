# 协作数据模型 (Collaboration Models)

## 📋 模块职责

定义实时协作系统中的核心数据结构，包括协作操作、用户状态、网络信息等。

## 🏗️ 架构设计

### 设计原则
- **类型安全**：使用强类型定义确保数据一致性
- **序列化友好**：支持JSON序列化用于网络传输
- **版本兼容**：支持向后兼容的数据结构演进
- **性能优化**：最小化内存占用和序列化开销

### 核心数据流
```
MapDataEvent → CollaborativeOperation → 网络传输 → CollaborativeOperation → MapDataEvent
```

## 📁 文件结构

```
models/
├── collaborative_operation.dart    # 协作操作数据结构
├── user_presence.dart             # 用户在线状态
├── network_metrics.dart           # 网络质量指标
├── conflict_data.dart             # 冲突检测数据
├── vector_clock.dart              # 向量时钟实现
├── message_envelope.dart          # 消息封装结构
├── topology_info.dart             # 网络拓扑信息
└── sync_state.dart                # 同步状态数据
```

## 🔧 核心模型说明

### CollaborativeOperation
**用途**：表示用户的协作操作
**关键字段**：
- `id`: 操作唯一标识
- `userId`: 操作用户ID
- `type`: 操作类型 (addLayer, updateLayer等)
- `data`: 操作数据
- `vectorClock`: 向量时钟
- `timestamp`: 时间戳

### UserPresence
**用途**：跟踪用户在线状态和活动
**关键字段**：
- `userId`: 用户ID
- `status`: 在线状态
- `lastActivity`: 最后活动时间
- `cursorPosition`: 光标位置
- `selectedElements`: 选中元素

### NetworkMetrics
**用途**：网络质量监控和拓扑决策
**关键字段**：
- `bandwidth`: 带宽
- `latency`: 延迟
- `packetLoss`: 丢包率
- `stability`: 连接稳定性

## 🔄 数据转换

### MapDataEvent → CollaborativeOperation
```dart
CollaborativeOperation fromMapDataEvent(MapDataEvent event) {
  return CollaborativeOperation(
    type: _mapEventType(event.runtimeType),
    data: _extractEventData(event),
    // ...
  );
}
```

### CollaborativeOperation → MapDataEvent
```dart
MapDataEvent toMapDataEvent(CollaborativeOperation operation) {
  switch (operation.type) {
    case OperationType.addLayer:
      return AddLayer.fromJson(operation.data);
    // ...
  }
}
```

## 📊 性能考虑

- **序列化优化**：使用高效的JSON序列化
- **内存管理**：及时清理过期数据
- **批量处理**：支持操作批量打包
- **压缩传输**：大数据自动压缩

## 🧪 测试策略

- **单元测试**：每个模型的序列化/反序列化
- **性能测试**：大数据量的序列化性能
- **兼容性测试**：不同版本间的数据兼容性

## 📝 开发规范

1. **命名规范**：使用清晰的英文命名
2. **文档注释**：为每个字段添加详细注释
3. **类型安全**：避免使用dynamic类型
4. **序列化支持**：实现toJson/fromJson方法
5. **等值比较**：实现Equatable接口

## 🔗 依赖关系

- **上游依赖**：无
- **下游依赖**：services/, blocs/, sync/
- **外部依赖**：equatable, json_annotation

## 📋 开发清单

- [ ] CollaborativeOperation基础结构
- [ ] UserPresence用户状态
- [ ] NetworkMetrics网络指标
- [ ] VectorClock向量时钟
- [ ] ConflictData冲突数据
- [ ] MessageEnvelope消息封装
- [ ] TopologyInfo拓扑信息
- [ ] SyncState同步状态
- [ ] 序列化测试
- [ ] 性能基准测试