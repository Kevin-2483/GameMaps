// drawing_utils.dart - 绘制工具函数库
// 从 map_canvas.dart 中提取的通用绘制工具函数

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../../models/map_layer.dart';

/// ================= 路径创建工具函数 =================

/// 创建三角形裁剪路径
Path createTrianglePath(Rect rect, TriangleCutType triangleCut) {
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
Path createSuperellipsePath(Rect rect, double curvature) {
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

  // 使用三段式插值逻辑
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

/// 获取最终的橡皮擦路径（结合曲率和三角形切割）
Path getFinalEraserPath(
  Rect rect,
  double curvature,
  TriangleCutType triangleCut,
) {
  Path curvedPath = createSuperellipsePath(rect, curvature);

  if (triangleCut == TriangleCutType.none) {
    return curvedPath;
  }
  Path triangleAreaPath = createTrianglePath(rect, triangleCut);

  // 返回两个路径的交集
  return Path.combine(PathOperation.intersect, curvedPath, triangleAreaPath);
}

/// ================= 基础绘制工具函数 =================

/// 绘制弧度矩形（从圆角矩形到椭圆的渐变）
void drawCurvedRectangle(
  Canvas canvas,
  Rect rect,
  Paint paint,
  double curvature,
) {
  final Path path = createSuperellipsePath(rect, curvature);
  canvas.drawPath(path, paint);
}

/// 绘制带三角形切割的弧度路径
void drawCurvedTrianglePath(
  Canvas canvas,
  Rect rect,
  Paint paint,
  double curvature,
  TriangleCutType triangleCut,
) {
  final Path path = getFinalEraserPath(rect, curvature, triangleCut);
  canvas.drawPath(path, paint);
}

/// 绘制箭头
void drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
  // Draw main line
  canvas.drawLine(start, end, paint);

  // Draw arrowhead
  const arrowLength = 10.0;
  const arrowAngle = 0.5;

  final direction = (end - start).direction;
  final arrowPoint1 = end +
      Offset(
        arrowLength * -1 * math.cos(direction - arrowAngle),
        arrowLength * -1 * math.sin(direction - arrowAngle),
      );
  final arrowPoint2 = end +
      Offset(
        arrowLength * -1 * math.cos(direction + arrowAngle),
        arrowLength * -1 * math.sin(direction + arrowAngle),
      );

  canvas.drawLine(end, arrowPoint1, paint);
  canvas.drawLine(end, arrowPoint2, paint);
}

/// 绘制虚线
void drawDashedLine(
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

/// 绘制对角线图案
void drawDiagonalPattern(
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

/// 绘制十字线图案
void drawCrossPattern(
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

/// 绘制点阵图案
void drawDotGrid(
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

/// ================= 高级绘制工具函数（带曲率支持）=================

/// 绘制弧度对角线图案
void drawCurvedDiagonalPattern(
  Canvas canvas,
  Rect rect,
  Paint paint,
  double density,
  double curvature,
) {
  // 创建超椭圆路径作为裁剪区域
  final clipPath = createSuperellipsePath(rect, curvature);

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
void drawCurvedCrossPattern(
  Canvas canvas,
  Rect rect,
  Paint paint,
  double density,
  double curvature,
) {
  // 创建超椭圆路径作为裁剪区域
  final clipPath = createSuperellipsePath(rect, curvature);

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
void drawCurvedDotGrid(
  Canvas canvas,
  Rect rect,
  Paint paint,
  double density,
  double curvature,
) {
  // 创建超椭圆路径作为裁剪区域
  final clipPath = createSuperellipsePath(rect, curvature);

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

/// ================= 虚线绘制工具函数 =================

/// 绘制虚线矩形
void drawDashedRect(
  Canvas canvas,
  Rect rect,
  Paint paint,
  double dashWidth, [
  double? dashSpace,
]) {
  final actualDashSpace = dashSpace ?? dashWidth * 0.6;
  
  final path = Path();

  // 顶边
  addDashedLine(path, rect.topLeft, rect.topRight, dashWidth, actualDashSpace);
  // 右边
  addDashedLine(path, rect.topRight, rect.bottomRight, dashWidth, actualDashSpace);
  // 底边
  addDashedLine(path, rect.bottomRight, rect.bottomLeft, dashWidth, actualDashSpace);
  // 左边
  addDashedLine(path, rect.bottomLeft, rect.topLeft, dashWidth, actualDashSpace);

  canvas.drawPath(path, paint);
}

/// 向路径添加虚线段
void addDashedLine(
  Path path,
  Offset start,
  Offset end,
  double dashWidth,
  double dashSpace,
) {
  final distance = (end - start).distance;
  final unitVector = (end - start) / distance;

  double currentDistance = 0.0;
  bool isDash = true;

  while (currentDistance < distance) {
    final segmentLength = isDash ? dashWidth : dashSpace;
    final segmentEnd = currentDistance + segmentLength > distance
        ? distance
        : currentDistance + segmentLength;

    if (isDash) {
      final segmentStart = start + unitVector * currentDistance;
      final segmentEndPoint = start + unitVector * segmentEnd;
      
      path.moveTo(segmentStart.dx, segmentStart.dy);
      path.lineTo(segmentEndPoint.dx, segmentEndPoint.dy);
    }

    currentDistance = segmentEnd;
    isDash = !isDash;
  }
}

/// ================= 碰撞检测工具函数 =================

/// 检查点是否在橡皮擦形状内（可以是矩形、超椭圆或标准椭圆）
bool isPointInEraserShape(Offset point, Rect eraserRect, double curvature) {
  // 1. 处理曲率为0或负数的情况（矩形）
  if (curvature <= 0.0) {
    return eraserRect.contains(point);
  }

  // 2. 限制弧度值在合理范围内 (0.0 到 1.0)
  final clampedCurvature = curvature.clamp(0.0, 1.0);

  // 如果限制后的曲率仍然是0或以下，则按矩形处理
  if (clampedCurvature <= 0.0) {
    return eraserRect.contains(point);
  }

  final center = eraserRect.center;
  final a = eraserRect.width / 2; // 半宽
  final b = eraserRect.height / 2; // 半高

  // 3. 根据 clampedCurvature 确定 n 值和是否使用标准椭圆
  double n;
  bool useStandardEllipse = false;

  if (clampedCurvature <= 0.3) {
    // 圆角矩形阶段 (超椭圆)
    final t = clampedCurvature / 0.3;
    n = 8.0 - (t * 4.0); // n 从 8.0 变化到 4.0
  } else if (clampedCurvature <= 0.7) {
    // 过渡阶段 (超椭圆)
    final t = (clampedCurvature - 0.3) / 0.4;
    n = 4.0 - (t * 1.8); // n 从 4.0 变化到 2.2
  } else {
    // 椭圆阶段：使用标准椭圆方程
    useStandardEllipse = true;
    n = 2.0; // 标准椭圆
  }

  // 4. 检查点是否在形状内
  final dx = (point.dx - center.dx).abs();
  final dy = (point.dy - center.dy).abs();

  if (useStandardEllipse) {
    // 标准椭圆方程: (x/a)² + (y/b)² <= 1
    return (dx * dx) / (a * a) + (dy * dy) / (b * b) <= 1.0;
  } else {
    // 超椭圆方程: (|x|/a)^n + (|y|/b)^n <= 1
    final termX = dx / a;
    final termY = dy / b;
    return math.pow(termX, n) + math.pow(termY, n) <= 1.0;
  }
}

/// 检查点是否在最终橡皮擦形状内（结合曲率和三角形切割）
bool isPointInFinalEraserShape(
  Offset point,
  Rect eraserRect,
  double curvature,
  TriangleCutType triangleCut,
) {
  // 1. 首先检查点是否在由 curvature 定义的基础形状内
  if (!isPointInEraserShape(point, eraserRect, curvature)) {
    return false; // 如果不在基础形状内，则肯定不在最终切割后的形状内
  }

  // 2. 如果没有对角线切割，则点在基础形状内即为在最终形状内
  if (triangleCut == TriangleCutType.none) {
    return true;
  }

  // 3. 如果有对角线切割，则还需要检查点是否在三角形区域内
  Path triangleAreaPath = createTrianglePath(eraserRect, triangleCut);
  return triangleAreaPath.contains(point); // 使用 Path.contains() 判断
}

/// 检查绘制元素类型是否支持三角形切割
bool isTriangleCutApplicable(DrawingElementType type) {
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

/// ================= 自由绘制工具函数 =================

/// 绘制自由绘制路径
void drawFreeDrawingPath(
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

/// ================= 文本绘制工具函数 =================

/// 绘制文本元素
void drawText(Canvas canvas, MapDrawingElement element, Size size) {
  if (element.text == null || element.text!.isEmpty || element.points.isEmpty) {
    return;
  }

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

/// ================= 图片占位符绘制工具函数 =================

/// 绘制图片占位符
void drawImageEmptyPlaceholder(Canvas canvas, Rect rect, BoxFit fit) {
  // 背景色
  final backgroundPaint = Paint()
    ..color = Colors.grey.shade100
    ..style = PaintingStyle.fill;
  canvas.drawRect(rect, backgroundPaint);

  // 边框
  final borderPaint = Paint()
    ..color = Colors.grey.shade300
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  // 绘制虚线矩形
  drawDashedRect(canvas, rect, borderPaint, 5.0);

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

/// ================= BoxFit 工具函数 =================

/// 获取 BoxFit 的显示名称
String getBoxFitDisplayName(BoxFit boxFit) {
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
