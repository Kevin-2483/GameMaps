import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../models/sticky_note.dart';
import '../../../models/map_layer.dart';

/// 便签显示组件
/// 用于在画布上渲染可交互的便签
class StickyNoteDisplay extends StatefulWidget {
  final StickyNote note;
  final bool isSelected;
  final bool isPreviewMode;
  final Function(StickyNote)? onNoteUpdated;

  const StickyNoteDisplay({
    super.key,
    required this.note,
    required this.isSelected,
    required this.isPreviewMode,
    this.onNoteUpdated,
  });

  @override
  State<StickyNoteDisplay> createState() => _StickyNoteDisplayState();
}

class _StickyNoteDisplayState extends State<StickyNoteDisplay> {
  bool _isDragging = false;
  bool _isResizing = false;
  Offset? _dragStartPosition;
  Offset? _resizeStartPosition;
  Size? _resizeStartSize;
  Offset? _dragStartNotePosition; // 记录拖拽开始时便签的位置

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.note.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: widget.isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题栏
          _buildTitleBar(),

          // 内容区域（如果未折叠）
          if (!widget.note.isCollapsed) _buildContentArea(),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildTitleBar() {
    return GestureDetector(
      onPanStart: widget.isPreviewMode ? null : _onTitleBarDragStart,
      onPanUpdate: widget.isPreviewMode ? null : _onTitleBarDragUpdate,
      onPanEnd: widget.isPreviewMode ? null : _onTitleBarDragEnd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: widget.note.titleBarColor,
          borderRadius: widget.note.isCollapsed
              ? BorderRadius.circular(8)
              : const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
        ),
        child: Row(
          children: [
            // 标题文本
            Expanded(
              child: Text(
                widget.note.title,
                style: TextStyle(
                  color: widget.note.textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 折叠/展开按钮
            if (!widget.isPreviewMode)
              GestureDetector(
                onTap: _toggleCollapse,
                child: Icon(
                  widget.note.isCollapsed
                      ? Icons.expand_more
                      : Icons.expand_less,
                  size: 16,
                  color: widget.note.textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContentArea() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            // 背景图片（如果有）
            if (widget.note.hasBackgroundImage) _buildBackgroundImage(),

            // 绘画元素
            if (widget.note.hasElements) _buildDrawingElements(),

            // 文本内容
            if (widget.note.content.isNotEmpty) _buildTextContent(),

            // 调整大小手柄
            if (widget.isSelected && !widget.isPreviewMode)
              _buildResizeHandles(),
          ],
        ),
      ),
    );
  }

  /// 构建背景图片
  Widget _buildBackgroundImage() {
    if (widget.note.backgroundImageData == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Opacity(
        opacity: widget.note.backgroundImageOpacity,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          child: Image.memory(
            widget.note.backgroundImageData!,
            fit: widget.note.backgroundImageFit,
          ),
        ),
      ),
    );
  }

  /// 构建绘画元素
  Widget _buildDrawingElements() {
    if (widget.note.elements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: CustomPaint(
        painter: _StickyNoteElementsPainter(elements: widget.note.elements),
      ),
    );
  }

  /// 构建文本内容
  Widget _buildTextContent() {
    return Positioned.fill(
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Text(
          widget.note.content,
          style: TextStyle(
            color: widget.note.textColor.withOpacity(0.8),
            fontSize: 10,
          ),
          maxLines: null,
        ),
      ),
    );
  }

  /// 构建调整大小手柄
  Widget _buildResizeHandles() {
    const double handleSize = 16.0;

    return Stack(
      children: [
        // 右下角调整手柄
        Positioned(
          right: -4,
          bottom: -4,
          child: GestureDetector(
            onPanStart: _onResizeStart,
            onPanUpdate: _onResizeUpdate,
            onPanEnd: _onResizeEnd,
            child: Container(
              width: handleSize,
              height: handleSize,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 处理标题栏拖拽开始
  void _onTitleBarDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartPosition = details.localPosition;
    _dragStartNotePosition = widget.note.position; // 记录开始位置
  }

  /// 处理标题栏拖拽更新
  void _onTitleBarDragUpdate(DragUpdateDetails details) {
    if (!_isDragging ||
        _dragStartPosition == null ||
        _dragStartNotePosition == null)
      return;

    // 计算拖动偏移量
    final delta = details.localPosition - _dragStartPosition!;

    // 获取画布尺寸（与 MapCanvas 中的常量保持一致）
    const canvasSize = Size(1600, 1600);

    // 将像素偏移量转换为相对坐标偏移量
    final relativeDelta = Offset(
      delta.dx / canvasSize.width,
      delta.dy / canvasSize.height,
    );

    // 计算新的相对位置（基于拖拽开始时的位置）
    final newPosition = Offset(
      (_dragStartNotePosition!.dx + relativeDelta.dx).clamp(
        0.0,
        1.0 - widget.note.size.width,
      ),
      (_dragStartNotePosition!.dy + relativeDelta.dy).clamp(
        0.0,
        1.0 - widget.note.size.height,
      ),
    );

    _updateNotePosition(newPosition);
  }

  /// 处理标题栏拖拽结束
  void _onTitleBarDragEnd(DragEndDetails details) {
    _isDragging = false;
    _dragStartPosition = null;
    _dragStartNotePosition = null;
  }

  /// 处理调整大小开始
  void _onResizeStart(DragStartDetails details) {
    _isResizing = true;
    _resizeStartPosition = details.localPosition;
    _resizeStartSize = widget.note.size;
  }

  /// 处理调整大小更新
  void _onResizeUpdate(DragUpdateDetails details) {
    if (!_isResizing ||
        _resizeStartPosition == null ||
        _resizeStartSize == null)
      return;

    // 计算大小变化
    final delta = details.localPosition - _resizeStartPosition!;
    const canvasSize = Size(1600, 1600);

    final newSize = Size(
      (_resizeStartSize!.width + delta.dx / canvasSize.width).clamp(
        0.05,
        0.5,
      ), // 最小5%，最大50%
      (_resizeStartSize!.height + delta.dy / canvasSize.height).clamp(
        0.05,
        0.5,
      ),
    );

    _updateNoteSize(newSize);
  }

  /// 处理调整大小结束
  void _onResizeEnd(DragEndDetails details) {
    _isResizing = false;
    _resizeStartPosition = null;
    _resizeStartSize = null;
  }

  /// 切换折叠状态
  void _toggleCollapse() {
    final updatedNote = widget.note.copyWith(
      isCollapsed: !widget.note.isCollapsed,
      updatedAt: DateTime.now(),
    );
    widget.onNoteUpdated?.call(updatedNote);
  }

  /// 更新便签位置
  void _updateNotePosition(Offset newPosition) {
    final updatedNote = widget.note.copyWith(
      position: newPosition,
      updatedAt: DateTime.now(),
    );
    widget.onNoteUpdated?.call(updatedNote);
  }

  /// 更新便签大小
  void _updateNoteSize(Size newSize) {
    final updatedNote = widget.note.copyWith(
      size: newSize,
      updatedAt: DateTime.now(),
    );
    widget.onNoteUpdated?.call(updatedNote);
  }
}

/// 便签绘画元素画笔
class _StickyNoteElementsPainter extends CustomPainter {
  final List<MapDrawingElement> elements;

  _StickyNoteElementsPainter({required this.elements});

  @override
  void paint(Canvas canvas, Size size) {
    // 按 z 值排序元素
    final sortedElements = List<MapDrawingElement>.from(elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (final element in sortedElements) {
      _drawElement(canvas, element, size);
    }
  }

  /// 绘制单个元素
  void _drawElement(Canvas canvas, MapDrawingElement element, Size size) {
    if (element.points.isEmpty) return;

    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 转换相对坐标到实际坐标
    final points = element.points
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList();

    switch (element.type) {
      case DrawingElementType.line:
        if (points.length >= 2) {
          canvas.drawLine(points[0], points[1], paint);
        }
        break;

      case DrawingElementType.rectangle:
        if (points.length >= 2) {
          paint.style = PaintingStyle.fill;
          final rect = Rect.fromPoints(points[0], points[1]);
          canvas.drawRect(rect, paint);
        }
        break;

      case DrawingElementType.hollowRectangle:
        if (points.length >= 2) {
          paint.style = PaintingStyle.stroke;
          final rect = Rect.fromPoints(points[0], points[1]);
          canvas.drawRect(rect, paint);
        }
        break; // Note: circle and hollowCircle are not available in DrawingElementType enum
      // These can be added if needed in the future

      case DrawingElementType.freeDrawing:
        if (points.length >= 2) {
          final path = Path();
          path.moveTo(points[0].dx, points[0].dy);
          for (int i = 1; i < points.length; i++) {
            path.lineTo(points[i].dx, points[i].dy);
          }
          canvas.drawPath(path, paint);
        }
        break;

      case DrawingElementType.text:
        if (element.text != null && element.text!.isNotEmpty) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: element.text!,
              style: TextStyle(
                color: element.color,
                fontSize: (element.fontSize ?? 16.0) * 0.8, // 便签中的文字稍小
                fontWeight: FontWeight.normal,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, points[0]);
        }
        break;

      default:
        // 其他类型的绘制元素可以根据需要添加
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _StickyNoteElementsPainter oldDelegate) {
    return oldDelegate.elements != elements;
  }
}
