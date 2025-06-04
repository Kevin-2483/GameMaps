import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/virtual_file_system/vfs_import_export_service.dart';

/// VFS导入面板
/// 提供虚拟文件系统数据导入功能
class VfsImportPanel extends StatefulWidget {
  const VfsImportPanel({super.key});

  @override
  State<VfsImportPanel> createState() => _VfsImportPanelState();
}

class _VfsImportPanelState extends State<VfsImportPanel> {
  final VfsImportExportService _importExportService = VfsImportExportService();

  String? _selectedFilePath;
  bool _isImporting = false;
  bool _overwriteExisting = false;
  bool _mergeMetadata = true;
  bool _skipErrors = true;
  VfsExportData? _previewData;
  String? _importStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFileSelector(),
          const SizedBox(height: 16),
          _buildImportOptions(),
          if (_previewData != null) ...[
            const SizedBox(height: 16),
            _buildPreview(),
          ],
          const SizedBox(height: 16),
          _buildImportButton(),
          if (_importStatus != null) ...[
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
        const Icon(Icons.cloud_upload, size: 32, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VFS数据导入',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '从JSON文件导入虚拟文件系统数据',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择导入文件',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                      _selectedFilePath ?? '未选择文件',
                      style: TextStyle(
                        color: _selectedFilePath != null
                            ? null
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _selectFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('选择文件'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '导入选项',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('覆盖现有文件'),
              subtitle: const Text('如果文件已存在，将覆盖原有文件'),
              value: _overwriteExisting,
              onChanged: (value) {
                setState(() {
                  _overwriteExisting = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('合并元数据'),
              subtitle: const Text('将导入的元数据与现有元数据合并'),
              value: _mergeMetadata,
              onChanged: (value) {
                setState(() {
                  _mergeMetadata = value ?? true;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('跳过错误'),
              subtitle: const Text('遇到错误时继续导入其他数据'),
              value: _skipErrors,
              onChanged: (value) {
                setState(() {
                  _skipErrors = value ?? true;
                });
              },
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
              '导入预览',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  _buildPreviewItem('导出版本', _previewData!.version),
                  _buildPreviewItem(
                    '导出时间',
                    _previewData!.exportedAt.toLocal().toString(),
                  ),
                  _buildPreviewItem(
                    '数据库数量',
                    '${_previewData!.databases.length}',
                  ),
                  const SizedBox(height: 8),
                  ...(_previewData!.databases.entries.map((entry) {
                    final dbName = entry.key;
                    final dbData = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '数据库: $dbName',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _buildPreviewItem(
                            '  集合数量',
                            '${dbData.collections.length}',
                          ),
                          ...dbData.collections.entries.map((collEntry) {
                            final collName = collEntry.key;
                            final collData = collEntry.value;
                            return _buildPreviewItem(
                              '    $collName',
                              '${collData.files.length} 个文件',
                            );
                          }),
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
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildImportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canImport() ? _performImport : null,
        icon: _isImporting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_upload),
        label: Text(_isImporting ? '导入中...' : '开始导入'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    final isError =
        _importStatus!.contains('错误') || _importStatus!.contains('失败');
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
              _importStatus!,
              style: TextStyle(
                color: isError ? Colors.red[700] : Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canImport() {
    return _selectedFilePath != null && !_isImporting && _previewData != null;
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: '选择VFS导入文件',
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _previewData = null;
          _importStatus = null;
        });

        await _loadPreview();
      }
    } catch (e) {
      setState(() {
        _importStatus = '选择文件时出错: $e';
      });
    }
  }

  Future<void> _loadPreview() async {
    if (_selectedFilePath == null) return;

    try {
      setState(() {
        _importStatus = '正在加载预览...';
      });
      final file = File(_selectedFilePath!);
      final content = await file.readAsString();
      final json = Map<String, dynamic>.from(jsonDecode(content));

      final exportData = VfsExportData.fromJson(json);

      setState(() {
        _previewData = exportData;
        _importStatus = null;
      });
    } catch (e) {
      setState(() {
        _previewData = null;
        _importStatus = '加载预览失败: $e';
      });
    }
  }

  Future<void> _performImport() async {
    if (_selectedFilePath == null || _previewData == null) return;

    setState(() {
      _isImporting = true;
      _importStatus = '正在导入数据...';
    });

    try {
      final options = VfsImportOptions(
        overwriteExisting: _overwriteExisting,
        mergeMetadata: _mergeMetadata,
        skipErrors: _skipErrors,
      );

      await _importExportService.importData(_previewData!, options: options);

      setState(() {
        _importStatus = '导入完成！';
      });
    } catch (e) {
      setState(() {
        _importStatus = '导入失败: $e';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }
}
