import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 高级颜色选择器对话框，支持RGB轮盘和透明度滑条
class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final String title;
  final bool enableAlpha;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    this.title = '选择颜色',
    this.enableAlpha = false,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late HSVColor _currentHsv;
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentHsv = HSVColor.fromColor(widget.initialColor);
    _currentColor = widget.initialColor;
  }

  void _updateColor(HSVColor hsv) {
    setState(() {
      _currentHsv = hsv;
      _currentColor = hsv.toColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 颜色轮盘
            SizedBox(
              width: 280,
              height: 280,
              child: ColorWheel(
                hsv: _currentHsv,
                onChanged: _updateColor,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 亮度滑条
            _buildSlider(
              '亮度',
              _currentHsv.value,
              (value) => _updateColor(_currentHsv.withValue(value)),
              Colors.black,
              _currentHsv.withValue(1.0).toColor(),
            ),
            
            const SizedBox(height: 12),
            
            // 饱和度滑条
            _buildSlider(
              '饱和度',
              _currentHsv.saturation,
              (value) => _updateColor(_currentHsv.withSaturation(value)),
              Colors.white,
              _currentHsv.withSaturation(1.0).toColor(),
            ),
            
            // 透明度滑条（如果启用）
            if (widget.enableAlpha) ...[
              const SizedBox(height: 12),
              _buildSlider(
                '透明度',
                _currentHsv.alpha,
                (value) => _updateColor(_currentHsv.withAlpha(value)),
                Colors.transparent,
                _currentColor.withOpacity(1.0),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // 当前颜色预览
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '#${_currentColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                  style: TextStyle(
                    color: _currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // RGB值显示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorValue('R', _currentColor.red),
                _buildColorValue('G', _currentColor.green),
                _buildColorValue('B', _currentColor.blue),
                if (widget.enableAlpha)
                  _buildColorValue('A', _currentColor.alpha),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_currentColor),
          child: const Text('确定'),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
    Color startColor,
    Color endColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${(value * 100).round()}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [startColor, endColor],
            ),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 20,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0.0,
              max: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorValue(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// 颜色轮盘组件
class ColorWheel extends StatefulWidget {
  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  const ColorWheel({
    super.key,
    required this.hsv,
    required this.onChanged,
  });

  @override
  State<ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends State<ColorWheel> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onTapDown: _handleTapDown,
      child: CustomPaint(
        size: const Size(280, 280),
        painter: ColorWheelPainter(widget.hsv),
      ),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _updateColorFromPosition(details.localPosition);
  }

  void _handleTapDown(TapDownDetails details) {
    _updateColorFromPosition(details.localPosition);
  }

  void _updateColorFromPosition(Offset position) {
    final center = const Offset(140, 140);
    final offset = position - center;
    final distance = offset.distance;
    final radius = 130.0;

    if (distance <= radius) {
      final angle = math.atan2(offset.dy, offset.dx);
      final hue = (angle * 180 / math.pi + 360) % 360;
      final saturation = (distance / radius).clamp(0.0, 1.0);

      final newHsv = widget.hsv.withHue(hue).withSaturation(saturation);
      widget.onChanged(newHsv);
    }
  }
}

/// 颜色轮盘绘制器
class ColorWheelPainter extends CustomPainter {
  final HSVColor hsv;

  ColorWheelPainter(this.hsv);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // 绘制颜色轮盘
    for (int i = 0; i < 360; i++) {
      final hue = i.toDouble();
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      final startAngle = (i - 1) * math.pi / 180;
      final endAngle = (i + 1) * math.pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        true,
        paint,
      );
    }

    // 绘制选择器指示器
    final selectedAngle = hsv.hue * math.pi / 180;
    final selectedRadius = hsv.saturation * radius;
    final selectedPosition = Offset(
      center.dx + selectedRadius * math.cos(selectedAngle),
      center.dy + selectedRadius * math.sin(selectedAngle),
    );

    // 外圈指示器
    final indicatorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(selectedPosition, 8, indicatorPaint);

    // 内圈指示器
    final innerIndicatorPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(selectedPosition, 6, innerIndicatorPaint);
  }

  @override
  bool shouldRepaint(covariant ColorWheelPainter oldDelegate) {
    return oldDelegate.hsv != hsv;
  }
}

/// 静态方法，用于显示颜色选择器对话框
class ColorPicker {
  /// 显示颜色选择器对话框
  static Future<Color?> showColorPicker({
    required BuildContext context,
    required Color initialColor,
    String title = '选择颜色',
    bool enableAlpha = false,
  }) async {
    return await showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: initialColor,
        title: title,
        enableAlpha: enableAlpha,
      ),
    );
  }
}
