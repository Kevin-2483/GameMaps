import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:intl/intl.dart';
import '../../utils/web_download_stub.dart'
    if (dart.library.html) '../../utils/web_download_web.dart';
import '../../components/layout/main_layout.dart';
import '../../components/common/draggable_title_bar.dart';
import '../../services/virtual_file_system/vfs_service_provider.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';
import '../../services/virtual_file_system/vfs_platform_io.dart';
import '../../services/work_status_service.dart';
import '../../services/work_status_action.dart';
import '../../services/notification/notification_service.dart';

import '../../l10n/app_localizations.dart';
import '../../components/vfs/vfs_file_picker_window.dart';
import '../../services/webdav/webdav_client_service.dart';
import '../../services/webdav/webdav_database_service.dart';
import '../../models/webdav_config.dart';

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

class ExportMapping {
  final String sourcePath;
  final String exportName;
  final bool isValidPath;

  ExportMapping({
    required this.sourcePath,
    required this.exportName,
    required this.isValidPath,
  });

  ExportMapping copyWith({
    String? sourcePath,
    String? exportName,
    bool? isValidPath,
  }) {
    return ExportMapping(
      sourcePath: sourcePath ?? this.sourcePath,
      exportName: exportName ?? this.exportName,
      isValidPath: isValidPath ?? this.isValidPath,
    );
  }
}

class _ExternalResourcesPageContentState
    extends State<_ExternalResourcesPageContent> {
  final VfsServiceProvider _vfsService = VfsServiceProvider();
  final WebDavClientService _webdavClientService = WebDavClientService();
  final WebDavDatabaseService _webdavDbService = WebDavDatabaseService();
  bool _isUploading = false;

  // 预览状态
  bool _showPreview = false;
  final List<FileMapping> _fileMappings = [];
  String _tempPath = '';

  // 导入预览状态
  bool _importListCollapsed = false;
  Map<String, dynamic>? _importMetadata;
  WorkStatusService? _webdavWorkStatusService; // 用于WebDAV导入的工作状态服务

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
                    if (!_showPreview) _buildExportSection(context),
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
    // 计算总文件数量（包括递归）
    final totalFiles = _fileMappings.length;

    // 检查是否有冲突或问题
    final hasIssues = _fileMappings.any((mapping) => !mapping.isValidPath);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和操作按钮
            Row(
              children: [
                Icon(
                  Icons.preview,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '导入预览 (共 $totalFiles 个项目)',
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

            // 元数据信息显示
            if (_importMetadata != null) ...[
              _buildImportMetadataCard(context),
              const SizedBox(height: 20),
            ],

            // 文件列表标题和折叠控制
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '文件映射列表',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (hasIssues)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '需要处理',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _importListCollapsed = !_importListCollapsed;
                      });
                    },
                    icon: Icon(
                      _importListCollapsed
                          ? Icons.expand_more
                          : Icons.expand_less,
                      size: 18,
                    ),
                    label: Text(_importListCollapsed ? '展开' : '折叠'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 提示信息（仅在展开时显示）
            if (!_importListCollapsed) ...[
              const SizedBox(height: 12),
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
            ] else ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: hasIssues
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasIssues
                            ? '检测到 ${_fileMappings.where((m) => !m.isValidPath).length} 个路径问题，请展开列表进行修正'
                            : '所有文件路径检查通过，可以直接导入',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: hasIssues
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
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
    // 清理工作状态（检查是否是WebDAV导入）
    if (_webdavWorkStatusService != null) {
      _webdavWorkStatusService!.stopWorking(taskId: 'webdav_import');
      _webdavWorkStatusService = null;
    } else {
      WorkStatusService().stopWorking(taskId: 'upload_external_resources');
    }

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
      _importMetadata = null;
      _importListCollapsed = false;
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

    // 检查是否是WebDAV导入，如果是则使用保存的工作状态服务
    final workStatusService = _webdavWorkStatusService ?? WorkStatusService();
    final taskId = _webdavWorkStatusService != null ? 'webdav_import' : 'upload_external_resources';

    try {
      setState(() {
        _isUploading = true;
      });
      
      // 更新工作状态描述
      workStatusService.updateWorkDescription('正在验证文件路径...');

      // 再次检查路径合法性（防止用户手动修改后未更新isValidPath）
      for (final mapping in _fileMappings) {
        final isValid = _isValidTargetPath(mapping.targetPath);
        mapping.isValidPath = isValid;
        if (!isValid) {
          throw Exception('目标路径不合法：${mapping.targetPath}');
        }
      }

      // 更新工作状态描述
      workStatusService.updateWorkDescription('正在检查文件冲突...');

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
      final totalFiles = _fileMappings.length;
      int processedFiles = 0;
      workStatusService.updateWorkDescription(
        '正在复制文件到目标位置... ($processedFiles/$totalFiles)',
      );

      // 处理文件映射
      for (final mapping in _fileMappings) {
        processedFiles++;
        workStatusService.updateWorkDescription(
          '正在复制文件到目标位置... ($processedFiles/$totalFiles)',
        );
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
      workStatusService.updateWorkDescription('正在清理临时文件...');

      // 清理临时文件
      await _cleanupTempFiles(_tempPath);

      // 清理工作状态
      workStatusService.stopWorking(taskId: taskId);
      
      // 清理WebDAV工作状态服务引用
      if (_webdavWorkStatusService != null) {
        _webdavWorkStatusService = null;
      }

      _showSuccessSnackBar('外部资源更新成功');
      _cancelPreview();
    } catch (e) {
      // 发生错误时清理工作状态
      workStatusService.stopWorking(taskId: taskId);
      
      // 清理WebDAV工作状态服务引用
      if (_webdavWorkStatusService != null) {
        _webdavWorkStatusService = null;
      }
      
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

  Widget _buildMetadataInputSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
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
                Text(
                  '元数据信息',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 基础字段 - 两列布局
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _exportNameController,
                        decoration: const InputDecoration(
                          labelText: '资源包名称 *',
                          hintText: '输入资源包名称',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _exportVersionController,
                        decoration: const InputDecoration(
                          labelText: '版本 *',
                          hintText: '如: 1.0.0',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _exportAuthorController,
                        decoration: const InputDecoration(
                          labelText: '作者',
                          hintText: '输入作者名称',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _exportLicenseController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: '使用要求',
                          hintText: '如：不允许私自转发、仅供学习使用、需注明出处等',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 描述字段 - 全宽
                TextField(
                  controller: _exportDescriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '描述',
                    hintText: '输入资源包的详细描述',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // 自定义字段
                if (_customFields.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    '自定义字段',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._customFields.asMap().entries.map((entry) {
                    final index = entry.key;
                    final field = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: field.key,
                              decoration: const InputDecoration(
                                labelText: '字段名',
                                hintText: '输入字段名',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: field.value,
                              decoration: const InputDecoration(
                                labelText: '字段值',
                                hintText: '输入字段值',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _removeCustomField(index),
                            icon: const Icon(Icons.delete_outline),
                            tooltip: '删除字段',
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                // 添加自定义字段按钮
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _addCustomField,
                      icon: const Icon(Icons.add),
                      label: const Text('添加自定义字段'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportMetadataCard(BuildContext context) {
    if (_importMetadata == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '资源包信息',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (_importMetadata!['name'] != null)
                _buildMetadataChip(
                  context,
                  '名称',
                  _importMetadata!['name'].toString(),
                ),
              if (_importMetadata!['version'] != null)
                _buildMetadataChip(
                  context,
                  '版本',
                  _importMetadata!['version'].toString(),
                ),
              if (_importMetadata!['author'] != null)
                _buildMetadataChip(
                  context,
                  '作者',
                  _importMetadata!['author'].toString(),
                ),
              if (_importMetadata!['license'] != null)
                _buildMetadataChip(
                  context,
                  '使用要求',
                  _importMetadata!['license'].toString(),
                ),
            ],
          ),

          if (_importMetadata!['description'] != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '描述',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _importMetadata!['description'].toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],

          // 显示其他自定义字段
          ...(_importMetadata!.entries
              .where(
                (entry) => ![
                  'name',
                  'version',
                  'author',
                  'license',
                  'description',
                  'file_mappings',
                  'export_time',
                ].contains(entry.key),
              )
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildMetadataChip(
                    context,
                    entry.key,
                    entry.value.toString(),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMetadataChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection(BuildContext context) {
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
                  Icons.file_download,
                  size: 24,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Text(
                  '导出外部资源',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '选择要导出的文件或文件夹，并为它们指定导出名称。系统将创建一个包含所选资源和元数据的ZIP文件。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),

            // 元数据字段输入区域
            _buildMetadataInputSection(context),
            const SizedBox(height: 20),

            // 导出映射列表
            if (_exportMappings.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // 表头
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              '源路径',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '导出名称',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 100), // 操作按钮空间
                        ],
                      ),
                    ),
                    // 导出项列表
                    ...List.generate(_exportMappings.length, (index) {
                      final mapping = _exportMappings[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // 源路径
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: '选择源文件或文件夹',
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                !_isValidSourcePathField(
                                                  mapping.sourcePath,
                                                )
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.error
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                !_isValidSourcePathField(
                                                  mapping.sourcePath,
                                                )
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.error
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                !_isValidSourcePathField(
                                                  mapping.sourcePath,
                                                )
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.error
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                        errorText:
                                            !mapping.isValidPath &&
                                                mapping.sourcePath.isNotEmpty
                                            ? '路径无效'
                                            : !_isValidSourcePathField(
                                                mapping.sourcePath,
                                              )
                                            ? '请选择源路径'
                                            : null,
                                      ),
                                      controller: TextEditingController(
                                        text: mapping.sourcePath,
                                      ),
                                      onChanged: (value) =>
                                          _updateExportSourcePath(index, value),
                                      readOnly: true,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _selectSourcePath(index),
                                    icon: const Icon(Icons.folder_open),
                                    tooltip: '选择路径',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 导出名称
                            Expanded(
                              flex: 2,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: '输入导出名称',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          !_isValidExportName(
                                            index,
                                            mapping.exportName,
                                          )
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          !_isValidExportName(
                                            index,
                                            mapping.exportName,
                                          )
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          !_isValidExportName(
                                            index,
                                            mapping.exportName,
                                          )
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  errorText: mapping.exportName.trim().isEmpty
                                      ? '请输入导出名称'
                                      : !_isValidExportName(
                                          index,
                                          mapping.exportName,
                                        )
                                      ? '导出名称重复'
                                      : null,
                                ),
                                controller: TextEditingController(
                                  text: mapping.exportName,
                                ),
                                onChanged: (value) =>
                                    _updateExportName(index, value),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 删除按钮
                            IconButton(
                              onPressed: () => _removeExportMapping(index),
                              icon: const Icon(Icons.delete_outline),
                              tooltip: '删除',
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 操作按钮
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _addExportMapping,
                  icon: const Icon(Icons.add),
                  label: const Text('添加导出项'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (kIsWeb)
                  // Web平台：只显示下载按钮
                  ElevatedButton.icon(
                    onPressed: _isExporting || _exportMappings.isEmpty
                        ? null
                        : _performDirectDownload,
                    icon: _isExporting
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
                        : const Icon(Icons.download),
                    label: Text(_isExporting ? '导出中...' : '下载导出文件'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      elevation: _isExporting ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  )
                else
                  // 桌面平台：显示两个按钮
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isExporting || _exportMappings.isEmpty
                            ? null
                            : _performLocalExport,
                        icon: _isExporting
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
                            : const Icon(Icons.folder),
                        label: Text(_isExporting ? '导出中...' : '导出到文件夹'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          elevation: _isExporting ? 0 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isExporting || _exportMappings.isEmpty
                            ? null
                            : _performWebDAVExport,
                        icon: _isExporting
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
                            : const Icon(Icons.cloud_upload),
                        label: Text(_isExporting ? '上传中...' : '上传到WebDAV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: _isExporting ? 0 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
            if (kIsWeb)
              // Web平台：只显示本地导入按钮
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
              )
            else
              // 桌面平台：显示两个按钮
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
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
                          _isUploading ? '正在处理...' : '本地导入',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _handleWebDAVImport,
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
                            : const Icon(Icons.cloud_download, size: 20),
                        label: Text(
                          _isUploading ? '正在处理...' : 'WebDAV导入',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                '  "version": "1.1.0",\n'
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
                '    "min_app_version": "1.1.0"\n'
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

      // 4. 保存元数据信息
      _importMetadata = metadata;

      // 5. 准备文件映射预览
      WorkStatusService().updateWorkDescription('正在准备文件映射预览...');

      await _prepareFileMappingPreview(tempPath, metadata);

      // 6. 检查是否有路径问题，决定是否折叠列表
      final hasIssues = _fileMappings.any((mapping) => !mapping.isValidPath);
      _importListCollapsed = !hasIssues; // 如果没有问题就折叠，有问题就展开

      // 7. 显示预览界面
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

  void _showInfoSnackBar(String message) {
    // 使用新的通知系统替换 SnackBar
    context.showInfoSnackBar(message);
  }

  // ==================== 导出功能 ====================

  final List<ExportMapping> _exportMappings = [];
  bool _isExporting = false;

  // 导出元数据字段控制器
  final TextEditingController _exportNameController = TextEditingController();
  final TextEditingController _exportVersionController = TextEditingController(
    text: '1.0.0',
  );
  final TextEditingController _exportDescriptionController =
      TextEditingController();
  final TextEditingController _exportAuthorController = TextEditingController();
  final TextEditingController _exportLicenseController =
      TextEditingController();
  final List<MapEntry<TextEditingController, TextEditingController>>
  _customFields = [];

  @override
  void dispose() {
    _exportNameController.dispose();
    _exportVersionController.dispose();
    _exportDescriptionController.dispose();
    _exportAuthorController.dispose();
    _exportLicenseController.dispose();
    for (final field in _customFields) {
      field.key.dispose();
      field.value.dispose();
    }
    super.dispose();
  }

  /// 添加导出映射
  void _addExportMapping() {
    setState(() {
      _exportMappings.add(
        ExportMapping(sourcePath: '', exportName: '', isValidPath: false),
      );
    });
  }

  /// 删除导出映射
  void _removeExportMapping(int index) {
    setState(() {
      _exportMappings.removeAt(index);
    });
  }

  /// 添加自定义字段
  void _addCustomField() {
    setState(() {
      _customFields.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  /// 删除自定义字段
  void _removeCustomField(int index) {
    setState(() {
      final field = _customFields.removeAt(index);
      field.key.dispose();
      field.value.dispose();
    });
  }

  /// 更新导出映射的源路径
  void _updateExportSourcePath(int index, String path) {
    setState(() {
      _exportMappings[index] = _exportMappings[index].copyWith(
        sourcePath: path,
        isValidPath: _isValidSourcePath(path),
      );
    });
  }

  /// 更新导出映射的导出名称
  void _updateExportName(int index, String name) {
    setState(() {
      _exportMappings[index] = _exportMappings[index].copyWith(
        exportName: name,
      );
    });
  }

  /// 验证源路径是否有效
  bool _isValidSourcePath(String path) {
    if (path.isEmpty) return false;

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

    return true;
  }

  /// 选择源路径
  Future<void> _selectSourcePath(int index) async {
    try {
      final result = await VfsFileManagerWindow.showFilePicker(
        context,
        allowDirectorySelection: true,
        selectionType: SelectionType.both,
      );

      if (result != null) {
        _updateExportSourcePath(index, result);

        // 自动提取路径结尾填充导出名称
        final pathName = _extractPathName(result);
        if (pathName.isNotEmpty) {
          _updateExportName(index, pathName);
        }
      }
    } catch (e) {
      _showErrorSnackBar('选择路径失败：$e');
    }
  }

  /// 从路径中提取文件/文件夹名称
  String _extractPathName(String path) {
    if (path.isEmpty) return '';

    // 移除末尾的斜杠
    String cleanPath = path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;

    // 提取最后一个路径段
    final segments = cleanPath.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return '';

    return segments.last;
  }

  /// 检查导出名称是否有效（不为空且不重复）
  bool _isValidExportName(int currentIndex, String name) {
    if (name.trim().isEmpty) return false;

    // 检查是否与其他项重复
    for (int i = 0; i < _exportMappings.length; i++) {
      if (i != currentIndex &&
          _exportMappings[i].exportName.trim() == name.trim()) {
        return false;
      }
    }

    return true;
  }

  /// 检查源路径是否为空
  bool _isValidSourcePathField(String path) {
    return path.trim().isNotEmpty;
  }

  /// Web平台直接下载
  Future<void> _performDirectDownload() async {
    final validMappings = _getValidMappings();
    if (validMappings == null) return;

    await _performExportWithOption(validMappings, {'type': 'local'});
  }

  /// 桌面平台本地导出
  Future<void> _performLocalExport() async {
    final validMappings = _getValidMappings();
    if (validMappings == null) return;

    await _performExportWithOption(validMappings, {'type': 'local'});
  }

  /// 桌面平台WebDAV导出
  Future<void> _performWebDAVExport() async {
    final validMappings = _getValidMappings();
    if (validMappings == null) return;

    // 获取可用的WebDAV配置
    final webdavConfigs = await _webdavDbService.getAllConfigs();
    final enabledWebdavConfigs = webdavConfigs.where((config) => config.isEnabled).toList();

    if (enabledWebdavConfigs.isEmpty) {
      _showErrorSnackBar('没有可用的WebDAV配置，请先在WebDAV管理页面添加配置');
      return;
    }

    if (!mounted) return;

    // 显示WebDAV配置选择对话框
    final selectedConfig = await _showWebDAVConfigDialog(enabledWebdavConfigs);
    if (selectedConfig != null) {
      await _performExportWithOption(validMappings, {
        'type': 'webdav',
        'config': selectedConfig,
      });
    }
  }

  /// 获取有效的导出映射
  List<ExportMapping>? _getValidMappings() {
    if (_exportMappings.isEmpty) {
      _showErrorSnackBar('请至少添加一个导出项');
      return null;
    }

    final validMappings = _exportMappings
        .where(
          (mapping) =>
              mapping.isValidPath &&
              mapping.sourcePath.isNotEmpty &&
              mapping.exportName.isNotEmpty,
        )
        .toList();

    if (validMappings.isEmpty) {
      _showErrorSnackBar('请确保所有导出项都有有效的源路径和导出名称');
      return null;
    }

    return validMappings;
  }

  /// 显示WebDAV配置选择对话框
  Future<WebDavConfig?> _showWebDAVConfigDialog(List<WebDavConfig> configs) async {
    return await showDialog<WebDavConfig>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择WebDAV配置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: configs.map((config) => ListTile(
            leading: const Icon(Icons.cloud),
            title: Text(config.displayName),
            subtitle: Text(config.serverUrl),
            onTap: () => Navigator.of(context).pop(config),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 根据选择的选项执行导出
  Future<void> _performExportWithOption(
    List<ExportMapping> validMappings,
    Map<String, dynamic> option,
  ) async {
    setState(() {
      _isExporting = true;
    });

    try {
      // 开始导出状态
      final workStatusService = WorkStatusService();
      workStatusService.startWorking('正在准备导出...', taskId: 'export');

      // 创建临时文件夹
      final tempFolderName =
          'export_temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempPath = 'indexeddb://r6box/fs/temp/$tempFolderName';

      await _vfsService.vfs.createDirectory(tempPath);

      // 复制文件到临时文件夹并重命名
      final fileMapping = <String, String>{};

      for (int i = 0; i < validMappings.length; i++) {
        final mapping = validMappings[i];
        workStatusService.updateWorkDescription(
          '正在复制文件 ${i + 1}/${validMappings.length}',
        );
        await _copyToTempFolder(
          mapping,
          tempPath,
          fileMapping,
        );
      }

      // 创建 metadata.json
      workStatusService.updateWorkDescription('正在生成元数据...');
      await _createMetadataFile(tempPath, fileMapping);

      // 压缩文件夹
      workStatusService.updateWorkDescription('正在压缩文件...');
      final zipBytes = await _compressTempFolder(tempPath);

      // 根据选择的选项进行保存
      final exportType = option['type'] as String;
      if (exportType == 'local') {
        // 本地保存
        workStatusService.updateWorkDescription('正在保存文件...');
        if (kIsWeb) {
          await _downloadFile(zipBytes);
        } else {
          await _saveExportFile(zipBytes);
        }
      } else if (exportType == 'webdav') {
        // WebDAV上传
        final config = option['config'] as WebDavConfig;
        workStatusService.updateWorkDescription('正在上传到WebDAV...');
        await _uploadToWebDAV(zipBytes, config, fileMapping);
      }

      // 清理临时文件
      workStatusService.updateWorkDescription('正在清理临时文件...');
      await _vfsService.vfs.delete(tempPath, recursive: true);

      _showSuccessSnackBar('导出成功！');

      workStatusService.stopWorking(taskId: 'export');
    } catch (e) {
      final workStatusService = WorkStatusService();
      workStatusService.updateWorkDescription('导出失败：$e');
      _showErrorSnackBar('导出失败：$e');
      debugPrint('导出失败：$e');
      // 延迟结束工作状态以显示错误信息
      Future.delayed(const Duration(seconds: 2), () {
        workStatusService.stopWorking(taskId: 'export');
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  /// 计算数据的SHA256哈希值
  String _calculateDataHash(Uint8List data) {
    final digest = sha256.convert(data);
    return digest.toString().substring(0, 8); // 取前8位作为短哈希
  }

  /// 上传到WebDAV
  Future<void> _uploadToWebDAV(
    Uint8List zipBytes, 
    WebDavConfig config, 
    Map<String, String> fileMapping,
  ) async {
    try {
      // 计算文件内容的哈希值
      final contentHash = _calculateDataHash(zipBytes);
      
      // 获取导出名称，如果为空则使用默认名称
      final exportName = _exportNameController.text.trim().isNotEmpty 
          ? _exportNameController.text.trim() 
          : 'external_resources';
      
      // 生成文件夹名称：hash + 导出名称
      final folderName = '${contentHash}_$exportName';
      final fileName = '$exportName.zip';
      
      // 检查WebDAV上是否已存在相同的文件夹
      final folderExists = await _webdavClientService.checkPathExists(
        config.configId,
        folderName,
      );
      
      if (folderExists) {
        // 如果文件夹已存在，说明相同内容已经上传过，跳过上传
        debugPrint('WebDAV上已存在相同内容的导出，跳过上传：$folderName');
        return;
      }
      
      // 写入到VFS临时文件
      final tempVfsPath = 'indexeddb://r6box/fs/temp/$fileName';
      await _vfsService.vfs.writeBinaryFile(
        tempVfsPath,
        zipBytes,
        mimeType: 'application/zip',
      );

      // 使用VFS服务生成系统临时文件路径
      final systemTempPath = await _vfsService.generateFileUrl(tempVfsPath);
      if (systemTempPath == null) {
        throw Exception('无法生成系统临时文件路径');
      }

      // 上传ZIP文件到WebDAV的指定文件夹中
      final remotePath = '$folderName/$fileName';
      final success = await _webdavClientService.uploadFile(
        config.configId,
        systemTempPath,
        remotePath,
      );

      if (!success) {
        throw Exception('WebDAV上传失败');
      }

      // 生成并上传metadata.json文件
      await _uploadMetadataToWebDAV(config, folderName, fileMapping);

      // 清理VFS临时文件
      await _vfsService.vfs.delete(tempVfsPath);
      
      debugPrint('成功上传到WebDAV：$remotePath');
    } catch (e) {
      throw Exception('WebDAV上传失败：$e');
    }
  }

  /// 上传metadata.json文件到WebDAV
  Future<void> _uploadMetadataToWebDAV(
    WebDavConfig config,
    String folderName,
    Map<String, String> fileMapping,
  ) async {
    try {
      // 生成metadata.json内容
      final metadata = <String, dynamic>{};
      
      // 按固定顺序添加字段以确保确定性
      
      // 1. 文件映射（排序后的）
      final sortedFileMapping = Map<String, String>.fromEntries(
        fileMapping.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
      );
      metadata['file_mappings'] = sortedFileMapping;
      
      // 2. 基础字段（按字母顺序）
      if (_exportAuthorController.text.trim().isNotEmpty) {
        metadata['author'] = _exportAuthorController.text.trim();
      }
      if (_exportDescriptionController.text.trim().isNotEmpty) {
        metadata['description'] = _exportDescriptionController.text.trim();
      }
      if (_exportLicenseController.text.trim().isNotEmpty) {
        metadata['license'] = _exportLicenseController.text.trim();
      }
      if (_exportNameController.text.trim().isNotEmpty) {
        metadata['name'] = _exportNameController.text.trim();
      }
      if (_exportVersionController.text.trim().isNotEmpty) {
        metadata['version'] = _exportVersionController.text.trim();
      }

      // 3. 自定义字段（按键名排序）
      final customFieldsMap = <String, String>{};
      for (final field in _customFields) {
        final key = field.key.text.trim();
        final value = field.value.text.trim();
        if (key.isNotEmpty && value.isNotEmpty) {
          customFieldsMap[key] = value;
        }
      }
      
      // 按键名排序添加自定义字段
      final sortedCustomFields = customFieldsMap.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      for (final entry in sortedCustomFields) {
        metadata[entry.key] = entry.value;
      }

      final metadataJson = jsonEncode(metadata);
      
      // 写入到VFS临时文件
      final tempMetadataPath = 'indexeddb://r6box/fs/temp/metadata.json';
      await _vfsService.vfs.writeTextFile(tempMetadataPath, metadataJson);
      
      // 使用VFS服务生成系统临时文件路径
      final systemTempPath = await _vfsService.generateFileUrl(tempMetadataPath);
      if (systemTempPath == null) {
        throw Exception('无法生成metadata.json系统临时文件路径');
      }

      // 上传metadata.json到WebDAV的指定文件夹中
      final remoteMetadataPath = '$folderName/metadata.json';
      final success = await _webdavClientService.uploadFile(
        config.configId,
        systemTempPath,
        remoteMetadataPath,
      );

      if (!success) {
        throw Exception('metadata.json WebDAV上传失败');
      }

      // 清理VFS临时文件
      await _vfsService.vfs.delete(tempMetadataPath);
      
      debugPrint('成功上传metadata.json到WebDAV：$remoteMetadataPath');
    } catch (e) {
      throw Exception('metadata.json WebDAV上传失败：$e');
    }
  }

  /// 复制文件到临时文件夹
  /// 返回复制的文件数量
  Future<int> _copyToTempFolder(
    ExportMapping mapping,
    String tempPath,
    Map<String, String> fileMapping,
  ) async {
    final sourcePath = mapping.sourcePath;
    final exportName = mapping.exportName;

    // 记录顶层映射（无论是文件还是文件夹）
    fileMapping[exportName] = sourcePath;

    // 检查源路径是否存在
    final exists = await _vfsService.vfs.exists(sourcePath);
    if (!exists) {
      throw Exception('源路径不存在：$sourcePath');
    }

    // 检查是文件还是文件夹
    final fileInfo = await _vfsService.vfs.getFileInfo(sourcePath);
    final isDirectory = fileInfo?.isDirectory ?? false;

    if (isDirectory) {
      // 处理文件夹（不记录子文件映射）
      return await _copyDirectoryToTemp(sourcePath, tempPath, exportName);
    } else {
      // 处理单个文件
      final fileContent = await _vfsService.vfs.readFile(sourcePath);
      if (fileContent != null) {
        final targetPath = '$tempPath/$exportName';
        await _vfsService.vfs.writeBinaryFile(
          targetPath,
          fileContent.data,
          mimeType: fileContent.mimeType,
        );
        return 1; // 复制了1个文件
      }
      return 0; // 没有复制文件
    }
  }

  /// 递归复制文件夹到临时位置
  /// 返回复制的文件数量
  Future<int> _copyDirectoryToTemp(
    String sourcePath,
    String tempPath,
    String exportName,
  ) async {
    final targetDirPath = '$tempPath/$exportName';
    await _vfsService.vfs.createDirectory(targetDirPath);

    // 解析源路径获取collection和相对路径
    final sourceRelativePath = sourcePath.substring(
      'indexeddb://r6box/'.length,
    );
    final pathParts = sourceRelativePath.split('/');
    final collection = pathParts[0];
    final relativePath = pathParts.length > 1
        ? pathParts.sublist(1).join('/')
        : '';

    final items = await _vfsService.listFiles(collection, relativePath);
    int totalFilesCopied = 0;

    for (final item in items) {
      final itemName = item.name;
      final itemSourcePath = item.path;
      final itemTargetPath = '$targetDirPath/$itemName';

      if (item.isDirectory) {
        // 递归处理子文件夹
        final subFileCount = await _copyDirectoryToTemp(
          itemSourcePath,
          targetDirPath,
          itemName,
        );
        totalFilesCopied += subFileCount;
      } else {
        // 复制文件
        final fileContent = await _vfsService.vfs.readFile(itemSourcePath);
        if (fileContent != null) {
          await _vfsService.vfs.writeBinaryFile(
            itemTargetPath,
            fileContent.data,
            mimeType: fileContent.mimeType,
          );
          totalFilesCopied++;
        }
      }
    }

    return totalFilesCopied;
  }

  /// 创建 metadata.json 文件
  Future<void> _createMetadataFile(
    String tempPath,
    Map<String, String> fileMapping,
  ) async {
    // 使用LinkedHashMap确保字段顺序一致
    final metadata = <String, dynamic>{};
    
    // 按固定顺序添加字段以确保确定性
    
    // 1. 文件映射（排序后的）
    final sortedFileMapping = Map<String, String>.fromEntries(
      fileMapping.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    metadata['file_mappings'] = sortedFileMapping;
    
    // 2. 基础字段（按字母顺序）
    if (_exportAuthorController.text.trim().isNotEmpty) {
      metadata['author'] = _exportAuthorController.text.trim();
    }
    if (_exportDescriptionController.text.trim().isNotEmpty) {
      metadata['description'] = _exportDescriptionController.text.trim();
    }
    if (_exportLicenseController.text.trim().isNotEmpty) {
      metadata['license'] = _exportLicenseController.text.trim();
    }
    if (_exportNameController.text.trim().isNotEmpty) {
      metadata['name'] = _exportNameController.text.trim();
    }
    if (_exportVersionController.text.trim().isNotEmpty) {
      metadata['version'] = _exportVersionController.text.trim();
    }

    // 3. 自定义字段（按键名排序）
    final customFieldsMap = <String, String>{};
    for (final field in _customFields) {
      final key = field.key.text.trim();
      final value = field.value.text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        customFieldsMap[key] = value;
      }
    }
    
    // 按键名排序添加自定义字段
    final sortedCustomFields = customFieldsMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in sortedCustomFields) {
      metadata[entry.key] = entry.value;
    }

    final metadataJson = jsonEncode(metadata);
    final metadataPath = '$tempPath/metadata.json';

    await _vfsService.vfs.writeTextFile(metadataPath, metadataJson);
  }

  /// 压缩临时文件夹
  Future<Uint8List> _compressTempFolder(String tempPath) async {
    final archive = Archive();

    // 解析临时文件夹路径
    final tempRelativePath = tempPath.substring('indexeddb://r6box/'.length);
    final pathParts = tempRelativePath.split('/');
    final collection = pathParts[0];
    final relativePath = pathParts.length > 1
        ? pathParts.sublist(1).join('/')
        : '';

    final items = await _vfsService.listFiles(collection, relativePath);

    // 递归添加所有文件到压缩包
    await _addItemsToArchive(archive, items, '');

    // 压缩
    final zipEncoder = ZipEncoder();
    return Uint8List.fromList(zipEncoder.encode(archive)!);
  }

  /// 递归添加文件到压缩包
  Future<void> _addItemsToArchive(
    Archive archive,
    List<VfsFileInfo> items,
    String basePath,
  ) async {
    // 对文件列表进行排序以确保确定性顺序
    final sortedItems = List<VfsFileInfo>.from(items)
      ..sort((a, b) => a.name.compareTo(b.name));
    
    for (final item in sortedItems) {
      final itemPath = basePath.isEmpty ? item.name : '$basePath/${item.name}';

      if (item.isDirectory) {
        // 处理文件夹
        final itemRelativePath = item.path.substring(
          'indexeddb://r6box/'.length,
        );
        final itemPathParts = itemRelativePath.split('/');
        final itemCollection = itemPathParts[0];
        final itemSubPath = itemPathParts.length > 1
            ? itemPathParts.sublist(1).join('/')
            : '';

        final subItems = await _vfsService.listFiles(
          itemCollection,
          itemSubPath,
        );
        await _addItemsToArchive(archive, subItems, itemPath);
      } else {
        // 添加文件到压缩包
        final fileContent = await _vfsService.vfs.readFile(item.path);
        if (fileContent != null) {
          final archiveFile = ArchiveFile(
            itemPath,
            fileContent.data.length,
            fileContent.data,
          );
          // 设置固定的时间戳以确保确定性
          archiveFile.lastModTime = 0;
          archive.addFile(archiveFile);
        }
      }
    }
  }

  /// 保存导出文件
  Future<void> _saveExportFile(Uint8List zipBytes) async {
    try {
      // 生成默认文件名
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName = 'external_resources_export_$timestamp.zip';

      // 使用文件选择器让用户选择保存位置
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '保存导出文件',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null) {
        // 写入文件
        final file = File(result);
        await file.writeAsBytes(zipBytes);
      }
    } catch (e) {
      // 如果文件选择器失败，尝试下载到默认位置
      debugPrint('文件选择器失败，尝试下载：$e');
      await _downloadFile(zipBytes);
    }
  }

  /// 下载文件（Web平台备用方案）
  Future<void> _downloadFile(Uint8List zipBytes) async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'external_resources_export_$timestamp.zip';

      if (kIsWeb) {
        // Web平台：使用WebDownloader下载
        await WebDownloader.downloadFile(zipBytes, fileName);
      } else {
        // 桌面平台：保存到下载文件夹
        final downloadsPath = Platform.isWindows
            ? '${Platform.environment['USERPROFILE']}\\Downloads'
            : '${Platform.environment['HOME']}/Downloads';
        final file = File('$downloadsPath/$fileName');
        await file.writeAsBytes(zipBytes);
      }
    } catch (e) {
      throw Exception('下载失败：$e');
    }
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

  /// 处理WebDAV导入
  Future<void> _handleWebDAVImport() async {
    // 开始WebDAV导入工作状态
    final workStatusService = WorkStatusService();
    
    // 添加取消操作控件
    final cancelAction = WorkStatusAction.cancel(
      onPressed: () {
        workStatusService.stopWorking(taskId: 'webdav_import');
        if (mounted) {
          _showInfoSnackBar('WebDAV导入已取消');
        }
      },
      tooltip: '取消WebDAV导入',
    );
    
    workStatusService.startWorking(
      '正在连接WebDAV...', 
      taskId: 'webdav_import',
      actions: [cancelAction],
    );
    
    try {
      // 获取可用的WebDAV配置
      final webdavConfigs = await _webdavDbService.getAllConfigs();
      final enabledWebdavConfigs = webdavConfigs.where((config) => config.isEnabled).toList();

      if (enabledWebdavConfigs.isEmpty) {
        workStatusService.stopWorking(taskId: 'webdav_import');
        _showErrorSnackBar('没有可用的WebDAV配置，请先在WebDAV管理页面添加配置');
        return;
      }

      // 让用户选择WebDAV配置
      final selectedConfig = await _showWebDAVConfigDialog(enabledWebdavConfigs);
      if (selectedConfig == null) {
        workStatusService.stopWorking(taskId: 'webdav_import');
        return;
      }

      try {
        // 更新工作状态
        workStatusService.updateWorkDescription('正在读取WebDAV目录...');
        
        // 读取WebDAV根目录
        final directories = await _webdavClientService.listDirectory(
          selectedConfig.configId,
          '',
        );

        if (directories == null) {
          workStatusService.stopWorking(taskId: 'webdav_import');
          _showErrorSnackBar('无法读取WebDAV目录');
          return;
        }

        // 筛选出目录
        final dirList = directories.where((item) {
          return item.isDir == true;
        }).toList();

        if (dirList.isEmpty) {
          workStatusService.stopWorking(taskId: 'webdav_import');
          _showErrorSnackBar('WebDAV中没有找到任何目录');
          return;
        }

        // 更新工作状态
        workStatusService.updateWorkDescription('正在扫描目录...');
        
        // 读取每个目录的metadata.json
        final importItems = <WebDAVImportItem>[];
        for (final dir in dirList) {
          final dirName = dir.name;
          if (dirName == null) continue;

          try {
            // 读取目录内容，检查是否包含metadata.json
            final dirContents = await _webdavClientService.listDirectory(
              selectedConfig.configId,
              dirName,
            );

            if (dirContents != null) {
              // 检查目录中是否包含metadata.json文件
              final hasMetadata = dirContents.any((file) => 
                file.name == 'metadata.json' && file.isDir != true
              );

              if (hasMetadata) {
                // 下载并解析metadata.json
                final metadataPath = '$dirName/metadata.json';
                final tempMetadataFile = File(await VfsPlatformIO.generateWebDAVImportTempFilePath('temp_metadata_${DateTime.now().millisecondsSinceEpoch}.json'));
                
                final downloadSuccess = await _webdavClientService.downloadFile(
                  selectedConfig.configId,
                  metadataPath,
                  tempMetadataFile.path,
                );

                if (downloadSuccess && await tempMetadataFile.exists()) {
                  final metadataContent = await tempMetadataFile.readAsString();
                  final metadata = jsonDecode(metadataContent) as Map<String, dynamic>;
                  
                  importItems.add(WebDAVImportItem(
                    directoryName: dirName,
                    metadata: metadata,
                    config: selectedConfig,
                  ));

                  // 清理临时文件
                  await tempMetadataFile.delete();
                }
              }
            }
          } catch (e) {
            debugPrint('读取目录 $dirName 的内容失败: $e');
          }
        }

        if (importItems.isEmpty) {
          workStatusService.stopWorking(taskId: 'webdav_import');
          _showErrorSnackBar('没有找到包含有效metadata.json的目录');
          return;
        }

        // 更新工作状态为等待用户选择
        workStatusService.updateWorkDescription('等待用户选择导入项...');
        
        // 显示导入项列表对话框
        _showWebDAVImportDialog(importItems, workStatusService);
      } catch (e) {
        workStatusService.stopWorking(taskId: 'webdav_import');
        _showErrorSnackBar('读取WebDAV目录失败: $e');
      }
    } catch (e) {
      workStatusService.stopWorking(taskId: 'webdav_import');
      _showErrorSnackBar('WebDAV导入失败: $e');
    }
  }

  /// 显示WebDAV导入项列表对话框
  void _showWebDAVImportDialog(List<WebDAVImportItem> importItems, WorkStatusService workStatusService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WebDAV导入列表'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: importItems.length,
            itemBuilder: (context, index) {
              final item = importItems[index];
              final metadata = item.metadata;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  metadata['name']?.toString() ?? item.directoryName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (metadata['version'] != null)
                                  Text(
                                    '版本: ${metadata['version']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                if (metadata['author'] != null)
                                  Text(
                                    '作者: ${metadata['author']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              // 添加短暂延迟以确保对话框完全关闭
                              await Future.delayed(const Duration(milliseconds: 100));
                              if (mounted) {
                                await _downloadAndImportFromWebDAV(item, workStatusService);
                              }
                            },
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('下载并导入'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (metadata['description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          metadata['description'].toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '目录: ${item.directoryName}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              workStatusService.stopWorking(taskId: 'webdav_import');
              Navigator.of(context).pop();
            },
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 从WebDAV下载并导入
  Future<void> _downloadAndImportFromWebDAV(WebDAVImportItem item, WorkStatusService workStatusService) async {
    try {
      // 更新取消操作控件
      final cancelAction = WorkStatusAction.cancel(
        onPressed: () {
          workStatusService.stopWorking(taskId: 'webdav_import');
          if (mounted) {
            _showInfoSnackBar('WebDAV下载已取消');
          }
        },
        tooltip: '取消WebDAV下载',
      );
      
      workStatusService.updateActions([cancelAction]);
      
      // 更新工作状态
      workStatusService.updateWorkDescription('正在准备下载...');
      // 查找ZIP文件
      final directories = await _webdavClientService.listDirectory(
        item.config.configId,
        item.directoryName,
      );

      if (directories == null) {
        workStatusService.stopWorking(taskId: 'webdav_import');
        if (mounted) {
          _showErrorSnackBar('无法读取目录内容');
        }
        return;
      }

      // 查找ZIP文件
      final zipFiles = directories.where((file) {
        return file.isDir != true && 
               file.name != null && 
               file.name!.toLowerCase().endsWith('.zip');
      }).toList();

      if (zipFiles.isEmpty) {
        workStatusService.stopWorking(taskId: 'webdav_import');
        if (mounted) {
          _showErrorSnackBar('目录中没有找到ZIP文件');
        }
        return;
      }

      // 使用第一个ZIP文件
      final zipFile = zipFiles.first;
      final zipFileName = zipFile.name!;

      // 更新工作状态
      workStatusService.updateWorkDescription('正在下载 $zipFileName...');

      // 下载ZIP文件到自定义临时目录
      final tempZipFilePath = await VfsPlatformIO.generateWebDAVImportTempFilePath(zipFileName);
      final tempZipFile = File(tempZipFilePath);
      
      final downloadSuccess = await _webdavClientService.downloadFile(
        item.config.configId,
        '${item.directoryName}/$zipFileName',
        tempZipFile.path,
      );

      if (!downloadSuccess || !await tempZipFile.exists()) {
        workStatusService.stopWorking(taskId: 'webdav_import');
        if (mounted) {
          _showErrorSnackBar('下载ZIP文件失败');
        }
        return;
      }

      // 更新工作状态
      workStatusService.updateWorkDescription('正在处理ZIP文件...');
      
      // 读取ZIP文件内容
      final zipBytes = await tempZipFile.readAsBytes();
      
      // 清理临时文件
      await tempZipFile.delete();

      // 调用现有的导入流程（不重复设置工作状态）
      if (mounted) {
        await _handleZipImportForWebDAV(zipBytes, zipFileName, workStatusService);
      }
    } catch (e) {
      workStatusService.stopWorking(taskId: 'webdav_import');
      if (mounted) {
        _showErrorSnackBar('下载并导入失败: $e');
      }
    }
  }

  /// 处理ZIP文件导入（用于WebDAV，使用传入的工作状态服务）
  Future<void> _handleZipImportForWebDAV(Uint8List zipBytes, String fileName, WorkStatusService workStatusService) async {
    try {
      // 保存WebDAV工作状态服务，以便在确认导入时继续使用
      _webdavWorkStatusService = workStatusService;
      
      // 更新工作状态到预览阶段
      workStatusService.updateWorkDescription('正在准备预览...');
      
      // 清理之前的状态
      setState(() {
        _showPreview = false;
        _fileMappings.clear();
        _importMetadata = null;
      });

      // 处理ZIP文件并显示预览
      await _processZipFileForPreview(zipBytes, fileName);
      
      // 更新工作状态到等待用户确认
      workStatusService.updateWorkDescription('等待用户确认导入...');
    } catch (e) {
      // 出错时停止工作状态
      workStatusService.stopWorking(taskId: 'webdav_import');
      _webdavWorkStatusService = null;
      _showErrorSnackBar('处理ZIP文件失败: $e');
    }
  }

  /// 处理ZIP文件导入（用于常规导入）
  Future<void> _handleZipImport(Uint8List zipBytes, String fileName) async {
    try {
      // 开始工作状态
      final workStatusService = WorkStatusService();
      workStatusService.startWorking('正在处理ZIP文件...', taskId: 'import');

      // 清理之前的状态
      setState(() {
        _showPreview = false;
        _fileMappings.clear();
        _importMetadata = null;
      });

      // 处理ZIP文件并显示预览
      await _processZipFileForPreview(zipBytes, fileName);

      // 完成工作状态
      workStatusService.stopWorking(taskId: 'import');
    } catch (e) {
      // 完成工作状态（即使出错）
      WorkStatusService().stopWorking(taskId: 'import');
      _showErrorSnackBar('处理ZIP文件失败: $e');
    }
  }
}

/// WebDAV导入项
class WebDAVImportItem {
  final String directoryName;
  final Map<String, dynamic> metadata;
  final WebDavConfig config;

  WebDAVImportItem({
    required this.directoryName,
    required this.metadata,
    required this.config,
  });
}
