import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../models/sticky_note.dart';

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

