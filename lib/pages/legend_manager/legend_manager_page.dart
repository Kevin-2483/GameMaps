import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:jovial_svg/jovial_svg.dart';
import '../../components/layout/main_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../models/legend_item.dart';
import '../../services/legend_vfs/legend_vfs_service.dart';
import '../../components/common/config_aware_widgets.dart';
import '../../components/common/center_point_selector.dart';
import '../../components/common/draggable_title_bar.dart';

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
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.loadLegendsFailed(e.toString()));
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _addLegend() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'svg'],
      allowMultiple: false,
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name.toLowerCase();
      final imageBytes = await file.readAsBytes();

      // 确定文件类型
      LegendFileType fileType;
      if (fileName.endsWith('.svg')) {
        fileType = LegendFileType.svg;
      } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
        fileType = LegendFileType.jpg;
      } else {
        fileType = LegendFileType.png;
      }

      // 对于非SVG文件进行压缩
      final processedImage = fileType == LegendFileType.svg 
          ? imageBytes 
          : _compressImage(imageBytes);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final legendInfo = await _showAddLegendDialog(l10n, processedImage, fileType);
        if (legendInfo != null && legendInfo['title']?.isNotEmpty == true) {
          try {
            final legendItem = LegendItem(
              title: legendInfo['title'],
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
            _showSuccessSnackBar(l10n.legendAddedSuccessfully);
          } catch (e) {
            _showErrorSnackBar(l10n.addLegendFailed(e.toString()));
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
        return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
      }
    } catch (e) {
      debugPrint('图片压缩失败: $e');
    }
    return imageBytes;
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
    const cardWidth = 300.0; // 每个卡片的最小宽度
    return (screenWidth / cardWidth).floor().clamp(1, 6);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          DraggableTitleBar(
            title: l10n.legendManager,
            icon: Icons.legend_toggle,
            actions: [
              // 创建文件夹按钮
              ConfigAwareAppBarAction(
                featureId: 'DebugMode',
                action: IconButton(
                  onPressed: _createFolder,
                  icon: const Icon(Icons.create_new_folder),
                  tooltip: '创建文件夹',
                ),
              ),
              // 调试模式功能
              ConfigAwareAppBarAction(
                featureId: 'DebugMode',
                action: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'add':
                        _addLegend();
                        break;
                      case 'root':
                        _navigateToRoot();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add',
                      child: ListTile(
                        leading: Icon(Icons.add),
                        title: Text('添加图例'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'root',
                      child: ListTile(
                        leading: Icon(Icons.home),
                        title: Text('回到根目录'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 面包屑导航
          if (_currentPath.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _navigateBack,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: '返回上级',
                  ),
                  Expanded(
                    child: Text(
                      '当前位置: ${_currentPath.isEmpty ? '根目录' : _currentPath}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToRoot,
                    child: const Text('根目录'),
                  ),
                ],
              ),
            ),
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
            const Icon(
              Icons.legend_toggle,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.legendManagerEmpty,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(l10n.addLegend),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _calculateCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5, // 长方形卡片比例
        ),
        itemCount: _folders.length + _legends.length,
        itemBuilder: (context, index) {
          if (index < _folders.length) {
            // 文件夹项
            final folderName = _folders[index];
            return _FolderCard(
              folderName: folderName,
              onTap: () => _navigateToFolder(folderName),
            );
          } else {
            // 图例项
            final legendIndex = index - _folders.length;
            final legend = _legends[legendIndex];
            return _LegendCard(
              legend: legend,
              onDelete: () => _deleteLegend(legend),
              onTap: () {
                // 暂时不实现点击事件
              },
            );
          }
        },
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  final LegendItem legend;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _LegendCard({
    required this.legend,
    required this.onDelete,
    required this.onTap,
  });

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
          child: const Icon(
            Icons.error,
            size: 48,
            color: Colors.red,
          ),
        );
      }
    } else {
      try {
        return Image.memory(
          legend.imageData!,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.error,
            size: 48,
            color: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // 左半部分：图片
            Expanded(
              flex: 1,
              child: AspectRatio(
                aspectRatio: 1,
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
                                size: 48,
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
            // 右半部分：标题和操作
            Expanded(
              flex: 1,
              child: Container(
                height: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            legend.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'v${legend.version}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '中心点: (${(legend.centerX * 100).round()}%, ${(legend.centerY * 100).round()}%)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      // 调试模式下显示删除按钮
                      ConfigAwareWidget(
                        featureId: 'DebugMode',
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 20),
                            color: Colors.red,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final String folderName;
  final VoidCallback onTap;

  const _FolderCard({required this.folderName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),
          child: Row(
            children: [
              // 左半部分：文件夹图标
              Expanded(
                flex: 1,
                child: Container(
                  height: double.infinity,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.folder,
                    size: 48,
                    color: Colors.amber,
                  ),
                ),
              ),
              // 右半部分：文件夹名称
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        folderName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '文件夹',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
