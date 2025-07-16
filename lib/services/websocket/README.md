# Flutter WebSocket 客户端

这是一个兼容 Go SignalingService 客户端的 Flutter WebSocket 客户端实现，支持多身份管理、安全存储和挑战-响应认证。

## 功能特性

- ✅ **多身份管理**: 支持创建和管理多个客户端身份
- ✅ **安全存储**: 使用 `flutter_secure_storage` 安全存储 RSA 私钥
- ✅ **数据库存储**: 使用 SQLite 存储客户端配置
- ✅ **挑战-响应认证**: 实现与 Go 服务端兼容的认证机制
- ✅ **自动重连**: 支持断线自动重连，带指数退避
- ✅ **消息处理**: 完整的 WebSocket 消息收发处理
- ✅ **RSA 加密**: 使用 `fast_rsa` 进行 RSA 密钥操作

## 核心组件

### 1. 数据模型 (`websocket_client_config.dart`)
- `WebSocketClientConfig`: 客户端配置主模型
- `ServerConfig`: 服务器配置
- `WebSocketConfig`: WebSocket 连接配置
- `ClientKeyConfig`: 客户端密钥配置

### 2. 服务层

#### `WebSocketClientManager`
主要管理器，提供统一的接口：
```dart
final manager = WebSocketClientManager();
await manager.initialize();

// 使用 Web API Key 创建客户端
final config = await manager.createClientWithWebApiKey(
  'https://example.com/api/client?key=xxx',
  '我的客户端',
);

// 连接到服务器
final success = await manager.connect();

// 发送消息
await manager.sendJson({
  'type': 'test',
  'data': 'hello world',
});
```

#### `WebSocketClientInitService`
处理客户端初始化：
- Web API Key 初始化
- 默认配置创建
- RSA 密钥对生成
- 配置验证

#### `WebSocketClientAuthService`
处理认证流程：
- 发送认证消息
- 处理服务器挑战
- RSA 解密挑战
- 发送挑战响应

#### `WebSocketClientService`
核心连接服务：
- WebSocket 连接管理
- 消息收发处理
- 心跳机制
- 自动重连

#### `WebSocketClientDatabaseService`
数据库操作：
- 客户端配置存储
- 多身份管理
- 活跃客户端设置

#### `WebSocketSecureStorageService`
安全存储：
- RSA 密钥对生成
- 私钥安全存储
- 加密解密操作
- 数字签名

## 使用示例

### 1. 初始化管理器
```dart
final manager = WebSocketClientManager();
await manager.initialize();
```

### 2. 创建客户端配置

#### 使用 Web API Key
```dart
final config = await manager.createClientWithWebApiKey(
  'https://your-server.com/api/client?key=your-api-key',
  '客户端显示名称',
);
```

#### 创建默认配置
```dart
final config = await manager.createDefaultClient(
  '默认客户端',
  host: 'localhost',
  port: 8080,
  path: '/ws/client',
);
```

### 3. 连接和消息处理
```dart
// 监听连接状态
manager.connectionStateStream.listen((state) {
  print('连接状态: ${state.name}');
});

// 监听消息
manager.messageStream.listen((message) {
  print('收到消息: ${message.type} - ${message.data}');
});

// 监听错误
manager.errorStream.listen((error) {
  print('错误: $error');
});

// 连接到服务器
final success = await manager.connect();
if (success) {
  print('连接成功');
}

// 发送消息
await manager.sendJson({
  'type': 'ping',
  'timestamp': DateTime.now().millisecondsSinceEpoch,
});
```

### 4. 多身份管理
```dart
// 获取所有配置
final configs = await manager.getAllConfigs();

// 设置活跃配置
await manager.setActiveConfig('client-id');

// 获取活跃配置
final activeConfig = await manager.getActiveConfig();

// 删除配置
await manager.deleteConfig('client-id');
```

## 认证流程

1. **连接建立**: 客户端连接到 WebSocket 服务器
2. **发送认证**: 发送包含客户端ID和公钥的认证消息
3. **接收挑战**: 服务器发送加密的挑战数据
4. **解密挑战**: 使用私钥解密挑战
5. **发送响应**: 将解密后的挑战发送回服务器
6. **认证完成**: 服务器验证响应并确认认证成功

## 消息格式

### 认证消息
```json
{
  "type": "auth",
  "client_id": "client-123",
  "public_key": "-----BEGIN PUBLIC KEY-----\n..."
}
```

### 挑战响应
```json
{
  "type": "challenge_response",
  "response": "decrypted-challenge-data"
}
```

### 心跳消息
```json
{
  "type": "ping",
  "timestamp": 1234567890,
  "client_id": "client-123"
}
```

## 配置说明

### 服务器配置
- `host`: 服务器主机地址
- `port`: 服务器端口（443 使用 WSS，其他使用 WS）

### WebSocket 配置
- `path`: WebSocket 路径（默认: `/ws/client`）
- `pingInterval`: 心跳间隔（秒，默认: 3）
- `reconnectDelay`: 重连延迟（秒，默认: 5）

### 安全配置
- RSA 密钥长度: 2048 位
- 加密算法: RSA PKCS1v15
- 私钥存储: Flutter Secure Storage

## 演示页面

项目包含一个完整的演示页面 `WebSocketClientDemoPage`，展示了所有功能的使用方法：

```dart
import 'package:r6box/pages/websocket_client_demo_page.dart';

// 在你的应用中使用
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const WebSocketClientDemoPage(),
  ),
);
```

## 依赖项

确保在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  web_socket_channel: ^2.4.0
  http: ^1.1.0
  flutter_secure_storage: ^9.2.4
  fast_rsa: ^3.8.5
  sqflite: ^2.3.0
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

## 注意事项

1. **平台兼容性**: 确保在 Android/iOS 上正确配置 `flutter_secure_storage`
2. **网络权限**: 确保应用有网络访问权限
3. **证书验证**: 生产环境中使用 HTTPS/WSS 时注意证书验证
4. **错误处理**: 实现适当的错误处理和用户反馈
5. **资源清理**: 应用退出时调用 `manager.dispose()` 清理资源

## 故障排除

### 连接失败
- 检查服务器地址和端口
- 确认网络连接
- 查看错误日志

### 认证失败
- 验证客户端配置完整性
- 检查 RSA 密钥是否正确
- 确认服务器支持的认证流程

### 消息发送失败
- 确认连接状态
- 检查消息格式
- 查看服务器响应