// This file has been processed by AI for internationalization
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:r6box/services/notification/notification_service.dart';
import 'package:uuid/uuid.dart';
import '../../components/common/draggable_title_bar.dart';
import '../../components/layout/main_layout.dart';
import '../../models/webdav_config.dart';
import '../../services/webdav/webdav_database_service.dart';
import '../../services/webdav/webdav_secure_storage_service.dart';
import '../../services/webdav/webdav_client_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// WebDAV管理页面
class WebDavManagerPage extends BasePage {
  const WebDavManagerPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _WebDavManagerPageContent();
  }
}

/// WebDAV管理页面内容
class _WebDavManagerPageContent extends StatefulWidget {
  const _WebDavManagerPageContent();

  @override
  State<_WebDavManagerPageContent> createState() => _WebDavManagerPageState();
}

class _WebDavManagerPageState extends State<_WebDavManagerPageContent>
    with TickerProviderStateMixin {
  final WebDavDatabaseService _dbService = WebDavDatabaseService();
  final WebDavSecureStorageService _secureStorage =
      WebDavSecureStorageService();
  final WebDavClientService _clientService = WebDavClientService();

  late TabController _tabController;

  // 状态管理
  bool _isLoading = false;
  String? _errorMessage;
  List<WebDavConfig> _configs = [];
  List<WebDavAuthAccount> _authAccounts = [];

  // 测试状态
  final Map<String, bool> _testingConfigs = {};
  final Map<String, WebDavTestResult?> _testResults = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 初始化服务
  Future<void> _initializeServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _clientService.initialize();
      await _loadData();
    } catch (e) {
      setState(() {
        _errorMessage = LocalizationService.instance.current
            .initializationFailed(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 加载数据
  Future<void> _loadData() async {
    try {
      final configs = await _dbService.getAllConfigs();
      final authAccounts = await _dbService.getAllAuthAccounts();

      setState(() {
        _configs = configs;
        _authAccounts = authAccounts;
      });
    } catch (e) {
      setState(() {
        _errorMessage = LocalizationService.instance.current.dataLoadFailed(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DraggableTitleBar(
            title: LocalizationService.instance.current.webDavManagement_7421,
            icon: Icons.cloud_sync,
          ),
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: LocalizationService.instance.current.webDavConfig_7281,
                icon: Icon(Icons.settings),
              ),
              Tab(
                text: LocalizationService.instance.current.verifiedAccount_7281,
                icon: Icon(Icons.account_circle),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [_buildConfigsTab(), _buildAuthAccountsTab()],
                  ),
          ),
        ],
      ),
    );
  }

  /// 构建配置标签页
  Widget _buildConfigsTab() {
    return Column(
      children: [
        // 工具栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _showAddConfigDialog,
                icon: const Icon(Icons.add),
                label: Text(
                  LocalizationService.instance.current.addConfiguration_7421,
                ),
              ),
              const Spacer(),
              Text(
                LocalizationService.instance.current.totalConfigsCount(
                  _configs.length,
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
                      const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        LocalizationService
                            .instance
                            .current
                            .noWebDAVConfig_7281,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocalizationService.instance.current.clickToAddConfig,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _configs.length,
                  itemBuilder: (context, index) {
                    final config = _configs[index];
                    return _buildConfigCard(config);
                  },
                ),
        ),
      ],
    );
  }

  /// 构建认证账户标签页
  Widget _buildAuthAccountsTab() {
    return Column(
      children: [
        // 工具栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _showAddAuthAccountDialog,
                icon: const Icon(Icons.add),
                label: Text(
                  LocalizationService.instance.current.addAccount_7421,
                ),
              ),
              const Spacer(),
              Text(
                LocalizationService.instance.current.totalAccountsCount(
                  _authAccounts.length,
                ),
              ),
            ],
          ),
        ),
        // 账户列表
        Expanded(
          child: _authAccounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_circle_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LocalizationService
                            .instance
                            .current
                            .noAuthenticatedAccount_7421,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocalizationService
                            .instance
                            .current
                            .clickToAddAccount_7281,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _authAccounts.length,
                  itemBuilder: (context, index) {
                    final account = _authAccounts[index];
                    return _buildAuthAccountCard(account);
                  },
                ),
        ),
      ],
    );
  }

  /// 构建配置卡片
  Widget _buildConfigCard(WebDavConfig config) {
    final authAccount = _authAccounts.firstWhere(
      (account) => account.authAccountId == config.authAccountId,
      orElse: () => WebDavAuthAccount(
        authAccountId: config.authAccountId,
        displayName: LocalizationService.instance.current.unknownAccount_4821,
        username: LocalizationService.instance.current.unknown_4822,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final isTestingThis = _testingConfigs[config.configId] ?? false;
    final testResult = _testResults[config.configId];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                Icon(
                  config.isEnabled ? Icons.cloud : Icons.cloud_off,
                  color: config.isEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    config.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                // 状态指示器
                if (testResult != null)
                  Icon(
                    testResult.success ? Icons.check_circle : Icons.error,
                    color: testResult.success ? Colors.green : Colors.red,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 配置信息
            _buildInfoRow(
              LocalizationService.instance.current.serverLabel_4821,
              config.serverUrl,
            ),
            _buildInfoRow(
              LocalizationService.instance.current.storagePath_7281,
              config.storagePath,
            ),
            _buildInfoRow(
              LocalizationService.instance.current.verifiedAccountTitle_4821,
              '${authAccount.displayName} (${authAccount.username})',
            ),
            if (testResult != null) ...[
              const SizedBox(height: 8),
              _buildTestResultInfo(testResult),
            ],
            const SizedBox(height: 16),
            // 操作按钮
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: isTestingThis
                      ? null
                      : () => _testConnection(config.configId),
                  icon: isTestingThis
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_protected_setup),
                  label: Text(
                    isTestingThis
                        ? LocalizationService
                              .instance
                              .current
                              .testingInProgress_4821
                        : LocalizationService
                              .instance
                              .current
                              .testConnection_4821,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showEditConfigDialog(config),
                  icon: const Icon(Icons.edit),
                  label: Text(
                    LocalizationService.instance.current.editLabel_4271,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _toggleConfigEnabled(config),
                  icon: Icon(config.isEnabled ? Icons.pause : Icons.play_arrow),
                  label: Text(
                    config.isEnabled
                        ? LocalizationService.instance.current.disable_4821
                        : LocalizationService.instance.current.enable_7532,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _deleteConfig(config),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建认证账户卡片
  Widget _buildAuthAccountCard(WebDavAuthAccount account) {
    // 查找使用此账户的配置数量
    final configCount = _configs
        .where((config) => config.authAccountId == account.authAccountId)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                const Icon(Icons.account_circle),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    account.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (configCount > 0)
                  Chip(
                    label: Text(
                      '$configCount ${LocalizationService.instance.current.configurationsCount_7421}',
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 账户信息
            _buildInfoRow(
              LocalizationService.instance.current.usernameLabel_5421,
              account.username,
            ),
            _buildInfoRow(
              LocalizationService.instance.current.creationTime_4821,
              _formatDateTime(account.createdAt),
            ),
            const SizedBox(height: 16),
            // 操作按钮
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showEditAuthAccountDialog(account),
                  icon: const Icon(Icons.edit),
                  label: Text(
                    LocalizationService.instance.current.editLabel_4271,
                  ),
                ),
                const Spacer(),
                if (configCount == 0)
                  IconButton(
                    onPressed: () => _deleteAuthAccount(account),
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                  )
                else
                  Tooltip(
                    message: LocalizationService.instance.current
                        .accountInUseMessage_4821(configCount),
                    child: IconButton(
                      onPressed: null,
                      icon: const Icon(Icons.delete),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  /// 构建测试结果信息
  Widget _buildTestResultInfo(WebDavTestResult result) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: result.success
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: result.success ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.error,
                color: result.success ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                result.success
                    ? LocalizationService
                          .instance
                          .current
                          .connectionSuccess_4821
                    : LocalizationService
                          .instance
                          .current
                          .connectionFailed_4821,
                style: TextStyle(
                  color: result.success ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (result.responseTimeMs != null) ...[
                const Spacer(),
                Text(
                  '${result.responseTimeMs}ms',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
          if (result.errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              result.errorMessage!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
          if (result.serverInfo != null) ...[
            const SizedBox(height: 4),
            Text(
              LocalizationService.instance.current.serverInfoLabel_7281(
                result.serverInfo.toString(),
              ),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  /// 测试连接
  Future<void> _testConnection(String configId) async {
    setState(() {
      _testingConfigs[configId] = true;
      _testResults.remove(configId);
    });

    try {
      final result = await _clientService.testConnection(configId);
      setState(() {
        _testResults[configId] = result;
      });
    } catch (e) {
      setState(() {
        _testResults[configId] = WebDavTestResult(
          success: false,
          errorMessage: LocalizationService.instance.current.testFailedMessage(
            e,
          ),
        );
      });
    } finally {
      setState(() {
        _testingConfigs[configId] = false;
      });
    }
  }

  /// 切换配置启用状态
  Future<void> _toggleConfigEnabled(WebDavConfig config) async {
    try {
      await _dbService.toggleConfigEnabled(config.configId);
      await _loadData();
      context.showSuccessSnackBar(
        config.isEnabled
            ? LocalizationService.instance.current.configDisabled_4821
            : LocalizationService.instance.current.configEnabled_4822,
      );
    } catch (e) {
      context.showErrorSnackBar(
        LocalizationService.instance.current.operationFailedWithError(e),
      );
    }
  }

  /// 删除配置
  Future<void> _deleteConfig(WebDavConfig config) async {
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbService.deleteConfig(config.configId);
        await _loadData();
        context.showSuccessSnackBar(
          LocalizationService.instance.current.configurationDeleted_4821,
        );
      } catch (e) {
        context.showErrorSnackBar(
          LocalizationService.instance.current.operationFailedWithError(e),
        );
      }
    }
  }

  /// 删除认证账户
  Future<void> _deleteAuthAccount(WebDavAuthAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.confirmDelete_7281),
        content: Text(
          LocalizationService.instance.current.confirmDeleteAccount_7421(
            account.displayName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocalizationService.instance.current.cancel_4821),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(LocalizationService.instance.current.delete_7281),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbService.deleteAuthAccount(account.authAccountId);
        await _secureStorage.deletePassword(account.authAccountId);
        await _loadData();

        context.showSuccessSnackBar(
          LocalizationService.instance.current.accountDeletedSuccess_4821,
        );
      } catch (e) {
        context.showErrorSnackBar(
          LocalizationService.instance.current.operationFailedWithError(e),
        );
      }
    }
  }

  /// 显示添加配置对话框
  void _showAddConfigDialog() {
    _showConfigDialog();
  }

  /// 显示编辑配置对话框
  void _showEditConfigDialog(WebDavConfig config) {
    _showConfigDialog(config: config);
  }

  /// 显示添加认证账户对话框
  void _showAddAuthAccountDialog() {
    _showAuthAccountDialog();
  }

  /// 显示编辑认证账户对话框
  void _showEditAuthAccountDialog(WebDavAuthAccount account) {
    _showAuthAccountDialog(account: account);
  }

  /// 显示配置对话框
  void _showConfigDialog({WebDavConfig? config}) {
    showDialog(
      context: context,
      builder: (context) => _ConfigDialog(
        config: config,
        authAccounts: _authAccounts,
        onSaved: () {
          _loadData();
        },
      ),
    );
  }

  /// 显示认证账户对话框
  void _showAuthAccountDialog({WebDavAuthAccount? account}) {
    showDialog(
      context: context,
      builder: (context) => _AuthAccountDialog(
        account: account,
        onSaved: () {
          _loadData();
        },
      ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// 配置对话框
class _ConfigDialog extends StatefulWidget {
  final WebDavConfig? config;
  final List<WebDavAuthAccount> authAccounts;
  final VoidCallback onSaved;

  const _ConfigDialog({
    this.config,
    required this.authAccounts,
    required this.onSaved,
  });

  @override
  State<_ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<_ConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _serverUrlController = TextEditingController();
  final _storagePathController = TextEditingController();

  String? _selectedAuthAccountId;
  bool _isEnabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.config != null) {
      _displayNameController.text = widget.config!.displayName;
      _serverUrlController.text = widget.config!.serverUrl;
      _storagePathController.text = widget.config!.storagePath;
      _selectedAuthAccountId = widget.config!.authAccountId;
      _isEnabled = widget.config!.isEnabled;
    } else {
      _storagePathController.text = '/r6box'; // 默认存储路径
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _serverUrlController.dispose();
    _storagePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.config != null;

    return AlertDialog(
      title: Text(
        isEditing
            ? LocalizationService.instance.current.editWebDavConfig
            : LocalizationService.instance.current.addWebDavConfig,
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText:
                      LocalizationService.instance.current.displayName_4821,
                  hintText:
                      LocalizationService.instance.current.exampleMyCloud_4822,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocalizationService
                        .instance
                        .current
                        .inputDisplayName_4821;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serverUrlController,
                decoration: InputDecoration(
                  labelText:
                      LocalizationService.instance.current.serverUrlLabel_4821,
                  hintText:
                      LocalizationService.instance.current.serverUrlHint_4821,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocalizationService
                        .instance
                        .current
                        .serverUrlRequired_4821;
                  }
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !uri.hasAbsolutePath) {
                    return LocalizationService
                        .instance
                        .current
                        .invalidUrlPrompt_7281;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _storagePathController,
                decoration: InputDecoration(
                  labelText: LocalizationService
                      .instance
                      .current
                      .storageFolderLabel_4821,
                  hintText: '/r6box',
                  helperText:
                      LocalizationService.instance.current.folderNameRules_4821,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocalizationService
                        .instance
                        .current
                        .inputFolderPath_4821;
                  }

                  final trimmedValue = value.trim();

                  // 检查长度限制
                  if (trimmedValue.length > 100) {
                    return LocalizationService
                        .instance
                        .current
                        .storagePathLengthExceeded_4821;
                  }

                  // 检查是否包含中文字符
                  if (_containsChinese(trimmedValue)) {
                    return LocalizationService
                        .instance
                        .current
                        .pathNoChineseChars_4821;
                  }

                  // 检查是否包含特殊字符（只允许字母、数字、斜杠、下划线、连字符）
                  if (!_isValidPathCharacters(trimmedValue)) {
                    return LocalizationService
                        .instance
                        .current
                        .invalidPathCharactersError_4821;
                  }

                  // 验证路径格式
                  final normalizedPath = _normalizeStoragePath(trimmedValue);
                  if (normalizedPath.isEmpty) {
                    return LocalizationService
                        .instance
                        .current
                        .invalidPathFormat_4821;
                  }

                  return null;
                },
                onChanged: (value) {
                  // 实时显示标准化后的路径
                  if (value.isNotEmpty) {
                    final normalized = _normalizeStoragePath(value);
                    if (normalized != value && normalized.isNotEmpty) {
                      // 可以在这里添加实时预览逻辑
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAuthAccountId,
                decoration: InputDecoration(
                  labelText: LocalizationService
                      .instance
                      .current
                      .authenticationAccount_7281,
                ),
                items: widget.authAccounts.map((account) {
                  return DropdownMenuItem(
                    value: account.authAccountId,
                    child: Text('${account.displayName} (${account.username})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAuthAccountId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return LocalizationService
                        .instance
                        .current
                        .selectAuthAccount_4821;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  LocalizationService.instance.current.enableConfiguration_4271,
                ),
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(LocalizationService.instance.current.cancel_4821),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveConfig,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  isEditing
                      ? LocalizationService.instance.current.saveButton_5421
                      : LocalizationService.instance.current.addButton_5421,
                ),
        ),
      ],
    );
  }

  /// 检查字符串是否包含中文字符
  bool _containsChinese(String input) {
    final regex = RegExp(r'[\u4e00-\u9fa5]');
    return regex.hasMatch(input);
  }

  /// 检查路径字符是否有效（只允许字母、数字、斜杠、下划线、连字符）
  bool _isValidPathCharacters(String input) {
    final regex = RegExp(r'^[a-zA-Z0-9/_-]+$');
    return regex.hasMatch(input);
  }

  /// 标准化存储路径
  String _normalizeStoragePath(String path) {
    if (path.isEmpty) {
      return '';
    }

    // 去除前后空格
    String normalized = path.trim();

    // 移除多余的斜杠
    normalized = normalized.replaceAll(RegExp(r'/+'), '/');

    // 确保以斜杠开头
    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }

    // 移除末尾的斜杠（除非是根路径）
    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    return normalized;
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final config = WebDavConfig(
        configId: widget.config?.configId ?? const Uuid().v4(),
        displayName: _displayNameController.text.trim(),
        serverUrl: _serverUrlController.text.trim(),
        storagePath: _normalizeStoragePath(_storagePathController.text.trim()),
        authAccountId: _selectedAuthAccountId!,
        isEnabled: _isEnabled,
        createdAt: widget.config?.createdAt ?? now,
        updatedAt: now,
      );

      final dbService = WebDavDatabaseService();
      if (widget.config != null) {
        await dbService.updateConfig(config);
      } else {
        await dbService.createConfig(config);
      }

      widget.onSaved();
      Navigator.of(context).pop();
      context.showSuccessSnackBar(
        widget.config != null
            ? LocalizationService.instance.current.configUpdated_42
            : LocalizationService.instance.current.configAdded_17,
      );
    } catch (e) {
      context.showErrorSnackBar(
        LocalizationService.instance.current.operationFailedWithError(e),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

/// 认证账户对话框
class _AuthAccountDialog extends StatefulWidget {
  final WebDavAuthAccount? account;
  final VoidCallback onSaved;

  const _AuthAccountDialog({this.account, required this.onSaved});

  @override
  State<_AuthAccountDialog> createState() => _AuthAccountDialogState();
}

class _AuthAccountDialogState extends State<_AuthAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    if (widget.account != null) {
      _displayNameController.text = widget.account!.displayName;
      _usernameController.text = widget.account!.username;
      // 密码不预填充，用户需要重新输入
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;

    return AlertDialog(
      title: Text(
        isEditing
            ? LocalizationService.instance.current.editAuthAccount_5421
            : LocalizationService.instance.current.addAuthAccount_8753,
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: LocalizationService
                      .instance
                      .current
                      .displayNameLabel_4821,
                  hintText:
                      LocalizationService.instance.current.accountNameHint_7532,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocalizationService
                        .instance
                        .current
                        .inputDisplayName_4821;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText:
                      LocalizationService.instance.current.usernameLabel_4521,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocalizationService
                        .instance
                        .current
                        .usernameRequired_4821;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: isEditing
                      ? LocalizationService
                            .instance
                            .current
                            .passwordKeepEmpty_1234
                      : LocalizationService.instance.current.password_5678,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (!isEditing && (value == null || value.trim().isEmpty)) {
                    return LocalizationService
                        .instance
                        .current
                        .enterPassword_4821;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(LocalizationService.instance.current.cancel_4821),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveAccount,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  isEditing
                      ? LocalizationService.instance.current.saveButton_5421
                      : LocalizationService.instance.current.addButton_5421,
                ),
        ),
      ],
    );
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final account = WebDavAuthAccount(
        authAccountId: widget.account?.authAccountId ?? const Uuid().v4(),
        displayName: _displayNameController.text.trim(),
        username: _usernameController.text.trim(),
        createdAt: widget.account?.createdAt ?? now,
        updatedAt: now,
      );

      final dbService = WebDavDatabaseService();
      final secureStorage = WebDavSecureStorageService();

      if (widget.account != null) {
        await dbService.updateAuthAccount(account);
        // 只有在用户输入了新密码时才更新密码
        if (_passwordController.text.trim().isNotEmpty) {
          await secureStorage.updatePassword(
            account.authAccountId,
            _passwordController.text.trim(),
          );
        }
      } else {
        await dbService.createAuthAccount(account);
        await secureStorage.storePassword(
          account.authAccountId,
          _passwordController.text.trim(),
        );
      }

      widget.onSaved();
      Navigator.of(context).pop();

      context.showSuccessSnackBar(
        widget.account != null
            ? LocalizationService.instance.current.accountUpdated_5421
            : LocalizationService.instance.current.accountAdded_5421,
      );
    } catch (e) {
      context.showErrorSnackBar(
        LocalizationService.instance.current.operationFailedWithError(e),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
