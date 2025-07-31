// This file has been processed by AI for internationalization
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:r6box/services/notification/notification_service.dart';

import '../../components/common/draggable_title_bar.dart';
import '../../components/layout/main_layout.dart';
import '../../collaboration/services/websocket/websocket_client_manager.dart';
import '../../models/websocket_client_config.dart';
import '../../collaboration/services/websocket/websocket_client_init_service.dart';
import '../../collaboration/services/websocket/websocket_client_service.dart';
import '../../services/localization_service.dart';

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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _manager.initialize();
      await _loadConfigs();
      _addLog(
        LocalizationService.instance.current.webSocketManagerInitialized_7281,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = LocalizationService.instance.current
            .initializationFailed(e);
      });
      _addLog(
        LocalizationService.instance.current.initializationFailed_7285(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 设置流订阅
  void _setupSubscriptions() {
    // 监听连接状态变化
    _stateSubscription = _manager.connectionStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _connectionState = state;
      });
      _addLog(
        LocalizationService.instance.current.connectionStateChanged_7281(
          _getStateDisplayName(state),
        ),
      );
    });

    // 监听错误信息
    _errorSubscription = _manager.errorStream.listen((error) {
      _addLog(LocalizationService.instance.current.errorLog_7421(error));
    });

    // 监听延迟变化
    _pingDelaySubscription = _manager.pingDelayStream.listen((delay) {
      if (!mounted) return;
      setState(() {
        _currentPingDelay = delay;
      });
      _addLog(LocalizationService.instance.current.delayUpdateLog(delay));
    });

    // 监听WebSocket消息（包括用户状态广播）
    _messageSubscription = _manager.messageStream.listen((message) {
      if (message.type == 'user_status_broadcast') {
        final data = message.data;
        final userId = data['user_id'] as String?;
        final onlineStatus = data['online_status'] as String?;
        final activityStatus = data['activity_status'] as String?;
        final spaceId = data['space_id'] as String?;

        _addLog(
          LocalizationService.instance.current.userStatusBroadcast_7421(
            activityStatus ?? 'unknown',
            onlineStatus ?? 'unknown',
            spaceId ?? 'unknown',
            userId ?? 'unknown',
          ),
        );
      }
    });

    // 监听配置变化
    _configsSubscription = _manager.configsStream.listen((configs) {
      if (!mounted) return;
      setState(() {
        _configs = configs;
      });
      _addLog(
        LocalizationService.instance.current.configListUpdated(configs.length),
      );
    });

    // 监听活跃配置变化
    _activeConfigSubscription = _manager.activeConfigStream.listen((config) {
      if (!mounted) return;
      setState(() {
        _activeConfig = config;
      });
      if (config != null) {
        _addLog(
          LocalizationService.instance.current.activeConfigChange(
            config.displayName,
            config.clientId,
          ),
        );
      } else {
        _addLog(LocalizationService.instance.current.activeConfigCleared_7281);
      }
    });
  }

  /// 加载配置列表
  Future<void> _loadConfigs() async {
    try {
      final configs = await _manager.getAllConfigs();
      final activeConfig = await _manager.getActiveConfig();

      if (!mounted) return;
      setState(() {
        _configs = configs;
        _activeConfig = activeConfig;
        _connectionState = _manager.connectionState;
        _currentPingDelay = _manager.currentPingDelay;
      });

      _addLog(
        LocalizationService.instance.current.configListLoaded(configs.length),
      );
      if (activeConfig != null) {
        _addLog(
          LocalizationService.instance.current.activeConfigLog(
            activeConfig.displayName,
          ),
        );
        _addLog(
          LocalizationService.instance.current.currentConnectionState_7421(
            _getStateDisplayName(_connectionState),
          ),
        );
      }
    } catch (e) {
      _addLog(LocalizationService.instance.current.loadConfigFailed(e));
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
      if (mounted && _logScrollController.hasClients) {
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
        return LocalizationService.instance.current.disconnected_4821;
      case WebSocketConnectionState.connecting:
        return LocalizationService.instance.current.connecting_5732;
      case WebSocketConnectionState.authenticating:
        return LocalizationService.instance.current.authenticating_6943;
      case WebSocketConnectionState.connected:
        return LocalizationService.instance.current.connected_7154;
      case WebSocketConnectionState.reconnecting:
        return LocalizationService.instance.current.reconnecting_8265;
      case WebSocketConnectionState.error:
        return LocalizationService.instance.current.error_9376;
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
          title: Text(
            LocalizationService.instance.current.createNewClientConfig_7281,
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: displayNameController,
                  decoration: InputDecoration(
                    labelText: LocalizationService
                        .instance
                        .current
                        .displayNameLabel_4821,
                    hintText: LocalizationService
                        .instance
                        .current
                        .displayNameHint_4821,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: webApiKeyController,
                  decoration: InputDecoration(
                    labelText: LocalizationService
                        .instance
                        .current
                        .webApiKeyLabel_4821,
                    hintText:
                        LocalizationService.instance.current.webApiKeyHint_7532,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                LocalizationService.instance.current.cancelButton_7421,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final displayName = displayNameController.text.trim();
                final webApiKey = webApiKeyController.text.trim();
                final navigator = Navigator.of(context);

                if (displayName.isEmpty) {
                  context.showErrorSnackBar(
                    LocalizationService.instance.current.enterDisplayName_4821,
                  );
                  return;
                }

                if (webApiKey.isEmpty) {
                  context.showErrorSnackBar(
                    LocalizationService.instance.current.enterWebApiKey_4821,
                  );
                  return;
                }

                await _createConfigWithWebApiKey(webApiKey, displayName);
                if (mounted) {
                  navigator.pop();
                }
              },
              child: Text(
                LocalizationService.instance.current.createButton_7421,
              ),
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
    _addLog(
      LocalizationService
          .instance
          .current
          .startCreatingClientConfigWithWebApiKey_4821,
    );

    try {
      final config = await _initService.initializeWithWebApiKey(
        webApiKey,
        displayName,
      );

      _addLog(
        LocalizationService.instance.current.clientConfigCreatedSuccessfully(
          config.displayName,
          config.clientId,
        ),
      );
      await _loadConfigs();
    } catch (e) {
      _addLog(
        LocalizationService.instance.current.webApiKeyClientConfigFailed(e),
      );
    }
  }

  /// 设置活跃配置
  Future<void> _setActiveConfig(WebSocketClientConfig config) async {
    _addLog(
      LocalizationService.instance.current.setActiveConfig(
        config.displayName,
        config.clientId,
      ),
    );

    try {
      await _manager.setActiveConfig(config.clientId);
      await _loadConfigs(); // 刷新状态
      _addLog(LocalizationService.instance.current.activeConfigSetSuccess_4821);
    } catch (e) {
      _addLog(LocalizationService.instance.current.setActiveConfigFailed(e));
    }
  }

  /// 取消活跃配置
  Future<void> _clearActiveConfig() async {
    _addLog(LocalizationService.instance.current.cancelActiveConfig_7421);

    try {
      // 先断开连接
      if (_connectionState != WebSocketConnectionState.disconnected) {
        await _disconnect();
      }

      // 清除活跃配置（设置为空字符串）
      await _manager.setActiveConfig('');
      await _loadConfigs(); // 刷新状态
      _addLog(LocalizationService.instance.current.activeConfigCancelled_7281);
    } catch (e) {
      _addLog(
        LocalizationService.instance.current.cancelActiveConfigFailed_7285(e),
      );
    }
  }

  /// 连接到指定配置
  Future<void> _connectToConfig(WebSocketClientConfig config) async {
    _addLog(
      LocalizationService.instance.current.connectingToTarget(
        config.clientId,
        config.displayName,
      ),
    );

    try {
      // 先设置为活跃配置
      await _setActiveConfig(config);

      // 然后连接
      final success = await _manager.connect(config.clientId);
      if (success) {
        _addLog(LocalizationService.instance.current.connectionSuccess_4821);
      } else {
        _addLog(
          LocalizationService.instance.current.connectionFailed_7281(
            'Connection attempt failed',
          ),
        );
      }
    } catch (e) {
      final errorMessage = LocalizationService.instance.current
          .connectionError_5421(e);
      _addLog(errorMessage);
    }
  }

  /// 断开连接
  Future<void> _disconnect() async {
    _addLog(
      LocalizationService.instance.current.disconnectCurrentConnection_7281,
    );

    try {
      await _manager.disconnect();
      _addLog(LocalizationService.instance.current.connectionDisconnected_4821);
    } catch (e) {
      _addLog(LocalizationService.instance.current.disconnectFailed_7285(e));
    }
  }

  /// 删除配置
  Future<void> _deleteConfig(WebSocketClientConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.confirmDelete_7281),
        content: Text(
          LocalizationService.instance.current.confirmDeleteConfig(
            config.displayName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocalizationService.instance.current.cancel_4821),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(LocalizationService.instance.current.delete_4821),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _addLog(
        LocalizationService.instance.current.deleteConfigLog_7421(
          config.displayName,
          config.clientId,
        ),
      );

      try {
        await _manager.deleteConfig(config.clientId);
        _addLog(
          LocalizationService
              .instance
              .current
              .configurationDeletedSuccessfully_7421,
        );
        await _loadConfigs();
      } catch (e) {
        _addLog(
          LocalizationService.instance.current.deleteConfigFailed_7284(e),
        );
      }
    }
  }

  /// 清空日志
  void _clearLogs() {
    if (!mounted) return;
    setState(() {
      _logs.clear();
    });
    _addLog(LocalizationService.instance.current.logCleared_7281);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 标题栏
          DraggableTitleBar(
            title: LocalizationService
                .instance
                .current
                .websocketConnectionManagement_4821,
            icon: Icons.wifi,
            actions: [
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  tooltip:
                      LocalizationService.instance.current.closeButton_7421,
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
                          child: Text(
                            LocalizationService.instance.current.retry_4821,
                          ),
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
                  Text(
                    LocalizationService.instance.current.connectionConfig_7281,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _createNewConfig,
                    icon: const Icon(Icons.add),
                    label: Text(
                      LocalizationService.instance.current.newButton_4821,
                    ),
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
                            LocalizationService
                                .instance
                                .current
                                .noConnectionConfig_4521,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            LocalizationService
                                .instance
                                .current
                                .createFirstConnectionHint_4821,
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
                                  PopupMenuItem(
                                    value: 'setActive',
                                    child: ListTile(
                                      leading: Icon(Icons.radio_button_checked),
                                      title: Text(
                                        LocalizationService
                                            .instance
                                            .current
                                            .setAsActive_7281,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                if (isActive)
                                  PopupMenuItem(
                                    value: 'clearActive',
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.radio_button_unchecked,
                                      ),
                                      title: Text(
                                        LocalizationService
                                            .instance
                                            .current
                                            .cancelActive_7281,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                if (isActive &&
                                    (_connectionState ==
                                            WebSocketConnectionState
                                                .disconnected ||
                                        _connectionState ==
                                            WebSocketConnectionState.error))
                                  PopupMenuItem(
                                    value: 'connect',
                                    child: ListTile(
                                      leading: Icon(Icons.play_arrow),
                                      title: Text(
                                        LocalizationService
                                            .instance
                                            .current
                                            .connect_4821,
                                      ),
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
                                  PopupMenuItem(
                                    value: 'disconnect',
                                    child: ListTile(
                                      leading: Icon(Icons.stop),
                                      title: Text(
                                        LocalizationService
                                            .instance
                                            .current
                                            .disconnect_7421,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text(
                                      LocalizationService
                                          .instance
                                          .current
                                          .delete_4821,
                                    ),
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
      shadowColor: Colors.black.withValues(alpha: 0.3),
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
                    child: Text(
                      LocalizationService.instance.current.disconnect_7421,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              LocalizationService.instance.current.currentConfigDisplay(
                _activeConfig!.displayName,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              LocalizationService.instance.current.serverInfo(
                _activeConfig!.server.host,
                _activeConfig!.server.port,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_connectionState == WebSocketConnectionState.connected &&
                _currentPingDelay > 0)
              Text(
                LocalizationService.instance.current.latencyWithValue(
                  _currentPingDelay,
                ),
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
              Text(
                LocalizationService.instance.current.activityLog_7281,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _clearLogs,
                icon: const Icon(Icons.clear_all),
                label: Text(
                  LocalizationService.instance.current.clearText_4821,
                ),
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
                      LocalizationService.instance.current.noLogsAvailable_7421,
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
