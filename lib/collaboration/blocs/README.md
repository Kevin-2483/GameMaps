# 协作状态管理 (Collaboration Blocs)

## 📋 模块职责

使用Bloc模式管理实时协作的状态，包括连接状态、用户在线状态、冲突处理状态等，与现有MapDataBloc系统无缝集成。

## 🏗️ 架构设计

### Bloc层次结构
```
CollaborationBloc (主协调器)
├── ConnectionBloc (连接管理)
├── PresenceBloc (用户状态)
├── ConflictBloc (冲突处理)
├── TopologyBloc (网络拓扑)
└── SyncBloc (同步状态)
```

### 与现有系统集成
```
MapDataBloc (现有)
    ↕ 双向通信
CollaborationBloc (新增)
    ↓ 管理
各子Bloc模块
```

### 设计原则
- **状态隔离**：每个Bloc管理独立的状态域
- **事件驱动**：通过事件触发状态变更
- **响应式**：状态变更自动通知UI层
- **可测试**：纯函数式状态转换
- **可扩展**：支持新功能的状态管理

## 📁 文件结构

```
blocs/
├── collaboration_bloc.dart         # 主协作状态管理
├── collaboration_event.dart        # 协作事件定义
├── collaboration_state.dart        # 协作状态定义
├── connection/                      # 连接状态管理
│   ├── connection_bloc.dart
│   ├── connection_event.dart
│   └── connection_state.dart
├── presence/                        # 用户在线状态
│   ├── presence_bloc.dart
│   ├── presence_event.dart
│   └── presence_state.dart
├── conflict/                        # 冲突处理状态
│   ├── conflict_bloc.dart
│   ├── conflict_event.dart
│   └── conflict_state.dart
├── topology/                        # 网络拓扑状态
│   ├── topology_bloc.dart
│   ├── topology_event.dart
│   └── topology_state.dart
├── sync/                           # 同步状态管理
│   ├── sync_bloc.dart
│   ├── sync_event.dart
│   └── sync_state.dart
└── integration/                    # 与MapDataBloc集成
    ├── map_collaboration_bridge.dart
    └── reactive_integration.dart
```

## 🔧 核心Bloc说明

### CollaborationBloc
**职责**：协作功能的主状态管理器
**状态类型**：
- `CollaborationInitial`: 初始状态
- `CollaborationConnecting`: 连接中
- `CollaborationActive`: 协作活跃
- `CollaborationError`: 错误状态
- `CollaborationDisconnected`: 断开连接

**关键事件**：
```dart
abstract class CollaborationEvent {}

class StartCollaboration extends CollaborationEvent {
  final String sessionId;
  final String clientId;
}

class StopCollaboration extends CollaborationEvent {}

class HandleRemoteOperation extends CollaborationEvent {
  final CollaborativeOperation operation;
}

class HandleConnectionChange extends CollaborationEvent {
  final String peerId;
  final ConnectionStatus status;
}
```

### ConnectionBloc
**职责**：管理WebRTC连接状态
**状态类型**：
- `ConnectionIdle`: 空闲状态
- `ConnectionEstablishing`: 建立连接中
- `ConnectionEstablished`: 连接已建立
- `ConnectionFailed`: 连接失败
- `ConnectionLost`: 连接丢失

### PresenceBloc
**职责**：管理用户在线状态和活动
**状态数据**：
```dart
class PresenceState {
  final Map<String, UserPresence> onlineUsers;
  final Map<String, CursorPosition> userCursors;
  final Map<String, Set<String>> userSelections;
  final DateTime lastUpdate;
}
```

### ConflictBloc
**职责**：管理冲突检测和解决状态
**状态类型**：
- `ConflictFree`: 无冲突
- `ConflictDetected`: 检测到冲突
- `ConflictResolving`: 解决中
- `ConflictResolved`: 已解决
- `ConflictRequiresManualResolution`: 需要手动解决

### TopologyBloc
**职责**：管理网络拓扑状态
**状态数据**：
```dart
class TopologyState {
  final NetworkTopology currentTopology;
  final Set<String> superNodes;
  final Map<String, Set<String>> nodeConnections;
  final NetworkMetrics networkMetrics;
  final bool isTransitioning;
}
```

## 🔄 状态流转图

### 协作生命周期
```
Initial → Connecting → Active → Disconnected
    ↓         ↓         ↓         ↓
   Error ←── Error ←── Error ←── Error
```

### 冲突处理流程
```
ConflictFree → ConflictDetected → ConflictResolving
     ↑              ↓                    ↓
     ←─────── ConflictResolved ←─────────┘
                     ↓
            ConflictRequiresManualResolution
```

## 🔗 与MapDataBloc集成

### 双向通信机制
```dart
class MapCollaborationBridge {
  final MapDataBloc mapDataBloc;
  final CollaborationBloc collaborationBloc;
  
  // MapDataEvent → CollaborativeOperation
  void _onMapDataEvent(MapDataEvent event) {
    final operation = _convertToCollaborativeOperation(event);
    collaborationBloc.add(BroadcastOperation(operation));
  }
  
  // CollaborativeOperation → MapDataEvent
  void _onRemoteOperation(CollaborativeOperation operation) {
    final event = _convertToMapDataEvent(operation);
    mapDataBloc.add(event);
  }
}
```

### 响应式集成
```dart
class ReactiveIntegration {
  late StreamSubscription _mapDataSubscription;
  late StreamSubscription _collaborationSubscription;
  
  void initialize() {
    // 监听MapDataBloc状态变更
    _mapDataSubscription = mapDataBloc.stream.listen(_handleMapDataState);
    
    // 监听CollaborationBloc状态变更
    _collaborationSubscription = collaborationBloc.stream.listen(_handleCollaborationState);
  }
}
```

## 📊 状态监控

### 关键指标
- **连接成功率**：成功建立连接的比例
- **状态同步延迟**：状态变更到UI更新的时间
- **冲突解决时间**：从检测到解决的平均时间
- **内存使用**：状态对象的内存占用

### 性能优化
- **状态缓存**：避免重复计算
- **增量更新**：只更新变化的部分
- **懒加载**：按需加载状态数据
- **内存清理**：及时清理过期状态

## 🧪 测试策略

### 单元测试
```dart
// 测试状态转换
void main() {
  group('CollaborationBloc', () {
    test('should emit connecting state when starting collaboration', () {
      // Given
      final bloc = CollaborationBloc();
      
      // When
      bloc.add(StartCollaboration('session1', 'user1'));
      
      // Then
      expect(bloc.stream, emits(isA<CollaborationConnecting>()));
    });
  });
}
```

### 集成测试
- Bloc间的交互测试
- 与Service层的集成测试
- 端到端状态流转测试

### Widget测试
- UI组件对状态变更的响应
- 用户交互触发的状态变更

## 🛡️ 错误处理

### 错误状态管理
```dart
class CollaborationError {
  final String code;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final bool isRecoverable;
}
```

### 错误恢复策略
- **自动重试**：网络错误自动重试
- **状态重置**：严重错误时重置状态
- **降级服务**：部分功能不可用时的降级处理
- **用户通知**：向用户展示错误信息和建议

## 📋 开发清单

### 第一阶段：基础Bloc
- [ ] CollaborationBloc主状态管理
- [ ] ConnectionBloc连接状态
- [ ] PresenceBloc用户状态
- [ ] 与MapDataBloc基础集成

### 第二阶段：高级功能
- [ ] ConflictBloc冲突处理
- [ ] TopologyBloc拓扑管理
- [ ] SyncBloc同步状态
- [ ] 完整的响应式集成

### 第三阶段：优化完善
- [ ] 性能优化
- [ ] 错误处理完善
- [ ] 状态持久化
- [ ] 测试覆盖率100%

## 🔗 依赖关系

- **上游依赖**：models/, services/
- **下游依赖**：widgets/
- **外部依赖**：flutter_bloc, equatable
- **内部依赖**：现有MapDataBloc系统

## 📝 开发规范

1. **命名规范**：Event以动词开头，State以名词结尾
2. **状态不可变**：所有状态类使用不可变对象
3. **事件简洁**：事件只包含必要的数据
4. **错误处理**：每个Bloc都要处理错误状态
5. **文档注释**：为每个事件和状态添加详细注释
6. **测试覆盖**：每个状态转换都要有对应测试