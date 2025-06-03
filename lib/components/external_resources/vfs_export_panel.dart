import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/virtual_file_system/vfs_import_export_service.dart';

/// VFS导出面板
/// 提供虚拟文件系统数据导出功能
class VfsExportPanel extends StatefulWidget {
  const VfsExportPanel({super.key});

  @override
  State<VfsExportPanel> createState() => _VfsExportPanelState();
}

class _VfsExportPanelState extends State<VfsExportPanel> {
  final VfsImportExportService _importExportService = VfsImportExportService();
  
  String? _outputPath;
  bool _isExporting = false;
  bool _includeMetadata = true;
  bool _includeFileContent = true;
  bool _compressOutput = false;
  
  Set<String> _selectedDatabases = {};
  Set<String> _selectedCollections = {};
  List<String> _availableDatabases = [];
  Map<String, List<String>> _databaseCollections = {};
  
  VfsExportPreview? _exportPreview;
  String? _exportStatus;

  @override
  void initState() {
    super.initState();
    _loadAvailableDatabases();
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
          _buildDatabaseSelector(),
          const SizedBox(height: 16),
          _buildExportOptions(),
          const SizedBox(height: 16),
          _buildOutputSelector(),
          if (_exportPreview != null) ...[
            const SizedBox(height: 16),
            _buildPreview(),
          ],
          const SizedBox(height: 16),
          _buildExportButton(),
          if (_exportStatus != null) ...[
            const SizedBox(height: 16),
            _buildStatusMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.cloud_download, size: 32, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VFS数据导出',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '将虚拟文件系统数据导出为JSON文件',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatabaseSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择要导出的数据',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_availableDatabases.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('没有可用的VFS数据库'),
                  ],
                ),
              )
            else ...[
              CheckboxListTile(
                title: const Text('全选数据库'),
                value: _selectedDatabases.length == _availableDatabases.length,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedDatabases = Set.from(_availableDatabases);
                    } else {
                      _selectedDatabases.clear();
                    }
                    _selectedCollections.clear();
                    _updatePreview();
                  });
                },
              ),
              const Divider(),
              ..._availableDatabases.map((dbName) {
                final isSelected = _selectedDatabases.contains(dbName);
                final collections = _databaseCollections[dbName] ?? [];
                
                return ExpansionTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedDatabases.add(dbName);
                        } else {
                          _selectedDatabases.remove(dbName);
                          // 移除该数据库下的所有集合选择
                          _selectedCollections.removeWhere(
                            (coll) => coll.startsWith('$dbName/'),
                          );
                        }
                        _updatePreview();
                      });
                    },
                  ),
                  title: Text(dbName),
                  subtitle: Text('${collections.length} 个集合'),
                  children: collections.map((collName) {
                    final collKey = '$dbName/$collName';
                    return CheckboxListTile(
                      title: Text(collName),
                      value: isSelected || _selectedCollections.contains(collKey),
                      onChanged: isSelected ? null : (value) {
                        setState(() {
                          if (value == true) {
                            _selectedCollections.add(collKey);
                          } else {
                            _selectedCollections.remove(collKey);
                          }
                          _updatePreview();
                        });
                      },
                    );
                  }).toList(),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '导出选项',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('包含元数据'),
              subtitle: const Text('导出数据库和集合的元数据信息'),
              value: _includeMetadata,
              onChanged: (value) {
                setState(() {
                  _includeMetadata = value ?? true;
                  _updatePreview();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('包含文件内容'),
              subtitle: const Text('导出文件的实际内容（将增加文件大小）'),
              value: _includeFileContent,
              onChanged: (value) {
                setState(() {
                  _includeFileContent = value ?? true;
                  _updatePreview();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('压缩输出'),
              subtitle: const Text('压缩导出文件以减小文件大小'),
              value: _compressOutput,
              onChanged: (value) {
                setState(() {
                  _compressOutput = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '输出位置',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _outputPath ?? '未选择输出位置',
                      style: TextStyle(
                        color: _outputPath != null ? null : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _selectOutputPath,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('选择位置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '导出预览',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreviewItem('数据库数量', '${_exportPreview!.databases.length}'),
                  _buildPreviewItem('总文件数', '${_exportPreview!.totalFiles}'),
                  _buildPreviewItem(
                    '预估大小',
                    _formatFileSize(_exportPreview!.totalSize),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '数据库详情:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...(_exportPreview!.databases.entries.map((entry) {
                    final dbName = entry.key;
                    final dbPreview = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$dbName:',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          _buildPreviewItem(
                            '  集合数量',
                            '${dbPreview.collections.length}',
                          ),
                          _buildPreviewItem(
                            '  文件数量',
                            '${dbPreview.totalFiles}',
                          ),
                          _buildPreviewItem(
                            '  大小',
                            _formatFileSize(dbPreview.totalSize),
                          ),
                        ],
                      ),
                    );
                  })),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canExport() ? _performExport : null,
        icon: _isExporting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_download),
        label: Text(_isExporting ? '导出中...' : '开始导出'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    final isError = _exportStatus!.contains('错误') || _exportStatus!.contains('失败');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red[50] : Colors.green[50],
        border: Border.all(
          color: isError ? Colors.red[300]! : Colors.green[300]!,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error : Icons.check_circle,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _exportStatus!,
              style: TextStyle(
                color: isError ? Colors.red[700] : Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canExport() {
    return _outputPath != null && 
           !_isExporting && 
           (_selectedDatabases.isNotEmpty || _selectedCollections.isNotEmpty);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _loadAvailableDatabases() async {
    try {
      final databases = await _importExportService.getAllDatabases();
      final collections = <String, List<String>>{};
      
      for (final dbName in databases) {
        final dbCollections = await _importExportService.getCollections(dbName);
        collections[dbName] = dbCollections;
      }
      
      setState(() {
        _availableDatabases = databases;
        _databaseCollections = collections;
      });
    } catch (e) {
      setState(() {
        _exportStatus = '加载数据库列表失败: $e';
      });
    }
  }

  Future<void> _selectOutputPath() async {
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: '选择导出位置',
        fileName: 'vfs_export_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (path != null) {
        setState(() {
          _outputPath = path;
        });
      }
    } catch (e) {
      setState(() {
        _exportStatus = '选择输出位置时出错: $e';
      });
    }
  }

  Future<void> _updatePreview() async {
    if (_selectedDatabases.isEmpty && _selectedCollections.isEmpty) {
      setState(() {
        _exportPreview = null;
      });
      return;
    }

    try {
      final options = VfsExportOptions(
        includeDatabases: _selectedDatabases.isEmpty ? null : _selectedDatabases,
        includeCollections: _selectedCollections.isEmpty ? null : _selectedCollections,
        includeMetadata: _includeMetadata,
        includeFileContent: _includeFileContent,
        compressOutput: _compressOutput,
      );

      final preview = await _importExportService.getExportPreview(options: options);
      
      setState(() {
        _exportPreview = preview;
      });
    } catch (e) {
      setState(() {
        _exportStatus = '生成预览失败: $e';
      });
    }
  }

  Future<void> _performExport() async {
    if (_outputPath == null) return;

    setState(() {
      _isExporting = true;
      _exportStatus = '正在导出数据...';
    });

    try {
      final options = VfsExportOptions(
        includeDatabases: _selectedDatabases.isEmpty ? null : _selectedDatabases,
        includeCollections: _selectedCollections.isEmpty ? null : _selectedCollections,
        includeMetadata: _includeMetadata,
        includeFileContent: _includeFileContent,
        compressOutput: _compressOutput,
      );

      final result = await _importExportService.exportToFile(
        outputPath: _outputPath!,
        options: options,
      );

      if (result != null) {
        setState(() {
          _exportStatus = '导出完成！文件保存至: $result';
        });
      } else {
        setState(() {
          _exportStatus = '导出失败：未知错误';
        });
      }
    } catch (e) {
      setState(() {
        _exportStatus = '导出失败: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }
}
