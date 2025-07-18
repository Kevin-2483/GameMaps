import 'package:flutter/material.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';

/// 文件冲突处理动作
enum VfsConflictAction {
  /// 重命名
  rename,
  /// 覆盖
  overwrite,
  /// 跳过
  skip,
  /// 合并（仅适用于文件夹）
  merge,
}

/// 文件冲突处理结果
class VfsConflictResult {
  final VfsConflictAction action;
  final String? newName;
  final bool applyToAll;

  const VfsConflictResult({
    required this.action,
    this.newName,
    this.applyToAll = false,
  });
}

/// 文件冲突信息
class VfsConflictInfo {
  final String fileName;
  final bool isDirectory;
  final VfsFileInfo? existingFile;
  final VfsFileInfo sourceFile;
  final String? suggestedName;

  const VfsConflictInfo({
    required this.fileName,
    required this.isDirectory,
    required this.existingFile,
    required this.sourceFile,
    this.suggestedName,
  });
}

/// VFS文件冲突处理对话框
class VfsFileConflictDialog extends StatefulWidget {
  final VfsConflictInfo conflictInfo;
  final bool showApplyToAll;
  final int? remainingConflicts;

  const VfsFileConflictDialog({
    super.key,
    required this.conflictInfo,
    this.showApplyToAll = false,
    this.remainingConflicts,
  });

  @override
  State<VfsFileConflictDialog> createState() => _VfsFileConflictDialogState();

  /// 显示单个文件冲突对话框
  static Future<VfsConflictResult?> show(
    BuildContext context,
    VfsConflictInfo conflictInfo, {
    bool showApplyToAll = false,
    int? remainingConflicts,
  }) {
    return showDialog<VfsConflictResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VfsFileConflictDialog(
        conflictInfo: conflictInfo,
        showApplyToAll: showApplyToAll,
        remainingConflicts: remainingConflicts,
      ),
    );
  }
}

class _VfsFileConflictDialogState extends State<VfsFileConflictDialog> {
  late TextEditingController _nameController;
  VfsConflictAction _selectedAction = VfsConflictAction.rename;
  bool _applyToAll = false;
  bool _isValidName = true;
  String? _errorMessage;
  late String _originalName;
  late String _nameWithoutExtension;
  late String _extension;

  @override
  void initState() {
    super.initState();
    _originalName = widget.conflictInfo.fileName;
    
    // 分离文件名和扩展名
    if (!widget.conflictInfo.isDirectory) {
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

    // 使用预生成的建议名称或生成默认的重命名建议
    String suggestedName;
    if (widget.conflictInfo.suggestedName != null) {
      // 使用预生成的唯一建议名称，需要去掉扩展名
      final suggested = widget.conflictInfo.suggestedName!;
      if (!widget.conflictInfo.isDirectory && _extension.isNotEmpty) {
        suggestedName = suggested.endsWith(_extension) 
            ? suggested.substring(0, suggested.length - _extension.length)
            : suggested;
      } else {
        suggestedName = suggested;
      }
    } else {
      // 回退到默认生成逻辑
      suggestedName = _generateSuggestedName(_nameWithoutExtension);
    }
    _nameController = TextEditingController(text: suggestedName);
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _generateSuggestedName(String baseName) {
    // 生成唯一的建议名称，如 "文件名 (副本)", "文件名 (副本 2)" 等
    String suggestedName = '$baseName (副本)';
    int counter = 2;
    
    // 这里应该检查目标路径是否存在同名文件，但由于我们在对话框中
    // 无法直接访问VFS服务，所以先返回基本的建议名称
    // 实际的唯一性检查应该在调用方进行
    return suggestedName;
  }

  void _validateName() {
    final name = _nameController.text.trim();

    setState(() {
      if (name.isEmpty) {
        _isValidName = false;
        _errorMessage = '名称不能为空';
      } else if (name.contains(RegExp(r'[<>:"/\\|?*]'))) {
        _isValidName = false;
        _errorMessage = '名称包含无效字符: < > : " / \\ | ? *';
      } else if (name.startsWith('.') || name.endsWith('.')) {
        _isValidName = false;
        _errorMessage = '名称不能以点号开头或结尾';
      } else if (name.length > 255) {
        _isValidName = false;
        _errorMessage = '名称长度不能超过255个字符';
      } else if (_isReservedName(name)) {
        _isValidName = false;
        _errorMessage = '不能使用系统保留名称';
      } else {
        _isValidName = true;
        _errorMessage = null;
      }
    });
  }

  bool _isReservedName(String name) {
    const reservedNames = [
      'CON', 'PRN', 'AUX', 'NUL',
      'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
      'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9',
    ];
    return reservedNames.contains(name.toUpperCase());
  }

  void _handleConfirm() {
    if (_selectedAction == VfsConflictAction.rename && !_isValidName) {
      return;
    }

    String? newName;
    if (_selectedAction == VfsConflictAction.rename) {
      newName = _nameController.text.trim() + _extension;
    }

    final result = VfsConflictResult(
      action: _selectedAction,
      newName: newName,
      applyToAll: _applyToAll,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final conflictInfo = widget.conflictInfo;

    return Dialog(
      backgroundColor: colorScheme.surface,
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '文件冲突',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 冲突描述
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '目标位置已存在同名${conflictInfo.isDirectory ? "文件夹" : "文件"}:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        conflictInfo.isDirectory
                            ? Icons.folder
                            : Icons.insert_drive_file,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          conflictInfo.fileName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.remainingConflicts != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '还有 ${widget.remainingConflicts} 个冲突需要处理',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 可滚动的选项区域
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 处理选项
                    Text(
                      '请选择处理方式:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 重命名选项
                    RadioListTile<VfsConflictAction>(
                      value: VfsConflictAction.rename,
                      groupValue: _selectedAction,
                      onChanged: (value) {
                        setState(() {
                          _selectedAction = value!;
                        });
                      },
                      title: const Text('重命名'),
                      subtitle: const Text('保留两个文件，重命名新文件'),
                      secondary: const Icon(Icons.drive_file_rename_outline),
                    ),

                    // 重命名输入框
                    if (_selectedAction == VfsConflictAction.rename) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: '输入新名称',
                                  errorText: _errorMessage,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _handleConfirm(),
                              ),
                            ),
                            if (_extension.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
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
                      ),
                    ],

                    // 覆盖选项
                    RadioListTile<VfsConflictAction>(
                      value: VfsConflictAction.overwrite,
                      groupValue: _selectedAction,
                      onChanged: (value) {
                        setState(() {
                          _selectedAction = value!;
                        });
                      },
                      title: const Text('覆盖'),
                      subtitle: const Text('用新文件替换现有文件'),
                      secondary: Icon(
                        Icons.file_copy,
                        color: colorScheme.error,
                      ),
                    ),

                    // 合并选项（仅文件夹）
                    if (conflictInfo.isDirectory)
                      RadioListTile<VfsConflictAction>(
                        value: VfsConflictAction.merge,
                        groupValue: _selectedAction,
                        onChanged: (value) {
                          setState(() {
                            _selectedAction = value!;
                          });
                        },
                        title: const Text('合并'),
                        subtitle: const Text('合并文件夹内容，子文件冲突时会再次询问'),
                        secondary: const Icon(Icons.merge),
                      ),

                    // 跳过选项
                    RadioListTile<VfsConflictAction>(
                      value: VfsConflictAction.skip,
                      groupValue: _selectedAction,
                      onChanged: (value) {
                        setState(() {
                          _selectedAction = value!;
                        });
                      },
                      title: const Text('跳过'),
                      subtitle: const Text('跳过此文件，保留现有文件'),
                      secondary: const Icon(Icons.skip_next),
                    ),

                    const SizedBox(height: 16),

                    // 应用到所有选项
                    if (widget.showApplyToAll)
                      CheckboxListTile(
                        value: _applyToAll,
                        onChanged: (value) {
                          setState(() {
                            _applyToAll = value ?? false;
                          });
                        },
                        title: const Text('应用到所有冲突'),
                        subtitle: const Text('对剩余的所有冲突使用相同的处理方式'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 按钮栏
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_selectedAction == VfsConflictAction.rename && !_isValidName)
                      ? null
                      : _handleConfirm,
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 批量文件冲突处理对话框
class VfsBatchConflictDialog extends StatefulWidget {
  final List<VfsConflictInfo> conflicts;

  const VfsBatchConflictDialog({
    super.key,
    required this.conflicts,
  });

  @override
  State<VfsBatchConflictDialog> createState() => _VfsBatchConflictDialogState();

  /// 显示批量文件冲突处理对话框
  static Future<List<VfsConflictResult>?> show(
    BuildContext context,
    List<VfsConflictInfo> conflicts,
  ) {
    return showDialog<List<VfsConflictResult>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VfsBatchConflictDialog(conflicts: conflicts),
    );
  }
}

class _VfsBatchConflictDialogState extends State<VfsBatchConflictDialog> {
  final List<VfsConflictResult> _results = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNextConflictDialog();
    });
  }

  Future<void> _showNextConflictDialog() async {
    if (_currentIndex >= widget.conflicts.length) {
      // 所有冲突都已处理完成
      if (mounted) {
        Navigator.of(context).pop(_results);
      }
      return;
    }

    final currentConflict = widget.conflicts[_currentIndex];
    final remainingCount = widget.conflicts.length - _currentIndex - 1;

    if (!mounted) return;
    
    final result = await VfsFileConflictDialog.show(
      context,
      currentConflict,
      showApplyToAll: remainingCount > 0,
      remainingConflicts: remainingCount,
    );

    if (!mounted) return;
    
    if (result != null) {
      _handleConflictResult(result);
    } else {
      // 用户取消了操作
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  void _handleConflictResult(VfsConflictResult result) {
    _results.add(result);

    if (result.applyToAll && _currentIndex < widget.conflicts.length - 1) {
      // 应用到所有剩余冲突
      for (int i = _currentIndex + 1; i < widget.conflicts.length; i++) {
        final conflict = widget.conflicts[i];
        String? newName;
        
        if (result.action == VfsConflictAction.rename) {
          // 为每个文件生成唯一的重命名
          final baseName = conflict.isDirectory 
              ? conflict.fileName
              : conflict.fileName.substring(0, conflict.fileName.lastIndexOf('.'));
          final extension = conflict.isDirectory 
              ? ''
              : conflict.fileName.substring(conflict.fileName.lastIndexOf('.'));
          newName = '$baseName (副本)$extension';
        }
        
        _results.add(VfsConflictResult(
          action: result.action,
          newName: newName,
          applyToAll: false,
        ));
      }
      
      // 完成处理
      if (mounted) {
        Navigator.of(context).pop(_results);
      }
    } else {
      // 处理下一个冲突
      _currentIndex++;
      _showNextConflictDialog();
    }
  }
}