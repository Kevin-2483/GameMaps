# 协作状态管理系统

本文档介绍R6Box协作模块中新增的协作状态管理功能，包括元素锁定、用户选择同步和指针位置同步。

## 概述

协作状态管理系统独立于WebSocket的在线状态管理，专门处理：
- 元素锁定和解锁
- 用户选择状态同步
- 用户指针位置同步
- 协作冲突检测和解决

这种设计使系统能够兼容未来的WebRTC协议，同时保持与现有WebSocket在线状态系统的独立性。

## 核心组件

### 1. 数据模型 (`models/collaboration_state.dart`)

#### ElementLockState
```dart
class ElementLockState {
  final String elementId;
  final String elementType;
  final String userId;
  final String userDisplayName;
  final Color userColor;
  final DateTime lockTime;
  final DateTime? expiryTime;
  final bool isHardLock;
  final Map<String, dynamic> metadata;
}
```

#### UserSelectionState
```dart
class UserSelectionState {
  final String userId;
  final String userDisplayName;
  final Color userColor;
  final List<String> selectedElementIds;
  final String? selectionType;
  final DateTime timestamp;
}
```

#### UserCursorState
```dart
class UserCursorState {
  final String userId;
  final String userDisplayName;
  final Color userColor;
  final Offset position;
  final bool isVisible;
  final DateTime timestamp;
}
```

### 2. 状态管理器 (`services/collaboration_state_manager.dart`)

`CollaborationStateManager` 是核心的状态管理单例，负责：
- 管理元素锁定状态
- 跟踪用户选择和指针位置
- 检测和创建协作冲突
- 提供状态变更流

```dart
final manager = CollaborationStateManager();

// 初始化
manager.initialize(
  userId: 'user123',
  displayName: '张三',
  userColor: Colors.blue,
);

// 尝试锁定元素
final success = manager.tryLockElement(
  elementId: 'element_1',
  elementType: 'map_item',
  isHardLock: false,
  timeoutSeconds: 30,
);

// 更新用户选择
manager.updateCurrentUserSelection(
  selectedElementIds: ['element_1', 'element_2'],
  selectionType: 'multiple',
);

// 更新指针位置
manager.updateCurrentUserCursor(
  position: const Offset(100, 200),
  isVisible: true,
);
```

### 3. 同步服务 (`services/collaboration_sync_service.dart`)

`CollaborationSyncService` 处理与远程服务器的数据同步：

```dart
final syncService = CollaborationSyncService.instance;

// 初始化同步服务
await syncService.initialize(
  userId: 'user123',
  displayName: '张三',
  userColor: Colors.blue,
  onSendToRemote: (data) {
    // 发送数据到远程服务器
    webSocketService.send(data);
  },
  onUserJoined: (userId, displayName) {
    print('用户加入: $displayName');
  },
  onUserLeft: (userId) {
    print('用户离开: $userId');
  },
);

// 启用同步
syncService.enableSync();

// 处理接收到的远程数据
syncService.handleRemoteData(remoteData);
```

### 4. Bloc状态管理 (`blocs/collaboration_state/`)

使用Bloc模式管理UI状态：

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollaborationStateBloc(
        stateManager: CollaborationSyncService.instance.stateManager,
      )..add(InitializeCollaborationState(
        userId: 'user123',
        displayName: '张三',
        userColor: Colors.blue,
      )),
      child: BlocBuilder<CollaborationStateBloc, CollaborationStateBlocState>(
        builder: (context, state) {
          if (state is CollaborationStateLoaded) {
            return MyCollaborativeWidget(state: state);
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
```

### 5. UI组件 (`widgets/`)

#### CollaborationOverlay
主要的协作覆盖层组件，显示其他用户的指针、选择状态和冲突信息：

```dart
CollaborationOverlay(
  showUserCursors: true,
  showUserSelections: true,
  showConflicts: true,
  getElementBounds: (elementId) {
    // 返回元素在屏幕上的位置和大小
    return elementBoundsMap[elementId];
  },
  coordinateTransform: (logicalPosition) {
    // 将逻辑坐标转换为屏幕坐标
    return transformToScreen(logicalPosition);
  },
  child: YourMapWidget(),
)
```

#### UserCursorWidget
显示其他用户的指针：

```dart
UserCursorWidget(
  cursor: userCursorState,
  style: const UserCursorStyle(
    size: 20.0,
    showUserLabel: true,
  ),
)
```

#### CollaborationConflictWidget
显示协作冲突信息：

```dart
CollaborationConflictWidget(
  conflict: collaborationConflict,
  style: const ConflictStyle(),
  onResolve: () {
    // 解决冲突
  },
)
```

## 集成指南

### 1. 基本集成

在你的地图或画布组件中集成协作功能：

```dart
class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late CollaborationStateBloc _collaborationBloc;
  late CollaborationSyncService _syncService;

  @override
  void initState() {
    super.initState();
    _initializeCollaboration();
  }

  Future<void> _initializeCollaboration() async {
    _syncService = CollaborationSyncService.instance;
    
    await _syncService.initialize(
      userId: getCurrentUserId(),
      displayName: getCurrentUserDisplayName(),
      userColor: getCurrentUserColor(),
      onSendToRemote: _handleSendToRemote,
    );
    
    _collaborationBloc = CollaborationStateBloc(
      stateManager: _syncService.stateManager,
    );
    
    _collaborationBloc.add(InitializeCollaborationState(
      userId: getCurrentUserId(),
      displayName: getCurrentUserDisplayName(),
      userColor: getCurrentUserColor(),
    ));
    
    _syncService.enableSync();
  }

  void _handleSendToRemote(Map<String, dynamic> data) {
    // 通过WebSocket或其他方式发送到远程服务器
    webSocketService.send(data);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _collaborationBloc,
      child: CollaborationOverlay(
        getElementBounds: _getElementBounds,
        child: YourMapWidget(
          onElementTap: _onElementTap,
          onCursorMove: _onCursorMove,
        ),
      ),
    );
  }

  void _onElementTap(String elementId) {
    // 尝试锁定元素
    _collaborationBloc.add(TryLockElement(
      elementId: elementId,
      elementType: 'map_element',
    ));
    
    // 更新选择状态
    _collaborationBloc.add(UpdateUserSelection(
      selectedElementIds: [elementId],
    ));
  }

  void _onCursorMove(Offset position) {
    // 更新指针位置
    _collaborationBloc.add(UpdateUserCursor(
      position: position,
      isVisible: true,
    ));
  }

  Rect? _getElementBounds(String elementId) {
    // 返回元素的屏幕位置和大小
    return elementBoundsMap[elementId];
  }
}
```

### 2. 处理远程数据

在WebSocket消息处理中集成协作数据：

```dart
void handleWebSocketMessage(Map<String, dynamic> message) {
  final type = message['type'] as String;
  
  if (type == 'collaboration_batch' || 
      type == 'element_lock' ||
      type == 'user_selection' ||
      type == 'user_cursor') {
    // 处理协作相关消息
    CollaborationSyncService.instance.handleRemoteData(message);
  } else {
    // 处理其他消息（如在线状态）
    handleOtherMessages(message);
  }
}
```

### 3. 与MapDataBloc集成

在地图数据操作时检查元素锁定状态：

```dart
void updateMapElement(String elementId, Map<String, dynamic> updates) {
  final collaborationBloc = context.read<CollaborationStateBloc>();
  
  // 检查元素是否被其他用户锁定
  if (collaborationBloc.isElementLockedByOtherUser(elementId)) {
    showError('元素被其他用户锁定，无法编辑');
    return;
  }
  
  // 尝试锁定元素
  collaborationBloc.add(TryLockElement(
    elementId: elementId,
    elementType: 'map_element',
    isHardLock: true, // 编辑时使用硬锁定
  ));
  
  // 执行更新操作
  context.read<MapDataBloc>().add(UpdateMapElement(
    elementId: elementId,
    updates: updates,
  ));
}
```

## 配置选项

### 同步配置

```dart
await syncService.initialize(
  // ... 其他参数
  syncInterval: const Duration(milliseconds: 500), // 同步间隔
  batchDelay: const Duration(milliseconds: 100),   // 批处理延迟
);
```

### 样式配置

```dart
CollaborationOverlay(
  cursorStyle: const UserCursorStyle(
    size: 24.0,
    opacity: 0.9,
    showUserLabel: true,
    animationDuration: Duration(milliseconds: 200),
  ),
  selectionStyle: const UserSelectionStyle(
    strokeWidth: 2.0,
    opacity: 0.7,
    borderRadius: 4.0,
    showUserLabel: true,
  ),
  conflictStyle: const ConflictStyle(
    backgroundColor: Colors.red,
    textColor: Colors.white,
    borderRadius: 8.0,
  ),
  child: YourWidget(),
)
```

## 最佳实践

1. **元素锁定策略**：
   - 查看操作使用软锁定（`isHardLock: false`）
   - 编辑操作使用硬锁定（`isHardLock: true`）
   - 设置合适的超时时间避免死锁

2. **性能优化**：
   - 合理设置同步间隔和批处理延迟
   - 只在必要时显示协作覆盖层
   - 使用坐标转换函数优化渲染性能

3. **用户体验**：
   - 提供清晰的视觉反馈（锁定状态、选择状态）
   - 及时显示冲突信息并提供解决方案
   - 支持用户自定义协作功能的显示/隐藏

4. **错误处理**：
   - 监听同步服务的错误事件
   - 提供网络断开时的降级体验
   - 实现冲突解决机制

## 示例代码

完整的集成示例请参考 `examples/collaboration_integration_example.dart`。

## 注意事项

1. 协作状态管理系统独立于WebSocket在线状态，但可以与之配合使用
2. 系统设计为兼容未来的WebRTC协议
3. 所有协作数据都是临时的，不会持久化存储
4. 用户离线时，其协作状态会被自动清理
5. 冲突检测是实时的，但解决需要用户手动操作