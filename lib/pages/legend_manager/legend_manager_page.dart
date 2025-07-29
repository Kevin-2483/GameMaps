import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:jovial_svg/jovial_svg.dart';
import '../../components/layout/main_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../models/legend_item.dart';
import '../../services/legend_vfs/legend_vfs_service.dart';
// import '../../components/common/config_aware_widgets.dart';
import '../../components/common/center_point_selector.dart';
import '../../components/common/draggable_title_bar.dart';
import '../../../services/notification/notification_service.dart';

class LegendManagerPage extends BasePage {
  const LegendManagerPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _LegendManagerContent();
  }
}

class _LegendManagerContent extends StatefulWidget {
  const _LegendManagerContent();

  @override
  State<_LegendManagerContent> createState() => _LegendManagerContentState();
}

class _LegendManagerContentState extends State<_LegendManagerContent> {
  final LegendVfsService _vfsService = LegendVfsService();
  List<LegendItem> _legends = [];
  List<String> _folders = [];
  bool _isLoading = true;
  String _currentPath = ''; // 当前文件夹路径
  List<String> _pathHistory = []; // 路径历史，用于面包屑导航

  @override
  void initState() {
    super.initState();
    _loadLegends();
  }

  Future<void> _loadLegends() async {
    setState(() => _isLoading = true);
    try {
      final legends = await _vfsService.getAllLegends(
        _currentPath.isEmpty ? null : _currentPath,
      );
      final folders = await _loadFolders();
      setState(() {
        _legends = legends;
        _folders = folders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('加载图例失败: $e');
      }
    }
  }

  Future<List<String>> _loadFolders() async {
    try {
      final allFolders = await _vfsService.getAllFolders();

      // 只返回当前路径下的直接子文件夹
      if (_currentPath.isEmpty) {
        return allFolders.where((folder) => !folder.contains('/')).toList();
      } else {
        final prefix = '$_currentPath/';
        return allFolders
            .where((folder) => folder.startsWith(prefix))
            .map((folder) => folder.substring(prefix.length))
            .where((relativePath) => !relativePath.contains('/'))
            .toList();
      }
    } catch (e) {
      debugPrint('加载文件夹失败: $e');
      return [];
    }
  }

  void _showErrorSnackBar(String message) {
    context.showErrorSnackBar(message);
  }

  void _showSuccessSnackBar(String message) {
    context.showSuccessSnackBar(message);
  }

  Future<void> _addLegend() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'svg'],
      allowMultiple: false,
    );

    if (result != null) {
      final fileName = result.files.single.name.toLowerCase();
      final Uint8List imageBytes;
      if (kIsWeb) {
        // Web平台使用bytes
        imageBytes = result.files.single.bytes!;
      } else {
        // 桌面平台使用path
        final file = File(result.files.single.path!);
        imageBytes = await file.readAsBytes();
      }

      // 确定文件类型
      LegendFileType fileType;
      if (fileName.endsWith('.svg')) {
        fileType = LegendFileType.svg;
      } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
        fileType = LegendFileType.jpg;
      } else {
        fileType = LegendFileType.png;
      }

      // 处理图片 - PNG保持原始文件，只压缩JPG/JPEG
      final processedImage =
          fileType == LegendFileType.svg || fileType == LegendFileType.png
          ? imageBytes
          : _compressImage(imageBytes);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final legendInfo = await _showAddLegendDialog(
          l10n,
          processedImage,
          fileType,
        );
        if (legendInfo != null && legendInfo['title']?.isNotEmpty == true) {
          try {
            final legendTitle = legendInfo['title'] as String;

            // 检查图例是否已存在
            final existingLegend = await _vfsService.getLegend(
              legendTitle,
              _currentPath.isEmpty ? null : _currentPath,
            );

            if (existingLegend != null) {
              // 显示覆盖确认对话框
              final shouldOverwrite = await _showOverwriteConfirmDialog(
                l10n,
                legendTitle,
              );
              if (shouldOverwrite != true) {
                return; // 用户取消覆盖
              }
            }

            final legendItem = LegendItem(
              title: legendTitle,
              imageData: processedImage,
              fileType: fileType,
              centerX: legendInfo['centerX'] ?? 0.5,
              centerY: legendInfo['centerY'] ?? 0.5,
              version: legendInfo['version'] ?? 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await _vfsService.saveLegend(
              legendItem,
              _currentPath.isEmpty ? null : _currentPath,
            );
            await _loadLegends();
            _showSuccessSnackBar('添加图例成功');
          } catch (e) {
            _showErrorSnackBar('添加图例失败: $e');
          }
        }
      }
    }
  }

  Uint8List _compressImage(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image != null) {
        // 调整图片大小，最大宽度800像素
        final resized = img.copyResize(image, width: 800);
        // 保持PNG格式以保留透明通道
        return Uint8List.fromList(img.encodePng(resized));
      }
    } catch (e) {
      debugPrint('图片压缩失败: $e');
    }
    return imageBytes;
  }

  Future<bool?> _showOverwriteConfirmDialog(
    AppLocalizations l10n,
    String legendTitle,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('图例已存在'),
          content: Text('图例 "$legendTitle" 已存在，是否要覆盖现有图例？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('覆盖'),
            ),
          ],
        );
      },
    );
  }

  /// 显示编辑图例对话框
  Future<Map<String, dynamic>?> _showEditLegendDialog(
    AppLocalizations l10n,
    LegendItem legend,
  ) async {
    final TextEditingController titleController = TextEditingController(
      text: legend.title,
    );
    final TextEditingController versionController = TextEditingController(
      text: legend.version.toString(),
    );
    double centerX = legend.centerX;
    double centerY = legend.centerY;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('编辑图例'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: l10n.legendTitle,
                          hintText: l10n.enterLegendTitle,
                        ),
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: versionController,
                        decoration: InputDecoration(
                          labelText: l10n.legendVersion,
                          hintText: '输入图例版本号',
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.selectCenterPoint,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CenterPointSelector(
                        imageData: legend.imageData!,
                        fileType: legend.fileType,
                        initialX: centerX,
                        initialY: centerY,
                        onCenterChanged: (x, y) {
                          centerX = x;
                          centerY = y;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final version = int.tryParse(versionController.text) ?? 1;
                    if (title.isNotEmpty) {
                      Navigator.of(context).pop({
                        'title': title,
                        'version': version,
                        'centerX': centerX,
                        'centerY': centerY,
                      });
                    }
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 根据文件类型构建图像组件
  Future<Map<String, dynamic>?> _showAddLegendDialog(
    AppLocalizations l10n,
    Uint8List imageData,
    LegendFileType fileType,
  ) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController versionController = TextEditingController(
      text: '1',
    );
    double centerX = 0.5;
    double centerY = 0.5;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.addLegend),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: l10n.legendTitle,
                          hintText: l10n.enterLegendTitle,
                        ),
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: versionController,
                        decoration: InputDecoration(
                          labelText: l10n.legendVersion,
                          hintText: '输入图例版本号',
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.selectCenterPoint,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CenterPointSelector(
                        imageData: imageData,
                        fileType: fileType,
                        initialX: centerX,
                        initialY: centerY,
                        onCenterChanged: (x, y) {
                          centerX = x;
                          centerY = y;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final version = int.tryParse(versionController.text) ?? 1;
                    if (title.isNotEmpty) {
                      Navigator.of(context).pop({
                        'title': title,
                        'version': version,
                        'centerX': centerX,
                        'centerY': centerY,
                      });
                    }
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 编辑图例
  Future<void> _editLegend(LegendItem legend) async {
    final l10n = AppLocalizations.of(context)!;

    final result = await _showEditLegendDialog(l10n, legend);
    if (result != null) {
      try {
        // 创建更新后的图例项
        final updatedLegend = LegendItem(
          title: result['title'] as String,
          version: result['version'] as int,
          centerX: result['centerX'] as double,
          centerY: result['centerY'] as double,
          imageData: legend.imageData,
          fileType: legend.fileType,
          createdAt: legend.createdAt,
          updatedAt: DateTime.now(),
        );

        // 如果标题发生变化，需要删除旧图例并创建新图例
        if (legend.title != updatedLegend.title) {
          // 检查新标题是否已存在
          final existingLegend = await _vfsService.getLegend(
            updatedLegend.title,
            _currentPath.isEmpty ? null : _currentPath,
          );

          if (existingLegend != null) {
            // 显示覆盖确认对话框
            final shouldOverwrite = await _showOverwriteConfirmDialog(
              l10n,
              updatedLegend.title,
            );
            if (shouldOverwrite != true) {
              return;
            }
          }

          // 删除旧图例
          await _vfsService.deleteLegend(
            legend.title,
            _currentPath.isEmpty ? null : _currentPath,
          );
        }

        // 保存更新后的图例
        await _vfsService.saveLegend(
          updatedLegend,
          _currentPath.isEmpty ? null : _currentPath,
        );

        await _loadLegends();
        _showSuccessSnackBar('图例更新成功');
      } catch (e) {
        _showErrorSnackBar('更新图例失败: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteLegend(LegendItem legend) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteLegend),
          content: Text(l10n.confirmDeleteLegend(legend.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _vfsService.deleteLegend(
          legend.title,
          _currentPath.isEmpty ? null : _currentPath,
        );
        await _loadLegends();
        _showSuccessSnackBar(l10n.legendDeletedSuccessfully);
      } catch (e) {
        _showErrorSnackBar(l10n.deleteLegendFailed(e.toString()));
      }
    }
  }

  /// 导航到指定文件夹
  void _navigateToFolder(String folderName) {
    setState(() {
      _pathHistory.add(_currentPath);
      if (_currentPath.isEmpty) {
        _currentPath = folderName;
      } else {
        _currentPath = '$_currentPath/$folderName';
      }
    });
    _loadLegends();
  }

  /// 返回上级文件夹
  void _navigateBack() {
    if (_pathHistory.isNotEmpty) {
      setState(() {
        _currentPath = _pathHistory.removeLast();
      });
      _loadLegends();
    }
  }

  /// 导航到根目录
  void _navigateToRoot() {
    setState(() {
      _currentPath = '';
      _pathHistory.clear();
    });
    _loadLegends();
  }

  /// 导航到指定路径
  void _navigateToPath(String path) {
    setState(() {
      _currentPath = path;
      // 重建路径历史
      _pathHistory.clear();
      if (path.isNotEmpty) {
        final pathSegments = path.split('/');
        for (int i = 0; i < pathSegments.length - 1; i++) {
          _pathHistory.add(pathSegments.sublist(0, i + 1).join('/'));
        }
      }
    });
    _loadLegends();
  }

  /// 构建面包屑导航
  Widget _buildBreadcrumbs() {
    if (_currentPath.isEmpty) {
      return const SizedBox.shrink();
    }

    final pathSegments = _currentPath.split('/');
    final breadcrumbs = <Map<String, String>>[
      {'name': '根目录', 'path': ''},
    ];

    String currentPath = '';
    for (final segment in pathSegments) {
      currentPath = currentPath.isEmpty ? segment : '$currentPath/$segment';
      breadcrumbs.add({'name': segment, 'path': currentPath});
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: breadcrumbs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final breadcrumb = entry.value;
                  final isLast = index == breadcrumbs.length - 1;

                  return Row(
                    children: [
                      if (index > 0)
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      InkWell(
                        onTap: isLast
                            ? null
                            : () => breadcrumb['path']!.isEmpty
                                  ? _navigateToRoot()
                                  : _navigateToPath(breadcrumb['path']!),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            breadcrumb['name']!,
                            style: TextStyle(
                              color: isLast
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.primary,
                              fontWeight: isLast
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 创建新文件夹
  Future<void> _createFolder() async {
    final l10n = AppLocalizations.of(context)!;
    final folderName = await _showCreateFolderDialog(l10n);

    if (folderName != null && folderName.isNotEmpty) {
      try {
        final fullPath = _currentPath.isEmpty
            ? folderName
            : '$_currentPath/$folderName';
        final success = await _vfsService.createFolder(fullPath);

        if (success) {
          _showSuccessSnackBar('文件夹创建成功');
          await _loadLegends();
        } else {
          _showErrorSnackBar('文件夹创建失败');
        }
      } catch (e) {
        _showErrorSnackBar('文件夹创建失败: ${e.toString()}');
      }
    }
  }

  /// 显示创建文件夹对话框
  Future<String?> _showCreateFolderDialog(AppLocalizations l10n) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建文件夹'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '文件夹名称',
            hintText: '输入文件夹名称',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(name);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const cardWidth = 150.0; // 每个卡片的最小宽度
    // 移除最大列数限制，允许窗口变大时增加更多列
    return (screenWidth / cardWidth).floor().clamp(2, double.infinity).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          DraggableTitleBar(
            icon: Icons.legend_toggle,
            titleWidget: Row(
              children: [
                Text(
                  l10n.legendManager,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
            actions: [
              // 添加图例按钮
              IconButton(
                onPressed: _addLegend,
                icon: const Icon(Icons.add),
                tooltip: '添加图例',
              ),
              const SizedBox(width: 4),
              // 创建文件夹按钮
              IconButton(
                onPressed: _createFolder,
                icon: const Icon(Icons.create_new_folder),
                tooltip: '创建文件夹',
              ),
            ],
          ),
          // 面包屑导航
          _buildBreadcrumbs(),
          // 内容区域
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(context, l10n),
          ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    if (_legends.isEmpty && _folders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.legend_toggle, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.legendManagerEmpty, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(l10n.addLegend),
          ],
        ),
      );
    }

    // 对文件夹和图例进行排序
    final sortedFolders = List<String>.from(_folders)..sort(_compareNames);
    final sortedLegends = List<LegendItem>.from(_legends)
      ..sort((a, b) => _compareNames(a.title, b.title));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文件夹部分
            if (sortedFolders.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _calculateCrossAxisCount(context),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.87,
                ),
                itemCount: sortedFolders.length,
                itemBuilder: (context, index) {
                  final folderName = sortedFolders[index];
                  return _FolderCard(
                    folderName: folderName,
                    onTap: () => _navigateToFolder(folderName),
                    onDelete: () => _deleteFolder(folderName),
                    onRename: () => _renameFolder(folderName),
                    onCheckEmpty: () => _isFolderEmpty(folderName),
                  );
                },
              ),
            ],
            // 分割线
            if (sortedFolders.isNotEmpty && sortedLegends.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 24),
            ],
            // 图例部分
            if (sortedLegends.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _calculateCrossAxisCount(context),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.87,
                ),
                itemCount: sortedLegends.length,
                itemBuilder: (context, index) {
                  final legend = sortedLegends[index];
                  return _LegendCard(
                    legend: legend,
                    onDelete: () => _deleteLegend(legend),
                    onEdit: () => _editLegend(legend),
                    onTap: () {
                      // 暂时不实现点击事件
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 比较名称，中文转拼音排序
  int _compareNames(String a, String b) {
    // 简单的中文转拼音排序，这里使用字符编码比较
    // 在实际项目中可能需要使用专门的拼音库
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  /// 删除文件夹
  Future<void> _deleteFolder(String folderName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除文件夹'),
          content: Text('确定要删除文件夹 "$folderName" 吗？\n\n注意：只能删除空文件夹。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final folderPath = _currentPath.isEmpty
            ? folderName
            : '$_currentPath/$folderName';
        final success = await _vfsService.deleteFolder(folderPath);
        if (success) {
          await _loadLegends();
          _showSuccessSnackBar('文件夹删除成功');
        } else {
          _showErrorSnackBar('删除失败：文件夹不为空或不存在');
        }
      } catch (e) {
        _showErrorSnackBar('删除文件夹失败: ${e.toString()}');
      }
    }
  }

  /// 检查文件夹是否为空
  Future<bool> _isFolderEmpty(String folderName) async {
    try {
      final folderPath = _currentPath.isEmpty
          ? folderName
          : '$_currentPath/$folderName';

      // 检查文件夹中的图例
      final legends = await _vfsService.getAllLegendTitles(folderPath);
      if (legends.isNotEmpty) {
        return false;
      }

      // 检查文件夹中的子文件夹
      final subFolders = await _vfsService.getFolders(folderPath);
      if (subFolders.isNotEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('检查文件夹是否为空失败: $folderName, 错误: $e');
      return false;
    }
  }

  /// 重命名文件夹
  Future<void> _renameFolder(String oldFolderName) async {
    final controller = TextEditingController(text: oldFolderName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('重命名文件夹'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: '文件夹名称',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty && name != oldFolderName) {
                  Navigator.of(context).pop(name);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName != oldFolderName) {
      try {
        final oldPath = _currentPath.isEmpty
            ? oldFolderName
            : '$_currentPath/$oldFolderName';
        final newPath = _currentPath.isEmpty
            ? newName
            : '$_currentPath/$newName';

        // 检查新名称是否已存在
        final folders = await _vfsService.getFolders(
          _currentPath.isEmpty ? null : _currentPath,
        );
        if (folders.contains(newName)) {
          _showErrorSnackBar('文件夹名称已存在');
          return;
        }

        // 使用VFS的move方法来重命名文件夹
        final success = await _vfsService.renameFolder(oldPath, newPath);
        if (success) {
          await _loadLegends();
          _showSuccessSnackBar('文件夹重命名成功');
        } else {
          _showErrorSnackBar('重命名失败');
        }
      } catch (e) {
        _showErrorSnackBar('重命名文件夹失败: ${e.toString()}');
      }
    }
  }
}

class _LegendCard extends StatelessWidget {
  final LegendItem legend;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _LegendCard({
    required this.legend,
    required this.onDelete,
    required this.onTap,
    this.onEdit,
  });

  /// 显示图例右键菜单
  void _showLegendContextMenu(BuildContext context, TapDownDetails details) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        if (onEdit != null)
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text('编辑'),
              ],
            ),
          ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('删除'),
            ],
          ),
        ),
      ],
    ).then((value) {
      switch (value) {
        case 'edit':
          onEdit?.call();
          break;
        case 'delete':
          onDelete.call();
          break;
      }
    });
  }

  Widget _buildImageWidget(LegendItem legend) {
    if (legend.fileType == LegendFileType.svg) {
      try {
        return ScalableImageWidget.fromSISource(
          si: ScalableImageSource.fromSvgHttpUrl(
            Uri.dataFromBytes(legend.imageData!, mimeType: 'image/svg+xml'),
          ),
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error, size: 48, color: Colors.red),
        );
      }
    } else {
      try {
        return Image.memory(legend.imageData!, fit: BoxFit.cover);
      } catch (e) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error, size: 48, color: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 卡片部分：只显示图片
        Expanded(
          child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              onSecondaryTapDown: onEdit != null || onDelete != null
                  ? (details) => _showLegendContextMenu(context, details)
                  : null,
              child: Stack(
                children: [
                  // 图片
                  Positioned.fill(
                    child: legend.imageData != null
                        ? _buildImageWidget(legend)
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  // 中心点指示器
                  if (legend.imageData != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CenterPointIndicatorPainter(
                          legend.centerX,
                          legend.centerY,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // 标题部分：显示在卡片外下方
        const SizedBox(height: 4),
        Text(
          legend.title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FolderCard extends StatelessWidget {
  final String folderName;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;
  final Future<bool> Function()? onCheckEmpty;

  const _FolderCard({
    required this.folderName,
    required this.onTap,
    this.onDelete,
    this.onRename,
    this.onCheckEmpty,
  });

  /// 显示文件夹右键菜单
  void _showFolderContextMenu(
    BuildContext context,
    TapDownDetails details,
  ) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // 检查文件夹是否为空（用于决定是否显示删除选项）
    bool isEmpty = false;
    if (onCheckEmpty != null && onDelete != null) {
      isEmpty = await onCheckEmpty!();
    }

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        if (onRename != null)
          const PopupMenuItem<String>(
            value: 'rename',
            child: Row(
              children: [
                Icon(Icons.edit, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text('重命名'),
              ],
            ),
          ),
        if (onDelete != null && isEmpty)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('删除'),
              ],
            ),
          ),
      ],
    ).then((value) {
      switch (value) {
        case 'rename':
          onRename?.call();
          break;
        case 'delete':
          onDelete?.call();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 卡片部分：只显示文件夹图标
        Expanded(
          child: InkWell(
            onTap: onTap,
            onSecondaryTapDown: onDelete != null || onRename != null
                ? (details) => _showFolderContextMenu(context, details)
                : null,
            child: Container(
              width: double.infinity,
              child: Icon(
                Icons.folder,
                size: 108,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        // 标题部分：显示在卡片外下方
        const SizedBox(height: 4),
        Text(
          folderName,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class CenterPointIndicatorPainter extends CustomPainter {
  final double centerX;
  final double centerY;

  CenterPointIndicatorPainter(this.centerX, this.centerY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(centerX * size.width, centerY * size.height);
    const radius = 6.0;

    // 绘制十字线
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    // 绘制圆圈
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CenterPointIndicatorPainter oldDelegate) {
    return oldDelegate.centerX != centerX || oldDelegate.centerY != centerY;
  }
}
