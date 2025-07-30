// This file has been processed by AI for internationalization
import '../../l10n/app_localizations.dart';
import '../../services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 调整大小手柄类型
enum _ResizeHandle { topLeft, topRight, bottomLeft, bottomRight }

/// 浮动窗口组件，模仿VFS文件选择器的设计风格
/// 提供统一的浮动窗口外观和行为
class FloatingWindow extends StatefulWidget {
  /// 窗口标题
  final String title;

  /// 窗口图标
  final IconData? icon;

  /// 窗口内容
  final Widget child;

  /// 关闭回调
  final VoidCallback? onClose;

  /// 窗口大小比例 (相对于屏幕大小)
  final double widthRatio;
  final double heightRatio;

  /// 最小和最大尺寸限制
  final Size? minSize;
  final Size? maxSize;

  /// 是否可拖拽移动
  final bool draggable;

  /// 是否可调整大小
  final bool resizable;

  /// 自定义头部操作按钮
  final List<Widget>? headerActions;

  /// 头部副标题
  final String? subtitle;

  /// 是否显示关闭按钮
  final bool showCloseButton;

  /// 背景遮罩颜色
  final Color? barrierColor;

  /// 窗口圆角半径
  final double borderRadius;

  /// 阴影配置
  final List<BoxShadow>? shadows;

  const FloatingWindow({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.onClose,
    this.widthRatio = 0.9,
    this.heightRatio = 0.9,
    this.minSize,
    this.maxSize,
    this.draggable = false,
    this.resizable = false,
    this.headerActions,
    this.subtitle,
    this.showCloseButton = true,
    this.barrierColor,
    this.borderRadius = 16.0,
    this.shadows,
  });

  @override
  State<FloatingWindow> createState() => _FloatingWindowState();

  /// 显示浮动窗口
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    IconData? icon,
    double widthRatio = 0.9,
    double heightRatio = 0.9,
    Size? minSize,
    Size? maxSize,
    bool draggable = false,
    bool resizable = false,
    List<Widget>? headerActions,
    String? subtitle,
    bool showCloseButton = true,
    Color? barrierColor,
    double borderRadius = 16.0,
    List<BoxShadow>? shadows,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (context) => FloatingWindow(
        title: title,
        icon: icon,
        child: child,
        onClose: () => Navigator.of(context).pop(),
        widthRatio: widthRatio,
        heightRatio: heightRatio,
        minSize: minSize,
        maxSize: maxSize,
        draggable: draggable,
        resizable: resizable,
        headerActions: headerActions,
        subtitle: subtitle,
        showCloseButton: showCloseButton,
        borderRadius: borderRadius,
        shadows: shadows,
      ),
    );
  }
}

class _FloatingWindowState extends State<FloatingWindow> {
  double? _currentWidth;
  double? _currentHeight;
  Offset _position = Offset.zero;
  bool _isDragging = false;
  bool _isResizing = false;
  _ResizeHandle? _activeResizeHandle;

  @override
  void initState() {
    super.initState();
    // 延迟初始化，等待MediaQuery可用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeSize();
      }
    });
  }

  void _initializeSize() {
    final screenSize = MediaQuery.of(context).size;
    double width = screenSize.width * widget.widthRatio;
    double height = screenSize.height * widget.heightRatio;

    // 应用最小和最大尺寸限制
    if (widget.minSize != null) {
      width = width.clamp(widget.minSize!.width, double.infinity);
      height = height.clamp(widget.minSize!.height, double.infinity);
    }

    if (widget.maxSize != null) {
      width = width.clamp(0, widget.maxSize!.width);
      height = height.clamp(0, widget.maxSize!.height);
    }

    _currentWidth = width;
    _currentHeight = height;

    // 设置窗口初始位置为屏幕中心
    if (widget.draggable) {
      _position = Offset(
        (screenSize.width - width) / 2,
        (screenSize.height - height) / 2,
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 如果尺寸还未初始化，显示加载指示器
    if (_currentWidth == null || _currentHeight == null) {
      return const Material(
        color: Colors.transparent,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    Widget windowContent = _buildWindowContent();

    // 如果可拖拽，包装为可拖拽组件
    if (widget.draggable) {
      windowContent = _buildDraggableWindow(windowContent);
    } else {
      windowContent = Center(child: windowContent);
    }

    return Material(color: Colors.transparent, child: windowContent);
  }

  Widget _buildWindowContent() {
    Widget content = Container(
      width: _currentWidth!,
      height: _currentHeight!,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow:
            widget.shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: widget.child),
        ],
      ),
    );

    // 如果可以调整大小，添加调整大小手柄
    if (widget.resizable) {
      content = Stack(children: [content, ..._buildResizeHandles()]);
    }

    return content;
  }

  Widget _buildDraggableWindow(Widget child) {
    return Stack(
      children: [
        Positioned(left: _position.dx, top: _position.dy, child: child),
      ],
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget headerContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.borderRadius),
        ),
      ),
      child: _buildHeaderContent(),
    );

    // 如果可拖拽，将整个标题栏包装为拖拽区域
    if (widget.draggable) {
      headerContent = GestureDetector(
        onPanStart: (details) {
          _isDragging = true;
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            setState(() {
              _position += details.delta;
              // 限制拖拽范围在屏幕内
              final screenSize = MediaQuery.of(context).size;
              _position = Offset(
                _position.dx.clamp(
                  -_currentWidth! + 100, // 允许部分窗口移出屏幕
                  screenSize.width - 100,
                ),
                _position.dy.clamp(-50, screenSize.height - 100),
              );
            });
          }
        },
        onPanEnd: (details) {
          _isDragging = false;
        },
        child: headerContent,
      );
    }
    return headerContent;
  }

  /// 构建调整大小手柄
  List<Widget> _buildResizeHandles() {
    const handleSize = 16.0;

    return [
      // 左上角
      _buildResizeHandle(
        _ResizeHandle.topLeft,
        handleSize,
        top: -handleSize / 2,
        left: -handleSize / 2,
        cursor: SystemMouseCursors.resizeUpLeft,
      ),
      // 右上角
      _buildResizeHandle(
        _ResizeHandle.topRight,
        handleSize,
        top: -handleSize / 2,
        right: -handleSize / 2,
        cursor: SystemMouseCursors.resizeUpRight,
      ),
      // 左下角
      _buildResizeHandle(
        _ResizeHandle.bottomLeft,
        handleSize,
        bottom: -handleSize / 2,
        left: -handleSize / 2,
        cursor: SystemMouseCursors.resizeDownLeft,
      ),
      // 右下角
      _buildResizeHandle(
        _ResizeHandle.bottomRight,
        handleSize,
        bottom: -handleSize / 2,
        right: -handleSize / 2,
        cursor: SystemMouseCursors.resizeDownRight,
      ),
    ];
  }

  /// 构建单个调整大小手柄
  Widget _buildResizeHandle(
    _ResizeHandle handle,
    double size, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required SystemMouseCursor cursor,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onPanStart: (details) {
            _isResizing = true;
            _activeResizeHandle = handle;
          },
          onPanUpdate: (details) {
            if (_isResizing && _activeResizeHandle == handle) {
              _handleResize(handle, details.delta);
            }
          },
          onPanEnd: (details) {
            _isResizing = false;
            _activeResizeHandle = null;
          },
          child: Container(
            width: size,
            height: size,
            // 完全透明的容器，保持功能但不显示
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  /// 处理调整大小
  void _handleResize(_ResizeHandle handle, Offset delta) {
    final screenSize = MediaQuery.of(context).size;
    double newWidth = _currentWidth!;
    double newHeight = _currentHeight!;
    Offset newPosition = _position;

    switch (handle) {
      case _ResizeHandle.topLeft:
        newWidth -= delta.dx;
        newHeight -= delta.dy;
        newPosition += Offset(delta.dx, delta.dy);
        break;
      case _ResizeHandle.topRight:
        newWidth += delta.dx;
        newHeight -= delta.dy;
        newPosition += Offset(0, delta.dy);
        break;
      case _ResizeHandle.bottomLeft:
        newWidth -= delta.dx;
        newHeight += delta.dy;
        newPosition += Offset(delta.dx, 0);
        break;
      case _ResizeHandle.bottomRight:
        newWidth += delta.dx;
        newHeight += delta.dy;
        break;
    }

    // 应用最小尺寸限制
    final minWidth = widget.minSize?.width ?? 200;
    final minHeight = widget.minSize?.height ?? 150;
    newWidth = newWidth.clamp(minWidth, double.infinity);
    newHeight = newHeight.clamp(minHeight, double.infinity);

    // 应用最大尺寸限制
    if (widget.maxSize != null) {
      newWidth = newWidth.clamp(0, widget.maxSize!.width);
      newHeight = newHeight.clamp(0, widget.maxSize!.height);
    }

    // 确保窗口不会超出屏幕边界
    newPosition = Offset(
      newPosition.dx.clamp(-newWidth + 100, screenSize.width - 100),
      newPosition.dy.clamp(-50, screenSize.height - 100),
    );

    setState(() {
      _currentWidth = newWidth;
      _currentHeight = newHeight;
      _position = newPosition;
    });
  }

  Widget _buildHeaderContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // 图标和标题
        if (widget.icon != null) ...[
          Icon(widget.icon, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ],
          ),
        ),

        // 自定义操作按钮
        if (widget.headerActions != null) ...[
          ...widget.headerActions!,
          const SizedBox(width: 8),
        ],

        // 关闭按钮
        if (widget.showCloseButton)
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            tooltip: LocalizationService.instance.current.closeButton_7421,
          ),
      ],
    );
  }
}

/// 浮动窗口构建器，提供更便捷的API
class FloatingWindowBuilder {
  String? _title;
  IconData? _icon;
  Widget? _child;
  double _widthRatio = 0.9;
  double _heightRatio = 0.9;
  Size? _minSize;
  Size? _maxSize;
  bool _draggable = false;
  bool _resizable = false;
  List<Widget>? _headerActions;
  String? _subtitle;
  bool _showCloseButton = true;
  Color? _barrierColor;
  double _borderRadius = 16.0;
  List<BoxShadow>? _shadows;
  bool _barrierDismissible = false;

  FloatingWindowBuilder title(String title) {
    _title = title;
    return this;
  }

  FloatingWindowBuilder icon(IconData icon) {
    _icon = icon;
    return this;
  }

  FloatingWindowBuilder child(Widget child) {
    _child = child;
    return this;
  }

  FloatingWindowBuilder size({double? widthRatio, double? heightRatio}) {
    if (widthRatio != null) _widthRatio = widthRatio;
    if (heightRatio != null) _heightRatio = heightRatio;
    return this;
  }

  FloatingWindowBuilder constraints({Size? minSize, Size? maxSize}) {
    _minSize = minSize;
    _maxSize = maxSize;
    return this;
  }

  FloatingWindowBuilder draggable([bool draggable = true]) {
    _draggable = draggable;
    return this;
  }

  FloatingWindowBuilder resizable([bool resizable = true]) {
    _resizable = resizable;
    return this;
  }

  FloatingWindowBuilder headerActions(List<Widget> actions) {
    _headerActions = actions;
    return this;
  }

  FloatingWindowBuilder subtitle(String subtitle) {
    _subtitle = subtitle;
    return this;
  }

  FloatingWindowBuilder showCloseButton([bool show = true]) {
    _showCloseButton = show;
    return this;
  }

  FloatingWindowBuilder barrierColor(Color color) {
    _barrierColor = color;
    return this;
  }

  FloatingWindowBuilder borderRadius(double radius) {
    _borderRadius = radius;
    return this;
  }

  FloatingWindowBuilder shadows(List<BoxShadow> shadows) {
    _shadows = shadows;
    return this;
  }

  FloatingWindowBuilder barrierDismissible([bool dismissible = true]) {
    _barrierDismissible = dismissible;
    return this;
  }

  /// 构建并显示浮动窗口
  Future<T?> show<T>(BuildContext context) {
    assert(_title != null, 'Title is required');
    assert(_child != null, 'Child widget is required');

    return FloatingWindow.show<T>(
      context,
      title: _title!,
      child: _child!,
      icon: _icon,
      widthRatio: _widthRatio,
      heightRatio: _heightRatio,
      minSize: _minSize,
      maxSize: _maxSize,
      draggable: _draggable,
      resizable: _resizable,
      headerActions: _headerActions,
      subtitle: _subtitle,
      showCloseButton: _showCloseButton,
      barrierColor: _barrierColor,
      borderRadius: _borderRadius,
      shadows: _shadows,
      barrierDismissible: _barrierDismissible,
    );
  }
}

/// 快速创建浮动窗口的扩展方法
extension FloatingWindowExtensions on BuildContext {
  /// 显示简单的浮动窗口
  Future<T?> showFloatingWindow<T>({
    required String title,
    required Widget child,
    IconData? icon,
    VoidCallback? onClose,
  }) {
    return FloatingWindow.show<T>(this, title: title, child: child, icon: icon);
  }

  /// 获取浮动窗口构建器
  FloatingWindowBuilder get floatingWindow => FloatingWindowBuilder();
}
