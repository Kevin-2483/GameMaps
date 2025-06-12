import 'package:flutter/material.dart';
import '../../../models/user_preferences.dart';
import '../utils/drawing_utils.dart';

/// 背景渲染器 - 负责绘制画布背景图案
class BackgroundRenderer {
  /// 绘制背景图案
  static void drawBackgroundPattern(
    Canvas canvas,
    Size size,
    BackgroundPattern pattern,
  ) {
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

  /// 绘制网格背景
  static void _drawGrid(Canvas canvas, Size size) {
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

  /// 绘制棋盘格背景
  static void _drawCheckerboard(Canvas canvas, Size size) {
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

  /// 绘制选区矩形
  static void drawSelection(Canvas canvas, Rect selectionRect) {
    // 选区半透明填充
    final selectionFillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRect(selectionRect, selectionFillPaint);

    // 选区边框（虚线效果）
    final selectionBorderPaint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 绘制虚线边框
    _drawDashedRect(canvas, selectionRect, selectionBorderPaint);
  }

  /// 绘制虚线矩形
  static void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const double dashLength = 8.0;
    const double gapLength = 4.0;

    // 绘制上边
    _drawDashedLine(
      canvas,
      rect.topLeft,
      rect.topRight,
      paint,
      dashLength,
      gapLength,
    );
    // 绘制右边
    _drawDashedLine(
      canvas,
      rect.topRight,
      rect.bottomRight,
      paint,
      dashLength,
      gapLength,
    );
    // 绘制下边
    _drawDashedLine(
      canvas,
      rect.bottomRight,
      rect.bottomLeft,
      paint,
      dashLength,
      gapLength,
    );
    // 绘制左边
    _drawDashedLine(
      canvas,
      rect.bottomLeft,
      rect.topLeft,
      paint,
      dashLength,
      gapLength,
    );
  }

  /// 绘制虚线
  static void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashLength,
    double gapLength,
  ) {
    final double distance = (end - start).distance;
    final Offset direction = (end - start) / distance;

    double currentDistance = 0;
    bool shouldDraw = true;

    while (currentDistance < distance) {
      final double segmentLength = shouldDraw ? dashLength : gapLength;
      final double nextDistance = (currentDistance + segmentLength).clamp(
        0.0,
        distance,
      );

      if (shouldDraw) {
        final Offset segmentStart = start + direction * currentDistance;
        final Offset segmentEnd = start + direction * nextDistance;
        canvas.drawLine(segmentStart, segmentEnd, paint);
      }

      currentDistance = nextDistance;
      shouldDraw = !shouldDraw;
    }
  }
}

/// 选区渲染器 - 负责绘制选择区域
class SelectionRenderer {
  /// 绘制选区边框
  static void drawSelection(Canvas canvas, Rect? selectionRect) {
    if (selectionRect == null) return;

    // 绘制选区边框
    final borderPaint = Paint()
      ..color = Colors.blue.withAlpha((0.8 * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 绘制虚线边框
    drawDashedRect(canvas, selectionRect, borderPaint, 5.0, 3.0);
  }
}
