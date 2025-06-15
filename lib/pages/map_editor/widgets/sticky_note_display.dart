import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../models/sticky_note.dart';
import '../../../models/map_layer.dart';
import '../renderers/eraser_renderer.dart';

/// 便签点击类型枚举
enum StickyNoteHitType {
  titleBar, // 标题栏（用于拖拽便签）
  resizeHandle, // 调整大小手柄
  collapseButton, // 折叠/展开按钮
}

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
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.note.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: widget.isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null, // 未选中时不渲染边框
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
    // 当便签被选中时，边框会占用2px，所以标题栏圆角需要相应调整
    final double cornerRadius = widget.isSelected ? 6.0 : 8.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: widget.note.titleBarColor,
        borderRadius: widget.note.isCollapsed
            ? BorderRadius.circular(cornerRadius)
            : BorderRadius.only(
                topLeft: Radius.circular(cornerRadius),
                topRight: Radius.circular(cornerRadius),
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
          ), // 折叠/展开按钮
          if (!widget.isPreviewMode)
            GestureDetector(
              onTap: _toggleCollapse,
              behavior: HitTestBehavior.opaque, // 确保按钮区域可以接收点击
              child: Container(
                padding: const EdgeInsets.all(4), // 增加点击区域
                child: Icon(
                  widget.note.isCollapsed
                      ? Icons.expand_more
                      : Icons.expand_less,
                  size: 16,
                  color: widget.note.textColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContentArea() {
    // 当便签被选中时，边框会占用2px，所以内容区域圆角需要相应调整
    final double cornerRadius = widget.isSelected ? 6.0 : 8.0;

    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(cornerRadius),
            bottomRight: Radius.circular(cornerRadius),
          ),
          // 当选中便签且不在预览模式时，添加虚线边框提示可绘制区域
          border: widget.isSelected && !widget.isPreviewMode
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                  style: BorderStyle.solid,
                )
              : null,
        ),
        child: Stack(
          children: [
            // 背景图片（如果有）
            if (widget.note.hasBackgroundImage) _buildBackgroundImage(),

            // 便签绘制元素层
            if (widget.note.elements.isNotEmpty) _buildDrawingElements(),

            // 调整大小手柄
            if (widget.isSelected && !widget.isPreviewMode)
              _buildResizeHandles(),

            // 绘制区域提示（当选中且无内容时显示）
            if (widget.isSelected &&
                !widget.isPreviewMode &&
                widget.note.elements.isEmpty &&
                !widget.note.hasBackgroundImage)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.brush,
                        size: 32,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '可在此区域绘制',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

    // 当便签被选中时，边框会占用2px，所以背景图片圆角需要相应调整
    final double cornerRadius = widget.isSelected ? 6.0 : 8.0;

    return Positioned.fill(
      child: Opacity(
        opacity: widget.note.backgroundImageOpacity,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(cornerRadius),
            bottomRight: Radius.circular(cornerRadius),
          ),
          child: Image.memory(
            widget.note.backgroundImageData!,
            fit: widget.note.backgroundImageFit,
          ),
        ),
      ),
    );
  }

  /// 构建便签绘制元素
  Widget _buildDrawingElements() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _StickyNoteDrawingPainter(
          elements: widget.note.elements,
          isSelected: widget.isSelected,
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
      ],
    );
  }

  /// 切换折叠状态
  void _toggleCollapse() {
    final updatedNote = widget.note.copyWith(
      isCollapsed: !widget.note.isCollapsed,
      updatedAt: DateTime.now(),
    );
    widget.onNoteUpdated?.call(updatedNote);
  }
}

/// 便签手势检测工具类
/// 供 MapCanvas 使用的静态方法
class StickyNoteGestureHelper {
  /// 清理节流资源
  static void dispose() {
    // 已移除节流机制，此方法保留以兼容现有代码
  }

  /// 检测点击位置是否命中便签的特定区域
  ///
  /// [canvasPosition] 相对于画布的点击位置
  /// [note] 便签对象
  /// [canvasSize] 画布尺寸
  ///
  /// 返回命中的区域类型，如果没有命中特定区域则返回 null
  static StickyNoteHitType? getStickyNoteHitType(
    Offset canvasPosition,
    StickyNote note,
    Size canvasSize,
  ) {
    // 转换便签的相对坐标到画布坐标
    final notePosition = Offset(
      note.position.dx * canvasSize.width,
      note.position.dy * canvasSize.height,
    );
    final noteSize = Size(
      note.size.width * canvasSize.width,
      note.size.height * canvasSize.height,
    );

    // 创建便签的矩形区域
    final noteRect = Rect.fromLTWH(
      notePosition.dx,
      notePosition.dy,
      noteSize.width,
      noteSize.height,
    );

    // 检查点击位置是否在便签区域内
    if (!noteRect.contains(canvasPosition)) {
      return null;
    }

    // 计算相对于便签的本地坐标
    final localPosition = Offset(
      canvasPosition.dx - notePosition.dx,
      canvasPosition.dy - notePosition.dy,
    );

    // 检查是否点击了调整大小手柄（只有在便签被选中且未折叠时才有）
    if (!note.isCollapsed) {
      const double handleSize = 16.0;
      final handleRect = Rect.fromLTWH(
        noteSize.width - 4 - handleSize,
        noteSize.height - 4 - handleSize,
        handleSize + 8, // 增加点击区域
        handleSize + 8,
      );

      if (handleRect.contains(localPosition)) {
        return StickyNoteHitType.resizeHandle;
      }
    } // 检查是否点击了标题栏
    const double titleBarHeight =
        30.0; // 标题栏高度：padding(12px) + 内容(~18px) = ~30px
    final titleBarRect = Rect.fromLTWH(0, 0, noteSize.width, titleBarHeight);

    if (titleBarRect.contains(localPosition)) {
      // 在标题栏内，进一步检查是否点击了折叠按钮
      const double collapseButtonSize = 24.0; // 折叠按钮区域大小（包括padding）
      final collapseButtonRect = Rect.fromLTWH(
        noteSize.width - collapseButtonSize, // 右对齐
        0,
        collapseButtonSize,
        titleBarHeight,
      );
      if (collapseButtonRect.contains(localPosition)) {
        return StickyNoteHitType.collapseButton;
      }

      return StickyNoteHitType.titleBar;
    }

    // 点击了便签的其他区域，不返回特定类型
    return null;
  }

  /// 处理便签拖拽开始
  ///
  /// [note] 要拖拽的便签
  /// [hitType] 命中的区域类型
  /// [details] 拖拽开始的详细信息
  /// [getCanvasPosition] 将本地坐标转换为画布坐标的函数
  /// [onNoteUpdated] 便签更新回调
  static StickyNoteDragState? handleStickyNotePanStart(
    StickyNote note,
    StickyNoteHitType hitType,
    DragStartDetails details,
    Offset Function(Offset) getCanvasPosition,
    Function(StickyNote) onNoteUpdated,
  ) {
    final canvasPosition = getCanvasPosition(details.localPosition);
    switch (hitType) {
      case StickyNoteHitType.titleBar:
        return StickyNoteDragState(
          type: StickyNoteDragType.move,
          note: note,
          startPosition: canvasPosition,
          startNotePosition: note.position,
          onNoteUpdated: onNoteUpdated,
        );

      case StickyNoteHitType.resizeHandle:
        return StickyNoteDragState(
          type: StickyNoteDragType.resize,
          note: note,
          startPosition: canvasPosition,
          startNoteSize: note.size,
          onNoteUpdated: onNoteUpdated,
        );

      case StickyNoteHitType.collapseButton:
        // 对于折叠按钮，我们不启动拖拽
        // 折叠操作应该在 TapDown 事件中处理
        return null; // 不返回拖拽状态
    }
  }

  /// 处理便签拖拽更新
  static void handleStickyNotePanUpdate(
    StickyNoteDragState dragState,
    DragUpdateDetails details,
    Offset Function(Offset) getCanvasPosition,
    Size canvasSize,
  ) {
    final currentPosition = getCanvasPosition(details.localPosition);

    switch (dragState.type) {
      case StickyNoteDragType.move:
        _handleMoveUpdate(dragState, currentPosition, canvasSize);
        break;

      case StickyNoteDragType.resize:
        _handleResizeUpdate(dragState, currentPosition, canvasSize);
        break;
    }
  }

  /// 处理便签拖拽结束
  static void handleStickyNotePanEnd(
    StickyNoteDragState dragState,
    DragEndDetails details,
    Offset Function(Offset) getCanvasPosition,
    Size canvasSize,
    List<StickyNote> allStickyNotes,
    Function(List<StickyNote>) onStickyNotesReordered,
  ) {
    // 立即执行任何待处理的节流更新
    _flushPendingUpdate(dragState.note.id, dragState.onNoteUpdated);

    // 如果不是移动操作，直接返回
    if (dragState.type != StickyNoteDragType.move) {
      return;
    }

    // 获取拖拽结束时的画布位置
    final endPosition = getCanvasPosition(details.localPosition);

    // 查找拖拽结束位置是否命中了其他便签的标题栏
    final targetNote = _findTargetStickyNote(
      endPosition,
      dragState.note,
      allStickyNotes,
      canvasSize,
    );

    if (targetNote != null) {
      // 执行层级重排
      final reorderedNotes = _reorderStickyNotes(
        dragState.note,
        targetNote,
        allStickyNotes,
      );

      // 通知上层更新便签列表
      onStickyNotesReordered(reorderedNotes);
    }
  }

  /// 立即执行待处理的更新（已移除节流，此方法保留兼容性）
  static void _flushPendingUpdate(
    String noteId,
    Function(StickyNote) onNoteUpdated,
  ) {
    // 由于移除了节流机制，此方法不再执行任何操作
    // 保留此方法以兼容现有的调用代码
  }
  // 私有方法：处理移动更新（带节流）
  static void _handleMoveUpdate(
    StickyNoteDragState dragState,
    Offset currentPosition,
    Size canvasSize,
  ) {
    if (dragState.startPosition == null ||
        dragState.startNotePosition == null) {
      return;
    }

    // 计算拖动偏移量
    final delta = currentPosition - dragState.startPosition!;

    // 将像素偏移量转换为相对坐标偏移量
    final relativeDelta = Offset(
      delta.dx / canvasSize.width,
      delta.dy / canvasSize.height,
    );

    // 计算新的相对位置
    final newPosition = Offset(
      (dragState.startNotePosition!.dx + relativeDelta.dx).clamp(
        0.0,
        1.0 - dragState.note.size.width,
      ),
      (dragState.startNotePosition!.dy + relativeDelta.dy).clamp(
        0.0,
        1.0 - dragState.note.size.height,
      ),
    );

    // 创建更新后的便签
    final updatedNote = dragState.note.copyWith(
      position: newPosition,
      updatedAt: DateTime.now(),
    ); // 使用实时更新（不节流）确保UI响应性
    dragState.onNoteUpdated(updatedNote);
  }

  // 私有方法：处理调整大小更新（不节流，实时更新）
  static void _handleResizeUpdate(
    StickyNoteDragState dragState,
    Offset currentPosition,
    Size canvasSize,
  ) {
    if (dragState.startPosition == null || dragState.startNoteSize == null) {
      return;
    }

    // 计算大小变化
    final delta = currentPosition - dragState.startPosition!;

    // 转换为相对坐标变化
    final newSize = Size(
      (dragState.startNoteSize!.width + delta.dx / canvasSize.width).clamp(
        0.05, // 最小5%
        0.5, // 最大50%
      ),
      (dragState.startNoteSize!.height + delta.dy / canvasSize.height).clamp(
        0.05,
        0.5,
      ),
    );

    // 创建更新后的便签
    final updatedNote = dragState.note.copyWith(
      size: newSize,
      updatedAt: DateTime.now(),
    ); // 使用实时更新（不节流）确保UI响应性
    dragState.onNoteUpdated(updatedNote);
  }

  // 私有方法：查找目标便签
  static StickyNote? _findTargetStickyNote(
    Offset endPosition,
    StickyNote draggedNote,
    List<StickyNote> allStickyNotes,
    Size canvasSize,
  ) {
    // 按照Z值倒序检查所有可见的便签（优先检查上层便签）
    final sortedStickyNotes = List<StickyNote>.from(allStickyNotes)
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));

    for (final note in sortedStickyNotes) {
      // 跳过自己和不可见的便签
      if (!note.isVisible || note.id == draggedNote.id) continue;

      // 转换相对坐标到画布坐标
      final notePosition = Offset(
        note.position.dx * canvasSize.width,
        note.position.dy * canvasSize.height,
      );
      final noteSize = Size(
        note.size.width * canvasSize.width,
        note.size.height * canvasSize.height,
      ); // 检查是否命中了标题栏
      const double titleBarHeight = 30.0; // 标题栏高度
      final titleBarRect = Rect.fromLTWH(
        notePosition.dx,
        notePosition.dy,
        noteSize.width,
        titleBarHeight,
      );

      if (titleBarRect.contains(endPosition)) {
        return note;
      }
    }
    return null;
  }

  // 私有方法：重排便签层级
  static List<StickyNote> _reorderStickyNotes(
    StickyNote draggedNote,
    StickyNote targetNote,
    List<StickyNote> allStickyNotes,
  ) {
    final result = List<StickyNote>.from(allStickyNotes);
    final draggedIndex = result.indexWhere((note) => note.id == draggedNote.id);
    final targetIndex = result.indexWhere((note) => note.id == targetNote.id);

    if (draggedIndex == -1 || targetIndex == -1) {
      return result; // 如果找不到便签，返回原列表
    }

    final draggedOriginalZ = draggedNote.zIndex;
    final targetZ = targetNote.zIndex;
    final newDraggedZ = targetZ + 1; // 放在目标便签的上层

    for (int i = 0; i < result.length; i++) {
      final note = result[i];

      if (note.id == draggedNote.id) {
        // 更新被拖拽便签的z值
        result[i] = note.copyWith(
          zIndex: newDraggedZ,
          updatedAt: DateTime.now(),
        );
      } else if (draggedOriginalZ < targetZ) {
        // 原本z值低，目标及以下的便签z值减一
        if (note.zIndex <= targetZ && note.zIndex > draggedOriginalZ) {
          result[i] = note.copyWith(
            zIndex: note.zIndex - 1,
            updatedAt: DateTime.now(),
          );
        }
      } else if (draggedOriginalZ > targetZ) {
        // 原本z值高，比目标z值大的z值加一
        if (note.zIndex > targetZ && note.zIndex < draggedOriginalZ) {
          result[i] = note.copyWith(
            zIndex: note.zIndex + 1,
            updatedAt: DateTime.now(),
          );
        }
      }
    }

    return result;
  }
}

/// 便签拖拽类型枚举
enum StickyNoteDragType {
  move, // 移动便签
  resize, // 调整大小
}

/// 便签拖拽状态类
class StickyNoteDragState {
  final StickyNoteDragType type;
  final StickyNote note;
  final Offset? startPosition;
  final Offset? startNotePosition; // 移动时使用
  final Size? startNoteSize; // 调整大小时使用
  final Function(StickyNote) onNoteUpdated;
  StickyNoteDragState({
    required this.type,
    required this.note,
    this.startPosition,
    this.startNotePosition,
    this.startNoteSize,
    required this.onNoteUpdated,
  });
}

/// 便签绘制元素画笔
/// 用于在便签上渲染绘画元素
class _StickyNoteDrawingPainter extends CustomPainter {
  final List<MapDrawingElement> elements;
  final bool isSelected;

  _StickyNoteDrawingPainter({required this.elements, required this.isSelected});
  @override
  void paint(Canvas canvas, Size size) {
    if (elements.isEmpty) return;

    // 创建裁剪区域，确保绘制内容不超出便签内容区域
    final clipRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.save();
    canvas.clipRect(clipRect);

    // 按 z 值排序元素
    final sortedElements = List<MapDrawingElement>.from(elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    // 找到所有橡皮擦元素
    final eraserElements = sortedElements
        .where((e) => e.type == DrawingElementType.eraser)
        .toList();

    // 绘制所有常规元素（排除橡皮擦）
    for (final element in sortedElements) {
      if (element.type == DrawingElementType.eraser) {
        continue; // 橡皮擦本身不绘制
      }

      // 使用橡皮擦渲染器来处理橡皮擦遮挡效果
      EraserRenderer.drawElementWithEraserMask(
        canvas,
        element,
        eraserElements,
        size,
      );
    }

    // 恢复画布状态
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StickyNoteDrawingPainter oldDelegate) {
    return oldDelegate.elements != elements ||
        oldDelegate.isSelected != isSelected;
  }
}
