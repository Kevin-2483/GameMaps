import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/virtual_file_system/vfs_service_provider.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';

/// VFS文件搜索对话框
class VfsFileSearchDialog extends StatefulWidget {
  final VfsServiceProvider vfsService;
  final String database;
  final String collection;
  final String currentPath;

  const VfsFileSearchDialog({
    super.key,
    required this.vfsService,
    required this.database,
    required this.collection,
    required this.currentPath,
  });

  @override
  State<VfsFileSearchDialog> createState() => _VfsFileSearchDialogState();
  /// 显示文件搜索对话框
  static Future<VfsFileInfo?> show(
    BuildContext context,
    VfsServiceProvider vfsService,
    String database,
    String collection,
    String currentPath,
  ) {
    return showDialog<VfsFileInfo>(
      context: context,
      builder: (context) => VfsFileSearchDialog(
        vfsService: vfsService,
        database: database,
        collection: collection,
        currentPath: currentPath,
      ),
    );
  }
}

class _VfsFileSearchDialogState extends State<VfsFileSearchDialog> {
  late TextEditingController _searchController;
  List<VfsFileInfo> _searchResults = [];
  bool _isSearching = false;
  bool _searchInCurrentPath = true;
  bool _includeFiles = true;
  bool _includeFolders = true;
  bool _caseSensitive = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });    try {      // 使用专用的搜索方法而不是listFiles，这样可以递归搜索所有文件
      final pattern = '*$query*'; // 使用通配符模式
      final allResults = await widget.vfsService.searchFiles(
        widget.collection,
        pattern,
        caseSensitive: _caseSensitive,
        includeDirectories: _includeFolders, // 传递文件夹包含设置
        maxResults: 1000, // 设置合理的最大结果数
      );

      final filteredResults = allResults.where((file) {
        // 类型过滤
        if (file.isDirectory && !_includeFolders) return false;
        if (!file.isDirectory && !_includeFiles) return false;
        
        // 如果设置了只在当前路径搜索，则过滤路径
        if (_searchInCurrentPath && widget.currentPath.isNotEmpty) {
          final expectedPrefix = widget.currentPath.endsWith('/') 
              ? widget.currentPath 
              : '${widget.currentPath}/';
          final filePath = file.path.replaceFirst('indexeddb://${widget.database}/${widget.collection}/', '');
          if (!filePath.startsWith(expectedPrefix) && filePath != widget.currentPath) {
            return false;
          }
        }
        
        return true;
      }).toList();      if (mounted) {
        setState(() {
          _searchResults = filteredResults;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: $e')),
        );
      }
    }
  }
  void _selectFile(VfsFileInfo file) {
    // 返回文件信息以便文件管理器进行导航
    Navigator.of(context).pop(file);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      child: Container(
        width: 600,
        height: 500,
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '搜索文件',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // 搜索区域
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 搜索输入框
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '输入搜索关键词...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 搜索选项
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _searchInCurrentPath,
                            onChanged: (value) {
                              setState(() {
                                _searchInCurrentPath = value ?? true;
                              });
                              _performSearch();
                            },
                          ),
                          const Text('仅在当前路径搜索'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _includeFiles,
                            onChanged: (value) {
                              setState(() {
                                _includeFiles = value ?? true;
                              });
                              _performSearch();
                            },
                          ),
                          const Text('包含文件'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _includeFolders,
                            onChanged: (value) {
                              setState(() {
                                _includeFolders = value ?? true;
                              });
                              _performSearch();
                            },
                          ),
                          const Text('包含文件夹'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _caseSensitive,
                            onChanged: (value) {
                              setState(() {
                                _caseSensitive = value ?? false;
                              });
                              _performSearch();
                            },
                          ),
                          const Text('区分大小写'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 搜索结果
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildSearchResults(),
              ),
            ),
            
            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '找到 ${_searchResults.length} 个结果',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),                      FilledButton(
                        onPressed: _searchController.text.isNotEmpty
                            ? () => Navigator.of(context).pop(null)
                            : null,
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      if (_searchController.text.isEmpty) {
        return const Center(
          child: Text('输入关键词开始搜索'),
        );
      } else {
        return const Center(
          child: Text('未找到匹配的文件'),
        );
      }
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final file = _searchResults[index];
        return _buildFileItem(file);
      },
    );
  }

  Widget _buildFileItem(VfsFileInfo file) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _selectFile(file),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              file.isDirectory ? Icons.folder : Icons.insert_drive_file,
              color: file.isDirectory
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (file.path != file.name) ...[
                    const SizedBox(height: 2),
                    Text(
                      file.path,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!file.isDirectory) ...[
              const SizedBox(width: 8),
              Text(
                _formatFileSize(file.size),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
