// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../services/notification/notification_service.dart';
import '../../../services/user_preferences/user_preferences_config_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/localization_service.dart';

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
              LocalizationService.instance.current.userManagement_4521,
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
                          LocalizationService.instance.current
                              .creationTimeText_7421(
                                _formatDate(widget.preferences.createdAt),
                              ),
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
                            LocalizationService.instance.current.lastLoginTime(
                              _formatDate(widget.preferences.lastLoginAt!),
                            ),
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
              LocalizationService.instance.current.configurationManagement_7421,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // 保存当前配置
            ListTile(
              leading: Icon(Icons.save, color: Colors.green),
              title: Text(
                LocalizationService.instance.current.saveCurrentConfig_4271,
              ),
              subtitle: Text(
                LocalizationService.instance.current.saveAsNewConfig_7281,
              ),
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
                    Text(
                      LocalizationService.instance.current
                          .loadConfigFailed_4821(_configError!),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadConfigs,
                      child: Text(
                        LocalizationService.instance.current.retryButton_7281,
                      ),
                    ),
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
                    Text(
                      LocalizationService.instance.current.noSavedConfigs_7281,
                      style: TextStyle(color: Colors.grey),
                    ),
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
                          LocalizationService.instance.current
                              .savedConfigsCount(_configs.length),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _loadConfigs,
                          child: Text(
                            LocalizationService
                                .instance
                                .current
                                .refreshButton_7421,
                          ),
                        ),
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
              title: Text(
                LocalizationService.instance.current.importConfig_7421,
              ),
              subtitle: Text(
                LocalizationService.instance.current.importConfigFromJson_4821,
              ),
              onTap: () => _showImportConfigDialog(context, provider),
            ),

            const SizedBox(height: 16),

            // 账户设置
            Text(
              LocalizationService.instance.current.accountSettings_7421,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // 更改显示名称
            ListTile(
              leading: Icon(Icons.badge),
              title: Text(
                LocalizationService.instance.current.displayName_1234,
              ),
              subtitle: Text(widget.preferences.displayName),
              trailing: Icon(Icons.edit),
              onTap: () => _changeDisplayName(context, provider),
            ), // 更改头像
            ListTile(
              leading: Icon(Icons.photo),
              title: Text(
                LocalizationService.instance.current.avatarTitle_4821,
              ),
              subtitle: Text(_getAvatarDisplayText()),
              trailing: Icon(Icons.edit),
              onTap: () => _changeAvatar(context, provider),
            ),

            // 语言设置
            ListTile(
              leading: Icon(Icons.language),
              title: Text(LocalizationService.instance.current.language_4821),
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
        return LocalizationService.instance.current.simplifiedChinese_4821;
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
      return LocalizationService.instance.current.localImageSize_7421(
        (widget.preferences.avatarData!.length / 1024).toStringAsFixed(1),
      );
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
        title: Text(LocalizationService.instance.current.changeAvatar_7421),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.link),
              title: Text(
                LocalizationService.instance.current.useNetworkImageUrl_4821,
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showUrlInputDialog(context, provider);
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text(
                LocalizationService.instance.current.uploadLocalImage_4271,
              ),
              onTap: () {
                Navigator.of(context).pop();
                _uploadLocalImage(context, provider);
              },
            ),
            if (widget.preferences.avatarPath != null ||
                widget.preferences.avatarData != null)
              ListTile(
                leading: Icon(Icons.clear, color: Colors.red),
                title: Text(
                  LocalizationService.instance.current.removeAvatar_4271,
                ),
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
          context.showErrorSnackBar(
            LocalizationService.instance.current.imageTooLargeError_4821,
          );
          return;
        }

        await provider.updateUserInfo(
          avatarData: imageData,
          avatarPath: null, // 清除URL路径
        );

        context.showSuccessSnackBar(
          LocalizationService.instance.current.avatarUploaded_7421,
        );
      }
    } catch (e) {
      context.showErrorSnackBar(
        LocalizationService.instance.current.uploadFailedWithError(
          e.toString(),
        ),
      );
    }
  }

  void _removeAvatar(
    BuildContext context,
    UserPreferencesProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.removeAvatar_4271),
        content: Text(
          LocalizationService.instance.current.confirmRemoveAvatar_7421,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocalizationService.instance.current.cancel_4821),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(LocalizationService.instance.current.remove_4821),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.updateUserInfo(avatarPath: null, avatarData: null);
        context.showSuccessSnackBar(
          LocalizationService.instance.current.avatarRemoved_4281,
        );
      } catch (e) {
        context.showErrorSnackBar(
          LocalizationService.instance.current.removeFailedMessage_7421(
            e.toString(),
          ),
        );
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
        title: Text(
          LocalizationService.instance.current.saveCurrentConfig_4271,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText:
                    LocalizationService.instance.current.configurationName_4821,
                hintText: LocalizationService
                    .instance
                    .current
                    .enterConfigurationName_5732,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: LocalizationService
                    .instance
                    .current
                    .configurationDescription_4521,
                hintText: LocalizationService
                    .instance
                    .current
                    .enterConfigurationDescriptionHint_4522,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocalizationService.instance.current.cancelButton_7421),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                context.showErrorSnackBar(
                  LocalizationService.instance.current.inputConfigName_4821,
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: Text(LocalizationService.instance.current.saveButton_7421),
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
          context.showSuccessSnackBar(
            LocalizationService
                .instance
                .current
                .configurationSavedSuccessfully_4821,
          );
          _loadConfigs();
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(
            LocalizationService.instance.current.saveConfigFailed(e.toString()),
          );
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
            LocalizationService.instance.current.creationTime_7281(
              _formatDateTime(config.createdAt),
            ),
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
          PopupMenuItem(
            value: 'load',
            child: Row(
              children: [
                Icon(Icons.download),
                SizedBox(width: 8),
                Text(
                  LocalizationService
                      .instance
                      .current
                      .loadingConfiguration_7281,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'export',
            child: Row(
              children: [
                Icon(Icons.share),
                SizedBox(width: 8),
                Text(LocalizationService.instance.current.exportConfig_7281),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  LocalizationService.instance.current.deleteConfiguration_7281,
                  style: TextStyle(color: Colors.red),
                ),
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
        title: Text(
          LocalizationService.instance.current.loadingConfiguration_7421,
        ),
        content: Text(
          LocalizationService.instance.current.confirmLoadConfig_7421(
            config.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocalizationService.instance.current.cancel_4821),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              LocalizationService.instance.current.confirmButton_7281,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final success = await provider.loadAndApplyConfig(config.id);

        if (success && mounted) {
          context.showSuccessSnackBar(
            LocalizationService
                .instance
                .current
                .configurationLoadedSuccessfully_4821,
          );
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(
            LocalizationService.instance.current.loadConfigFailed(e.toString()),
          );
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
        title: Text(
          LocalizationService.instance.current.deleteConfiguration_4271,
        ),
        content: Text(
          LocalizationService.instance.current.confirmDeleteConfig(config.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocalizationService.instance.current.cancel_4821),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(LocalizationService.instance.current.delete_4821),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final success = await provider.deleteConfig(config.id);

        if (success && mounted) {
          context.showSuccessSnackBar(
            LocalizationService
                .instance
                .current
                .configurationDeletedSuccessfully_7281,
          );
          _loadConfigs();
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(
            LocalizationService.instance.current.deleteConfigFailed_7281(
              e.toString(),
            ),
          );
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
        context.showSuccessSnackBar(
          LocalizationService
              .instance
              .current
              .configurationCopiedToClipboard_4821,
        );
      }
    } catch (e) {
      context.showErrorSnackBar(
        LocalizationService.instance.current.exportConfigFailed_7421(
          e.toString(),
        ),
      );
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
        title: Text(LocalizationService.instance.current.importConfig_4271),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(LocalizationService.instance.current.pasteJsonConfig_7281),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText:
                    LocalizationService.instance.current.jsonDataLabel_4521,
                hintText:
                    LocalizationService.instance.current.jsonDataHint_4522,
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
            child: Text(LocalizationService.instance.current.cancelButton_7281),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                context.showErrorSnackBar(
                  LocalizationService.instance.current.inputJsonData_4821,
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: Text(LocalizationService.instance.current.import_4521),
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
          context.showSuccessSnackBar(
            LocalizationService
                .instance
                .current
                .configurationImportSuccess_7281,
          );
          _loadConfigs();
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(
            LocalizationService.instance.current.importConfigFailed_7421(
              e.toString(),
            ),
          );
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
      {
        'code': 'zh_CN',
        'name': LocalizationService.instance.current.simplifiedChinese_7281,
      },
      {'code': 'en_US', 'name': 'English'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.current.selectLanguage_4821),
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
                    context.showSuccessSnackBar(
                      LocalizationService.instance.current.languageUpdated(
                        language['name']!,
                      ),
                    );
                  } catch (e) {
                    context.showErrorSnackBar(
                      LocalizationService.instance.current
                          .updateFailedWithError(e.toString()),
                    );
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
            child: Text(LocalizationService.instance.current.cancel_4821),
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
      title: Text(LocalizationService.instance.current.editUserInfo_4821),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: LocalizationService.instance.current.displayName_4521,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _avatarController,
            decoration: InputDecoration(
              labelText:
                  LocalizationService.instance.current.avatarUrlOptional_4821,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocalizationService.instance.current.cancel_4821),
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
            context.showSuccessSnackBar(
              LocalizationService.instance.current.userInfoUpdated_7421,
            );
          },
          child: Text(LocalizationService.instance.current.saveButton_7421),
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
      title: Text(LocalizationService.instance.current.createNewProfile_4271),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: LocalizationService.instance.current.profileNameLabel_4821,
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocalizationService.instance.current.cancel_4821),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              // 实现创建新配置文件的逻辑
              Navigator.of(context).pop();
              context.showSuccessSnackBar(
                LocalizationService.instance.current.configFileCreated(name),
              );
            }
          },
          child: Text(LocalizationService.instance.current.createButton_7421),
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
      return LocalizationService.instance.current.displayNameCannotBeEmpty_4821;
    }
    if (name.trim().length < 2) {
      return LocalizationService.instance.current.displayNameMinLength_4821;
    }
    if (name.trim().length > 50) {
      return LocalizationService.instance.current.displayNameTooLong_42;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocalizationService.instance.current.changeDisplayName_4821),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: LocalizationService.instance.current.displayNameLabel_4821,
          border: OutlineInputBorder(),
          hintText: LocalizationService.instance.current.displayNameHint_7532,
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
          child: Text(LocalizationService.instance.current.cancel_4821),
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
                      context.showSuccessSnackBar(
                        LocalizationService.instance.current.nameUpdatedTo_7421(
                          newName,
                        ),
                      );
                    } catch (e) {
                      context.showErrorSnackBar(
                        LocalizationService.instance.current
                            .updateFailedWithError(e.toString()),
                      );
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                }
              : null,
          child: Text(LocalizationService.instance.current.saveButton_7281),
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
      return LocalizationService.instance.current.enterValidUrl_4821;
    }

    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final hasValidExtension = validExtensions.any(
      (ext) => url.toLowerCase().contains(ext),
    );

    if (!hasValidExtension) {
      return LocalizationService.instance.current.invalidImageUrlError_4821;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocalizationService.instance.current.inputAvatarUrl_7281),
      content: TextField(
        controller: _urlController,
        decoration: InputDecoration(
          labelText: LocalizationService.instance.current.imageUrlLabel_4821,
          border: OutlineInputBorder(),
          hintText: 'https://example.com/avatar.jpg',
          errorText: _errorText,
          helperText:
              LocalizationService.instance.current.supportedImageFormats_5732,
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
