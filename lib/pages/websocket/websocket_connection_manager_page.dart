import 'dart:async';
import 'package:flutter/material.dart';

import '../../components/common/draggable_title_bar.dart';
import '../../components/layout/main_layout.dart';
import '../../collaboration/services/websocket/websocket_client_manager.dart';
import '../../collaboration/services/websocket/websocket_client_service.dart';
import '../../models/websocket_client_config.dart';
import '../../collaboration/services/websocket/websocket_client_init_service.dart';

/// WebSocket 连接管理页面
class WebSocketConnectionManagerPage extends BasePage {
  final VoidCallback? onClose;

  const WebSocketConnectionManagerPage({super.key, this.onClose});

  @override
  Widget buildContent(BuildContext context) {
    return _WebSocketConnectionManagerPageContent(onClose: onClose);
  }
}

/// WebSocket 连接管理页面内容
class _WebSocketConnectionManagerPageContent extends StatefulWidget {
  final VoidCallback? onClose;

  const _WebSocketConnectionManagerPageContent({this.onClose});

  @override
  State<_WebSocketConnectionManagerPageContent> createState() =>
      _WebSocketConnectionManagerPageState();
}

class _WebSocketConnectionManagerPageState
    extends State<_WebSocketConnectionManagerPageContent> {
  final WebSocketClientManager _manager = WebSocketClientManager();
  final WebSocketClientService _service = WebSocketClientService();
  final WebSocketClientInitService _initService = WebSocketClientInitService();

  // 状态管理
  bool _isLoading = false;
  String? _errorMessage;
  List<WebSocketClientConfig> _configs = [];
  WebSocketClientConfig? _activeConfig;
  WebSocketConnectionState _connectionState =
      WebSocketConnectionState.disconnected;
  int _currentPingDelay = 0; // 当前延迟（毫秒）

  // 日志管理
  final List<String> _logs = [];
  final ScrollController _logScrollController = ScrollController();

  // 流订阅
  StreamSubscription? _stateSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _configsSubscription;
  StreamSubscription? _activeConfigSubscription;
  StreamSubscription? _pingDelaySubscription;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _initializeManager();
    _setupSubscriptions();
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _errorSubscription?.cancel();
    _configsSubscription?.cancel();
    _activeConfigSubscription?.cancel();
    _pingDelaySubscription?.cancel();
    _messageSubscription?.cancel();
    _logScrollController.dispose();
    super.dispose();
  }

  /// 初始化管理器
  Future<void> _initializeManager() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _manager.initialize();
      await _loadConfigs();
      _addLog('WebSocket 连接管理器初始化成功');
    } catch (e) {
      setState(() {
        _errorMessage = '初始化失败: $e';
      });
      _addLog('初始化失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 设置流订阅
  void _setupSubscriptions() {
    // 监听连接状态变化
    _stateSubscription = _manager.connectionStateStream.listen((state) {
      setState(() {
        _connectionState = state;
      });
      _addLog('连接状态变更: ${_getStateDisplayName(state)}');
    });

    // 监听错误信息
    _errorSubscription = _manager.errorStream.listen((error) {
      _addLog('错误: $error');
    });

    // 监听延迟变化
    _pingDelaySubscription = _manager.pingDelayStream.listen((delay) {
      setState(() {
        _currentPingDelay = delay;
      });
      _addLog('延迟更新: ${delay}ms');
    });

    // 监听WebSocket消息（包括用户状态广播）
    _messageSubscription = _manager.messageStream.listen((message) {
      if (message.type == 'user_status_broadcast') {
        final data = message.data;
        final userId = data['user_id'] as String?;
        final onlineStatus = data['online_status'] as String?;
        final activityStatus = data['activity_status'] as String?;
        final spaceId = data['space_id'] as String?;
        
        _addLog('用户状态广播: 用户=$userId, 在线状态=$onlineStatus, 活动状态=$activityStatus, 空间=$spaceId');
      }
    });

    // 监听配置变化
    _configsSubscription = _manager.configsStream.listen((configs) {
      setState(() {
        _configs = configs;
      });
      _addLog('配置列表已更新，共 ${configs.length} 个配置');
    });

    // 监听活跃配置变化
    _activeConfigSubscription = _manager.activeConfigStream.listen((config) {
      setState(() {
        _activeConfig = config;
      });
      if (config != null) {
        _addLog('活跃配置变更: ${config.displayName} (${config.clientId})');
      } else {
        _addLog('活跃配置已清除');
      }
    });
  }

  /// 加载配置列表
  Future<void> _loadConfigs() async {
    try {
      final configs = await _manager.getAllConfigs();
      final activeConfig = await _manager.getActiveConfig();

      setState(() {
        _configs = configs;
        _activeConfig = activeConfig;
        _connectionState = _manager.connectionState;
        _currentPingDelay = _manager.currentPingDelay;
      });

      _addLog('配置列表已加载，共 ${configs.length} 个配置');
      if (activeConfig != null) {
        _addLog('当前活跃配置: ${activeConfig.displayName}');
        _addLog('当前连接状态: ${_getStateDisplayName(_connectionState)}');
      }
    } catch (e) {
      _addLog('加载配置失败: $e');
    }
  }

  /// 添加日志
  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logMessage = '[$timestamp] $message';

    // 检查组件是否仍然挂载
    if (!mounted) return;
    
    setState(() {
      _logs.add(logMessage);
      // 限制日志数量，避免内存溢出
      if (_logs.length > 1000) {
        _logs.removeAt(0);
      }
    });

    // 自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 获取状态显示名称
  String _getStateDisplayName(WebSocketConnectionState state) {
    switch (state) {
      case WebSocketConnectionState.disconnected:
        return '已断开';
      case WebSocketConnectionState.connecting:
        return '连接中';
      case WebSocketConnectionState.authenticating:
        return '认证中';
      case WebSocketConnectionState.connected:
        return '已连接';
      case WebSocketConnectionState.reconnecting:
        return '重连中';
      case WebSocketConnectionState.error:
        return '错误';
    }
  }

  /// 获取状态颜色
  Color _getStateColor(WebSocketConnectionState state) {
    switch (state) {
      case WebSocketConnectionState.disconnected:
        return Colors.grey;
      case WebSocketConnectionState.connecting:
      case WebSocketConnectionState.authenticating:
      case WebSocketConnectionState.reconnecting:
        return Colors.orange;
      case WebSocketConnectionState.connected:
        return Colors.green;
      case WebSocketConnectionState.error:
        return Colors.red;
    }
  }

  /// 获取排序后的配置列表
  List<WebSocketClientConfig> _getSortedConfigs() {
    final configs = List<WebSocketClientConfig>.from(_configs);

    // 排序：活跃配置在顶部，其他按显示名称字母排序
    configs.sort((a, b) {
      final aIsActive = _activeConfig?.clientId == a.clientId;
      final bIsActive = _activeConfig?.clientId == b.clientId;

      if (aIsActive && !bIsActive) return -1;
      if (!aIsActive && bIsActive) return 1;

      // 都是活跃或都不是活跃，按名称排序
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return configs;
  }

  /// 创建新的客户端配置
  Future<void> _createNewConfig() async {
    // 显示创建对话框
    await _showCreateConfigDialog();
  }

  /// 显示创建配置对话框
  Future<void> _showCreateConfigDialog() async {
    final webApiKeyController = TextEditingController();
    final displayNameController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('创建新的客户端配置'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: displayNameController,
                  decoration: const InputDecoration(
                    labelText: '显示名称',
                    hintText: '输入客户端显示名称',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: webApiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Web API Key',
                    hintText: '输入 Web API Key',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final displayName = displayNameController.text.trim();
                final webApiKey = webApiKeyController.text.trim();

                if (displayName.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('请输入显示名称')));
                  return;
                }

                if (webApiKey.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入 Web API Key')),
                  );
                  return;
                }

                await _createConfigWithWebApiKey(webApiKey, displayName);
                Navigator.of(context).pop();
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );

    webApiKeyController.dispose();
    displayNameController.dispose();
  }

  /// 使用 Web API Key 创建客户端配置
  Future<void> _createConfigWithWebApiKey(
    String webApiKey,
    String displayName,
  ) async {
    _addLog('开始使用 Web API Key 创建客户端配置...');

    try {
      final config = await _initService.initializeWithWebApiKey(
        webApiKey,
        displayName,
      );

      _addLog('客户端配置创建成功: ${config.displayName} (${config.clientId})');
      await _loadConfigs();
    } catch (e) {
      _addLog('使用 Web API Key 创建客户端配置失败: $e');
    }
  }

  /// 设置活跃配置
  Future<void> _setActiveConfig(WebSocketClientConfig config) async {
    _addLog('设置活跃配置: ${config.displayName} (${config.clientId})');

    try {
      await _manager.setActiveConfig(config.clientId);
      await _loadConfigs(); // 刷新状态
      _addLog('活跃配置设置成功');
    } catch (e) {
      _addLog('设置活跃配置失败: $e');
    }
  }

  /// 取消活跃配置
  Future<void> _clearActiveConfig() async {
    _addLog('取消当前活跃配置...');

    try {
      // 先断开连接
      if (_connectionState != WebSocketConnectionState.disconnected) {
        await _disconnect();
      }

      // 清除活跃配置（设置为空字符串）
      await _manager.setActiveConfig('');
      await _loadConfigs(); // 刷新状态
      _addLog('活跃配置已取消');
    } catch (e) {
      _addLog('取消活跃配置失败: $e');
    }
  }

  /// 连接到指定配置
  Future<void> _connectToConfig(WebSocketClientConfig config) async {
    _addLog('开始连接到: ${config.displayName} (${config.clientId})');

    try {
      // 先设置为活跃配置
      await _setActiveConfig(config);

      // 然后连接
      final success = await _manager.connect(config.clientId);
      if (success) {
        _addLog('连接成功');
      } else {
        _addLog('连接失败');
      }
    } catch (e) {
      _addLog('连接错误: $e');
    }
  }

  /// 断开连接
  Future<void> _disconnect() async {
    _addLog('断开当前连接...');

    try {
      await _manager.disconnect();
      _addLog('连接已断开');
    } catch (e) {
      _addLog('断开连接失败: $e');
    }
  }

  /// 删除配置
  Future<void> _deleteConfig(WebSocketClientConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除配置 "${config.displayName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _addLog('删除配置: ${config.displayName} (${config.clientId})');

      try {
        await _manager.deleteConfig(config.clientId);
        _addLog('配置删除成功');
        await _loadConfigs();
      } catch (e) {
        _addLog('删除配置失败: $e');
      }
    }
  }

  /// 清空日志
  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
    _addLog('日志已清空');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 标题栏
          DraggableTitleBar(
            title: 'WebSocket 连接管理',
            icon: Icons.wifi,
            actions: [
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  tooltip: '关闭',
                ),
            ],
          ),

          // 主体内容
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializeManager,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  )
                : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  /// 构建主体内容
  Widget _buildMainContent() {
    return Row(
      children: [
        // 左侧：连接列表和信息
        Expanded(flex: 1, child: _buildLeftPanel()),

        // 分隔线
        Container(width: 1, color: Theme.of(context).dividerColor),

        // 右侧：控制台日志
        Expanded(flex: 1, child: _buildRightPanel()),
      ],
    );
  }

  /// 构建左侧面板
  Widget _buildLeftPanel() {
    return Stack(
      children: [
        Column(
          children: [
            // 工具栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Text('连接配置', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _createNewConfig,
                    icon: const Icon(Icons.add),
                    label: const Text('新建'),
                  ),
                ],
              ),
            ),

            // 配置列表
            Expanded(
              child: _configs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暂无连接配置',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '点击"新建"按钮创建第一个连接配置',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: _activeConfig != null ? 120 : 16, // 为浮动卡片留出空间
                      ),
                      itemCount: _configs.length,
                      itemBuilder: (context, index) {
                        final sortedConfigs = _getSortedConfigs();
                        final config = sortedConfigs[index];
                        final isActive =
                            _activeConfig?.clientId == config.clientId;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          elevation: isActive ? 4 : 1,
                          color: isActive
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          child: ListTile(
                            leading: Icon(
                              isActive
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(config.displayName)),
                                if (isActive &&
                                    _connectionState ==
                                        WebSocketConnectionState.connected &&
                                    _currentPingDelay > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _currentPingDelay < 100
                                          ? Colors.green
                                          : _currentPingDelay < 300
                                          ? Colors.orange
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_currentPingDelay}ms',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              '${config.server.host}:${config.server.port}\n${config.clientId}',
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) {
                                switch (action) {
                                  case 'setActive':
                                    _setActiveConfig(config);
                                    break;
                                  case 'clearActive':
                                    _clearActiveConfig();
                                    break;
                                  case 'connect':
                                    _connectToConfig(config);
                                    break;
                                  case 'disconnect':
                                    _disconnect();
                                    break;
                                  case 'delete':
                                    _deleteConfig(config);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                if (!isActive)
                                  const PopupMenuItem(
                                    value: 'setActive',
                                    child: ListTile(
                                      leading: Icon(Icons.radio_button_checked),
                                      title: Text('设为活跃'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                if (isActive)
                                  const PopupMenuItem(
                                    value: 'clearActive',
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.radio_button_unchecked,
                                      ),
                                      title: Text('取消活跃'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                if (isActive &&
                                    (_connectionState ==
                                            WebSocketConnectionState
                                                .disconnected ||
                                        _connectionState ==
                                            WebSocketConnectionState.error))
                                  const PopupMenuItem(
                                    value: 'connect',
                                    child: ListTile(
                                      leading: Icon(Icons.play_arrow),
                                      title: Text('连接'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                if (isActive &&
                                    (_connectionState ==
                                            WebSocketConnectionState
                                                .connected ||
                                        _connectionState ==
                                            WebSocketConnectionState
                                                .connecting ||
                                        _connectionState ==
                                            WebSocketConnectionState
                                                .authenticating ||
                                        _connectionState ==
                                            WebSocketConnectionState
                                                .reconnecting))
                                  const PopupMenuItem(
                                    value: 'disconnect',
                                    child: ListTile(
                                      leading: Icon(Icons.stop),
                                      title: Text('断开'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('删除'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _setActiveConfig(config),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        
        // 浮动的连接状态信息
        if (_activeConfig != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildConnectionStatus(),
          ),
      ],
    );
  }

  /// 构建连接状态信息
  Widget _buildConnectionStatus() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getStateColor(_connectionState), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: _getStateColor(_connectionState),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStateDisplayName(_connectionState),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _getStateColor(_connectionState),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_connectionState == WebSocketConnectionState.connected ||
                    _connectionState == WebSocketConnectionState.connecting ||
                    _connectionState ==
                        WebSocketConnectionState.authenticating ||
                    _connectionState == WebSocketConnectionState.reconnecting)
                  ElevatedButton(
                    onPressed: _disconnect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('断开'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '当前配置: ${_activeConfig!.displayName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '服务器: ${_activeConfig!.server.host}:${_activeConfig!.server.port}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_connectionState == WebSocketConnectionState.connected &&
                _currentPingDelay > 0)
              Text(
                '延迟: ${_currentPingDelay}ms',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _currentPingDelay < 100
                      ? Colors.green
                      : _currentPingDelay < 300
                      ? Colors.orange
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建右侧面板
  Widget _buildRightPanel() {
    return Column(
      children: [
        // 日志工具栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Text('活动日志', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: _clearLogs,
                icon: const Icon(Icons.clear_all),
                label: const Text('清空'),
              ),
            ],
          ),
        ),

        // 日志内容
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _logs.isEmpty
                ? Center(
                    child: Text(
                      '暂无日志',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _logScrollController,
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          log,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}