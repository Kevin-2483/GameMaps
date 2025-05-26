import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../models/map_layer.dart';
import '../../../models/map_item.dart';
import '../../../models/legend_item.dart' as legend_db;

class MapCanvas extends StatefulWidget {
  final MapItem mapItem;
  final MapLayer? selectedLayer;
  final DrawingElementType? selectedDrawingTool;
  final Color selectedColor;
  final double selectedStrokeWidth;
  final List<legend_db.LegendItem> availableLegends;
  final bool isPreviewMode;
  final Function(MapLayer) onLayerUpdated;
  final Function(LegendGroup) onLegendGroupUpdated;

  const MapCanvas({
    super.key,
    required this.mapItem,
    this.selectedLayer,
    this.selectedDrawingTool,
    required this.selectedColor,
    required this.selectedStrokeWidth,
    required this.availableLegends,
    required this.isPreviewMode,
    required this.onLayerUpdated,
    required this.onLegendGroupUpdated,
  });

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  final TransformationController _transformationController = TransformationController();
  Offset? _currentDrawingStart;
  Offset? _currentDrawingEnd;
  bool _isDrawing = false;

  @override
  void dispose() {
    _transformationController.dispose();
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
          child: Container(
            width: 1200,
            height: 800,
            color: Colors.grey.shade100,
            child: Stack(
              children: [
                // Background map image
                if (widget.mapItem.hasImageData)
                  Positioned.fill(
                    child: Image.memory(
                      widget.mapItem.imageData!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                
                // Drawing layers
                ...widget.mapItem.layers.map((layer) => _buildLayerWidget(layer)),
                
                // Legend groups
                ...widget.mapItem.legendGroups.map((legendGroup) => _buildLegendWidget(legendGroup)),
                
                // Current drawing preview
                if (_isDrawing && _currentDrawingStart != null && _currentDrawingEnd != null)
                  CustomPaint(
                    size: const Size(1200, 800),
                    painter: _CurrentDrawingPainter(
                      start: _currentDrawingStart!,
                      end: _currentDrawingEnd!,
                      elementType: widget.selectedDrawingTool!,
                      color: widget.selectedColor,
                      strokeWidth: widget.selectedStrokeWidth,
                    ),
                  ),
                
                // Touch handler for drawing
                if (!widget.isPreviewMode && widget.selectedDrawingTool != null)
                  Positioned.fill(
                    child: GestureDetector(
                      onPanStart: _onDrawingStart,
                      onPanUpdate: _onDrawingUpdate,
                      onPanEnd: _onDrawingEnd,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerWidget(MapLayer layer) {
    return Positioned.fill(
      child: Opacity(
        opacity: layer.isVisible ? layer.opacity : 0.0,
        child: CustomPaint(
          size: const Size(1200, 800),
          painter: _LayerPainter(
            layer: layer,
            isEditMode: !widget.isPreviewMode,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendWidget(LegendGroup legendGroup) {
    if (!legendGroup.isVisible) return const SizedBox.shrink();

    return Positioned(
      left: 100, // 默认位置，后续可以改为可拖拽
      top: 100,
      child: Opacity(
        opacity: legendGroup.opacity,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                legendGroup.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              ...legendGroup.legendItems.map((item) => _buildLegendItem(item)),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLegendItem(LegendItem item) {
    // 通过 legendId 查找对应的图例数据
    final legendData = widget.availableLegends.where((legend) => legend.id.toString() == item.legendId).firstOrNull;
    final displayTitle = legendData?.title ?? 'Unknown Legend';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue, // 默认颜色，后续从图例数据获取
              border: Border.all(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            displayTitle,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _onDrawingStart(DragStartDetails details) {
    if (widget.isPreviewMode || widget.selectedDrawingTool == null) return;

    setState(() {
      _currentDrawingStart = details.localPosition;
      _currentDrawingEnd = details.localPosition;
      _isDrawing = true;
    });
  }

  void _onDrawingUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    setState(() {
      _currentDrawingEnd = details.localPosition;
    });
  }

  void _onDrawingEnd(DragEndDetails details) {
    if (!_isDrawing || _currentDrawingStart == null || _currentDrawingEnd == null || widget.selectedLayer == null) {
      setState(() {
        _isDrawing = false;
        _currentDrawingStart = null;
        _currentDrawingEnd = null;
      });
      return;
    }

    // Convert screen coordinates to normalized coordinates (0.0-1.0)
    final normalizedStart = Offset(
      _currentDrawingStart!.dx / 1200,
      _currentDrawingStart!.dy / 800,
    );
    final normalizedEnd = Offset(
      _currentDrawingEnd!.dx / 1200,
      _currentDrawingEnd!.dy / 800,
    );

    // Add the drawing element to the selected layer
    final element = MapDrawingElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: widget.selectedDrawingTool!,
      points: [normalizedStart, normalizedEnd],
      color: widget.selectedColor,
      strokeWidth: widget.selectedStrokeWidth,
      createdAt: DateTime.now(),
    );

    final updatedLayer = widget.selectedLayer!.copyWith(
      elements: [...widget.selectedLayer!.elements, element],
      updatedAt: DateTime.now(),
    );

    widget.onLayerUpdated(updatedLayer);

    setState(() {
      _isDrawing = false;
      _currentDrawingStart = null;
      _currentDrawingEnd = null;
    });
  }
}

class _LayerPainter extends CustomPainter {
  final MapLayer layer;
  final bool isEditMode;

  _LayerPainter({
    required this.layer,
    required this.isEditMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in layer.elements) {
      _drawElement(canvas, element, size);
    }
  }

  void _drawElement(Canvas canvas, MapDrawingElement element, Size size) {
    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..style = PaintingStyle.stroke;

    // Convert normalized coordinates to screen coordinates
    final points = element.points.map((point) => Offset(
      point.dx * size.width,
      point.dy * size.height,
    )).toList();

    if (points.length < 2) return;

    final start = points[0];
    final end = points[1];

    switch (element.type) {
      case DrawingElementType.line:
        canvas.drawLine(start, end, paint);
        break;
      
      case DrawingElementType.dashedLine:
        _drawDashedLine(canvas, start, end, paint);
        break;
      
      case DrawingElementType.arrow:
        _drawArrow(canvas, start, end, paint);
        break;
      
      case DrawingElementType.rectangle:
        final rect = Rect.fromPoints(start, end);
        paint.style = PaintingStyle.fill;
        canvas.drawRect(rect, paint);
        break;
      
      case DrawingElementType.hollowRectangle:
        final rect = Rect.fromPoints(start, end);
        paint.style = PaintingStyle.stroke;
        canvas.drawRect(rect, paint);
        break;
      
      case DrawingElementType.diagonalLines:
        _drawDiagonalPattern(canvas, start, end, paint);
        break;
      
      case DrawingElementType.crossLines:
        _drawCrossPattern(canvas, start, end, paint);
        break;
      
      case DrawingElementType.dotGrid:
        _drawDotGrid(canvas, start, end, paint);
        break;
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    
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
    final arrowPoint1 = end + Offset(
      arrowLength * -1 * math.cos(direction - arrowAngle),
      arrowLength * -1 * math.sin(direction - arrowAngle),
    );
    final arrowPoint2 = end + Offset(
      arrowLength * -1 * math.cos(direction + arrowAngle),
      arrowLength * -1 * math.sin(direction + arrowAngle),
    );
    
    canvas.drawLine(end, arrowPoint1, paint);
    canvas.drawLine(end, arrowPoint2, paint);
  }

  void _drawDiagonalPattern(Canvas canvas, Offset start, Offset end, Paint paint) {
    final rect = Rect.fromPoints(start, end);
    const spacing = 10.0;
    
    for (double x = rect.left; x <= rect.right; x += spacing) {
      final lineStart = Offset(x, rect.top);
      final lineEnd = Offset(
        math.min(x + rect.height, rect.right), 
        rect.bottom
      );
      canvas.drawLine(lineStart, lineEnd, paint);
    }
  }

  void _drawCrossPattern(Canvas canvas, Offset start, Offset end, Paint paint) {
    final rect = Rect.fromPoints(start, end);
    const spacing = 15.0;
    
    // Vertical lines
    for (double x = rect.left; x <= rect.right; x += spacing) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }
    
    // Horizontal lines
    for (double y = rect.top; y <= rect.bottom; y += spacing) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
  }

  void _drawDotGrid(Canvas canvas, Offset start, Offset end, Paint paint) {
    final rect = Rect.fromPoints(start, end);
    const spacing = 10.0;
    const dotRadius = 1.0;
    
    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    
    for (double x = rect.left; x <= rect.right; x += spacing) {
      for (double y = rect.top; y <= rect.bottom; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
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

  _CurrentDrawingPainter({
    required this.start,
    required this.end,
    required this.elementType,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final element = MapDrawingElement(
      id: 'preview',
      type: elementType,
      points: [
        Offset(start.dx / size.width, start.dy / size.height),
        Offset(end.dx / size.width, end.dy / size.height),
      ],
      color: color.withOpacity(0.7),
      strokeWidth: strokeWidth,
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
    );

    layerPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
