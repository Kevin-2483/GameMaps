import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/websocket_client_config.dart';
import '../../collaboration/services/websocket/websocket_client_manager.dart';
import '../../collaboration/services/websocket/websocket_client_service.dart';
import '../../services/localization_service.dart';

/// WebSocket 客户端演示页面
class WebSocketClientDemoPage extends StatefulWidget {
  const WebSocketClientDemoPage({super.key});

  @override
  State<WebSocketClientDemoPage> createState() =>
      _WebSocketClientDemoPageState();
}

class _WebSocketClientDemoPageState extends State<WebSocketClientDemoPage> {
  final WebSocketClientManager _manager = WebSocketClientManager();
  final TextEditingController _webApiKeyController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _hostController = TextEditingController(
    text: 'localhost',
  );
  final TextEditingController _portController = TextEditingController(
    text: '8080',
  );
  final TextEditingController _pathController = TextEditingController(
    text: '/ws/client',
  );

  List<WebSocketClientConfig> _configs = [];
  WebSocketClientConfig? _activeConfig;
  WebSocketConnectionState _connectionState =
      WebSocketConnectionState.disconnected;
  List<String> _messages = [];
  List<String> _errors = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeManager();
  }

  Future<void> _initializeManager() async {
    try {
      await _manager.initialize();

      // 监听配置变化
      _manager.configsStream.listen((configs) {
        if (mounted) {
          setState(() {
            _configs = configs;
          });
        }
      });

      // 监听活跃配置变化
      _manager.activeConfigStream.listen((config) {
        if (mounted) {
          setState(() {
            _activeConfig = config;
          });
        }
      });

      // 监听连接状态变化
      _manager.connectionStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _connectionState = state;
          });
        }
      });

      // 监听消息
      _manager.messageStream.listen((message) {
        if (mounted) {
          setState(() {
            _messages.add(
              LocalizationService.instance.current.receivedMessage(
                message.type,
                message.data,
              ),
            );
          });
        }
      });

      // 监听错误
      _manager.errorStream.listen((error) {
        if (mounted) {
          setState(() {
            _errors.add(error);
          });
          _showSnackBar(
            LocalizationService.instance.current.errorMessage(error),
            isError: true,
          );
        }
      });

      setState(() {
        _isInitialized = true;
      });

      _showSnackBar(
        LocalizationService
            .instance
            .current
            .websocketManagerInitializedSuccess_4821,
      );
    } catch (e) {
      _showSnackBar(
        LocalizationService.instance.current.initializationFailed(e),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket 客户端演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionStatus(),
            const SizedBox(height: 20),
            _buildClientManagement(),
            const SizedBox(height: 20),
            _buildConnectionControls(),
            const SizedBox(height: 20),
            _buildMessageControls(),
            const SizedBox(height: 20),
            _buildMessageHistory(),
            const SizedBox(height: 20),
            _buildErrorHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    Color statusColor;
    String statusText;

    switch (_connectionState) {
      case WebSocketConnectionState.connected:
        statusColor = Colors.green;
        statusText = LocalizationService.instance.current.connected_4821;
        break;
      case WebSocketConnectionState.connecting:
        statusColor = Colors.orange;
        statusText = LocalizationService.instance.current.connecting_5723;
        break;
      case WebSocketConnectionState.authenticating:
        statusColor = Colors.blue;
        statusText = LocalizationService.instance.current.authenticating_6934;
        break;
      case WebSocketConnectionState.reconnecting:
        statusColor = Colors.amber;
        statusText = LocalizationService.instance.current.reconnecting_7845;
        break;
      case WebSocketConnectionState.error:
        statusColor = Colors.red;
        statusText = LocalizationService.instance.current.error_8956;
        break;
      default:
        statusColor = Colors.grey;
        statusText = LocalizationService.instance.current.disconnected_9067;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.connectionStatus_4821,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(statusText),
              ],
            ),
            if (_activeConfig != null) ...[
              const SizedBox(height: 8),
              Text(
                LocalizationService.instance.current.activeClientDisplay(
                  _activeConfig!.displayName,
                ),
              ),
              Text(
                LocalizationService.instance.current.clientIdLabel(
                  _activeConfig!.clientId,
                ),
              ),
              Text(
                LocalizationService.instance.current.serverInfo_4827(
                  _activeConfig!.server.host,
                  _activeConfig!.server.port,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientManagement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.current.clientManagement_7281,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Web API Key 创建
            TextField(
              controller: _webApiKeyController,
              decoration: const InputDecoration(
                labelText: 'Web API Key URL',
                hintText: 'https://example.com/api/client?key=xxx',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: '显示名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createClientWithWebApiKey,
                    child: const Text('使用 Web API Key 创建'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createDefaultClient,
                    child: const Text('创建默认客户端'),
                  ),
                ),
              ],
            ),

            // 默认客户端配置
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('默认客户端配置'),
              children: [
                TextField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: '主机',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: '端口',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _pathController,
                  decoration: const InputDecoration(
                    labelText: 'WebSocket 路径',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),

            // 客户端列表
            const SizedBox(height: 16),
            Text(
              '已配置的客户端 (${_configs.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ..._configs.map((config) => _buildClientTile(config)),
          ],
        ),
      ),
    );
  }

  Widget _buildClientTile(WebSocketClientConfig config) {
    final isActive = _activeConfig?.clientId == config.clientId;

    return Card(
      color: isActive ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(config.displayName),
        subtitle: Text(
          '${config.server.host}:${config.server.port}\n'
          '创建时间: ${config.createdAt.toString().substring(0, 19)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleClientAction(value, config),
          itemBuilder: (context) => [
            if (!isActive)
              const PopupMenuItem(value: 'activate', child: Text('设为活跃')),
            const PopupMenuItem(value: 'validate', child: Text('验证配置')),
            const PopupMenuItem(value: 'export', child: Text('导出配置')),
            const PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
        leading: Icon(
          isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: isActive ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
    );
  }

  Widget _buildConnectionControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('连接控制', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _activeConfig != null && !_manager.isConnected
                        ? _connect
                        : null,
                    child: const Text('连接'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _manager.isConnected ? _disconnect : null,
                    child: const Text('断开'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetReconnectAttempts,
                    child: const Text('重置重连'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('消息控制', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: '消息内容 (JSON)',
                hintText: '{"type": "test", "data": "hello"}',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _manager.isConnected ? _sendMessage : null,
                    child: const Text('发送消息'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _manager.isConnected ? _sendPing : null,
                    child: const Text('发送 Ping'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '消息历史 (${_messages.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => setState(() => _messages.clear()),
                  child: const Text('清空'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 2.0,
                    ),
                    child: Text(
                      _messages[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '错误历史 (${_errors.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => setState(() => _errors.clear()),
                  child: const Text('清空'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: _errors.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 2.0,
                    ),
                    child: Text(
                      _errors[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createClientWithWebApiKey() async {
    final webApiKey = _webApiKeyController.text.trim();
    final displayName = _displayNameController.text.trim();

    if (webApiKey.isEmpty || displayName.isEmpty) {
      _showSnackBar('请填写 Web API Key 和显示名称', isError: true);
      return;
    }

    try {
      await _manager.createClientWithWebApiKey(webApiKey, displayName);
      _webApiKeyController.clear();
      _displayNameController.clear();
      _showSnackBar('客户端创建成功');
    } catch (e) {
      _showSnackBar('创建客户端失败: $e', isError: true);
    }
  }

  Future<void> _createDefaultClient() async {
    final displayName = _displayNameController.text.trim();

    if (displayName.isEmpty) {
      _showSnackBar('请填写显示名称', isError: true);
      return;
    }

    try {
      final host = _hostController.text.trim();
      final port = int.tryParse(_portController.text.trim()) ?? 8080;
      final path = _pathController.text.trim();

      await _manager.createDefaultClient(
        displayName,
        host: host,
        port: port,
        path: path,
      );

      _displayNameController.clear();
      _showSnackBar('默认客户端创建成功');
    } catch (e) {
      _showSnackBar('创建默认客户端失败: $e', isError: true);
    }
  }

  Future<void> _handleClientAction(
    String action,
    WebSocketClientConfig config,
  ) async {
    switch (action) {
      case 'activate':
        try {
          await _manager.setActiveConfig(config.clientId);
          _showSnackBar('已设置为活跃客户端');
        } catch (e) {
          _showSnackBar('设置活跃客户端失败: $e', isError: true);
        }
        break;

      case 'validate':
        try {
          final isValid = await _manager.validateConfig(config.clientId);
          _showSnackBar(
            LocalizationService.instance.current.configValidationResult(
              isValid
                  ? LocalizationService.instance.current.valid_4821
                  : LocalizationService.instance.current.invalid_5739,
            ),
          );
        } catch (e) {
          _showSnackBar('验证配置失败: $e', isError: true);
        }
        break;

      case 'export':
        try {
          final exportData = await _manager.exportConfig(config.clientId);
          const encoder = JsonEncoder.withIndent('  ');
          final jsonString = encoder.convert(exportData);
          await Clipboard.setData(ClipboardData(text: jsonString));
          _showSnackBar('配置已复制到剪贴板');
        } catch (e) {
          _showSnackBar('导出配置失败: $e', isError: true);
        }
        break;

      case 'delete':
        final confirmed = await _showConfirmDialog(
          '确认删除',
          '确定要删除客户端 "${config.displayName}" 吗？此操作不可撤销。',
        );
        if (confirmed) {
          try {
            await _manager.deleteConfig(config.clientId);
            _showSnackBar('客户端已删除');
          } catch (e) {
            _showSnackBar('删除客户端失败: $e', isError: true);
          }
        }
        break;
    }
  }

  Future<void> _connect() async {
    try {
      final success = await _manager.connect();
      if (success) {
        _showSnackBar('连接成功');
      } else {
        _showSnackBar('连接失败', isError: true);
      }
    } catch (e) {
      _showSnackBar('连接失败: $e', isError: true);
    }
  }

  Future<void> _disconnect() async {
    try {
      await _manager.disconnect();
      _showSnackBar('已断开连接');
    } catch (e) {
      _showSnackBar('断开连接失败: $e', isError: true);
    }
  }

  void _resetReconnectAttempts() {
    _manager.resetReconnectAttempts();
    _showSnackBar('重连计数器已重置');
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) {
      _showSnackBar('请输入消息内容', isError: true);
      return;
    }

    try {
      final messageData = jsonDecode(messageText) as Map<String, dynamic>;
      final success = await _manager.sendJson(messageData);
      if (success) {
        _messageController.clear();
        setState(() {
          _messages.add('发送: ${messageData['type']} - $messageData');
        });
        _showSnackBar('消息发送成功');
      } else {
        _showSnackBar('消息发送失败', isError: true);
      }
    } catch (e) {
      _showSnackBar('消息格式错误: $e', isError: true);
    }
  }

  Future<void> _sendPing() async {
    try {
      final success = await _manager.sendJson({
        'type': 'ping',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      if (success) {
        setState(() {
          _messages.add('发送: ping');
        });
        _showSnackBar('Ping 发送成功');
      } else {
        _showSnackBar('Ping 发送失败', isError: true);
      }
    } catch (e) {
      _showSnackBar('Ping 发送失败: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _webApiKeyController.dispose();
    _displayNameController.dispose();
    _messageController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _pathController.dispose();
    super.dispose();
  }
}
