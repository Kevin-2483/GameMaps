import 'package:flutter/material.dart';
import '../../../services/legend_vfs/vfs_directory_tree.dart';
import '../../../services/reactive_version/reactive_version_manager.dart';
import '../../../services/legend_cache_manager.dart';
import '../../../services/legend_vfs/legend_vfs_service.dart';

/// VFS目录树显示组件
///
/// 实现步进型递归选择逻辑：
/// - 选择目录时，只影响当前选中的目录，不会自动选择子目录
/// - 取消选择时，只清理当前目录的缓存，不会递归清理子目录缓存
/// - 如果组1选择了目录2，组2选择了目录2/3，两者互不干扰
/// - 取消选择目录2时，不会影响目录2/3的选择状态和缓存
class VfsDirectoryTreeDisplay extends StatefulWidget {
  final String legendGroupId; // 当前图例组ID
  final ReactiveVersionManager versionManager; // 版本管理器
  final Function(String)? onCacheCleared; // 缓存清理回调

  const VfsDirectoryTreeDisplay({
    super.key,
    required this.legendGroupId,
    required this.versionManager,
    this.onCacheCleared,
  });

  @override
  State<VfsDirectoryTreeDisplay> createState() =>
      _VfsDirectoryTreeDisplayState();
}

class _VfsDirectoryTreeDisplayState extends State<VfsDirectoryTreeDisplay> {
  final VfsDirectoryTreeManager _treeManager = VfsDirectoryTreeManager();

  @override
  void initState() {
    super.initState();
    _treeManager.addListener(_onTreeChanged);
    widget.versionManager.addListener(_onVersionChanged);
    _loadDirectoryTree();
  }

  @override
  void dispose() {
    _treeManager.removeListener(_onTreeChanged);
    widget.versionManager.removeListener(_onVersionChanged);
    _treeManager.dispose();
    super.dispose();
  }

  void _onTreeChanged() {
    // 同步树状态与选中状态
    _syncTreeWithSelectionManager();
    setState(() {});
  }

  void _onVersionChanged() {
    // 当版本管理器状态变化时（例如版本切换）重新同步树状态
    _syncTreeWithSelectionManager();
    setState(() {});
  }

  Future<void> _loadDirectoryTree() async {
    await _treeManager.loadDirectoryTree();
    // 加载完成后同步选中状态
    _syncTreeWithSelectionManager();
  }

  // 同步树状态与选择管理器 - 步进型递归
  void _syncTreeWithSelectionManager() {
    if (_treeManager.rootNode == null) return;

    // 获取当前图例组选中的路径
    final selectedPaths = widget.versionManager.getSelectedPaths(
      widget.legendGroupId,
    );

    // 获取其他图例组选中的路径
    final allSelectedPaths = widget.versionManager.getAllSelectedPaths();
    final otherSelectedPaths = Set<String>.from(allSelectedPaths)
      ..removeAll(selectedPaths);

    // 步进型更新节点状态（只针对精确匹配的路径）
    _updateNodeSelectionStateStepwise(
      _treeManager.rootNode!,
      selectedPaths,
      otherSelectedPaths,
    );

    // 调试信息，帮助排查问题
    debugPrint('同步树状态（步进型）- 当前图例组: ${widget.legendGroupId}');
    debugPrint(
      '当前组选中路径: ${selectedPaths.length} 个，其他组选中: ${otherSelectedPaths.length} 个',
    );
    debugPrint('当前版本: ${widget.versionManager.currentVersionId}');
  }

  // 步进型更新节点选中状态 - 只针对精确匹配的路径，不递归子目录
  void _updateNodeSelectionStateStepwise(
    VfsDirectoryNode node,
    Set<String> selectedPaths,
    Set<String> otherSelectedPaths,
  ) {
    // 更新当前节点状态（包括根节点）
    // 根节点的路径为空字符串，用空字符串表示根目录
    final nodePath = node.path.isEmpty ? "" : node.path;

    // 精确匹配检查：只有当路径完全匹配时才设置选中状态
    node.isSelected = selectedPaths.contains(nodePath);
    node.isDisabled = otherSelectedPaths.contains(nodePath);

    // 递归处理子节点，但只传递状态检查，不传递父级选择状态
    for (final child in node.children) {
      _updateNodeSelectionStateStepwise(
        child,
        selectedPaths,
        otherSelectedPaths,
      );
    }
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
            Icon(Icons.folder_off_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('无法加载VFS目录', style: TextStyle(color: Colors.grey)),
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
                '已选中: ${widget.versionManager.getSelectedPaths(widget.legendGroupId).length} 个目录',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Tooltip(
                message: '步进型选择模式：只选择当前目录，不会递归选择子目录',
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 8),
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
            children: [_buildDirectoryNode(rootNode, 0)],
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
                // 复选框（所有节点都显示，包括根节点）
                Checkbox(
                  value: node.isSelected,
                  onChanged: node.isDisabled
                      ? null
                      : (value) => _toggleSelected(node),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // 如果是禁用状态（被其他组选中），则使用特殊样式
                  fillColor: node.isDisabled
                      ? MaterialStateProperty.resolveWith<Color>(
                          (states) => Colors.grey.withValues(alpha: 0.6),
                        )
                      : null,
                ),
                // 文件夹图标
                Icon(
                  Icons.folder,
                  size: 16,
                  color: node.isDisabled
                      ? Colors.grey.shade400
                      : node.isSelected
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
                      fontWeight: node.isRoot
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: node.isDisabled
                          ? Colors.grey.shade500
                          : node.isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                // 显示该目录被哪个图例组选中（如果被其他组选中）
                if (node.isDisabled)
                  Tooltip(
                    message: _getOtherGroupsMessage(node.path),
                    child: Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // 子节点
        if (node.isExpanded && hasChildren)
          ...node.children.map(
            (child) => _buildDirectoryNode(child, depth + 1),
          ),
      ],
    );
  }

  /// 切换节点展开状态
  void _toggleExpanded(VfsDirectoryNode node) {
    _treeManager.toggleExpanded(node.path);
  }

  /// 切换节点选中状态 - 步进型递归（只影响当前目录）
  void _toggleSelected(VfsDirectoryNode node) {
    if (node.isDisabled) return; // 如果是禁用状态，不允许切换

    // 切换选中状态
    final newSelectedState = !node.isSelected;

    // 更新树状态（只更新当前节点）
    _treeManager.toggleSelected(node.path);

    // 更新选择管理器状态（只更新当前路径）
    widget.versionManager.setPathSelected(
      widget.legendGroupId,
      node.path,
      newSelectedState,
    );

    // 如果选中目录，加载其中的图例到缓存系统
    if (newSelectedState) {
      _loadLegendsFromDirectoryToCache(node.path);
      debugPrint('步进型选择: 选中目录 ${node.path}');
    }

    // 如果取消选中，清理相关缓存（只清理当前路径的缓存）
    if (!newSelectedState) {
      widget.versionManager.clearUnusedCache(widget.legendGroupId, node.path, (
        path,
      ) {
        // 通知上层组件缓存已清理，让上层组件处理具体的清理逻辑
        widget.onCacheCleared?.call(path);
        debugPrint('步进型取消: 通知上层清理路径 $path 的缓存');
      });
      debugPrint('步进型取消: 取消选中目录 ${node.path}');
    }
  }

  /// 从目录加载图例到缓存系统
  Future<void> _loadLegendsFromDirectoryToCache(String directoryPath) async {
    try {
      debugPrint('开始从目录加载图例到缓存: $directoryPath');

      // 获取图例VFS服务
      final legendService = LegendVfsService();

      // 获取目录下的所有图例文件
      final legendFiles = await legendService.getLegendsInFolder(directoryPath);

      debugPrint('在目录 $directoryPath 中找到 ${legendFiles.length} 个图例文件');

      // 加载每个图例到缓存
      for (final legendFile in legendFiles) {
        try {
          // 构造图例的完整路径
          final legendPath = directoryPath.isEmpty
              ? legendFile
              : '$directoryPath/$legendFile';

          // 提取图例标题（移除.legend扩展名）
          final legendTitle = legendFile.replaceAll('.legend', '');

          // 加载图例数据
          final legendData = await legendService.getLegend(
            legendTitle,
            directoryPath,
          );

          if (legendData != null) {
            // 添加到缓存管理器
            LegendCacheManager().cacheLegend(
              legendPath,
              legendData,
              metadata: {
                'directoryPath': directoryPath,
                'selectedByGroup': widget.legendGroupId,
                'loadedAt': DateTime.now().toIso8601String(),
              },
            );

            debugPrint('已缓存图例: $legendPath');
          }
        } catch (e) {
          debugPrint('加载图例失败: $legendFile, 错误: $e');
        }
      }
    } catch (e) {
      debugPrint('从目录加载图例失败: $directoryPath, 错误: $e');
    }
  }

  /// 获取其他图例组的提示信息
  String _getOtherGroupsMessage(String path) {
    final otherGroupNames = widget.versionManager
        .getOtherGroupNamesSelectingPath(path, widget.legendGroupId);

    if (otherGroupNames.isEmpty) {
      return '此目录已被其他图例组选择';
    } else if (otherGroupNames.length == 1) {
      return '此目录已被图例组 "${otherGroupNames.first}" 选择';
    } else {
      return '此目录已被以下图例组选择：${otherGroupNames.join(", ")}';
    }
  }

  @override
  void didUpdateWidget(VfsDirectoryTreeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果图例组ID发生变化，需要重新同步选中状态
    if (oldWidget.legendGroupId != widget.legendGroupId) {
      _syncTreeWithSelectionManager();
      setState(() {});
    }
  }
}
