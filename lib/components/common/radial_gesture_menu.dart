import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 轮盘手势菜单项
class RadialMenuItem {
  final String id;
  final String label;
  final IconData? icon;
  final Color? color;
  final List<RadialMenuItem>? subItems;
  final VoidCallback? onTap;

  const RadialMenuItem({
    required this.id,
    required this.label,
    this.icon,
    this.color,
    this.subItems,
    this.onTap,
  });
}

/// 轮盘手势菜单组件
class RadialGestureMenu extends StatefulWidget {
  final Widget child;
  final List<RadialMenuItem> menuItems;
  final Function(RadialMenuItem)? onItemSelected;
  final double radius;
  final double centerRadius;
  final bool debugMode;
  final double opacity;
  final Color plateColor;
  final Duration animationDuration;

  const RadialGestureMenu({
    super.key,
    required this.child,
    required this.menuItems,
    this.onItemSelected,
    this.radius = 120.0,
    this.centerRadius = 30.0,
    this.debugMode = false,
    this.opacity = 1.0,
    this.plateColor = const Color(0xFF2C2C2C),
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<RadialGestureMenu> createState() => _RadialGestureMenuState();
}

class _RadialGestureMenuState extends State<RadialGestureMenu>
    with TickerProviderStateMixin {
  bool _isMenuVisible = false;
  Offset? _menuCenter;
  Offset? _currentPointer;
  RadialMenuItem? _hoveredItem;
  List<RadialMenuItem> _currentMenuItems = [];
  bool _isInSubMenu = false;
  RadialMenuItem? _selectedParentItem;

  late AnimationController _mainAnimationController;
  late AnimationController _plateAnimationController;
  late List<AnimationController> _cardAnimationControllers;
  late Animation<double> _plateScaleAnimation;
  late Animation<double> _plateOpacityAnimation;
  late List<Animation<double>> _cardScaleAnimations;
  late List<Animation<double>> _cardOpacityAnimations;

  @override
  void initState() {
    super.initState();
    _currentMenuItems = widget.menuItems;
    
    // 主动画控制器
    _mainAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    // 盘子动画控制器
    _plateAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // 盘子动画
    _plateScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _plateAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _plateOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: widget.opacity,
    ).animate(CurvedAnimation(
      parent: _plateAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _initCardAnimations();
  }
  
  void _initCardAnimations() {
    // 为每个卡片创建动画控制器
    _cardAnimationControllers = List.generate(
      _currentMenuItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    
    // 为每个卡片创建动画
    _cardScaleAnimations = _cardAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();
    
    _cardOpacityAnimations = _cardAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _plateAnimationController.dispose();
    for (final controller in _cardAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showMenu(Offset position) {
    setState(() {
      _isMenuVisible = true;
      _menuCenter = position;
      _currentPointer = position;
      _hoveredItem = null;
      _isInSubMenu = false;
      _selectedParentItem = null;
      _currentMenuItems = widget.menuItems;
    });
    
    // 重新初始化卡片动画
    _disposeCardAnimations();
    _initCardAnimations();
    
    if (widget.debugMode) {
      print('显示菜单于位置: $position');
    }
    
    HapticFeedback.lightImpact();
    
    // 先播放盘子动画
    _plateAnimationController.forward().then((_) {
      // 然后依次播放卡片动画
      _playCardAnimations();
    });
  }

  void _hideMenu() {
    // 同时隐藏所有动画
    _plateAnimationController.reverse();
    for (final controller in _cardAnimationControllers) {
      controller.reverse();
    }
    
    _plateAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() {
          _isMenuVisible = false;
          _menuCenter = null;
          _currentPointer = null;
          _hoveredItem = null;
          _isInSubMenu = false;
          _selectedParentItem = null;
        });
      }
    });
    
    if (widget.debugMode) {
      print('隐藏菜单');
    }
  }
  
  void _disposeCardAnimations() {
    for (final controller in _cardAnimationControllers) {
      controller.dispose();
    }
  }
  
  void _playCardAnimations() async {
    for (int i = 0; i < _cardAnimationControllers.length; i++) {
      // 延迟播放每个卡片动画，创建顺序弹出效果
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted && _isMenuVisible) {
          _cardAnimationControllers[i].forward();
        }
      });
    }
  }

  void _updatePointer(Offset position) {
    if (!_isMenuVisible || _menuCenter == null) return;
    
    setState(() {
      _currentPointer = position;
    });
    
    final distance = (position - _menuCenter!).distance;
    
    // 如果在中心区域，返回主菜单
    if (distance < widget.centerRadius) {
      if (_isInSubMenu) {
        // 先隐藏当前卡片
        for (final controller in _cardAnimationControllers) {
          controller.reverse();
        }
        
        // 等待动画完成后返回主菜单
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _currentMenuItems = widget.menuItems;
              _isInSubMenu = false;
              _selectedParentItem = null;
              _hoveredItem = null;
            });
            
            // 重新初始化并播放卡片动画
            _disposeCardAnimations();
            _initCardAnimations();
            _playCardAnimations();
            
            if (widget.debugMode) {
              print('返回主菜单');
            }
          }
        });
      }
      return;
    }
    
    // 计算角度
    final angle = math.atan2(
      position.dy - _menuCenter!.dy,
      position.dx - _menuCenter!.dx,
    );
    
    // 转换为0-2π范围
    final normalizedAngle = (angle + 2 * math.pi) % (2 * math.pi);
    
    // 计算选中的项目
    final itemCount = _currentMenuItems.length;
    if (itemCount == 0) return;
    
    final sectorAngle = 2 * math.pi / itemCount;
    final adjustedAngle = (normalizedAngle + math.pi / 2) % (2 * math.pi);
    final selectedIndex = (adjustedAngle / sectorAngle).floor() % itemCount;
    
    final selectedItem = _currentMenuItems[selectedIndex];
    
    if (_hoveredItem != selectedItem) {
      setState(() {
        _hoveredItem = selectedItem;
      });
      
      if (widget.debugMode) {
        print('悬停项目: ${selectedItem.label}');
      }
      
      HapticFeedback.selectionClick();
      
      // 如果是主菜单项目且有子项目，切换到子菜单
      if (!_isInSubMenu && selectedItem.subItems != null && selectedItem.subItems!.isNotEmpty) {
        // 先隐藏当前卡片
        for (final controller in _cardAnimationControllers) {
          controller.reverse();
        }
        
        // 等待动画完成后切换到子菜单
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _currentMenuItems = selectedItem.subItems!;
              _isInSubMenu = true;
              _selectedParentItem = selectedItem;
            });
            
            // 重新初始化并播放卡片动画
            _disposeCardAnimations();
            _initCardAnimations();
            _playCardAnimations();
            
            if (widget.debugMode) {
              print('进入子菜单: ${selectedItem.label}');
            }
          }
        });
      }
    }
  }

  void _selectItem() {
    if (_hoveredItem != null) {
      if (widget.debugMode) {
        print('选择项目: ${_hoveredItem!.label}');
      }
      
      HapticFeedback.mediumImpact();
      
      // 执行回调
      _hoveredItem!.onTap?.call();
      widget.onItemSelected?.call(_hoveredItem!);
      
      _hideMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (event) {
          // 检查是否为中键按下
          if (event.buttons == 4) {
            _showMenu(event.localPosition);
          }
        },
        onPointerMove: (event) {
          if (_isMenuVisible) {
            _updatePointer(event.localPosition);
          }
        },
        onPointerUp: (event) {
          if (_isMenuVisible) {
            // 检查是否在中心区域松开按键
            final distance = (event.localPosition - _menuCenter!).distance;
            if (distance <= widget.centerRadius) {
              // 在中心区域松开，直接隐藏菜单
              _hideMenu();
            } else {
              // 在菜单项区域松开，选择项目
              _selectItem();
            }
          }
        },
      child: Stack(
        children: [
          widget.child,
          if (_isMenuVisible) _buildMenu(),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    if (_menuCenter == null) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _plateAnimationController,
          ..._cardAnimationControllers,
        ]),
        builder: (context, child) {
          return Opacity(
            opacity: widget.opacity,
            child: CustomPaint(
              painter: RadialMenuPainter(
                center: _menuCenter!,
                radius: widget.radius,
                centerRadius: widget.centerRadius,
                menuItems: _currentMenuItems,
                hoveredItem: _hoveredItem,
                currentPointer: _currentPointer,
                isInSubMenu: _isInSubMenu,
                selectedParentItem: _selectedParentItem,
                plateScale: _plateScaleAnimation.value,
                plateOpacity: _plateOpacityAnimation.value,
                cardScales: _cardScaleAnimations.map((anim) => anim.value).toList(),
                cardOpacities: _cardOpacityAnimations.map((anim) => anim.value).toList(),
                plateColor: widget.plateColor,
                debugMode: widget.debugMode,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 轮盘菜单绘制器
class RadialMenuPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double centerRadius;
  final List<RadialMenuItem> menuItems;
  final RadialMenuItem? hoveredItem;
  final Offset? currentPointer;
  final bool isInSubMenu;
  final RadialMenuItem? selectedParentItem;
  final double plateScale;
  final double plateOpacity;
  final List<double> cardScales;
  final List<double> cardOpacities;
  final Color plateColor;
  final bool debugMode;

  RadialMenuPainter({
    required this.center,
    required this.radius,
    required this.centerRadius,
    required this.menuItems,
    this.hoveredItem,
    this.currentPointer,
    required this.isInSubMenu,
    this.selectedParentItem,
    required this.plateScale,
    required this.plateOpacity,
    required this.cardScales,
    required this.cardOpacities,
    required this.plateColor,
    required this.debugMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (menuItems.isEmpty) return;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(plateScale, plateScale);
    canvas.translate(-center.dx, -center.dy);
    
    final itemCount = menuItems.length;
    final sectorAngle = 2 * math.pi / itemCount;
    
    // 绘制背景圆圈（盘子）
    final backgroundPaint = Paint()
      ..color = plateColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 中心区域保持透明（不绘制中心圆圈）
    // 只绘制中心圆圈边框作为取消区域的指示
    // final centerBorderPaint = Paint()
    //   ..color = Colors.white.withValues(alpha: 0.3)
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 1.0;
    // canvas.drawCircle(center, centerRadius, centerBorderPaint);
    
    // 绘制菜单项（卡片）
    for (int i = 0; i < itemCount; i++) {
      final item = menuItems[i];
      final startAngle = i * sectorAngle - math.pi / 2;
      final isHovered = item == hoveredItem;
      final cardScale = i < cardScales.length ? cardScales[i] : 1.0;
      final cardOpacity = i < cardOpacities.length ? cardOpacities[i] : 1.0;
      
      _drawMenuItem(canvas, item, startAngle, sectorAngle, isHovered, cardScale, cardOpacity);
    }
    
    // 绘制调试信息
    if (debugMode && currentPointer != null) {
      _drawDebugInfo(canvas);
    }
    
    canvas.restore();
  }

  void _drawMenuItem(
    Canvas canvas,
    RadialMenuItem item,
    double startAngle,
    double sectorAngle,
    bool isHovered,
    double cardScale,
    double cardOpacity,
  ) {
    canvas.save();

    // 1. 定义间隙的物理宽度
    const double gapWidth = 4.0;
    final double halfGap = gapWidth / 2.0;

    // 2. 计算扇区两侧“间隙中心线”的角度
    // 这不是扇区本身的起止角度，而是扇区与邻居之间的分界线角度
    final double startDividerAngle = startAngle;
    final double endDividerAngle = startAngle + sectorAngle;

    // 3. 通过矢量偏移计算四个精确的顶点
    // 我们需要找到每条中心线上点的法线向量，然后沿法线方向偏移半个间隙宽度

    // 起始边的顶点
    final Offset startNormal = Offset(
      -math.sin(startDividerAngle),
      math.cos(startDividerAngle),
    ); // 垂直于起始分割线的单位向量
    final Offset innerStartPoint = Offset(
      center.dx +
          centerRadius * math.cos(startDividerAngle) +
          startNormal.dx * halfGap,
      center.dy +
          centerRadius * math.sin(startDividerAngle) +
          startNormal.dy * halfGap,
    );
    final Offset outerStartPoint = Offset(
      center.dx +
          radius * math.cos(startDividerAngle) +
          startNormal.dx * halfGap,
      center.dy +
          radius * math.sin(startDividerAngle) +
          startNormal.dy * halfGap,
    );

    // 结束边的顶点
    final Offset endNormal = Offset(
      -math.sin(endDividerAngle),
      math.cos(endDividerAngle),
    ); // 垂直于结束分割线的单位向量
    final Offset innerEndPoint = Offset(
      center.dx +
          centerRadius * math.cos(endDividerAngle) -
          endNormal.dx * halfGap,
      center.dy +
          centerRadius * math.sin(endDividerAngle) -
          endNormal.dy * halfGap,
    );
    final Offset outerEndPoint = Offset(
      center.dx + radius * math.cos(endDividerAngle) - endNormal.dx * halfGap,
      center.dy + radius * math.sin(endDividerAngle) - endNormal.dy * halfGap,
    );

    // 4. 构建路径
    // 使用 arcToPoint 来连接偏移后的顶点，这能确保弧线完美地衔接直线
    final path = Path()
      ..moveTo(innerStartPoint.dx, innerStartPoint.dy) // 移动到内弧起点
      ..lineTo(outerStartPoint.dx, outerStartPoint.dy) // 绘制起始边 (直线)
      ..arcToPoint(
        // 绘制外弧
        outerEndPoint,
        radius: Radius.circular(radius),
        largeArc: sectorAngle > math.pi, // 如果扇区大于半圆，则使用大弧
      )
      ..lineTo(innerEndPoint.dx, innerEndPoint.dy) // 绘制结束边 (直线)
      ..arcToPoint(
        // 绘制内弧
        innerStartPoint,
        radius: Radius.circular(centerRadius),
        largeArc: sectorAngle > math.pi,
        clockwise: false, // 内弧需要逆时针绘制
      )
      ..close();

    // 5. 应用卡片动画、绘制、文本和图标
    final midAngle = startAngle + sectorAngle / 2;
    final cardCenterRadius = (centerRadius + radius) / 2;
    final cardCenter = Offset(
      center.dx + cardCenterRadius * math.cos(midAngle),
      center.dy + cardCenterRadius * math.sin(midAngle),
    );

    // 应用卡片动画变换
    canvas.translate(cardCenter.dx, cardCenter.dy);
    canvas.scale(cardScale);
    canvas.translate(-cardCenter.dx, -cardCenter.dy);

    // 绘制扇区背景和边框
    final sectorPaint = Paint()
      ..color = (item.color ?? Colors.blue).withValues(alpha: cardOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, sectorPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * cardOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHovered ? 2.0 : 1.0;
    canvas.drawPath(path, borderPaint);

    // 绘制文本和图标
    final textCenter = Offset(
      center.dx + math.cos(midAngle) * cardCenterRadius,
      center.dy + math.sin(midAngle) * cardCenterRadius,
    );

    final iconAndTextStyle = TextStyle(
      color: Colors.white.withValues(alpha: cardOpacity),
      fontSize: 12,
      fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
    );

    // 绘制图标
    if (item.icon != null) {
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(item.icon!.codePoint),
          style: iconAndTextStyle.copyWith(
            fontFamily: item.icon!.fontFamily,
            package: item.icon!.fontPackage,
            fontSize: 20,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      final iconOffset = Offset(
        textCenter.dx - iconPainter.width / 2,
        textCenter.dy - iconPainter.height / 2 - 10,
      );
      iconPainter.paint(canvas, iconOffset);
    }

    // 绘制文本
    final textPainter = TextPainter(
      text: TextSpan(text: item.label, style: iconAndTextStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textOffset = Offset(
      textCenter.dx - textPainter.width / 2,
      textCenter.dy - textPainter.height / 2 + (item.icon != null ? 10 : 0),
    );
    textPainter.paint(canvas, textOffset);

    // 绘制子项目指示器
    if (item.subItems != null && item.subItems!.isNotEmpty) {
      final indicatorPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: cardOpacity)
        ..style = PaintingStyle.fill;

      final indicatorCenter = Offset(
        center.dx + math.cos(midAngle) * (radius - 15),
        center.dy + math.sin(midAngle) * (radius - 15),
      );

      canvas.drawCircle(indicatorCenter, 3, indicatorPaint);
    }

    canvas.restore();
  }

  void _drawDebugInfo(Canvas canvas) {
    if (currentPointer == null) return;
    
    // 绘制鼠标指针到中心的连线
    final linePaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(center, currentPointer!, linePaint);
    
    // 绘制鼠标指针位置
    final pointerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(currentPointer!, 5, pointerPaint);
    
    // 绘制距离和角度信息
    final distance = (currentPointer! - center).distance;
      final angle = math.atan2(
        currentPointer!.dy - center.dy,
        currentPointer!.dx - center.dx,
      );
      final degrees = (angle * 180 / math.pi).round();
      
      final debugText = 'Distance: ${distance.round()}\nAngle: $degrees°';
      final debugTextPainter = TextPainter(
        text: TextSpan(
          text: debugText,
          style: TextStyle(
            color: Colors.red,
            fontSize: 10,
            backgroundColor: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      debugTextPainter.layout();
      
      final debugOffset = Offset(
        currentPointer!.dx + 10,
        currentPointer!.dy - debugTextPainter.height,
      );
      debugTextPainter.paint(canvas, debugOffset);
  }

  @override
  bool shouldRepaint(RadialMenuPainter oldDelegate) {
    return oldDelegate.hoveredItem != hoveredItem ||
        oldDelegate.currentPointer != currentPointer ||
        oldDelegate.isInSubMenu != isInSubMenu ||
        oldDelegate.plateScale != plateScale ||
        oldDelegate.plateOpacity != plateOpacity ||
        oldDelegate.cardScales != cardScales ||
        oldDelegate.cardOpacities != cardOpacities;
  }
}