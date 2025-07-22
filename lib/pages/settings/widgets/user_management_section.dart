import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../services/notification/notification_service.dart';
import '../../../services/user_preferences/user_preferences_config_service.dart';

class UserManagementSection extends StatefulWidget {
  final UserPreferences preferences;

  const UserManagementSection({super.key, required this.preferences});

  @override
  State<UserManagementSection> createState() => _UserManagementSectionState();
}

class _UserManagementSectionState extends State<UserManagementSection> {
  List<ConfigInfo> _configs = [];
  bool _isLoadingConfigs = false;
  String? _configError;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    if (!mounted) return;

    setState(() {
      _isLoadingConfigs = true;
      _configError = null;
    });

    try {
      final provider = context.read<UserPreferencesProvider>();
      final configs = await provider.getAllConfigs();
      if (mounted) {
        setState(() {
          _configs = configs;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _configError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingConfigs = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserPreferencesProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户管理',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 当前用户信息
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: _getAvatarImage(),
                    child: _getAvatarImage() == null
                        ? Text(
                            widget.preferences.displayName.isNotEmpty
                                ? widget.preferences.displayName[0]
                                      .toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.preferences.displayName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (widget.preferences.userId != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${widget.preferences.userId}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '创建时间: ${_formatDate(widget.preferences.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (widget.preferences.lastLoginAt != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '最后登录: ${_formatDate(widget.preferences.lastLoginAt!)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 配置管理
            Text(
              '配置管理',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // 保存当前配置
            ListTile(
              leading: Icon(Icons.save, color: Colors.green),
              title: Text('保存当前配置'),
              subtitle: Text('将当前设置保存为新配置'),
              onTap: () => _showSaveConfigDialog(context, provider),
            ),

            // 配置列表
            if (_isLoadingConfigs)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_configError != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('加载配置失败: $_configError'),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _loadConfigs, child: Text('重试')),
                  ],
                ),
              )
            else if (_configs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.inbox, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('暂无保存的配置', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          '已保存的配置 (${_configs.length})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        TextButton(onPressed: _loadConfigs, child: Text('刷新')),
                      ],
                    ),
                  ),
                  ..._configs.map(
                    (config) => _buildConfigTile(context, provider, config),
                  ),
                ],
              ),

            // 导入配置
            ListTile(
              leading: Icon(Icons.upload, color: Colors.blue),
              title: Text('导入配置'),
              subtitle: Text('从JSON数据导入配置'),
              onTap: () => _showImportConfigDialog(context, provider),
            ),

            const SizedBox(height: 16),

            // 账户设置
            Text(
              '账户设置',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // 更改显示名称
            ListTile(
              leading: Icon(Icons.badge),
              title: Text('显示名称'),
              subtitle: Text(widget.preferences.displayName),
              trailing: Icon(Icons.edit),
              onTap: () => _changeDisplayName(context, provider),
            ), // 更改头像
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('头像'),
              subtitle: Text(_getAvatarDisplayText()),
              trailing: Icon(Icons.edit),
              onTap: () => _changeAvatar(context, provider),
            ),

            // 语言设置
            ListTile(
              leading: Icon(Icons.language),
              title: Text('语言'),
              subtitle: Text(
                _getLanguageDisplayName(widget.preferences.locale),
              ),
              trailing: Icon(Icons.edit),
              onTap: () => _changeLanguage(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getLanguageDisplayName(String locale) {
    switch (locale) {
      case 'zh_CN':
        return '简体中文';
      case 'en_US':
        return 'English';
      default:
        return locale;
    }
  }

  /// 获取头像图片提供者
  ImageProvider? _getAvatarImage() {
    if (widget.preferences.avatarData != null &&
        widget.preferences.avatarData!.isNotEmpty) {
      return MemoryImage(widget.preferences.avatarData!);
    } else if (widget.preferences.avatarPath != null &&
        widget.preferences.avatarPath!.isNotEmpty) {
      return NetworkImage(widget.preferences.avatarPath!);
    }
    return null;
  }

  /// 获取头像显示文本
  String _getAvatarDisplayText() {
    if (widget.preferences.avatarData != null &&
        widget.preferences.avatarData!.isNotEmpty) {
      return '本地图片 (${(widget.preferences.avatarData!.length / 1024).toStringAsFixed(1)} KB)';
    } else if (widget.preferences.avatarPath != null &&
        widget.preferences.avatarPath!.isNotEmpty) {
      return widget.preferences.avatarPath!;
    }
    return '未设置';
  }

  void _changeDisplayName(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => _DisplayNameDialog(
        currentName: widget.preferences.displayName,
        provider: provider,
      ),
    );
  }

  void _changeAvatar(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('更改头像'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.link),
              title: Text('使用网络图片URL'),
              onTap: () {
                Navigator.of(context).pop();
                _showUrlInputDialog(context, provider);
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('上传本地图片'),
              onTap: () {
                Navigator.of(context).pop();
                _uploadLocalImage(context, provider);
              },
            ),
            if (widget.preferences.avatarPath != null ||
                widget.preferences.avatarData != null)
              ListTile(
                leading: Icon(Icons.clear, color: Colors.red),
                title: Text('移除头像'),
                onTap: () {
                  Navigator.of(context).pop();
                  _removeAvatar(context, provider);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showUrlInputDialog(
    BuildContext context,
    UserPreferencesProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => _AvatarUrlDialog(
        currentUrl: widget.preferences.avatarPath ?? '',
        provider: provider,
      ),
    );
  }

  void _uploadLocalImage(
    BuildContext context,
    UserPreferencesProvider provider,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final imageData = result.files.single.bytes!;

        // 检查文件大小（限制为5MB）
        if (imageData.length > 5 * 1024 * 1024) {
          context.showErrorSnackBar('图片文件过大，请选择小于5MB的图片');
          return;
        }

        await provider.updateUserInfo(
          avatarData: imageData,
          avatarPath: null, // 清除URL路径
        );

        context.showSuccessSnackBar('头像已上传');
      }
    } catch (e) {
      context.showErrorSnackBar('上传失败: ${e.toString()}');
    }
  }

  void _removeAvatar(
    BuildContext context,
    UserPreferencesProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('移除头像'),
        content: Text('确定要移除当前头像吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('移除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.updateUserInfo(avatarPath: null, avatarData: null);
        context.showSuccessSnackBar('头像已移除');
      } catch (e) {
        context.showErrorSnackBar('移除失败: ${e.toString()}');
      }
    }
  }

  // 配置管理相关方法
  Future<void> _showSaveConfigDialog(
    BuildContext context,
    UserPreferencesProvider provider,
  ) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存当前配置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '配置名称',
                hintText: '请输入配置名称',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '配置描述',
                hintText: '请输入配置描述（可选）',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                context.showErrorSnackBar('请输入配置名称');
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final configId = await provider.saveCurrentAsConfig(
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
        );

        if (configId != null && mounted) {
          context.showSuccessSnackBar('配置保存成功');
          _loadConfigs();
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar('保存配置失败: ${e.toString()}');
        }
      }
    }
  }

  Widget _buildConfigTile(
    BuildContext context,
    UserPreferencesProvider provider,
    ConfigInfo config,
  ) {
    return ListTile(
      leading: Icon(Icons.settings_backup_restore),
      title: Text(config.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.description.isNotEmpty) Text(config.description),
          Text(
            '创建时间: ${_formatDateTime(config.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'load':
              _loadConfig(context, provider, config);
              break;
            case 'export':
              _exportConfig(context, provider, config);
              break;
            case 'delete':
              _deleteConfig(context, provider, config);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'load',
            child: Row(
              children: [
                Icon(Icons.download),
                SizedBox(width: 8),
                Text('加载配置'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'export',
            child: Row(
              children: [Icon(Icons.share), SizedBox(width: 8), Text('导出配置')],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('删除配置', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadConfig(
    BuildContext context,
    UserPreferencesProvider provider,
    ConfigInfo config,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('加载配置'),
        content: Text('确定要加载配置 "${config.name}" 吗？\n\n这将覆盖当前的所有设置（用户信息除外）。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final success = await provider.loadAndApplyConfig(config.id);

        if (success && mounted) {
          context.showSuccessSnackBar('配置加载成功');
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar('加载配置失败: ${e.toString()}');
        }
      }
    }
  }

  Future<void> _deleteConfig(
    BuildContext context,
    UserPreferencesProvider provider,
    ConfigInfo config,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除配置'),
        content: Text('确定要删除配置 "${config.name}" 吗？\n\n此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final success = await provider.deleteConfig(config.id);

        if (success && mounted) {
          context.showSuccessSnackBar('配置删除成功');
          _loadConfigs();
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar('删除配置失败: ${e.toString()}');
        }
      }
    }
  }

  Future<void> _exportConfig(
    BuildContext context,
    UserPreferencesProvider provider,
    ConfigInfo config,
  ) async {
    try {
      final jsonData = await provider.exportConfigAsJson(config.id);

      if (jsonData != null) {
        await Clipboard.setData(ClipboardData(text: jsonData));
        context.showSuccessSnackBar('配置已复制到剪贴板');
      }
    } catch (e) {
      context.showErrorSnackBar('导出配置失败: ${e.toString()}');
    }
  }

  Future<void> _showImportConfigDialog(
    BuildContext context,
    UserPreferencesProvider provider,
  ) async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入配置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请粘贴配置JSON数据：'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'JSON数据',
                hintText: '粘贴配置JSON数据...',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
              minLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                context.showErrorSnackBar('请输入JSON数据');
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final configId = await provider.importConfigFromJson(
          controller.text.trim(),
        );

        if (configId != null && mounted) {
          context.showSuccessSnackBar('配置导入成功');
          _loadConfigs();
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar('导入配置失败: ${e.toString()}');
        }
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _changeLanguage(BuildContext context, UserPreferencesProvider provider) {
    final List<Map<String, String>> languages = [
      {'code': 'zh_CN', 'name': '简体中文'},
      {'code': 'en_US', 'name': 'English'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language['name']!),
              value: language['code']!,
              groupValue: widget.preferences.locale,
              onChanged: (value) async {
                if (value != null && value != widget.preferences.locale) {
                  try {
                    await provider.updateUserInfo(locale: value);
                    Navigator.of(context).pop();
                    context.showSuccessSnackBar('语言已更新为 ${language['name']}');
                  } catch (e) {
                    context.showErrorSnackBar('更新失败: ${e.toString()}');
                  }
                } else {
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
        ],
      ),
    );
  }
}

// 用户信息编辑对话框
class _UserInfoEditDialog extends StatefulWidget {
  final UserPreferences preferences;
  final UserPreferencesProvider provider;

  const _UserInfoEditDialog({
    required this.preferences,
    required this.provider,
  });

  @override
  State<_UserInfoEditDialog> createState() => _UserInfoEditDialogState();
}

class _UserInfoEditDialogState extends State<_UserInfoEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.preferences.displayName,
    );
    _avatarController = TextEditingController(
      text: widget.preferences.avatarPath ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('编辑用户信息'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '显示名称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _avatarController,
            decoration: InputDecoration(
              labelText: '头像URL（可选）',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.provider.updateUserInfo(
              displayName: _nameController.text.trim(),
              avatarPath: _avatarController.text.trim().isEmpty
                  ? null
                  : _avatarController.text.trim(),
            );
            Navigator.of(context).pop();
            context.showSuccessSnackBar('用户信息已更新');
          },
          child: Text('保存'),
        ),
      ],
    );
  }
}

// 创建配置文件对话框
class _CreateProfileDialog extends StatefulWidget {
  final UserPreferencesProvider provider;

  const _CreateProfileDialog({required this.provider});

  @override
  State<_CreateProfileDialog> createState() => _CreateProfileDialogState();
}

class _CreateProfileDialogState extends State<_CreateProfileDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('创建新配置文件'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: '配置文件名称',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              // 实现创建新配置文件的逻辑
              Navigator.of(context).pop();
              context.showSuccessSnackBar('配置文件"$name"已创建');
            }
          },
          child: Text('创建'),
        ),
      ],
    );
  }
}

// 显示名称编辑对话框
class _DisplayNameDialog extends StatefulWidget {
  final String currentName;
  final UserPreferencesProvider provider;

  const _DisplayNameDialog({required this.currentName, required this.provider});

  @override
  State<_DisplayNameDialog> createState() => _DisplayNameDialogState();
}

class _DisplayNameDialogState extends State<_DisplayNameDialog> {
  late TextEditingController _nameController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String name) {
    if (name.trim().isEmpty) {
      return '显示名称不能为空';
    }
    if (name.trim().length < 2) {
      return '显示名称至少需要2个字符';
    }
    if (name.trim().length > 50) {
      return '显示名称不能超过50个字符';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('修改显示名称'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: '显示名称',
          border: OutlineInputBorder(),
          hintText: '请输入您的显示名称',
          errorText: _errorText,
        ),
        autofocus: true,
        onChanged: (value) {
          setState(() {
            _errorText = _validateName(value);
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: _errorText == null
              ? () async {
                  final newName = _nameController.text.trim();
                  if (newName != widget.currentName) {
                    try {
                      await widget.provider.updateUserInfo(
                        displayName: newName,
                      );
                      Navigator.of(context).pop();
                      context.showSuccessSnackBar('显示名称已更新为 "$newName"');
                    } catch (e) {
                      context.showErrorSnackBar('更新失败: ${e.toString()}');
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                }
              : null,
          child: Text('保存'),
        ),
      ],
    );
  }
}

// 头像URL编辑对话框
class _AvatarUrlDialog extends StatefulWidget {
  final String currentUrl;
  final UserPreferencesProvider provider;

  const _AvatarUrlDialog({required this.currentUrl, required this.provider});

  @override
  State<_AvatarUrlDialog> createState() => _AvatarUrlDialogState();
}

class _AvatarUrlDialogState extends State<_AvatarUrlDialog> {
  late TextEditingController _urlController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.currentUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String? _validateUrl(String url) {
    if (url.trim().isEmpty) {
      return null; // 允许空URL
    }

    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return '请输入有效的URL';
    }

    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final hasValidExtension = validExtensions.any(
      (ext) => url.toLowerCase().contains(ext),
    );

    if (!hasValidExtension) {
      return '请输入图片URL（支持 jpg, png, gif 等格式）';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('输入头像URL'),
      content: TextField(
        controller: _urlController,
        decoration: InputDecoration(
          labelText: '图片URL',
          border: OutlineInputBorder(),
          hintText: 'https://example.com/avatar.jpg',
          errorText: _errorText,
          helperText: '支持 jpg, png, gif 等格式的图片',
        ),
        autofocus: true,
        onChanged: (value) {
          setState(() {
            _errorText = _validateUrl(value);
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: _errorText == null
              ? () async {
                  final url = _urlController.text.trim();
                  try {
                    await widget.provider.updateUserInfo(
                      avatarPath: url.isEmpty ? null : url,
                      avatarData: null, // 清除二进制数据
                    );
                    Navigator.of(context).pop();
                    context.showSuccessSnackBar(
                      url.isEmpty ? '头像URL已清除' : '头像已更新',
                    );
                  } catch (e) {
                    context.showErrorSnackBar('更新失败: ${e.toString()}');
                  }
                }
              : null,
          child: Text('保存'),
        ),
      ],
    );
  }
}
