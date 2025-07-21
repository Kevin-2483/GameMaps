# 协作功能集成指南

本指南提供了将协作功能集成到现有地图编辑器和地图图集页面的详细步骤。

## 快速开始

### 方式一：使用 AutoPresenceMixin（推荐）

最简单的集成方式是使用 `AutoPresenceMixin`，它提供了开箱即用的协作功能。

## 集成步骤

### 1. 在地图编辑器页面集成

#### 1.1 修改 `map_editor_page.dart`

在 `_MapEditorContentState` 类中添加以下代码：

```dart
// 在类的顶部添加导入
import '../../collaboration/collaboration.dart';

// 在 _MapEditorContentState 类中添加字段
class _MapEditorContentState extends State<_MapEditorContent>
    with MapEditorReactiveMixin, ReactiveVersionMixin {
  // ... 现有字段 ...
  
  // 添加协作相关服务
  late final PresenceBloc _presenceBloc;
  late final WebSocketClientService _webSocketService;
  late final MapSyncService _mapSyncService;
  late final AutoPresenceManager _autoPresenceManager;
  
  // ... 其他现有字段 ...
}
```

#### 1.2 在 `initState` 中初始化服务

```dart
@override
void initState() {
  super.initState();
  _mainFocusNode = FocusNode();
  
  // 初始化协作服务
  _initializeCollaborationServices();
  
  _initializeMapAndReactiveSystem();
  _initializeLayoutFromPreferences();
}

/// 初始化协作服务
void _initializeCollaborationServices() {
  // 初始化WebSocket服务
  _webSocketService = WebSocketClientService.instance;
  
  // 初始化PresenceBloc
  _presenceBloc = PresenceBloc(
    webSocketService: _webSocketService,
    mapDataBloc: mapDataBloc, // 使用现有的mapDataBloc
  );
  
  // 初始化MapSyncService
  _mapSyncService = MapSyncService(presenceBloc: _presenceBloc);
  
  // 初始化AutoPresenceManager
  _autoPresenceManager = AutoPresenceManager(
    presenceBloc: _presenceBloc,
    webSocketService: _webSocketService,
    mapSyncService: _mapSyncService,
  );
  
  // 启动自动状态管理
  _autoPresenceManager.initialize();
  
  // 初始化用户状态
  _presenceBloc.add(InitializePresence(
    currentUserId: 'user_${DateTime.now().millisecondsSinceEpoch}', // 使用实际用户ID
    currentUserName: '当前用户', // 使用实际用户名
  ));
}
```

#### 1.3 在地图加载完成后进入编辑器

在 `_initializeMapAndReactiveSystem` 方法中，当地图加载完成后调用：

```dart
/// 当地图加载完成时调用
void _onMapLoaded() {
  if (_currentMap != null) {
    // 进入地图编辑器，开始自动状态管理
    _autoPresenceManager.enterMapEditor(
      mapId: _currentMap!.id?.toString() ?? 'unknown',
      mapTitle: _currentMap!.title,
      mapCover: _currentMap!.coverImageData,
      mapDataBloc: mapDataBloc, // 传入MapDataBloc以监听编辑操作
    );
  }
}
```

#### 1.4 在 `dispose` 中清理资源

```dart
@override
void dispose() {
  // 退出地图编辑器
  _autoPresenceManager.exitMapEditor();
  
  // 清理协作服务
  _autoPresenceManager.dispose();
  _presenceBloc.close();
  
  // ... 现有的dispose代码 ...
  
  super.dispose();
}
```

#### 1.5 添加在线用户显示组件（可选）

在地图编辑器的UI中添加在线用户显示：

```dart
// 在build方法中添加
Widget build(BuildContext context) {
  return MultiBlocProvider(
    providers: [
      // ... 现有的providers ...
      BlocProvider.value(value: _presenceBloc),
    ],
    child: Scaffold(
      // ... 现有的UI ...
      
      // 添加在线用户显示（可以放在状态栏或侧边栏）
      floatingActionButton: _buildOnlineUsersButton(),
    ),
  );
}

Widget _buildOnlineUsersButton() {
  return BlocBuilder<PresenceBloc, PresenceState>(
    builder: (context, state) {
      final onlineCount = state.remoteUsers.length + (state.currentUser != null ? 1 : 0);
      
      return FloatingActionButton(
        mini: true,
        onPressed: () {
          // 显示在线用户列表
          _showOnlineUsersDialog();
        },
        child: Badge(
          label: Text('$onlineCount'),
          child: const Icon(Icons.people),
        ),
      );
    },
  );
}

void _showOnlineUsersDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('在线用户'),
      content: BlocBuilder<PresenceBloc, PresenceState>(
        builder: (context, state) {
          final allUsers = [
            if (state.currentUser != null) state.currentUser!,
            ...state.remoteUsers,
          ];
          
          return SizedBox(
            width: 300,
            height: 400,
            child: ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                final user = allUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(user.status),
                    child: Text(user.name[0]),
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getStatusText(user.status)),
                      if (user.hasMapTitle)
                        Text('正在编辑: ${user.mapTitle}', 
                             style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: user.hasMapCover
                      ? SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.memory(
                            user.currentMapCover!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    ),
  );
}

Color _getStatusColor(UserStatus status) {
  switch (status) {
    case UserStatus.online:
      return Colors.green;
    case UserStatus.offline:
      return Colors.grey;
    case UserStatus.viewing:
      return Colors.blue;
    case UserStatus.editing:
      return Colors.orange;
  }
}

String _getStatusText(UserStatus status) {
  switch (status) {
    case UserStatus.online:
      return '在线';
    case UserStatus.offline:
      return '离线';
    case UserStatus.viewing:
      return '查看中';
    case UserStatus.editing:
      return '编辑中';
  }
}
```

### 2. 在地图册页面集成

#### 2.1 修改 `map_atlas_page.dart`

```dart
// 在类的顶部添加导入
import '../../collaboration/collaboration.dart';

// 在 _MapAtlasContentState 类中添加字段
class _MapAtlasContentState extends State<_MapAtlasContent>
    with MapLocalizationMixin {
  // ... 现有字段 ...
  
  // 添加协作相关服务
  late final PresenceBloc _presenceBloc;
  late final WebSocketClientService _webSocketService;
  late final MapSyncService _mapSyncService;
  late final AutoPresenceManager _autoPresenceManager;
  
  // ... 其他现有字段 ...
}
```

#### 2.2 在 `initState` 中初始化服务

```dart
@override
void initState() {
  super.initState();
  
  // 初始化协作服务
  _initializeCollaborationServices();
  
  _loadDirectoryContents();
  _searchController.addListener(_onSearchChanged);
}

/// 初始化协作服务
void _initializeCollaborationServices() {
  // 初始化WebSocket服务
  _webSocketService = WebSocketClientService.instance;
  
  // 初始化PresenceBloc
  _presenceBloc = PresenceBloc(
    webSocketService: _webSocketService,
    mapDataBloc: null, // 地图册页面不需要MapDataBloc
  );
  
  // 初始化MapSyncService
  _mapSyncService = MapSyncService(presenceBloc: _presenceBloc);
  
  // 初始化AutoPresenceManager
  _autoPresenceManager = AutoPresenceManager(
    presenceBloc: _presenceBloc,
    webSocketService: _webSocketService,
    mapSyncService: _mapSyncService,
  );
  
  // 启动自动状态管理
  _autoPresenceManager.initialize();
  
  // 初始化用户状态
  _presenceBloc.add(InitializePresence(
    currentUserId: 'user_${DateTime.now().millisecondsSinceEpoch}', // 使用实际用户ID
    currentUserName: '当前用户', // 使用实际用户名
  ));
}
```

#### 2.3 在 `dispose` 中清理资源

```dart
@override
void dispose() {
  // 清理协作服务
  _autoPresenceManager.dispose();
  _presenceBloc.close();
  
  _searchController.removeListener(_onSearchChanged);
  _searchController.dispose();
  super.dispose();
}
```

#### 2.4 在进入地图编辑器时同步地图信息

修改导航到地图编辑器的方法：

```dart
void _openMapEditor(MapFileItem mapFile) {
  // 在进入编辑器前同步地图信息
  _mapSyncService.syncFromMapItemSummary(mapFile.mapSummary);
  
  // 导航到地图编辑器
  context.push('/map-editor', extra: {
    'mapTitle': mapFile.mapSummary.title,
    'folderPath': _currentPath,
    'absoluteMapPath': mapFile.path,
  });
}
```

### 3. 配置WebSocket连接

确保在应用启动时配置WebSocket连接：

```dart
// 在main.dart或app.dart中
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化WebSocket服务
  final webSocketService = WebSocketClientService.instance;
  await webSocketService.connect('ws://your-server-url'); // 使用实际的服务器地址
  
  runApp(MyApp());
}
```

## 高级功能

### 手动触发编辑状态

在某些无法自动检测编辑操作的情况下，可以手动触发编辑状态：

```dart
// 在执行编辑操作时调用
_autoPresenceManager.triggerEditingState();

// 更新地图标题时
_autoPresenceManager.updateMapTitle('新标题');

// 更新地图封面时
_autoPresenceManager.updateMapCover(newCoverData);
```

### 自定义状态管理

如果需要自定义状态管理逻辑，可以直接使用 `PresenceBloc`：

```dart
// 手动更新用户状态
_presenceBloc.add(UpdateCurrentUserStatus(status: UserStatus.editing));

// 手动更新地图信息
_presenceBloc.add(UpdateCurrentMapInfo(
  mapId: 'map123',
  mapTitle: '地图标题',
  mapCover: coverData,
  mapCoverQuality: 80,
));
```

## 注意事项

1. **用户ID和用户名**：请使用实际的用户ID和用户名，而不是示例中的占位符。

2. **WebSocket服务器**：确保WebSocket服务器地址正确，并且服务器支持协作功能。

3. **权限管理**：根据需要添加用户权限检查，确保只有授权用户才能看到其他用户的状态。

4. **错误处理**：添加适当的错误处理逻辑，处理网络连接失败等情况。

5. **性能优化**：在大量用户同时在线时，考虑添加用户列表分页或过滤功能。

## 测试

使用提供的集成示例进行测试：

```dart
// 运行自动状态管理示例
flutter run lib/collaboration/services/auto_presence_integration_example.dart
```

这个示例展示了所有自动状态管理功能，可以用来验证集成是否正确。