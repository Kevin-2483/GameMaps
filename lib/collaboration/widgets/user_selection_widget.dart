import 'package:flutter/material.dart';
import '../models/collaboration_state.dart';

/// 用户选择组件
/// 显示其他用户选择的元素
class UserSelectionWidget extends StatefulWidget {
  final UserSelectionState selection;
  final Rect elementBounds;
  final double strokeWidth;
  final double opacity;
  final double padding;
  final double borderRadius;
  final bool showUserLabel;
  final Color labelTextColor;
  final double labelFontSize;
  final Duration animationDuration;

  const UserSelectionWidget({
    super.key,
    required this.selection,
    required this.elementBounds,
    this.strokeWidth = 2.0,
    this.opacity = 0.7,
    this.padding = 2.0,
    this.borderRadius = 4.0,
    this.showUserLabel = true,
    this.labelTextColor = Colors.white,
    this.labelFontSize = 12.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<UserSelectionWidget> createState() => _UserSelectionWidgetState();
}

class _UserSelectionWidgetState extends State<UserSelectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _strokeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: widget.opacity,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _strokeAnimation = Tween<double>(
      begin: widget.strokeWidth * 2,
      end: widget.strokeWidth,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: CustomPaint(
            size: Size(
              widget.elementBounds.width + widget.padding * 2,
              widget.elementBounds.height + widget.padding * 2,
            ),
            painter: UserSelectionPainter(
              selection: widget.selection,
              elementBounds: widget.elementBounds,
              strokeWidth: _strokeAnimation.value,
              opacity: _opacityAnimation.value,
              padding: widget.padding,
              borderRadius: widget.borderRadius,
              showUserLabel: widget.showUserLabel,
              labelTextColor: widget.labelTextColor,
              labelFontSize: widget.labelFontSize,
            ),
          ),
        );
      },
    );
  }
}

/// 用户选择绘制器
class UserSelectionPainter extends CustomPainter {
  final UserSelectionState selection;
  final Rect elementBounds;
  final double strokeWidth;
  final double opacity;
  final double padding;
  final double borderRadius;
  final bool showUserLabel;
  final Color labelTextColor;
  final double labelFontSize;

  UserSelectionPainter({
    required this.selection,
    required this.elementBounds,
    required this.strokeWidth,
    required this.opacity,
    required this.padding,
    required this.borderRadius,
    required this.showUserLabel,
    required this.labelTextColor,
    required this.labelFontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintSelectionBorder(canvas);
    
    if (showUserLabel) {
      _paintUserLabel(canvas);
    }
  }

  void _paintSelectionBorder(Canvas canvas) {
    final paint = Paint()
      ..color = selection.userColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // 绘制选择边框
    final rect = RRect.fromRectAndRadius(
      elementBounds.inflate(padding),
      Radius.circular(borderRadius),
    );
    
    canvas.drawRRect(rect, paint);
    
    // 绘制内部高亮
    final highlightPaint = Paint()
      ..color = selection.userColor.withValues(alpha: opacity * 0.1)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, highlightPaint);
    
    // 绘制角落装饰
    _paintCornerDecorations(canvas, rect);
  }

  void _paintCornerDecorations(Canvas canvas, RRect rect) {
    final cornerPaint = Paint()
      ..color = selection.userColor
      ..style = PaintingStyle.fill;
    
    final cornerSize = strokeWidth * 2;
    
    // 左上角
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left - strokeWidth / 2,
          rect.top - strokeWidth / 2,
          cornerSize,
          cornerSize,
        ),
        Radius.circular(borderRadius / 2),
      ),
      cornerPaint,
    );
    
    // 右下角
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.right - cornerSize + strokeWidth / 2,
          rect.bottom - cornerSize + strokeWidth / 2,
          cornerSize,
          cornerSize,
        ),
        Radius.circular(borderRadius / 2),
      ),
      cornerPaint,
    );
  }

  void _paintUserLabel(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: selection.userDisplayName,
        style: TextStyle(
          color: labelTextColor,
          fontSize: labelFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final labelRect = Rect.fromLTWH(
      elementBounds.left,
      elementBounds.top - textPainter.height - 8,
      textPainter.width + 12,
      textPainter.height + 6,
    );
    
    // 绘制标签背景
    final labelPaint = Paint()
      ..color = selection.userColor.withValues(alpha: 0.95);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      labelPaint,
    );
    
    // 绘制标签边框
    final labelBorderPaint = Paint()
      ..color = selection.userColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      labelBorderPaint,
    );
    
    // 绘制标签文字
    textPainter.paint(canvas, Offset(labelRect.left + 6, labelRect.top + 3));
    
    // 绘制指向箭头
    _paintLabelArrow(canvas, labelRect, elementBounds);
  }

  void _paintLabelArrow(Canvas canvas, Rect labelRect, Rect elementBounds) {
    final arrowPaint = Paint()
      ..color = selection.userColor
      ..style = PaintingStyle.fill;
    
    final arrowPath = Path();
    final arrowTip = Offset(
      labelRect.center.dx,
      elementBounds.top - padding,
    );
    
    arrowPath.moveTo(labelRect.center.dx - 4, labelRect.bottom);
    arrowPath.lineTo(arrowTip.dx, arrowTip.dy);
    arrowPath.lineTo(labelRect.center.dx + 4, labelRect.bottom);
    arrowPath.close();
    
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(UserSelectionPainter oldDelegate) {
    return selection != oldDelegate.selection ||
           elementBounds != oldDelegate.elementBounds ||
           strokeWidth != oldDelegate.strokeWidth ||
           opacity != oldDelegate.opacity;
  }
}

/// 多用户选择状态组件
/// 显示多个用户对同一元素的选择状态
class MultiUserSelectionWidget extends StatelessWidget {
  final List<UserSelectionState> selections;
  final Rect elementBounds;
  final double strokeWidth;
  final double opacity;
  final double padding;
  final double borderRadius;
  final bool showUserLabels;
  final Color labelTextColor;
  final double labelFontSize;

  const MultiUserSelectionWidget({
    super.key,
    required this.selections,
    required this.elementBounds,
    this.strokeWidth = 2.0,
    this.opacity = 0.7,
    this.padding = 2.0,
    this.borderRadius = 4.0,
    this.showUserLabels = true,
    this.labelTextColor = Colors.white,
    this.labelFontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    if (selections.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: Size(
        elementBounds.width + padding * 2,
        elementBounds.height + padding * 2,
      ),
      painter: MultiUserSelectionPainter(
        selections: selections,
        elementBounds: elementBounds,
        strokeWidth: strokeWidth,
        opacity: opacity,
        padding: padding,
        borderRadius: borderRadius,
        showUserLabels: showUserLabels,
        labelTextColor: labelTextColor,
        labelFontSize: labelFontSize,
      ),
    );
  }
}

/// 多用户选择绘制器
class MultiUserSelectionPainter extends CustomPainter {
  final List<UserSelectionState> selections;
  final Rect elementBounds;
  final double strokeWidth;
  final double opacity;
  final double padding;
  final double borderRadius;
  final bool showUserLabels;
  final Color labelTextColor;
  final double labelFontSize;

  MultiUserSelectionPainter({
    required this.selections,
    required this.elementBounds,
    required this.strokeWidth,
    required this.opacity,
    required this.padding,
    required this.borderRadius,
    required this.showUserLabels,
    required this.labelTextColor,
    required this.labelFontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制多层边框
    for (int i = 0; i < selections.length; i++) {
      final selection = selections[i];
      final offset = i * 2.0;
      
      _paintSelectionBorder(canvas, selection, offset);
    }
    
    // 绘制用户标签
    if (showUserLabels) {
      _paintUserLabels(canvas);
    }
  }

  void _paintSelectionBorder(Canvas canvas, UserSelectionState selection, double offset) {
    final paint = Paint()
      ..color = selection.userColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = RRect.fromRectAndRadius(
      elementBounds.inflate(padding + offset),
      Radius.circular(borderRadius),
    );
    
    canvas.drawRRect(rect, paint);
  }

  void _paintUserLabels(Canvas canvas) {
    final labelHeight = labelFontSize + 6;
    final totalHeight = selections.length * labelHeight;
    
    for (int i = 0; i < selections.length; i++) {
      final selection = selections[i];
      final yOffset = i * labelHeight;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: selection.userDisplayName,
          style: TextStyle(
            color: labelTextColor,
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      final labelRect = Rect.fromLTWH(
        elementBounds.left,
        elementBounds.top - totalHeight - 8 + yOffset,
        textPainter.width + 12,
        labelHeight,
      );
      
      // 绘制标签背景
      final labelPaint = Paint()
        ..color = selection.userColor.withValues(alpha: 0.9);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        labelPaint,
      );
      
      // 绘制标签文字
      textPainter.paint(canvas, Offset(labelRect.left + 6, labelRect.top + 3));
    }
  }

  @override
  bool shouldRepaint(MultiUserSelectionPainter oldDelegate) {
    return selections != oldDelegate.selections ||
           elementBounds != oldDelegate.elementBounds;
  }
}