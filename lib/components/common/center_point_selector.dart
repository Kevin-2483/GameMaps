import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import '../../models/legend_item.dart';

class CenterPointSelector extends StatefulWidget {
  final Uint8List imageData;
  final LegendFileType fileType;
  final double initialX;
  final double initialY;
  final Function(double x, double y) onCenterChanged;

  const CenterPointSelector({
    super.key,
    required this.imageData,
    required this.fileType,
    required this.initialX,
    required this.initialY,
    required this.onCenterChanged,
  });

  @override
  State<CenterPointSelector> createState() => _CenterPointSelectorState();
}

class _CenterPointSelectorState extends State<CenterPointSelector> {
  late double _centerX;
  late double _centerY;

  @override
  void initState() {
    super.initState();
    _centerX = widget.initialX;
    _centerY = widget.initialY;
  }

  void _updateCenter(double x, double y) {
    setState(() {
      _centerX = x.clamp(0.0, 1.0);
      _centerY = y.clamp(0.0, 1.0);
    });
    widget.onCenterChanged(_centerX, _centerY);
  }

  Widget _buildImageWidget() {
    switch (widget.fileType) {
      case LegendFileType.svg:
        try {
          return ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSvgHttpUrl(
              Uri.dataFromBytes(widget.imageData, mimeType: 'image/svg+xml'),
            ),
            fit: BoxFit.contain,
          );
        } catch (e) {
          return Container(
            color: Colors.grey[200],
            child: const Center(child: Icon(Icons.error, color: Colors.red)),
          );
        }
      case LegendFileType.png:
      case LegendFileType.jpg:
      case LegendFileType.jpeg:
        return Image.memory(
          widget.imageData,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.error, color: Colors.red)),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 图片预览区域
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // 图片
                Positioned.fill(child: _buildImageWidget()),
                // 中心点指示器
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: (details) {
                      final RenderBox box =
                          context.findRenderObject() as RenderBox;
                      final localPosition = box.globalToLocal(
                        details.globalPosition,
                      );
                      final x = localPosition.dx / box.size.width;
                      final y = localPosition.dy / box.size.height;
                      _updateCenter(x, y);
                    },
                    child: CustomPaint(
                      painter: CenterPointPainter(_centerX, _centerY),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 滑杆控制
        Column(
          children: [
            Row(
              children: [
                const Text('X轴: '),
                Expanded(
                  child: Slider(
                    value: _centerX,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: '${(_centerX * 100).round()}%',
                    onChanged: (value) => _updateCenter(value, _centerY),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text('${(_centerX * 100).round()}%'),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Y轴: '),
                Expanded(
                  child: Slider(
                    value: _centerY,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: '${(_centerY * 100).round()}%',
                    onChanged: (value) => _updateCenter(_centerX, value),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text('${(_centerY * 100).round()}%'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class CenterPointPainter extends CustomPainter {
  final double centerX;
  final double centerY;

  CenterPointPainter(this.centerX, this.centerY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(centerX * size.width, centerY * size.height);
    const radius = 10.0;

    // 绘制十字线
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    // 绘制圆圈
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CenterPointPainter oldDelegate) {
    return oldDelegate.centerX != centerX || oldDelegate.centerY != centerY;
  }
}
