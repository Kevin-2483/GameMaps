import 'package:flutter/material.dart';
import '../../../services/legend_vfs/vfs_directory_tree.dart';

/// VFS目录树显示组件
class VfsDirectoryTreeDisplay extends StatefulWidget {
  const VfsDirectoryTreeDisplay({super.key});

  @override
  State<VfsDirectoryTreeDisplay> createState() => _VfsDirectoryTreeDisplayState();
}

class _VfsDirectoryTreeDisplayState extends State<VfsDirectoryTreeDisplay> {
  final VfsDirectoryTreeManager _treeManager = VfsDirectoryTreeManager();

  @override
  void initState() {
    super.initState();
    _treeManager.addListener(_onTreeChanged);
    _loadDirectoryTree();
  }

  @override
  void dispose() {
    _treeManager.removeListener(_onTreeChanged);
    _treeManager.dispose();
    super.dispose();
  }

  void _onTreeChanged() {
    setState(() {});
  }

  Future<void> _loadDirectoryTree() async {
    await _treeManager.loadDirectoryTree();
  }

  @override
  Widget build(BuildContext context) {
    if (_treeManager.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载VFS目录结构...'),
          ],
        ),
      );
    }

    final rootNode = _treeManager.rootNode;
    if (rootNode == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '无法加载VFS目录',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 工具栏
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                '已选中: ${_treeManager.getSelectedPaths().length} 个目录',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: _loadDirectoryTree,
                tooltip: '刷新目录树',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 目录树
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildDirectoryNode(rootNode, 0),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建目录节点
  Widget _buildDirectoryNode(VfsDirectoryNode node, int depth) {
    final hasChildren = node.children.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 节点本身
        InkWell(
          onTap: hasChildren ? () => _toggleExpanded(node) : null,
          child: Padding(
            padding: EdgeInsets.only(left: depth * 16.0),
            child: Row(
              children: [
                // 展开/折叠图标
                SizedBox(
                  width: 24,
                  height: 24,
                  child: hasChildren
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            node.isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: 16,
                          ),
                          onPressed: () => _toggleExpanded(node),
                        )
                      : null,
                ),
                // 复选框（只有非根节点才显示）
                if (!node.isRoot) ...[
                  Checkbox(
                    value: node.isSelected,
                    onChanged: (value) => _toggleSelected(node),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
                // 文件夹图标
                Icon(
                  Icons.folder,
                  size: 16,
                  color: node.isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                // 节点名称
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: node.isRoot ? FontWeight.w500 : FontWeight.normal,
                      color: node.isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 子节点
        if (node.isExpanded && hasChildren)
          ...node.children.map((child) => _buildDirectoryNode(child, depth + 1)),
      ],
    );
  }

  /// 切换节点展开状态
  void _toggleExpanded(VfsDirectoryNode node) {
    _treeManager.toggleExpanded(node.path);
  }

  /// 切换节点选中状态
  void _toggleSelected(VfsDirectoryNode node) {
    _treeManager.toggleSelected(node.path);
  }
}
