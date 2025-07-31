// This file has been processed by AI for internationalization
import 'package:flutter/foundation.dart';
import 'legend_vfs_service.dart';

import '../localization_service.dart';

/// VFS目录节点
class VfsDirectoryNode {
  final String name;
  final String path;
  final bool isRoot;
  final List<VfsDirectoryNode> children; // 改为可修改的列表
  bool isExpanded;
  bool isSelected;
  bool isDisabled; // 添加禁用状态，表示被其他图例组选中

  VfsDirectoryNode({
    required this.name,
    required this.path,
    this.isRoot = false,
    List<VfsDirectoryNode>? children, // 改为可选参数
    this.isExpanded = false,
    this.isSelected = false,
    this.isDisabled = false, // 初始化禁用状态
  }) : children = children ?? <VfsDirectoryNode>[]; // 创建可修改的列表

  VfsDirectoryNode copyWith({
    String? name,
    String? path,
    bool? isRoot,
    List<VfsDirectoryNode>? children,
    bool? isExpanded,
    bool? isSelected,
    bool? isDisabled,
  }) {
    return VfsDirectoryNode(
      name: name ?? this.name,
      path: path ?? this.path,
      isRoot: isRoot ?? this.isRoot,
      children: children ?? List<VfsDirectoryNode>.from(this.children), // 复制列表
      isExpanded: isExpanded ?? this.isExpanded,
      isSelected: isSelected ?? this.isSelected,
      isDisabled: isDisabled ?? this.isDisabled, // 复制禁用状态
    );
  }

  /// 递归查找节点
  VfsDirectoryNode? findNode(String targetPath) {
    if (path == targetPath) return this;

    for (final child in children) {
      final found = child.findNode(targetPath);
      if (found != null) return found;
    }

    return null;
  }

  /// 获取所有选中的节点路径
  List<String> getSelectedPaths() {
    final List<String> selectedPaths = [];

    if (isSelected) {
      selectedPaths.add(path);
    }

    for (final child in children) {
      selectedPaths.addAll(child.getSelectedPaths());
    }

    return selectedPaths;
  }

  /// 递归更新节点状态
  void updateNode(
    String targetPath, {
    bool? isExpanded,
    bool? isSelected,
    bool? isDisabled,
  }) {
    if (path == targetPath) {
      if (isExpanded != null) this.isExpanded = isExpanded;
      if (isSelected != null) this.isSelected = isSelected;
      if (isDisabled != null) this.isDisabled = isDisabled;
      return;
    }

    for (final child in children) {
      child.updateNode(
        targetPath,
        isExpanded: isExpanded,
        isSelected: isSelected,
        isDisabled: isDisabled,
      );
    }
  }
}

/// VFS目录树管理器
class VfsDirectoryTreeManager extends ChangeNotifier {
  final LegendVfsService _legendService = LegendVfsService();
  VfsDirectoryNode? _rootNode;
  bool _isLoading = false;

  VfsDirectoryNode? get rootNode => _rootNode;
  bool get isLoading => _isLoading;

  /// 加载目录结构
  Future<void> loadDirectoryTree() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 获取所有文件夹
      final folders = await _legendService.getAllFolders();

      // 构建目录树
      _rootNode = _buildDirectoryTree(folders);

      debugPrint(
        LocalizationService.instance.current.vfsDirectoryTreeLoaded(
          _rootNode?.children.length ?? 0,
        ),
      );
    } catch (e) {
      debugPrint(
        LocalizationService.instance.current.vfsDirectoryLoadFailed_7421(e),
      );
      _rootNode = VfsDirectoryNode(
        name: LocalizationService.instance.current.rootDirectoryName_4721,
        path: '',
        isRoot: true,
        isExpanded: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 构建目录树结构
  VfsDirectoryNode _buildDirectoryTree(List<String> folders) {
    // 创建根节点
    final root = VfsDirectoryNode(
      name: LocalizationService.instance.current.exampleLibrary_7421,
      path: '',
      isRoot: true,
      isExpanded: true,
    );

    // 构建节点映射
    final Map<String, VfsDirectoryNode> nodeMap = {'': root};

    debugPrint(
      LocalizationService.instance.current.vfsDirectoryTreeStartBuilding(
        folders.length,
      ),
    );
    // 处理所有文件夹路径
    for (final folderPath in folders) {
      final pathSegments = folderPath
          .split('/')
          .where((s) => s.isNotEmpty)
          .toList();

      debugPrint(
        LocalizationService.instance.current.vfsDirectoryTreeProcessingPath(
          folderPath,
          pathSegments.join(', '),
        ),
      );
      String currentPath = '';

      debugPrint(
        LocalizationService.instance.current.vfsDirectoryTreeProcessingPath(
          folderPath,
          pathSegments,
        ),
      );

      for (int i = 0; i < pathSegments.length; i++) {
        final segment = pathSegments[i];
        final parentPath = currentPath;
        currentPath = currentPath.isEmpty ? segment : '$currentPath/$segment';

        // 如果节点不存在，创建它
        if (!nodeMap.containsKey(currentPath)) {
          final newNode = VfsDirectoryNode(
            name: segment,
            path: currentPath,
            isExpanded: false,
          );

          nodeMap[currentPath] = newNode;

          // 添加到父节点
          final parentNode = nodeMap[parentPath];
          if (parentNode != null) {
            parentNode.children.add(newNode);
            debugPrint(
              LocalizationService.instance.current.vfsDirectoryTreeCreateNode(
                segment,
                currentPath,
                parentNode.name,
                parentPath,
              ),
            );
          } else {
            debugPrint(
              LocalizationService.instance.current.vfsTreeWarningParentNotFound(
                parentPath,
              ),
            );
          }
        } else {
          debugPrint(
            LocalizationService.instance.current.vfsNodeExists_7281(
              currentPath,
            ),
          );
        }
      }
    }

    // 对所有节点的子节点进行排序
    _sortChildrenRecursively(root);

    debugPrint(
      LocalizationService.instance.current.vfsDirectoryTreeBuilt_7281(
        root.children.length,
      ),
    );
    _printTreeStructure(root, 0);

    return root;
  }

  /// 递归排序子节点
  void _sortChildrenRecursively(VfsDirectoryNode node) {
    node.children.sort((a, b) => a.name.compareTo(b.name));
    for (final child in node.children) {
      _sortChildrenRecursively(child);
    }
  }

  /// 切换节点展开状态
  void toggleExpanded(String nodePath) {
    final node = _rootNode?.findNode(nodePath);
    if (node != null) {
      node.isExpanded = !node.isExpanded;
      notifyListeners();
    }
  }

  /// 切换节点选中状态
  void toggleSelected(String nodePath) {
    final node = _rootNode?.findNode(nodePath);
    if (node != null) {
      node.isSelected = !node.isSelected;
      notifyListeners();

      // 注意：原先的缓存管理已移至LegendPathSelectionManager
      // 这里只触发状态变化通知，不再直接管理缓存
    }
  }

  /// 获取所有选中的节点路径
  List<String> getSelectedPaths() {
    return _rootNode?.getSelectedPaths() ?? [];
  }

  /// 刷新目录树
  Future<void> refresh() async {
    await loadDirectoryTree();
  }

  /// 打印树结构（调试用）
  void _printTreeStructure(VfsDirectoryNode node, int depth) {
    final indent = '  ' * depth;
    debugPrint(
      '$indent${node.name} (${node.path}) - ${node.children.length} children',
    );
    for (final child in node.children) {
      _printTreeStructure(child, depth + 1);
    }
  }

  @override
  void dispose() {
    _rootNode = null;
    super.dispose();
  }
}
