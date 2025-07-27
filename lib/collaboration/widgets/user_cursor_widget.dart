import 'package:flutter/material.dart';
import '../models/collaboration_state.dart';
import 'collaboration_overlay.dart';

/// 用户指针组件
/// 显示其他用户的鼠标指针位置和用户信息
class UserCursorWidget extends StatefulWidget {
  final UserCursorState cursor;
  final UserCursorStyle style;

  const UserCursorWidget({
    super.key,
    required this.cursor,
    required this.style,
  });

  @override
  State<UserCursorWidget> createState() => _UserCursorWidgetState();
}

class _UserCursorWidgetState extends State<UserCursorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.style.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: widget.style.opacity)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    if (widget.cursor.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(UserCursorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.cursor.isVisible != oldWidget.cursor.isVisible) {
      if (widget.cursor.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.cursor.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: _buildCursor(),
          ),
        );
      },
    );
  }

  Widget _buildCursor() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 指针图标
        _buildCursorIcon(),

        // 用户标签
        if (widget.style.showUserLabel) _buildUserLabel(),
      ],
    );
  }

  Widget _buildCursorIcon() {
    return CustomPaint(
      size: Size(widget.style.size, widget.style.size),
      painter: CursorPainter(
        color: widget.cursor.userColor,
        size: widget.style.size,
      ),
    );
  }

  Widget _buildUserLabel() {
    return Container(
      margin: const EdgeInsets.only(top: 4, left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.cursor.userColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        widget.cursor.userDisplayName,
        style: TextStyle(
          color: widget.style.labelTextColor,
          fontSize: widget.style.labelFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 指针绘制器
class CursorPainter extends CustomPainter {
  final Color color;
  final double size;

  CursorPainter({required this.color, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 绘制指针形状（类似鼠标指针）
    final path = Path();

    // 指针主体
    path.moveTo(0, 0);
    path.lineTo(0, size * 0.8);
    path.lineTo(size * 0.3, size * 0.6);
    path.lineTo(size * 0.45, size * 0.65);
    path.lineTo(size * 0.65, size * 0.9);
    path.lineTo(size * 0.75, size * 0.85);
    path.lineTo(size * 0.55, size * 0.6);
    path.lineTo(size * 0.7, size * 0.55);
    path.lineTo(size * 0.5, size * 0.4);
    path.close();

    // 绘制指针
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);

    // 绘制指针尖端高亮
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(0, 0);
    highlightPath.lineTo(size * 0.15, size * 0.4);
    highlightPath.lineTo(size * 0.4, size * 0.15);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(CursorPainter oldDelegate) {
    return color != oldDelegate.color || size != oldDelegate.size;
  }
}

/// 用户指针列表组件
/// 显示所有在线用户的指针状态
class UserCursorsList extends StatelessWidget {
  final List<UserCursorState> cursors;
  final UserCursorStyle? style;
  final VoidCallback? onTap;

  const UserCursorsList({
    super.key,
    required this.cursors,
    this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (cursors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '在线用户 (${cursors.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          ...cursors.map((cursor) => _buildCursorItem(cursor)),
        ],
      ),
    );
  }

  Widget _buildCursorItem(UserCursorState cursor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 用户颜色指示器
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: cursor.userColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
          const SizedBox(width: 6),

          // 用户名
          Text(
            cursor.userDisplayName,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),

          // 可见状态指示器
          if (cursor.isVisible) ...[
            const SizedBox(width: 4),
            Icon(Icons.visibility, size: 12, color: Colors.green.shade300),
          ],
        ],
      ),
    );
  }
}
