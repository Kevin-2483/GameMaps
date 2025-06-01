import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart'; // For RenderRepaintBoundary
import 'package:provider/provider.dart';
import '../../../models/map_layer.dart';
import '../../../models/map_item.dart';
import '../../../models/user_preferences.dart';
import '../../../models/legend_item.dart' as legend_db;
import '../../../providers/user_preferences_provider.dart';

// 画布固定尺寸常量，确保坐标转换的一致性
const double kCanvasWidth = 1600.0;
const double kCanvasHeight = 1600.0;

/// 调整大小控制柄枚举
enum ResizeHandle {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
  centerLeft,
  centerRight,
}

/// 绘制预览数据
class DrawingPreviewData {
  final Offset start;
  final Offset end;
  final DrawingElementType elementType;
  final Color color;
  final double strokeWidth;
  final double density;
  final double curvature; // 弧度值
  final TriangleCutType triangleCut; // 三角形切割类型
  final List<Offset>? freeDrawingPath; // 自由绘制路径

  const DrawingPreviewData({
    required this.start,
    required this.end,
    required this.elementType,
    required this.color,
    required this.strokeWidth,
    required this.density,
    required this.curvature,
    required this.triangleCut,
    this.freeDrawingPath,
  });
}

/// 创建三角形裁剪路径
Path _createTrianglePath(Rect rect, TriangleCutType triangleCut) {
  final path = Path();

  switch (triangleCut) {
    case TriangleCutType.topLeft:
      // 左上三角：保留左上角，切掉右下角
      path.moveTo(rect.left, rect.top);
      path.lineTo(rect.right, rect.top);
      path.lineTo(rect.left, rect.bottom);
      path.close();
      break;

    case TriangleCutType.topRight:
      // 右上三角：保留右上角，切掉左下角
      path.moveTo(rect.left, rect.top);
      path.lineTo(rect.right, rect.top);
      path.lineTo(rect.right, rect.bottom);
      path.close();
      break;

    case TriangleCutType.bottomRight:
      // 右下三角：保留右下角，切掉左上角
      path.moveTo(rect.right, rect.top);
      path.lineTo(rect.right, rect.bottom);
      path.lineTo(rect.left, rect.bottom);
      path.close();
      break;

    case TriangleCutType.bottomLeft:
      // 左下三角：保留左下角，切掉右上角
      path.moveTo(rect.left, rect.top);
      path.lineTo(rect.right, rect.bottom);
      path.lineTo(rect.left, rect.bottom);
      path.close();
      break;
    case TriangleCutType.none:
      // 无切割：返回整个矩形
      path.addRect(rect);
      break;
  }

  return path;
}

/// 创建超椭圆路径（从圆角矩形到椭圆的渐变）
Path _createSuperellipsePath(Rect rect, double curvature) {
  if (curvature <= 0.0) {
    return Path()..addRect(rect);
  }

  // 限制弧度值在合理范围内 (0.0 到 1.0)
  final clampedCurvature = curvature.clamp(0.0, 1.0);

  final centerX = rect.center.dx;
  final centerY = rect.center.dy;
  final a = rect.width / 2;
  final b = rect.height / 2;

  if (a < 2 || b < 2) {
    return Path()..addRect(rect);
  }

  // 使用与 _drawCurvedRectangle 相同的三段式插值逻辑
  double n;
  bool useStandardEllipse = false;

  if (clampedCurvature <= 0.3) {
    // 圆角矩形阶段：从尖角 (n=8) 到圆角 (n=4)
    final t = clampedCurvature / 0.3;
    n = 8.0 - (t * 4.0); // 从 8.0 到 4.0
  } else if (clampedCurvature <= 0.7) {
    // 过渡阶段：从圆角 (n=4) 到椭圆准备 (n=2.2)
    final t = (clampedCurvature - 0.3) / 0.4;
    n = 4.0 - (t * 1.8); // 从 4.0 到 2.2
  } else {
    // 椭圆阶段：使用标准椭圆方程
    useStandardEllipse = true;
    n = 2.0; // 标准椭圆
  }

  final path = Path();
  const int numPoints = 100;

  bool isFirstPoint = true;

  for (int i = 0; i <= numPoints; i++) {
    final t = (i / numPoints) * 2 * math.pi;

    double x, y;

    if (useStandardEllipse) {
      // 使用标准椭圆方程: x = a*cos(t), y = b*sin(t)
      x = centerX + a * math.cos(t);
      y = centerY + b * math.sin(t);
    } else {
      // 使用超椭圆方程
      final cosT = math.cos(t);
      final sinT = math.sin(t);

      final signCos = cosT >= 0 ? 1.0 : -1.0;
      final signSin = sinT >= 0 ? 1.0 : -1.0;

      x = centerX + a * signCos * math.pow(cosT.abs(), 2.0 / n);
      y = centerY + b * signSin * math.pow(sinT.abs(), 2.0 / n);
    }

    if (isFirstPoint) {
      path.moveTo(x, y);
      isFirstPoint = false;
    } else {
      path.lineTo(x, y);
    }
  }

  path.close();
  return path;
}

Path _getFinalEraserPath(
  Rect rect,
  double curvature,
  TriangleCutType triangleCut,
) {
  Path curvedPath = _createSuperellipsePath(rect, curvature); // 这是你处理曲率生成路径的函数

  if (triangleCut == TriangleCutType.none) {
    return curvedPath;
  }
  Path triangleAreaPath = _createTrianglePath(rect, triangleCut); // 你提供的函数

  // 返回两个路径的交集
  return Path.combine(PathOperation.intersect, curvedPath, triangleAreaPath);
}

// --- 重构后的 _drawCurvedRectangle 函数 ---
/// 绘制弧度矩形（从圆角矩形到椭圆的渐变）
/// 现在它调用 _createEraserShapePath 来获取路径。
void _drawCurvedRectangle(
  Canvas canvas,
  Rect rect,
  Paint paint,
  double curvature,
) {
  // 基本的提前返回条件可以保留，或者让 _createEraserShapePath 处理
  // 例如，如果曲率直接是0，_createEraserShapePath 会返回一个矩形路径
  // if (curvature <= 0.0) { // _createEraserShapePath 内部会处理这种情况
  //   canvas.drawRect(rect, paint);
  //   return;
  // }
  //
  // // 如果矩形太小，_createEraserShapePath 也会处理并返回矩形路径
  // if (rect.width / 2 < 2 || rect.height / 2 < 2) {
  //   canvas.drawRect(rect, paint);
  //   return;
  // }

  // 调用核心函数来创建路径
  final Path path = _createSuperellipsePath(rect, curvature);

  // 绘制生成的路径
  canvas.drawPath(path, paint);
}

void _drawCurvedTrianglePath(
  Canvas canvas,
  Rect rect,
  Paint paint,
  double curvature,
  TriangleCutType triangleCut,
) {
  // 基本的提前返回条件可以保留，或者让 _createEraserShapePath 处理
  // 例如，如果曲率直接是0，_createEraserShapePath 会返回一个矩形路径
  // if (curvature <= 0.0) { // _createEraserShapePath 内部会处理这种情况
  //   canvas.drawRect(rect, paint);
  //   return;
  // }
  //
  // // 如果矩形太小，_createEraserShapePath 也会处理并返回矩形路径
  // if (rect.width / 2 < 2 || rect.height / 2 < 2) {
  //   canvas.drawRect(rect, paint);
  //   return;
  // }

  // 调用核心函数来创建路径
  final Path path = _getFinalEraserPath(rect, curvature, triangleCut);

  // 绘制生成的路径
  canvas.drawPath(path, paint);
}

/// 辅助类：用于管理分层元素
class _LayeredElement {
  final int order;
  final bool isSelected;
  final Widget widget;

  const _LayeredElement({
    required this.order,
    required this.isSelected,
    required this.widget,
  });
}

class MapCanvas extends StatefulWidget {
  final MapItem mapItem;
  final MapLayer? selectedLayer;
  final DrawingElementType? selectedDrawingTool;
  final Color selectedColor;
  final double selectedStrokeWidth;
  final double selectedDensity;
  final double selectedCurvature;
  final List<legend_db.LegendItem> availableLegends;
  final bool isPreviewMode;
  final Function(MapLayer) onLayerUpdated;
  final Function(LegendGroup) onLegendGroupUpdated;
  final Function(String) onLegendItemSelected;
  final Function(LegendItem) onLegendItemDoubleClicked;
  final Map<String, double> previewOpacityValues;
  final DrawingElementType? previewDrawingTool;
  final Color? previewColor;
  final double? previewStrokeWidth;
  final double? previewDensity;
  final double? previewCurvature;
  final TriangleCutType? previewTriangleCut;
  final String? selectedElementId;
  final Function(String?) onElementSelected;
  final BackgroundPattern backgroundPattern;
  final double zoomSensitivity;

  // 添加图片缓冲区相关参数
  final Uint8List? imageBufferData; // 图片缓冲区数据
  final BoxFit imageBufferFit; // 图片适应方式

  const MapCanvas({
    super.key,
    required this.mapItem,
    this.selectedLayer,
    this.selectedDrawingTool,
    required this.selectedColor,
    required this.selectedStrokeWidth,
    required this.selectedDensity,
    required this.selectedCurvature,
    required this.availableLegends,
    required this.isPreviewMode,
    required this.onLayerUpdated,
    required this.onLegendGroupUpdated,
    required this.onLegendItemSelected,
    required this.onLegendItemDoubleClicked,
    required this.previewOpacityValues,
    this.previewDrawingTool,
    this.previewColor,
    this.previewStrokeWidth,
    this.previewDensity,
    this.previewCurvature,
    this.previewTriangleCut,
    this.selectedElementId,
    required this.onElementSelected,
    required this.backgroundPattern,
    required this.zoomSensitivity,

    // 添加图片缓冲区参数
    this.imageBufferData,
    this.imageBufferFit = BoxFit.contain,
  });

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  final TransformationController _transformationController =
      TransformationController();
  Offset? _currentDrawingStart;
  Offset? _currentDrawingEnd;
  bool _isDrawing = false;
  // 添加图片缓存 - 支持实时解码
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, Future<ui.Image?>> _imageDecodingFutures = {}; // 正在解码的图片

  @override
  void initState() {
    super.initState();
    // 在组件初始化时预加载所有图层的图片
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAllLayerImages();
    });
  }

  // 监听图片缓冲区变化
  Uint8List? _lastImageBufferData;
  ui.Image? _imageBufferCachedImage;
  Future<ui.Image?>? _imageBufferDecodingFuture;
  @override
  void didUpdateWidget(MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检查图片缓冲区是否发生变化
    if (widget.imageBufferData != oldWidget.imageBufferData) {
      _handleImageBufferChange();
    }

    // 检查图层元素是否有新的图片需要解码
    if (oldWidget.selectedLayer != widget.selectedLayer) {
      _preloadLayerImages();
    }

    // 检查是否是新地图或图层数据发生了变化，如果是则预加载所有图片
    if (oldWidget.mapItem != widget.mapItem) {
      _preloadAllLayerImages();
    }
  }

  /// 预加载图层中的图片元素
  Future<void> _preloadLayerImages() async {
    if (widget.selectedLayer == null) return;

    for (final element in widget.selectedLayer!.elements) {
      if (element.type == DrawingElementType.imageArea &&
          element.imageData != null) {
        await _getOrDecodeElementImage(element);
      }
    }
  }

  /// 预加载所有图层的图片元素
  /// 在地图初始化时调用，确保所有图片立即显示
  Future<void> _preloadAllLayerImages() async {
    for (final layer in widget.mapItem.layers) {
      for (final element in layer.elements) {
        if (element.type == DrawingElementType.imageArea &&
            element.imageData != null) {
          await _getOrDecodeElementImage(element);
        }
      }
    }
  }

  /// 获取或解码元素图片
  Future<ui.Image?> _getOrDecodeElementImage(MapDrawingElement element) async {
    final cacheKey = element.id;

    // 如果已经缓存，直接返回
    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }

    // 如果正在解码，返回正在进行的Future
    if (_imageDecodingFutures.containsKey(cacheKey)) {
      return _imageDecodingFutures[cacheKey];
    }

    // 开始新的解码过程
    if (element.imageData != null) {
      final decodingFuture = _decodeElementImage(element.imageData!, cacheKey);
      _imageDecodingFutures[cacheKey] = decodingFuture;
      return decodingFuture;
    }

    return null;
  }

  /// 解码元素图片
  Future<ui.Image?> _decodeElementImage(
    Uint8List imageData,
    String cacheKey,
  ) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();

      // 缓存解码结果
      _imageCache[cacheKey] = frame.image;
      _imageDecodingFutures.remove(cacheKey);

      // 触发重绘
      if (mounted) {
        setState(() {});
      }

      return frame.image;
    } catch (e) {
      print('Failed to decode image for element $cacheKey: $e');
      _imageDecodingFutures.remove(cacheKey);
      return null;
    }
  }

  /// 处理图片缓冲区变化
  void _handleImageBufferChange() {
    // 如果图片缓冲区清空了
    if (widget.imageBufferData == null) {
      _imageBufferCachedImage?.dispose();
      _imageBufferCachedImage = null;
      _imageBufferDecodingFuture = null;
      _lastImageBufferData = null;
      return;
    }

    // 如果图片数据没有变化，不需要重新解码
    if (widget.imageBufferData == _lastImageBufferData) {
      return;
    }

    _lastImageBufferData = widget.imageBufferData;

    // 开始异步解码新图片
    _imageBufferDecodingFuture = _decodeImageBuffer(widget.imageBufferData!);
  }

  /// 异步解码图片缓冲区
  Future<ui.Image?> _decodeImageBuffer(Uint8List imageData) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();

      // 释放旧的缓存图片
      _imageBufferCachedImage?.dispose();
      _imageBufferCachedImage = frame.image;

      // 触发重绘
      if (mounted) {
        setState(() {});
      }

      return frame.image;
    } catch (e) {
      print('Failed to decode image buffer: $e');
      return null;
    }
  }

  // 自由绘制路径支持
  List<Offset> _freeDrawingPath = [];

  // 绘制预览的 ValueNotifier，避免整个 widget 重绘
  final ValueNotifier<DrawingPreviewData?> _drawingPreviewNotifier =
      ValueNotifier(null); // 获取有效的绘制工具状态（预览值或实际值）

  // Add this GlobalKey
  final GlobalKey _canvasGlobalKey = GlobalKey();

  DrawingElementType? get _effectiveDrawingTool =>
      widget.previewDrawingTool ?? widget.selectedDrawingTool;
  Color get _effectiveColor => widget.previewColor ?? widget.selectedColor;
  double get _effectiveStrokeWidth =>
      widget.previewStrokeWidth ?? widget.selectedStrokeWidth;
  double get _effectiveDensity =>
      widget.previewDensity ?? widget.selectedDensity;
  double get _effectiveCurvature =>
      widget.previewCurvature ?? widget.selectedCurvature;
  TriangleCutType get _effectiveTriangleCut =>
      widget.previewTriangleCut ?? TriangleCutType.none;

  @override
  void dispose() {
    // 清理图片缓存
    for (final image in _imageCache.values) {
      image.dispose();
    }
    _imageCache.clear();
    _imageDecodingFutures.clear();

    _imageBufferCachedImage?.dispose();

    _transformationController.dispose();
    _drawingPreviewNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.1,
          maxScale: 5.0,
          scaleFactor: 200.0 / widget.zoomSensitivity,
          constrained: false,
          child: RepaintBoundary(
            // Wrap with RepaintBoundary
            key: _canvasGlobalKey, // Assign the key
            child: SizedBox(
              width: kCanvasWidth,
              height: kCanvasHeight,
              child: Stack(
                children: [
                  // 画布容器
                  Container(
                    width: kCanvasWidth,
                    height: kCanvasHeight,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Stack(
                      children: [
                        // 背景图案（根据用户偏好设置）
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _BackgroundPatternPainter(
                              widget.backgroundPattern,
                            ),
                          ),
                        ),
                        // 按层级顺序渲染所有元素
                        ..._buildLayeredElements(),
                        // Current drawing preview
                        ValueListenableBuilder<DrawingPreviewData?>(
                          valueListenable: _drawingPreviewNotifier,
                          builder: (context, previewData, child) {
                            if (previewData == null) {
                              return const SizedBox.shrink();
                            }
                            return CustomPaint(
                              size: const Size(kCanvasWidth, kCanvasHeight),
                              painter: _CurrentDrawingPainter(
                                start: previewData.start,
                                end: previewData.end,
                                elementType: previewData.elementType,
                                color: previewData.color,
                                strokeWidth: previewData.strokeWidth,
                                density: previewData.density,
                                curvature: previewData.curvature,
                                triangleCut: previewData.triangleCut,
                                freeDrawingPath: previewData.freeDrawingPath,
                                selectedElementId: widget.selectedElementId,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Touch handler for drawing - 覆盖整个画布区域
                  if (!widget.isPreviewMode && _effectiveDrawingTool != null)
                    Positioned(
                      left: 0,
                      top: 0,
                      width: kCanvasWidth,
                      height: kCanvasHeight,
                      child: _effectiveDrawingTool == DrawingElementType.text
                          ? GestureDetector(
                              // 文本工具使用点击手势
                              onTapDown: (details) {
                                _currentDrawingStart = _getCanvasPosition(
                                  details.localPosition,
                                );
                                _showTextInputDialog();
                              },
                              behavior: HitTestBehavior.translucent,
                            )
                          : GestureDetector(
                              // 其他工具使用拖拽手势
                              onPanStart: _onDrawingStart,
                              onPanUpdate: _onDrawingUpdate,
                              onPanEnd: _onDrawingEnd,
                              behavior: HitTestBehavior.translucent,
                            ),
                    ),

                  // Touch handler for element interaction - 当没有绘制工具选中时
                  if (!widget.isPreviewMode && _effectiveDrawingTool == null)
                    Positioned(
                      left: 0,
                      top: 0,
                      width: kCanvasWidth,
                      height: kCanvasHeight,
                      child: GestureDetector(
                        onTapDown: _onElementInteractionTapDown,
                        onPanStart: _onElementInteractionPanStart,
                        onPanUpdate: _onElementInteractionPanUpdate,
                        onPanEnd: _onElementInteractionPanEnd,
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerImageWidget(MapLayer layer) {
    if (layer.imageData == null) return const SizedBox.shrink();

    // 获取有效透明度（预览值或实际值）
    final effectiveOpacity =
        widget.previewOpacityValues[layer.id] ?? layer.opacity;

    return Positioned.fill(
      child: Opacity(
        opacity: layer.isVisible ? effectiveOpacity : 0.0,
        child: Image.memory(
          layer.imageData!,
          width: kCanvasWidth,
          height: kCanvasHeight,
          fit: BoxFit.contain,
          // opacity: 1.0, // 透明度已经通过Opacity widget控制
        ),
      ),
    );
  }

  Widget _buildLayerWidget(MapLayer layer) {
    // 获取有效透明度（预览值或实际值）
    final effectiveOpacity =
        widget.previewOpacityValues[layer.id] ?? layer.opacity;

    // 获取用户偏好设置中的 handleSize
    final userPreferences = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );
    final handleSize = userPreferences.tools.handleSize;

    return Positioned.fill(
      child: Opacity(
        opacity: layer.isVisible ? effectiveOpacity : 0.0,
        child: CustomPaint(
          size: const Size(kCanvasWidth, kCanvasHeight),
          painter: _LayerPainter(
            layer: layer,
            isEditMode: !widget.isPreviewMode,
            selectedElementId: widget.selectedElementId,
            handleSize: handleSize,
            imageCache: _imageCache, // 传递元素图片缓存
            imageBufferCachedImage: _imageBufferCachedImage, // 传递缓冲区图片
            currentImageBufferData: widget.imageBufferData,
            imageBufferFit: widget.imageBufferFit,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendWidget(LegendGroup legendGroup) {
    if (!legendGroup.isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Opacity(
        opacity: legendGroup.opacity,
        child: Stack(
          children: legendGroup.legendItems
              .map((item) => _buildLegendSticker(item))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildLegendSticker(LegendItem item) {
    // 获取对应的图例数据
    final legend = widget.availableLegends.firstWhere(
      (l) => l.id.toString() == item.legendId,
      orElse: () => legend_db.LegendItem(
        title: '未知图例',
        centerX: 0.0,
        centerY: 0.0,
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (!legend.hasImageData) return const SizedBox.shrink();

    // 转换相对坐标到画布坐标
    final canvasPosition = Offset(
      item.position.dx * kCanvasWidth,
      item.position.dy * kCanvasHeight,
    );

    // 计算图例的中心点（基于图例的中心点坐标）
    final imageSize = 60.0 * item.size; // 基础大小60像素
    final centerOffset = Offset(
      imageSize * legend.centerX,
      imageSize * legend.centerY,
    );
    return Positioned(
      left: canvasPosition.dx - centerOffset.dx,
      top: canvasPosition.dy - centerOffset.dy,
      child: GestureDetector(
        onPanStart: widget.isPreviewMode
            ? null
            : (details) => _onLegendDragStart(item, details),
        onPanUpdate: widget.isPreviewMode
            ? null
            : (details) => _onLegendDragUpdate(item, details),
        onPanEnd: widget.isPreviewMode
            ? null
            : (details) => _onLegendDragEnd(item, details),
        onTap: () => _onLegendTap(item),
        onDoubleTap: () => _onLegendDoubleTap(item),
        child: Transform.rotate(
          angle: item.rotation * (3.14159 / 180), // 转换为弧度
          child: Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              border: widget.selectedElementId == item.id
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Opacity(
              opacity: item.isVisible ? item.opacity : 0.0,
              child: Stack(
                children: [
                  // 图例图片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.memory(
                      legend.imageData!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // 中心点指示器（选中时显示）
                  if (widget.selectedElementId == item.id)
                    Positioned(
                      left: centerOffset.dx - 4,
                      top: centerOffset.dy - 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  } // 图例拖拽相关方法

  LegendItem? _draggingLegendItem;
  Offset? _dragStartOffset; // 记录拖拽开始时的偏移量

  // 绘画元素拖拽和调整大小相关变量
  String? _draggingElementId; // 当前拖拽的元素ID
  Offset? _elementDragStartOffset; // 元素拖拽开始时的偏移量
  String? _resizingElementId; // 当前调整大小的元素ID
  ResizeHandle? _activeResizeHandle; // 当前活动的调整大小控制柄
  Offset? _resizeStartPosition; // 调整大小开始时的位置
  Rect? _originalElementBounds; // 元素原始边界

  // 元素交互手势处理方法
  /// 处理元素交互的点击事件
  void _onElementInteractionTapDown(TapDownDetails details) {
    final canvasPosition = _getCanvasPosition(details.localPosition);
    final hitElementId = _getHitElement(canvasPosition);

    // 只有当点击了当前选中的元素时才保持选中状态
    // 如果点击了其他地方或其他元素，则取消选择
    if (hitElementId != widget.selectedElementId) {
      // 取消选择
      widget.onElementSelected.call(null);
    }

    // 注意：我们不在这里选中新元素，只能通过Z层级检视器选中
  }

  /// 后续功能
  Future<Uint8List?> captureCanvasAreaToArgbUint8List(Rect area) async {
    // Ensure the context is mounted before proceeding
    if (!_canvasGlobalKey.currentContext!.mounted) {
      // print("Error: RepaintBoundary context not mounted.");
      return null;
    }
    try {
      RenderRepaintBoundary? boundary =
          _canvasGlobalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        // print("Error: RepaintBoundary not found.");
        return null;
      }

      // Capture the image at its native resolution (kCanvasWidth x kCanvasHeight)
      // pixelRatio: 1.0 ensures the image dimensions match kCanvasWidth/kCanvasHeight.
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);

      try {
        // Get pixel data in RGBA format
        final ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (byteData == null) {
          // print("Error: Failed to get ByteData from image.");
          return null;
        }

        final Uint8List sourcePixelsRgba = byteData.buffer.asUint8List();
        final int sourceImageWidth =
            image.width; // Should be kCanvasWidth.round()
        final int sourceImageHeight =
            image.height; // Should be kCanvasHeight.round()

        // Define canvas bounds as a Rect
        final Rect canvasBounds = Rect.fromLTWH(
          0,
          0,
          sourceImageWidth.toDouble(),
          sourceImageHeight.toDouble(),
        );

        // Find the intersection of the requested area and the canvas bounds
        // This gives the actual area to crop, fully within the canvas.
        final Rect intersectionArea = area.intersect(canvasBounds);

        if (intersectionArea.isEmpty) {
          return Uint8List(
            0,
          ); // Return empty list if no overlap or area is invalid
        }

        // Convert intersectionArea to integer coordinates for pixel access
        final int cropX = intersectionArea.left.round();
        final int cropY = intersectionArea.top.round();
        final int cropWidth = intersectionArea.width.round();
        final int cropHeight = intersectionArea.height.round();

        // Ensure calculated width/height are not negative or zero after rounding and intersection
        if (cropWidth <= 0 || cropHeight <= 0) {
          return Uint8List(0);
        }

        final Uint8List destPixelsArgb = Uint8List(
          cropWidth * cropHeight * 4,
        ); // 4 bytes per ARGB pixel

        for (int y = 0; y < cropHeight; ++y) {
          for (int x = 0; x < cropWidth; ++x) {
            // Source pixel coordinates in the full image
            final int currentSourceX = cropX + x;
            final int currentSourceY = cropY + y;

            // Index in the source RGBA buffer
            final int sourceIndex =
                (currentSourceY * sourceImageWidth + currentSourceX) * 4;

            // Safety check, though intersection should make this unnecessary if logic is sound
            if (sourceIndex + 3 < sourcePixelsRgba.length) {
              final int r = sourcePixelsRgba[sourceIndex];
              final int g = sourcePixelsRgba[sourceIndex + 1];
              final int b = sourcePixelsRgba[sourceIndex + 2];
              final int a = sourcePixelsRgba[sourceIndex + 3];

              // Index in the destination ARGB buffer
              final int destIndex = (y * cropWidth + x) * 4;
              destPixelsArgb[destIndex] = a; // Alpha
              destPixelsArgb[destIndex + 1] = r; // Red
              destPixelsArgb[destIndex + 2] = g; // Green
              destPixelsArgb[destIndex + 3] = b; // Blue
            } else {
              // Fallback for any unexpected out-of-bounds access
              final int destIndex = (y * cropWidth + x) * 4;
              destPixelsArgb[destIndex] = 0; // Transparent black
              destPixelsArgb[destIndex + 1] = 0;
              destPixelsArgb[destIndex + 2] = 0;
              destPixelsArgb[destIndex + 3] = 0;
            }
          }
        }
        return destPixelsArgb;
      } finally {
        image
            .dispose(); // IMPORTANT: Dispose the ui.Image to free up native resources
      }
    } catch (e) {
      // print("Exception in captureCanvasAreaToArgbUint8List: $e");
      return null;
    }
  }

  /// Gets the color of a single pixel at the specified [point] on the canvas.
  ///
  /// The [point] is an Offset in canvas coordinates (0,0 to kCanvasWidth, kCanvasHeight).
  /// Returns a [Color] object (ARGB), or null/transparent if the point is outside
  /// bounds or an error occurs.
  /// 后续功能
  Future<Color?> getPixelColorAtCanvasPoint(Offset point) async {
    if (!_canvasGlobalKey.currentContext!.mounted) {
      // print("Error: RepaintBoundary context not mounted.");
      return null;
    }

    final int x = point.dx.round();
    final int y = point.dy.round();

    // Check if point is outside the logical canvas dimensions
    final int canvasIntWidth = kCanvasWidth.round();
    final int canvasIntHeight = kCanvasHeight.round();

    if (x < 0 || x >= canvasIntWidth || y < 0 || y >= canvasIntHeight) {
      // print("Point ($x, $y) is outside canvas bounds ($canvasIntWidth, $canvasIntHeight). Returning transparent.");
      return Colors.transparent; // Or null, depending on desired behavior
    }

    try {
      RenderRepaintBoundary? boundary =
          _canvasGlobalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);

      try {
        final ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (byteData == null) return null;

        final Uint8List pixelsRgba = byteData.buffer.asUint8List();
        final int imageWidth = image.width; // Should be canvasIntWidth

        // Defensive check, in case image dimensions differ unexpectedly
        if (x < 0 || x >= image.width || y < 0 || y >= image.height) {
          // print("Point ($x, $y) is outside actual image dimensions (${image.width}, ${image.height}). Returning transparent.");
          return Colors.transparent;
        }

        final int index = (y * imageWidth + x) * 4; // 4 bytes per pixel (RGBA)

        if (index + 3 < pixelsRgba.length) {
          final int r = pixelsRgba[index];
          final int g = pixelsRgba[index + 1];
          final int b = pixelsRgba[index + 2];
          final int a = pixelsRgba[index + 3];
          return Color.fromARGB(a, r, g, b);
        } else {
          // Should not happen if point validation is correct
          // print("Calculated index is out of bounds for pixel data. Returning transparent.");
          return Colors.transparent; // Or null
        }
      } finally {
        image.dispose(); // IMPORTANT: Dispose the ui.Image
      }
    } catch (e) {
      // print("Exception in getPixelColorAtCanvasPoint: $e");
      return null;
    }
  }

  /// 检测点击位置是否命中某个图例项
  LegendItem? _getHitLegendItem(Offset canvasPosition) {
    // 按照渲染顺序（从上到下）检查所有可见的图例组
    for (final legendGroup in widget.mapItem.legendGroups.reversed) {
      if (!legendGroup.isVisible) continue;

      // 检查图例组中的每个图例项（按照渲染顺序）
      for (final item in legendGroup.legendItems.reversed) {
        if (!item.isVisible) continue;

        // 获取对应的图例数据
        final legend = widget.availableLegends.firstWhere(
          (l) => l.id.toString() == item.legendId,
          orElse: () => legend_db.LegendItem(
            title: '未知图例',
            centerX: 0.0,
            centerY: 0.0,
            version: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (!legend.hasImageData) continue;

        // 转换相对坐标到画布坐标
        final canvasItemPosition = Offset(
          item.position.dx * kCanvasWidth,
          item.position.dy * kCanvasHeight,
        );

        // 计算图例的实际显示区域
        final imageSize = 60.0 * item.size;
        final centerOffset = Offset(
          imageSize * legend.centerX,
          imageSize * legend.centerY,
        );

        // 修复：计算图例的实际显示矩形
        // 图例的左上角位置 = 图例中心位置 - 中心偏移
        final topLeft = Offset(
          canvasItemPosition.dx - centerOffset.dx,
          canvasItemPosition.dy - centerOffset.dy,
        );

        // 创建完整的图例显示区域矩形
        final itemRect = Rect.fromLTWH(
          topLeft.dx,
          topLeft.dy,
          imageSize,
          imageSize,
        );

        // 检查点击位置是否在图例项的显示区域内
        if (itemRect.contains(canvasPosition)) {
          return item;
        }
      }
    }
    return null;
  }

  void _onElementInteractionPanStart(DragStartDetails details) {
    final canvasPosition = _getCanvasPosition(details.localPosition);

    // --- 新增：优先检测图例交互 ---
    final hitLegendItem = _getHitLegendItem(canvasPosition);
    if (hitLegendItem != null) {
      // 如果点击了图例，启动图例拖拽，不继续处理元素交互
      _onLegendDragStart(hitLegendItem, details);
      return;
    }

    final hitElementId = _getHitElement(canvasPosition);

    // --- 步骤 1: 优先处理已选中的元素 ---
    if (widget.selectedElementId != null) {
      final selectedElement = widget.selectedLayer?.elements
          .where((e) => e.id == widget.selectedElementId)
          .firstOrNull;

      if (selectedElement != null) {
        // 获取用户偏好设置中的控制柄大小
        final userPrefsProvider = Provider.of<UserPreferencesProvider>(
          context,
          listen: false,
        );
        final handleSize = userPrefsProvider.tools.handleSize;

        // 1a. 检查是否点击了选中元素的【调整大小控制柄】
        final resizeHandle = _getHitResizeHandle(
          canvasPosition,
          selectedElement,
          handleSize: handleSize,
        );
        if (resizeHandle != null) {
          _onResizeStart(widget.selectedElementId!, resizeHandle, details);
          return; // 开始调整大小，操作结束
        }

        // 1b. 如果不是控制柄，检查是否点击了选中元素的【主体区域】
        //     这里直接使用 _isPointInElement，它不考虑 zIndex，只判断点是否在该元素的几何形状内。
        if (_isPointInElement(canvasPosition, selectedElement)) {
          _onElementDragStart(widget.selectedElementId!, details);
          return; // 开始拖动选中的元素，操作结束
        }
        // 如果点击的不是选中元素的控制柄，也不是其主体区域，则继续往下走，
        // 看看是否点击了其他元素或者空白区域。
      }
    }

    // --- 步骤 2: 如果没有与预选中的元素发生交互 (或最初就没有元素被选中) ---
    // --- 则进行常规的命中检测，找出视觉上最顶层的元素 ---
    // --- 这时调用你提供的 _getHitElement 函数是合适的 ---

    if (hitElementId != null) {
      // 如果命中了某个元素 (根据 zIndex)
      if (hitElementId != widget.selectedElementId) {
        // 并且这个元素不是当前已经选中的元素 (如果是，上面的逻辑应该已经处理了)
        // 这种情况通常是用户点击了一个新的、未选中的元素。
        // 你可以在这里处理选中新元素的操作。
        // 例如: widget.onSelectElement(hitElementIdFromTop);
        print(
          "Hit a new element by z-order: $hitElementId. Consider selecting it.",
        );
        // 根据你的设计，也可以在这里直接开始拖动新选中的元素：
        // widget.onSelectElement(hitElementIdFromTop);
        // _onElementDragStart(hitElementIdFromTop, details);
      } else {
        // 这个分支理论上不应该经常被走到，因为如果 hitElementIdFromTop 是 selectedElementId，
        // 并且不是控制柄，那么上面的 _isPointInElement(canvasPosition, selectedElement) 应该返回 true 并已处理。
        // 但如果因为某种原因（例如 _isPointInElement 的判断逻辑和元素实际绘制区域有细微差别）走到了这里，
        // 那么意味着用户确实点击了已选中的元素（且它是最顶层），可以开始拖动。
        _onElementDragStart(widget.selectedElementId!, details);
        return;
      }
    } else {
      // 点击了空白区域
      // 例如: widget.onDeselectElement();
    }
  }

  /// 处理元素交互的拖拽更新事件
  void _onElementInteractionPanUpdate(DragUpdateDetails details) {
    if (_draggingLegendItem != null) {
      // 正在拖拽图例
      _onLegendDragUpdate(_draggingLegendItem!, details);
    } else if (_resizingElementId != null) {
      // 正在调整大小
      _onResizeUpdate(_resizingElementId!, details);
    } else if (_draggingElementId != null) {
      // 正在拖拽元素
      _onElementDragUpdate(_draggingElementId!, details);
    }
  }

  /// 处理元素交互的拖拽结束事件
  void _onElementInteractionPanEnd(DragEndDetails details) {
    if (_draggingLegendItem != null) {
      // 结束拖拽图例
      final item = _draggingLegendItem!;
      _onLegendDragEnd(item, details);
    } else if (_resizingElementId != null) {
      // 结束调整大小
      final elementId = _resizingElementId!;
      _onResizeEnd(elementId, details);
    } else if (_draggingElementId != null) {
      // 结束拖拽元素
      final elementId = _draggingElementId!;
      _onElementDragEnd(elementId, details);
    }
  }

  void _onLegendDragStart(LegendItem item, DragStartDetails details) {
    _draggingLegendItem = item;

    // 计算拖拽开始时的偏移量（点击位置相对于图例中心的偏移）
    final canvasPosition = _getCanvasPosition(details.localPosition);
    final itemCanvasPosition = Offset(
      item.position.dx * kCanvasWidth,
      item.position.dy * kCanvasHeight,
    );

    _dragStartOffset = Offset(
      canvasPosition.dx - itemCanvasPosition.dx,
      canvasPosition.dy - itemCanvasPosition.dy,
    );

    setState(() {
      // 触发重绘以显示拖拽状态
    });
  }

  void _onLegendDragUpdate(LegendItem item, DragUpdateDetails details) {
    if (_draggingLegendItem?.id != item.id || _dragStartOffset == null) return;

    // 获取当前拖拽位置（不限制在画布范围内，以支持正确的偏移计算）
    final canvasPosition = _getCanvasPosition(details.localPosition);
    final adjustedPosition = Offset(
      canvasPosition.dx - _dragStartOffset!.dx,
      canvasPosition.dy - _dragStartOffset!.dy,
    );

    // 转换为相对坐标
    final relativePosition = Offset(
      adjustedPosition.dx / kCanvasWidth,
      adjustedPosition.dy / kCanvasHeight,
    );

    // 在相对坐标系统中限制范围（0.0 到 1.0）
    final clampedPosition = Offset(
      relativePosition.dx.clamp(0.0, 1.0),
      relativePosition.dy.clamp(0.0, 1.0),
    );

    // 更新图例位置
    _updateLegendItemPosition(item, clampedPosition);
  }

  void _onLegendDragEnd(LegendItem item, DragEndDetails details) {
    _draggingLegendItem = null;
    _dragStartOffset = null; // 清理偏移量
    // 保存更改到撤销历史
    // 这里可以通过回调通知主页面保存状态
  }

  void _onLegendTap(LegendItem item) {
    // 在选中前检查是否满足条件
    if (!_canSelectLegendItem(item)) {
      _showLegendSelectionNotAllowedMessage(item);
      return;
    }

    // 选中图例项，高亮显示
    widget.onLegendItemSelected.call(item.id);
  }

  void _onLegendDoubleTap(LegendItem item) {
    // 在双击前检查是否满足条件
    if (!_canSelectLegendItem(item)) {
      _showLegendSelectionNotAllowedMessage(item);
      return;
    }

    // 双击图例项，触发双击回调
    widget.onLegendItemDoubleClicked.call(item);
  }

  /// 检查是否可以选择图例项
  /// 条件：
  /// 1. 图例组必须可见
  /// 2. 至少有一个绑定的图层被选中
  bool _canSelectLegendItem(LegendItem item) {
    // 查找包含此图例项的图例组
    LegendGroup? containingGroup;
    for (final legendGroup in widget.mapItem.legendGroups) {
      if (legendGroup.legendItems.any(
        (legendItem) => legendItem.id == item.id,
      )) {
        containingGroup = legendGroup;
        break;
      }
    }

    if (containingGroup == null) {
      return false; // 找不到图例组
    }

    // 检查图例组是否可见
    if (!containingGroup.isVisible) {
      return false;
    }

    // 检查是否有绑定的图层被选中
    final boundLayers = widget.mapItem.layers.where((layer) {
      return layer.legendGroupIds.contains(containingGroup!.id);
    }).toList();

    if (boundLayers.isEmpty) {
      return true; // 如果没有绑定图层，允许选择
    }

    // 检查绑定的图层中是否有被选中的
    if (widget.selectedLayer == null) {
      return false; // 没有选中任何图层
    }

    // 检查当前选中的图层是否绑定了此图例组
    return boundLayers.any((layer) => layer.id == widget.selectedLayer!.id);
  }

  /// 显示图例选择受限的消息
  void _showLegendSelectionNotAllowedMessage(LegendItem item) {
    // 查找包含此图例项的图例组
    LegendGroup? containingGroup;
    for (final legendGroup in widget.mapItem.legendGroups) {
      if (legendGroup.legendItems.any(
        (legendItem) => legendItem.id == item.id,
      )) {
        containingGroup = legendGroup;
        break;
      }
    }

    if (containingGroup == null) return;

    String message;
    if (!containingGroup.isVisible) {
      message = '无法选择图例：图例组"${containingGroup.name}"当前不可见';
    } else {
      message = '无法选择图例：请先选择一个绑定了图例组"${containingGroup.name}"的图层';
    }

    // 使用 SnackBar 显示消息，因为在 Canvas 中显示对话框可能会有问题
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updateLegendItemPosition(LegendItem item, Offset newPosition) {
    // 找到包含此图例项的图例组
    for (final legendGroup in widget.mapItem.legendGroups) {
      final itemIndex = legendGroup.legendItems.indexWhere(
        (li) => li.id == item.id,
      );
      if (itemIndex != -1) {
        final updatedItem = item.copyWith(position: newPosition);
        final updatedItems = List<LegendItem>.from(legendGroup.legendItems);
        updatedItems[itemIndex] = updatedItem;

        final updatedGroup = legendGroup.copyWith(
          legendItems: updatedItems,
          updatedAt: DateTime.now(),
        );

        widget.onLegendGroupUpdated(updatedGroup);
        break;
      }
    }
  }

  void _onDrawingStart(DragStartDetails details) {
    if (widget.isPreviewMode || _effectiveDrawingTool == null) return;

    // 获取相对于画布的坐标，对于绘制操作需要限制在画布范围内
    _currentDrawingStart = _getClampedCanvasPosition(details.localPosition);
    _currentDrawingEnd = _currentDrawingStart;
    _isDrawing = true;

    // 初始化自由绘制路径
    if (_effectiveDrawingTool == DrawingElementType.freeDrawing) {
      _freeDrawingPath = [_currentDrawingStart!];
    } // 只更新绘制预览，不触发整个 widget 重绘
    _drawingPreviewNotifier.value = DrawingPreviewData(
      start: _currentDrawingStart!,
      end: _currentDrawingEnd!,
      elementType: _effectiveDrawingTool!,
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
      density: _effectiveDensity,
      curvature: _effectiveCurvature,
      triangleCut: _effectiveTriangleCut,
      freeDrawingPath: _effectiveDrawingTool == DrawingElementType.freeDrawing
          ? _freeDrawingPath
          : null,
    );
  }

  void _onDrawingUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    // 获取相对于画布的坐标，对于绘制操作需要限制在画布范围内
    _currentDrawingEnd = _getClampedCanvasPosition(
      details.localPosition,
    ); // 自由绘制路径处理
    if (_effectiveDrawingTool == DrawingElementType.freeDrawing) {
      _freeDrawingPath.add(_currentDrawingEnd!); // 对于自由绘制，使用路径信息更新预览
      _drawingPreviewNotifier.value = DrawingPreviewData(
        start: _freeDrawingPath.first,
        end: _freeDrawingPath.last,
        elementType: _effectiveDrawingTool!,
        color: _effectiveColor,
        strokeWidth: _effectiveStrokeWidth,
        density: _effectiveDensity,
        curvature: _effectiveCurvature,
        triangleCut: _effectiveTriangleCut,
        freeDrawingPath: _freeDrawingPath,
      );
      return;
    }
    // 只更新绘制预览，不触发整个 widget 重绘
    _drawingPreviewNotifier.value = DrawingPreviewData(
      start: _currentDrawingStart!,
      end: _currentDrawingEnd!,
      elementType: _effectiveDrawingTool!,
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
      density: _effectiveDensity,
      curvature: _effectiveCurvature,
      triangleCut: _effectiveTriangleCut,
      freeDrawingPath: null,
    );
  }

  // 获取相对于画布的正确坐标
  Offset _getCanvasPosition(Offset localPosition) {
    // localPosition 已经是相对于画布容器的坐标
    // 对于绘制操作，需要限制在画布范围内
    // 对于拖拽操作，不应该限制以避免偏移量计算错误
    return localPosition;
  }

  // 专门用于绘制操作的坐标获取，会进行边界限制
  Offset _getClampedCanvasPosition(Offset localPosition) {
    final clampedX = localPosition.dx.clamp(0.0, kCanvasWidth);
    final clampedY = localPosition.dy.clamp(0.0, kCanvasHeight);
    return Offset(clampedX, clampedY);
  }

  void _onDrawingEnd(DragEndDetails details) {
    if (!_isDrawing ||
        _currentDrawingStart == null ||
        _currentDrawingEnd == null ||
        widget.selectedLayer == null) {
      _isDrawing = false;
      _currentDrawingStart = null;
      _currentDrawingEnd = null;
      _drawingPreviewNotifier.value = null; // 清除预览
      return;
    }

    // Convert screen coordinates to normalized coordinates (0.0-1.0)
    // 使用固定的画布尺寸，与绘制时保持一致
    final normalizedStart = Offset(
      _currentDrawingStart!.dx / kCanvasWidth,
      _currentDrawingStart!.dy / kCanvasHeight,
    );
    final normalizedEnd = Offset(
      _currentDrawingEnd!.dx / kCanvasWidth,
      _currentDrawingEnd!.dy / kCanvasHeight,
    ); // 处理橡皮擦功能
    if (_effectiveDrawingTool == DrawingElementType.eraser) {
      _handleEraserAction(normalizedStart, normalizedEnd);
    } else if (_effectiveDrawingTool == DrawingElementType.freeDrawing) {
      _handleFreeDrawingEnd();
    } else {
      // 计算新元素的 z 值（比当前最大 z 值大 1）
      final maxZIndex = widget.selectedLayer!.elements.isEmpty
          ? 0
          : widget.selectedLayer!.elements
                .map((e) => e.zIndex)
                .reduce(
                  (a, b) => a > b ? a : b,
                ); // Add the drawing element to the selected layer
      final element = MapDrawingElement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _effectiveDrawingTool!,
        points: [normalizedStart, normalizedEnd],
        color: _effectiveColor,
        strokeWidth: _effectiveStrokeWidth,
        density: _effectiveDensity,
        curvature: _effectiveCurvature,
        triangleCut: _effectiveTriangleCut,
        zIndex: maxZIndex + 1,
        createdAt: DateTime.now(),
        // 对于图片选区工具，将缓冲区数据复制到元素中，使其独立于缓冲区
        imageData: _effectiveDrawingTool == DrawingElementType.imageArea
            ? widget.imageBufferData
            : null,
        imageFit: _effectiveDrawingTool == DrawingElementType.imageArea
            ? widget.imageBufferFit
            : null,
      );

      final updatedLayer = widget.selectedLayer!.copyWith(
        elements: [...widget.selectedLayer!.elements, element],
        updatedAt: DateTime.now(),
      );

      widget.onLayerUpdated(updatedLayer);
    }

    // 清理绘制状态，不需要 setState
    _isDrawing = false;
    _currentDrawingStart = null;
    _currentDrawingEnd = null;
    _drawingPreviewNotifier.value = null; // 清除预览
  } // 处理橡皮擦动作 - 使用 z 值方式

  void _handleEraserAction(Offset normalizedStart, Offset normalizedEnd) {
    // 计算橡皮擦的 z 值（比当前 z 值大 1）
    final maxZIndex = widget.selectedLayer!.elements.isEmpty
        ? 0
        : widget.selectedLayer!.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b);

    // 创建一个橡皮擦元素，用于遮挡下方的绘制元素
    final eraserElement = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.eraser,
      points: [normalizedStart, normalizedEnd],
      color: Colors.transparent, // 橡皮擦本身是透明的
      strokeWidth: 0.0,
      curvature: _effectiveCurvature, // 保存曲率参数
      triangleCut: _effectiveTriangleCut,
      zIndex: maxZIndex + 1,
      createdAt: DateTime.now(),
    );
    final updatedLayer = widget.selectedLayer!.copyWith(
      elements: [...widget.selectedLayer!.elements, eraserElement],
      updatedAt: DateTime.now(),
    );

    widget.onLayerUpdated(updatedLayer);
  }

  // 处理自由绘制完成
  void _handleFreeDrawingEnd() {
    if (_freeDrawingPath.isEmpty || widget.selectedLayer == null) return;

    // 将路径点转换为标准化坐标
    final normalizedPoints = _freeDrawingPath
        .map(
          (point) => Offset(point.dx / kCanvasWidth, point.dy / kCanvasHeight),
        )
        .toList();

    // 计算新元素的 z 值
    final maxZIndex = widget.selectedLayer!.elements.isEmpty
        ? 0
        : widget.selectedLayer!.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b); // 创建自由绘制元素
    final element = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.freeDrawing,
      points: normalizedPoints,
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
      density: _effectiveDensity,
      curvature: _effectiveCurvature,
      zIndex: maxZIndex + 1,
      createdAt: DateTime.now(),
    );

    final updatedLayer = widget.selectedLayer!.copyWith(
      elements: [...widget.selectedLayer!.elements, element],
      updatedAt: DateTime.now(),
    );

    widget.onLayerUpdated(updatedLayer);

    // 清空路径
    _freeDrawingPath.clear();
  }

  void _showTextInputDialog() async {
    final textController = TextEditingController();
    final fontSize = ValueNotifier<double>(16.0);

    // 保存文本位置，避免在对话框期间被清除
    final textPosition = _currentDrawingStart;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加文本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: '文本内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<double>(
              valueListenable: fontSize,
              builder: (context, value, child) => Column(
                children: [
                  Text('字体大小: ${value.round()}px'),
                  Slider(
                    value: value,
                    min: 10.0,
                    max: 48.0,
                    divisions: 19,
                    onChanged: (newValue) => fontSize.value = newValue,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Navigator.of(context).pop({
                  'text': textController.text,
                  'fontSize': fontSize.value,
                });
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null && result['text'] != null && textPosition != null) {
      _createTextElement(result['text'], result['fontSize'], textPosition);
    }

    // 重置绘制状态
    _isDrawing = false;
    _currentDrawingStart = null;
    _currentDrawingEnd = null;
    _drawingPreviewNotifier.value = null;
  }

  void _createTextElement(String text, double fontSize, Offset position) {
    if (widget.selectedLayer == null) return;

    final normalizedPosition = Offset(
      position.dx / kCanvasWidth,
      position.dy / kCanvasHeight,
    );

    final maxZIndex = widget.selectedLayer!.elements.isEmpty
        ? 0
        : widget.selectedLayer!.elements
              .map((e) => e.zIndex)
              .reduce((a, b) => a > b ? a : b);
    final element = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: DrawingElementType.text,
      points: [normalizedPosition],
      color: _effectiveColor,
      strokeWidth: _effectiveStrokeWidth,
      density: _effectiveDensity,
      curvature: _effectiveCurvature,
      zIndex: maxZIndex + 1,
      text: text,
      fontSize: fontSize,
      createdAt: DateTime.now(),
    );

    final updatedLayer = widget.selectedLayer!.copyWith(
      elements: [...widget.selectedLayer!.elements, element],
      updatedAt: DateTime.now(),
    );

    widget.onLayerUpdated(updatedLayer);
  }

  /// 构建按层级排序的所有元素
  List<Widget> _buildLayeredElements() {
    final List<_LayeredElement> allElements = [];

    // **关键修改：使用 mapItem.layers 的顺序，而不是基于 order 字段重新排序**
    // 收集所有图层及其元素（按照 mapItem.layers 中的顺序）
    for (
      int layerIndex = 0;
      layerIndex < widget.mapItem.layers.length;
      layerIndex++
    ) {
      final layer = widget.mapItem.layers[layerIndex];
      if (!layer.isVisible) continue;

      final isSelectedLayer = widget.selectedLayer?.id == layer.id;

      // 添加图层图片（如果有）
      if (layer.imageData != null) {
        allElements.add(
          _LayeredElement(
            order: layerIndex, // 使用在 mapItem.layers 中的索引作为渲染顺序
            isSelected: isSelectedLayer,
            widget: _buildLayerImageWidget(layer),
          ),
        );
      }

      // 添加图层绘制元素
      allElements.add(
        _LayeredElement(
          order: layerIndex, // 使用在 mapItem.layers 中的索引作为渲染顺序
          isSelected: isSelectedLayer,
          widget: _buildLayerWidget(layer),
        ),
      );
    }

    // 收集所有图例组
    for (final legendGroup in widget.mapItem.legendGroups) {
      if (!legendGroup.isVisible) continue;

      // 计算图例组的层级（基于绑定的最高图层在 mapItem.layers 中的位置）
      int legendOrder = -1;
      bool isLegendSelected = false;

      for (
        int layerIndex = 0;
        layerIndex < widget.mapItem.layers.length;
        layerIndex++
      ) {
        final layer = widget.mapItem.layers[layerIndex];
        if (layer.legendGroupIds.contains(legendGroup.id)) {
          legendOrder = math.max(legendOrder, layerIndex); // 使用图层在列表中的位置
          // 如果任何绑定的图层被选中，图例也被认为是选中的
          if (widget.selectedLayer?.id == layer.id) {
            isLegendSelected = true;
          }
        }
      }

      // 如果图例组没有绑定到任何图层，使用默认order
      if (legendOrder == -1) {
        legendOrder = 0;
      }

      allElements.add(
        _LayeredElement(
          order: legendOrder,
          isSelected: isLegendSelected,
          widget: _buildLegendWidget(legendGroup),
        ),
      );
    }

    // 按order排序，选中的元素排在最后（显示在最上层）
    allElements.sort((a, b) {
      if (a.isSelected && !b.isSelected) return 1;
      if (!a.isSelected && b.isSelected) return -1;
      return a.order.compareTo(b.order);
    });

    return allElements.map((e) => e.widget).toList();
  }

  // 绘画元素选择和操作相关方法

  /// 检测点击位置是否命中某个绘画元素
  String? _getHitElement(Offset canvasPosition) {
    if (widget.selectedLayer == null ||
        widget.selectedLayer!.elements.isEmpty) {
      return null;
    }

    // 按z值倒序检查，确保优先选择上层元素
    final sortedElements = List<MapDrawingElement>.from(
      widget.selectedLayer!.elements,
    )..sort((a, b) => b.zIndex.compareTo(a.zIndex));

    for (final element in sortedElements) {
      if (_isPointInElement(canvasPosition, element)) {
        return element.id;
      }
    }
    return null;
  }

  /// 检查点是否在指定元素内
  bool _isPointInElement(Offset canvasPosition, MapDrawingElement element) {
    final size = const Size(kCanvasWidth, kCanvasHeight);

    switch (element.type) {
      case DrawingElementType.text:
        if (element.points.isEmpty) return false;
        final textPosition = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        // 为文本创建一个点击区域
        final hitArea = Rect.fromCenter(
          center: textPosition,
          width: 100, // 假设文本宽度
          height: element.fontSize ?? 16.0,
        );
        return hitArea.contains(canvasPosition);

      case DrawingElementType.freeDrawing:
        // 检查点是否靠近自由绘制路径
        for (final point in element.points) {
          final screenPoint = Offset(
            point.dx * size.width,
            point.dy * size.height,
          );
          if ((screenPoint - canvasPosition).distance < 10) {
            return true;
          }
        }
        return false;

      default:
        // 其他元素基于矩形边界检测
        if (element.points.length < 2) return false;
        final start = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        final end = Offset(
          element.points[1].dx * size.width,
          element.points[1].dy * size.height,
        );
        final rect = Rect.fromPoints(start, end);
        return rect.contains(canvasPosition);
    }
  }

  /// 处理绘画元素的拖拽开始
  void _onElementDragStart(String elementId, DragStartDetails details) {
    _draggingElementId = elementId; // 计算拖拽开始时的偏移量
    final canvasPosition = _getCanvasPosition(details.localPosition);
    final element = widget.selectedLayer!.elements
        .where((e) => e.id == elementId)
        .first;

    // 计算元素中心位置
    Offset elementCenter;
    if (element.type == DrawingElementType.text) {
      elementCenter = Offset(
        element.points[0].dx * kCanvasWidth,
        element.points[0].dy * kCanvasHeight,
      );
    } else if (element.points.length >= 2) {
      final start = Offset(
        element.points[0].dx * kCanvasWidth,
        element.points[0].dy * kCanvasHeight,
      );
      final end = Offset(
        element.points[1].dx * kCanvasWidth,
        element.points[1].dy * kCanvasHeight,
      );
      elementCenter = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    } else {
      return;
    }

    _elementDragStartOffset = Offset(
      canvasPosition.dx - elementCenter.dx,
      canvasPosition.dy - elementCenter.dy,
    );

    setState(() {
      // 触发重绘以显示拖拽状态
    });
  }

  /// 处理绘画元素的拖拽更新
  void _onElementDragUpdate(String elementId, DragUpdateDetails details) {
    if (_draggingElementId != elementId || _elementDragStartOffset == null)
      return;

    final canvasPosition = _getCanvasPosition(details.localPosition);
    final adjustedPosition = Offset(
      canvasPosition.dx - _elementDragStartOffset!.dx,
      canvasPosition.dy - _elementDragStartOffset!.dy,
    );

    // 更新元素位置
    _updateElementPosition(elementId, adjustedPosition);
  }

  /// 处理绘画元素的拖拽结束
  void _onElementDragEnd(String elementId, DragEndDetails details) {
    _draggingElementId = null;
    _elementDragStartOffset = null;

    setState(() {
      // 触发重绘以清除拖拽状态
    });
  }

  /// 更新元素位置
  void _updateElementPosition(String elementId, Offset newCenter) {
    if (widget.selectedLayer == null) return;

    final elementIndex = widget.selectedLayer!.elements.indexWhere(
      (e) => e.id == elementId,
    );
    if (elementIndex == -1) return;

    final element = widget.selectedLayer!.elements[elementIndex];
    final updatedElements = List<MapDrawingElement>.from(
      widget.selectedLayer!.elements,
    );

    // 转换为标准化坐标
    final normalizedCenter = Offset(
      (newCenter.dx / kCanvasWidth).clamp(0.0, 1.0),
      (newCenter.dy / kCanvasHeight).clamp(0.0, 1.0),
    );

    MapDrawingElement updatedElement;

    if (element.type == DrawingElementType.text) {
      // 文本元素只有一个点
      updatedElement = element.copyWith(points: [normalizedCenter]);
    } else if (element.points.length >= 2) {
      // 计算当前元素的尺寸
      final currentStart = element.points[0];
      final currentEnd = element.points[1];
      final width = (currentEnd.dx - currentStart.dx).abs();
      final height = (currentEnd.dy - currentStart.dy).abs();

      // 保持尺寸，更新位置
      final newStart = Offset(
        normalizedCenter.dx - width / 2,
        normalizedCenter.dy - height / 2,
      );
      final newEnd = Offset(
        normalizedCenter.dx + width / 2,
        normalizedCenter.dy + height / 2,
      );
      updatedElement = element.copyWith(points: [newStart, newEnd]);
    } else {
      return;
    }

    updatedElements[elementIndex] = updatedElement;
    final updatedLayer = widget.selectedLayer!.copyWith(
      elements: updatedElements,
    );

    widget.onLayerUpdated(updatedLayer);
  }

  /// 获取调整大小控制柄的矩形区域
  static List<Rect> getResizeHandles(
    MapDrawingElement element, {
    double? handleSize,
  }) {
    if (element.points.length < 2) return [];

    final size = const Size(kCanvasWidth, kCanvasHeight);
    final start = Offset(
      element.points[0].dx * size.width,
      element.points[0].dy * size.height,
    );
    final end = Offset(
      element.points[1].dx * size.width,
      element.points[1].dy * size.height,
    );
    final rect = Rect.fromPoints(start, end);

    final effectiveHandleSize = handleSize ?? 8.0;
    final handles = <Rect>[]; // 四个角的控制柄
    handles.add(
      Rect.fromCenter(
        center: rect.topLeft,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: rect.topRight,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: rect.bottomLeft,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: rect.bottomRight,
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );

    // 边中点的控制柄
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.center.dx, rect.top),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.center.dx, rect.bottom),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.left, rect.center.dy),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );
    handles.add(
      Rect.fromCenter(
        center: Offset(rect.right, rect.center.dy),
        width: effectiveHandleSize,
        height: effectiveHandleSize,
      ),
    );

    return handles;
  }

  /// 检测点击位置命中哪个调整大小控制柄
  ResizeHandle? _getHitResizeHandle(
    Offset canvasPosition,
    MapDrawingElement element, {
    double? handleSize,
  }) {
    final handles = _MapCanvasState.getResizeHandles(
      element,
      handleSize: handleSize,
    );

    for (int i = 0; i < handles.length; i++) {
      if (handles[i].contains(canvasPosition)) {
        return ResizeHandle.values[i];
      }
    }
    return null;
  }

  /// 处理调整大小的开始
  void _onResizeStart(
    String elementId,
    ResizeHandle handle,
    DragStartDetails details,
  ) {
    _resizingElementId = elementId;
    _activeResizeHandle = handle;
    _resizeStartPosition = _getCanvasPosition(details.localPosition);
    final element = widget.selectedLayer!.elements
        .where((e) => e.id == elementId)
        .first;
    if (element.points.length >= 2) {
      final size = const Size(kCanvasWidth, kCanvasHeight);
      final start = Offset(
        element.points[0].dx * size.width,
        element.points[0].dy * size.height,
      );
      final end = Offset(
        element.points[1].dx * size.width,
        element.points[1].dy * size.height,
      );
      _originalElementBounds = Rect.fromPoints(start, end);
    }

    setState(() {
      // 触发重绘以显示调整大小状态
    });
  }

  /// 处理调整大小的更新
  void _onResizeUpdate(String elementId, DragUpdateDetails details) {
    if (_resizingElementId != elementId ||
        _activeResizeHandle == null ||
        _resizeStartPosition == null ||
        _originalElementBounds == null)
      return;

    final currentPosition = _getCanvasPosition(details.localPosition);
    final delta = currentPosition - _resizeStartPosition!;

    // 根据控制柄类型计算新的边界
    Rect newBounds = _calculateNewBounds(
      _originalElementBounds!,
      _activeResizeHandle!,
      delta,
    );

    // 更新元素大小
    _updateElementSize(elementId, newBounds);
  }

  /// 处理调整大小的结束
  void _onResizeEnd(String elementId, DragEndDetails details) {
    _resizingElementId = null;
    _activeResizeHandle = null;
    _resizeStartPosition = null;
    _originalElementBounds = null;

    setState(() {
      // 触发重绘以清除调整大小状态
    });
  }

  /// 根据控制柄和拖拽偏移计算新边界
  Rect _calculateNewBounds(
    Rect originalBounds,
    ResizeHandle handle,
    Offset delta,
  ) {
    double left = originalBounds.left;
    double top = originalBounds.top;
    double right = originalBounds.right;
    double bottom = originalBounds.bottom;

    switch (handle) {
      case ResizeHandle.topLeft:
        left += delta.dx;
        top += delta.dy;
        break;
      case ResizeHandle.topRight:
        right += delta.dx;
        top += delta.dy;
        break;
      case ResizeHandle.bottomLeft:
        left += delta.dx;
        bottom += delta.dy;
        break;
      case ResizeHandle.bottomRight:
        right += delta.dx;
        bottom += delta.dy;
        break;
      case ResizeHandle.topCenter:
        top += delta.dy;
        break;
      case ResizeHandle.bottomCenter:
        bottom += delta.dy;
        break;
      case ResizeHandle.centerLeft:
        left += delta.dx;
        break;
      case ResizeHandle.centerRight:
        right += delta.dx;
        break;
    }

    // 确保最小尺寸
    const minSize = 0.0;
    if (right - left < minSize) {
      if (handle == ResizeHandle.centerLeft ||
          handle == ResizeHandle.topLeft ||
          handle == ResizeHandle.bottomLeft) {
        left = right - minSize;
      } else {
        right = left + minSize;
      }
    }
    if (bottom - top < minSize) {
      if (handle == ResizeHandle.topCenter ||
          handle == ResizeHandle.topLeft ||
          handle == ResizeHandle.topRight) {
        top = bottom - minSize;
      } else {
        bottom = top + minSize;
      }
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// 更新元素大小
  void _updateElementSize(String elementId, Rect newBounds) {
    if (widget.selectedLayer == null) return;

    final elementIndex = widget.selectedLayer!.elements.indexWhere(
      (e) => e.id == elementId,
    );
    if (elementIndex == -1) return;

    final element = widget.selectedLayer!.elements[elementIndex];
    final updatedElements = List<MapDrawingElement>.from(
      widget.selectedLayer!.elements,
    );

    // 转换为标准化坐标
    final normalizedStart = Offset(
      (newBounds.left / kCanvasWidth).clamp(0.0, 1.0),
      (newBounds.top / kCanvasHeight).clamp(0.0, 1.0),
    );
    final normalizedEnd = Offset(
      (newBounds.right / kCanvasWidth).clamp(0.0, 1.0),
      (newBounds.bottom / kCanvasHeight).clamp(0.0, 1.0),
    );
    final updatedElement = element.copyWith(
      points: [normalizedStart, normalizedEnd],
    );

    updatedElements[elementIndex] = updatedElement;

    final updatedLayer = widget.selectedLayer!.copyWith(
      elements: updatedElements,
    );

    widget.onLayerUpdated(updatedLayer);
  }
}

class _LayerPainter extends CustomPainter {
  final MapLayer layer;
  final bool isEditMode;
  final String? selectedElementId;
  final double? handleSize;
  final Map<String, ui.Image> imageCache; // 元素图片缓存
  final ui.Image? imageBufferCachedImage; // 图片缓冲区缓存
  final Uint8List? currentImageBufferData; // 当前图片缓冲区数据
  final BoxFit imageBufferFit; // 图片缓冲区适应方式

  _LayerPainter({
    required this.layer,
    required this.isEditMode,
    this.selectedElementId,
    this.handleSize,
    required this.imageCache,
    this.imageBufferCachedImage,
    this.currentImageBufferData,
    this.imageBufferFit = BoxFit.contain,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 按 z 值排序元素
    final sortedElements = List<MapDrawingElement>.from(layer.elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    // 找到所有橡皮擦元素
    final eraserElements = sortedElements
        .where((e) => e.type == DrawingElementType.eraser)
        .toList();

    // 首先绘制所有常规元素
    for (final element in sortedElements) {
      if (element.type == DrawingElementType.eraser) {
        continue; // 橡皮擦本身不绘制
      }

      // 使用裁剪来实现选择性遮挡
      _drawElementWithEraserMask(canvas, element, eraserElements, size);
    } // 最后绘制选中元素的彩虹效果，确保它不受任何遮挡
    if (selectedElementId != null) {
      final selectedElement = sortedElements
          .where((e) => e.id == selectedElementId)
          .firstOrNull;
      if (selectedElement != null) {
        _drawRainbowHighlight(canvas, selectedElement, size);
        _drawResizeHandles(
          canvas,
          selectedElement,
          size,
          handleSize: handleSize,
        );
      }
    }
  }

  // 根据元素类型直接显示内容
  void _drawRainbowHighlight(
    Canvas canvas,
    MapDrawingElement element,
    Size size,
  ) {
    // 首先获取元素的坐标
    if (element.points.isEmpty) return;

    // 彩虹色渐变效果（用于填充文本或形状）
    final rainbowColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    // 获取当前时间以创建动画效果
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final animOffset = now % 1.0; // 0.0 - 1.0 之间循环变化

    // 根据元素类型绘制不同的内容
    switch (element.type) {
      case DrawingElementType.text:
        // 文本元素
        if (element.text == null || element.text!.isEmpty) return;

        final position = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );

        // 创建彩虹渐变文本
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.text!,
            style: TextStyle(
              fontSize: element.fontSize ?? 16.0,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: rainbowColors,
                  transform: GradientRotation(animOffset * math.pi * 2),
                ).createShader(Rect.fromLTWH(0, 0, 300, 50)),
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, position);
        break;

      case DrawingElementType.freeDrawing:
        // 自由绘制路径
        if (element.points.length < 2) return;

        final path = Path();
        final screenPoints = element.points
            .map(
              (point) => Offset(point.dx * size.width, point.dy * size.height),
            )
            .toList();

        path.moveTo(screenPoints[0].dx, screenPoints[0].dy);
        for (int i = 1; i < screenPoints.length; i++) {
          path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
        }

        // 彩虹渐变画笔
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = element.strokeWidth + 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = LinearGradient(
            colors: rainbowColors,
            transform: GradientRotation(animOffset * math.pi * 2),
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

        canvas.drawPath(path, paint);
        break;

      default:
        // 其他基于两点的元素
        if (element.points.length < 2) return;

        final start = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );

        final end = Offset(
          element.points[1].dx * size.width,
          element.points[1].dy * size.height,
        );

        // 彩虹渐变画笔
        final paint = Paint()
          ..strokeWidth = element.strokeWidth + 2
          ..shader = LinearGradient(
            colors: rainbowColors,
            transform: GradientRotation(animOffset * math.pi * 2),
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

        // 根据不同的绘制类型绘制不同的形状
        switch (element.type) {
          case DrawingElementType.line:
            paint.style = PaintingStyle.stroke;
            canvas.drawLine(start, end, paint);
            break;
          case DrawingElementType.dashedLine:
            paint.style = PaintingStyle.stroke;
            _drawDashedLine(canvas, start, end, paint, element.density);
            break;

          case DrawingElementType.arrow:
            paint.style = PaintingStyle.stroke;
            _drawArrow(canvas, start, end, paint);
            break;
          case DrawingElementType.rectangle:
            paint.style = PaintingStyle.fill;
            final rect = Rect.fromPoints(start, end);
            canvas.drawRect(rect, paint);
            break;

          case DrawingElementType.hollowRectangle:
            paint.style = PaintingStyle.stroke;
            final rect = Rect.fromPoints(start, end);
            canvas.drawRect(rect, paint);
            break;
          case DrawingElementType.diagonalLines:
            paint.style = PaintingStyle.stroke;
            _drawDiagonalPattern(canvas, start, end, paint, element.density);
            break;

          case DrawingElementType.crossLines:
            paint.style = PaintingStyle.stroke;
            _drawCrossPattern(canvas, start, end, paint, element.density);
            break;

          case DrawingElementType.dotGrid:
            paint.style = PaintingStyle.fill;
            _drawDotGrid(canvas, start, end, paint, element.density);
            break;

          default:
            // 默认绘制一个边框
            paint.style = PaintingStyle.stroke;
            final rect = Rect.fromPoints(start, end);
            canvas.drawRect(rect, paint);
            break;
        }
        break;
    }
  }

  void _drawResizeHandles(
    Canvas canvas,
    MapDrawingElement element,
    Size size, {
    double? handleSize,
  }) {
    // 获取所有调整手柄的位置
    final handles = _MapCanvasState.getResizeHandles(
      element,
      handleSize: handleSize,
    );

    if (handles.isEmpty) return;

    // 外边框画笔（白色边框）
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // 内部填充画笔（蓝色）
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // 使用动态大小计算圆形半径
    final effectiveHandleSize = handleSize ?? 8.0;
    final radius = effectiveHandleSize / 4.0; // 控制柄内圆半径为控制柄大小的1/4
    final borderRadius = radius + 0.5;

    // 绘制每个控制柄为圆形
    for (final handle in handles) {
      final center = handle.center;

      // 白色边框圆（稍大）
      canvas.drawCircle(center, borderRadius, borderPaint);

      // 蓝色填充圆（略小）
      canvas.drawCircle(center, radius, fillPaint);
    }
  }

  void _drawElementWithEraserMask(
    Canvas canvas,
    MapDrawingElement element,
    List<MapDrawingElement> eraserElements,
    Size size,
  ) {
    // 找到影响当前元素的橡皮擦（z值更高的）
    final affectingErasers = eraserElements
        .where((eraser) => eraser.zIndex > element.zIndex)
        .toList();

    if (affectingErasers.isEmpty) {
      // 没有橡皮擦影响，直接绘制
      _drawElement(canvas, element, size);
      return;
    }

    // 保存canvas状态
    canvas.save();

    // 创建裁剪路径，初始为整个画布区域，然后从中排除所有相关橡皮擦区域
    Path clipPath = Path();
    clipPath.addRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    ); // 添加整个画布区域作为基础

    // 减去所有影响当前元素的橡皮擦区域
    for (final eraser in affectingErasers) {
      // 确保橡皮擦元素有足够的点来定义一个矩形
      // 并且橡皮擦类型是 eraser (如果你的 MapDrawingElement 有 type 属性来区分普通元素和橡皮擦)
      if (eraser.points.length >=
          2 /* && eraser.type == DrawingElementType.eraser */ ) {
        // 转换橡皮擦坐标到屏幕坐标
        final eraserStart = Offset(
          eraser.points[0].dx * size.width,
          eraser.points[0].dy * size.height,
        );
        final eraserEnd = Offset(
          eraser.points[1].dx * size.width,
          eraser.points[1].dy * size.height,
        );
        final eraserRect = Rect.fromPoints(eraserStart, eraserEnd);

        // 检查橡皮擦是否与当前元素重叠 (这个函数对于性能很重要)
        // 确保 _doesEraserAffectElement 内部也使用了考虑 triangleCut 的碰撞检测逻辑
        final doesEraserAffectElement = _doesEraserAffectElement(
          element,
          eraser,
          size,
        );
        // print(doesEraserAffectElement);
        if (doesEraserAffectElement) {
          // *** 修改在这里：调用 _getFinalEraserPath 并传入 triangleCut ***
          final Path singleEraserPath = _getFinalEraserPath(
            eraserRect,
            eraser.curvature,
            eraser.triangleCut, // 使用橡皮擦元素的 triangleCut 属性
          );

          // 从允许绘制的区域中减去这个橡皮擦的路径
          clipPath = Path.combine(
            PathOperation.difference,
            clipPath,
            singleEraserPath,
          );
        }
      }
    }

    // 应用计算好的裁剪路径
    // 后续的绘制操作将只在 clipPath 定义的区域内可见
    canvas.clipPath(clipPath);

    // 在裁剪后的区域内绘制元素
    _drawElement(canvas, element, size);

    // 恢复canvas状态
    canvas.restore();
  }

  // 检查橡皮擦是否影响元素
  bool _doesEraserAffectElement(
    MapDrawingElement element,
    MapDrawingElement eraser,
    Size size,
  ) {
    // 基础检查
    if (element.points.isEmpty || eraser.points.length < 2) return false;

    // 获取橡皮擦的基础信息
    final eraserStart = Offset(
      eraser.points[0].dx * size.width,
      eraser.points[0].dy * size.height,
    );
    final eraserEnd = Offset(
      eraser.points[1].dx * size.width,
      eraser.points[1].dy * size.height,
    );
    final Rect eraserRect = Rect.fromPoints(eraserStart, eraserEnd);
    final double eraserCurvature = eraser.curvature;
    final TriangleCutType eraserTriangleCut = eraser.triangleCut; // 获取橡皮擦的切割类型
    // print(eraserTriangleCut);

    // 根据元素类型进行判断
    switch (element.type) {
      case DrawingElementType.text:
        if (element.points.isNotEmpty) {
          final textPosition = Offset(
            element.points[0].dx * size.width,
            element.points[0].dy * size.height,
          );
          return _isPointInFinalEraserShape(
            textPosition,
            eraserRect,
            eraserCurvature,
            eraserTriangleCut,
          );
        }
        return false;

      case DrawingElementType.freeDrawing:
        for (final pointModel in element.points) {
          // 假设 element.points 是 Offset 列表
          final screenPoint = Offset(
            pointModel.dx * size.width,
            pointModel.dy * size.height,
          );
          if (_isPointInFinalEraserShape(
            screenPoint,
            eraserRect,
            eraserCurvature,
            eraserTriangleCut,
          )) {
            return true;
          }
        }
        return false;

      default: // 其他被视为矩形的元素类型
        if (element.points.length < 2) return false;
        final elementStart = Offset(
          element.points[0].dx * size.width,
          element.points[0].dy * size.height,
        );
        final elementEnd = Offset(
          element.points[1].dx * size.width,
          element.points[1].dy * size.height,
        );
        final Rect elementRect = Rect.fromPoints(elementStart, elementEnd);

        // // 如果橡皮擦是完整的基础矩形（无曲率也无切割），则使用最简单的矩形重叠判断
        // if (eraserCurvature <= 0.0) {

        // }

        // // 否则，使用更新后的、能处理复杂橡皮擦形状的重叠判断函数
        // return _isRectOverlappingEraserShape(
        //   elementRect,
        //   eraserRect,
        //   eraserCurvature,
        // );
        return eraserRect.overlaps(elementRect);
    }
  }

  /// 检查点是否在橡皮擦形状内（可以是矩形、超椭圆或标准椭圆）
  /// Checks if a point is inside the eraser shape (can be a rectangle, superellipse, or standard ellipse)
  bool _isPointInEraserShape(Offset point, Rect eraserRect, double curvature) {
    // 1. 处理曲率为0或负数的情况（矩形）
    // 1. Handle curvature <= 0.0 (rectangle)
    if (curvature <= 0.0) {
      return eraserRect.contains(point);
    }

    // 2. 限制弧度值在合理范围内 (0.0 到 1.0)
    // 2. Clamp curvature value to a reasonable range (0.0 to 1.0)
    final clampedCurvature = curvature.clamp(0.0, 1.0);

    // 如果限制后的曲率仍然是0或以下，则按矩形处理
    // If clamped curvature is still 0 or less, treat as a rectangle
    if (clampedCurvature <= 0.0) {
      return eraserRect.contains(point);
    }

    final center = eraserRect.center;
    final a = eraserRect.width / 2; // 半宽 (Half-width)
    final b = eraserRect.height / 2; // 半高 (Half-height)

    // 如果半宽或半高为0或负数，则点不可能在形状内 (除非点恰好是中心且a,b都为0)
    // If half-width or half-height is zero or negative, the point cannot be inside
    // (unless the point is the center and a, b are both 0, which is a degenerate case)
    if (a <= 0 || b <= 0) {
      // For a point to be contained, width and height must be positive.
      // If a or b is zero, it's a line or a point.
      // A point is contained in a zero-area rect if it's exactly that point.
      // However, for shapes like ellipses/superellipses, non-positive a or b means no area.
      return false;
    }

    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;

    // 3. 根据 clampedCurvature 确定 n 值和是否使用标准椭圆
    // 3. Determine n value and whether to use standard ellipse based on clampedCurvature
    double n;
    bool useStandardEllipse = false;

    if (clampedCurvature <= 0.3) {
      // 圆角矩形阶段 (超椭圆)
      // Rounded rectangle stage (superellipse)
      final t = clampedCurvature / 0.3;
      n = 8.0 - (t * 4.0); // n 从 8.0 变化到 4.0 (n varies from 8.0 to 4.0)
    } else if (clampedCurvature <= 0.7) {
      // 过渡阶段 (超椭圆)
      // Transition stage (superellipse)
      final t = (clampedCurvature - 0.3) / 0.4;
      n = 4.0 - (t * 1.8); // n 从 4.0 变化到 2.2 (n varies from 4.0 to 2.2)
    } else {
      // 标准椭圆阶段
      // Standard ellipse stage
      useStandardEllipse = true;
      n = 2.0; // For standard ellipse, the exponent in the general form is 2
    }

    // 4. 点在形状内的判断
    // 4. Point-in-shape test
    if (useStandardEllipse || n == 2.0) {
      // n=2.0 is the standard ellipse case
      // 标准椭圆方程: (x/a)² + (y/b)² <= 1
      // Standard ellipse equation: (x/a)² + (y/b)² <= 1
      // (dx * dx) / (a * a) can cause issues if a is very small.
      // (dx/a) * (dx/a) is numerically more stable.
      final termX = (dx / a);
      final termY = (dy / b);
      return (termX * termX) + (termY * termY) <= 1.0;
    } else {
      // 超椭圆方程: (|x/a|)^n + (|y/b|)^n <= 1
      // Superellipse equation: (|dx/a|)^n + (|dy/b|)^n <= 1
      // Ensure a and b are not zero to prevent division by zero.
      // This was already checked by (a <= 0 || b <= 0)

      final termX = (dx.abs() / a);
      final termY = (dy.abs() / b);

      // math.pow can be computationally intensive.
      // Also, math.pow(negative, non-integer) can result in NaN.
      // Since we use .abs(), the base for pow will be non-negative.
      return math.pow(termX, n) + math.pow(termY, n) <= 1.0;
    }
  }

  bool _isPointInFinalEraserShape(
    Offset point,
    Rect eraserRect,
    double curvature,
    TriangleCutType triangleCut,
  ) {
    // 1. 首先检查点是否在由 curvature 定义的基础形状内
    if (!_isPointInEraserShape(point, eraserRect, curvature)) {
      return false; // 如果不在基础形状内，则肯定不在最终切割后的形状内
    }

    // 2. 如果没有对角线切割，则点在基础形状内即为在最终形状内
    if (triangleCut == TriangleCutType.none) {
      return true;
    }

    // 3. 如果有对角线切割，则还需要检查点是否在 _createTrianglePath 定义的三角形区域内
    // _createTrianglePath 返回的是要“保留”的三角形区域
    Path triangleAreaPath = _createTrianglePath(eraserRect, triangleCut);
    return triangleAreaPath.contains(point); // 使用 Path.contains() 判断
  }

  /// 检查矩形是否与橡皮擦形状重叠
  /// 检查矩形是否与橡皮擦形状重叠
  // bool _isRectOverlappingEraserShape(
  //   Rect elementRect,
  //   Rect eraserRect,
  //   double curvature,
  // ) {
  //   // 检查矩形的角点和中点是否有任何一个在椭圆内  <--- 注意这里的注释
  //   final testPoints = [
  //     elementRect.topLeft,
  //     elementRect.topRight,
  //     elementRect.bottomLeft,
  //     elementRect.bottomRight,
  //     elementRect.center,
  //     Offset(elementRect.center.dx, elementRect.top), // 上中
  //     Offset(elementRect.center.dx, elementRect.bottom), // 下中
  //     Offset(elementRect.left, elementRect.center.dy), // 左中
  //     Offset(elementRect.right, elementRect.center.dy), // 右中
  //   ];

  //   for (final point in testPoints) {
  //     // 关键调用：这里使用了 _isPointInEraserShape
  //     if (_isPointInEraserShape(point, eraserRect, curvature)) {
  //       return true;
  //     }
  //   }

  //     // 如果没有点在椭圆内，还需要检查椭圆是否完全在矩形内 <--- 注意这里的注释
  //   // 这个检查的是 eraserRect (橡皮擦的包围盒) 是否在 elementRect 内部
  //   if (eraserRect.left >= elementRect.left &&
  //       eraserRect.right <= elementRect.right &&
  //       eraserRect.top >= elementRect.top &&
  //       eraserRect.bottom <= elementRect.bottom) {
  //     return true;
  //   }

  //   return false;
  // }

  void _drawElement(Canvas canvas, MapDrawingElement element, Size size) {
    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..style = PaintingStyle.stroke;

    // Convert normalized coordinates to screen coordinates
    final points = element.points
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();

    // 特殊处理：文本元素只需要一个点，自由绘制可能有多个点
    if (element.type == DrawingElementType.text) {
      if (points.isEmpty) return;
      _drawText(canvas, element, size);
      return;
    }

    if (element.type == DrawingElementType.freeDrawing) {
      if (points.isEmpty) return;
      _drawFreeDrawingPath(canvas, element, paint, size);
      return;
    }

    // 其他绘制类型需要至少两个点
    if (points.length < 2) return;

    final start = points[0];
    final end = points[1];
    final rect = Rect.fromPoints(start, end); // 检查是否需要应用三角形切割
    final needsTriangleClip =
        element.triangleCut != TriangleCutType.none &&
        _isTriangleCutApplicable(element.type);

    if (needsTriangleClip) {
      // 保存画布状态并应用三角形裁剪
      canvas.save();
      final trianglePath = _createTrianglePath(rect, element.triangleCut);
      canvas.clipPath(trianglePath);
    }

    switch (element.type) {
      case DrawingElementType.line:
        canvas.drawLine(start, end, paint);
        break;
      case DrawingElementType.dashedLine:
        _drawDashedLine(canvas, start, end, paint, element.density);
        break;

      case DrawingElementType.imageArea:
        _drawImageArea(canvas, element, size);
        break;

      case DrawingElementType.arrow:
        _drawArrow(canvas, start, end, paint);
        break;
      case DrawingElementType.rectangle:
        paint.style = PaintingStyle.fill;
        if (element.curvature > 0.0) {
          _drawCurvedRectangle(canvas, rect, paint, element.curvature);
        } else {
          canvas.drawRect(rect, paint);
        }
        break;

      case DrawingElementType.hollowRectangle:
        paint.style = PaintingStyle.stroke;
        if (element.curvature > 0.0) {
          _drawCurvedRectangle(canvas, rect, paint, element.curvature);
        } else {
          canvas.drawRect(rect, paint);
        }
        break;
      case DrawingElementType.diagonalLines:
        if (element.curvature > 0.0) {
          _drawCurvedDiagonalPattern(
            canvas,
            rect,
            paint,
            element.density,
            element.curvature,
          );
        } else {
          _drawDiagonalPattern(canvas, start, end, paint, element.density);
        }
        break;

      case DrawingElementType.crossLines:
        if (element.curvature > 0.0) {
          _drawCurvedCrossPattern(
            canvas,
            rect,
            paint,
            element.density,
            element.curvature,
          );
        } else {
          _drawCrossPattern(canvas, start, end, paint, element.density);
        }
        break;

      case DrawingElementType.dotGrid:
        if (element.curvature > 0.0) {
          _drawCurvedDotGrid(
            canvas,
            rect,
            paint,
            element.density,
            element.curvature,
          );
        } else {
          _drawDotGrid(canvas, start, end, paint, element.density);
        }
        break;

      case DrawingElementType.freeDrawing:
        // 已在上面处理
        break;

      case DrawingElementType.text:
        // 已在上面处理
        break;

      case DrawingElementType.eraser:
        // 橡皮擦不需要绘制，它只是删除元素
        break;
    }

    if (needsTriangleClip) {
      // 恢复画布状态
      canvas.restore();
    }
  }

  void _drawImageArea(Canvas canvas, MapDrawingElement element, Size size) {
    if (element.points.length < 2) return;

    final start = Offset(
      element.points[0].dx * size.width,
      element.points[0].dy * size.height,
    );
    final end = Offset(
      element.points[1].dx * size.width,
      element.points[1].dy * size.height,
    );
    final rect = Rect.fromPoints(start, end);

    // 检查是否需要应用裁剪
    final needsTriangleClip = element.triangleCut != TriangleCutType.none;
    final needsCurvatureClip = element.curvature > 0.0;

    if (needsTriangleClip || needsCurvatureClip) {
      canvas.save();

      if (needsCurvatureClip && needsTriangleClip) {
        final Path finalPath = _getFinalEraserPath(
          rect,
          element.curvature,
          element.triangleCut,
        );
        canvas.clipPath(finalPath);
      } else if (needsCurvatureClip) {
        final Path curvedPath = _createSuperellipsePath(
          rect,
          element.curvature,
        );
        canvas.clipPath(curvedPath);
      } else if (needsTriangleClip) {
        final Path trianglePath = _createTrianglePath(
          rect,
          element.triangleCut,
        );
        canvas.clipPath(trianglePath);
      }
    }

    // 绘制图片内容
    if (element.imageData != null) {
      // 1. 优先使用元素自己的图片数据
      final cachedImage = imageCache[element.id];
      if (cachedImage != null) {
        _drawCachedImage(
          canvas,
          cachedImage,
          rect,
          element.imageFit ?? BoxFit.contain,
        );
      } else {
        // 图片还在解码中，显示加载占位符
        _drawImageLoadingPlaceholder(
          canvas,
          rect,
          element.imageFit ?? BoxFit.contain,
        );
      }
    } else if (currentImageBufferData != null) {
      // 2. 如果元素没有图片数据，但图片缓冲区有数据，使用缓冲区的图片
      if (imageBufferCachedImage != null) {
        _drawCachedImage(canvas, imageBufferCachedImage!, rect, imageBufferFit);
      } else {
        // 缓冲区图片还在解码中
        _drawImageBufferLoadingPlaceholder(canvas, rect);
      }
    } else {
      // 3. 没有任何图片数据，显示空白占位符
      _drawImageEmptyPlaceholder(
        canvas,
        rect,
        element.imageFit ?? BoxFit.contain,
      );
    }

    if (needsTriangleClip || needsCurvatureClip) {
      canvas.restore();
    }
  }

  /// 绘制缓存的图片
  void _drawCachedImage(Canvas canvas, ui.Image image, Rect rect, BoxFit fit) {
    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final FittedSizes fittedSizes = applyBoxFit(fit, imageSize, rect.size);

    final Size destinationSize = fittedSizes.destination;
    final Size sourceSize = fittedSizes.source;

    // 计算居中位置
    final Rect destinationRect = Rect.fromLTWH(
      rect.left + (rect.width - destinationSize.width) / 2,
      rect.top + (rect.height - destinationSize.height) / 2,
      destinationSize.width,
      destinationSize.height,
    );

    // 计算源矩形
    final Rect sourceRect = Rect.fromLTWH(
      (imageSize.width - sourceSize.width) / 2,
      (imageSize.height - sourceSize.height) / 2,
      sourceSize.width,
      sourceSize.height,
    );

    // 绘制图片
    canvas.drawImageRect(image, sourceRect, destinationRect, Paint());
  }

  /// 绘制图片缓冲区加载占位符
  void _drawImageBufferLoadingPlaceholder(Canvas canvas, Rect rect) {
    // 半透明背景
    final backgroundPaint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, backgroundPaint);

    // 边框
    final borderPaint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(rect, borderPaint);

    // 加载图标
    final iconSize = math.min(rect.width, rect.height) * 0.2;
    final center = rect.center;

    final iconPaint = Paint()
      ..color = Colors.green.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // 简单的加载图标 (圆形)
    canvas.drawCircle(center, iconSize / 2, iconPaint);

    // 绘制提示文本
    final textPainter = TextPainter(
      text: TextSpan(
        text: '缓冲区图片解码中...',
        style: TextStyle(
          color: Colors.green.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2, rect.center.dy + iconSize),
    );
  }

  /// 绘制图片加载状态的占位符
  void _drawImageLoadingPlaceholder(
    Canvas canvas,
    Rect rect,
    BoxFit fit, // 修正：这里应该是 BoxFit，不是 Uint8List
  ) {
    // 半透明背景
    final backgroundPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, backgroundPaint);

    // 边框
    final borderPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(rect, borderPaint);

    // 加载图标
    final iconSize = math.min(rect.width, rect.height) * 0.2;
    final center = rect.center;

    final iconPaint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // 简单的加载图标 (圆形)
    canvas.drawCircle(center, iconSize / 2, iconPaint);

    // 绘制提示文本
    final textPainter = TextPainter(
      text: TextSpan(
        text: '图片解码中...',
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2, rect.center.dy + iconSize),
    );

    // 绘制图片适应方式提示
    final fitText = _getBoxFitDisplayName(fit);
    final fitTextPainter = TextPainter(
      text: TextSpan(
        text: '适应: $fitText',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    );
    fitTextPainter.layout();
    fitTextPainter.paint(
      canvas,
      Offset(
        rect.center.dx - fitTextPainter.width / 2,
        rect.center.dy + iconSize + textPainter.height + 2,
      ),
    );
  }

  /// 绘制空白图片占位符
  void _drawImageEmptyPlaceholder(Canvas canvas, Rect rect, BoxFit fit) {
    // 虚线边框
    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 绘制虚线矩形
    _drawDashedRect(canvas, rect, borderPaint, 5.0);

    // 图片图标
    final iconSize = math.min(rect.width, rect.height) * 0.2;
    final center = rect.center;

    final iconPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 简单的图片图标 (矩形加山峰)
    final iconRect = Rect.fromCenter(
      center: center,
      width: iconSize,
      height: iconSize * 0.8,
    );
    canvas.drawRect(iconRect, iconPaint);

    // 画一个简单的山峰图标
    final mountainPath = Path();
    mountainPath.moveTo(
      iconRect.left + iconRect.width * 0.2,
      iconRect.bottom - iconRect.height * 0.3,
    );
    mountainPath.lineTo(
      iconRect.left + iconRect.width * 0.5,
      iconRect.top + iconRect.height * 0.2,
    );
    mountainPath.lineTo(
      iconRect.left + iconRect.width * 0.8,
      iconRect.bottom - iconRect.height * 0.3,
    );
    canvas.drawPath(mountainPath, iconPaint);

    // 绘制提示文本
    final textPainter = TextPainter(
      text: TextSpan(
        text: '点击上传图片',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2, rect.center.dy + iconSize),
    );
  }

  /// 绘制虚线矩形
  void _drawDashedRect(
    Canvas canvas,
    Rect rect,
    Paint paint,
    double dashWidth,
  ) {
    final Path path = Path();

    // 顶边
    double currentX = rect.left;
    bool draw = true;
    while (currentX < rect.right) {
      final nextX = math.min(currentX + dashWidth, rect.right);
      if (draw) {
        path.moveTo(currentX, rect.top);
        path.lineTo(nextX, rect.top);
      }
      currentX = nextX;
      draw = !draw;
    }

    // 右边
    double currentY = rect.top;
    draw = true;
    while (currentY < rect.bottom) {
      final nextY = math.min(currentY + dashWidth, rect.bottom);
      if (draw) {
        path.moveTo(rect.right, currentY);
        path.lineTo(rect.right, nextY);
      }
      currentY = nextY;
      draw = !draw;
    }

    // 底边
    currentX = rect.right;
    draw = true;
    while (currentX > rect.left) {
      final nextX = math.max(currentX - dashWidth, rect.left);
      if (draw) {
        path.moveTo(currentX, rect.bottom);
        path.lineTo(nextX, rect.bottom);
      }
      currentX = nextX;
      draw = !draw;
    }

    // 左边
    currentY = rect.bottom;
    draw = true;
    while (currentY > rect.top) {
      final nextY = math.max(currentY - dashWidth, rect.top);
      if (draw) {
        path.moveTo(rect.left, currentY);
        path.lineTo(rect.left, nextY);
      }
      currentY = nextY;
      draw = !draw;
    }

    canvas.drawPath(path, paint);
  }

  String _getBoxFitDisplayName(BoxFit boxFit) {
    switch (boxFit) {
      case BoxFit.fill:
        return '填充';
      case BoxFit.contain:
        return '包含';
      case BoxFit.cover:
        return '覆盖';
      case BoxFit.fitWidth:
        return '适宽';
      case BoxFit.fitHeight:
        return '适高';
      case BoxFit.none:
        return '原始';
      case BoxFit.scaleDown:
        return '缩小';
    }
  }

  /// 检查绘制元素类型是否支持三角形切割
  bool _isTriangleCutApplicable(DrawingElementType type) {
    switch (type) {
      case DrawingElementType.rectangle:
      case DrawingElementType.hollowRectangle:
      case DrawingElementType.diagonalLines:
      case DrawingElementType.crossLines:
      case DrawingElementType.dotGrid:
      case DrawingElementType.eraser:
        return true;
      default:
        return false;
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double density,
  ) {
    final dashWidth = paint.strokeWidth * density * 0.8; // 虚线长度基于密度
    final dashSpace = paint.strokeWidth * density * 0.4; // 间隔基于密度

    final distance = (end - start).distance;
    if (distance == 0) return;

    final direction = (end - start) / distance;

    double currentDistance = 0;
    bool isDash = true;

    while (currentDistance < distance) {
      final segmentLength = isDash ? dashWidth : dashSpace;
      final segmentEnd = currentDistance + segmentLength > distance
          ? distance
          : currentDistance + segmentLength;

      if (isDash) {
        final segmentStart = start + direction * currentDistance;
        final segmentEndPoint = start + direction * segmentEnd;
        canvas.drawLine(segmentStart, segmentEndPoint, paint);
      }

      currentDistance = segmentEnd;
      isDash = !isDash;
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    // Draw main line
    canvas.drawLine(start, end, paint);

    // Draw arrowhead
    const arrowLength = 10.0;
    const arrowAngle = 0.5;

    final direction = (end - start).direction;
    final arrowPoint1 =
        end +
        Offset(
          arrowLength * -1 * math.cos(direction - arrowAngle),
          arrowLength * -1 * math.sin(direction - arrowAngle),
        );
    final arrowPoint2 =
        end +
        Offset(
          arrowLength * -1 * math.cos(direction + arrowAngle),
          arrowLength * -1 * math.sin(direction + arrowAngle),
        );

    canvas.drawLine(end, arrowPoint1, paint);
    canvas.drawLine(end, arrowPoint2, paint);
  }

  void _drawDiagonalPattern(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double density,
  ) {
    final rect = Rect.fromPoints(start, end);
    final spacing = paint.strokeWidth * density;

    final width = rect.width;
    final height = rect.height;

    // 计算需要的线条数量：覆盖从左上到右下的所有45度平行线
    final int totalLines = ((width + height) / spacing).ceil();

    for (int i = 0; i < totalLines; i++) {
      final double offset = i * spacing;

      Offset lineStart;
      Offset lineEnd;

      if (offset <= width) {
        // 起点在顶边界上（从左上角往右推进）
        lineStart = Offset(rect.left + offset, rect.top);
      } else {
        // 起点在右边界上（从右上角往下推进）
        lineStart = Offset(rect.right, rect.top + (offset - width));
      }

      if (offset <= height) {
        // 终点在左边界上（从左上角往下推进）
        lineEnd = Offset(rect.left, rect.top + offset);
      } else {
        // 终点在底边界上（从左下角往右推进）
        lineEnd = Offset(rect.left + (offset - height), rect.bottom);
      }

      canvas.drawLine(lineStart, lineEnd, paint);
    }
  }

  void _drawCrossPattern(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double density,
  ) {
    final rect = Rect.fromPoints(start, end);
    final spacing = paint.strokeWidth * density;

    // Vertical lines
    for (double x = rect.left; x <= rect.right; x += spacing) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }

    // Horizontal lines
    for (double y = rect.top; y <= rect.bottom; y += spacing) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
  }

  void _drawDotGrid(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double density,
  ) {
    final rect = Rect.fromPoints(start, end);
    final spacing = paint.strokeWidth * density;
    final dotRadius = paint.strokeWidth * 0.5; // 点的半径基于线宽

    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    for (double x = rect.left; x <= rect.right; x += spacing) {
      for (double y = rect.top; y <= rect.bottom; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  void _drawFreeDrawingPath(
    Canvas canvas,
    MapDrawingElement element,
    Paint paint,
    Size size,
  ) {
    if (element.points.length < 2) return;

    final path = Path();
    final screenPoints = element.points
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();

    path.moveTo(screenPoints[0].dx, screenPoints[0].dy);
    for (int i = 1; i < screenPoints.length; i++) {
      path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }

    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, MapDrawingElement element, Size size) {
    if (element.text == null || element.text!.isEmpty || element.points.isEmpty)
      return;

    final position = Offset(
      element.points[0].dx * size.width,
      element.points[0].dy * size.height,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: element.text!,
        style: TextStyle(
          color: element.color,
          fontSize: element.fontSize ?? 16.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  /// 绘制弧度对角线图案
  void _drawCurvedDiagonalPattern(
    Canvas canvas,
    Rect rect,
    Paint paint,
    double density,
    double curvature,
  ) {
    // 创建超椭圆路径作为裁剪区域
    final clipPath = _createSuperellipsePath(rect, curvature);

    // 保存画布状态
    canvas.save();
    canvas.clipPath(clipPath);

    // 在裁剪区域内绘制对角线图案
    final spacing = paint.strokeWidth * density;
    final width = rect.width;
    final height = rect.height;

    final int totalLines = ((width + height) / spacing).ceil();

    for (int i = 0; i < totalLines; i++) {
      final double offset = i * spacing;

      Offset lineStart;
      Offset lineEnd;

      if (offset <= width) {
        lineStart = Offset(rect.left + offset, rect.top);
      } else {
        lineStart = Offset(rect.right, rect.top + (offset - width));
      }

      if (offset <= height) {
        lineEnd = Offset(rect.left, rect.top + offset);
      } else {
        lineEnd = Offset(rect.left + (offset - height), rect.bottom);
      }

      canvas.drawLine(lineStart, lineEnd, paint);
    }

    // 恢复画布状态
    canvas.restore();
  }

  /// 绘制弧度十字线图案
  void _drawCurvedCrossPattern(
    Canvas canvas,
    Rect rect,
    Paint paint,
    double density,
    double curvature,
  ) {
    // 创建超椭圆路径作为裁剪区域
    final clipPath = _createSuperellipsePath(rect, curvature);

    // 保存画布状态
    canvas.save();
    canvas.clipPath(clipPath);

    // 在裁剪区域内绘制十字线图案
    final spacing = paint.strokeWidth * density;

    // 垂直线
    for (double x = rect.left; x <= rect.right; x += spacing) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }

    // 水平线
    for (double y = rect.top; y <= rect.bottom; y += spacing) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }

    // 恢复画布状态
    canvas.restore();
  }

  /// 绘制弧度点网格图案
  void _drawCurvedDotGrid(
    Canvas canvas,
    Rect rect,
    Paint paint,
    double density,
    double curvature,
  ) {
    // 创建超椭圆路径作为裁剪区域
    final clipPath = _createSuperellipsePath(rect, curvature);

    // 保存画布状态
    canvas.save();
    canvas.clipPath(clipPath);

    // 在裁剪区域内绘制点网格
    final spacing = paint.strokeWidth * density;
    final dotRadius = paint.strokeWidth * 0.5;

    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    for (double x = rect.left; x <= rect.right; x += spacing) {
      for (double y = rect.top; y <= rect.bottom; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }

    // 恢复画布状态
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CurrentDrawingPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final DrawingElementType elementType;
  final Color color;
  final double strokeWidth;
  final double density;
  final double curvature; // 曲率参数
  final TriangleCutType triangleCut; // 三角形切割类型
  final List<Offset>? freeDrawingPath; // 自由绘制路径
  final String? selectedElementId; // 当前选中的元素ID

  _CurrentDrawingPainter({
    required this.start,
    required this.end,
    required this.elementType,
    required this.color,
    required this.strokeWidth,
    required this.density,
    required this.curvature,
    required this.triangleCut,
    this.freeDrawingPath,
    this.selectedElementId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 橡皮擦特殊预览
    if (elementType == DrawingElementType.eraser) {
      final rect = Rect.fromPoints(start, end);
      final paint = Paint()
        ..color = Colors.red.withAlpha((0.3 * 255).toInt())
        ..style = PaintingStyle.fill;

      switch ((curvature > 0.0, triangleCut != TriangleCutType.none)) {
        case (true, true):
          _drawCurvedTrianglePath(canvas, rect, paint, curvature, triangleCut);
          break;
        case (true, false):
          _drawCurvedRectangle(canvas, rect, paint, curvature);
          break;
        case (false, true):
          _drawCurvedTrianglePath(canvas, rect, paint, curvature, triangleCut);
          break;
        case (false, false):
          canvas.drawRect(rect, paint);
          break;
      }

      // 绘制边框
      final borderPaint = Paint()
        ..color = Colors.red.withAlpha((0.8 * 255).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      switch ((curvature > 0.0, triangleCut != TriangleCutType.none)) {
        case (true, true):
          _drawCurvedTrianglePath(
            canvas,
            rect,
            borderPaint,
            curvature,
            triangleCut,
          );
          break;
        case (true, false):
          _drawCurvedRectangle(canvas, rect, borderPaint, curvature);
          break;
        case (false, true):
          _drawCurvedTrianglePath(
            canvas,
            rect,
            borderPaint,
            curvature,
            triangleCut,
          );
          break;
        case (false, false):
          canvas.drawRect(rect, borderPaint);
          break;
      }
      return;
    }

    // 自由绘制特殊预览
    if (elementType == DrawingElementType.freeDrawing &&
        freeDrawingPath != null &&
        freeDrawingPath!.isNotEmpty) {
      final paint = Paint()
        ..color = color.withAlpha((0.7 * 255).toInt())
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(freeDrawingPath![0].dx, freeDrawingPath![0].dy);
      for (int i = 1; i < freeDrawingPath!.length; i++) {
        path.lineTo(freeDrawingPath![i].dx, freeDrawingPath![i].dy);
      }
      canvas.drawPath(path, paint);
      return;
    }

    // 文本工具特殊预览 - 显示一个小方块指示放置位置
    if (elementType == DrawingElementType.text) {
      final paint = Paint()
        ..color = color.withAlpha((0.7 * 255).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // 在文本位置绘制一个小方块作为预览
      final rect = Rect.fromCenter(center: start, width: 20, height: 20);
      canvas.drawRect(rect, paint);
      // 绘制文本预览提示
      final textPainter = TextPainter(
        text: TextSpan(
          text: "点击添加文本",
          style: TextStyle(
            color: color.withAlpha((0.7 * 255).toInt()),
            fontSize: 12.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          start.dx - textPainter.width / 2,
          start.dy - textPainter.height / 2,
        ),
      );
      return;
    }

    // 使用固定的画布尺寸来确保坐标转换的一致性
    List<Offset> points;
    if (elementType == DrawingElementType.freeDrawing &&
        freeDrawingPath != null) {
      // 对于自由绘制，使用路径点
      points = freeDrawingPath!
          .map(
            (point) =>
                Offset(point.dx / kCanvasWidth, point.dy / kCanvasHeight),
          )
          .toList();
    } else {
      // 对于其他绘制类型，使用开始和结束点
      points = [
        Offset(start.dx / kCanvasWidth, start.dy / kCanvasHeight),
        Offset(end.dx / kCanvasWidth, end.dy / kCanvasHeight),
      ];
    }
    final element = MapDrawingElement(
      id: 'preview',
      type: elementType,
      points: points,
      color: color.withAlpha((0.7 * 255).toInt()),
      strokeWidth: strokeWidth,
      density: density,
      curvature: curvature, // 使用实际的曲率值进行预览
      triangleCut: triangleCut, // 使用实际的三角形切割值进行预览
      createdAt: DateTime.now(),
    );
    final layerPainter = _LayerPainter(
      layer: MapLayer(
        id: 'preview',
        name: 'Preview',
        elements: [element],
        isVisible: true,
        opacity: 0.7,
        order: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      isEditMode: true,
      selectedElementId: selectedElementId,
      imageCache: const {}, // 添加必需的 imageCache 参数，预览时使用空缓存
    );
    layerPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 背景图案画笔，支持多种背景模式
class _BackgroundPatternPainter extends CustomPainter {
  final BackgroundPattern pattern;

  _BackgroundPatternPainter(this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    switch (pattern) {
      case BackgroundPattern.blank:
        // 空白背景，不绘制任何图案
        break;
      case BackgroundPattern.grid:
        _drawGrid(canvas, size);
        break;
      case BackgroundPattern.checkerboard:
        _drawCheckerboard(canvas, size);
        break;
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    const double gridSize = 20.0;
    final Paint gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 绘制垂直线
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 绘制水平线
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawCheckerboard(Canvas canvas, Size size) {
    const double squareSize = 20.0;
    final Paint lightPaint = Paint()..color = Colors.grey.shade100;
    final Paint darkPaint = Paint()..color = Colors.grey.shade200;

    for (double x = 0; x < size.width; x += squareSize) {
      for (double y = 0; y < size.height; y += squareSize) {
        final isEvenRow = (y / squareSize).floor() % 2 == 0;
        final isEvenCol = (x / squareSize).floor() % 2 == 0;
        final isLightSquare =
            (isEvenRow && isEvenCol) || (!isEvenRow && !isEvenCol);

        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isLightSquare ? lightPaint : darkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern;
  }
}
