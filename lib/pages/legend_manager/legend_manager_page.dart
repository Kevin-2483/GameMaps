import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import '../../components/layout/main_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../models/legend_item.dart';
import '../../services/legend_database_service.dart';
import '../../components/common/config_aware_widgets.dart';
import '../../components/common/center_point_selector.dart';

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
  final LegendDatabaseService _databaseService = LegendDatabaseService();
  List<LegendItem> _legends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLegends();
  }

  Future<void> _loadLegends() async {
    setState(() => _isLoading = true);
    try {
      final legends = await _databaseService.getAllLegends();
      setState(() {
        _legends = legends;
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
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final imageBytes = await file.readAsBytes();

      // 压缩图片
      final compressedImage = _compressImage(imageBytes);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final legendInfo = await _showAddLegendDialog(l10n, compressedImage);
        if (legendInfo != null && legendInfo['title']?.isNotEmpty == true) {
          try {
            final legendItem = LegendItem(
              title: legendInfo['title'],
              imageData: compressedImage,
              centerX: legendInfo['centerX'] ?? 0.5,
              centerY: legendInfo['centerY'] ?? 0.5,
              version: legendInfo['version'] ?? 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await _databaseService.insertLegend(legendItem);
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

  Future<Map<String, dynamic>?> _showAddLegendDialog(
    AppLocalizations l10n,
    Uint8List imageData,
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
        await _databaseService.deleteLegend(legend.id!);
        await _loadLegends();
        _showSuccessSnackBar(l10n.legendDeletedSuccessfully);
      } catch (e) {
        _showErrorSnackBar(l10n.deleteLegendFailed(e.toString()));
      }
    }
  }

  Future<void> _exportDatabase() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // 显示版本选择对话框
      final exportVersion = await _showExportVersionDialog(l10n);
      if (exportVersion != null) {
        final filePath = await _databaseService.exportDatabase(
          customVersion: exportVersion,
        );
        if (filePath != null) {
          _showSuccessSnackBar(
            l10n.legendDatabaseExportedSuccessfully(filePath),
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('导出失败: ${e.toString()}');
    }
  }

  Future<int?> _showExportVersionDialog(AppLocalizations l10n) async {
    final TextEditingController versionController = TextEditingController(
      text: '1',
    );

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择导出版本'),
          content: TextField(
            controller: versionController,
            decoration: const InputDecoration(
              labelText: '版本号',
              hintText: '输入导出数据库版本号',
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final version = int.tryParse(versionController.text) ?? 1;
                Navigator.of(context).pop(version);
              },
              child: const Text('导出'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _importDatabase() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await _databaseService.importDatabase();
      if (success) {
        await _loadLegends();
        _showSuccessSnackBar(l10n.legendDatabaseImportedSuccessfully);
      }
    } catch (e) {
      _showErrorSnackBar('导入失败: ${e.toString()}');
    }
  }

  /// 更新外部资源
  Future<void> _updateExternalResources() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await _databaseService.updateExternalResources();
      if (success) {
        await _loadLegends();
        _showSuccessSnackBar(l10n.legendUpdateSuccessful);
      } else {
        _showErrorSnackBar(l10n.legendUpdateFailed('版本不高于当前版本'));
      }
    } catch (e) {
      _showErrorSnackBar(l10n.legendUpdateFailed(e.toString()));
    }
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
      appBar: AppBar(
        title: Text(l10n.legendManager),
        actions: [
          // 调试模式功能
          ConfigAwareAppBarAction(
            featureId: 'DebugMode',
            action: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'add':
                    _addLegend();
                    break;
                  case 'import':
                    _importDatabase();
                    break;
                  case 'export':
                    _exportDatabase();
                    break;
                  case 'update':
                    _updateExternalResources();
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
                PopupMenuItem(
                  value: 'import',
                  child: ListTile(
                    leading: const Icon(Icons.file_upload),
                    title: Text(l10n.importLegendDatabase),
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: const Icon(Icons.file_download),
                    title: Text(l10n.exportLegendDatabase),
                  ),
                ),
                PopupMenuItem(
                  value: 'update',
                  child: ListTile(
                    leading: const Icon(Icons.update),
                    title: Text(l10n.updateLegendExternalResources),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _legends.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.legend_toggle, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.legendManagerEmpty,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.addLegend),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _calculateCrossAxisCount(context),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5, // 长方形卡片比例
                ),
                itemCount: _legends.length,
                itemBuilder: (context, index) {
                  final legend = _legends[index];
                  return _LegendCard(
                    legend: legend,
                    onDelete: () => _deleteLegend(legend),
                    onTap: () {
                      // 暂时不实现点击事件
                    },
                  );
                },
              ),
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
                          ? Image.memory(legend.imageData!, fit: BoxFit.cover)
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
