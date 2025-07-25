// R6Box 协作模块
//
// 该模块提供了完整的实时协作功能，包括：
// - WebSocket客户端服务
// - 用户在线状态管理
// - 实时数据同步
// - 协作冲突处理
// - 网络拓扑管理
//
// 主要组件：
// - WebSocketClientService: WebSocket连接管理
// - PresenceBloc: 用户在线状态管理
// - UserPresence: 用户状态数据模型
//
// 使用示例：
// ```dart
// // 1. 初始化WebSocket服务
// final webSocketService = WebSocketClientService.instance;
//
// // 2. 创建PresenceBloc
// final presenceBloc = PresenceBloc(
//   webSocketService: webSocketService,
//   mapDataBloc: mapDataBloc,
// );
//
// // 3. 初始化用户状态
// presenceBloc.add(InitializePresence(
//   currentClientId: 'client123',
//   currentUserName: '用户名',
// ));
// ```

// 服务层
export 'services/websocket/websocket_client_service.dart';
export 'services/websocket/websocket_client_auth_service.dart';
export 'services/websocket/websocket_client_database_service.dart';
export 'services/map_sync_service.dart';
export 'services/auto_presence_manager.dart';
export 'services/collaboration_state_manager.dart';
export 'services/collaboration_sync_service.dart';

// Mixins
export 'mixins/auto_presence_mixin.dart';

// 数据模型
export 'models/user_presence.dart';
export 'models/collaboration_state.dart';

// 状态管理
export 'blocs/presence/presence.dart';
export 'blocs/collaboration_state/collaboration_state_bloc.dart';
export 'blocs/collaboration_state/collaboration_state_event.dart';
export 'blocs/collaboration_state/collaboration_state_state.dart';

// 协作组件
export 'widgets/collaboration_overlay.dart';
export 'widgets/user_cursor_widget.dart';
export 'widgets/user_selection_widget.dart';
export 'widgets/collaboration_conflict_widget.dart';

// 集成示例
// export 'examples/map_editor_integration_example.dart';
// export 'examples/map_atlas_integration_example.dart';
