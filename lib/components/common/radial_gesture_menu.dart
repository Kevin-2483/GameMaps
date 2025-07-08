import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



/// Offset扩展方法
extension OffsetExtension on Offset {
  /// 归一化向量
  Offset normalize() {
    final length = distance;
    if (length == 0) return Offset.zero;
    return this / length;
  }
}

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
  final Color? borderColor;
  final Duration animationDuration;
  final int menuButton;
  final Duration returnDelay;

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
    this.borderColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.menuButton = 2,
    this.returnDelay = const Duration(milliseconds: 100),
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
  double _subMenuRotationOffset = 0.0; // 子菜单的固定旋转偏移
  
  // 中央区域停留计时器相关
  Timer? _centerAreaTimer;
  bool _isInCenterArea = false;
  Offset? _lastPointerPosition;
  DateTime? _lastPointerMoveTime;

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
    _centerAreaTimer?.cancel();
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
    final now = DateTime.now();
    
    // 检查鼠标是否移动
    bool hasMouseMoved = false;
    if (_lastPointerPosition != null) {
      final moveDistance = (position - _lastPointerPosition!).distance;
      hasMouseMoved = moveDistance > 2.0; // 移动超过2像素认为是移动
    }
    
    // 更新鼠标位置和时间
    if (hasMouseMoved) {
      _lastPointerPosition = position;
      _lastPointerMoveTime = now;
    }
    
    // 中心区域检测和延迟返回逻辑
    if (distance < widget.centerRadius) {
      if (!_isInCenterArea) {
        // 刚进入中央区域
        _isInCenterArea = true;
        _lastPointerPosition = position;
        _lastPointerMoveTime = now;
        _centerAreaTimer?.cancel();
        
        if (_isInSubMenu) {
          _centerAreaTimer = Timer(widget.returnDelay, () {
            if (mounted && _isInCenterArea && _isInSubMenu) {
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
                    _subMenuRotationOffset = 0.0; // 重置旋转偏移
                    _isInCenterArea = false;
                  });
                  
                  // 重新初始化并播放卡片动画
                  _disposeCardAnimations();
                  _initCardAnimations();
                  _playCardAnimations();
                  
                  // 根据当前鼠标位置预设hover状态
                  if (_currentPointer != null && _menuCenter != null) {
                    _setInitialHoverForSubMenu(_currentPointer!);
                  }
                  
                  if (widget.debugMode) {
                    print('延迟返回主菜单');
                  }
                }
              });
            }
          });
        }
      } else {
        // 已经在中央区域，如果鼠标移动了，重新启动计时器
        if (hasMouseMoved && _isInSubMenu) {
          _lastPointerPosition = position;
          _lastPointerMoveTime = now;
          _centerAreaTimer?.cancel();
          _centerAreaTimer = Timer(widget.returnDelay, () {
            if (mounted && _isInCenterArea && _isInSubMenu) {
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
                    _subMenuRotationOffset = 0.0; // 重置旋转偏移
                    _isInCenterArea = false;
                  });
                  
                  // 重新初始化并播放卡片动画
                  _disposeCardAnimations();
                  _initCardAnimations();
                  _playCardAnimations();
                  
                  // 根据当前鼠标位置预设hover状态
                  if (_currentPointer != null && _menuCenter != null) {
                    _setInitialHoverForSubMenu(_currentPointer!);
                  }
                  
                  if (widget.debugMode) {
                    print('延迟返回主菜单');
                  }
                }
              });
            }
          });
        }
      }
      
      // 主菜单状态下，在中心区域不触发选择，直接返回
      if (!_isInSubMenu) {
        return;
      }
      // 子菜单状态下，继续执行下面的角度计算和项目选择逻辑
    } else {
      // 离开中央区域，取消计时器
      if (_isInCenterArea) {
        _isInCenterArea = false;
        _centerAreaTimer?.cancel();
      }
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
    // 在子菜单状态下需要考虑旋转偏移
    double adjustedAngle = (normalizedAngle + math.pi / 2) % (2 * math.pi);
    if (_isInSubMenu) {
      adjustedAngle = (adjustedAngle - _subMenuRotationOffset + 2 * math.pi) % (2 * math.pi);
    }
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
        // 立即切换到子菜单状态
        setState(() {
          _currentMenuItems = selectedItem.subItems!;
          _isInSubMenu = true;
          _selectedParentItem = selectedItem;
          
          // 计算并固定子菜单的旋转偏移
          if (_currentPointer != null && _menuCenter != null) {
            final mouseAngle = math.atan2(
              _currentPointer!.dy - _menuCenter!.dy,
              _currentPointer!.dx - _menuCenter!.dx,
            );
            // 计算第一个项目的中心角度偏移
            final itemCount = selectedItem.subItems!.length;
            final sectorAngle = 2 * math.pi / itemCount;
            // 让第一个项目的中心对准鼠标位置
            _subMenuRotationOffset = mouseAngle + math.pi / 2 - sectorAngle / 2;
          } else {
            _subMenuRotationOffset = 0.0;
          }
        });
        
        // 同时开始一级菜单消失和二级菜单出现动画
        for (final controller in _cardAnimationControllers) {
          controller.reverse();
        }
        
        // 立即重新初始化并播放新的卡片动画
        _disposeCardAnimations();
        _initCardAnimations();
        _playCardAnimations();
        
        // 根据当前鼠标位置预设hover状态
        if (_currentPointer != null && _menuCenter != null) {
          _setInitialHoverForSubMenu(_currentPointer!);
        }
        
        if (widget.debugMode) {
          print('进入子菜单: ${selectedItem.label}');
        }
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
  
  void _setInitialHoverForSubMenu(Offset position) {
    if (!_isMenuVisible || _menuCenter == null || _currentMenuItems.isEmpty) return;
    
    final distance = (position - _menuCenter!).distance;
    
    // 如果在中心区域，不设置hover
    if (distance < widget.centerRadius) {
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
    final sectorAngle = 2 * math.pi / itemCount;
    // 在子菜单状态下需要考虑旋转偏移
    double adjustedAngle = (normalizedAngle + math.pi / 2) % (2 * math.pi);
    if (_isInSubMenu) {
      adjustedAngle = (adjustedAngle - _subMenuRotationOffset + 2 * math.pi) % (2 * math.pi);
    }
    final selectedIndex = (adjustedAngle / sectorAngle).floor() % itemCount;
    
    final selectedItem = _currentMenuItems[selectedIndex];
    
    setState(() {
      _hoveredItem = selectedItem;
    });
    
    if (widget.debugMode) {
      print('子菜单初始悬停项目: ${selectedItem.label}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (event) {
          // 检查是否为中键按下
          if (event.buttons == widget.menuButton) {
            _showMenu(event.localPosition);
            if (widget.debugMode) {
              print('中键按下，显示径向菜单于位置: ${event.localPosition}');
            }
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
                subMenuRotationOffset: _subMenuRotationOffset,
                plateScale: _plateScaleAnimation.value,
                plateOpacity: _plateOpacityAnimation.value,
                cardScales: _cardScaleAnimations.map((anim) => anim.value).toList(),
                cardOpacities: _cardOpacityAnimations.map((anim) => anim.value).toList(),
                plateColor: widget.plateColor,
                borderColor: widget.borderColor,
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
  final double subMenuRotationOffset;
  final double plateScale;
  final double plateOpacity;
  final List<double> cardScales;
  final List<double> cardOpacities;
  final Color plateColor;
  final Color? borderColor;
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
    required this.subMenuRotationOffset,
    required this.plateScale,
    required this.plateOpacity,
    required this.cardScales,
    required this.cardOpacities,
    required this.plateColor,
    this.borderColor,
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
    
    // 绘制背景圆圈（盘子）- 比扇形稍大一圈
    const double plateRadiusExpansion = 12.0; // 盘子半径扩展
    final plateRadius = radius + plateRadiusExpansion;
    final backgroundPaint = Paint()
      ..color = plateColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, plateRadius, backgroundPaint);
    
    // 绘制背景边框
    if (borderColor != null) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, plateRadius, borderPaint);
    }
    
    // 中心区域保持透明（不绘制中心圆圈）
    // 只绘制中心圆圈边框作为取消区域的指示
    // final centerBorderPaint = Paint()
    //   ..color = Colors.white.withValues(alpha: 0.3)
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 1.0;
    // canvas.drawCircle(center, centerRadius, centerBorderPaint);
    
    // 使用固定的子菜单旋转偏移
    double rotationOffset = 0.0;
    if (isInSubMenu) {
      rotationOffset = subMenuRotationOffset;
    }
    
    // 绘制菜单项（卡片）
    for (int i = 0; i < itemCount; i++) {
      final item = menuItems[i];
      final startAngle = i * sectorAngle - math.pi / 2 + rotationOffset;
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

    // 1. 定义间隙的物理宽度和选中项目的半径扩展
    const double gapWidth = 4.0;
    final double halfGap = gapWidth / 2.0;
    const double hoverRadiusExpansion = 8.0; // 选中项目半径扩展
    
    // 根据是否选中调整半径
    final double adjustedRadius = radius + (isHovered ? hoverRadiusExpansion : 0.0);
    final double adjustedCenterRadius = centerRadius - (isHovered ? hoverRadiusExpansion / 2 : 0.0);

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
          adjustedCenterRadius * math.cos(startDividerAngle) +
          startNormal.dx * halfGap,
      center.dy +
          adjustedCenterRadius * math.sin(startDividerAngle) +
          startNormal.dy * halfGap,
    );
    final Offset outerStartPoint = Offset(
      center.dx +
          adjustedRadius * math.cos(startDividerAngle) +
          startNormal.dx * halfGap,
      center.dy +
          adjustedRadius * math.sin(startDividerAngle) +
          startNormal.dy * halfGap,
    );

    // 结束边的顶点
    final Offset endNormal = Offset(
      -math.sin(endDividerAngle),
      math.cos(endDividerAngle),
    ); // 垂直于结束分割线的单位向量
    final Offset innerEndPoint = Offset(
      center.dx +
          adjustedCenterRadius * math.cos(endDividerAngle) -
          endNormal.dx * halfGap,
      center.dy +
          adjustedCenterRadius * math.sin(endDividerAngle) -
          endNormal.dy * halfGap,
    );
    final Offset outerEndPoint = Offset(
      center.dx + adjustedRadius * math.cos(endDividerAngle) - endNormal.dx * halfGap,
      center.dy + adjustedRadius * math.sin(endDividerAngle) - endNormal.dy * halfGap,
    );

    // 4. 构建路径（带圆角效果）
    // 定义圆角半径
    const double cornerRadius = 8.0;
    
    // 计算圆角过渡点
    // 起始边的圆角过渡点
    final startLineVector = (outerStartPoint - innerStartPoint).normalize();
    final startCornerInner = innerStartPoint + startLineVector * cornerRadius;
    final startCornerOuter = outerStartPoint - startLineVector * cornerRadius;
    
    // 结束边的圆角过渡点
    final endLineVector = (outerEndPoint - innerEndPoint).normalize();
    final endCornerOuter = outerEndPoint - endLineVector * cornerRadius;
    final endCornerInner = innerEndPoint + endLineVector * cornerRadius;
    
    // 外弧的圆角过渡点
    final outerArcStartTangent = Offset(
      -math.sin(startDividerAngle),
      math.cos(startDividerAngle),
    ).normalize();
    final outerArcEndTangent = Offset(
      -math.sin(endDividerAngle),
      math.cos(endDividerAngle),
    ).normalize();
    
    final outerArcStartCorner = outerStartPoint + outerArcStartTangent * cornerRadius;
    final outerArcEndCorner = outerEndPoint - outerArcEndTangent * cornerRadius;
    
    // 内弧的圆角过渡点（向直边方向弯曲）
    // 计算起始直边的垂直方向（向扇形内部旋转90度）
    final startLineDirection = (outerStartPoint - innerStartPoint).normalize();
    final startPerpendicularDirection = Offset(-startLineDirection.dy, startLineDirection.dx);
    
    // 计算结束直边的垂直方向（向扇形内部旋转90度）
    final endLineDirection = (outerEndPoint - innerEndPoint).normalize();
    final endPerpendicularDirection = Offset(endLineDirection.dy, -endLineDirection.dx);
    
    // 内弧圆角向直边垂直方向偏移
    final innerArcStartCorner = innerStartPoint + startPerpendicularDirection * cornerRadius;
    final innerArcEndCorner = innerEndPoint + endPerpendicularDirection * cornerRadius;
    
    final path = Path()
      ..moveTo(innerArcStartCorner.dx, innerArcStartCorner.dy) // 移动到内弧圆角起点
      // 内弧起始圆角过渡
      ..quadraticBezierTo(
        innerStartPoint.dx, innerStartPoint.dy,
        startCornerInner.dx, startCornerInner.dy,
      )
      ..lineTo(startCornerOuter.dx, startCornerOuter.dy) // 绘制起始边直线部分
      // 起始边到外弧的圆角过渡
      ..quadraticBezierTo(
        outerStartPoint.dx, outerStartPoint.dy,
        outerArcStartCorner.dx, outerArcStartCorner.dy,
      )
      // 绘制外弧
       ..arcToPoint(
         outerArcEndCorner,
         radius: Radius.circular(adjustedRadius),
         largeArc: sectorAngle > math.pi,
       )
      // 外弧到结束边的圆角过渡
      ..quadraticBezierTo(
        outerEndPoint.dx, outerEndPoint.dy,
        endCornerOuter.dx, endCornerOuter.dy,
      )
      ..lineTo(endCornerInner.dx, endCornerInner.dy) // 绘制结束边直线部分
      // 结束边到内弧的圆角过渡
      ..quadraticBezierTo(
        innerEndPoint.dx, innerEndPoint.dy,
        innerArcEndCorner.dx, innerArcEndCorner.dy,
      )
      // 绘制内弧
       ..arcToPoint(
         innerArcStartCorner,
         radius: Radius.circular(adjustedCenterRadius),
         largeArc: sectorAngle > math.pi,
         clockwise: false,
       )
      ..close();

    // 5. 应用卡片动画、绘制、文本和图标
    final midAngle = startAngle + sectorAngle / 2;
    final cardCenterRadius = (adjustedCenterRadius + adjustedRadius) / 2;
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
      ..color = (borderColor ?? Colors.white).withValues(alpha: 0.8 * cardOpacity)
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

    // 检查是否有文本内容
    final hasText = item.label.isNotEmpty;
    
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
        textCenter.dy - iconPainter.height / 2 - (hasText ? 10 : 0),
      );
      iconPainter.paint(canvas, iconOffset);
    }

    // 绘制文本（只有当文本不为空时才绘制）
    if (hasText) {
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
    }

    // 绘制子项目指示器（已禁用）
    // if (item.subItems != null && item.subItems!.isNotEmpty) {
    //   final indicatorPaint = Paint()
    //     ..color = Colors.yellow.withValues(alpha: cardOpacity)
    //     ..style = PaintingStyle.fill;

    //   final indicatorCenter = Offset(
    //     center.dx + math.cos(midAngle) * (adjustedRadius - 15),
    //     center.dy + math.sin(midAngle) * (adjustedRadius - 15),
    //   );

    //   canvas.drawCircle(indicatorCenter, 3, indicatorPaint);
    // }

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
        oldDelegate.subMenuRotationOffset != subMenuRotationOffset ||
        oldDelegate.plateScale != plateScale ||
        oldDelegate.plateOpacity != plateOpacity ||
        oldDelegate.cardScales != cardScales ||
        oldDelegate.cardOpacities != cardOpacities;
  }
}