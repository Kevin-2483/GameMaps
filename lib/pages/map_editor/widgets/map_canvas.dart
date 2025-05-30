import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../models/map_layer.dart';
import '../../../models/map_item.dart';
import '../../../models/user_preferences.dart';
import '../../../models/legend_item.dart' as legend_db;

// 画布固定尺寸常量，确保坐标转换的一致性
const double kCanvasWidth = 1600.0;
const double kCanvasHeight = 1600.0;

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

// --- 核心的路径生成函数 (之前已经创建) ---
/// 根据给定的矩形和曲率创建橡皮擦的形状路径。
///
/// [rect]: 橡皮擦的基础矩形边界。
/// [curvature]: 橡皮擦的曲率 (0.0 为矩形, 0.0-1.0 之间为超椭圆到椭圆的过渡)。
Path _createEraserShapePath(Rect rect, double curvature) {
  final path = Path();
  // 限制曲率在0.0到1.0之间
  final clampedCurvature = curvature.clamp(0.0, 1.0);

  // 如果曲率是0或负数，或者矩形太小，则为矩形
  if (clampedCurvature <= 0.0 || rect.width < 1 || rect.height < 1) {
    path.addRect(rect);
    return path;
  }

  final centerX = rect.center.dx;
  final centerY = rect.center.dy;
  final a = rect.width / 2; // 半宽
  final b = rect.height / 2; // 半高

  // 如果半宽或半高小于等于0，则无法形成有效形状，也按矩形处理（或返回空路径）
  // 这里我们确保a, b是正数，因为后续计算需要
  if (a <= 0 || b <= 0) {
    path.addRect(rect); // 或者可以考虑返回一个空的 path
    return path;
  }

  double n; // 超椭圆的指数
  bool useStandardEllipse = false;

  // 根据曲率确定超椭圆指数 n 或是否使用标准椭圆
  if (clampedCurvature <= 0.3) {
    final t = clampedCurvature / 0.3;
    n = 8.0 - (t * 4.0);
  } else if (clampedCurvature <= 0.7) {
    final t = (clampedCurvature - 0.3) / 0.4;
    n = 4.0 - (t * 1.8);
  } else {
    useStandardEllipse = true;
    n = 2.0;
  }

  if (useStandardEllipse || (n - 2.0).abs() < 0.001) {
    path.addOval(rect);
  } else {
    const int numPoints = 100;
    bool isFirstPoint = true;

    for (int i = 0; i <= numPoints; i++) {
      final angleT = (i / numPoints) * 2 * math.pi;
      final cosT = math.cos(angleT);
      final sinT = math.sin(angleT);

      double x, y;
      final signCos = cosT.sign;
      final signSin = sinT.sign;

      // 确保基数非负数，因为 n 可能不是整数
      // math.pow(negative, non-integer) -> NaN
      // math.pow(0, non-positive_exponent) -> Infinity or NaN
      // 我们使用 abs() 来避免负基数
      final absCosT = cosT.abs();
      final absSinT = sinT.abs();

      // 防止对0取非正指数的幂，或者2.0/n为负数的情况
      // 如果 absCosT 或 absSinT 为0，且 2.0/n 为负，则会出错
      // 在这种情况下，超椭圆的坐标应该在轴上
      if (absCosT < 1e-9 && (2.0 / n) < 0) {
        // cosT 约等于 0
        x = centerX; // 点在y轴上
      } else {
        x = centerX + a * signCos * math.pow(absCosT, 2.0 / n);
      }

      if (absSinT < 1e-9 && (2.0 / n) < 0) {
        // sinT 约等于 0
        y = centerY; // 点在x轴上
      } else {
        y = centerY + b * signSin * math.pow(absSinT, 2.0 / n);
      }

      if (isFirstPoint) {
        path.moveTo(x, y);
        isFirstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
  }
  return path;
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

Path _getFinalEraserPath(
  Rect rect,
  double curvature,
  TriangleCutType triangleCut,
) {
  Path curvedPath = _createEraserShapePath(rect, curvature); // 这是你处理曲率生成路径的函数

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
  final Path path = _createEraserShapePath(rect, curvature);

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
  final double selectedCurvature; // 弧度值
  final List<legend_db.LegendItem> availableLegends;
  final bool isPreviewMode;
  final Function(MapLayer) onLayerUpdated;
  final Function(LegendGroup) onLegendGroupUpdated;
  final Function(String)? onLegendItemSelected; // 图例项选中回调
  final Function(LegendItem)? onLegendItemDoubleClicked; // 图例项双击回调
  final Map<String, double> previewOpacityValues; // 绘制工具预览状态
  final DrawingElementType? previewDrawingTool;
  final Color? previewColor;
  final double? previewStrokeWidth;
  final double? previewDensity;
  final double? previewCurvature; // 弧度预览状态
  final TriangleCutType? previewTriangleCut; // 三角形切割预览状态

  // 选中元素高亮
  final String? selectedElementId;
  // 背景图案设置
  final BackgroundPattern backgroundPattern;

  // 缩放敏感度
  final double zoomSensitivity;

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
    this.onLegendItemSelected,
    this.onLegendItemDoubleClicked,
    this.previewOpacityValues = const {},
    this.previewDrawingTool,
    this.previewColor,
    this.previewStrokeWidth,
    this.previewDensity,
    this.previewCurvature,
    this.previewTriangleCut,
    this.selectedElementId,
    this.backgroundPattern = BackgroundPattern.checkerboard,
    this.zoomSensitivity = 1.0,
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

  // 自由绘制路径支持
  List<Offset> _freeDrawingPath = [];

  // 绘制预览的 ValueNotifier，避免整个 widget 重绘
  final ValueNotifier<DrawingPreviewData?> _drawingPreviewNotifier =
      ValueNotifier(null); // 获取有效的绘制工具状态（预览值或实际值）
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
          scaleFactor: 200.0 / widget.zoomSensitivity, // 应用缩放敏感度（除法确保高数值=高敏感度）
          constrained: false, // 关键：不约束子组件大小
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
                          if (previewData == null)
                            return const SizedBox.shrink();
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
              ],
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

    return Positioned.fill(
      child: Opacity(
        opacity: layer.isVisible ? effectiveOpacity : 0.0,
        child: CustomPaint(
          size: const Size(kCanvasWidth, kCanvasHeight),
          painter: _LayerPainter(
            layer: layer,
            isEditMode: !widget.isPreviewMode,
            selectedElementId: widget.selectedElementId,
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
    // 选中图例项，高亮显示
    widget.onLegendItemSelected?.call(item.id);
  }

  void _onLegendDoubleTap(LegendItem item) {
    // 双击图例项，触发双击回调
    widget.onLegendItemDoubleClicked?.call(item);
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
    // 计算橡皮擦的 z 值（比当前最大 z 值大 1）
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

    // 收集所有图层及其元素
    for (final layer in widget.mapItem.layers) {
      if (!layer.isVisible) continue;

      final isSelectedLayer = widget.selectedLayer?.id == layer.id;

      // 添加图层图片（如果有）
      if (layer.imageData != null) {
        allElements.add(
          _LayeredElement(
            order: layer.order,
            isSelected: isSelectedLayer,
            widget: _buildLayerImageWidget(layer),
          ),
        );
      }

      // 添加图层绘制元素
      allElements.add(
        _LayeredElement(
          order: layer.order,
          isSelected: isSelectedLayer,
          widget: _buildLayerWidget(layer),
        ),
      );
    }

    // 收集所有图例组
    for (final legendGroup in widget.mapItem.legendGroups) {
      if (!legendGroup.isVisible) continue;

      // 计算图例组的层级（基于绑定的最高图层order）
      int legendOrder = -1;
      bool isLegendSelected = false;

      for (final layer in widget.mapItem.layers) {
        if (layer.legendGroupIds.contains(legendGroup.id)) {
          legendOrder = math.max(legendOrder, layer.order);
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
}

class _LayerPainter extends CustomPainter {
  final MapLayer layer;
  final bool isEditMode;
  final String? selectedElementId;

  _LayerPainter({
    required this.layer,
    required this.isEditMode,
    this.selectedElementId,
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
    }
    // 最后绘制选中元素的彩虹效果，确保它不受任何遮挡
    if (selectedElementId != null) {
      MapDrawingElement? selectedElement;
      try {
        selectedElement = sortedElements.firstWhere(
          (e) => e.id == selectedElementId,
        );
        _drawRainbowHighlight(canvas, selectedElement, size);
      } catch (e) {
        // 如果找不到元素，忽略绘制
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
      // As noted before, if goal is n=2.0, this would be 4.0 - (t * 2.0)
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
      // Standard ellipse equation: (dx/a)² + (dy/b)² <= 1
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

  //   // 如果没有点在椭圆内，还需要检查椭圆是否完全在矩形内 <--- 注意这里的注释
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
