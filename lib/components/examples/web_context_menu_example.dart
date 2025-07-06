import 'package:flutter/material.dart';
import '../web/web_context_menu_handler.dart';

/// Web兼容的右键菜单组件示例
/// 用于演示如何在Web平台上实现与客户端一致的右键菜单体验
class WebCompatibleContextMenuExample extends StatelessWidget {
  const WebCompatibleContextMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return WebContextMenuHandler(
      preventWebContextMenu: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Web兼容右键菜单示例')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Web平台右键菜单说明',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                '在Web平台上，浏览器默认会显示自己的右键菜单。'
                '通过我们的处理方案，可以禁用浏览器默认菜单，使用Flutter自定义菜单。',
              ),
              const SizedBox(height: 24),

              // 示例1：简单的右键菜单
              _buildContextMenuExample1(context),
              const SizedBox(height: 16),

              // 示例2：复杂的右键菜单
              _buildContextMenuExample2(context),
              const SizedBox(height: 16),

              // 示例3：列表项右键菜单
              _buildContextMenuExample3(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextMenuExample1(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('示例1：简单右键菜单', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ContextMenuWrapper(
              menuBuilder: (context) => [
                ContextMenuItem(
                  label: '复制',
                  icon: Icons.copy,
                  onTap: () => _showSnackBar(context, '已复制'),
                ),
                ContextMenuItem(
                  label: '粘贴',
                  icon: Icons.paste,
                  onTap: () => _showSnackBar(context, '已粘贴'),
                ),
                const ContextMenuItem.divider(),
                ContextMenuItem(
                  label: '删除',
                  icon: Icons.delete,
                  onTap: () => _showSnackBar(context, '已删除'),
                ),
              ],
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('右键点击这里试试')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuExample2(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('示例2：图片编辑菜单', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ContextMenuWrapper(
              menuBuilder: (context) => [
                ContextMenuItem(
                  label: '编辑',
                  icon: Icons.edit,
                  onTap: () => _showSnackBar(context, '打开编辑器'),
                ),
                ContextMenuItem(
                  label: '旋转',
                  icon: Icons.rotate_right,
                  onTap: () => _showSnackBar(context, '图片已旋转'),
                ),
                ContextMenuItem(
                  label: '缩放',
                  icon: Icons.zoom_in,
                  onTap: () => _showSnackBar(context, '缩放图片'),
                ),
                const ContextMenuItem.divider(),
                ContextMenuItem(
                  label: '另存为',
                  icon: Icons.save_as,
                  onTap: () => _showSnackBar(context, '另存为'),
                ),
                ContextMenuItem(
                  label: '导出',
                  icon: Icons.file_download,
                  onTap: () => _showSnackBar(context, '正在导出'),
                ),
                const ContextMenuItem.divider(),
                ContextMenuItem(
                  label: '属性',
                  icon: Icons.info,
                  onTap: () => _showSnackBar(context, '显示属性'),
                ),
              ],
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 48),
                      SizedBox(height: 8),
                      Text('图片编辑区域 - 右键查看选项'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuExample3(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('示例3：列表项菜单', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...List.generate(3, (index) {
              return ContextMenuWrapper(
                menuBuilder: (context) => [
                  ContextMenuItem(
                    label: '查看详情',
                    icon: Icons.visibility,
                    onTap: () => _showSnackBar(context, '查看项目 ${index + 1} 详情'),
                  ),
                  ContextMenuItem(
                    label: '编辑',
                    icon: Icons.edit,
                    onTap: () => _showSnackBar(context, '编辑项目 ${index + 1}'),
                  ),
                  const ContextMenuItem.divider(),
                  ContextMenuItem(
                    label: '复制链接',
                    icon: Icons.link,
                    onTap: () =>
                        _showSnackBar(context, '已复制项目 ${index + 1} 链接'),
                  ),
                  ContextMenuItem(
                    label: '分享',
                    icon: Icons.share,
                    onTap: () => _showSnackBar(context, '分享项目 ${index + 1}'),
                  ),
                  const ContextMenuItem.divider(),
                  ContextMenuItem(
                    label: '删除',
                    icon: Icons.delete,
                    onTap: () => _showSnackBar(context, '删除项目 ${index + 1}'),
                  ),
                ],
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('列表项 ${index + 1}'),
                  subtitle: Text('右键点击查看选项'),
                  trailing: const Icon(Icons.more_vert),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
