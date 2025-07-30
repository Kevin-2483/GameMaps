// This file has been processed by AI for internationalization
import 'package:flutter/material.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';

/// VFS文件重命名对话框
class VfsFileRenameDialog extends StatefulWidget {
  final VfsFileInfo fileInfo;

  const VfsFileRenameDialog({super.key, required this.fileInfo});

  @override
  State<VfsFileRenameDialog> createState() => _VfsFileRenameDialogState();

  /// 显示文件重命名对话框
  static Future<String?> show(BuildContext context, VfsFileInfo fileInfo) {
    return showDialog<String>(
      context: context,
      builder: (context) => VfsFileRenameDialog(fileInfo: fileInfo),
    );
  }
}

class _VfsFileRenameDialogState extends State<VfsFileRenameDialog> {
  late TextEditingController _nameController;
  late String _originalName;
  late String _nameWithoutExtension;
  late String _extension;
  bool _isValidName = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _originalName = widget.fileInfo.name;

    // 分离文件名和扩展名
    if (!widget.fileInfo.isDirectory) {
      final lastDotIndex = _originalName.lastIndexOf('.');
      if (lastDotIndex > 0 && lastDotIndex < _originalName.length - 1) {
        _nameWithoutExtension = _originalName.substring(0, lastDotIndex);
        _extension = _originalName.substring(lastDotIndex);
      } else {
        _nameWithoutExtension = _originalName;
        _extension = '';
      }
    } else {
      _nameWithoutExtension = _originalName;
      _extension = '';
    }

    _nameController = TextEditingController(text: _nameWithoutExtension);
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateName() {
    final name = _nameController.text.trim();

    setState(() {
      if (name.isEmpty) {
        _isValidName = false;
        _errorMessage =
            LocalizationService.instance.current.nameCannotBeEmpty_4821;
      } else if (name.contains(RegExp(r'[<>:"/\\|?*]'))) {
        _isValidName = false;
        _errorMessage =
            LocalizationService.instance.current.invalidCharactersError_4821;
      } else if (name.startsWith('.') || name.endsWith('.')) {
        _isValidName = false;
        _errorMessage =
            LocalizationService.instance.current.invalidNameDotError_4821;
      } else if (name.length > 255) {
        _isValidName = false;
        _errorMessage =
            LocalizationService.instance.current.nameLengthExceedLimit_4829;
      } else if (_isReservedName(name)) {
        _isValidName = false;
        _errorMessage =
            LocalizationService.instance.current.reservedNameError_4821;
      } else {
        _isValidName = true;
        _errorMessage = null;
      }
    });
  }

  bool _isReservedName(String name) {
    const reservedNames = [
      'CON',
      'PRN',
      'AUX',
      'NUL',
      'COM1',
      'COM2',
      'COM3',
      'COM4',
      'COM5',
      'COM6',
      'COM7',
      'COM8',
      'COM9',
      'LPT1',
      'LPT2',
      'LPT3',
      'LPT4',
      'LPT5',
      'LPT6',
      'LPT7',
      'LPT8',
      'LPT9',
    ];
    return reservedNames.contains(name.toUpperCase());
  }

  void _handleRename() {
    if (!_isValidName) return;

    final newName = _nameController.text.trim() + _extension;
    if (newName == _originalName) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop(newName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
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
                    LocalizationService.instance.current
                        .renameFileOrFolder_7421(
                          widget.fileInfo.isDirectory ? 'folder' : 'file',
                        ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 当前名称显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService.instance.current.currentNameLabel_4821,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _originalName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 新名称输入
            Text(
              LocalizationService.instance.current.newLabel_4821,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: LocalizationService
                          .instance
                          .current
                          .inputNewNameHint_4821,
                      errorText: _errorMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (_) => _handleRename(),
                  ),
                ),
                if (_extension.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _extension,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (_extension.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                LocalizationService.instance.current.fileExtensionNotice(
                  _extension,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 按钮栏
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(LocalizationService.instance.current.cancel_4821),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isValidName ? _handleRename : null,
                  child: Text(LocalizationService.instance.current.rename_4821),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
