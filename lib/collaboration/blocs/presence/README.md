# PresenceBloc - 用户在线状态管理

## 概述

`PresenceBloc` 是 R6Box 协作模块的核心组件，负责管理用户在线状态、实时同步用户活动，并与现有的 `MapDataBloc` 系统无缝集成。

## 功能特性

### 🔄 实时状态同步
- 用户在线/离线状态跟踪
- 用户活动状态（查看、编辑、空闲）

### 🔗 MapDataBloc 集成
- 自动检测用户编辑状态
- 同步地图查看状态
- 响应地图数据变化
- 双向状态通信

### 🌐 WebSocket 通信
- 基于 WebSocket 的实时通信
- 自动重连机制
- 心跳检测
- 错误处理和恢复

### 🧹 自动清理
- 离线用户自动清理
- 定时心跳更新
- 内存优化管理

## 核心组件

### 数据模型

#### UserPresence
```dart
class UserPresence {
  final String clientId;         // 客户端ID
  final String userName;         // 用户名
  final UserActivityStatus status; // 活动状态
  final DateTime lastSeen;       // 最后活跃时间
  final DateTime joinedAt;       // 加入时间
  final Map<String, dynamic> metadata; // 元数据
}
```

#### UserActivityStatus
```dart
enum UserActivityStatus {
  offline,  // 离线
  idle,     // 在线但空闲
  viewing,  // 正在查看地图
  editing,  // 正在编辑地图
}
```

### 状态管理

#### PresenceState
- `PresenceInitial`: 初始状态
- `PresenceLoading`: 加载中
- `PresenceLoaded`: 已加载，包含当前用户和远程用户状态
- `PresenceError`: 错误状态

#### PresenceEvent
- `InitializePresence`: 初始化用户状态
- `UpdateCurrentUserStatus`: 更新当前用户状态
- `ReceiveRemoteUserPresence`: 接收远程用户状态

## 使用指南

### 1. 基本设置

```dart
// 在应用的根部提供 PresenceBloc
MultiBlocProvider(
  providers: [
    BlocProvider<MapDataBloc>(
      create: (context) => MapDataBloc(),
    ),
    BlocProvider<PresenceBloc>(
      create: (context) => PresenceBloc(
        webSocketService: WebSocketClientService.instance,
        mapDataBloc: context.read<MapDataBloc>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

### 2. 初始化用户状态

```dart
// 在应用启动时初始化
context.read<PresenceBloc>().add(
  InitializePresence(
    currentClientId: 'client123',
    currentUserName: '张三',
  ),
);
```

### 3. 监听状态变化

```dart
BlocBuilder<PresenceBloc, PresenceState>(
  builder: (context, state) {
    if (state is PresenceLoaded) {
      return Column(
        children: [
          Text('在线用户: ${state.onlineUserCount}'),
          Text('编辑用户: ${state.editingUserCount}'),
          if (state.hasOtherEditingUsers)
            Text('其他用户正在编辑'),
        ],
      );
    }
    return CircularProgressIndicator();
  },
)
```

### 4. 更新用户活动

```dart
// 开始编辑
context.read<PresenceBloc>().add(
  UpdateCurrentUserStatus(status: UserActivityStatus.editing),
);

// 设置为空闲状态
context.read<PresenceBloc>().add(
  UpdateCurrentUserStatus(status: UserActivityStatus.idle),
);
```

### 5. 与 MapDataBloc 集成

```dart
// PresenceBloc 会自动监听 MapDataBloc 的状态变化
// 当地图状态改变时，用户活动状态会自动更新

// 手动更新状态（如果需要）
context.read<PresenceBloc>().add(
  UpdateCurrentUserStatus(
    status: UserActivityStatus.viewing,
  ),
);
```

## 高级用法

### 1. 自定义用户颜色

```dart
Color getUserColor(String clientId) {
  final hash = clientId.hashCode;
  final colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];
  return colors[hash.abs() % colors.length];
}
```

### 2. 用户状态显示

```dart
class UserStatusIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PresenceBloc, PresenceState>(
      builder: (context, state) {
        if (state is! PresenceLoaded) return SizedBox.shrink();
        
        return Row(
          children: [
            Icon(
              Icons.people,
              color: state.onlineUserCount > 1 ? Colors.green : Colors.grey,
            ),
            SizedBox(width: 4),
            Text('${state.onlineUserCount} 在线'),
            if (state.hasOtherEditingUsers)
              Text(' (${state.editingUserCount} 编辑中)'),
          ],
        );
      },
    );
  }
}
```

## 性能优化

### 1. 状态更新节流

```dart
// 使用 RxDart 的 debounceTime 来减少状态更新频率
StreamSubscription? _statusSubscription;

void _setupStatusThrottling() {
  _statusSubscription = _statusUpdateStream
      .debounceTime(Duration(milliseconds: 500))
      .listen((status) {
    context.read<PresenceBloc>().add(
      UpdateCurrentUserStatus(status: status),
    );
  });
}
```

### 2. 状态更新优化

```dart
// 避免频繁的状态更新
void updateUserStatus(BuildContext context, UserActivityStatus status) {
  final bloc = context.read<PresenceBloc>();
  
  // 只在状态真正改变时才更新
  if (bloc.state is PresenceLoaded) {
    final currentState = bloc.state as PresenceLoaded;
    if (currentState.currentUser.status != status) {
      bloc.add(UpdateCurrentUserStatus(status: status));
    }
  }
}
```

## 错误处理

### 1. 连接错误处理

```dart
BlocListener<PresenceBloc, PresenceState>(
  listener: (context, state) {
    if (state is PresenceError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('协作连接错误: ${state.message}'),
          action: SnackBarAction(
            label: '重试',
            onPressed: () {
              // 重新初始化
              context.read<PresenceBloc>().add(
                InitializePresence(
                  currentClientId: getCurrentClientId(),
                  currentUserName: getCurrentUserName(),
                ),
              );
            },
          ),
        ),
      );
    }
  },
  child: YourWidget(),
)
```

### 2. 网络状态监听

```dart
// 监听 WebSocket 连接状态
BlocBuilder<WebSocketClientService, WebSocketConnectionState>(
  bloc: WebSocketClientService.instance,
  builder: (context, connectionState) {
    return Container(
      color: connectionState == WebSocketConnectionState.connected
          ? Colors.green
          : Colors.red,
      child: Text(
        connectionState == WebSocketConnectionState.connected
            ? '已连接'
            : '连接中断',
      ),
    );
  },
)
```

## 测试

### 1. 单元测试示例

```dart
void main() {
  group('PresenceBloc', () {
    late PresenceBloc presenceBloc;
    late MockWebSocketService mockWebSocketService;
    late MockMapDataBloc mockMapDataBloc;

    setUp(() {
      mockWebSocketService = MockWebSocketService();
      mockMapDataBloc = MockMapDataBloc();
      presenceBloc = PresenceBloc(
        webSocketService: mockWebSocketService,
        mapDataBloc: mockMapDataBloc,
      );
    });

    test('初始状态应该是 PresenceInitial', () {
      expect(presenceBloc.state, isA<PresenceInitial>());
    });

    blocTest<PresenceBloc, PresenceState>(
      '初始化用户状态',
      build: () => presenceBloc,
      act: (bloc) => bloc.add(
        InitializePresence(
          currentClientId: 'client123',
          currentUserName: '测试用户',
        ),
      ),
      expect: () => [
        isA<PresenceLoading>(),
        isA<PresenceLoaded>(),
      ],
    );
  });
}
```

## 最佳实践

### 1. 状态管理
- 始终通过事件更新状态，避免直接修改
- 使用 `copyWith` 方法创建新的状态实例
- 合理使用防抖和节流来优化性能

### 2. 错误处理
- 实现全面的错误处理机制
- 提供用户友好的错误提示
- 支持自动重试和手动重试

### 3. 性能优化
- 避免频繁的状态更新
- 使用适当的防抖时间
- 及时清理不需要的订阅

### 4. 用户体验
- 提供清晰的在线状态指示
- 显示协作冲突警告
- 支持离线模式降级

## 故障排除

### 常见问题

1. **用户状态不更新**
   - 检查 WebSocket 连接状态
   - 确认事件正确发送
   - 验证状态监听器设置

2. **状态同步延迟**
   - 检查网络连接稳定性
   - 确认防抖设置合理
   - 验证WebSocket连接状态

3. **内存泄漏**
   - 确保正确取消订阅
   - 检查定时器清理
   - 验证 Bloc 正确关闭
   - 清理离线用户数据

### 调试技巧

```dart
// 启用详细日志
PresenceBloc.enableDebugMode = true;

// 监听所有状态变化
presenceBloc.stream.listen((state) {
  print('PresenceBloc状态变化: $state');
});

// 监听所有事件
presenceBloc.add = (event) {
  print('PresenceBloc事件: $event');
  super.add(event);
};
```

## 版本兼容性

- Flutter: >= 3.0.0
- Dart: >= 2.17.0
- flutter_bloc: >= 8.0.0
- rxdart: >= 0.27.0

## 相关文档

- [WebSocketClientService 文档](../services/README.md)
- [协作模块架构设计](../README.md)
- [MapDataBloc 集成指南](../../../data/README.md)