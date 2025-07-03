import 'package:flutter/material.dart';
import '../../../services/legend_vfs/vfs_directory_tree.dart';
import '../../../services/reactive_version/reactive_version_manager.dart';
import '../../../services/legend_cache_manager.dart';
import '../../../services/legend_vfs/legend_vfs_service.dart';

/// VFS目录树显示组件
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
  State<VfsDirectoryTreeDisplay> createState() => _VfsDirectoryTreeDisplayState();
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
  
  // 同步树状态与选择管理器
  void _syncTreeWithSelectionManager() {
    if (_treeManager.rootNode == null) return;
    
    // 获取当前图例组选中的路径
    final selectedPaths = widget.versionManager.getSelectedPaths(widget.legendGroupId);
    
    // 获取其他图例组选中的路径
    final allSelectedPaths = widget.versionManager.getAllSelectedPaths();
    final otherSelectedPaths = Set<String>.from(allSelectedPaths)
      ..removeAll(selectedPaths);
    
    // 递归更新节点状态
    _updateNodeSelectionState(_treeManager.rootNode!, selectedPaths, otherSelectedPaths);
    
    // 调试信息，帮助排查问题
    debugPrint('同步树状态 - 当前图例组: ${widget.legendGroupId}');
    debugPrint('当前组选中路径: ${selectedPaths.length} 个，其他组选中: ${otherSelectedPaths.length} 个');
    debugPrint('当前版本: ${widget.versionManager.currentVersionId}');
  }
  
  // 递归更新节点选中状态
  void _updateNodeSelectionState(
    VfsDirectoryNode node, 
    Set<String> selectedPaths,
    Set<String> otherSelectedPaths
  ) {
    // 更新当前节点状态
    if (node.path.isNotEmpty) {  // 排除根节点
      node.isSelected = selectedPaths.contains(node.path);
      node.isDisabled = otherSelectedPaths.contains(node.path);
    }
    
    // 递归更新子节点
    for (final child in node.children) {
      _updateNodeSelectionState(child, selectedPaths, otherSelectedPaths);
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
                '已选中: ${widget.versionManager.getSelectedPaths(widget.legendGroupId).length} 个目录',
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
                    onChanged: node.isDisabled ? null : (value) => _toggleSelected(node),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    // 如果是禁用状态（被其他组选中），则使用特殊样式
                    fillColor: node.isDisabled 
                        ? MaterialStateProperty.resolveWith<Color>(
                            (states) => Colors.grey.withOpacity(0.6),
                          )
                        : null,
                  ),
                ],
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
                      fontWeight: node.isRoot ? FontWeight.w500 : FontWeight.normal,
                      color: node.isDisabled
                          ? Colors.grey.shade500
                          : node.isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : null,
                    ),
                  ),
                ),
                // 显示该目录被哪个图例组选中（如果被其他组选中）
                if (node.isDisabled && !node.isRoot)
                  Tooltip(
                    message: '此目录已被其他图例组选择',
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
    if (node.isDisabled) return; // 如果是禁用状态，不允许切换
    
    // 切换选中状态
    final newSelectedState = !node.isSelected;
    
    // 更新树状态
    _treeManager.toggleSelected(node.path);
    
    // 更新选择管理器状态
    widget.versionManager.setPathSelected(
      widget.legendGroupId, 
      node.path, 
      newSelectedState
    );
    
    // 如果选中目录，加载其中的图例到缓存系统
    if (newSelectedState) {
      _loadLegendsFromDirectoryToCache(node.path);
    }
    
    // 如果取消选中，清理相关缓存
    if (!newSelectedState) {
      widget.versionManager.clearUnusedCache(
        widget.legendGroupId, 
        node.path, 
        (path) {
          // 清理缓存
          LegendCacheManager().clearCacheByFolder(path);
          // 通知上层组件缓存已清理
          widget.onCacheCleared?.call(path);
        }
      );
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
          final legendData = await legendService.getLegend(legendTitle, directoryPath);
          
          if (legendData != null) {
            // 添加到缓存管理器
            LegendCacheManager().cacheLegend(
              legendPath, 
              legendData,
              metadata: {
                'directoryPath': directoryPath,
                'selectedByGroup': widget.legendGroupId,
                'loadedAt': DateTime.now().toIso8601String(),
              }
            );
            
            debugPrint('已缓存图例: $legendPath');
          }
        } catch (e) {
          debugPrint('加载图例失败: $legendFile, 错误: $e');
        }
      }
      
      // 通知缓存已更新
      widget.onCacheCleared?.call(directoryPath);
      
    } catch (e) {
      debugPrint('从目录加载图例失败: $directoryPath, 错误: $e');
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
