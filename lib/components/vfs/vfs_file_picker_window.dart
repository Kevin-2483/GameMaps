// This file has been processed by AI for internationalization
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';

import '../../services/virtual_file_system/vfs_service_provider.dart';
import '../../services/virtual_file_system/vfs_protocol.dart';
import '../../services/virtual_file_system/vfs_import_export_service.dart';
import '../../services/virtual_file_system/vfs_database_initializer.dart';
import '../web/web_context_menu_handler.dart';
import '../../utils/web_download_utils.dart';
import 'vfs_file_metadata_dialog.dart';
import 'vfs_file_rename_dialog.dart';
import 'vfs_file_search_dialog.dart';
import 'vfs_file_conflict_dialog.dart';
import 'vfs_permission_dialog.dart';
import '../common/floating_window.dart';
import '../../services/vfs/vfs_file_opener_service.dart';
import '../../services/notification/notification_service.dart';

import '../../services/localization_service.dart';

/// 文件选择回调类型定义
typedef FileSelectionCallback = void Function(List<String> selectedPaths);

/// 选择类型枚举
enum SelectionType {
  /// 只能选择文件
  filesOnly,

  /// 只能选择目录
  directoriesOnly,

  /// 可以选择文件和目录
  both,
}

/// VFS文件管理器窗口，作为全屏覆盖层显示
class VfsFileManagerWindow extends StatefulWidget {
  final VoidCallback? onClose;
  final String? initialDatabase;
  final String? initialCollection;
  final String? initialPath;
  final FileSelectionCallback? onFilesSelected;
  final bool allowMultipleSelection;
  final bool allowDirectorySelection;
  final SelectionType selectionType;
  final List<String>? allowedExtensions;

  const VfsFileManagerWindow({
    super.key,
    this.onClose,
    this.initialDatabase,
    this.initialCollection,
    this.initialPath,
    this.onFilesSelected,
    this.allowMultipleSelection = false,
    this.allowDirectorySelection = true,
    this.selectionType = SelectionType.both,
    this.allowedExtensions,
  });

  @override
  State<VfsFileManagerWindow> createState() => _VfsFileManagerWindowState();

  /// 显示VFS文件管理器窗口（浏览模式）
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

  /// 显示文件选择器窗口（单选模式）
  static Future<String?> showFilePicker(
    BuildContext context, {
    String? initialDatabase,
    String? initialCollection,
    String? initialPath,
    bool allowDirectorySelection = true,
    SelectionType selectionType = SelectionType.both,
    List<String>? allowedExtensions,
  }) async {
    String? selectedFile;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => VfsFileManagerWindow(
        onClose: () => Navigator.of(context).pop(),
        initialDatabase: initialDatabase,
        initialCollection: initialCollection,
        initialPath: initialPath,
        allowMultipleSelection: false,
        allowDirectorySelection: allowDirectorySelection,
        selectionType: selectionType,
        allowedExtensions: allowedExtensions,
        onFilesSelected: (files) {
          if (files.isNotEmpty) {
            selectedFile = files.first;
          }
          Navigator.of(context).pop();
        },
      ),
    );

    return selectedFile;
  }

  /// 显示文件选择器窗口（多选模式）
  static Future<List<String>?> showMultiFilePicker(
    BuildContext context, {
    String? initialDatabase,
    String? initialCollection,
    String? initialPath,
    bool allowDirectorySelection = true,
    SelectionType selectionType = SelectionType.both,
    List<String>? allowedExtensions,
  }) async {
    List<String>? selectedFiles;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => VfsFileManagerWindow(
        onClose: () => Navigator.of(context).pop(),
        initialDatabase: initialDatabase,
        initialCollection: initialCollection,
        initialPath: initialPath,
        allowMultipleSelection: true,
        allowDirectorySelection: allowDirectorySelection,
        selectionType: selectionType,
        allowedExtensions: allowedExtensions,
        onFilesSelected: (files) {
          selectedFiles = files;
          Navigator.of(context).pop();
        },
      ),
    );

    return selectedFiles;
  }

  /// 显示路径选择对话框（单选模式）
  static Future<String?> showPathPicker(
    BuildContext context, {
    String? initialDatabase,
    String? initialCollection,
    String? initialPath,
    bool allowDirectorySelection = true,
    SelectionType selectionType = SelectionType.both,
    List<String>? allowedExtensions,
    String? title,
  }) async {
    String? selectedPath;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => VfsFileManagerWindow(
        onClose: () => Navigator.of(context).pop(),
        initialDatabase: initialDatabase,
        initialCollection: initialCollection,
        initialPath: initialPath,
        allowMultipleSelection: false,
        allowDirectorySelection: allowDirectorySelection,
        selectionType: selectionType,
        allowedExtensions: allowedExtensions,
        onFilesSelected: (files) {
          if (files.isNotEmpty) {
            selectedPath = files.first;
          }
          Navigator.of(context).pop();
        },
      ),
    );

    return selectedPath;
  }

  /// 显示路径选择对话框（多选模式）
  static Future<List<String>?> showMultiPathPicker(
    BuildContext context, {
    String? initialDatabase,
    String? initialCollection,
    String? initialPath,
    bool allowDirectorySelection = true,
    SelectionType selectionType = SelectionType.both,
    List<String>? allowedExtensions,
    String? title,
  }) async {
    List<String>? selectedPaths;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => VfsFileManagerWindow(
        onClose: () => Navigator.of(context).pop(),
        initialDatabase: initialDatabase,
        initialCollection: initialCollection,
        initialPath: initialPath,
        allowMultipleSelection: true,
        allowDirectorySelection: allowDirectorySelection,
        selectionType: selectionType,
        allowedExtensions: allowedExtensions,
        onFilesSelected: (paths) {
          selectedPaths = paths;
          Navigator.of(context).pop();
        },
      ),
    );

    return selectedPaths;
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
    // 添加标签页切换监听器，用于重新构建工具栏
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          // 标签页切换时重新构建UI
        });
      }
    });
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
      final vfsInitializer = VfsDatabaseInitializer();
      await vfsInitializer.initializeApplicationVfs();

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
        _errorMessage = LocalizationService.instance.current
            .initializationFailed(e);
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
      // 使用权限过滤的文件列表方法
      final allFiles = await _vfsService.listFilesWithPermissions(
        _selectedCollection!,
        path.isEmpty ? null : path,
      );

      // 在选择模式下应用文件过滤
      final filteredFiles = _shouldApplyFiltering()
          ? _filterFiles(allFiles)
          : allFiles;

      setState(() {
        _currentFiles = filteredFiles;
        _currentPath = path;
        _selectedFiles.clear();
      });

      // 更新历史记录
      _updateHistory(path);

      // 排序文件
      _sortFiles();
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.fileLoadFailed_7285(e),
      );
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

  /// 判断是否应用文件过滤
  bool _shouldApplyFiltering() {
    return widget.onFilesSelected != null;
  }

  /// 根据选择模式和限制条件过滤文件
  List<VfsFileInfo> _filterFiles(List<VfsFileInfo> files) {
    if (widget.onFilesSelected == null) {
      return files;
    }

    List<VfsFileInfo> filteredFiles = [];

    for (final file in files) {
      bool shouldInclude = true;

      // 在仅文件模式下，文件夹仍然显示（用于导航），但不能被选中
      // 只有在明确禁止选择目录时才过滤掉目录
      if (file.isDirectory &&
          widget.allowDirectorySelection == false &&
          widget.selectionType != SelectionType.filesOnly) {
        shouldInclude = false;
      }

      // 如果指定了文件扩展名限制，过滤文件
      if (!file.isDirectory &&
          widget.allowedExtensions != null &&
          widget.allowedExtensions!.isNotEmpty) {
        final extension = file.name.split('.').last.toLowerCase();
        if (!widget.allowedExtensions!.contains(extension)) {
          shouldInclude = false;
        }
      }

      if (shouldInclude) {
        filteredFiles.add(file);
      }
    }

    return filteredFiles;
  }

  /// 检查选择限制
  bool _canSelectFile(VfsFileInfo file) {
    if (widget.onFilesSelected == null) {
      return true;
    }

    // 检查新的选择类型限制
    switch (widget.selectionType) {
      case SelectionType.filesOnly:
        if (file.isDirectory) {
          return false;
        }
        break;
      case SelectionType.directoriesOnly:
        if (!file.isDirectory) {
          return false;
        }
        break;
      case SelectionType.both:
        // 允许选择文件和目录，继续其他检查
        break;
    }

    // 检查目录选择权限（向后兼容）
    if (file.isDirectory && widget.allowDirectorySelection == false) {
      return false;
    }

    // 检查文件扩展名限制
    if (!file.isDirectory &&
        widget.allowedExtensions != null &&
        widget.allowedExtensions!.isNotEmpty) {
      final extension = file.name.split('.').last.toLowerCase();
      if (!widget.allowedExtensions!.contains(extension)) {
        return false;
      }
    }

    return true;
  }

  /// 检查当前选择是否可以确认
  bool _canConfirmSelection() {
    if (widget.onFilesSelected == null) {
      return false;
    }

    // 必须有选择
    if (_selectedFiles.isEmpty) {
      return false;
    }

    // 验证所有已选择的文件是否都符合限制条件
    for (final selectedPath in _selectedFiles) {
      final selectedFile = _currentFiles.firstWhere(
        (file) => file.path == selectedPath,
        orElse: () =>
            throw StateError('Selected file not found in current files'),
      );

      // 检查目录选择权限
      if (selectedFile.isDirectory && widget.allowDirectorySelection == false) {
        return false;
      }

      // 检查文件扩展名限制
      if (!selectedFile.isDirectory &&
          widget.allowedExtensions != null &&
          widget.allowedExtensions!.isNotEmpty) {
        final extension = selectedFile.name.split('.').last.toLowerCase();
        if (!widget.allowedExtensions!.contains(extension)) {
          return false;
        }
      }
    }

    return true;
  }

  /// 构建选择模式描述文本
  String _buildSelectionModeDescription() {
    final List<String> restrictions = [];

    // 添加选择数量限制
    if (widget.allowMultipleSelection) {
      restrictions.add(
        LocalizationService.instance.current.supportMultipleSelection_7281,
      );
    } else {
      restrictions.add(
        LocalizationService.instance.current.singleSelectionOnly_4821,
      );
    } // 添加选择类型限制（优先使用新的 SelectionType）
    switch (widget.selectionType) {
      case SelectionType.filesOnly:
        if (widget.allowedExtensions != null &&
            widget.allowedExtensions!.isNotEmpty) {
          restrictions.add(
            LocalizationService.instance.current.fileTypeRestriction_7421(
              widget.allowedExtensions!.join(', '),
            ),
          );
        } else {
          restrictions.add(
            LocalizationService
                .instance
                .current
                .onlyFilesAndFoldersNavigable_7281,
          );
        }
        break;
      case SelectionType.directoriesOnly:
        restrictions.add(LocalizationService.instance.current.folderOnly_7281);
        break;
      case SelectionType.both:
        if (widget.allowedExtensions != null &&
            widget.allowedExtensions!.isNotEmpty) {
          restrictions.add(
            LocalizationService.instance.current.folderAndFileTypesRestriction(
              widget.allowedExtensions!.join(', '),
            ),
          );
        } else {
          restrictions.add(
            LocalizationService.instance.current.filesAndFolders_7281,
          );
        }
        break;
    }

    return restrictions.join(' • ');
  }

  /// 复制文件
  Future<void> _copyFiles(List<VfsFileInfo> files) async {
    setState(() {
      _clipboardFiles = List.from(files);
      _isCutOperation = false;
      _selectedFiles.clear(); // 清空选择
    });

    _showInfoSnackBar(
      LocalizationService.instance.current.copiedItemsCount(files.length),
    );
  }

  /// 剪切文件
  Future<void> _cutFiles(List<VfsFileInfo> files) async {
    setState(() {
      _clipboardFiles = List.from(files);
      _isCutOperation = true;
      _selectedFiles.clear(); // 清空选择
    });

    _showInfoSnackBar(
      LocalizationService.instance.current.itemsCutMessage(files.length),
    );
  }

  /// 生成唯一的文件名建议
  Future<String> _generateUniqueFileName(
    String originalName,
    String targetPath,
  ) async {
    if (_selectedCollection == null) return originalName;

    // 分离文件名和扩展名
    String baseName;
    String extension;

    final lastDotIndex = originalName.lastIndexOf('.');
    if (lastDotIndex > 0 && lastDotIndex < originalName.length - 1) {
      baseName = originalName.substring(0, lastDotIndex);
      extension = originalName.substring(lastDotIndex);
    } else {
      baseName = originalName;
      extension = '';
    }

    // 检查基本的副本名称
    String suggestedName =
        '$baseName ${LocalizationService.instance.current.copySuffix_3632}$extension';
    String testPath = _currentPath.isEmpty
        ? suggestedName
        : '$_currentPath/$suggestedName';

    final existingFile = await _vfsService.getFileInfo(
      _selectedCollection!,
      testPath,
    );
    if (existingFile == null) {
      return suggestedName;
    }

    // 如果副本也存在，尝试带数字的版本
    int counter = 2;
    while (counter <= 100) {
      // 限制尝试次数避免无限循环
      suggestedName =
          '$baseName (${LocalizationService.instance.current.copyWithNumber_3632} $counter)$extension';
      testPath = _currentPath.isEmpty
          ? suggestedName
          : '$_currentPath/$suggestedName';

      final testFile = await _vfsService.getFileInfo(
        _selectedCollection!,
        testPath,
      );
      if (testFile == null) {
        return suggestedName;
      }
      counter++;
    }

    // 如果都存在，返回带时间戳的版本
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$baseName (${LocalizationService.instance.current.copyWithTimestamp_3632} $timestamp)$extension';
  }

  /// 粘贴文件
  Future<void> _pasteFiles() async {
    if (_clipboardFiles.isEmpty ||
        _selectedDatabase == null ||
        _selectedCollection == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 收集所有冲突信息
      final conflicts = <VfsConflictInfo>[];

      for (final file in _clipboardFiles) {
        final fileName = file.name;
        final targetPath = _currentPath.isEmpty
            ? fileName
            : '$_currentPath/$fileName';

        // 检查目标文件是否存在
        final existingFile = await _vfsService.getFileInfo(
          _selectedCollection!,
          targetPath,
        );

        if (existingFile != null) {
          // 生成唯一的建议名称
          final suggestedName = await _generateUniqueFileName(
            file.name,
            targetPath,
          );

          conflicts.add(
            VfsConflictInfo(
              fileName: file.name,
              isDirectory: file.isDirectory,
              existingFile: existingFile,
              sourceFile: file,
              suggestedName: suggestedName,
            ),
          );
        }
      }

      // 如果有冲突，显示批量冲突处理对话框
      Map<String, VfsConflictResult>? conflictResults;
      if (conflicts.isNotEmpty) {
        final results = await VfsBatchConflictDialog.show(context, conflicts);

        if (results == null) {
          // 用户取消了操作
          return;
        }

        // 将结果列表转换为以文件路径为键的映射
        conflictResults = {};
        for (int i = 0; i < conflicts.length && i < results.length; i++) {
          conflictResults[conflicts[i].sourceFile.path] = results[i];
        }
      }

      // 执行文件操作
      int successCount = 0;
      for (final file in _clipboardFiles) {
        final sourcePath = file.path;
        final fileName = file.name;
        final targetPath = _currentPath.isEmpty
            ? fileName
            : '$_currentPath/$fileName';

        // 解析源路径以提取相对路径和集合信息
        final sourceVfsPath = VfsProtocol.parsePath(sourcePath);
        if (sourceVfsPath == null) {
          throw VfsException('Invalid source path format', path: sourcePath);
        }

        // 检查是否有冲突处理结果
        final conflictResult = conflictResults?[file.path];
        String finalTargetPath = targetPath;
        bool shouldSkip = false;
        bool shouldMerge = false;

        if (conflictResult != null) {
          switch (conflictResult.action) {
            case VfsConflictAction.skip:
              shouldSkip = true;
              break;
            case VfsConflictAction.rename:
              final pathSegments = targetPath.split('/');
              pathSegments[pathSegments.length - 1] = conflictResult.newName!;
              finalTargetPath = pathSegments.join('/');

              // 再次检查重命名后的路径是否仍有冲突
              final renamedFileExists = await _vfsService.getFileInfo(
                _selectedCollection!,
                finalTargetPath,
              );
              if (renamedFileExists != null) {
                // 如果重命名后仍有冲突，生成一个真正唯一的名称
                final uniqueName = await _generateUniqueFileName(
                  conflictResult.newName!,
                  finalTargetPath,
                );
                pathSegments[pathSegments.length - 1] = uniqueName;
                finalTargetPath = pathSegments.join('/');
              }
              break;
            case VfsConflictAction.merge:
              shouldMerge = true;
              break;
            case VfsConflictAction.overwrite:
              // 使用原始目标路径，允许覆盖
              break;
          }
        }

        if (shouldSkip) {
          continue;
        }

        try {
          if (_isCutOperation) {
            // 移动文件
            await _vfsService.moveFile(
              sourceVfsPath.collection,
              sourceVfsPath.path,
              _selectedCollection!,
              finalTargetPath,
            );
          } else {
            // 复制文件
            if (shouldMerge && file.isDirectory) {
              // 对于目录合并，需要递归处理子文件
              final defaultFileAction = ValueNotifier<VfsConflictAction?>(null);
              final defaultDirectoryAction = ValueNotifier<VfsConflictAction?>(
                null,
              );

              try {
                await _mergeDirectory(
                  sourceVfsPath.collection,
                  sourceVfsPath.path,
                  _selectedCollection!,
                  finalTargetPath,
                  defaultFileAction: defaultFileAction,
                  defaultDirectoryAction: defaultDirectoryAction,
                );
              } finally {
                defaultFileAction.dispose();
                defaultDirectoryAction.dispose();
              }
            } else {
              // 使用带冲突检测的复制方法
              final overwriteExisting =
                  conflictResult?.action == VfsConflictAction.overwrite;
              await _vfsService.copyFileWithConflictCheck(
                sourceVfsPath.collection,
                sourceVfsPath.path,
                _selectedCollection!,
                finalTargetPath,
                overwriteExisting: overwriteExisting,
              );
            }
          }
          successCount++;
        } catch (e) {
          // 记录单个文件的错误，但继续处理其他文件
          debugPrint(
            LocalizationService.instance.current.fileProcessingError_7281(
              file.name,
              e,
            ),
          );
        }
      }

      if (_isCutOperation) {
        _clipboardFiles.clear();
        _isCutOperation = false;
      }

      await _navigateToPath(_currentPath);
      _showInfoSnackBar(
        LocalizationService.instance.current.pasteCompleteSuccessfully(
          successCount,
        ),
      );
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.pasteFailed_7285(e),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 合并目录（递归处理子文件冲突）
  Future<void> _mergeDirectory(
    String sourceCollection,
    String sourcePath,
    String targetCollection,
    String targetPath, {
    ValueNotifier<VfsConflictAction?>? defaultFileAction,
    ValueNotifier<VfsConflictAction?>? defaultDirectoryAction,
  }) async {
    // 获取源目录下的所有文件
    final sourceFiles = await _vfsService.listFiles(
      sourceCollection,
      sourcePath.isEmpty ? null : sourcePath,
    );

    for (final sourceFile in sourceFiles) {
      final relativePath = sourceFile.path
          .replaceFirst('indexeddb://$_selectedDatabase/$sourceCollection/', '')
          .replaceFirst(sourcePath.isEmpty ? '' : '$sourcePath/', '');

      final newTargetPath = targetPath.isEmpty
          ? relativePath
          : '$targetPath/$relativePath';

      // 检查目标文件是否存在
      final existingFile = await _vfsService.getFileInfo(
        targetCollection,
        newTargetPath,
      );

      if (existingFile != null) {
        // 检查是否有对应类型的默认操作
        VfsConflictResult? conflictResult;
        final hasDefaultAction = sourceFile.isDirectory
            ? defaultDirectoryAction?.value != null
            : defaultFileAction?.value != null;

        if (hasDefaultAction) {
          // 使用默认操作
          final defaultAction = sourceFile.isDirectory
              ? defaultDirectoryAction!.value!
              : defaultFileAction!.value!;
          conflictResult = VfsConflictResult(
            action: defaultAction,
            newName: defaultAction == VfsConflictAction.rename
                ? await _generateUniqueFileName(sourceFile.name, newTargetPath)
                : null,
          );
        } else {
          // 显示冲突对话框
          final suggestedName = await _generateUniqueFileName(
            sourceFile.name,
            newTargetPath,
          );

          conflictResult = await VfsFileConflictDialog.show(
            context,
            VfsConflictInfo(
              fileName: sourceFile.name,
              isDirectory: sourceFile.isDirectory,
              existingFile: existingFile,
              sourceFile: sourceFile,
              suggestedName: suggestedName,
            ),
            showApplyToAll: true,
          );

          // 如果用户选择了"应用到全部"，更新对应类型的默认操作
          if (conflictResult?.applyToAll == true) {
            if (sourceFile.isDirectory) {
              defaultDirectoryAction?.value = conflictResult!.action;
            } else {
              defaultFileAction?.value = conflictResult!.action;
            }
          }
        }

        if (conflictResult == null ||
            conflictResult.action == VfsConflictAction.skip) {
          continue;
        }

        String finalPath = newTargetPath;
        if (conflictResult.action == VfsConflictAction.rename) {
          final pathSegments = newTargetPath.split('/');
          pathSegments[pathSegments.length - 1] = conflictResult.newName!;
          finalPath = pathSegments.join('/');

          // 再次检查重命名后的路径是否仍有冲突
          final renamedFileExists = await _vfsService.getFileInfo(
            targetCollection,
            finalPath,
          );
          if (renamedFileExists != null) {
            // 如果重命名后仍有冲突，生成一个真正唯一的名称
            final uniqueName = await _generateUniqueFileName(
              conflictResult.newName!,
              finalPath,
            );
            pathSegments[pathSegments.length - 1] = uniqueName;
            finalPath = pathSegments.join('/');
          }
        }

        if (sourceFile.isDirectory &&
            conflictResult.action == VfsConflictAction.merge) {
          // 对于目录合并，递归处理子文件，传递默认操作
          await _mergeDirectory(
            sourceCollection,
            sourceFile.path.replaceFirst(
              'indexeddb://$_selectedDatabase/$sourceCollection/',
              '',
            ),
            targetCollection,
            finalPath,
            defaultFileAction: defaultFileAction,
            defaultDirectoryAction: defaultDirectoryAction,
          );
        } else {
          // 对于文件或重命名/覆盖的目录
          await _vfsService.copyFileWithConflictCheck(
            sourceCollection,
            sourceFile.path.replaceFirst(
              'indexeddb://$_selectedDatabase/$sourceCollection/',
              '',
            ),
            targetCollection,
            finalPath,
            overwriteExisting:
                conflictResult.action == VfsConflictAction.overwrite,
          );
        }
      } else {
        // 没有冲突，直接复制
        await _vfsService.copyFileWithConflictCheck(
          sourceCollection,
          sourceFile.path.replaceFirst(
            'indexeddb://$_selectedDatabase/$sourceCollection/',
            '',
          ),
          targetCollection,
          newTargetPath,
          overwriteExisting: false,
        );
      }
    }
  }

  /// 删除文件
  Future<void> _deleteFiles(List<VfsFileInfo> files) async {
    final confirmed = await _showConfirmDialog(
      LocalizationService.instance.current.confirmDeletionTitle_4821,
      LocalizationService.instance.current.confirmDeletionMessage_4821(
        files.length,
      ),
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      for (final file in files) {
        await _vfsService.deleteFile(
          _selectedCollection!,
          file.path.replaceFirst(
            'indexeddb://$_selectedDatabase/$_selectedCollection/',
            '',
          ),
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
    final newName = await VfsFileRenameDialog.show(context, file);

    if (newName == null || newName == file.name) return;

    setState(() {
      _isLoading = true;
    });
    try {
      final oldPath = file.path.replaceFirst(
        'indexeddb://$_selectedDatabase/$_selectedCollection/',
        '',
      );
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
      _showInfoSnackBar(
        LocalizationService.instance.current.renameSuccess_4821,
      );
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.renameFailed_7285(e),
      );
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

  /// 打开文件
  Future<void> _openFile(VfsFileInfo file) async {
    try {
      await VfsFileOpenerService.openFile(context, file.path, fileInfo: file);
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.fileOpenFailed_7285(e),
      );
      // 如果文件打开失败，回退到显示文件元数据
      await _showFileMetadata(file);
    }
  }

  /// 管理文件权限
  Future<void> _managePermissions(VfsFileInfo file) async {
    try {
      final updatedPermissions = await VfsPermissionDialog.show(context, file);
      if (updatedPermissions != null) {
        // 权限已更新，刷新文件列表
        await _navigateToPath(_currentPath);
        _showInfoSnackBar(
          LocalizationService.instance.current.permissionUpdated_4821,
        );
      }
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.permissionFailed_7284(e),
      );
    }
  }

  /// 创建新文件夹
  Future<void> _createNewFolder() async {
    final name = await _showTextInputDialog(
      LocalizationService.instance.current.createFolderTitle_4821,
      LocalizationService.instance.current.folderNameHint_5732,
    );
    if (name == null || name.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final folderPath = _currentPath.isEmpty
          ? name.trim()
          : '$_currentPath/${name.trim()}';
      await _vfsService.createDirectory(_selectedCollection!, folderPath);
      await _navigateToPath(_currentPath);
      _showInfoSnackBar(
        LocalizationService.instance.current.folderCreatedSuccessfully_4821,
      );
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.createFolderFailed(e),
      );
      debugPrint(
        LocalizationService.instance.current.folderCreationFailed_7285(e),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 显示搜索对话框
  Future<void> _showSearchDialog() async {
    if (_selectedDatabase == null) {
      _showErrorSnackBar(
        LocalizationService.instance.current.selectDatabaseFirst_4821,
      );
      return;
    }

    final selectedFile = await VfsFileSearchDialog.show(
      context,
      _vfsService,
      _selectedDatabase!,
      _selectedCollection!,
      _currentPath,
    );

    if (selectedFile != null) {
      await _navigateToSelectedFile(selectedFile);
    }
  }

  /// 导航到选中的文件或文件夹
  Future<void> _navigateToSelectedFile(VfsFileInfo selectedFile) async {
    try {
      debugPrint(
        '🧭 Navigating to selected file: ${selectedFile.name} at path: ${selectedFile.path}',
      );

      // 解析文件路径，移除协议前缀
      String cleanPath = selectedFile.path;
      String? targetDatabase;
      String? targetCollection;

      if (cleanPath.startsWith('indexeddb://')) {
        final uri = Uri.parse(cleanPath);
        final pathSegments = uri.pathSegments
            .where((s) => s.isNotEmpty)
            .toList();
        debugPrint('🧭 URI path segments: $pathSegments');
        debugPrint('🧭 URI host: ${uri.host}');

        if (pathSegments.length >= 1) {
          targetDatabase = uri.host; // 数据库名在host部分
          targetCollection = pathSegments[0]; // 集合名是第一个路径段

          // 检查是否需要切换数据库/集合
          if (targetDatabase != _selectedDatabase ||
              targetCollection != _selectedCollection) {
            debugPrint(
              '🧭 Switching to database: $targetDatabase, collection: $targetCollection',
            );

            // 先切换数据库并加载集合列表
            if (targetDatabase != _selectedDatabase) {
              setState(() {
                _selectedDatabase = targetDatabase;
                _selectedCollection = null; // 先清空集合选择
              });
              await _loadCollections(targetDatabase!);
            }

            // 然后设置集合（确保集合存在于列表中）
            if (_collections[targetDatabase]?.contains(targetCollection) ==
                true) {
              setState(() {
                _selectedCollection = targetCollection;
              });
            } else {
              debugPrint(
                '🧭 Warning: Collection $targetCollection not found in database $targetDatabase',
              );
              setState(() {
                _selectedCollection = null;
              });
            }
          }

          // 构建相对于集合根目录的路径
          if (pathSegments.length > 1) {
            cleanPath = pathSegments.skip(1).join('/');
          } else {
            cleanPath = '';
          }
          debugPrint('🧭 Clean path after processing: "$cleanPath"');
        }
      }

      if (selectedFile.isDirectory) {
        // 如果是文件夹，直接导航到该文件夹
        debugPrint('🧭 Navigating to directory: "$cleanPath"');
        await _navigateToPath(cleanPath);
        _showInfoSnackBar('已导航到文件夹: ${selectedFile.name}');
      } else {
        // 如果是文件，导航到文件所在的文件夹并选中该文件
        final parentPath = cleanPath.contains('/')
            ? cleanPath.substring(0, cleanPath.lastIndexOf('/'))
            : '';

        debugPrint(
          '🧭 Navigating to parent directory: "$parentPath" for file: ${selectedFile.name}',
        );
        await _navigateToPath(parentPath);

        // 选中该文件
        setState(() {
          _selectedFiles.clear();
          _selectedFiles.add(selectedFile.path);
        });

        _showInfoSnackBar('已导航到文件: ${selectedFile.name}');
      }
    } catch (e) {
      debugPrint('🧭 Navigation failed: $e');
      _showErrorSnackBar('导航失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = widget.onFilesSelected != null;

    return FloatingWindow(
      title: isSelectionMode
          ? LocalizationService.instance.current.selectFiles_4821
          : LocalizationService.instance.current.vfsFileManager_4821,
      subtitle: _buildSubtitle(),
      icon: Icons.folder_special,
      onClose: widget.onClose,
      headerActions: _buildActionButtons(),
      showCloseButton: !isSelectionMode, // 在选择模式下隐藏关闭按钮，因为已经有"取消"按钮
      child: Column(
        children: [
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
    );
  }

  /// 构建副标题
  String? _buildSubtitle() {
    final isSelectionMode = widget.onFilesSelected != null;

    if (!isSelectionMode) return null;

    String subtitle = _buildSelectionModeDescription();

    if (_selectedFiles.isNotEmpty) {
      subtitle += ' - 已选择 ${_selectedFiles.length} 个项目';
    }

    return subtitle;
  }

  /// 构建操作按钮
  List<Widget> _buildActionButtons() {
    final isSelectionMode = widget.onFilesSelected != null;

    if (isSelectionMode) {
      return [
        TextButton(
          onPressed: () {
            widget.onClose?.call();
          },
          child: Text(LocalizationService.instance.current.cancel),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _canConfirmSelection()
              ? () {
                  widget.onFilesSelected?.call(_selectedFiles.toList());
                }
              : null,
          child: Text(LocalizationService.instance.current.confirmButton_4821),
        ),
      ];
    } else {
      return [
        IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.close),
          tooltip: LocalizationService.instance.current.close,
        ),
      ];
    }
  }

  /// 构建工具栏
  Widget _buildToolbar() {
    // 获取当前标签页索引
    final currentTabIndex = _tabController.index;
    // 判断是否为文件浏览标签页
    final isFileBrowserTab = currentTabIndex == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          // 数据库和集合选择（仅在文件浏览页显示）
          if (isFileBrowserTab) ...[
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
                    items:
                        _collections[_selectedDatabase]?.map((collection) {
                          return DropdownMenuItem(
                            value: collection,
                            child: Text(collection),
                          );
                        }).toList() ??
                        [],
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
          ],

          // 工具按钮和标签栏
          Row(
            children: [
              // 导航按钮（仅在文件浏览页显示）
              if (isFileBrowserTab) ...[
                Row(
                  children: [
                    IconButton(
                      onPressed: _historyIndex > 0
                          ? () async {
                              _historyIndex--;
                              await _navigateToPath(
                                _pathHistory[_historyIndex],
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: LocalizationService.instance.current.back_4821,
                    ),
                    IconButton(
                      onPressed: _historyIndex < _pathHistory.length - 1
                          ? () async {
                              _historyIndex++;
                              await _navigateToPath(
                                _pathHistory[_historyIndex],
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      tooltip:
                          LocalizationService.instance.current.forward_4821,
                    ),
                    IconButton(
                      onPressed: () => _navigateToPath(''),
                      icon: const Icon(Icons.home),
                      tooltip: LocalizationService
                          .instance
                          .current
                          .rootDirectory_4821,
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // 操作按钮
                Row(
                  children: [
                    // 批量操作按钮（仅在有选中文件时显示）
                    if (_selectedFiles.isNotEmpty) ...[
                      Text(
                        '已选择 ${_selectedFiles.length} 项',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final selectedFileInfos = _currentFiles
                              .where(
                                (file) => _selectedFiles.contains(file.path),
                              )
                              .toList();
                          _copyFiles(selectedFileInfos);
                        },
                        icon: const Icon(Icons.copy),
                        tooltip: LocalizationService
                            .instance
                            .current
                            .copySelected_4821,
                      ),
                      IconButton(
                        onPressed: () {
                          final selectedFileInfos = _currentFiles
                              .where(
                                (file) => _selectedFiles.contains(file.path),
                              )
                              .toList();
                          _cutFiles(selectedFileInfos);
                        },
                        icon: const Icon(Icons.cut),
                        tooltip: LocalizationService
                            .instance
                            .current
                            .cutSelected_4821,
                      ),
                      IconButton(
                        onPressed: () {
                          final selectedFileInfos = _currentFiles
                              .where(
                                (file) => _selectedFiles.contains(file.path),
                              )
                              .toList();
                          _deleteFiles(selectedFileInfos);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: LocalizationService
                            .instance
                            .current
                            .deleteSelected_4821,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedFiles.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                        tooltip:
                            LocalizationService.instance.current.clear_4821,
                      ),
                      const SizedBox(width: 16),
                    ],
                    IconButton(
                      onPressed: _createNewFolder,
                      icon: const Icon(Icons.create_new_folder),
                      tooltip: LocalizationService
                          .instance
                          .current
                          .createFolder_4821,
                    ),
                    IconButton(
                      onPressed: () => _navigateToPath(_currentPath),
                      icon: const Icon(Icons.refresh),
                      tooltip:
                          LocalizationService.instance.current.refresh_4976,
                    ),
                    IconButton(
                      onPressed: _showCurrentPathPermissions,
                      icon: const Icon(Icons.security),
                      tooltip: LocalizationService
                          .instance
                          .current
                          .viewFolderPermissions_4821,
                    ),
                    IconButton(
                      onPressed: _showSearchDialog,
                      icon: const Icon(Icons.search),
                      tooltip: LocalizationService.instance.current.search_4821,
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort),
                      tooltip: LocalizationService.instance.current.sort_4821,
                      onSelected: (value) {
                        setState(() {
                          if (value == _sortType.name) {
                            _sortAscending = !_sortAscending;
                          } else {
                            _sortType = _SortType.values.firstWhere(
                              (e) => e.name == value,
                            );
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
                              Icon(
                                _sortType == _SortType.name
                                    ? (_sortAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward)
                                    : Icons.sort_by_alpha,
                              ),
                              const SizedBox(width: 8),
                              const Text('按名称'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'size',
                          child: Row(
                            children: [
                              Icon(
                                _sortType == _SortType.size
                                    ? (_sortAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward)
                                    : Icons.data_usage,
                              ),
                              const SizedBox(width: 8),
                              const Text('按大小'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'modified',
                          child: Row(
                            children: [
                              Icon(
                                _sortType == _SortType.modified
                                    ? (_sortAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward)
                                    : Icons.access_time,
                              ),
                              const SizedBox(width: 8),
                              const Text('按修改时间'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'type',
                          child: Row(
                            children: [
                              Icon(
                                _sortType == _SortType.type
                                    ? (_sortAscending
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward)
                                    : Icons.category,
                              ),
                              const SizedBox(width: 8),
                              const Text('按类型'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<_ViewType>(
                      icon: Icon(
                        _viewType == _ViewType.list
                            ? Icons.view_list
                            : Icons.grid_view,
                      ),
                      tooltip: LocalizationService.instance.current.view_4821,
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
                        tooltip:
                            LocalizationService.instance.current.paste_4821,
                      ),
                    ],

                    // 上传按钮（支持文件和文件夹）
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.upload),
                      tooltip: LocalizationService.instance.current.upload_4821,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'files',
                          child: Row(
                            children: [
                              Icon(Icons.upload_file),
                              SizedBox(width: 8),
                              Text(
                                LocalizationService
                                    .instance
                                    .current
                                    .uploadFiles_4821,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'folder',
                          child: Row(
                            children: [
                              Icon(Icons.drive_folder_upload),
                              SizedBox(width: 8),
                              Text(
                                LocalizationService
                                    .instance
                                    .current
                                    .uploadFolder_4821,
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) => _handleUpload(value),
                    ), // 下载按钮（支持文件和文件夹）
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.download),
                      tooltip:
                          LocalizationService.instance.current.download_4821,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'selected',
                          child: Row(
                            children: [
                              Icon(Icons.download),
                              SizedBox(width: 8),
                              Text(
                                LocalizationService
                                    .instance
                                    .current
                                    .downloadSelected_4821,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'selected_zip',
                          child: Row(
                            children: [
                              Icon(Icons.archive),
                              SizedBox(width: 8),
                              Text(
                                LocalizationService
                                    .instance
                                    .current
                                    .downloadSelectedCompressed_4821,
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'all',
                          child: Row(
                            children: [
                              Icon(Icons.download_for_offline),
                              SizedBox(width: 8),
                              Text(
                                LocalizationService
                                    .instance
                                    .current
                                    .downloadCurrentDirectory_4821,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'all_zip',
                          child: Row(
                            children: [
                              Icon(Icons.folder_zip),
                              SizedBox(width: 8),
                              Text(
                                LocalizationService
                                    .instance
                                    .current
                                    .downloadCurrentDirectoryCompressed_4821,
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) => _handleDownload(value),
                    ),
                  ],
                ),
              ],

              const Spacer(),

              // 标签栏（始终显示）
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(
                    icon: Icon(Icons.folder),
                    text: LocalizationService.instance.current.fileBrowser_4821,
                  ),
                  Tab(
                    icon: Icon(Icons.info),
                    text: LocalizationService.instance.current.metadata_4821,
                  ),
                  Tab(
                    icon: Icon(Icons.settings),
                    text: LocalizationService.instance.current.settings_4821,
                  ),
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
              child: Text(LocalizationService.instance.current.retry_4821),
            ),
          ],
        ),
      );
    }
    final filesToShow = _isSearchMode ? _searchResults : _currentFiles;
    return Column(
      children: [
        // 路径导航或搜索状态栏
        if (!_isSearchMode) _buildPathNavigation() else _buildSearchStatusBar(),

        // 批量操作栏（当有文件时显示）
        if (filesToShow.isNotEmpty) _buildBatchOperationBar(filesToShow),

        // 文件列表
        Expanded(
          child: filesToShow.isEmpty
              ? Container(
                  width: double.infinity,
                  child: Center(
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
                          _isSearchMode
                              ? LocalizationService
                                    .instance
                                    .current
                                    .noMatchingFiles_4821
                              : LocalizationService
                                    .instance
                                    .current
                                    .folderEmpty_4821,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          LocalizationService
                              .instance
                              .current
                              .useToolbarToCreateFolder_4821,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  child: _viewType == _ViewType.list
                      ? _buildFileList(filesToShow)
                      : _buildFileGrid(filesToShow),
                ),
        ),
      ],
    );
  }

  /// 构建路径导航
  Widget _buildPathNavigation() {
    if (_selectedDatabase == null || _selectedCollection == null) {
      return Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              LocalizationService
                  .instance
                  .current
                  .pleaseSelectDatabaseAndCollection_4821,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    final pathParts = _parsePath(_currentPath);
    final breadcrumbs = _buildPathBreadcrumbs(pathParts);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 16,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: breadcrumbs),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索状态栏
  Widget _buildSearchStatusBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 16,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              LocalizationService.instance.current.searchResults_4821(
                _searchQuery,
              ),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isSearchMode = false;
                _searchQuery = '';
                _searchResults.clear();
              });
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              LocalizationService.instance.current.clear_4821,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 解析路径为面包屑组件
  List<Map<String, String>> _parsePath(String path) {
    final parts = <Map<String, String>>[];

    // 添加根路径
    parts.add({
      'name': '🏠 ${LocalizationService.instance.current.rootDirectory_4821}',
      'path': '',
      'isLast': 'false',
    });

    // 如果有选择的数据库，添加数据库路径
    if (_selectedDatabase != null) {
      parts.add({
        'name': '📁 $_selectedDatabase',
        'path': '',
        'isLast': 'false',
      });
    }

    // 如果有选择的集合，添加集合路径
    if (_selectedCollection != null) {
      parts.add({
        'name': '📂 $_selectedCollection',
        'path': '',
        'isLast': 'false',
      });
    }
    // 添加当前路径中的所有子文件夹
    if (_currentPath.isNotEmpty) {
      final currentSegments = _currentPath
          .split('/')
          .where((s) => s.isNotEmpty)
          .toList();

      for (int i = 0; i < currentSegments.length; i++) {
        final segment = currentSegments[i];
        // 构建到此文件夹的路径（相对于集合根目录）
        final folderPath = currentSegments.take(i + 1).join('/');

        parts.add({
          'name': '📂 $segment',
          'path': folderPath,
          'isLast': i == currentSegments.length - 1 ? 'true' : 'false',
        });
      }
    }

    // 更新最后一个元素的状态
    if (parts.isNotEmpty) {
      parts.last['isLast'] = 'true';
    }

    return parts;
  }

  /// 构建面包屑组件
  List<Widget> _buildPathBreadcrumbs(List<Map<String, String>> pathParts) {
    final widgets = <Widget>[];

    for (int i = 0; i < pathParts.length; i++) {
      final part = pathParts[i];
      final isLast = part['isLast'] == 'true';
      final isRoot = part['path'] == '' && i == 0;

      // 添加路径组件
      widgets.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLast
                ? null
                : () => _navigateToPathFromBreadcrumb(part['path']!, i),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLast
                    ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : isRoot
                    ? Theme.of(
                        context,
                      ).colorScheme.secondaryContainer.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isLast
                    ? Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5),
                        width: 1,
                      )
                    : null,
              ),
              child: Text(
                part['name']!,
                style: TextStyle(
                  fontSize: 12,
                  color: isLast
                      ? Theme.of(context).colorScheme.primary
                      : isRoot
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      );

      // 添加分隔符（除了最后一个）
      if (i < pathParts.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.chevron_right,
              size: 14,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  /// 从面包屑导航到路径
  Future<void> _navigateToPathFromBreadcrumb(String path, int index) async {
    if (index == 0) {
      // 回到根目录 - 清空所有选择
      setState(() {
        _selectedDatabase = null;
        _selectedCollection = null;
        _collections.clear();
        _currentFiles.clear();
        _currentPath = '';
        _selectedFiles.clear();
      });
      return;
    }

    if (index == 1) {
      // 导航到数据库级别（清空集合选择）
      setState(() {
        _selectedCollection = null;
        _currentFiles.clear();
        _currentPath = '';
        _selectedFiles.clear();
      });
      return;
    }

    if (index == 2) {
      // 导航到集合根目录
      await _navigateToPath('');
      return;
    }

    // 导航到指定的子文件夹路径
    await _navigateToPath(path);
  }

  /// 构建文件列表视图
  Widget _buildFileList(List<VfsFileInfo> files) {
    // 如果没有文件，显示空白信息
    if (files.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('此文件夹为空', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // 当有文件时，使用常规 ListView
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = _selectedFiles.contains(file.path);
        return ContextMenuWrapper(
          menuBuilder: (context) => _buildFileContextMenu(file),
          child: _FileListItem(
            file: file,
            isSelected: isSelected,
            isCutToClipboard:
                _isCutOperation &&
                _clipboardFiles.any((f) => f.path == file.path),
            canBeSelected: _canSelectFile(file),
            onTap: () {
              if (_selectedFiles.isNotEmpty) {
                // 如果有已选择的文件，优先处理选择逻辑
                _toggleFileSelection(file);
              } else if (file.isDirectory) {
                // 文件夹总是可以导航，无论选择模式如何
                final newPath = _currentPath.isEmpty
                    ? file.name
                    : '$_currentPath/${file.name}';
                _navigateToPath(newPath);
              } else {
                // 对于文件，根据模式决定行为
                if (widget.onFilesSelected == null) {
                  // 浏览模式：打开文件
                  _openFile(file);
                } else {
                  // 选择模式：如果可以选择则选择，否则显示元数据
                  if (_canSelectFile(file)) {
                    _toggleFileSelection(file);
                  } else {
                    _showFileMetadata(file);
                  }
                }
              }
            },
            onLongPress: () => _toggleFileSelection(file),
            onSelectionChanged: _canSelectFile(file)
                ? (value) => setState(() {
                    if (value == true) {
                      // 单选模式下，先清空之前的选择
                      if (!widget.allowMultipleSelection) {
                        _selectedFiles.clear();
                      }
                      _selectedFiles.add(file.path);
                    } else {
                      _selectedFiles.remove(file.path);
                    }
                  })
                : null,
            formatFileSize: _formatFileSize,
            formatDateTime: _formatDateTime,
            getFileIcon: _getFileIcon,
            buildPermissionIndicator: _buildPermissionIndicator,
          ),
        );
      },
    );
  }

  /// 构建文件网格视图

  Widget _buildFileGrid(List<VfsFileInfo> files) {
    // 如果没有文件，显示空白信息
    if (files.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('此文件夹为空', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
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
          child: _FileGridItem(
            file: file,
            isSelected: isSelected,
            isCutToClipboard:
                _isCutOperation &&
                _clipboardFiles.any((f) => f.path == file.path),
            canBeSelected: _canSelectFile(file),
            onSelectionChanged: _canSelectFile(file)
                ? (value) => setState(() {
                    if (value == true) {
                      // 单选模式下，先清空之前的选择
                      if (!widget.allowMultipleSelection) {
                        _selectedFiles.clear();
                      }
                      _selectedFiles.add(file.path);
                    } else {
                      _selectedFiles.remove(file.path);
                    }
                  })
                : null,
            formatFileSize: _formatFileSize,
            getFileIcon: _getFileIcon,
            onTap: () {
              if (_selectedFiles.isNotEmpty) {
                // 如果有已选择的文件，优先处理选择逻辑
                _toggleFileSelection(file);
              } else if (file.isDirectory) {
                // 文件夹总是可以导航，无论选择模式如何
                final newPath = _currentPath.isEmpty
                    ? file.name
                    : '$_currentPath/${file.name}';
                _navigateToPath(newPath);
              } else {
                // 对于文件，根据模式决定行为
                if (widget.onFilesSelected == null) {
                  // 浏览模式：打开文件
                  _openFile(file);
                } else {
                  // 选择模式：如果可以选择则选择，否则显示元数据
                  if (_canSelectFile(file)) {
                    _toggleFileSelection(file);
                  } else {
                    _showFileMetadata(file);
                  }
                }
              }
            },
            onLongPress: () => _toggleFileSelection(file),
          ),
        );
      },
    );
  }

  /// 构建文件上下文菜单
  List<ContextMenuItem> _buildFileContextMenu(VfsFileInfo file) {
    // 检查当前文件是否被选中
    final isCurrentFileSelected = _selectedFiles.contains(file.path);
    // 检查是否有多个文件被选中
    final hasMultipleSelected = _selectedFiles.length > 1;
    // 检查是否有任何文件被选中
    final hasSelected = _selectedFiles.isNotEmpty;

    // 如果当前文件被选中且有多个选中项，显示批处理菜单
    if (isCurrentFileSelected && hasMultipleSelected) {
      return _buildBatchContextMenu();
    }

    // 如果当前文件被选中且只有一个文件被选中，显示单文件菜单（保持选择状态）
    if (isCurrentFileSelected && _selectedFiles.length == 1) {
      // 不清除选择，显示单文件菜单
    }

    // 如果当前文件未被选中但有其他文件被选中，清除选择并显示单文件菜单
    if (!isCurrentFileSelected && hasSelected) {
      // 清除所有选择
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedFiles.clear();
        });
      });
    }

    // 显示单文件上下文菜单
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
      else ...[
        // 在浏览模式下显示"打开"选项，在选择模式下显示"查看详情"
        if (widget.onFilesSelected == null)
          ContextMenuItem(
            label: '打开',
            icon: Icons.open_in_new,
            onTap: () => _openFile(file),
          ),
        ContextMenuItem(
          label: '查看详情',
          icon: Icons.info,
          onTap: () => _showFileMetadata(file),
        ),
      ],

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
        ContextMenuItem(label: '粘贴', icon: Icons.paste, onTap: _pasteFiles),
      const ContextMenuItem.divider(),

      // 下载选项
      ContextMenuItem(
        label: '下载',
        icon: Icons.download,
        onTap: () => _downloadFiles([file], compress: false),
      ),
      if (file.isDirectory)
        ContextMenuItem(
          label: '下载为压缩包',
          icon: Icons.archive,
          onTap: () => _downloadFiles([file], compress: true),
        ),

      const ContextMenuItem.divider(),
      ContextMenuItem(
        label: '重命名',
        icon: Icons.edit,
        onTap: () => _renameFile(file),
      ),
      ContextMenuItem(
        label: '权限管理',
        icon: Icons.security,
        onTap: () => _managePermissions(file),
      ),
      ContextMenuItem(
        label: '删除',
        icon: Icons.delete,
        onTap: () => _deleteFiles([file]),
      ),
    ];
  }

  /// 构建批处理上下文菜单
  List<ContextMenuItem> _buildBatchContextMenu() {
    final selectedFiles = _currentFiles
        .where((file) => _selectedFiles.contains(file.path))
        .toList();

    return [
      ContextMenuItem(
        label: '复制选中项',
        icon: Icons.copy,
        onTap: () => _copyFiles(selectedFiles),
      ),
      ContextMenuItem(
        label: '剪切选中项',
        icon: Icons.cut,
        onTap: () => _cutFiles(selectedFiles),
      ),
      if (_clipboardFiles.isNotEmpty)
        ContextMenuItem(label: '粘贴', icon: Icons.paste, onTap: _pasteFiles),

      const ContextMenuItem.divider(),

      // 下载选项
      ContextMenuItem(
        label: '下载选中项',
        icon: Icons.download,
        onTap: () => _downloadFiles(selectedFiles, compress: false),
      ),
      ContextMenuItem(
        label: '下载为压缩包',
        icon: Icons.archive,
        onTap: () => _downloadFiles(selectedFiles, compress: true),
      ),

      const ContextMenuItem.divider(),

      ContextMenuItem(
        label: '删除选中项',
        icon: Icons.delete,
        onTap: () => _deleteFiles(selectedFiles),
      ),

      const ContextMenuItem.divider(),

      ContextMenuItem(
        label: '取消选择',
        icon: Icons.clear,
        onTap: () {
          setState(() {
            _selectedFiles.clear();
          });
        },
      ),
    ];
  }

  /// 显示当前路径权限信息
  Future<void> _showCurrentPathPermissions() async {
    if (_selectedDatabase == null || _selectedCollection == null) return;

    try {
      // 构建当前路径的完整URI
      final pathUri =
          'indexeddb://$_selectedDatabase/$_selectedCollection'
          '${_currentPath.isEmpty ? '/' : '/$_currentPath/'}';

      // 创建一个虚拟的文件信息对象来表示当前目录
      final currentDirInfo = VfsFileInfo(
        name: _currentPath.isEmpty
            ? LocalizationService.instance.current.rootDirectory_7421
            : _currentPath.split('/').last,
        path: pathUri,
        size: 0,
        isDirectory: true,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      await _managePermissions(currentDirInfo);
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.permissionViewError_4821(e),
      );
    }
  }

  /// 构建元数据视图
  Widget _buildMetadataView() {
    // 获取当前选中的文件
    final selectedFileInfos = _currentFiles
        .where((file) => _selectedFiles.contains(file.path))
        .toList();

    // 如果没有选中任何文件，显示提示信息
    if (selectedFileInfos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              LocalizationService
                  .instance
                  .current
                  .selectFileToViewMetadata_7281,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 如果选中了多个文件，显示汇总信息
          if (selectedFileInfos.length > 1) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.checklist,
                          size: 32,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            LocalizationService.instance.current
                                .selectedItemsCount(
                                  selectedFileInfos.length,
                                  _currentFiles.length,
                                ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    _buildMetadataRow(
                      LocalizationService.instance.current.totalCount_7281,
                      selectedFileInfos.length.toString(),
                    ),
                    _buildMetadataRow(
                      LocalizationService.instance.current.folderCount_4821,
                      selectedFileInfos
                          .where((f) => f.isDirectory)
                          .length
                          .toString(),
                    ),
                    _buildMetadataRow(
                      LocalizationService.instance.current.fileCount_4821,
                      selectedFileInfos
                          .where((f) => !f.isDirectory)
                          .length
                          .toString(),
                    ),
                    _buildMetadataRow(
                      LocalizationService.instance.current.totalSize_4821,
                      _formatFileSize(
                        selectedFileInfos.fold(
                          0,
                          (sum, file) => sum + file.size,
                        ),
                      ),
                    ),

                    // 显示文件类型统计
                    if (selectedFileInfos.any((f) => !f.isDirectory)) ...[
                      const Divider(),
                      Text(
                        LocalizationService
                            .instance
                            .current
                            .fileTypeStatistics_4821,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._buildFileTypeStatistics(selectedFileInfos),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 显示所有选中文件的列表
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService.instance.current.selectedFile_7281,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...selectedFileInfos.map(
                      (file) => _buildFileListItem(file),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // 单个文件的详细信息
            _buildSingleFileMetadata(selectedFileInfos.first),
          ],
        ],
      ),
    );
  }

  /// 构建单个文件的元数据视图
  Widget _buildSingleFileMetadata(VfsFileInfo file) {
    return Card(
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
                  color: file.isDirectory
                      ? Theme.of(context).colorScheme.primary
                      : null,
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

            _buildMetadataRow(
              LocalizationService.instance.current.typeLabel_4821,
              file.isDirectory
                  ? LocalizationService.instance.current.folderType_4821
                  : LocalizationService.instance.current.fileType_4821,
            ),
            _buildMetadataRow(
              LocalizationService.instance.current.fileSize_4821,
              _formatFileSize(file.size),
            ),
            _buildMetadataRow(
              LocalizationService.instance.current.creationTime_4821,
              _formatDateTime(file.createdAt),
            ),
            _buildMetadataRow(
              LocalizationService.instance.current.modifiedTime_4821,
              _formatDateTime(file.modifiedAt),
            ),

            if (file.mimeType != null)
              _buildMetadataRow(
                LocalizationService.instance.current.mimeType_4821,
                file.mimeType!,
              ),

            if (file.metadata != null && file.metadata!.isNotEmpty) ...[
              const Divider(),
              Text(
                LocalizationService.instance.current.customMetadata_7281,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final entry in file.metadata!.entries)
                _buildMetadataRow(entry.key, entry.value.toString()),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建文件类型统计
  List<Widget> _buildFileTypeStatistics(List<VfsFileInfo> files) {
    final fileTypeCount = <String, int>{};

    for (final file in files) {
      if (!file.isDirectory) {
        String type;
        if (file.mimeType != null) {
          type = file.mimeType!;
        } else {
          final extension = file.name.split('.').last.toLowerCase();
          type = extension.isEmpty
              ? LocalizationService.instance.current.noExtension_7281
              : '.$extension';
        }
        fileTypeCount[type] = (fileTypeCount[type] ?? 0) + 1;
      }
    }

    return fileTypeCount.entries
        .map(
          (entry) => _buildMetadataRow(
            entry.key,
            '${LocalizationService.instance.current.fileCount(entry.value)}',
          ),
        )
        .toList();
  }

  /// 构建文件列表项
  Widget _buildFileListItem(VfsFileInfo file) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            file.isDirectory ? Icons.folder : _getFileIcon(file),
            size: 20,
            color: file.isDirectory
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              file.name,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatFileSize(file.size),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
          Expanded(child: Text(value)),
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
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService.instance.current.storageInfo_7281,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  if (_selectedDatabase != null &&
                      _selectedCollection != null) ...[
                    _buildMetadataRow(
                      LocalizationService.instance.current.databaseLabel_4821,
                      _selectedDatabase!,
                    ),
                    _buildMetadataRow(
                      LocalizationService.instance.current.collectionLabel_4821,
                      _selectedCollection!,
                    ),
                    _buildMetadataRow(
                      LocalizationService.instance.current.totalFiles_4821,
                      _currentFiles.length.toString(),
                    ),
                    _buildMetadataRow(
                      LocalizationService.instance.current.selectedCount_7284,
                      _selectedFiles.length.toString(),
                    ),
                  ] else
                    Text(
                      LocalizationService
                          .instance
                          .current
                          .selectDatabaseAndCollection_7421,
                    ),
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
    // 检查是否可以选择此文件
    if (!_canSelectFile(file)) {
      // 显示详细的提示信息
      String message = '';

      // 检查选择类型限制
      switch (widget.selectionType) {
        case SelectionType.filesOnly:
          if (file.isDirectory) {
            message = LocalizationService
                .instance
                .current
                .fileSelectionModeWarning_4821;
          }
          break;
        case SelectionType.directoriesOnly:
          if (!file.isDirectory) {
            message = LocalizationService
                .instance
                .current
                .folderSelectionRequired_4821;
          }
          break;
        case SelectionType.both:
          // 继续其他检查
          break;
      }

      // 向后兼容的目录选择检查
      if (message.isEmpty &&
          file.isDirectory &&
          widget.allowDirectorySelection == false) {
        message = LocalizationService
            .instance
            .current
            .directorySelectionNotAllowed_4821;
      }

      // 检查文件扩展名限制
      if (message.isEmpty &&
          !file.isDirectory &&
          widget.allowedExtensions != null &&
          widget.allowedExtensions!.isNotEmpty) {
        final extension = file.name.split('.').last.toLowerCase();
        final allowedExts = widget.allowedExtensions!.join(', ');
        message = LocalizationService.instance.current.unsupportedFileType(
          extension,
        );
      }

      if (message.isNotEmpty) {
        _showErrorSnackBar(message);
      }
      return;
    }

    setState(() {
      if (_selectedFiles.contains(file.path)) {
        _selectedFiles.remove(file.path);
      } else {
        // 单选模式下，先清空之前的选择
        if (!widget.allowMultipleSelection) {
          _selectedFiles.clear();
        }
        _selectedFiles.add(file.path);
      }
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
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
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
            child: Text(LocalizationService.instance.current.cancelButton_7421),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              LocalizationService.instance.current.confirmButton_7281,
            ),
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
            child: Text(LocalizationService.instance.current.cancelButton_7421),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(
              LocalizationService.instance.current.confirmButton_7281,
            ),
          ),
        ],
      ),
    );

    return result;
  }

  /// 显示成功消息
  void _showInfoSnackBar(String message) {
    context.showSuccessSnackBar(message);
  }

  /// 显示错误消息
  void _showErrorSnackBar(String message) {
    context.showErrorSnackBar(message);
  }

  /// 构建权限指示器
  Widget _buildPermissionIndicator(VfsFileInfo file) {
    // 根据文件路径判断是否为系统保护文件
    final isSystemProtected =
        file.path.contains('/.initialized') ||
        file.path.contains('/mnt/') ||
        file.path == 'indexeddb://r6box/fs/.initialized' ||
        file.path.startsWith('indexeddb://r6box/fs/mnt/');

    if (isSystemProtected) {
      return Tooltip(
        message: LocalizationService.instance.current.systemProtectedFile_4821,
        child: Icon(Icons.shield, size: 16, color: Colors.orange),
      );
    }

    // 对于普通文件，显示简单的权限指示
    return Tooltip(
      message: LocalizationService.instance.current.userFile_4821,
      child: Icon(Icons.lock_open, size: 16, color: Colors.green.shade600),
    );
  }

  /// 构建批量操作栏
  Widget _buildBatchOperationBar(List<VfsFileInfo> files) {
    final hasFiles = files.isNotEmpty;
    final allSelected = hasFiles && _selectedFiles.length == files.length;
    final someSelected = _selectedFiles.isNotEmpty;
    final isMultipleSelectionAllowed = widget.allowMultipleSelection;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          // 全选复选框 - 在单选模式下禁用
          Checkbox(
            value: allSelected ? true : (someSelected ? null : false),
            tristate: true,
            onChanged: isMultipleSelectionAllowed
                ? (value) {
                    setState(() {
                      if (allSelected || someSelected) {
                        // 清除所有选择
                        _selectedFiles.clear();
                      } else {
                        // 全选 - 只选择可选择的文件
                        _selectedFiles.clear();
                        for (final file in files) {
                          if (_canSelectFile(file)) {
                            _selectedFiles.add(file.path);
                          }
                        }
                      }
                    });
                  }
                : null, // 单选模式下禁用
          ),
          const SizedBox(width: 8),
          Text(
            someSelected
                ? LocalizationService.instance.current.selectedItemsCount(
                    _selectedFiles.length,
                    files.length,
                  )
                : isMultipleSelectionAllowed
                ? LocalizationService.instance.current.selectAllWithCount(
                    files.length,
                  )
                : LocalizationService.instance.current
                      .singleSelectionModeWithCount(files.length),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: someSelected
                  ? Theme.of(context).colorScheme.primary
                  : isMultipleSelectionAllowed
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),

          // 批量操作按钮（仅在有选中项时显示）
          if (someSelected) ...[
            IconButton(
              onPressed: () {
                final selectedFileInfos = files
                    .where((file) => _selectedFiles.contains(file.path))
                    .toList();
                _copyFiles(selectedFileInfos);
              },
              icon: const Icon(Icons.copy),
              tooltip:
                  LocalizationService.instance.current.copySelectedItems_4821,
              iconSize: 20,
            ),
            IconButton(
              onPressed: () {
                final selectedFileInfos = files
                    .where((file) => _selectedFiles.contains(file.path))
                    .toList();
                _cutFiles(selectedFileInfos);
              },
              icon: const Icon(Icons.cut),
              tooltip:
                  LocalizationService.instance.current.cutSelectedItems_4821,
              iconSize: 20,
            ),
            IconButton(
              onPressed: () {
                final selectedFileInfos = files
                    .where((file) => _selectedFiles.contains(file.path))
                    .toList();
                _deleteFiles(selectedFileInfos);
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip:
                  LocalizationService.instance.current.deleteSelectedItems_4821,
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }

  /// 处理上传操作
  Future<void> _handleUpload(String uploadType) async {
    if (_selectedDatabase == null || _selectedCollection == null) {
      _showErrorSnackBar(
        LocalizationService
            .instance
            .current
            .selectDatabaseAndCollectionFirst_7281,
      );
      return;
    }

    try {
      switch (uploadType) {
        case 'files':
          await _uploadFiles();
          break;
        case 'folder':
          await _uploadFolder();
          break;
      }
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.uploadFailedWithError(e),
      );
    }
  }

  /// 上传文件
  Future<void> _uploadFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty) return;

    await _processFileUploads(result.files);
  }

  /// 上传文件夹
  Future<void> _uploadFolder() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;

    final directory = Directory(selectedDirectory);
    if (!directory.existsSync()) {
      _showErrorSnackBar(
        LocalizationService.instance.current.folderNotExist_4821,
      );
      return;
    }

    await _processFolderUpload(directory);
  }

  /// 处理文件上传
  Future<void> _processFileUploads(List<PlatformFile> files) async {
    setState(() {
      _isLoading = true;
    });

    try {
      int successCount = 0;
      for (var file in files) {
        final targetFilePath = _currentPath.isEmpty
            ? file.name
            : '$_currentPath/${file.name}';

        if (file.bytes != null) {
          // Web平台：使用bytes
          await _vfsService.vfs.writeBinaryFile(
            'indexeddb://$_selectedDatabase/$_selectedCollection/$targetFilePath',
            file.bytes!,
            mimeType: _getMimeType(file.name),
          );
          successCount++;
        } else if (file.path != null) {
          // 桌面平台：使用path
          final localFile = File(file.path!);
          if (localFile.existsSync()) {
            final fileData = await localFile.readAsBytes();
            await _vfsService.vfs.writeBinaryFile(
              'indexeddb://$_selectedDatabase/$_selectedCollection/$targetFilePath',
              fileData,
              mimeType: _getMimeType(file.name),
            );
            successCount++;
          }
        }
      }

      _showInfoSnackBar(
        LocalizationService.instance.current.fileUploadSuccess(successCount),
      );
      await _refreshCurrentDirectory();
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.fileUploadFailed_7284(e),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 处理文件夹上传
  Future<void> _processFolderUpload(Directory directory) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _collectFilesRecursively(directory);
      int successCount = 0;

      // 获取文件夹名称（不是完整路径）
      final folderName = directory.path.split(Platform.pathSeparator).last;

      for (var fileEntry in files) {
        final localFile = File(fileEntry.path);
        if (localFile.existsSync()) {
          final fileData = await localFile.readAsBytes();

          // 正确计算相对路径：保留文件夹名称
          final fullRelativePath = fileEntry.path.substring(
            directory.parent.path.length + 1,
          );

          // 将本地路径分隔符转换为VFS路径分隔符
          final normalizedPath = fullRelativePath.replaceAll(
            Platform.pathSeparator,

            '/',
          );

          // 构建目标文件路径
          final targetFilePath = _currentPath.isEmpty
              ? normalizedPath
              : '$_currentPath/$normalizedPath';

          // 创建必要的目录结构
          await _ensureDirectoryStructure(targetFilePath);

          // 上传文件
          await _vfsService.vfs.writeBinaryFile(
            'indexeddb://$_selectedDatabase/$_selectedCollection/$targetFilePath',
            fileData,
            mimeType: _getMimeType(normalizedPath.split('/').last),
          );
          successCount++;
        }
      }

      _showInfoSnackBar('成功上传文件夹 "$folderName" 包含 $successCount 个文件');
      await _refreshCurrentDirectory();
    } catch (e) {
      _showErrorSnackBar('上传文件夹失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 递归收集文件夹中的所有文件
  Future<List<FileSystemEntity>> _collectFilesRecursively(
    Directory directory,
  ) async {
    final List<FileSystemEntity> files = [];

    await for (var entity in directory.list(recursive: true)) {
      if (entity is File) {
        files.add(entity);
      }
    }

    return files;
  }

  /// 确保目录结构存在
  Future<void> _ensureDirectoryStructure(String filePath) async {
    final pathSegments = filePath.split('/');
    if (pathSegments.length <= 1) return;

    final directoryPath = pathSegments
        .sublist(0, pathSegments.length - 1)
        .join('/');

    try {
      final fullPath =
          'indexeddb://$_selectedDatabase/$_selectedCollection/$directoryPath';
      final exists = await _vfsService.vfs.exists(fullPath);
      if (!exists) {
        await _vfsService.vfs.createDirectory(fullPath);
      }
    } catch (e) {
      // 忽略已存在的目录错误
    }
  }

  /// 刷新当前目录
  Future<void> _refreshCurrentDirectory() async {
    await _navigateToPath(_currentPath);
  }

  /// 获取文件的MIME类型
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'txt':
        return 'text/plain';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      case 'html':
        return 'text/html';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  /// 处理下载操作
  Future<void> _handleDownload(String downloadType) async {
    if (_selectedDatabase == null || _selectedCollection == null) {
      _showErrorSnackBar(
        LocalizationService.instance.current.selectDatabaseFirst_7281,
      );
      return;
    }

    try {
      switch (downloadType) {
        case 'selected':
          await _downloadSelectedItems(compress: false);
          break;
        case 'selected_zip':
          await _downloadSelectedItems(compress: true);
          break;
        case 'all':
          await _downloadCurrentDirectory(compress: false);
          break;
        case 'all_zip':
          await _downloadCurrentDirectory(compress: true);
          break;
      }
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.downloadFailed_7285(e),
      );
    }
  }

  /// 下载选中项
  Future<void> _downloadSelectedItems({bool compress = false}) async {
    final selectedFiles = _currentFiles
        .where((file) => _selectedFiles.contains(file.path))
        .toList();

    if (selectedFiles.isEmpty) {
      _showErrorSnackBar(
        LocalizationService.instance.current.selectFileOrFolderFirst_7281,
      );
      return;
    }

    await _downloadFiles(selectedFiles, compress: compress);
  }

  /// 下载当前目录
  Future<void> _downloadCurrentDirectory({bool compress = false}) async {
    if (_currentFiles.isEmpty) {
      _showErrorSnackBar(
        LocalizationService.instance.current.emptyDirectory_7281,
      );
      return;
    }

    await _downloadFiles(_currentFiles, compress: compress);
  }

  /// 下载文件列表
  Future<void> _downloadFiles(
    List<VfsFileInfo> files, {
    bool compress = false,
  }) async {
    try {
      if (compress) {
        // 压缩下载
        await _downloadFilesAsArchive(files);
      } else {
        // 普通下载
        await _downloadFilesNormally(files);
      }
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.downloadFailed_7285(e),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 普通下载（支持Web平台和桌面平台）
  Future<void> _downloadFilesNormally(List<VfsFileInfo> files) async {
    if (kIsWeb) {
      // Web平台：直接下载文件，不需要选择目录
      await _downloadFilesForWeb(files);
    } else {
      // 桌面平台：选择保存位置
      final downloadPath = await FilePicker.platform.getDirectoryPath();
      if (downloadPath == null) return;

      setState(() {
        _isLoading = true;
      });

      int fileCount = 0;
      int folderCount = 0;

      for (var file in files) {
        if (file.isDirectory) {
          // 下载整个文件夹
          final downloadedFiles = await _downloadDirectory(file, downloadPath);
          fileCount += downloadedFiles;
          folderCount++;
        } else {
          // 下载单个文件
          await _downloadSingleFile(file, downloadPath);
          fileCount++;
        }
      }

      String message = '';
      if (fileCount > 0 && folderCount > 0) {
        message = LocalizationService.instance.current.downloadSummary(
          fileCount,
          folderCount,
          downloadPath,
        );
      } else if (fileCount > 0) {
        message = LocalizationService.instance.current.filesDownloaded_7421(
          fileCount,
          downloadPath,
        );
      } else if (folderCount > 0) {
        message = LocalizationService.instance.current
            .foldersDownloadedToPath_7281(folderCount, downloadPath);
      }

      if (message.isNotEmpty) {
        _showInfoSnackBar(message);
      }
    }
  }

  /// 压缩下载（支持Web平台和桌面平台）
  Future<void> _downloadFilesAsArchive(List<VfsFileInfo> files) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 创建压缩包
      final archive = Archive();
      int totalFiles = 0;

      for (var file in files) {
        if (file.isDirectory) {
          totalFiles += await _addDirectoryToArchive(archive, file, '');
        } else {
          await _addFileToArchive(archive, file, '');
          totalFiles++;
        }
      }

      // 编码压缩包
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);
      if (zipData != null) {
        if (kIsWeb) {
          // Web平台：直接下载压缩包
          final fileName = WebDownloadUtils.generateTimestampedFileName(
            _currentPath.isEmpty
                ? LocalizationService.instance.current.rootDirectory_5421
                : _currentPath.split('/').last,
            'zip',
          );
          await WebDownloadUtils.downloadZipFile(
            fileName,
            Uint8List.fromList(zipData),
          );

          final fileSize = _formatFileSize(zipData.length);
          _showInfoSnackBar(
            LocalizationService.instance.current.filesCompressedInfo(
              totalFiles,
              fileSize,
            ),
          );
        } else {
          // 桌面平台：选择保存位置和文件名
          final zipPath = await FilePicker.platform.saveFile(
            dialogTitle:
                LocalizationService.instance.current.saveZipFileTitle_4821,
            fileName:
                '${_currentPath.isEmpty ? LocalizationService.instance.current.rootDirectory_5732 : _currentPath.split('/').last}_${DateTime.now().millisecondsSinceEpoch}.zip',
            type: FileType.custom,
            allowedExtensions: ['zip'],
          );

          if (zipPath == null) return;

          // 保存到文件
          final zipFile = File(zipPath);
          await zipFile.writeAsBytes(zipData);

          final fileSize = _formatFileSize(zipData.length);
          _showInfoSnackBar(
            LocalizationService.instance.current.filesCompressedInfo(
              totalFiles,
              zipPath,
            ),
          );
        }
      } else {
        _showErrorSnackBar(
          LocalizationService.instance.current.compressionFailed_7281,
        );
      }
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.compressionDownloadFailed(e),
      );
    }
  }

  /// 添加文件到压缩包
  Future<void> _addFileToArchive(
    Archive archive,
    VfsFileInfo file,
    String basePath,
  ) async {
    final fileContent = await _vfsService.vfs.readFile(file.path);
    if (fileContent != null) {
      final archiveFile = ArchiveFile(
        basePath.isEmpty ? file.name : '$basePath/${file.name}',
        fileContent.data.length,
        fileContent.data,
      );
      archive.addFile(archiveFile);
    }
  }

  /// 递归添加目录到压缩包
  Future<int> _addDirectoryToArchive(
    Archive archive,
    VfsFileInfo directory,
    String basePath,
  ) async {
    final allFiles = await _vfsService.vfs.listDirectory(directory.path);
    int fileCount = 0;

    final dirPath = basePath.isEmpty
        ? directory.name
        : '$basePath/${directory.name}';

    for (var file in allFiles) {
      if (file.isDirectory) {
        fileCount += await _addDirectoryToArchive(archive, file, dirPath);
      } else {
        await _addFileToArchive(archive, file, dirPath);
        fileCount++;
      }
    }

    return fileCount;
  }

  /// 下载单个文件
  Future<void> _downloadSingleFile(
    VfsFileInfo file,
    String downloadPath,
  ) async {
    final fileName = file.name;
    final fileContent = await _vfsService.vfs.readFile(file.path);

    if (fileContent != null) {
      final localFile = File('$downloadPath/$fileName');
      await localFile.writeAsBytes(fileContent.data);
    }
  }

  /// 下载整个目录
  Future<int> _downloadDirectory(VfsFileInfo directory, String basePath) async {
    // 创建本地目录
    final localDir = Directory('$basePath/${directory.name}');
    if (!localDir.existsSync()) {
      await localDir.create(recursive: true);
    }

    // 递归获取目录下的所有文件
    final allFiles = await _vfsService.vfs.listDirectory(directory.path);
    int downloadedFiles = 0;

    for (var file in allFiles) {
      if (file.isDirectory) {
        // 递归下载子目录
        downloadedFiles += await _downloadDirectory(file, localDir.path);
      } else {
        // 下载文件到子目录        await _downloadSingleFile(file, localDir.path);
        downloadedFiles++;
      }
    }

    return downloadedFiles;
  }

  /// Web平台文件下载方法
  Future<void> _downloadFilesForWeb(List<VfsFileInfo> files) async {
    setState(() {
      _isLoading = true;
    });

    try {
      int fileCount = 0;
      int directoryCount = 0;

      for (var file in files) {
        if (file.isDirectory) {
          // 下载目录中的所有文件
          final dirFiles = await _downloadDirectoryForWeb(file);
          fileCount += dirFiles;
          directoryCount++;
        } else {
          // 下载单个文件
          await _downloadSingleFileForWeb(file);
          fileCount++;
        }
      }

      String message = '';
      if (fileCount > 0 && directoryCount > 0) {
        message = LocalizationService.instance.current
            .downloadedFilesAndDirectories(fileCount, directoryCount);
      } else if (fileCount > 0) {
        message = LocalizationService.instance.current.downloadedFilesCount(
          fileCount,
        );
      } else if (directoryCount > 0) {
        message = LocalizationService.instance.current
            .downloadedFilesFromDirectories(directoryCount);
      }

      if (message.isNotEmpty) {
        _showInfoSnackBar(message);
      }
    } catch (e) {
      _showErrorSnackBar(
        LocalizationService.instance.current.webDownloadFailed_7285(e),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Web平台下载单个文件
  Future<void> _downloadSingleFileForWeb(VfsFileInfo file) async {
    final fileContent = await _vfsService.vfs.readFile(file.path);
    if (fileContent != null) {
      final fileName = WebDownloadUtils.sanitizeFileName(file.name);
      await WebDownloadUtils.downloadFile(
        fileName,
        fileContent.data,
        mimeType: fileContent.mimeType ?? 'application/octet-stream',
      );
    }
  }

  /// Web平台下载目录中的所有文件
  Future<int> _downloadDirectoryForWeb(VfsFileInfo directory) async {
    final allFiles = await _vfsService.vfs.listDirectory(directory.path);
    int downloadedFiles = 0;

    for (var file in allFiles) {
      if (file.isDirectory) {
        // 递归下载子目录
        downloadedFiles += await _downloadDirectoryForWeb(file);
      } else {
        // 下载文件，文件名包含目录结构
        final relativePath = file.path
            .replaceFirst(directory.path, '')
            .replaceFirst('/', '');

        final fileName = WebDownloadUtils.sanitizeFileName(
          '${directory.name}_$relativePath',
        );

        final fileContent = await _vfsService.vfs.readFile(file.path);
        if (fileContent != null) {
          await WebDownloadUtils.downloadFile(
            fileName,
            fileContent.data,
            mimeType: fileContent.mimeType ?? 'application/octet-stream',
          );
          downloadedFiles++;

          // 添加小延迟，避免浏览器阻止多个下载
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    }

    return downloadedFiles;
  }
}

/// 排序类型枚举
enum _SortType { name, size, modified, type }

/// 视图类型枚举
enum _ViewType { list, grid }

/// 文件列表项小部件，支持悬停阴影效果
class _FileListItem extends StatefulWidget {
  final VfsFileInfo file;
  final bool isSelected;
  final bool isCutToClipboard; // 新增：是否被剪切到剪贴板
  final bool canBeSelected; // 新增：是否可以被选择
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool?>? onSelectionChanged; // 修改为可选参数
  final String Function(int) formatFileSize;
  final String Function(DateTime) formatDateTime;
  final IconData Function(VfsFileInfo) getFileIcon;
  final Widget Function(VfsFileInfo) buildPermissionIndicator;

  const _FileListItem({
    required this.file,
    required this.isSelected,
    required this.isCutToClipboard,
    required this.canBeSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onSelectionChanged,
    required this.formatFileSize,
    required this.formatDateTime,
    required this.getFileIcon,
    required this.buildPermissionIndicator,
  });

  @override
  State<_FileListItem> createState() => _FileListItemState();
}

class _FileListItemState extends State<_FileListItem> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final opacity = widget.isCutToClipboard
        ? 0.5
        : (!widget.canBeSelected ? 0.6 : 1.0);
    return Opacity(
      opacity: opacity,
      child: MouseRegion(
        cursor: widget.canBeSelected || widget.file.isDirectory
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.canBeSelected || widget.file.isDirectory
              ? widget.onTap
              : null,
          onLongPress: widget.canBeSelected ? widget.onLongPress : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : (!widget.canBeSelected)
                  ? Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (!widget.canBeSelected)
                    ? Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3)
                    : Theme.of(context).dividerColor,
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: _isHovered && widget.canBeSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ]
                  : widget.isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // 复选框 - 移到左侧
                Checkbox(
                  value: widget.isSelected,
                  onChanged: widget.onSelectionChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                // 文件图标
                Icon(
                  widget.file.isDirectory
                      ? Icons.folder
                      : widget.getFileIcon(widget.file),
                  size: 40,
                  color: widget.file.isDirectory
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: 12),
                // 文件信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.file.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.formatFileSize(widget.file.size)} • ${widget.formatDateTime(widget.file.modifiedAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 权限图标 - 移到垂直中间右侧
                widget.buildPermissionIndicator(widget.file),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 文件网格项小部件，支持悬停阴影效果
class _FileGridItem extends StatefulWidget {
  final VfsFileInfo file;
  final bool isSelected;
  final bool isCutToClipboard; // 新增：是否被剪切到剪贴板
  final bool canBeSelected; // 新增：是否可以被选择
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool?>? onSelectionChanged; // 修改为可选参数
  final String Function(int) formatFileSize;
  final IconData Function(VfsFileInfo) getFileIcon;

  const _FileGridItem({
    required this.file,
    required this.isSelected,
    required this.isCutToClipboard,
    required this.canBeSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onSelectionChanged,
    required this.formatFileSize,
    required this.getFileIcon,
  });

  @override
  State<_FileGridItem> createState() => _FileGridItemState();
}

class _FileGridItemState extends State<_FileGridItem> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    // 计算整体透明度
    double opacity = 1.0;
    if (widget.isCutToClipboard) {
      opacity = 0.5;
    } else if (!widget.canBeSelected) {
      opacity = 0.6;
    }
    return Opacity(
      opacity: opacity,
      child: MouseRegion(
        cursor: widget.canBeSelected || widget.file.isDirectory
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: widget.canBeSelected || widget.file.isDirectory
            ? (_) => setState(() => _isHovered = true)
            : null,
        onExit: widget.canBeSelected || widget.file.isDirectory
            ? (_) => setState(() => _isHovered = false)
            : null,
        child: GestureDetector(
          onTap: widget.canBeSelected || widget.file.isDirectory
              ? widget.onTap
              : null,
          onLongPress: widget.canBeSelected ? widget.onLongPress : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ]
                  : widget.isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                // 复选框 - 移到左上角
                Positioned(
                  top: 4,
                  left: 4,
                  child: Checkbox(
                    value: widget.isSelected,
                    onChanged: widget.onSelectionChanged,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                // 主要内容 - 增加左边距避免与复选框重叠
                Padding(
                  padding: const EdgeInsets.only(
                    left: 32,
                    top: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.file.isDirectory
                            ? Icons.folder
                            : widget.getFileIcon(widget.file),
                        size: 48,
                        color: widget.file.isDirectory
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.file.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (!widget.file.isDirectory) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.formatFileSize(widget.file.size),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
