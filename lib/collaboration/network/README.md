# 网络通信层 (Network Layer)

## 📋 模块职责

负责WebRTC连接管理、信令处理、数据传输和网络状态监控，是实时协作系统的核心通信基础设施。

## 🏗️ 架构设计

### 网络层架构图
```
┌─────────────────────────────────────────────────────────┐
│                    Network Layer                        │
├─────────────────────────────────────────────────────────┤
│  WebRTC Manager  │  Signaling  │  Message Router       │
│  ┌─────────────┐  │  ┌────────┐  │  ┌──────────────┐    │
│  │ Peer Conn   │  │  │ Socket │  │  │ Message      │    │
│  │ Management  │  │  │ Client │  │  │ Dispatcher   │    │
│  └─────────────┘  │  └────────┘  │  └──────────────┘    │
├─────────────────────────────────────────────────────────┤
│  Connection Pool │  Data Channel │  Network Monitor     │
│  ┌─────────────┐  │  ┌────────┐   │  ┌──────────────┐    │
│  │ Peer Pool   │  │  │ Channel│   │  │ Quality      │    │
│  │ Management  │  │  │ Manager│   │  │ Monitor      │    │
│  └─────────────┘  │  └────────┘   │  └──────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### 设计原则
- **可靠性**：确保消息传输的可靠性和顺序性
- **扩展性**：支持动态添加和移除连接
- **容错性**：网络异常时的自动恢复机制
- **性能优化**：连接复用和消息批处理
- **安全性**：数据加密和身份验证

## 📁 文件结构

```
network/
├── webrtc/                        # WebRTC核心功能
│   ├── webrtc_manager.dart
│   ├── peer_connection_factory.dart
│   ├── data_channel_manager.dart
│   ├── ice_candidate_manager.dart
│   └── webrtc_config.dart
├── signaling/                     # 信令服务
│   ├── signaling_client.dart
│   ├── signaling_protocol.dart
│   ├── message_types.dart
│   └── signaling_config.dart
├── transport/                     # 传输层
│   ├── message_router.dart
│   ├── reliable_transport.dart
│   ├── message_serializer.dart
│   └── compression_manager.dart
├── connection/                    # 连接管理
│   ├── connection_pool.dart
│   ├── peer_connection_wrapper.dart
│   ├── connection_state_manager.dart
│   └── reconnection_manager.dart
├── monitoring/                    # 网络监控
│   ├── network_monitor.dart
│   ├── quality_metrics.dart
│   ├── latency_tracker.dart
│   └── bandwidth_monitor.dart
├── security/                      # 安全相关
│   ├── encryption_manager.dart
│   ├── authentication.dart
│   └── certificate_manager.dart
└── utils/                        # 工具类
    ├── network_utils.dart
    ├── stun_turn_config.dart
    └── debug_logger.dart
```

## 🔧 核心组件说明

### WebRTCManager
**职责**：WebRTC连接的统一管理器
**功能**：
- 创建和管理PeerConnection
- 处理ICE候选者交换
- 管理数据通道生命周期
- 监控连接状态变化

**核心接口**：
```dart
class WebRTCManager {
  Future<String> createConnection(String peerId, bool isInitiator);
  Future<void> closeConnection(String peerId);
  Future<void> sendData(String peerId, Uint8List data);
  Stream<WebRTCEvent> get events;
  Map<String, ConnectionState> get connectionStates;
}
```

### SignalingClient
**职责**：处理WebRTC信令交换
**功能**：
- WebSocket连接管理
- SDP offer/answer交换
- ICE候选者传输
- 房间管理和用户发现

**信令协议**：
```dart
enum SignalingMessageType {
  join,           // 加入房间
  leave,          // 离开房间
  offer,          // SDP Offer
  answer,         // SDP Answer
  iceCandidate,   // ICE候选者
  userList,       // 用户列表更新
  error,          // 错误消息
}

class SignalingMessage {
  final SignalingMessageType type;
  final String from;
  final String to;
  final Map<String, dynamic> data;
  final DateTime timestamp;
}
```

### MessageRouter
**职责**：消息路由和分发
**功能**：
- 消息类型识别和路由
- 广播和单播消息处理
- 消息优先级管理
- 失败重试机制

**路由策略**：
```dart
class MessageRouter {
  // 直接发送（P2P）
  Future<void> sendDirect(String peerId, Message message);
  
  // 广播发送（所有连接）
  Future<void> broadcast(Message message, {List<String>? exclude});
  
  // 智能路由（根据网络拓扑选择最优路径）
  Future<void> smartRoute(Message message, String targetId);
  
  // 可靠传输（确保消息到达）
  Future<void> reliableSend(String peerId, Message message);
}
```

### ConnectionPool
**职责**：连接池管理和优化
**功能**：
- 连接复用和负载均衡
- 连接健康检查
- 自动重连机制
- 连接质量评估

**连接状态管理**：
```dart
enum ConnectionState {
  disconnected,   // 未连接
  connecting,     // 连接中
  connected,      // 已连接
  reconnecting,   // 重连中
  failed,         // 连接失败
}

class PeerConnectionInfo {
  final String peerId;
  final ConnectionState state;
  final DateTime lastSeen;
  final NetworkQuality quality;
  final int messagesSent;
  final int messagesReceived;
  final Duration averageLatency;
}
```

### NetworkMonitor
**职责**：网络质量监控和诊断
**功能**：
- 实时延迟测量
- 带宽使用监控
- 丢包率统计
- 连接稳定性评估

**监控指标**：
```dart
class NetworkMetrics {
  final Duration latency;           // 延迟
  final double bandwidth;           // 带宽 (Mbps)
  final double packetLoss;          // 丢包率 (%)
  final double jitter;              // 抖动 (ms)
  final int activeConnections;      // 活跃连接数
  final DateTime timestamp;
}

class QualityLevel {
  static const excellent = 'excellent';  // < 50ms, < 1% loss
  static const good = 'good';            // < 100ms, < 3% loss
  static const fair = 'fair';            // < 200ms, < 5% loss
  static const poor = 'poor';            // > 200ms, > 5% loss
}
```

## 🔄 数据流处理

### 消息发送流程
```
1. 应用层消息 → MessageSerializer
2. 序列化数据 → CompressionManager
3. 压缩数据 → MessageRouter
4. 路由决策 → ReliableTransport
5. 可靠传输 → DataChannelManager
6. WebRTC发送 → 对端接收
```

### 消息接收流程
```
1. WebRTC接收 → DataChannelManager
2. 数据解析 → ReliableTransport
3. 可靠性检查 → CompressionManager
4. 数据解压 → MessageSerializer
5. 反序列化 → MessageRouter
6. 路由分发 → 应用层处理
```

## 🛡️ 可靠性保证

### 消息确认机制
```dart
class ReliableTransport {
  static const int maxRetries = 3;
  static const Duration ackTimeout = Duration(seconds: 5);
  
  Future<void> sendReliable(String peerId, Message message) async {
    final messageId = generateMessageId();
    final reliableMessage = ReliableMessage(
      id: messageId,
      payload: message,
      timestamp: DateTime.now(),
    );
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      await _sendMessage(peerId, reliableMessage);
      
      final ack = await _waitForAck(messageId, ackTimeout);
      if (ack != null) return; // 成功
      
      // 重试前的延迟
      await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
    }
    
    throw MessageDeliveryException('Failed to deliver message after $maxRetries attempts');
  }
}
```

### 连接恢复机制
```dart
class ReconnectionManager {
  static const Duration initialDelay = Duration(seconds: 1);
  static const Duration maxDelay = Duration(seconds: 30);
  static const int maxAttempts = 10;
  
  Future<void> handleConnectionLoss(String peerId) async {
    Duration delay = initialDelay;
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(delay);
      
      try {
        await _attemptReconnection(peerId);
        _onReconnectionSuccess(peerId);
        return;
      } catch (e) {
        _logger.warning('Reconnection attempt ${attempt + 1} failed: $e');
        delay = Duration(milliseconds: min(delay.inMilliseconds * 2, maxDelay.inMilliseconds));
      }
    }
    
    _onReconnectionFailed(peerId);
  }
}
```

## 🔧 配置管理

### WebRTC配置
```dart
class WebRTCConfig {
  static const Map<String, dynamic> defaultConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {
        'urls': 'turn:your-turn-server.com:3478',
        'username': 'your-username',
        'credential': 'your-password',
      },
    ],
    'iceCandidatePoolSize': 10,
    'bundlePolicy': 'max-bundle',
    'rtcpMuxPolicy': 'require',
  };
  
  static const Map<String, dynamic> dataChannelConfig = {
    'ordered': true,
    'maxRetransmits': 3,
    'maxPacketLifeTime': 3000,
  };
}
```

### 性能调优参数
```dart
class NetworkPerformanceConfig {
  static const int maxConcurrentConnections = 50;
  static const int messageQueueSize = 1000;
  static const Duration heartbeatInterval = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const int maxMessageSize = 64 * 1024; // 64KB
  static const bool enableCompression = true;
  static const CompressionLevel compressionLevel = CompressionLevel.balanced;
}
```

## 📊 性能监控

### 关键性能指标
```dart
class NetworkPerformanceMetrics {
  // 连接指标
  int get activeConnections;
  int get totalConnectionsCreated;
  int get connectionFailures;
  Duration get averageConnectionTime;
  
  // 消息指标
  int get messagesSent;
  int get messagesReceived;
  int get messagesLost;
  double get messageSuccessRate;
  
  // 网络指标
  Duration get averageLatency;
  double get averageBandwidth;
  double get packetLossRate;
  
  // 资源指标
  int get memoryUsage;
  double get cpuUsage;
  int get openFileDescriptors;
}
```

### 性能优化策略
```dart
class NetworkOptimizer {
  // 连接池优化
  void optimizeConnectionPool() {
    _removeIdleConnections();
    _balanceConnectionLoad();
    _preemptivelyCreateConnections();
  }
  
  // 消息批处理
  void enableMessageBatching() {
    _batchSmallMessages();
    _compressLargeMessages();
    _prioritizeUrgentMessages();
  }
  
  // 网络自适应
  void adaptToNetworkConditions() {
    _adjustCompressionLevel();
    _modifyRetransmissionStrategy();
    _optimizeBufferSizes();
  }
}
```

## 🧪 测试策略

### 单元测试
```dart
void main() {
  group('WebRTCManager', () {
    late WebRTCManager manager;
    
    setUp(() {
      manager = WebRTCManager();
    });
    
    test('should create peer connection', () async {
      final connectionId = await manager.createConnection('peer1', true);
      expect(connectionId, isNotNull);
      expect(manager.connectionStates['peer1'], ConnectionState.connecting);
    });
    
    test('should handle connection failure', () async {
      // 模拟网络故障
      when(mockNetworkAdapter.isConnected).thenReturn(false);
      
      expect(
        () => manager.createConnection('peer1', true),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
```

### 集成测试
```dart
void main() {
  group('Network Integration Tests', () {
    testWidgets('should establish P2P connection', (tester) async {
      // 创建两个WebRTC管理器实例
      final manager1 = WebRTCManager();
      final manager2 = WebRTCManager();
      
      // 建立连接
      await manager1.createConnection('peer2', true);
      await manager2.createConnection('peer1', false);
      
      // 等待连接建立
      await tester.pump(Duration(seconds: 5));
      
      // 验证连接状态
      expect(manager1.connectionStates['peer2'], ConnectionState.connected);
      expect(manager2.connectionStates['peer1'], ConnectionState.connected);
    });
  });
}
```

### 压力测试
```dart
void main() {
  group('Network Stress Tests', () {
    test('should handle 100 concurrent connections', () async {
      final manager = WebRTCManager();
      final futures = <Future>[];
      
      // 创建100个并发连接
      for (int i = 0; i < 100; i++) {
        futures.add(manager.createConnection('peer$i', true));
      }
      
      // 等待所有连接完成
      await Future.wait(futures);
      
      // 验证连接数量
      expect(manager.connectionStates.length, 100);
    });
  });
}
```

## 📋 开发清单

### 第一阶段：基础网络层
- [ ] WebRTCManager基础实现
- [ ] SignalingClient WebSocket连接
- [ ] 基础消息路由
- [ ] 连接状态管理

### 第二阶段：可靠性增强
- [ ] ReliableTransport可靠传输
- [ ] ReconnectionManager重连机制
- [ ] 消息确认和重试
- [ ] 错误处理和恢复

### 第三阶段：性能优化
- [ ] ConnectionPool连接池
- [ ] 消息压缩和批处理
- [ ] NetworkMonitor性能监控
- [ ] 自适应网络优化

### 第四阶段：安全和监控
- [ ] 数据加密传输
- [ ] 身份验证机制
- [ ] 详细性能指标
- [ ] 调试和诊断工具

## 🔗 依赖关系

- **上游依赖**：models/, utils/
- **下游依赖**：services/, blocs/
- **外部依赖**：flutter_webrtc, web_socket_channel
- **系统依赖**：网络连接, STUN/TURN服务器

## 📝 开发规范

1. **异步处理**：所有网络操作必须异步
2. **错误处理**：完善的异常捕获和处理
3. **资源管理**：及时释放网络资源
4. **日志记录**：详细的网络操作日志
5. **配置化**：网络参数可配置
6. **测试覆盖**：确保高测试覆盖率