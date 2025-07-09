import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';
import '../../services/notification/notification_service.dart';

/// VFS文件元数据对话框
class VfsFileMetadataDialog extends StatefulWidget {
  final VfsFileInfo fileInfo;

  const VfsFileMetadataDialog({super.key, required this.fileInfo});

  @override
  State<VfsFileMetadataDialog> createState() => _VfsFileMetadataDialogState();

  /// 显示文件元数据对话框
  static Future<void> show(BuildContext context, VfsFileInfo fileInfo) {
    return showDialog(
      context: context,
      builder: (context) => VfsFileMetadataDialog(fileInfo: fileInfo),
    );
  }
}

class _VfsFileMetadataDialogState extends State<VfsFileMetadataDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.fileInfo.isDirectory
                        ? Icons.folder
                        : Icons.insert_drive_file,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '文件信息 - ${widget.fileInfo.name}',
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
            // 内容区域
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection('基本信息', [
                      _buildInfoRow('名称', widget.fileInfo.name),
                      _buildInfoRow('路径', widget.fileInfo.path),
                      _buildInfoRow(
                        '类型',
                        widget.fileInfo.isDirectory ? '文件夹' : '文件',
                      ),
                      if (!widget.fileInfo.isDirectory)
                        _buildInfoRow(
                          '大小',
                          _formatFileSize(widget.fileInfo.size),
                        ),
                      _buildInfoRow(
                        '修改时间',
                        _formatDateTime(widget.fileInfo.modifiedAt),
                      ),
                      _buildInfoRow(
                        '创建时间',
                        _formatDateTime(widget.fileInfo.createdAt),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    if (widget.fileInfo.metadata != null &&
                        widget.fileInfo.metadata!.isNotEmpty) ...[
                      _buildInfoSection('元数据', [
                        for (final entry in widget.fileInfo.metadata!.entries)
                          _buildInfoRow(entry.key, entry.value.toString()),
                      ]),
                      const SizedBox(height: 16),
                    ],
                    if (!widget.fileInfo.isDirectory) ...[
                      _buildInfoSection('文件详情', [
                        _buildInfoRow(
                          'MIME类型',
                          widget.fileInfo.mimeType ?? '未知',
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
            // 按钮栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _copyToClipboard(),
                    child: const Text('复制信息'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard() {
    final buffer = StringBuffer();
    buffer.writeln('文件信息:');
    buffer.writeln('名称: ${widget.fileInfo.name}');
    buffer.writeln('路径: ${widget.fileInfo.path}');
    buffer.writeln('类型: ${widget.fileInfo.isDirectory ? '文件夹' : '文件'}');

    if (!widget.fileInfo.isDirectory) {
      buffer.writeln('大小: ${_formatFileSize(widget.fileInfo.size)}');
    }

    buffer.writeln('修改时间: ${_formatDateTime(widget.fileInfo.modifiedAt)}');
    buffer.writeln('创建时间: ${_formatDateTime(widget.fileInfo.createdAt)}');

    if (widget.fileInfo.metadata != null &&
        widget.fileInfo.metadata!.isNotEmpty) {
      buffer.writeln('\n元数据:');
      for (final entry in widget.fileInfo.metadata!.entries) {
        buffer.writeln('${entry.key}: ${entry.value}');
      }
    }

    if (!widget.fileInfo.isDirectory) {
      if (widget.fileInfo.mimeType != null) {
        buffer.writeln('MIME类型: ${widget.fileInfo.mimeType}');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (mounted) {
      context.showSuccessSnackBar('文件信息已复制到剪贴板');
    }
  }
}
