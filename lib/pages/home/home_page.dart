import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../components/layout/main_layout.dart'; // 请确保这个路径是正确的

/*
🌊 波纹背景效果自定义指南

📋 快速调整参数列表:

🚀 动画速度:
  - 第31行: Duration(seconds: 12) → 修改数值调整波纹速度

📍 波纹中心位置:
  - 第93-94行: size.width * 0.8, size.height * 0.8 → 修改系数调整位置
  - 0.0 = 左/上边缘, 0.5 = 中心, 1.0 = 右/下边缘

🎨 背景颜色:
  - 第99-106行: colors 数组 → 修改颜色值调整背景渐变

🌊 波纹层数和颜色:
  - 第120-122行: _drawRippleLayer 调用 → 添加/删除/修改波纹层

🔄 波纹密度:
  - 第132行: rippleCount = 2 → 修改数值调整每层波纹数量

⏱️ 波纹间隔:
  - 第142行: (i * 0.5) → 修改系数调整波纹间距

📏 波纹扩散距离:
  - 第149行: maxRadius * 2.2 → 修改倍数调整扩散范围

🖌️ 波纹线条粗细:
  - 第170行: 3.0 和 0.5 → 修改数值调整线条宽度

💡 中心发光大小:
  - 第191行: 20 和 * 5 → 修改数值调整发光半径

🌟 发光亮度:
  - 第199行: 0.6 和 0.2 → 修改数值调整发光强度

🎯 中心点大小:
  - 第229行: 3 → 修改数值调整中心亮点大小

🗺️ 地图标记图标大小:
  - 第241行: * 0.75 → 修改系数调整图标大小 (0.8 = 更大, 0.6 = 更小)

🎨 地图标记图标颜色:
  - 第245行: iconOpacity → 修改图标透明度和呼吸效果

📸 透视背景图片控制:

🎬 图片轮播速度:
  - Duration(seconds: 20): 每张图片显示时长 (数值越小 = 切换越快)

🎭 透视角度范围:
  - _initializeBackgroundParams() 中的 60: 最大倾斜角度 (度数)

🔍 摄像机缩放 (图片大小):
  - PerspectiveBackgroundPainter 中的 cameraZoom = 2.0
  - 1.0 = 原始大小, 2.0 = 放大2倍, 0.5 = 缩小一半

🌐 图片覆盖扩展:
  - expansionFactor = 1.8: 防止透视变换露出空白的扩展倍数

🎯 透视强度:
  - perspective.setEntry(3, 2, -0.001): 透视效果强度 (绝对值越大越明显)

💡 使用示例:
  - 让波纹更快: Duration(seconds: 8)
  - 移到左上角: size.width * 0.2, size.height * 0.2  
  - 更密集波纹: rippleCount = 4
  - 更大扩散: maxRadius * 3.0
  - 更快图片切换: Duration(seconds: 10)
  - 更强透视效果: -0.002
  - 更大图片缩放: cameraZoom = 3.0
*/

class HomePage extends BasePage {
  const HomePage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _HomePageContent();
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  // 背景图片控制
  List<String> _imagePaths = [];
  int _currentImageIndex = 0;
  late ImageProvider _currentImageProvider;
  ui.Image? _currentResolvedImage;
  bool _imageLoaded = false;

  // 透视变换参数
  late double _perspectiveAngleX;
  late double _perspectiveAngleY;
  late Offset _cameraStart;
  late Offset _cameraEnd;

  @override
  void initState() {
    super.initState();

    // 初始化图片路径
    _imagePaths = [
      'assets/images/1.png',
      'assets/images/2.png',
      'assets/images/3.png',
      'assets/images/4.png',
      'assets/images/5.png',
    ];

    // 波纹动画控制器 - 调整动画速度
    _rippleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.linear,
    ));

    // 📹 背景图片动画控制器 - 控制摄像机移动和图片切换
    // 🚀 摄像机移动速度调整:
    // - Duration(seconds: 60): 更慢、更平滑的移动速度
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30), // 使用更长的动画时间
      vsync: this,
    );
    // 🎛️ 渐变速度控制
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    // 初始化背景参数
    _initializeBackgroundParams();
    _loadCurrentImage();

    _rippleController.repeat();

    // 🎬 开始第一次背景动画
    _backgroundController.forward();

    // ✅ 【优化】不再需要 addListener 来调用 setState
    // 动画的更新将完全由 AnimatedBuilder 处理

    // 监听动画状态，在每次动画结束时切换到下一张图片
    _backgroundController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _switchToNextImage();
        _backgroundController.reset(); // 重置动画控制器
        _backgroundController.forward(); // 重新开始动画
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景图片层 - 具有透视变换效果
          if (_imageLoaded && _currentResolvedImage != null)
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                // ✅ 【优化】在此处直接计算当前帧的摄像机位置
                // 这将动画更新的范围限制在此构建器内，从而获得最佳性能
                final currentCameraPosition = Offset.lerp(
                  _cameraStart,
                  _cameraEnd,
                  _backgroundAnimation.value,
                )!;

                return CustomPaint(
                  painter: PerspectiveBackgroundPainter(
                    image: _currentResolvedImage,
                    cameraPosition: currentCameraPosition, // 使用最新计算的位置
                    perspectiveAngleX: _perspectiveAngleX,
                    perspectiveAngleY: _perspectiveAngleY,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          // 动态波纹层
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: RippleBackgroundPainter(
                  _rippleAnimation.value,
                  Theme.of(context).colorScheme,
                ),
                size: Size.infinite,
              );
            },
          ),
          // 内容层
          Container(),
        ],
      ),
    );
  }

  // 📍 初始化背景参数
  void _initializeBackgroundParams() {
    final random = math.Random();

    // 🎭 透视角度设置 (控制图片倾斜程度) - 每次随机化
    _perspectiveAngleX = (random.nextDouble() - 0.5) * 60 * math.pi / 180;
    _perspectiveAngleY = (random.nextDouble() - 0.5) * 60 * math.pi / 180;

    // 🎯 摄像机移动路径设置
    final startEdge = random.nextInt(4);

    switch (startEdge) {
      case 0: // 从左边开始
        _cameraStart = Offset(
          0.05 + random.nextDouble() * 0.1,
          0.1 + random.nextDouble() * 0.8,
        );
        _cameraEnd = Offset(
          0.85 + random.nextDouble() * 0.1,
          0.1 + random.nextDouble() * 0.8,
        );
        break;
      case 1: // 从上边开始
        _cameraStart = Offset(
          0.1 + random.nextDouble() * 0.8,
          0.05 + random.nextDouble() * 0.1,
        );
        _cameraEnd = Offset(
          0.1 + random.nextDouble() * 0.8,
          0.85 + random.nextDouble() * 0.1,
        );
        break;
      case 2: // 从右边开始
        _cameraStart = Offset(
          0.85 + random.nextDouble() * 0.1,
          0.1 + random.nextDouble() * 0.8,
        );
        _cameraEnd = Offset(
          0.05 + random.nextDouble() * 0.1,
          0.1 + random.nextDouble() * 0.8,
        );
        break;
      case 3: // 从下边开始
        _cameraStart = Offset(
          0.1 + random.nextDouble() * 0.8,
          0.85 + random.nextDouble() * 0.1,
        );
        _cameraEnd = Offset(
          0.1 + random.nextDouble() * 0.8,
          0.05 + random.nextDouble() * 0.1,
        );
        break;
    }

    if (random.nextBool()) {
      switch (startEdge) {
        case 0: _cameraEnd = Offset(0.9, 0.9); break;
        case 1: _cameraEnd = Offset(0.9, 0.9); break;
        case 2: _cameraEnd = Offset(0.1, 0.1); break;
        case 3: _cameraEnd = Offset(0.1, 0.1); break;
      }
    }
    
    // ✅ 【优化】不再需要 _currentCameraPosition 状态变量
    // _currentCameraPosition = _cameraStart;

    print('🎬 新的摄像机路径: $_cameraStart -> $_cameraEnd');
    print('📐 透视角度: X=${(_perspectiveAngleX * 180 / math.pi).toStringAsFixed(1)}°, Y=${(_perspectiveAngleY * 180 / math.pi).toStringAsFixed(1)}°');
  }

  // 加载当前图片
  void _loadCurrentImage() {
    _currentImageProvider = AssetImage(_imagePaths[_currentImageIndex]);

    _currentImageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        if (mounted) {
          setState(() {
            _currentResolvedImage = info.image;
            _imageLoaded = true;
          });
        }
      }),
    );
  }
  
  // ✅ 【优化】此方法不再需要，逻辑已移入 AnimatedBuilder
  /*
  void _updateCameraPosition() {
    _currentCameraPosition = Offset.lerp(
      _cameraStart,
      _cameraEnd,
      _backgroundAnimation.value,
    )!;
  }
  */

  // 🔄 切换到下一张图片
  void _switchToNextImage() {
    _currentImageIndex = (_currentImageIndex + 1) % _imagePaths.length;

    print('🖼️ 切换到图片 ${_currentImageIndex + 1}/${_imagePaths.length}: ${_imagePaths[_currentImageIndex]}');

    _initializeBackgroundParams();

    setState(() {
      _imageLoaded = false;
    });
    _loadCurrentImage();
  }
}

/// 波纹背景绘制器
class RippleBackgroundPainter extends CustomPainter {
  final double rippleValue;
  final ColorScheme colorScheme;

  RippleBackgroundPainter(this.rippleValue, this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width * 0.8,
      size.height * 0.9,
    );
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2;

    _drawRippleLayer(canvas, center, maxRadius, 0, 1.0, colorScheme.primary);
    _drawCenterGlow(canvas, center, maxRadius);
    _drawMapMarkerIcon(canvas, center, size);
  }

  void _drawRippleLayer(Canvas canvas, Offset center, double maxRadius, double phaseOffset, double baseOpacity, Color color) {
    const int rippleCount = 5;

    for (int i = 0; i < rippleCount; i++) {
      final progress = (rippleValue + phaseOffset + (i * 0.2)) % 1.0;
      final radius = progress * maxRadius * 2.2;

      if (radius > 10) {
        final fadeOut = math.pow(1.0 - (radius / (maxRadius * 2.2)), 1.5);
        final opacity = (fadeOut * (1.0 - progress * 0.3)).clamp(0.0, 1.0);

        if (opacity > 0.02) {
          final finalColor = color.withOpacity(opacity);
          final paint = Paint()
            ..color = finalColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = (2.0 * (1.0 - progress) + 0.5).clamp(0.5, 3.0);
          canvas.drawCircle(center, radius, paint);
        }
      }
    }
  }

  void _drawCenterGlow(Canvas canvas, Offset center, double maxRadius) {
    final glowRadius = 20 + math.sin(rippleValue * math.pi * 4) * 5;
    final glowOpacity = 0.6 + math.sin(rippleValue * math.pi * 6) * 0.2;

    final glowGradient = RadialGradient(
      radius: 0.5,
      colors: [
        colorScheme.primary.withOpacity(glowOpacity),
        colorScheme.primary.withOpacity(glowOpacity * 0.5),
        Colors.transparent,
      ],
    );

    final glowPaint = Paint()
      ..shader = glowGradient.createShader(
        Rect.fromCircle(center: center, radius: glowRadius),
      );
    canvas.drawCircle(center, glowRadius, glowPaint);

    final centerPaint = Paint()
      ..color = colorScheme.primary.withOpacity(glowOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, centerPaint);
  }

  void _drawMapMarkerIcon(Canvas canvas, Offset center, Size size) {
    final iconSize = size.height * 0.9;
    final iconColor = colorScheme.primary;

    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    final circleRadius = iconSize * 0.3;
    final triangleHeight = iconSize * 0.25;
    final circleCenter = Offset(
        center.dx,
        center.dy - triangleHeight - circleRadius
    );

    canvas.drawCircle(circleCenter, circleRadius, paint);

    final r = circleRadius;
    final d = center.dy - circleCenter.dy;
    final tangentY = circleCenter.dy + (r * r) / d;
    final yOffsetFromCircleCenter = tangentY - circleCenter.dy;
    final xOffsetFromCircleCenter = math.sqrt((r * r) - (yOffsetFromCircleCenter * yOffsetFromCircleCenter));
    final leftTangentPoint = Offset(circleCenter.dx - xOffsetFromCircleCenter, tangentY);
    final rightTangentPoint = Offset(circleCenter.dx + xOffsetFromCircleCenter, tangentY);

    final path = Path();
    path.moveTo(leftTangentPoint.dx, leftTangentPoint.dy);
    path.lineTo(center.dx, center.dy);
    path.lineTo(rightTangentPoint.dx, rightTangentPoint.dy);
    path.close();
    canvas.drawPath(path, paint);

    final innerCirclePaint = Paint()
      ..color = colorScheme.surface
      ..style = PaintingStyle.fill;
    final innerCircleRadius = circleRadius * 0.4;
    canvas.drawCircle(circleCenter, innerCircleRadius, innerCirclePaint);

    final borderPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = iconSize * 0.008;
    canvas.drawCircle(circleCenter, circleRadius, borderPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(RippleBackgroundPainter oldDelegate) {
    return oldDelegate.rippleValue != rippleValue;
  }
}

/// 透视背景图片绘制器
class PerspectiveBackgroundPainter extends CustomPainter {
  final ui.Image? image;
  final Offset cameraPosition;
  final double perspectiveAngleX;
  final double perspectiveAngleY;

  PerspectiveBackgroundPainter({
    required this.image,
    required this.cameraPosition,
    required this.perspectiveAngleX,
    required this.perspectiveAngleY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) {
      return;
    }

    canvas.save();

    const double expansionFactor = 1.8;
    final expandedSize = Size(
      size.width * expansionFactor,
      size.height * expansionFactor,
    );
    final offsetX = -(expandedSize.width - size.width) / 2;
    final offsetY = -(expandedSize.height - size.height) / 2;

    _applyPerspectiveTransform(canvas, size);

    final imageSize = Size(image!.width.toDouble(), image!.height.toDouble());
    final scaleX = expandedSize.width / imageSize.width;
    final scaleY = expandedSize.height / imageSize.height;
    final baseScale = math.max(scaleX, scaleY);

    const double cameraZoom = 2.0;
    final finalScale = baseScale * cameraZoom;
    final finalImageSize = Size(
      imageSize.width * finalScale,
      imageSize.height * finalScale,
    );

    final imageX = offsetX + (expandedSize.width - finalImageSize.width) * cameraPosition.dx;
    final imageY = offsetY + (expandedSize.height - finalImageSize.height) * cameraPosition.dy;

    final srcRect = Rect.fromLTWH(0, 0, imageSize.width, imageSize.height);
    final destRect = Rect.fromLTWH(imageX, imageY, finalImageSize.width, finalImageSize.height);

    canvas.drawImageRect(image!, srcRect, destRect, Paint());

    canvas.restore();
  }

  void _applyPerspectiveTransform(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    final Matrix4 perspective = Matrix4.identity();
    perspective.setEntry(3, 2, -0.001);
    perspective.rotateX(perspectiveAngleX);
    perspective.rotateY(perspectiveAngleY);

    canvas.transform(perspective.storage);

    canvas.translate(-size.width / 2, -size.height / 2);
  }

  @override
  bool shouldRepaint(PerspectiveBackgroundPainter oldDelegate) {
    return oldDelegate.cameraPosition != cameraPosition ||
        oldDelegate.perspectiveAngleX != perspectiveAngleX ||
        oldDelegate.perspectiveAngleY != perspectiveAngleY ||
        oldDelegate.image != image;
  }
}