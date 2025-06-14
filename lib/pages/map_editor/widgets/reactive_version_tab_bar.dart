import 'package:flutter/material.dart';
import '../../../services/reactive_version_manager.dart';

/// 响应式版本管理标签页组件
class ReactiveVersionTabBar extends StatelessWidget {
  final List<ReactiveVersionState> versions;
  final String? currentVersionId;
  final Function(String versionId) onVersionSelected;
  final Function(String name) onVersionCreated;
  final Function(String versionId) onVersionDeleted;
  final bool isPreviewMode;

  const ReactiveVersionTabBar({
    super.key,
    required this.versions,
    required this.currentVersionId,
    required this.onVersionSelected,
    required this.onVersionCreated,
    required this.onVersionDeleted,
    this.isPreviewMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // 添加调试信息
    debugPrint('响应式版本标签栏构建: 版本数量=${versions.length}, 当前版本=$currentVersionId');
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 版本标签
          Expanded(
            child: versions.isEmpty
                ? _buildEmptyVersions(context)
                : _buildVersionTabs(context),
          ),
          
          // 创建版本按钮
          if (!isPreviewMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => _showCreateVersionDialog(context),
                icon: const Icon(Icons.add),
                tooltip: '创建新版本',
                iconSize: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyVersions(BuildContext context) {
    return const Center(
      child: Text(
        '暂无版本',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildVersionTabs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: versions.map((version) {
          final isSelected = version.versionId == currentVersionId;
          return _buildVersionTab(context, version, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildVersionTab(
    BuildContext context,
    ReactiveVersionState version,
    bool isSelected,
  ) {
    final isDeletable = version.versionId != 'default';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => onVersionSelected(version.versionId),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : Border.all(color: Theme.of(context).dividerColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 版本名称
                Text(
                  version.versionName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                
                // 未保存更改指示器
                if (version.hasUnsavedChanges) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: Colors.orange,
                  ),
                ],
                
                // 删除按钮
                if (isDeletable && !isPreviewMode) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _showDeleteVersionDialog(context, version),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateVersionDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '版本名称',
                hintText: '输入版本名称',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop();
                onVersionCreated(name);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showDeleteVersionDialog(BuildContext context, ReactiveVersionState version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除版本'),
        content: Text('确定要删除版本 "${version.versionName}" 吗？\n此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onVersionDeleted(version.versionId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
