import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/virtual_file_system/virtual_file_system.dart';
import '../../services/virtual_file_system/vfs_service_provider.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';
import '../../services/virtual_file_system/vfs_import_export_service.dart';
import '../web/web_context_menu_handler.dart';
import 'vfs_file_metadata_dialog.dart';
import 'vfs_file_rename_dialog.dart';
import 'vfs_file_search_dialog.dart';

/// VFS文件管理器窗口，作为全屏覆盖层显示
class VfsFileManagerWindow extends StatefulWidget {
  final VoidCallback? onClose;
  final String? initialDatabase;
  final String? initialCollection;
  final String? initialPath;

  const VfsFileManagerWindow({
    super.key,
    this.onClose,
    this.initialDatabase,
    this.initialCollection,
    this.initialPath,
  });

  @override
  State<VfsFileManagerWindow> createState() => _VfsFileManagerWindowState();

  /// 显示VFS文件管理器窗口
  static Future<void> show(
    BuildContext context, {
    String? initialDatabase,
    String? initialCollection,
    String? initialPath,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => VfsFileManagerWindow(
        onClose: () => Navigator.of(context).pop(),
        initialDatabase: initialDatabase,
        initialCollection: initialCollection,
        initialPath: initialPath,
      ),
    );
  }
}

class _VfsFileManagerWindowState extends State<VfsFileManagerWindow>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late VfsServiceProvider _vfsService;
  late VfsImportExportService _importExportService;
  
  // 状态管理
  bool _isLoading = false;
  String? _errorMessage;
  
  // 数据库和集合状态
  List<String> _databases = [];
  String? _selectedDatabase;
  Map<String, List<String>> _collections = {};
  String? _selectedCollection;
  
  // 文件浏览状态
  List<VfsFileInfo> _currentFiles = [];
  String _currentPath = '';
  List<String> _pathHistory = [];
  int _historyIndex = -1;
  
  // 选择状态
  Set<String> _selectedFiles = {};
  VfsFileInfo? _lastSelectedFile;
  
  // 剪贴板状态
  List<VfsFileInfo> _clipboardFiles = [];
  bool _isCutOperation = false;
  
  // 搜索状态
  String _searchQuery = '';
  bool _isSearchMode = false;
  List<VfsFileInfo> _searchResults = [];
  
  // 排序状态
  _SortType _sortType = _SortType.name;
  bool _sortAscending = true;
  
  // 视图状态
  _ViewType _viewType = _ViewType.list;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _vfsService = VfsServiceProvider();
    _importExportService = VfsImportExportService();
    _initializeFileManager();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  /// 初始化文件管理器
  Future<void> _initializeFileManager() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 初始化VFS服务和根文件系统
      await _vfsService.initialize();
      
      // 加载数据库列表
      await _loadDatabases();
      
      // 设置初始位置
      if (widget.initialDatabase != null) {
        _selectedDatabase = widget.initialDatabase;
        await _loadCollections(_selectedDatabase!);
        
        if (widget.initialCollection != null) {
          _selectedCollection = widget.initialCollection;
          await _navigateToPath(widget.initialPath ?? '');
        }
      } else if (_databases.isNotEmpty) {
        _selectedDatabase = _databases.first;
        await _loadCollections(_selectedDatabase!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = '初始化失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 加载数据库列表
  Future<void> _loadDatabases() async {
    _databases = await _importExportService.getAllDatabases();
    setState(() {});
  }

  /// 加载集合列表
  Future<void> _loadCollections(String databaseName) async {
    final collections = await _importExportService.getCollections(databaseName);
    _collections[databaseName] = collections;
    
    if (collections.isNotEmpty && _selectedCollection == null) {
      _selectedCollection = collections.first;
      await _navigateToPath('');
    }
    
    setState(() {});
  }

  /// 导航到指定路径
  Future<void> _navigateToPath(String path) async {
    if (_selectedDatabase == null || _selectedCollection == null) return;

    setState(() {
      _isLoading = true;
      _isSearchMode = false;
    });

    try {
      final fullPath = 'indexeddb://$_selectedDatabase/$_selectedCollection/$path';
      final files = await _vfsService.listFiles(_selectedCollection!, path.isEmpty ? null : path);
      
      setState(() {
        _currentFiles = files;
        _currentPath = path;
        _selectedFiles.clear();
        _lastSelectedFile = null;
      });
      
      // 更新历史记录
      _updateHistory(path);
      
      // 排序文件
      _sortFiles();
    } catch (e) {
      _showErrorSnackBar('加载文件失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 更新路径历史
  void _updateHistory(String path) {
    // 移除当前位置之后的历史
    if (_historyIndex < _pathHistory.length - 1) {
      _pathHistory.removeRange(_historyIndex + 1, _pathHistory.length);
    }
    
    // 添加新路径（如果与当前不同）
    if (_pathHistory.isEmpty || _pathHistory.last != path) {
      _pathHistory.add(path);
      _historyIndex = _pathHistory.length - 1;
    }
  }

  /// 排序文件
  void _sortFiles() {
    _currentFiles.sort((a, b) {
      // 目录优先
      if (a.isDirectory != b.isDirectory) {
        return a.isDirectory ? -1 : 1;
      }
      
      int result = 0;
      switch (_sortType) {
        case _SortType.name:
          result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case _SortType.size:
          result = a.size.compareTo(b.size);
          break;
        case _SortType.modified:
          result = a.modifiedAt.compareTo(b.modifiedAt);
          break;
        case _SortType.type:
          final aExt = a.name.split('.').last.toLowerCase();
          final bExt = b.name.split('.').last.toLowerCase();
          result = aExt.compareTo(bExt);
          break;
      }
      
      return _sortAscending ? result : -result;
    });
  }

  /// 搜索文件
  Future<void> _searchFiles(String query) async {
    if (_selectedDatabase == null || _selectedCollection == null) return;

    setState(() {
      _searchQuery = query;
      _isSearchMode = query.isNotEmpty;
      _isLoading = true;
    });

    if (query.isEmpty) {
      await _navigateToPath(_currentPath);
      return;
    }

    try {
      final results = await _vfsService.searchFiles(
        _selectedCollection!,
        '*$query*',
        caseSensitive: false,
        maxResults: 100,
      );
      
      setState(() {
        _searchResults = results;
        _selectedFiles.clear();
      });
    } catch (e) {
      _showErrorSnackBar('搜索失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 复制文件
  Future<void> _copyFiles(List<VfsFileInfo> files) async {
    setState(() {
      _clipboardFiles = List.from(files);
      _isCutOperation = false;
    });
    
    _showInfoSnackBar('已复制 ${files.length} 个项目');
  }

  /// 剪切文件
  Future<void> _cutFiles(List<VfsFileInfo> files) async {
    setState(() {
      _clipboardFiles = List.from(files);
      _isCutOperation = true;
    });
    
    _showInfoSnackBar('已剪切 ${files.length} 个项目');
  }

  /// 粘贴文件
  Future<void> _pasteFiles() async {
    if (_clipboardFiles.isEmpty || _selectedDatabase == null || _selectedCollection == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      for (final file in _clipboardFiles) {
        final sourcePath = file.path;
        final fileName = file.name;
        final targetPath = _currentPath.isEmpty ? fileName : '$_currentPath/$fileName';
        
        if (_isCutOperation) {
          // 移动文件
          await _vfsService.moveFile(
            _selectedCollection!,
            sourcePath.replaceFirst('indexeddb://$_selectedDatabase/$_selectedCollection/', ''),
            _selectedCollection!,
            targetPath,
          );
        } else {
          // 复制文件
          await _vfsService.copyFile(
            _selectedCollection!,
            sourcePath.replaceFirst('indexeddb://$_selectedDatabase/$_selectedCollection/', ''),
            _selectedCollection!,
            targetPath,
          );
        }
      }
      
      if (_isCutOperation) {
        _clipboardFiles.clear();
        _isCutOperation = false;
      }
      
      await _navigateToPath(_currentPath);
      _showInfoSnackBar('粘贴完成');
    } catch (e) {
      _showErrorSnackBar('粘贴失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 删除文件
  Future<void> _deleteFiles(List<VfsFileInfo> files) async {
    final confirmed = await _showConfirmDialog(
      '确认删除',
      '确定要删除选中的 ${files.length} 个项目吗？此操作不可撤销。',
    );
    
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      for (final file in files) {
        await _vfsService.deleteFile(
          _selectedCollection!,
          file.path.replaceFirst('indexeddb://$_selectedDatabase/$_selectedCollection/', ''),
        );
      }
      
      await _navigateToPath(_currentPath);
      _showInfoSnackBar('已删除 ${files.length} 个项目');
    } catch (e) {
      _showErrorSnackBar('删除失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  /// 重命名文件
  Future<void> _renameFile(VfsFileInfo file) async {
    final newName = await VfsFileRenameDialog.show(
      context,
      file,
    );
    
    if (newName == null || newName == file.name) return;

    setState(() {
      _isLoading = true;
    });    try {
      final oldPath = file.path.replaceFirst('indexeddb://$_selectedDatabase/$_selectedCollection/', '');
      final pathSegments = oldPath.split('/').toList();
      pathSegments[pathSegments.length - 1] = newName;
      final newPath = pathSegments.join('/');
      
      await _vfsService.moveFile(
        _selectedCollection!,
        oldPath,
        _selectedCollection!,
        newPath,
      );
      
      await _navigateToPath(_currentPath);
      _showInfoSnackBar('重命名成功');
    } catch (e) {
      _showErrorSnackBar('重命名失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 显示文件元数据
  Future<void> _showFileMetadata(VfsFileInfo file) async {
    await VfsFileMetadataDialog.show(context, file);
  }

  /// 创建新文件夹
  Future<void> _createNewFolder() async {
    final name = await _showTextInputDialog('新建文件夹', '文件夹名称');
    if (name == null || name.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final folderPath = _currentPath.isEmpty ? name.trim() : '$_currentPath/${name.trim()}';
      await _vfsService.createDirectory(_selectedCollection!, folderPath);
      await _navigateToPath(_currentPath);
      _showInfoSnackBar('文件夹创建成功');
    } catch (e) {
      _showErrorSnackBar('创建文件夹失败: $e');
      print('创建文件夹失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  /// 显示搜索对话框
  Future<void> _showSearchDialog() async {
    if (_selectedDatabase == null) {
      _showErrorSnackBar('请先选择数据库');
      return;
    }
    
    final query = await VfsFileSearchDialog.show(
      context,
      _vfsService,
      _selectedDatabase!,
      _selectedCollection!,
      _currentPath,
    );
    if (query != null) {
      _searchFiles(query);
    }
  }

  /// 导出选中文件
  Future<void> _exportSelectedFiles() async {
    // TODO: 实现文件导出功能
    _showInfoSnackBar('导出功能开发中...');
  }

  /// 导入文件
  Future<void> _importFiles() async {
    // TODO: 实现文件导入功能
    _showInfoSnackBar('导入功能开发中...');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildToolbar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFileBrowser(),
                    _buildMetadataView(),
                    _buildSettingsView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder_special,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'VFS 文件管理器',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            tooltip: '关闭',
          ),
        ],
      ),
    );
  }

  /// 构建工具栏
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          // 数据库和集合选择
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedDatabase,
                  hint: const Text('选择数据库'),
                  isExpanded: true,
                  items: _databases.map((db) {
                    return DropdownMenuItem(value: db, child: Text(db));
                  }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        _selectedDatabase = value;
                        _selectedCollection = null;
                      });
                      await _loadCollections(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCollection,
                  hint: const Text('选择集合'),
                  isExpanded: true,
                  items: _collections[_selectedDatabase]?.map((collection) {
                    return DropdownMenuItem(value: collection, child: Text(collection));
                  }).toList() ?? [],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        _selectedCollection = value;
                      });
                      await _navigateToPath('');
                    }
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 工具按钮和标签栏
          Row(
            children: [
              // 导航按钮
              Row(
                children: [
                  IconButton(
                    onPressed: _historyIndex > 0 ? () async {
                      _historyIndex--;
                      await _navigateToPath(_pathHistory[_historyIndex]);
                    } : null,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: '后退',
                  ),
                  IconButton(
                    onPressed: _historyIndex < _pathHistory.length - 1 ? () async {
                      _historyIndex++;
                      await _navigateToPath(_pathHistory[_historyIndex]);
                    } : null,
                    icon: const Icon(Icons.arrow_forward),
                    tooltip: '前进',
                  ),
                  IconButton(
                    onPressed: () => _navigateToPath(''),
                    icon: const Icon(Icons.home),
                    tooltip: '根目录',
                  ),
                ],
              ),
              
              const SizedBox(width: 8),
              
              // 操作按钮
              Row(
                children: [
                  IconButton(
                    onPressed: _createNewFolder,
                    icon: const Icon(Icons.create_new_folder),
                    tooltip: '新建文件夹',
                  ),
                  IconButton(
                    onPressed: _showSearchDialog,
                    icon: const Icon(Icons.search),
                    tooltip: '搜索',
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    tooltip: '排序',
                    onSelected: (value) {
                      setState(() {
                        if (value == _sortType.name) {
                          _sortAscending = !_sortAscending;
                        } else {
                          _sortType = _SortType.values.firstWhere((e) => e.name == value);
                          _sortAscending = true;
                        }
                      });
                      _sortFiles();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'name',
                        child: Row(
                          children: [
                            Icon(_sortType == _SortType.name 
                              ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                              : Icons.sort_by_alpha),
                            const SizedBox(width: 8),
                            const Text('按名称'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'size',
                        child: Row(
                          children: [
                            Icon(_sortType == _SortType.size
                              ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                              : Icons.data_usage),
                            const SizedBox(width: 8),
                            const Text('按大小'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'modified',
                        child: Row(
                          children: [
                            Icon(_sortType == _SortType.modified
                              ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                              : Icons.access_time),
                            const SizedBox(width: 8),
                            const Text('按修改时间'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'type',
                        child: Row(
                          children: [
                            Icon(_sortType == _SortType.type
                              ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                              : Icons.category),
                            const SizedBox(width: 8),
                            const Text('按类型'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<_ViewType>(
                    icon: Icon(_viewType == _ViewType.list ? Icons.view_list : Icons.grid_view),
                    tooltip: '视图',
                    onSelected: (value) {
                      setState(() {
                        _viewType = value;
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _ViewType.list,
                        child: const Row(
                          children: [
                            Icon(Icons.view_list),
                            SizedBox(width: 8),
                            Text('列表视图'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _ViewType.grid,
                        child: const Row(
                          children: [
                            Icon(Icons.grid_view),
                            SizedBox(width: 8),
                            Text('网格视图'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_clipboardFiles.isNotEmpty) ...[
                    IconButton(
                      onPressed: _pasteFiles,
                      icon: const Icon(Icons.paste),
                      tooltip: '粘贴',
                    ),
                  ],
                ],
              ),
              
              const Spacer(),
              
              // 标签栏
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(icon: Icon(Icons.folder), text: '文件浏览'),
                  Tab(icon: Icon(Icons.info), text: '元数据'),
                  Tab(icon: Icon(Icons.settings), text: '设置'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建文件浏览器
  Widget _buildFileBrowser() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeFileManager,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final filesToShow = _isSearchMode ? _searchResults : _currentFiles;
    
    if (filesToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSearchMode ? Icons.search_off : Icons.folder_open,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _isSearchMode ? '未找到匹配的文件' : '此文件夹为空',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 路径导航
        if (!_isSearchMode) _buildPathNavigation(),
        
        // 文件列表
        Expanded(
          child: _viewType == _ViewType.list
            ? _buildFileList(filesToShow)
            : _buildFileGrid(filesToShow),
        ),
      ],
    );
  }

  /// 构建路径导航
  Widget _buildPathNavigation() {
    final pathSegments = _currentPath.split('/').where((s) => s.isNotEmpty).toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToPath(''),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _currentPath.isEmpty 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.home, size: 16),
                  const SizedBox(width: 4),
                  Text(_selectedCollection ?? 'Root'),
                ],
              ),
            ),
          ),
          
          for (int i = 0; i < pathSegments.length; i++) ...[
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            GestureDetector(
              onTap: () {
                final path = pathSegments.take(i + 1).join('/');
                _navigateToPath(path);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: i == pathSegments.length - 1
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(pathSegments[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建文件列表视图
  Widget _buildFileList(List<VfsFileInfo> files) {
    return WebContextMenuHandler(
      child: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          final isSelected = _selectedFiles.contains(file.path);
          
          return ContextMenuWrapper(
            menuBuilder: (context) => _buildFileContextMenu(file),
            child: ListTile(
              selected: isSelected,
              leading: Icon(
                file.isDirectory ? Icons.folder : _getFileIcon(file),
                color: file.isDirectory ? Colors.amber : null,
              ),
              title: Text(file.name),
              subtitle: Text(
                '${_formatFileSize(file.size)} • ${_formatDateTime(file.modifiedAt)}',
              ),
              trailing: _selectedFiles.isNotEmpty
                ? Checkbox(
                    value: isSelected,
                    onChanged: (value) => _toggleFileSelection(file),
                  )
                : null,
              onTap: () {
                if (_selectedFiles.isNotEmpty) {
                  _toggleFileSelection(file);
                } else if (file.isDirectory) {
                  final newPath = _currentPath.isEmpty 
                    ? file.name 
                    : '$_currentPath/${file.name}';
                  _navigateToPath(newPath);
                } else {
                  _showFileMetadata(file);
                }
              },
              onLongPress: () => _toggleFileSelection(file),
            ),
          );
        },
      ),
    );
  }

  /// 构建文件网格视图
  Widget _buildFileGrid(List<VfsFileInfo> files) {
    return WebContextMenuHandler(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          final isSelected = _selectedFiles.contains(file.path);
          
          return ContextMenuWrapper(
            menuBuilder: (context) => _buildFileContextMenu(file),
            child: GestureDetector(
              onTap: () {
                if (_selectedFiles.isNotEmpty) {
                  _toggleFileSelection(file);
                } else if (file.isDirectory) {
                  final newPath = _currentPath.isEmpty 
                    ? file.name 
                    : '$_currentPath/${file.name}';
                  _navigateToPath(newPath);
                } else {
                  _showFileMetadata(file);
                }
              },
              onLongPress: () => _toggleFileSelection(file),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      file.isDirectory ? Icons.folder : _getFileIcon(file),
                      size: 48,
                      color: file.isDirectory ? Colors.amber : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      file.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (!file.isDirectory) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatFileSize(file.size),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建文件上下文菜单
  List<ContextMenuItem> _buildFileContextMenu(VfsFileInfo file) {
    return [
      if (file.isDirectory)
        ContextMenuItem(
          label: '打开',
          icon: Icons.folder_open,
          onTap: () {
            final newPath = _currentPath.isEmpty 
              ? file.name 
              : '$_currentPath/${file.name}';
            _navigateToPath(newPath);
          },
        )
      else
        ContextMenuItem(
          label: '查看详情',
          icon: Icons.info,
          onTap: () => _showFileMetadata(file),
        ),
      
      const ContextMenuItem.divider(),
      
      ContextMenuItem(
        label: '复制',
        icon: Icons.copy,
        onTap: () => _copyFiles([file]),
      ),
      ContextMenuItem(
        label: '剪切',
        icon: Icons.cut,
        onTap: () => _cutFiles([file]),
      ),
      if (_clipboardFiles.isNotEmpty)
        ContextMenuItem(
          label: '粘贴',
          icon: Icons.paste,
          onTap: _pasteFiles,
        ),
      
      const ContextMenuItem.divider(),
      
      ContextMenuItem(
        label: '重命名',
        icon: Icons.edit,
        onTap: () => _renameFile(file),
      ),
      ContextMenuItem(
        label: '删除',
        icon: Icons.delete,
        onTap: () => _deleteFiles([file]),
      ),
    ];
  }

  /// 构建元数据视图
  Widget _buildMetadataView() {
    if (_lastSelectedFile == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('选择文件以查看元数据', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final file = _lastSelectedFile!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        file.isDirectory ? Icons.folder : _getFileIcon(file),
                        size: 32,
                        color: file.isDirectory ? Colors.amber : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              file.path,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(),
                  
                  _buildMetadataRow('类型', file.isDirectory ? '文件夹' : '文件'),
                  _buildMetadataRow('大小', _formatFileSize(file.size)),
                  _buildMetadataRow('创建时间', _formatDateTime(file.createdAt)),
                  _buildMetadataRow('修改时间', _formatDateTime(file.modifiedAt)),
                  
                  if (file.mimeType != null)
                    _buildMetadataRow('MIME类型', file.mimeType!),
                  
                  if (file.metadata != null && file.metadata!.isNotEmpty) ...[
                    const Divider(),
                    Text(
                      '自定义元数据',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final entry in file.metadata!.entries)
                      _buildMetadataRow(entry.key, entry.value.toString()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建元数据行
  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// 构建设置视图
  Widget _buildSettingsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '导入/导出',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _importFiles,
                          icon: const Icon(Icons.upload),
                          label: const Text('导入文件'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _exportSelectedFiles,
                          icon: const Icon(Icons.download),
                          label: const Text('导出选中'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '存储信息',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  if (_selectedDatabase != null && _selectedCollection != null) ...[
                    _buildMetadataRow('数据库', _selectedDatabase!),
                    _buildMetadataRow('集合', _selectedCollection!),
                    _buildMetadataRow('文件总数', _currentFiles.length.toString()),
                    _buildMetadataRow('选中数量', _selectedFiles.length.toString()),
                  ] else
                    const Text('请选择数据库和集合'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 切换文件选择状态
  void _toggleFileSelection(VfsFileInfo file) {
    setState(() {
      if (_selectedFiles.contains(file.path)) {
        _selectedFiles.remove(file.path);
      } else {
        _selectedFiles.add(file.path);
      }
      _lastSelectedFile = file;
    });
  }

  /// 获取文件图标
  IconData _getFileIcon(VfsFileInfo file) {
    if (file.isDirectory) return Icons.folder;
    
    final extension = file.name.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'json':
        return Icons.code;
      case 'txt':
      case 'md':
        return Icons.text_snippet;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 显示确认对话框
  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// 显示文本输入对话框
  Future<String?> _showTextInputDialog(String title, String hint) async {
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    return result;
  }

  /// 显示成功消息
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 显示错误消息
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// 排序类型枚举
enum _SortType { name, size, modified, type }

/// 视图类型枚举
enum _ViewType { list, grid }
