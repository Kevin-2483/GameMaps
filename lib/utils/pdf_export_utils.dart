import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import '../models/pdf_image_info.dart';

// 平台特定导入
import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// PDF导出布局类型
enum PdfLayoutType {
  onePerPage, // 一页一张
  twoPerPage, // 一页两张
  fourPerPage, // 一页四张
  sixPerPage, // 一页六张
  ninePerPage, // 一页九张
}

/// PDF纸张大小
enum PdfPaperSize { a4, a3, letter, legal }

/// PDF方向
enum PdfOrientation {
  portrait, // 竖向
  landscape, // 横向
}

/// PDF导出配置
class PdfExportConfig {
  final PdfLayoutType layoutType;
  final PdfPaperSize paperSize;
  final PdfOrientation orientation;
  final String fileName;
  final double margin;
  final double spacing;

  const PdfExportConfig({
    this.layoutType = PdfLayoutType.onePerPage,
    this.paperSize = PdfPaperSize.a4,
    this.orientation = PdfOrientation.portrait,
    this.fileName = 'export',
    this.margin = 20.0,
    this.spacing = 10.0,
  });
}

/// PDF导出工具类
class PdfExportUtils {
  // 缓存中文字体
  static pw.Font? _chineseFont;

  /// 获取中文字体
  static Future<pw.Font> _getChineseFont() async {
    if (_chineseFont != null) {
      return _chineseFont!;
    }

    try {
      // 尝试使用Google字体中的中文字体
      _chineseFont = await PdfGoogleFonts.notoSansSCRegular();
      return _chineseFont!;
    } catch (e) {
      debugPrint('无法加载Google中文字体，使用默认字体: $e');
      // 如果Google字体加载失败，返回默认字体
      return pw.Font.helvetica();
    }
  }

  /// 创建支持中文的文本样式
  static Future<pw.TextStyle> _createTextStyle({
    required double fontSize,
    pw.FontWeight? fontWeight,
  }) async {
    final chineseFont = await _getChineseFont();
    return pw.TextStyle(
      font: chineseFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// 将图片列表导出为PDF
  static Future<bool> exportImagesToPdf(
    List<PdfImageInfo> imageInfos,
    PdfExportConfig config,
  ) async {
    try {
      final pdf = await _generatePdfDocument(imageInfos, config);
      if (pdf == null) return false;

      // 保存PDF
      return await _savePdf(pdf, config.fileName);
    } catch (e) {
      debugPrint('PDF导出失败: $e');
      return false;
    }
  }

  /// 生成PDF预览数据
  static Future<List<int>?> generatePdfPreview(
    List<PdfImageInfo> imageInfos,
    PdfExportConfig config,
  ) async {
    try {
      final pdf = await _generatePdfDocument(imageInfos, config);
      if (pdf == null) return null;

      return await pdf.save();
    } catch (e) {
      debugPrint('PDF预览生成失败: $e');
      return null;
    }
  }

  /// 构建图片文本块（一页两张布局专用，布局逻辑相反）
  static Future<pw.Widget> _buildImageTextBlockForTwoPerPage(
    pw.MemoryImage image,
    PdfImageInfo imageInfo,
    PdfExportConfig config,
    bool isLandscape, {
    bool isFullPage = false,
    bool showContentText = true,
  }) async {
    // 创建图片标题复合体
    final titleStyle = await _createTextStyle(
      fontSize: isFullPage ? 18 : 14,
      fontWeight: pw.FontWeight.bold,
    );

    final imageWithTitle = pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        // 标题（粗体放大）
        if (imageInfo.title.isNotEmpty) ...[
          pw.Text(
            imageInfo.title,
            style: titleStyle,
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: isFullPage ? 8 : 4),
        ],
        // 图片 - 添加约束确保适应可用空间
        pw.Expanded(
          child: pw.Container(
            constraints: const pw.BoxConstraints(
              minHeight: 50, // 最小高度
              maxHeight: double.infinity,
            ),
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      ],
    );

    // 如果没有内容文本或不显示内容文本，直接返回复合体
    if (imageInfo.content.isEmpty || !showContentText) {
      return imageWithTitle;
    }

    // 创建内容文本样式
    final contentStyle = await _createTextStyle(fontSize: isFullPage ? 12 : 10);

    // 一页两张布局的相反逻辑：
    // 横向时文本在下方，纵向时文本在右侧
    if (isLandscape) {
      // 横向：文本在下方（与其他布局相反）
      return pw.Container(
        height: isFullPage ? null : 300, // 一页两张布局使用更宽松的高度
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Expanded(flex: 3, child: imageWithTitle),
            pw.SizedBox(height: config.spacing),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  imageInfo.content,
                  style: contentStyle,
                  textAlign: pw.TextAlign.left,
                  softWrap: true, // 启用自动换行
                  maxLines: null, // 允许多行
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 纵向：文本在右侧（与其他布局相反）
      return pw.Container(
        height: isFullPage ? null : 300, // 一页两张布局使用更宽松的高度
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(flex: 3, child: imageWithTitle),
            pw.SizedBox(width: config.spacing),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  imageInfo.content,
                  style: contentStyle,
                  textAlign: pw.TextAlign.left,
                  softWrap: true, // 启用自动换行
                  maxLines: null, // 允许多行
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// 构建图片文本块
  static Future<pw.Widget> _buildImageTextBlock(
    pw.MemoryImage image,
    PdfImageInfo imageInfo,
    PdfExportConfig config,
    bool isLandscape, {
    bool isFullPage = false,
    bool showContentText = true,
  }) async {
    // 创建图片标题复合体
    final titleStyle = await _createTextStyle(
      fontSize: isFullPage ? 18 : 14,
      fontWeight: pw.FontWeight.bold,
    );

    final imageWithTitle = pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        // 标题（粗体放大）
        if (imageInfo.title.isNotEmpty) ...[
          pw.Text(
            imageInfo.title,
            style: titleStyle,
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: isFullPage ? 8 : 4),
        ],
        // 图片 - 添加约束确保适应可用空间
        pw.Expanded(
          child: pw.Container(
            constraints: const pw.BoxConstraints(
              minHeight: 50, // 最小高度
              maxHeight: double.infinity,
            ),
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      ],
    );

    // 如果没有内容文本或不显示内容文本，直接返回复合体
    if (imageInfo.content.isEmpty || !showContentText) {
      return imageWithTitle;
    }

    // 创建内容文本样式
    final contentStyle = await _createTextStyle(fontSize: isFullPage ? 12 : 10);

    // 根据纸张方向排列复合体和文本
    if (isLandscape) {
      // 横向：文本在右侧，高度对齐
      return pw.Container(
        height: isFullPage ? null : 200, // 为非全页模式设置固定高度
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(flex: 3, child: imageWithTitle),
            pw.SizedBox(width: config.spacing),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  imageInfo.content,
                  style: contentStyle,
                  textAlign: pw.TextAlign.left,
                  softWrap: true, // 启用自动换行
                  maxLines: null, // 允许多行
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 纵向：文本在下方，宽度对齐
      return pw.Container(
        height: isFullPage ? null : 200, // 为非全页模式设置固定高度
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Expanded(flex: 3, child: imageWithTitle),
            pw.SizedBox(height: config.spacing),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  imageInfo.content,
                  style: contentStyle,
                  textAlign: pw.TextAlign.left,
                  softWrap: true, // 启用自动换行
                  maxLines: null, // 允许多行
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// 生成PDF文档
  static Future<pw.Document?> _generatePdfDocument(
    List<PdfImageInfo> imageInfos,
    PdfExportConfig config,
  ) async {
    try {
      final pdf = pw.Document();

      // 获取页面格式
      final pageFormat = _getPageFormat(config.paperSize, config.orientation);

      // 转换图片为PDF图片格式
      final List<pw.MemoryImage> pdfImages = [];
      for (final imageInfo in imageInfos) {
        final byteData = await imageInfo.image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (byteData != null) {
          pdfImages.add(pw.MemoryImage(byteData.buffer.asUint8List()));
        }
      }

      if (pdfImages.isEmpty) {
        return null;
      }

      // 根据布局类型生成页面
      switch (config.layoutType) {
        case PdfLayoutType.onePerPage:
          await _addOnePerPageLayout(
            pdf,
            imageInfos,
            pdfImages,
            pageFormat,
            config,
          );
          break;
        case PdfLayoutType.twoPerPage:
          await _addTwoPerPageLayout(
            pdf,
            imageInfos,
            pdfImages,
            pageFormat,
            config,
          );
          break;
        case PdfLayoutType.fourPerPage:
          await _addFourPerPageLayout(
            pdf,
            imageInfos,
            pdfImages,
            pageFormat,
            config,
          );
          break;
        case PdfLayoutType.sixPerPage:
          await _addSixPerPageLayout(
            pdf,
            imageInfos,
            pdfImages,
            pageFormat,
            config,
          );
          break;
        case PdfLayoutType.ninePerPage:
          await _addNinePerPageLayout(
            pdf,
            imageInfos,
            pdfImages,
            pageFormat,
            config,
          );
          break;
      }

      return pdf;
    } catch (e) {
      debugPrint('PDF文档生成失败: $e');
      return null;
    }
  }

  /// 获取页面格式
  static PdfPageFormat _getPageFormat(
    PdfPaperSize paperSize,
    PdfOrientation orientation,
  ) {
    PdfPageFormat format;

    switch (paperSize) {
      case PdfPaperSize.a4:
        format = PdfPageFormat.a4;
        break;
      case PdfPaperSize.a3:
        format = PdfPageFormat.a3;
        break;
      case PdfPaperSize.letter:
        format = PdfPageFormat.letter;
        break;
      case PdfPaperSize.legal:
        format = PdfPageFormat.legal;
        break;
    }

    if (orientation == PdfOrientation.landscape) {
      format = format.landscape;
    }

    return format;
  }

  /// 一页一张布局
  static Future<void> _addOnePerPageLayout(
    pw.Document pdf,
    List<PdfImageInfo> imageInfos,
    List<pw.MemoryImage> images,
    PdfPageFormat pageFormat,
    PdfExportConfig config,
  ) async {
    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final imageInfo = imageInfos[i];

      final widget = await _buildImageTextBlock(
        image,
        imageInfo,
        config,
        config.orientation == PdfOrientation.landscape,
        isFullPage: true,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.all(config.margin),
          build: (pw.Context context) {
            return widget;
          },
        ),
      );
    }
  }

  /// 一页两张布局
  static Future<void> _addTwoPerPageLayout(
    pw.Document pdf,
    List<PdfImageInfo> imageInfos,
    List<pw.MemoryImage> images,
    PdfPageFormat pageFormat,
    PdfExportConfig config,
  ) async {
    for (int i = 0; i < images.length; i += 2) {
      final pageImages = images.skip(i).take(2).toList();
      final pageImageInfos = imageInfos.skip(i).take(2).toList();
      final isLandscape = config.orientation == PdfOrientation.landscape;

      pw.Widget widget;
      if (pageImages.length == 1) {
        widget = await _buildImageTextBlock(
          pageImages[0],
          pageImageInfos[0],
          config,
          isLandscape,
          isFullPage: true,
        );
      } else {
        final widget1 = await _buildImageTextBlockForTwoPerPage(
          pageImages[0],
          pageImageInfos[0],
          config,
          isLandscape,
        );
        final widget2 = await _buildImageTextBlockForTwoPerPage(
          pageImages[1],
          pageImageInfos[1],
          config,
          isLandscape,
        );

        // 根据纸张方向决定布局方式
        if (config.orientation == PdfOrientation.portrait) {
          // 纵向：上下排列
          widget = pw.Column(
            children: [
              pw.Expanded(child: widget1),
              pw.SizedBox(height: config.spacing),
              pw.Expanded(child: widget2),
            ],
          );
        } else {
          // 横向：左右排列
          widget = pw.Row(
            children: [
              pw.Expanded(child: widget1),
              pw.SizedBox(width: config.spacing),
              pw.Expanded(child: widget2),
            ],
          );
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.all(config.margin),
          build: (pw.Context context) {
            return widget;
          },
        ),
      );
    }
  }

  /// 一页四张布局
  static Future<void> _addFourPerPageLayout(
    pw.Document pdf,
    List<PdfImageInfo> imageInfos,
    List<pw.MemoryImage> images,
    PdfPageFormat pageFormat,
    PdfExportConfig config,
  ) async {
    for (int i = 0; i < images.length; i += 4) {
      final pageImages = images.skip(i).take(4).toList();
      final pageImageInfos = imageInfos.skip(i).take(4).toList();
      final isLandscape = config.orientation == PdfOrientation.landscape;

      // 预先构建所有widget
      final widget1 = pageImages.isNotEmpty
          ? await _buildImageTextBlock(
              pageImages[0],
              pageImageInfos[0],
              config,
              isLandscape,
            )
          : pw.Container();

      final widget2 = pageImages.length > 1
          ? await _buildImageTextBlock(
              pageImages[1],
              pageImageInfos[1],
              config,
              isLandscape,
            )
          : pw.Container();

      final widget3 = pageImages.length > 2
          ? await _buildImageTextBlock(
              pageImages[2],
              pageImageInfos[2],
              config,
              isLandscape,
            )
          : pw.Container();

      final widget4 = pageImages.length > 3
          ? await _buildImageTextBlock(
              pageImages[3],
              pageImageInfos[3],
              config,
              isLandscape,
            )
          : pw.Container();

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.all(config.margin),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Expanded(child: widget1),
                      pw.SizedBox(width: config.spacing),
                      pw.Expanded(child: widget2),
                    ],
                  ),
                ),
                pw.SizedBox(height: config.spacing),
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Expanded(child: widget3),
                      pw.SizedBox(width: config.spacing),
                      pw.Expanded(child: widget4),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  /// 一页六张布局
  static Future<void> _addSixPerPageLayout(
    pw.Document pdf,
    List<PdfImageInfo> imageInfos,
    List<pw.MemoryImage> images,
    PdfPageFormat pageFormat,
    PdfExportConfig config,
  ) async {
    for (int i = 0; i < images.length; i += 6) {
      final pageImages = images.skip(i).take(6).toList();
      final pageImageInfos = imageInfos.skip(i).take(6).toList();
      final isLandscape = config.orientation == PdfOrientation.landscape;

      // 预先构建所有widget
      final widget1 = pageImages.isNotEmpty
          ? await _buildImageTextBlock(
              pageImages[0],
              pageImageInfos[0],
              config,
              isLandscape,
            )
          : pw.Container();

      final widget2 = pageImages.length > 1
          ? await _buildImageTextBlock(
              pageImages[1],
              pageImageInfos[1],
              config,
              isLandscape,
            )
          : pw.Container();

      final widget3 = pageImages.length > 2
          ? await _buildImageTextBlock(
              pageImages[2],
              pageImageInfos[2],
              config,
              isLandscape,
            )
          : pw.Container();

      final widget4 = pageImages.length > 3
          ? await _buildImageTextBlock(
              pageImages[3],
              pageImageInfos[3],
              config,
              isLandscape,
            )
          : pw.Container();

      final widget5 = pageImages.length > 4
          ? await _buildImageTextBlock(
              pageImages[4],
              pageImageInfos[4],
              config,
              isLandscape,
            )
          : pw.Container();

      final widget6 = pageImages.length > 5
          ? await _buildImageTextBlock(
              pageImages[5],
              pageImageInfos[5],
              config,
              isLandscape,
            )
          : pw.Container();

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.all(config.margin),
          build: (pw.Context context) {
            // 根据纸张方向决定布局方式
            if (config.orientation == PdfOrientation.portrait) {
              // 纵向：3行2列
              return pw.Column(
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      children: [
                        pw.Expanded(child: widget1),
                        pw.SizedBox(width: config.spacing),
                        pw.Expanded(child: widget2),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: config.spacing),
                  pw.Expanded(
                    child: pw.Row(
                      children: [
                        pw.Expanded(child: widget3),
                        pw.SizedBox(width: config.spacing),
                        pw.Expanded(child: widget4),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: config.spacing),
                  pw.Expanded(
                    child: pw.Row(
                      children: [
                        pw.Expanded(child: widget5),
                        pw.SizedBox(width: config.spacing),
                        pw.Expanded(child: widget6),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // 横向：2行3列
              return pw.Column(
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      children: [
                        pw.Expanded(child: widget1),
                        pw.SizedBox(width: config.spacing),
                        pw.Expanded(child: widget2),
                        pw.SizedBox(width: config.spacing),
                        pw.Expanded(child: widget3),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: config.spacing),
                  pw.Expanded(
                    child: pw.Row(
                      children: [
                        pw.Expanded(child: widget4),
                        pw.SizedBox(width: config.spacing),
                        pw.Expanded(child: widget5),
                        pw.SizedBox(width: config.spacing),
                        pw.Expanded(child: widget6),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      );
    }
  }

  /// 一页九张布局
  static Future<void> _addNinePerPageLayout(
    pw.Document pdf,
    List<PdfImageInfo> imageInfos,
    List<pw.MemoryImage> images,
    PdfPageFormat pageFormat,
    PdfExportConfig config,
  ) async {
    for (int i = 0; i < images.length; i += 9) {
      final pageImages = images.skip(i).take(9).toList();
      final pageImageInfos = imageInfos.skip(i).take(9).toList();
      final isLandscape = config.orientation == PdfOrientation.landscape;

      // 预先构建所有widget
      final List<pw.Widget> widgets = [];
      for (int j = 0; j < 9; j++) {
        if (pageImages.length > j) {
          widgets.add(
            await _buildImageTextBlock(
              pageImages[j],
              pageImageInfos[j],
              config,
              isLandscape,
              showContentText: false, // 3x3布局不显示内容文本
            ),
          );
        } else {
          widgets.add(pw.Container());
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.all(config.margin),
          build: (pw.Context context) {
            return pw.Column(
              children:
                  List.generate(3, (rowIndex) {
                        return pw.Expanded(
                          child: pw.Row(
                            children: [
                              for (
                                int colIndex = 0;
                                colIndex < 3;
                                colIndex++
                              ) ...[
                                pw.Expanded(
                                  child: widgets[rowIndex * 3 + colIndex],
                                ),
                                if (colIndex < 2)
                                  pw.SizedBox(width: config.spacing),
                              ],
                            ],
                          ),
                        );
                      })
                      .expand(
                        (widget) => [
                          widget,
                          pw.SizedBox(height: config.spacing),
                        ],
                      )
                      .take(5)
                      .toList(),
            );
          },
        ),
      );
    }
  }

  /// 打印PDF文件
  static Future<bool> printPdf(
    List<PdfImageInfo> imageInfos,
    PdfExportConfig config,
  ) async {
    try {
      final pdf = await _generatePdfDocument(imageInfos, config);
      if (pdf == null) return false;

      final pdfBytes = await pdf.save();

      // 使用printing包的打印功能
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: config.fileName,
      );
      debugPrint('PDF打印对话框已打开');
      return true;
    } catch (e) {
      debugPrint('PDF打印失败: $e');
      return false;
    }
  }

  /// 保存PDF文件
  static Future<bool> _savePdf(pw.Document pdf, String fileName) async {
    try {
      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        // Web平台：使用printing包的打印功能
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: fileName,
        );
        debugPrint('Web平台PDF打印对话框已打开');
        return true;
      } else {
        // 桌面端和移动端：让用户选择保存位置
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: '保存PDF文件',
          fileName: '$fileName.pdf',
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsBytes(pdfBytes);
          debugPrint('PDF已保存到: ${file.path}');
          return true;
        } else {
          debugPrint('用户取消了保存操作');
          return false;
        }
      }
    } catch (e) {
      debugPrint('保存PDF失败: $e');
      return false;
    }
  }

  /// 获取布局类型的显示名称
  static String getLayoutTypeName(PdfLayoutType type) {
    switch (type) {
      case PdfLayoutType.onePerPage:
        return '一页一张';
      case PdfLayoutType.twoPerPage:
        return '一页两张';
      case PdfLayoutType.fourPerPage:
        return '一页四张';
      case PdfLayoutType.sixPerPage:
        return '一页六张';
      case PdfLayoutType.ninePerPage:
        return '一页九张';
    }
  }

  /// 获取纸张大小的显示名称
  static String getPaperSizeName(PdfPaperSize size) {
    switch (size) {
      case PdfPaperSize.a4:
        return 'A4';
      case PdfPaperSize.a3:
        return 'A3';
      case PdfPaperSize.letter:
        return 'Letter';
      case PdfPaperSize.legal:
        return 'Legal';
    }
  }

  /// 获取方向的显示名称
  static String getOrientationName(PdfOrientation orientation) {
    switch (orientation) {
      case PdfOrientation.portrait:
        return '竖向';
      case PdfOrientation.landscape:
        return '横向';
    }
  }
}
