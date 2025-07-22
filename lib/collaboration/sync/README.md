# 数据同步层 (Data Synchronization Layer)

## 📋 模块职责

负责实时协作中的数据同步、操作转换(OT)、CRDT集成和版本控制，确保多用户环境下的数据一致性和操作顺序。

## 🏗️ 架构设计

### 同步层架构图
```
┌─────────────────────────────────────────────────────────┐
│                 Data Sync Layer                         │
├─────────────────────────────────────────────────────────┤
│  Operation Transform │    CRDT Engine    │  Version Ctrl │
│  ┌─────────────────┐ │ ┌───────────────┐ │ ┌────────────┐ │
│  │ OT Processor    │ │ │ CRDT Manager  │ │ │ Version    │ │
│  │ Transform Rules │ │ │ Merge Logic   │ │ │ History    │ │
│  └─────────────────┘ │ └───────────────┘ │ └────────────┘ │
├─────────────────────────────────────────────────────────┤
│  Sync Coordinator   │  Change Detector  │  State Manager │
│  ┌─────────────────┐ │ ┌───────────────┐ │ ┌────────────┐ │
│  │ Sync Strategy   │ │ │ Delta Calc    │ │ │ Sync State │ │
│  │ Conflict Res    │ │ │ Change Events │ │ │ Persistence│ │
│  └─────────────────┘ │ └───────────────┘ │ └────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 设计原则
- **最终一致性**：保证所有节点最终达到相同状态
- **操作幂等性**：相同操作多次执行结果一致
- **因果一致性**：保持操作的因果关系
- **分区容错性**：网络分区时仍能正常工作
- **性能优化**：最小化同步开销和延迟

## 📁 文件结构

```
sync/
├── operation_transform/           # 操作转换(OT)
│   ├── ot_engine.dart
│   ├── operation_types.dart
│   ├── transform_rules.dart
│   ├── ot_processor.dart
│   └── operation_composer.dart
├── crdt/                         # CRDT实现
│   ├── crdt_manager.dart
│   ├── lww_register.dart         # Last-Writer-Wins Register
│   ├── g_counter.dart            # Grow-only Counter
│   ├── pn_counter.dart           # Increment/Decrement Counter
│   ├── or_set.dart               # Observed-Remove Set
│   └── rga_sequence.dart         # Replicated Growable Array
├── coordination/                 # 同步协调
│   ├── sync_coordinator.dart
│   ├── sync_strategy.dart
│   ├── conflict_resolver.dart
│   ├── merge_engine.dart
│   └── consensus_manager.dart
├── versioning/                   # 版本控制
│   ├── version_vector.dart
│   ├── logical_clock.dart
│   ├── causal_order.dart
│   ├── snapshot_manager.dart
│   └── history_tracker.dart
├── change_detection/             # 变更检测
│   ├── change_detector.dart
│   ├── delta_calculator.dart
│   ├── diff_engine.dart
│   ├── patch_generator.dart
│   └── change_listener.dart
├── state_management/             # 状态管理
│   ├── sync_state_manager.dart
│   ├── operation_queue.dart
│   ├── pending_operations.dart
│   ├── acknowledged_operations.dart
│   └── state_persistence.dart
└── utils/                       # 工具类
    ├── sync_utils.dart
    ├── operation_serializer.dart
    ├── vector_clock.dart
    └── sync_logger.dart
```

## 🔧 核心组件说明

### OTEngine (操作转换引擎)
**职责**：处理并发操作的转换和合并
**功能**：
- 操作转换算法实现
- 冲突检测和解决
- 操作组合和优化
- 因果关系维护

**核心接口**：
```dart
class OTEngine {
  // 转换操作
  Operation transform(Operation op1, Operation op2, OperationPriority priority);
  
  // 应用操作
  Future<MapData> applyOperation(MapData state, Operation operation);
  
  // 组合操作
  Operation compose(List<Operation> operations);
  
  // 验证操作
  bool validateOperation(Operation operation, MapData currentState);
}
```

**操作类型定义**：
```dart
abstract class Operation {
  final String id;
  final String clientId;
  final DateTime timestamp;
  final VectorClock vectorClock;
  
  Operation({
    required this.id,
    required this.clientId,
    required this.timestamp,
    required this.vectorClock,
  });
  
  // 应用操作到状态
  MapData apply(MapData state);
  
  // 转换操作
  Operation transform(Operation other, OperationPriority priority);
  
  // 操作的逆操作
  Operation inverse();
}

// 具体操作类型
class InsertOperation extends Operation {
  final String elementId;
  final MapElement element;
  final int position;
}

class DeleteOperation extends Operation {
  final String elementId;
}

class UpdateOperation extends Operation {
  final String elementId;
  final Map<String, dynamic> changes;
}

class MoveOperation extends Operation {
  final String elementId;
  final int fromPosition;
  final int toPosition;
}
```

### CRDTManager (CRDT管理器)
**职责**：管理CRDT数据结构和合并逻辑
**功能**：
- 多种CRDT类型支持
- 自动冲突解决
- 状态合并算法
- 增量同步优化

**CRDT类型实现**：
```dart
// Last-Writer-Wins Register
class LWWRegister<T> {
  T _value;
  DateTime _timestamp;
  String _actorId;
  
  void assign(T value, String actorId) {
    final now = DateTime.now();
    if (now.isAfter(_timestamp) || 
        (now == _timestamp && actorId.compareTo(_actorId) > 0)) {
      _value = value;
      _timestamp = now;
      _actorId = actorId;
    }
  }
  
  LWWRegister<T> merge(LWWRegister<T> other) {
    if (other._timestamp.isAfter(_timestamp) ||
        (other._timestamp == _timestamp && other._actorId.compareTo(_actorId) > 0)) {
      return other;
    }
    return this;
  }
}

// Observed-Remove Set
class ORSet<T> {
  final Map<T, Set<String>> _elements = {};
  final Map<T, Set<String>> _tombstones = {};
  
  void add(T element, String actorId) {
    _elements.putIfAbsent(element, () => {}).add(actorId);
  }
  
  void remove(T element, String actorId) {
    final tags = _elements[element];
    if (tags != null) {
      _tombstones.putIfAbsent(element, () => {}).addAll(tags);
    }
  }
  
  Set<T> get elements {
    return _elements.entries
        .where((entry) {
          final tombstones = _tombstones[entry.key] ?? {};
          return entry.value.any((tag) => !tombstones.contains(tag));
        })
        .map((entry) => entry.key)
        .toSet();
  }
  
  ORSet<T> merge(ORSet<T> other) {
    final merged = ORSet<T>();
    
    // 合并元素
    for (final entry in _elements.entries) {
      merged._elements[entry.key] = Set.from(entry.value);
    }
    for (final entry in other._elements.entries) {
      merged._elements.putIfAbsent(entry.key, () => {}).addAll(entry.value);
    }
    
    // 合并墓碑
    for (final entry in _tombstones.entries) {
      merged._tombstones[entry.key] = Set.from(entry.value);
    }
    for (final entry in other._tombstones.entries) {
      merged._tombstones.putIfAbsent(entry.key, () => {}).addAll(entry.value);
    }
    
    return merged;
  }
}
```

### SyncCoordinator (同步协调器)
**职责**：协调多节点间的数据同步
**功能**：
- 同步策略选择
- 冲突检测和解决
- 同步状态管理
- 性能优化

**同步策略**：
```dart
enum SyncStrategy {
  immediate,    // 立即同步
  batched,      // 批量同步
  periodic,     // 定期同步
  onDemand,     // 按需同步
  adaptive,     // 自适应同步
}

class SyncCoordinator {
  SyncStrategy _currentStrategy = SyncStrategy.adaptive;
  final Queue<Operation> _pendingOperations = Queue();
  final Map<String, DateTime> _lastSyncTimes = {};
  
  Future<void> synchronize(List<String> peerIds) async {
    switch (_currentStrategy) {
      case SyncStrategy.immediate:
        await _immediateSync(peerIds);
        break;
      case SyncStrategy.batched:
        await _batchedSync(peerIds);
        break;
      case SyncStrategy.periodic:
        await _periodicSync(peerIds);
        break;
      case SyncStrategy.adaptive:
        await _adaptiveSync(peerIds);
        break;
    }
  }
  
  Future<void> _adaptiveSync(List<String> peerIds) async {
    // 根据网络条件和操作频率选择策略
    final networkQuality = await _getNetworkQuality();
    final operationRate = _calculateOperationRate();
    
    if (networkQuality.isGood && operationRate.isHigh) {
      await _immediateSync(peerIds);
    } else if (operationRate.isLow) {
      await _periodicSync(peerIds);
    } else {
      await _batchedSync(peerIds);
    }
  }
}
```

### VersionVector (版本向量)
**职责**：跟踪分布式系统中的因果关系
**功能**：
- 逻辑时钟维护
- 因果关系检测
- 并发操作识别
- 版本比较

**实现细节**：
```dart
class VectorClock {
  final Map<String, int> _clocks = {};
  
  void increment(String actorId) {
    _clocks[actorId] = (_clocks[actorId] ?? 0) + 1;
  }
  
  void update(String actorId, int timestamp) {
    _clocks[actorId] = max(_clocks[actorId] ?? 0, timestamp);
  }
  
  VectorClock merge(VectorClock other) {
    final merged = VectorClock();
    final allActors = {..._clocks.keys, ...other._clocks.keys};
    
    for (final actor in allActors) {
      merged._clocks[actor] = max(
        _clocks[actor] ?? 0,
        other._clocks[actor] ?? 0,
      );
    }
    
    return merged;
  }
  
  CausalRelation compareTo(VectorClock other) {
    bool thisLessOrEqual = true;
    bool otherLessOrEqual = true;
    bool hasStrictlyLess = false;
    bool hasStrictlyGreater = false;
    
    final allActors = {..._clocks.keys, ...other._clocks.keys};
    
    for (final actor in allActors) {
      final thisTime = _clocks[actor] ?? 0;
      final otherTime = other._clocks[actor] ?? 0;
      
      if (thisTime < otherTime) {
        thisLessOrEqual = true;
        otherLessOrEqual = false;
        hasStrictlyLess = true;
      } else if (thisTime > otherTime) {
        thisLessOrEqual = false;
        otherLessOrEqual = true;
        hasStrictlyGreater = true;
      }
    }
    
    if (thisLessOrEqual && hasStrictlyLess) return CausalRelation.before;
    if (otherLessOrEqual && hasStrictlyGreater) return CausalRelation.after;
    if (thisLessOrEqual && otherLessOrEqual) return CausalRelation.equal;
    return CausalRelation.concurrent;
  }
}

enum CausalRelation {
  before,      // this happened before other
  after,       // this happened after other
  equal,       // same event
  concurrent,  // concurrent events
}
```

### ChangeDetector (变更检测器)
**职责**：检测和计算数据变更
**功能**：
- 增量变更检测
- 差异计算
- 补丁生成
- 变更事件发布

**变更检测算法**：
```dart
class ChangeDetector {
  MapData? _previousState;
  final StreamController<ChangeEvent> _changeController = StreamController.broadcast();
  
  Stream<ChangeEvent> get changes => _changeController.stream;
  
  List<Change> detectChanges(MapData currentState) {
    if (_previousState == null) {
      _previousState = currentState.copy();
      return [FullStateChange(currentState)];
    }
    
    final changes = <Change>[];
    
    // 检测元素变更
    changes.addAll(_detectElementChanges(currentState));
    
    // 检测属性变更
    changes.addAll(_detectPropertyChanges(currentState));
    
    // 检测结构变更
    changes.addAll(_detectStructureChanges(currentState));
    
    _previousState = currentState.copy();
    return changes;
  }
  
  List<Change> _detectElementChanges(MapData currentState) {
    final changes = <Change>[];
    final previousElements = _previousState!.elements;
    final currentElements = currentState.elements;
    
    // 检测新增元素
    for (final element in currentElements) {
      if (!previousElements.any((e) => e.id == element.id)) {
        changes.add(ElementAddedChange(element));
      }
    }
    
    // 检测删除元素
    for (final element in previousElements) {
      if (!currentElements.any((e) => e.id == element.id)) {
        changes.add(ElementRemovedChange(element));
      }
    }
    
    // 检测修改元素
    for (final currentElement in currentElements) {
      final previousElement = previousElements
          .firstWhereOrNull((e) => e.id == currentElement.id);
      
      if (previousElement != null && !_elementsEqual(previousElement, currentElement)) {
        changes.add(ElementModifiedChange(previousElement, currentElement));
      }
    }
    
    return changes;
  }
}

abstract class Change {
  final DateTime timestamp = DateTime.now();
  final String id = Uuid().v4();
}

class ElementAddedChange extends Change {
  final MapElement element;
  ElementAddedChange(this.element);
}

class ElementRemovedChange extends Change {
  final MapElement element;
  ElementRemovedChange(this.element);
}

class ElementModifiedChange extends Change {
  final MapElement oldElement;
  final MapElement newElement;
  ElementModifiedChange(this.oldElement, this.newElement);
}
```

## 🔄 同步流程

### 操作同步流程
```
1. 本地操作 → ChangeDetector检测变更
2. 生成Operation → OTEngine验证操作
3. 更新VectorClock → 添加到PendingQueue
4. SyncCoordinator选择同步策略
5. 序列化操作 → 网络传输
6. 远端接收 → 反序列化操作
7. OTEngine转换操作 → 应用到本地状态
8. 发送确认 → 更新AcknowledgedQueue
```

### 冲突解决流程
```
1. 检测并发操作 → VectorClock比较
2. 识别冲突类型 → ConflictResolver分析
3. 应用解决策略 → 自动或手动解决
4. 生成合并操作 → MergeEngine处理
5. 广播解决结果 → 同步到所有节点
6. 更新本地状态 → 记录解决历史
```

## 📊 性能优化

### 操作压缩
```dart
class OperationComposer {
  List<Operation> composeOperations(List<Operation> operations) {
    final composed = <Operation>[];
    Operation? current;
    
    for (final op in operations) {
      if (current == null) {
        current = op;
      } else if (_canCompose(current, op)) {
        current = _compose(current, op);
      } else {
        composed.add(current);
        current = op;
      }
    }
    
    if (current != null) {
      composed.add(current);
    }
    
    return composed;
  }
  
  bool _canCompose(Operation op1, Operation op2) {
    // 相同用户的连续操作可以合并
    return op1.clientId == op2.clientId &&
           op1.runtimeType == op2.runtimeType &&
           op2.timestamp.difference(op1.timestamp).inMilliseconds < 1000;
  }
}
```

### 增量同步
```dart
class IncrementalSync {
  Future<void> syncIncremental(String peerId, VectorClock remoteVector) async {
    // 计算需要同步的操作
    final missedOperations = _calculateMissedOperations(remoteVector);
    
    if (missedOperations.isEmpty) return;
    
    // 压缩操作序列
    final compressedOps = _compressOperations(missedOperations);
    
    // 分批发送
    await _sendInBatches(peerId, compressedOps);
  }
  
  List<Operation> _calculateMissedOperations(VectorClock remoteVector) {
    return _operationHistory.where((op) {
      return _localVector.compareTo(remoteVector) == CausalRelation.after;
    }).toList();
  }
}
```

## 🧪 测试策略

### 一致性测试
```dart
void main() {
  group('Sync Consistency Tests', () {
    test('should maintain eventual consistency', () async {
      // 创建多个同步节点
      final nodes = List.generate(3, (i) => SyncNode('node$i'));
      
      // 并发执行操作
      final futures = <Future>[];
      for (int i = 0; i < nodes.length; i++) {
        futures.add(_performRandomOperations(nodes[i], 100));
      }
      
      await Future.wait(futures);
      
      // 等待同步完成
      await _waitForSync(nodes);
      
      // 验证所有节点状态一致
      final states = nodes.map((node) => node.getState()).toList();
      for (int i = 1; i < states.length; i++) {
        expect(states[i], equals(states[0]));
      }
    });
    
    test('should handle network partition', () async {
      final nodes = List.generate(4, (i) => SyncNode('node$i'));
      
      // 模拟网络分区
      _simulatePartition(nodes, [0, 1], [2, 3]);
      
      // 在分区中执行操作
      await _performOperationsInPartition(nodes.sublist(0, 2));
      await _performOperationsInPartition(nodes.sublist(2, 4));
      
      // 恢复网络连接
      _healPartition(nodes);
      
      // 等待同步完成
      await _waitForSync(nodes);
      
      // 验证最终一致性
      final states = nodes.map((node) => node.getState()).toList();
      for (int i = 1; i < states.length; i++) {
        expect(states[i], equals(states[0]));
      }
    });
  });
}
```

### 性能测试
```dart
void main() {
  group('Sync Performance Tests', () {
    test('should handle high operation rate', () async {
      final syncEngine = SyncEngine();
      final stopwatch = Stopwatch()..start();
      
      // 执行1000个操作
      for (int i = 0; i < 1000; i++) {
        await syncEngine.applyOperation(generateRandomOperation());
      }
      
      stopwatch.stop();
      
      // 验证性能指标
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5秒内完成
      expect(syncEngine.operationQueue.length, lessThan(100)); // 队列不积压
    });
  });
}
```

## 📋 开发清单

### 第一阶段：基础同步
- [ ] OTEngine操作转换引擎
- [ ] 基础Operation类型定义
- [ ] VectorClock逻辑时钟
- [ ] ChangeDetector变更检测

### 第二阶段：CRDT集成
- [ ] CRDTManager管理器
- [ ] LWWRegister实现
- [ ] ORSet实现
- [ ] 基础合并算法

### 第三阶段：高级同步
- [ ] SyncCoordinator协调器
- [ ] ConflictResolver冲突解决
- [ ] 增量同步优化
- [ ] 操作压缩算法

### 第四阶段：性能和可靠性
- [ ] 自适应同步策略
- [ ] 网络分区处理
- [ ] 状态持久化
- [ ] 性能监控和调优

## 🔗 依赖关系

- **上游依赖**：models/, network/
- **下游依赖**：services/, blocs/
- **外部依赖**：无
- **内部依赖**：utils/, conflict/

## 📝 开发规范

1. **操作幂等性**：确保操作可重复执行
2. **因果一致性**：维护操作的因果关系
3. **性能优化**：最小化同步开销
4. **错误处理**：优雅处理同步异常
5. **测试覆盖**：确保一致性和性能
6. **文档完善**：详细的算法说明