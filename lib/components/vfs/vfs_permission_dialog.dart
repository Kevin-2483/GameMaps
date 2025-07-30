// This file has been processed by AI for internationalization
import '../../services/localization_service.dart';
import 'package:flutter/material.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';
import '../../services/virtual_file_system/vfs_permission_system.dart';
import '../../services/virtual_file_system/vfs_service_provider.dart';
import '../../services/notification/notification_service.dart';

/// VFS权限管理对话框
class VfsPermissionDialog extends StatefulWidget {
  final VfsFileInfo fileInfo;
  final VfsPermissionMask currentPermissions;

  const VfsPermissionDialog({
    super.key,
    required this.fileInfo,
    required this.currentPermissions,
  });

  @override
  State<VfsPermissionDialog> createState() => _VfsPermissionDialogState();

  /// 显示权限管理对话框
  static Future<VfsPermissionMask?> show(
    BuildContext context,
    VfsFileInfo fileInfo,
  ) async {
    final vfsService = VfsServiceProvider();

    try {
      // 解析文件路径获取collection和filePath
      final vfsPath = VfsProtocol.parsePath(fileInfo.path);
      if (vfsPath == null) {
        throw Exception('Invalid file path');
      }

      final permissions = await vfsService.getFilePermissions(
        vfsPath.collection,
        vfsPath.path,
      );

      return showDialog<VfsPermissionMask>(
        context: context,
        builder: (context) => VfsPermissionDialog(
          fileInfo: fileInfo,
          currentPermissions: permissions,
        ),
      );
    } catch (e) {
      context.showErrorSnackBar(
        LocalizationService.instance.current.filePermissionFailed_7285(e),
      );
      return null;
    }
  }
}

class _VfsPermissionDialogState extends State<VfsPermissionDialog> {
  late VfsPermissionMask _permissions;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _permissions = widget.currentPermissions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  widget.fileInfo.isDirectory
                      ? Icons.folder
                      : Icons.description,
                  color: widget.fileInfo.isDirectory ? Colors.amber : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fileInfo.name,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        LocalizationService
                            .instance
                            .current
                            .permissionManagement_7421,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 系统保护状态
            if (_permissions.isSystemProtected) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        LocalizationService
                            .instance
                            .current
                            .systemProtectedFileWarning_4821,
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 当前权限显示
            Text(
              LocalizationService.instance.current.currentPermissions_7421(
                _permissions.toString(),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'monospace',
                backgroundColor: colorScheme.surfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // 权限设置
            if (!_permissions.isSystemProtected) ...[
              Text(
                LocalizationService.instance.current.permissionSettings_7281,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              _buildPermissionSection(
                LocalizationService.instance.current.userPermissionsTitle_7281,
                _permissions.userPermissions,
                (value) {
                  setState(() {
                    _permissions = _permissions.copyWith(
                      userPermissions: value,
                    );
                  });
                },
              ),

              _buildPermissionSection(
                LocalizationService.instance.current.groupPermissions_7421,
                _permissions.groupPermissions,
                (value) {
                  setState(() {
                    _permissions = _permissions.copyWith(
                      groupPermissions: value,
                    );
                  });
                },
              ),

              _buildPermissionSection(
                LocalizationService.instance.current.otherPermissions_7281,
                _permissions.otherPermissions,
                (value) {
                  setState(() {
                    _permissions = _permissions.copyWith(
                      otherPermissions: value,
                    );
                  });
                },
              ),
            ] else ...[
              Text(
                LocalizationService.instance.current.permissionDetails_7281,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              _buildPermissionDisplay(
                LocalizationService.instance.current.userPermissions_7281,
                _permissions.userPermissions,
              ),
              _buildPermissionDisplay(
                LocalizationService.instance.current.groupPermissions_4821,
                _permissions.groupPermissions,
              ),
              _buildPermissionDisplay(
                LocalizationService.instance.current.otherPermissions_7281,
                _permissions.otherPermissions,
              ),
            ],

            const SizedBox(height: 24),

            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    LocalizationService.instance.current.cancelButton_4271,
                  ),
                ),
                const SizedBox(width: 8),
                if (!_permissions.isSystemProtected)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _savePermissions,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            LocalizationService
                                .instance
                                .current
                                .saveButton_7284,
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection(
    String title,
    int permissions,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPermissionCheckbox(
              LocalizationService.instance.current.readPermission_4821,
              permissions & VfsPermission.read != 0,
              (value) => onChanged(
                value
                    ? permissions | VfsPermission.read
                    : permissions & ~VfsPermission.read,
              ),
            ),
            const SizedBox(width: 16),
            _buildPermissionCheckbox(
              LocalizationService.instance.current.writePermission_4821,
              permissions & VfsPermission.write != 0,
              (value) => onChanged(
                value
                    ? permissions | VfsPermission.write
                    : permissions & ~VfsPermission.write,
              ),
            ),
            const SizedBox(width: 16),
            _buildPermissionCheckbox(
              LocalizationService.instance.current.executePermission_4821,
              permissions & VfsPermission.execute != 0,
              (value) => onChanged(
                value
                    ? permissions | VfsPermission.execute
                    : permissions & ~VfsPermission.execute,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPermissionDisplay(String title, int permissions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPermissionIndicator(
              LocalizationService.instance.current.readPermission_5421,
              permissions & VfsPermission.read != 0,
            ),
            const SizedBox(width: 16),
            _buildPermissionIndicator(
              LocalizationService.instance.current.writePermission_7421,
              permissions & VfsPermission.write != 0,
            ),
            const SizedBox(width: 16),
            _buildPermissionIndicator(
              LocalizationService.instance.current.executeAction_7421,
              permissions & VfsPermission.execute != 0,
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPermissionCheckbox(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (newValue) => onChanged(newValue ?? false),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildPermissionIndicator(String label, bool hasPermission) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasPermission ? Icons.check : Icons.close,
          size: 16,
          color: hasPermission ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Future<void> _savePermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vfsService = VfsServiceProvider();
      final vfsPath = VfsProtocol.parsePath(widget.fileInfo.path);

      if (vfsPath != null) {
        await vfsService.setFilePermissions(
          vfsPath.collection,
          vfsPath.path,
          _permissions,
        );

        if (mounted) {
          Navigator.of(context).pop(_permissions);
          context.showSuccessSnackBar(
            LocalizationService.instance.current.permissionSaved_7421,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          LocalizationService.instance.current.savePermissionFailed(e),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
