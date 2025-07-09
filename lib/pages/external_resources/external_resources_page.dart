import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
// import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import '../../components/layout/main_layout.dart';
import '../../components/common/draggable_title_bar.dart';
import '../../services/virtual_file_system/vfs_service_provider.dart';
import '../../services/work_status_service.dart';
import '../../services/notification/notification_service.dart';

import '../../l10n/app_localizations.dart';
import '../../components/vfs/vfs_file_picker_window.dart';

class ExternalResourcesPage extends BasePage {
  const ExternalResourcesPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _ExternalResourcesPageContent();
  }
}

class _ExternalResourcesPageContent extends StatefulWidget {
  const _ExternalResourcesPageContent();

  @override
  State<_ExternalResourcesPageContent> createState() =>
      _ExternalResourcesPageContentState();
}

class FileMapping {
  final String sourceFile;
  String targetPath;
  final String fileName;
  late final TextEditingController controller;
  bool isValidPath; // 标记路径是否有效

  FileMapping({
    required this.sourceFile,
    required this.targetPath,
    required this.fileName,
    this.isValidPath = true, // 默认为有效
  }) {
    controller = TextEditingController(text: targetPath);
  }

  void dispose() {
    controller.dispose();
  }

  void updateTargetPath(String newPath) {
    targetPath = newPath;
    controller.text = newPath;
  }
}

class _ExternalResourcesPageContentState
    extends State<_ExternalResourcesPageContent> {
  final VfsServiceProvider _vfsService = VfsServiceProvider();
  bool _isUploading = false;

  // 预览状态
  bool _showPreview = false;
  final List<FileMapping> _fileMappings = [];
  String _tempPath = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          DraggableTitleBar(title: '外部资源管理', icon: Icons.cloud_sync),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_showPreview) _buildUpdateSection(context, l10n),
                    if (!_showPreview) const SizedBox(height: 24),
                    if (!_showPreview) _buildInstructionsSection(context),
                    if (_showPreview) _buildPreviewSection(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '文件映射预览',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _cancelPreview,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isUploading ? null : _confirmAndProcess,
                  style: ElevatedButton.styleFrom(
                    elevation: _isUploading ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: _isUploading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '处理中...',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        )
                      : const Text(
                          '确认并处理',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '请检查并修改文件的目标路径。您可以直接编辑路径或点击文件夹图标选择目标位置。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400, // 设置固定高度以支持滚动
              child: _buildFileMappingTable(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileMappingTable(BuildContext context) {
    return Container(
      width: double.infinity, // 占满父组件宽度
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16,
          headingRowHeight: 56,
          dataRowHeight: 72,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          columns: [
            DataColumn(
              label: SizedBox(
                width: 150, // 调整源文件列宽度
                child: Text(
                  '源文件',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 300, // 设置目标路径列的固定宽度
                child: Text(
                  '目标路径',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 60, // 调整操作列宽度
                child: Text(
                  '操作',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          rows: _fileMappings.map((mapping) {
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 150, // 与列标题宽度保持一致
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mapping.fileName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '源文件',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 300, // 与列标题宽度保持一致
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: mapping.controller,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                hintText: 'indexeddb://r6box/...',
                                hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                              onChanged: (value) {
                                mapping.targetPath = value;
                                mapping.isValidPath = _isValidTargetPath(value);
                                setState(() {}); // 触发UI更新
                              },
                              onFieldSubmitted: (value) {
                                setState(() {
                                  mapping.targetPath = value;
                                  mapping.isValidPath = _isValidTargetPath(
                                    value,
                                  );
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (mapping.targetPath.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _isValidTargetPath(mapping.targetPath)
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                _isValidTargetPath(mapping.targetPath)
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _isValidTargetPath(mapping.targetPath)
                                    ? Colors.green
                                    : Colors.red,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 60, // 与列标题宽度保持一致
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.folder_open),
                          tooltip: '选择目标文件夹',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () => _selectTargetPath(mapping),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _cancelPreview() async {
    // 清理工作状态
    WorkStatusService().stopWorking(taskId: 'upload_external_resources');

    // 清理临时文件
    if (_tempPath.isNotEmpty) {
      try {
        await _cleanupTempFiles(_tempPath);
      } catch (e) {
        debugPrint('清理临时文件失败：$e');
      }
    }

    setState(() {
      _showPreview = false;
      // 清理controllers
      for (final mapping in _fileMappings) {
        mapping.dispose();
      }
      _fileMappings.clear();
      _tempPath = '';
    });
  }

  void _confirmAndProcess() async {
    // 检查是否所有路径都有效
    final invalidMappings = _fileMappings
        .where((mapping) => !mapping.isValidPath)
        .toList();
    if (invalidMappings.isNotEmpty) {
      _showErrorSnackBar('存在无效路径，请修正后再试。无效路径数量：${invalidMappings.length}');
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });

      // 更新工作状态描述
      WorkStatusService().updateWorkDescription('正在验证文件路径...');

      // 再次检查路径合法性（防止用户手动修改后未更新isValidPath）
      for (final mapping in _fileMappings) {
        final isValid = _isValidTargetPath(mapping.targetPath);
        mapping.isValidPath = isValid;
        if (!isValid) {
          throw Exception('目标路径不合法：${mapping.targetPath}');
        }
      }

      // 更新工作状态描述
      WorkStatusService().updateWorkDescription('正在检查文件冲突...');

      // 检查文件冲突
      final conflicts = await _checkFileConflicts();
      if (conflicts.isNotEmpty) {
        final shouldContinue = await _showConflictDialog(conflicts);
        if (!shouldContinue) {
          setState(() {
            _isUploading = false;
          });
          return;
        }
      }

      // 更新工作状态描述
      WorkStatusService().updateWorkDescription('正在复制文件到目标位置...');

      // 处理文件映射
      for (final mapping in _fileMappings) {
        // 确保目标目录存在
        final targetDir = mapping.targetPath.substring(
          0,
          mapping.targetPath.lastIndexOf('/'),
        );

        // 从完整路径中提取集合和相对路径部分用于创建目录
        String collection = 'fs';
        String relativePath = '';

        if (targetDir.startsWith('indexeddb://r6box/')) {
          // 提取集合名称和路径部分
          final pathParts = targetDir
              .substring('indexeddb://r6box/'.length)
              .split('/');
          if (pathParts.isNotEmpty) {
            collection = pathParts[0]; // 第一部分是集合名
            if (pathParts.length >= 2) {
              // 跳过数据库名和集合名，获取实际的目录路径
              relativePath = pathParts.sublist(1).join('/');
            }
          }
        } else {
          relativePath = targetDir;
        }

        if (relativePath.isNotEmpty) {
          await _vfsService.createDirectory(collection, relativePath);
        }

        // 复制文件
        await _copyFileToTarget(mapping.sourceFile, mapping.targetPath);
      }

      // 更新工作状态描述
      WorkStatusService().updateWorkDescription('正在清理临时文件...');

      // 清理临时文件
      await _cleanupTempFiles(_tempPath);

      // 清理工作状态
      WorkStatusService().stopWorking(taskId: 'upload_external_resources');

      _showSuccessSnackBar('外部资源更新成功');
      _cancelPreview();
    } catch (e) {
      // 发生错误时清理工作状态
      WorkStatusService().stopWorking(taskId: 'upload_external_resources');
      _showErrorSnackBar('更新失败：$e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<List<String>> _checkFileConflicts() async {
    final conflicts = <String>[];

    for (final mapping in _fileMappings) {
      // 直接使用绝对路径（已经是 indexeddb://r6box/fs/ 格式）
      final exists = await _vfsService.vfs.exists(mapping.targetPath);
      if (exists) {
        conflicts.add(mapping.targetPath);
      }
    }

    return conflicts;
  }

  Future<bool> _showConflictDialog(List<String> conflicts) async {
    bool isProcessing = false;

    return await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text('文件冲突'),
              content: SizedBox(
                width: 500,
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('以下文件已存在，是否覆盖？'),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: conflicts
                              .map(
                                (path) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    '• $path',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () {
                          setState(() {
                            isProcessing = true;
                          });
                          Navigator.of(context).pop(true);
                        },
                  child: isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('覆盖'),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _selectTargetPath(FileMapping mapping) async {
    try {
      final result = await VfsFileManagerWindow.showPathPicker(
        context,
        title: '选择目标文件夹',
        initialDatabase: 'r6box',
        initialCollection: 'fs',
        initialPath: '',
        allowDirectorySelection: true,
        selectionType: SelectionType.directoriesOnly,
      );

      if (result != null) {
        // VfsFileManagerWindow 返回的已经是完整的 indexeddb:// 路径
        String folderPath = result;

        // 拼接文件名形成完整路径
        final fullPath = '$folderPath/${mapping.fileName}';

        setState(() {
          mapping.updateTargetPath(fullPath);
          mapping.isValidPath = _isValidTargetPath(fullPath);
        });
      }
    } catch (e) {
      _showErrorSnackBar('选择路径失败：$e');
    }
  }

  Widget _buildUpdateSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_upload,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '更新外部资源',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: SizedBox(
                width: double.infinity, // 占满父组件宽度
                child: Text(
                  '上传包含外部资源的ZIP文件，系统将自动解压并根据元数据文件将资源复制到指定位置。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _handleUpdateExternalResources,
                style: ElevatedButton.styleFrom(
                  elevation: _isUploading ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.upload_file, size: 20),
                label: Text(
                  _isUploading ? '正在处理...' : '选择并上传ZIP文件',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '使用说明',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInstructionItem(
              context,
              '1',
              'ZIP文件结构',
              'ZIP文件应包含一个metadata.json文件，用于指定资源的目标位置',
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(context, '2', '元数据格式', 'metadata.json格式示例：'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '{\n'
                '  "name": "测试资源包",\n'
                '  "version": "1.0.0",\n'
                '  "description": "用于测试外部资源上传功能的示例资源包",\n'
                '  "author": "测试用户",\n'
                '  "created_at": "2024-01-15",\n'
                '  "file_mappings": {\n'
                '    "logo.png": "indexeddb://r6box/fs/assets/images/logo.png",\n'
                '    "images/background.jpg": "indexeddb://r6box/fs/assets/images/backgrounds/main_bg.jpg",\n'
                '    "sounds": "indexeddb://r6box/maps/assets/sound",\n'
                '    "docs": "indexeddb://r6box/fs/docs"\n'
                '  },\n'
                '  "tags": ["测试", "示例", "资源包"],\n'
                '  "requirements": {\n'
                '    "min_app_version": "1.0.0"\n'
                '  }\n'
                '}\n',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              context,
              '3',
              '处理流程',
              '系统会在VFS的fs集合中创建临时文件夹进行处理',
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(context, '4', '自动清理', '处理完成后会自动清理临时文件'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    String number,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpdateExternalResources() async {
    try {
      // 选择ZIP文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // 用户取消了选择
      }

      final file = result.files.first;
      Uint8List? fileBytes;

      if (file.bytes != null) {
        // Web平台：使用bytes
        fileBytes = file.bytes!;
      } else if (file.path != null) {
        // 桌面平台：使用path读取文件
        try {
          final localFile = File(file.path!);
          if (localFile.existsSync()) {
            fileBytes = await localFile.readAsBytes();
          }
        } catch (e) {
          _showErrorSnackBar('读取文件失败：$e');
          return;
        }
      }

      if (fileBytes == null) {
        _showErrorSnackBar('无法读取文件内容，请确保文件存在且有读取权限');
        return;
      }

      // 设置工作状态
      WorkStatusService().startWorking(
        '正在处理外部资源文件...',
        taskId: 'upload_external_resources',
      );

      setState(() {
        _isUploading = true;
      });

      await _processZipFileForPreview(fileBytes, file.name);
    } catch (e) {
      // 发生错误时清理工作状态
      WorkStatusService().stopWorking(taskId: 'upload_external_resources');
      _showErrorSnackBar('更新失败：$e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _processZipFileForPreview(
    Uint8List zipBytes,
    String fileName,
  ) async {
    // 更新工作状态描述
    WorkStatusService().updateWorkDescription('正在解压ZIP文件...');

    // 解压ZIP文件
    final archive = ZipDecoder().decodeBytes(zipBytes);

    // 生成唯一的临时文件夹名称
    final tempFolderName =
        'external_resources_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
    final tempPath = 'temp/$tempFolderName';

    try {
      // 1. 创建独占的临时文件夹
      await _vfsService.createDirectory('fs', tempPath);

      // 更新工作状态描述
      WorkStatusService().updateWorkDescription('正在提取文件到临时目录...');

      // 2. 解压所有文件到临时文件夹，查找根目录的metadata.json
      Map<String, dynamic>? metadata;

      for (final file in archive) {
        if (file.isFile) {
          final filePath = '$tempPath/${file.name}';
          await _vfsService.vfs.writeBinaryFile(
            'indexeddb://r6box/fs/$filePath',
            Uint8List.fromList(file.content as List<int>),
            mimeType: _getMimeType(file.name),
          );

          // 检查是否是根目录的元数据文件
          if (file.name == 'metadata.json' && !file.name.contains('/')) {
            try {
              final metadataContent = utf8.decode(file.content as List<int>);
              metadata = json.decode(metadataContent) as Map<String, dynamic>;
            } catch (e) {
              throw Exception('元数据文件格式错误：$e');
            }
          }
        }
      }

      // 3. 验证元数据
      WorkStatusService().updateWorkDescription('正在验证元数据文件...');

      if (metadata == null) {
        throw Exception('ZIP文件根目录中未找到metadata.json文件');
      }

      // 4. 准备文件映射预览
      WorkStatusService().updateWorkDescription('正在准备文件映射预览...');

      await _prepareFileMappingPreview(tempPath, metadata);

      // 5. 显示预览界面
      setState(() {
        _showPreview = true;
        _tempPath = tempPath;
      });
    } catch (e) {
      // 出错时也要清理临时文件
      try {
        await _cleanupTempFiles(tempPath);
      } catch (cleanupError) {
        debugPrint('清理临时文件失败：$cleanupError');
      }
      rethrow;
    }
  }

  /// 准备文件映射预览
  Future<void> _prepareFileMappingPreview(
    String tempPath,
    Map<String, dynamic> metadata,
  ) async {
    // 支持两种元数据格式：
    // 1. 简单格式：{ "target_path": "fs/assets/images" }
    // 2. 复杂格式：{ "file_mappings": { "file1.png": "fs/assets/images/file1.png", ... } }

    final fileMappings = metadata['file_mappings'] as Map<String, dynamic>?;
    final defaultTargetPath = metadata['target_path'] as String?;

    if (fileMappings != null) {
      // 使用复杂映射格式
      await _prepareComplexMapping(tempPath, fileMappings);
    } else if (defaultTargetPath != null) {
      // 使用简单格式，将所有文件复制到同一目标路径
      await _prepareSimpleMapping(tempPath, defaultTargetPath);
    } else {
      throw Exception('元数据中未指定target_path或file_mappings');
    }
  }

  /// 准备简单映射：所有文件复制到同一目标路径
  Future<void> _prepareSimpleMapping(String tempPath, String targetPath) async {
    // 不在这里验证路径合法性，让用户在预览界面中手动修改不合法的路径

    // 获取临时目录中的所有文件（除了metadata.json）
    final tempFiles = await _vfsService.listFiles('fs', tempPath);

    for (final file in tempFiles) {
      if (!file.isDirectory && !file.name.endsWith('metadata.json')) {
        // 使用绝对路径
        final sourcePath = file.path;
        final fileName = file.name;
        final targetFilePath = '$targetPath/$fileName';

        final isValid = _isValidTargetPath(targetFilePath);
        _fileMappings.add(
          FileMapping(
            sourceFile: sourcePath,
            targetPath: targetFilePath,
            fileName: fileName,
            isValidPath: isValid,
          ),
        );
      }
    }
  }

  /// 准备复杂映射：每个文件有独立的目标路径
  Future<void> _prepareComplexMapping(
    String tempPath,
    Map<String, dynamic> fileMappings,
  ) async {
    for (final entry in fileMappings.entries) {
      final sourceFileName = entry.key;
      final targetPath = entry.value as String;

      // 记录路径验证结果，但不阻止处理，让用户在预览界面修改

      // 构建绝对路径
      final sourcePath = 'indexeddb://r6box/fs/$tempPath/$sourceFileName';

      // 检查源路径是否存在
      final exists = await _vfsService.vfs.exists(sourcePath);
      if (!exists) {
        debugPrint('警告：源路径不存在，跳过：$sourceFileName');
        continue;
      }

      // 检查是否为文件夹
      final sourceFiles = await _vfsService.listFiles(
        'fs',
        '$tempPath/$sourceFileName',
      );
      final isDirectory = sourceFiles.isNotEmpty;

      if (isDirectory) {
        // 处理文件夹映射：递归处理文件夹中的所有文件
        await _processDirectoryMapping(sourcePath, targetPath, sourceFileName);
      } else {
        // 处理单个文件映射
        final isValid = _isValidTargetPath(targetPath);
        _fileMappings.add(
          FileMapping(
            sourceFile: sourcePath,
            targetPath: targetPath,
            fileName: sourceFileName,
            isValidPath: isValid,
          ),
        );
      }
    }
  }

  /// 复制单个文件到目标位置
  Future<void> _copyFileToTarget(String sourcePath, String targetPath) async {
    // sourcePath 和 targetPath 都是绝对路径
    final fileContent = await _vfsService.vfs.readFile(sourcePath);
    if (fileContent != null) {
      await _vfsService.vfs.writeBinaryFile(
        targetPath,
        fileContent.data,
        mimeType: fileContent.mimeType,
      );
    }
  }

  bool _isValidTargetPath(String path) {
    // 只允许 indexeddb://r6box/ 开头的绝对路径
    if (!path.startsWith('indexeddb://r6box/')) {
      return false;
    }

    // 解析路径以验证数据库和集合
    final pathPart = path.substring('indexeddb://'.length);
    final segments = pathPart.split('/').where((s) => s.isNotEmpty).toList();

    // 路径必须至少包含数据库和集合
    if (segments.length < 2) {
      return false;
    }

    final database = segments[0];
    final collection = segments[1];

    // 验证数据库名称必须是 r6box
    if (database != 'r6box') {
      return false;
    }

    // 验证集合必须是已挂载的集合之一：fs, legends, maps
    const allowedCollections = ['fs', 'legends', 'maps'];
    if (!allowedCollections.contains(collection)) {
      return false;
    }

    // 不允许包含危险字符（排除协议部分的双斜杠）
    final pathWithoutScheme = path.substring('indexeddb://'.length);
    if (pathWithoutScheme.contains('..') || pathWithoutScheme.contains('//')) {
      return false;
    }

    return true;
  }

  Future<void> _cleanupTempFiles(String tempPath) async {
    try {
      // 构建完整的临时文件夹路径
      final fullTempPath = 'indexeddb://r6box/fs/$tempPath';
      debugPrint('🗑️ 开始清理临时文件夹: $fullTempPath');

      // 检查临时文件夹是否存在
      final exists = await _vfsService.vfs.exists(fullTempPath);
      if (!exists) {
        debugPrint('🗑️ 临时文件夹不存在，无需清理: $fullTempPath');
        return;
      }

      // 递归删除整个临时文件夹
      final success = await _vfsService.vfs.delete(
        fullTempPath,
        recursive: true,
      );
      if (success) {
        debugPrint('🗑️ 临时文件夹清理成功: $fullTempPath');
      } else {
        debugPrint('🗑️ 临时文件夹清理失败: $fullTempPath');
      }
    } catch (e) {
      debugPrint('🗑️ 清理临时文件失败：$e');
    }
  }

  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'json':
        return 'application/json';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'txt':
        return 'text/plain';
      case 'md':
        return 'text/markdown';
      default:
        return 'application/octet-stream';
    }
  }

  void _showSuccessSnackBar(String message) {
    // 使用新的通知系统替换 SnackBar
    context.showSuccessSnackBar(message);
  }

  void _showErrorSnackBar(String message) {
    // 使用新的通知系统替换 SnackBar
    context.showErrorSnackBar(message);
  }

  /// 处理文件夹映射：递归处理文件夹中的所有文件
  Future<void> _processDirectoryMapping(
    String sourceFolderPath,
    String targetFolderPath,
    String folderName,
  ) async {
    try {
      // 获取文件夹中的所有文件和子文件夹
      final items = await _vfsService.listFiles(
        'fs',
        sourceFolderPath.substring('indexeddb://r6box/fs/'.length),
      );

      for (final item in items) {
        if (item.isDirectory) {
          // 递归处理子文件夹
          final subFolderName = item.name;
          final subSourcePath = '${sourceFolderPath}/${subFolderName}';
          final subTargetPath = '${targetFolderPath}/${subFolderName}';
          await _processDirectoryMapping(
            subSourcePath,
            subTargetPath,
            subFolderName,
          );
        } else {
          // 处理文件
          final fileName = item.name;
          final fileSourcePath = item.path;
          final fileTargetPath = '${targetFolderPath}/${fileName}';

          final isValid = _isValidTargetPath(fileTargetPath);
          _fileMappings.add(
            FileMapping(
              sourceFile: fileSourcePath,
              targetPath: fileTargetPath,
              fileName: fileName,
              isValidPath: isValid,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('处理文件夹映射失败：$folderName, 错误：$e');
    }
  }
}
