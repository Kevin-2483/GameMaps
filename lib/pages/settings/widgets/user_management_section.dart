import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_preferences.dart';
import '../../../providers/user_preferences_provider.dart';

class UserManagementSection extends StatelessWidget {
  final UserPreferences preferences;

  const UserManagementSection({
    super.key,
    required this.preferences,
  });
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
                    backgroundImage: preferences.avatarPath != null
                        ? NetworkImage(preferences.avatarPath!)
                        : null,
                    child: preferences.avatarPath == null
                        ? Text(
                            preferences.displayName.isNotEmpty
                                ? preferences.displayName[0].toUpperCase()
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
                          preferences.displayName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (preferences.userId != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${preferences.userId}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '创建时间: ${_formatDate(preferences.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (preferences.lastLoginAt != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '最后登录: ${_formatDate(preferences.lastLoginAt!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _editUserInfo(context, provider),
                    icon: Icon(Icons.edit),
                    tooltip: '编辑用户信息',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 用户配置文件管理
            Text(
              '配置文件管理',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // 创建新配置文件
            ListTile(
              leading: Icon(Icons.person_add, color: Colors.green),
              title: Text('创建新配置文件'),
              subtitle: Text('为不同用户或用途创建独立配置'),
              onTap: () => _createNewProfile(context, provider),
            ),
            
            // 切换配置文件
            ListTile(
              leading: Icon(Icons.switch_account, color: Colors.blue),
              title: Text('切换配置文件'),
              subtitle: Text('在多个用户配置之间切换'),
              onTap: () => _switchProfile(context, provider),
            ),
            
            // 删除当前配置文件
            if (preferences.userId != null)
              ListTile(
                leading: Icon(Icons.person_remove, color: Colors.red),
                title: Text('删除当前配置文件'),
                subtitle: Text('永久删除当前用户配置文件'),
                onTap: () => _deleteCurrentProfile(context, provider),
              ),
            
            const SizedBox(height: 16),
            
            // 账户设置
            Text(
              '账户设置',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // 更改显示名称
            ListTile(
              leading: Icon(Icons.badge),
              title: Text('显示名称'),
              subtitle: Text(preferences.displayName),
              trailing: Icon(Icons.edit),
              onTap: () => _changeDisplayName(context, provider),
            ),
            
            // 更改头像
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('头像'),
              subtitle: Text(preferences.avatarPath ?? '未设置'),
              trailing: Icon(Icons.edit),
              onTap: () => _changeAvatar(context, provider),
            ),
            
            // 语言设置
            ListTile(
              leading: Icon(Icons.language),
              title: Text('语言'),
              subtitle: Text(_getLanguageDisplayName(preferences.locale)),
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

  void _editUserInfo(BuildContext context, UserPreferencesProvider provider) {
    // 编辑用户信息的实现
    showDialog(
      context: context,
      builder: (context) => _UserInfoEditDialog(preferences: preferences, provider: provider),
    );
  }

  void _createNewProfile(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _CreateProfileDialog(provider: provider),
    );
  }

  void _switchProfile(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _SwitchProfileDialog(provider: provider),
    );
  }

  void _deleteCurrentProfile(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除配置文件'),
        content: Text('确定要删除当前配置文件"${preferences.displayName}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 实现删除配置文件的逻辑
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('配置文件已删除'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('删除'),
          ),
        ],
      ),
    );
  }

  void _changeDisplayName(BuildContext context, UserPreferencesProvider provider) {
    // 更改显示名称的实现
  }

  void _changeAvatar(BuildContext context, UserPreferencesProvider provider) {
    // 更改头像的实现
  }

  void _changeLanguage(BuildContext context, UserPreferencesProvider provider) {
    // 更改语言的实现
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
    _nameController = TextEditingController(text: widget.preferences.displayName);
    _avatarController = TextEditingController(text: widget.preferences.avatarPath ?? '');
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
              avatarPath: _avatarController.text.trim().isEmpty ? null : _avatarController.text.trim(),
            );
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('用户信息已更新'),
                backgroundColor: Colors.green,
              ),
            );
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('配置文件"$name"已创建'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: Text('创建'),
        ),
      ],
    );
  }
}

// 切换配置文件对话框
class _SwitchProfileDialog extends StatelessWidget {
  final UserPreferencesProvider provider;

  const _SwitchProfileDialog({required this.provider});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('切换配置文件'),
      content: Container(
        width: 300,
        height: 400,
        child: Column(
          children: [
            Text('选择要切换到的配置文件：'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  // 这里会显示所有可用的配置文件列表
                  ListTile(
                    leading: CircleAvatar(child: Text('D')),
                    title: Text('默认配置'),
                    subtitle: Text('2024-01-01 创建'),
                    onTap: () {
                      // 切换到选定的配置文件
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
      ],
    );
  }
}
