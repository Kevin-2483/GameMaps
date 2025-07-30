// This file has been processed by AI for internationalization
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import '../../../utils/pdf_export_utils.dart';
import '../../../services/notification/notification_service.dart';
import '../../../services/notification/notification_models.dart';
import '../../../models/pdf_image_info.dart';
import '../../../services/localization_service.dart';

/// PDF导出配置对话框
class PdfExportDialog extends StatefulWidget {
  final List<ui.Image> images;
  final String defaultFileName;

  const PdfExportDialog({
    super.key,
    required this.images,
    this.defaultFileName = 'map_export',
  });

  @override
  State<PdfExportDialog> createState() => _PdfExportDialogState();
}

class _PdfExportDialogState extends State<PdfExportDialog> {
  PdfLayoutType _selectedLayout = PdfLayoutType.onePerPage;
  PdfPaperSize _selectedPaperSize = PdfPaperSize.a4;
  PdfOrientation _selectedOrientation = PdfOrientation.portrait;
  late TextEditingController _fileNameController;
  double _margin = 20.0;
  double _spacing = 10.0;
  bool _isExporting = false;
  bool _isGeneratingPreview = false;
  Uint8List? _previewPdfBytes;
  late List<PdfImageInfo> _imageInfos;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(text: widget.defaultFileName);
    // 将ui.Image转换为PdfImageInfo
    _imageInfos = widget.images
        .map((image) => PdfImageInfo(image: image, title: '', content: ''))
        .toList();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.picture_as_pdf,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(LocalizationService.instance.current.exportAsPdf_7281),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧设置面板
            SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 文件名设置
                    _buildSection(
                      title: '文件名',
                      icon: Icons.drive_file_rename_outline,
                      child: TextField(
                        controller: _fileNameController,
                        decoration: InputDecoration(
                          hintText: LocalizationService
                              .instance
                              .current
                              .fileNameHint_4521,
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 图片列表
                    _buildSection(
                      title: LocalizationService.instance.current
                          .imageListTitle(_imageInfos.length),
                      icon: Icons.photo_library,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: _imageInfos.length,
                          itemBuilder: (context, index) {
                            return _buildImageListItem(index);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 布局设置
                    _buildSection(
                      title: '页面布局',
                      icon: Icons.view_module,
                      child: Row(
                        children: [
                          Text(
                            LocalizationService
                                .instance
                                .current
                                .layoutType_7281,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<PdfLayoutType>(
                              value: _selectedLayout,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: PdfLayoutType.values.map((layout) {
                                return DropdownMenuItem(
                                  value: layout,
                                  child: Text(
                                    PdfExportUtils.getLayoutTypeName(layout),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedLayout = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 纸张设置
                    _buildSection(
                      title: '纸张设置',
                      icon: Icons.article,
                      child: Column(
                        children: [
                          // 纸张大小
                          Row(
                            children: [
                              Text(
                                LocalizationService
                                    .instance
                                    .current
                                    .paperSize_4821,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<PdfPaperSize>(
                                  value: _selectedPaperSize,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: PdfPaperSize.values.map((size) {
                                    return DropdownMenuItem(
                                      value: size,
                                      child: Text(
                                        PdfExportUtils.getPaperSizeName(size),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedPaperSize = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 方向
                          Row(
                            children: [
                              Text(
                                LocalizationService
                                    .instance
                                    .current
                                    .pageOrientation_7281,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<PdfOrientation>(
                                  value: _selectedOrientation,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: PdfOrientation.values.map((
                                    orientation,
                                  ) {
                                    return DropdownMenuItem(
                                      value: orientation,
                                      child: Text(
                                        PdfExportUtils.getOrientationName(
                                          orientation,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedOrientation = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 间距设置
                    _buildSection(
                      title: '间距设置',
                      icon: Icons.space_bar,
                      child: Column(
                        children: [
                          // 页边距
                          Row(
                            children: [
                              Text(
                                LocalizationService
                                    .instance
                                    .current
                                    .marginLabel_4821,
                              ),
                              Expanded(
                                child: Slider(
                                  value: _margin,
                                  min: 10.0,
                                  max: 50.0,
                                  divisions: 8,
                                  label: '${_margin.round()}pt',
                                  onChanged: (value) {
                                    setState(() {
                                      _margin = value;
                                    });
                                  },
                                ),
                              ),
                              Text('${_margin.round()}pt'),
                            ],
                          ),
                          // 图片间距
                          Row(
                            children: [
                              Text(
                                LocalizationService
                                    .instance
                                    .current
                                    .imageSpacing_7281,
                              ),
                              Expanded(
                                child: Slider(
                                  value: _spacing,
                                  min: 5.0,
                                  max: 30.0,
                                  divisions: 5,
                                  label: '${_spacing.round()}pt',
                                  onChanged: (value) {
                                    setState(() {
                                      _spacing = value;
                                    });
                                  },
                                ),
                              ),
                              Text('${_spacing.round()}pt'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 预览信息
                    _buildSection(
                      title: '导出信息',
                      icon: Icons.info_outline,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocalizationService.instance.current
                                  .totalImageCount(widget.images.length),
                            ),

                            Text(
                              LocalizationService.instance.current
                                  .layoutTypeName(
                                    PdfExportUtils.getLayoutTypeName(
                                      _selectedLayout,
                                    ),
                                  ),
                            ),
                            Text(
                              LocalizationService.instance.current
                                  .paperSizeAndOrientation(
                                    PdfExportUtils.getPaperSizeName(
                                      _selectedPaperSize,
                                    ),
                                    PdfExportUtils.getOrientationName(
                                      _selectedOrientation,
                                    ),
                                  ),
                            ),
                            if (kIsWeb) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.print,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        LocalizationService
                                            .instance
                                            .current
                                            .webPlatformExportPdf_4728,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
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
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 右侧预览面板
            Expanded(child: _buildPreviewPanel()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocalizationService.instance.current.cancelButton_4271),
        ),
        if (!kIsWeb) ...[
          OutlinedButton.icon(
            onPressed: _isExporting ? null : _printPdf,
            icon: const Icon(Icons.print, size: 16),
            label: Text(LocalizationService.instance.current.printLabel_4271),
          ),
          const SizedBox(width: 8),
        ],
        ElevatedButton(
          onPressed: _isExporting ? null : _exportToPdf,
          child: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  kIsWeb
                      ? LocalizationService.instance.current.printPdf_1234
                      : LocalizationService.instance.current.exportPdf_5678,
                ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 预览标题栏
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.preview,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  LocalizationService.instance.current.pdfPreview_4521,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (!_isGeneratingPreview)
                  OutlinedButton.icon(
                    onPressed: _previewPdf,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(
                      LocalizationService.instance.current.generatePreview_7421,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
                if (_isGeneratingPreview)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          // 预览内容区域
          Expanded(child: _buildPreviewContent()),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (_isGeneratingPreview) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(LocalizationService.instance.current.generatingPreview_7421),
          ],
        ),
      );
    }

    if (_previewPdfBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.preview,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              LocalizationService.instance.current.clickToGeneratePreview_4821,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      );
    }

    // 使用PdfPreview显示已生成的PDF
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: PdfPreview(
          build: (format) async {
            return _previewPdfBytes!;
          },
          allowPrinting: false,
          allowSharing: false,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          maxPageWidth: 700,
        ),
      ),
    );
  }

  Widget _buildImageListItem(int index) {
    final imageInfo = _imageInfos[index];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: RawImage(
              image: imageInfo.image,
              fit: BoxFit.cover,
              width: 48,
              height: 48,
            ),
          ),
        ),
        title: Text(
          imageInfo.title.isEmpty
              ? LocalizationService.instance.current.imageTitleWithIndex(
                  index + 1,
                )
              : imageInfo.title,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: imageInfo.content.isEmpty
            ? Text(
                LocalizationService
                    .instance
                    .current
                    .clickToEditTitleAndContent_7281,
                style: TextStyle(fontSize: 12),
              )
            : Text(
                imageInfo.content,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Icon(
          imageInfo.hasText ? Icons.edit : Icons.edit_outlined,
          size: 20,
        ),
        onTap: () => _editImageInfo(index),
        dense: true,
      ),
    );
  }

  void _editImageInfo(int index) {
    final imageInfo = _imageInfos[index];
    final titleController = TextEditingController(text: imageInfo.title);
    final contentController = TextEditingController(text: imageInfo.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LocalizationService.instance.current.editImageTitle(index + 1),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText:
                      LocalizationService.instance.current.titleLabel_4521,
                  hintText:
                      LocalizationService.instance.current.imageTitleHint_4522,
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText:
                      LocalizationService.instance.current.contentLabel_4521,
                  hintText: LocalizationService
                      .instance
                      .current
                      .imageDescriptionHint_4522,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.current.cancelButton_7421),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _imageInfos[index] = imageInfo.copyWith(
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                );
              });
              Navigator.of(context).pop();
            },
            child: Text(LocalizationService.instance.current.saveButton_7421),
          ),
        ],
      ),
    ).then((_) {
      titleController.dispose();
      contentController.dispose();
    });
  }

  Future<void> _printPdf() async {
    if (_fileNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.instance.current.enterFileName_4821,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    const String notificationId = 'pdf-print-notification';

    try {
      // 显示打印进度
      NotificationService.instance.show(
        id: notificationId,
        message: LocalizationService.instance.current.preparingToPrint_7281,
        type: NotificationType.info,
        isPersistent: true,
        borderEffect: NotificationBorderEffect.loading,
      );

      final config = PdfExportConfig(
        layoutType: _selectedLayout,
        paperSize: _selectedPaperSize,
        orientation: _selectedOrientation,
        fileName: _fileNameController.text.trim(),
        margin: _margin,
        spacing: _spacing,
      );

      final success = await PdfExportUtils.printPdf(_imageInfos, config);

      if (mounted) {
        if (success) {
          NotificationService.instance.updateNotification(
            notificationId: notificationId,
            message:
                LocalizationService.instance.current.pdfPrintDialogOpened_4821,
            type: NotificationType.success,
            isPersistent: false,
            duration: const Duration(seconds: 3),
            borderEffect: NotificationBorderEffect.none,
          );
        } else {
          NotificationService.instance.updateNotification(
            notificationId: notificationId,
            message: LocalizationService.instance.current.pdfPrintFailed_4821,
            type: NotificationType.error,
            isPersistent: false,
            duration: const Duration(seconds: 3),
            borderEffect: NotificationBorderEffect.none,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationService.instance.updateNotification(
          notificationId: notificationId,
          message: LocalizationService.instance.current.pdfPrintFailed_7285(e),
          type: NotificationType.error,
          isPersistent: false,
          duration: const Duration(seconds: 3),
          borderEffect: NotificationBorderEffect.none,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _previewPdf() async {
    setState(() {
      _isGeneratingPreview = true;
    });

    try {
      final config = PdfExportConfig(
        layoutType: _selectedLayout,
        paperSize: _selectedPaperSize,
        orientation: _selectedOrientation,
        fileName: _fileNameController.text.trim(),
        margin: _margin,
        spacing: _spacing,
      );

      final pdfBytes = await PdfExportUtils.generatePdfPreview(
        _imageInfos,
        config,
      );

      if (mounted && pdfBytes != null) {
        setState(() {
          _previewPdfBytes = Uint8List.fromList(pdfBytes);
          _isGeneratingPreview = false;
        });
      } else if (mounted) {
        setState(() {
          _isGeneratingPreview = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.instance.current.pdfGenerationFailed_7281
                  .toString(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingPreview = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.instance.current.previewGenerationFailed_7421(
                e.toString(),
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _exportToPdf() async {
    if (_fileNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.instance.current.enterFileName_4821,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    const String notificationId = 'pdf-export-notification';

    try {
      // 显示导出进度
      NotificationService.instance.show(
        id: notificationId,
        message: LocalizationService.instance.current.generatingPdf_7421,
        type: NotificationType.info,
        isPersistent: true,
        borderEffect: NotificationBorderEffect.loading,
      );

      final config = PdfExportConfig(
        layoutType: _selectedLayout,
        paperSize: _selectedPaperSize,
        orientation: _selectedOrientation,
        fileName: _fileNameController.text.trim(),
        margin: _margin,
        spacing: _spacing,
      );

      final success = await PdfExportUtils.exportImagesToPdf(
        _imageInfos,
        config,
      );

      if (mounted) {
        if (success) {
          NotificationService.instance.updateNotification(
            notificationId: notificationId,
            message: LocalizationService.instance.current.pdfExportSuccess_4821,
            type: NotificationType.success,
            isPersistent: false,
            duration: const Duration(seconds: 3),
            borderEffect: NotificationBorderEffect.none,
          );
          Navigator.of(context).pop(true);
        } else {
          NotificationService.instance.updateNotification(
            notificationId: notificationId,
            message: LocalizationService.instance.current.pdfExportFailed_7281
                .toString(),
            type: NotificationType.error,
            isPersistent: false,
            duration: const Duration(seconds: 3),
            borderEffect: NotificationBorderEffect.none,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationService.instance.updateNotification(
          notificationId: notificationId,
          message: LocalizationService.instance.current.pdfExportFailed_7281(e),
          type: NotificationType.error,
          isPersistent: false,
          duration: const Duration(seconds: 3),
          borderEffect: NotificationBorderEffect.none,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
