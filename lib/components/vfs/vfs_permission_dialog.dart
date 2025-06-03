import 'package:flutter/material.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';
import '../../services/virtual_file_system/vfs_permission_system.dart';
import '../../services/virtual_file_system/vfs_service_provider.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load permissions: $e'),
          backgroundColor: Colors.red,
        ),
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
                  widget.fileInfo.isDirectory ? Icons.folder : Icons.description,
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
                        '权限管理',
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
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '系统保护文件 - 此文件受系统保护，不可删除或修改权限',
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
              '当前权限: ${_permissions.toString()}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'monospace',
                backgroundColor: colorScheme.surfaceVariant,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 权限设置
            if (!_permissions.isSystemProtected) ...[
              Text(
                '权限设置',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              
              _buildPermissionSection('用户权限', _permissions.userPermissions, (value) {
                setState(() {
                  _permissions = _permissions.copyWith(userPermissions: value);
                });
              }),
              
              _buildPermissionSection('组权限', _permissions.groupPermissions, (value) {
                setState(() {
                  _permissions = _permissions.copyWith(groupPermissions: value);
                });
              }),
              
              _buildPermissionSection('其他权限', _permissions.otherPermissions, (value) {
                setState(() {
                  _permissions = _permissions.copyWith(otherPermissions: value);
                });
              }),
            ] else ...[
              Text(
                '权限详情',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              
              _buildPermissionDisplay('用户权限', _permissions.userPermissions),
              _buildPermissionDisplay('组权限', _permissions.groupPermissions),
              _buildPermissionDisplay('其他权限', _permissions.otherPermissions),
            ],
            
            const SizedBox(height: 24),
            
            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
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
                        : const Text('保存'),
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
              '读取',
              permissions & VfsPermission.read != 0,
              (value) => onChanged(value
                  ? permissions | VfsPermission.read
                  : permissions & ~VfsPermission.read),
            ),
            const SizedBox(width: 16),
            _buildPermissionCheckbox(
              '写入',
              permissions & VfsPermission.write != 0,
              (value) => onChanged(value
                  ? permissions | VfsPermission.write
                  : permissions & ~VfsPermission.write),
            ),
            const SizedBox(width: 16),
            _buildPermissionCheckbox(
              '执行',
              permissions & VfsPermission.execute != 0,
              (value) => onChanged(value
                  ? permissions | VfsPermission.execute
                  : permissions & ~VfsPermission.execute),
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
            _buildPermissionIndicator('读取', permissions & VfsPermission.read != 0),
            const SizedBox(width: 16),
            _buildPermissionIndicator('写入', permissions & VfsPermission.write != 0),
            const SizedBox(width: 16),
            _buildPermissionIndicator('执行', permissions & VfsPermission.execute != 0),
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
        
        Navigator.of(context).pop(_permissions);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('权限已保存'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存权限失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
