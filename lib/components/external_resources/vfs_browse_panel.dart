import 'package:flutter/material.dart';
import '../../services/virtual_file_system/vfs_storage_service.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';

/// VFS浏览面板
/// 提供虚拟文件系统内容浏览功能
class VfsBrowsePanel extends StatefulWidget {
  const VfsBrowsePanel({super.key});

  @override
  State<VfsBrowsePanel> createState() => _VfsBrowsePanelState();
}

class _VfsBrowsePanelState extends State<VfsBrowsePanel> {
  final VfsStorageService _storageService = VfsStorageService();
  
  List<String> _databases = [];
  String? _selectedDatabase;
  List<String> _collections = [];
  String? _selectedCollection;
  List<VfsFileInfo> _files = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  String _currentPath = '';

  @override
  void initState() {
    super.initState();
    _loadDatabases();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildNavigationBar(),
          const SizedBox(height: 16),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.folder_open, size: 32, color: Colors.orange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VFS数据浏览',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '浏览虚拟文件系统中的数据',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '导航',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // 数据库选择器
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '数据库',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedDatabase,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _databases.map((db) {
                          return DropdownMenuItem(
                            value: db,
                            child: Text(db),
                          );
                        }).toList(),
                        onChanged: _onDatabaseChanged,
                        hint: const Text('选择数据库'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 集合选择器
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '集合',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedCollection,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _collections.map((coll) {
                          return DropdownMenuItem(
                            value: coll,
                            child: Text(coll),
                          );
                        }).toList(),
                        onChanged: _onCollectionChanged,
                        hint: const Text('选择集合'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 刷新按钮
                ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('刷新'),
                ),
              ],
            ),
            if (_currentPath.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _currentPath,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return _buildErrorMessage();
    }
    
    if (_selectedDatabase == null) {
      return _buildPlaceholder(
        icon: Icons.storage,
        title: '选择数据库',
        subtitle: '请先选择一个数据库以查看其内容',
      );
    }
    
    if (_selectedCollection == null) {
      return _buildPlaceholder(
        icon: Icons.folder,
        title: '选择集合',
        subtitle: '请选择一个集合以查看其文件',
      );
    }
    
    if (_files.isEmpty) {
      return _buildPlaceholder(
        icon: Icons.folder_open,
        title: '空集合',
        subtitle: '此集合中没有文件',
      );
    }
    
    return _buildFileList();
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '文件列表',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_files.length} 个项目',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                return _buildFileListItem(file);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileListItem(VfsFileInfo file) {
    return ListTile(
      leading: Icon(
        file.isDirectory ? Icons.folder : Icons.insert_drive_file,
        color: file.isDirectory ? Colors.blue : Colors.grey[600],
      ),
      title: Text(file.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(file.path),
          Row(
            children: [
              Text(
                _formatFileSize(file.size),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _formatDateTime(file.modifiedAt),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              if (file.mimeType != null) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    file.mimeType!,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'info',
            child: Row(
              children: [
                Icon(Icons.info),
                SizedBox(width: 8),
                Text('详细信息'),
              ],
            ),
          ),
          if (!file.isDirectory)
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('下载'),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('删除', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        onSelected: (value) => _handleFileAction(value, file),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadDatabases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final databases = await _storageService.getAllDatabases();
      setState(() {
        _databases = databases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载数据库列表失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onDatabaseChanged(String? database) async {
    if (database == null) return;

    setState(() {
      _selectedDatabase = database;
      _selectedCollection = null;
      _collections = [];
      _files = [];
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final collections = await _storageService.getCollections(database);
      setState(() {
        _collections = collections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载集合列表失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onCollectionChanged(String? collection) async {
    if (collection == null || _selectedDatabase == null) return;

    setState(() {
      _selectedCollection = collection;
      _files = [];
      _isLoading = true;
      _errorMessage = null;
      _currentPath = 'vfs://$_selectedDatabase/$collection/';
    });

    try {
      final files = await _storageService.listDirectory(
        'vfs://$_selectedDatabase/$collection/',
      );
      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载文件列表失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    if (_selectedDatabase != null && _selectedCollection != null) {
      await _onCollectionChanged(_selectedCollection);
    } else if (_selectedDatabase != null) {
      await _onDatabaseChanged(_selectedDatabase);
    } else {
      await _loadDatabases();
    }
  }

  void _handleFileAction(String action, VfsFileInfo file) {
    switch (action) {
      case 'info':
        _showFileInfo(file);
        break;
      case 'download':
        _downloadFile(file);
        break;
      case 'delete':
        _confirmDelete(file);
        break;
    }
  }

  void _showFileInfo(VfsFileInfo file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('路径', file.path),
            _buildInfoRow('类型', file.isDirectory ? '目录' : '文件'),
            _buildInfoRow('大小', _formatFileSize(file.size)),
            _buildInfoRow('创建时间', _formatDateTime(file.createdAt)),
            _buildInfoRow('修改时间', _formatDateTime(file.modifiedAt)),
            if (file.mimeType != null)
              _buildInfoRow('MIME类型', file.mimeType!),
            if (file.metadata != null && file.metadata!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('元数据:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...file.metadata!.entries.map((entry) =>
                _buildInfoRow(entry.key, entry.value.toString())),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _downloadFile(VfsFileInfo file) {
    // TODO: 实现文件下载功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('文件下载功能即将推出'),
      ),
    );
  }

  void _confirmDelete(VfsFileInfo file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${file.name}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteFile(file);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(VfsFileInfo file) async {
    try {
      final filePath = 'vfs://$_selectedDatabase/$_selectedCollection${file.path}';
      await _storageService.delete(filePath, recursive: file.isDirectory);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已删除 "${file.name}"'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 刷新文件列表
      if (mounted) {
        await _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
