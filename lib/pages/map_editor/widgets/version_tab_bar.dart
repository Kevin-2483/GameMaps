import 'package:flutter/material.dart';
import '../../../models/map_version.dart';

/// 版本管理标签页组件
class VersionTabBar extends StatelessWidget {
  final List<MapVersion> versions;
  final String currentVersionId;
  final Function(String versionId) onVersionSelected;
  final Function(String name) onVersionCreated;
  final Function(String versionId) onVersionDeleted;
  final bool isPreviewMode;

  const VersionTabBar({
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: versions
                    .map(
                      (version) => _buildVersionTab(
                        context,
                        version,
                        version.id == currentVersionId,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // 添加版本按钮
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: IconButton(
              onPressed: () => _showCreateVersionDialog(context),
              icon: const Icon(Icons.add, size: 20),
              iconSize: 20,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              tooltip: '创建新版本',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionTab(
    BuildContext context,
    MapVersion version,
    bool isSelected,
  ) {
    final isDeletable = version.id != 'default';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => onVersionSelected(version.id),
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
                  version.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),

                // 删除按钮
                if (isDeletable) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _showDeleteVersionDialog(context, version),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha((0.8 * 255).toInt()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
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
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '版本名称',
                hintText: '输入版本名称',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  onVersionCreated(value.trim());
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              '当前状态将被保存为新版本',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
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
              final name = nameController.text.trim();
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

  void _showDeleteVersionDialog(BuildContext context, MapVersion version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除版本'),
        content: Text('确定要删除版本 "${version.name}" 吗？\n此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onVersionDeleted(version.id);
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
