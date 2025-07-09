import '../../../services/legend_session_manager.dart';
import '../../../services/legend_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For PointerPanZoom events
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart'; // For RenderRepaintBoundary
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4; // 添加Matrix4导入
import 'package:jovial_svg/jovial_svg.dart';
import '../../../models/map_layer.dart';
import '../../../models/map_item.dart';
import '../../../models/sticky_note.dart'; // 导入便签模型
import '../../../models/user_preferences.dart';
import '../../../models/legend_item.dart' as legend_db;
import '../../../providers/user_preferences_provider.dart';
import '../../../services/vfs/vfs_file_opener_service.dart';
import '../../../services/legend_vfs/legend_vfs_service.dart'; // 导入图例VFS服务
import 'sticky_note_display.dart'; // 导入便签显示组件
// 导入渲染器
import '../renderers/highlight_renderer.dart';
import '../renderers/preview_renderer.dart';
import '../renderers/eraser_renderer.dart';
import '../renderers/background_renderer.dart';
// 导入绘制工具管理器
import '../tools/drawing_tool_manager.dart';
import '../tools/element_interaction_manager.dart';
import '../../../data/new_reactive_script_manager.dart'; // 新增：导入脚本管理器
import '../../../components/color_filter_dialog.dart'; // 导入色彩滤镜组件
import '../../../services/notification/notification_service.dart';

// 画布固定尺寸常量，确保坐标转换的一致性
const double kCanvasWidth = 1600.0;
const double kCanvasHeight = 1600.0;

/// 绘制预览数据
class DrawingPreviewData {
  final Offset start;
  final Offset end;
  final DrawingElementType elementType;
  final Color color;
  final double strokeWidth;
  final double density;
  final double curvature; // 弧度值
  final TriangleCutType triangleCut; // 三角形切割类型
  final List<Offset>? freeDrawingPath; // 自由绘制路径
  final StickyNote? targetStickyNote; // 目标便签（如果在便签上绘制）

  const DrawingPreviewData({
    required this.start,
    required this.end,
    required this.elementType,
    required this.color,
    required this.strokeWidth,
    required this.density,
    required this.curvature,
    required this.triangleCut,
    this.freeDrawingPath,
    this.targetStickyNote,
  });
}

// 这些工具函数已经移动到单独的渲染器文件中

// 这些工具函数已经移动到 drawing_utils.dart 中
// 现在保留包装函数以便于调用

// --- 重构后的 _drawCurvedRectangle 函数 ---

/// 辅助类：用于管理分层元素
class _LayeredElement {
  final int order;
  final bool isSelected;
  final Widget widget;

  const _LayeredElement({
    required this.order,
    required this.isSelected,
    required this.widget,
  });
}

class MapCanvas extends StatefulWidget {
  final MapItem mapItem;
  final MapLayer? selectedLayer;
  final DrawingElementType? selectedDrawingTool;
  final Color selectedColor;
  final double selectedStrokeWidth;
  final double selectedDensity;
  final double selectedCurvature;
  final List<legend_db.LegendItem> availableLegends; // 保留兼容性，但已弃用
  final LegendSessionManager? legendSessionManager; // 新的图例会话管理器
  final bool isPreviewMode;
  final Function(MapLayer) onLayerUpdated;
  final Function(LegendGroup) onLegendGroupUpdated;
  final Function(String) onLegendItemSelected;
  final Function(LegendItem) onLegendItemDoubleClicked;
  final Map<String, double> previewOpacityValues;
  final DrawingElementType? previewDrawingTool;
  final Color? previewColor;
  final double? previewStrokeWidth;
  final double? previewDensity;
  final double? previewCurvature;
  final TriangleCutType? previewTriangleCut;
  final String? selectedElementId;
  final Function(String?) onElementSelected;
  final BackgroundPattern backgroundPattern;
  final double zoomSensitivity;
  final VoidCallback? onSelectionCleared; //：选区清除回调
  final bool shouldDisableDrawingTools; // 是否应该禁用绘图工具
  // 添加图片缓冲区相关参数
  final Uint8List? imageBufferData; // 图片缓冲区数据
  final BoxFit imageBufferFit; // 图片适应方式
  final List<MapLayer>? displayOrderLayers; //：优先显示顺序的图层列表  // 便签相关参数
  final StickyNote? selectedStickyNote; // 当前选中的便签
  final Map<String, double> previewStickyNoteOpacityValues; // 便签透明度预览值
  final Function(StickyNote)? onStickyNoteUpdated; // 便签更新回调
  final Function(StickyNote?)? onStickyNoteSelected; // 便签选中回调
  final Function(List<StickyNote>)? onStickyNotesReordered; // 便签重排回调
  // 便签透明度更新回调
  final Function(String, double)? onStickyNoteOpacityChanged;
  final NewReactiveScriptManager? scriptManager; // 新增：脚本管理器参数
  final Function(String, Offset)? onLegendDragToCanvas; // 新增：拖拽图例到画布的回调
  final bool isMenuButtonDown; // 中键按下状态

  const MapCanvas({
    super.key,
    required this.mapItem,
    this.selectedLayer,
    this.selectedDrawingTool,
    required this.selectedColor,
    required this.selectedStrokeWidth,
    required this.selectedDensity,
    required this.selectedCurvature,
    required this.availableLegends, // 兼容性参数，已弃用
    this.legendSessionManager, // 新的图例会话管理器
    required this.isPreviewMode,
    required this.onLayerUpdated,
    required this.onLegendGroupUpdated,
    required this.onLegendItemSelected,
    required this.onLegendItemDoubleClicked,
    required this.previewOpacityValues,
    this.previewDrawingTool,
    this.previewColor,
    this.previewStrokeWidth,
    this.previewDensity,
    this.previewCurvature,
    this.previewTriangleCut,
    this.selectedElementId,
    required this.onElementSelected,
    required this.backgroundPattern,
    required this.zoomSensitivity,
    this.displayOrderLayers,
    this.onSelectionCleared,
    this.shouldDisableDrawingTools = false,

    // 添加图片缓冲区参数
    this.imageBufferData,
    this.imageBufferFit = BoxFit.contain, // 便签相关参数
    this.selectedStickyNote,
    this.previewStickyNoteOpacityValues = const {},
    this.onStickyNoteUpdated,
    this.onStickyNoteSelected,
    this.onStickyNotesReordered,
    this.onStickyNoteOpacityChanged,
    this.scriptManager, // 新增：脚本管理器参数
    this.onLegendDragToCanvas, // 新增：拖拽图例到画布的回调
    this.isMenuButtonDown = false, // 中键按下状态
  });

  @override
  State<MapCanvas> createState() => MapCanvasState();
}

class MapCanvasState extends State<MapCanvas> {
  Rect? get currentSelectionRect => _selectionRect;
  final TransformationController _transformationController =
      TransformationController();
  // 绘制工具管理器
  late final DrawingToolManager _drawingToolManager;
  // 元素交互管理器
  late final ElementInteractionManager _elementInteractionManager;

  // 添加图片缓存 - 支持实时解码
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, Future<ui.Image?>> _imageDecodingFutures = {}; // 正在解码的图片
  Rect? _selectionRect; // 当前选区矩形
  final ValueNotifier<Rect?> _selectionNotifier = ValueNotifier(null);
  // 选区拖动相关变量
  Offset? _selectionStartPosition;
  bool _isCreatingSelection = false;

  // 监听图片缓冲区变化
  Uint8List? _lastImageBufferData;
  ui.Image? _imageBufferCachedImage;

  // 绘制预览的 ValueNotifier，避免整个 widget 重绘
  final ValueNotifier<DrawingPreviewData?> _drawingPreviewNotifier =
      ValueNotifier(null);

  // Add this GlobalKey
  final GlobalKey _canvasGlobalKey = GlobalKey();

  DrawingElementType? get _effectiveDrawingTool {
    if (widget.shouldDisableDrawingTools) {
      return null;
    }
    return widget.previewDrawingTool ?? widget.selectedDrawingTool;
  }

  Color get _effectiveColor => widget.previewColor ?? widget.selectedColor;
  double get _effectiveStrokeWidth =>
      widget.previewStrokeWidth ?? widget.selectedStrokeWidth;
  double get _effectiveDensity =>
      widget.previewDensity ?? widget.selectedDensity;
  double get _effectiveCurvature =>
      widget.previewCurvature ?? widget.selectedCurvature;
  TriangleCutType get _effectiveTriangleCut =>
      widget.previewTriangleCut ?? TriangleCutType.none;

  @override
  void initState() {
    super.initState(); // 初始化绘制工具管理器
    _drawingToolManager = DrawingToolManager(
      onLayerUpdated: widget.onLayerUpdated,
      context: context,
    );

    // 初始化元素交互管理器
    _elementInteractionManager = ElementInteractionManager(
      onLayerUpdated: widget.onLayerUpdated,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    // 在组件初始化时预加载所有图层的图片
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAllLayerImages();
    });
  }

  // 添加清除选区的方法
  void clearSelection() {
    if (_selectionRect != null) {
      setState(() {
        _selectionRect = null;
      });
      _selectionNotifier.value = null;

      // 通知外部选区已清除
      widget.onSelectionCleared?.call();
    }
  }

  @override
  void dispose() {
    // 清理绘制工具管理器
    _drawingToolManager.dispose();

    // 清理元素交互管理器
    _elementInteractionManager.reset();

    // 清理便签手势辅助器的节流资源
    StickyNoteGestureHelper.dispose();

    // 清理图片缓存
    for (final image in _imageCache.values) {
      image.dispose();
    }
    _imageCache.clear();
    _imageDecodingFutures.clear();

    _imageBufferCachedImage?.dispose();

    _transformationController.dispose();
    _drawingPreviewNotifier.dispose();
    _selectionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 从用户首选项获取画布边距设置
    final userPreferences = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );
    final canvasBoundaryMargin = userPreferences.mapEditor.canvasBoundaryMargin;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: EdgeInsets.all(canvasBoundaryMargin),
          minScale: 0.1,
          maxScale: 5.0,
          scaleFactor: 200.0 / widget.zoomSensitivity,
          panEnabled: !widget.isMenuButtonDown,
          scaleEnabled: true,
          constrained: false,
          child: RepaintBoundary(
            // Wrap with RepaintBoundary
            key: _canvasGlobalKey, // Assign the key
            child: SizedBox(
              width: kCanvasWidth,
              height: kCanvasHeight,
              child: Stack(
                children: [
                  // 画布容器
                  Container(
                    width: kCanvasWidth,
                    height: kCanvasHeight,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Stack(
                      children: [
                        // 背景图案（根据用户偏好设置）
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _BackgroundPatternPainter(
                              widget.backgroundPattern,
                              context: context,
                            ),
                          ),
                        ),
                        // 按层级顺序渲染所有元素
                        ..._buildLayeredElements(),
                        ValueListenableBuilder<DrawingPreviewData?>(
                          valueListenable:
                              _drawingToolManager.drawingPreviewNotifier,
                          builder: (context, previewData, child) {
                            if (previewData == null) {
                              return const SizedBox.shrink();
                            }
                            return CustomPaint(
                              size: const Size(kCanvasWidth, kCanvasHeight),
                              painter: _CurrentDrawingPainter(
                                start: previewData.start,
                                end: previewData.end,
                                elementType: previewData.elementType,
                                color: previewData.color,
                                strokeWidth: previewData.strokeWidth,
                                density: previewData.density,
                                curvature: previewData.curvature,
                                triangleCut: previewData.triangleCut,
                                freeDrawingPath: previewData.freeDrawingPath,
                                selectedElementId: widget.selectedElementId,
                                targetStickyNote: previewData.targetStickyNote,
                              ),
                            );
                          },
                        ),
                        // 选区层
                        ValueListenableBuilder<Rect?>(
                          valueListenable: _selectionNotifier,
                          builder: (context, selectionRect, child) {
                            if (selectionRect == null) {
                              return const SizedBox.shrink();
                            }
                            return CustomPaint(
                              painter: _SelectionPainter(selectionRect),
                              size: const Size(kCanvasWidth, kCanvasHeight),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Touch handler for drawing - 覆盖整个画布区域
                  if (_effectiveDrawingTool != null)
                    Positioned(
                      left: 0,
                      top: 0,
                      width: kCanvasWidth,
                      height: kCanvasHeight,
                      child: _effectiveDrawingTool == DrawingElementType.text
                          ? GestureDetector(
                              // 文本工具使用点击手势
                              onTapDown: (details) {
                                final position = _getCanvasPosition(
                                  details.localPosition,
                                );
                                _handleTextToolTap(position);
                              },
                              behavior: HitTestBehavior.translucent,
                            )
                          : GestureDetector(
                              // 其他工具使用拖拽手势
                              onPanStart: _onDrawingStart,
                              onPanUpdate: _onDrawingUpdate,
                              onPanEnd: _onDrawingEnd,
                              behavior: HitTestBehavior.translucent,
                            ),
                    ), // Touch handler for element interaction - 当没有绘制工具选中时
                  if (_effectiveDrawingTool == null)
                    Positioned(
                      left: 0,
                      top: 0,
                      width: kCanvasWidth,
                      height: kCanvasHeight,
                      child: Listener(
                        // 监听触摸板的两指拖动事件
                        onPointerPanZoomStart: _onTrackpadPanZoomStart,
                        onPointerPanZoomUpdate: _onTrackpadPanZoomUpdate,
                        onPointerPanZoomEnd: _onTrackpadPanZoomEnd,
                        child: GestureDetector(
                          // 排除触摸板设备，避免与PointerPanZoom事件冲突
                          supportedDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.stylus,
                            PointerDeviceKind.invertedStylus,
                            // 不包含 PointerDeviceKind.trackpad
                          },
                          onTapDown: _onElementInteractionTapDown,
                          onPanStart: _onElementInteractionPanStart,
                          onPanUpdate: _onElementInteractionPanUpdate,
                          onPanEnd: _onElementInteractionPanEnd,
                          behavior: HitTestBehavior.translucent,
                        ),
                      ),
                    ),

                  // DragTarget for receiving legend drags from cache
                  if (!widget.isPreviewMode)
                    Positioned(
                      left: 0,
                      top: 0,
                      width: kCanvasWidth,
                      height: kCanvasHeight,
                      child: DragTarget<String>(
                        onWillAccept: (data) => data != null && data.isNotEmpty,
                        onAccept: (legendPath) {
                          // 这个方法主要用于兼容性，实际处理在onAcceptWithDetails中
                          debugPrint('接收到拖拽的图例(onAccept): $legendPath');
                        },
                        onAcceptWithDetails: (details) {
                          // 获取拖拽释放的位置并转换为画布坐标
                          final globalPosition = details.offset;
                          // 将全局坐标转换为画布坐标
                          final RenderBox? renderBox =
                              context.findRenderObject() as RenderBox?;
                          if (renderBox != null) {
                            final localPosition = renderBox.globalToLocal(
                              globalPosition,
                            );
                            debugPrint(
                              '拖拽释放位置 - 全局: $globalPosition, 本地: $localPosition',
                            );

                            // 考虑 InteractiveViewer 的变换矩阵进行坐标转换
                            final canvasPosition =
                                _transformLocalToCanvasPosition(localPosition);
                            debugPrint('转换后的画布坐标: $canvasPosition');

                            _handleLegendDragAccept(
                              details.data,
                              canvasPosition,
                            );
                          } else {
                            debugPrint('警告：无法获取RenderBox，使用默认位置处理拖拽');
                            // 使用默认位置(画布中心)
                            final defaultPosition = const Offset(
                              kCanvasWidth / 2,
                              kCanvasHeight / 2,
                            );
                            _handleLegendDragAccept(
                              details.data,
                              defaultPosition,
                            );
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isHovering = candidateData.isNotEmpty;
                          return IgnorePointer(
                            ignoring: !isHovering, // 只有在悬停时才接收指针事件
                            child: Container(
                              color: isHovering
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              child: isHovering
                                  ? Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '释放以添加图例到此位置',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 处理接收到的图例拖拽数据
  void _handleLegendDragAccept(String legendPath, Offset canvasPosition) {
    // 转换画布像素坐标到相对坐标
    final relativePosition = Offset(
      canvasPosition.dx / kCanvasWidth,
      canvasPosition.dy / kCanvasHeight,
    );

    // 将拖拽事件传递给图例组管理抽屉处理
    widget.onLegendDragToCanvas?.call(legendPath, relativePosition);
  }

  /// 将本地坐标转换为画布坐标，考虑 InteractiveViewer 的变换矩阵
  Offset _transformLocalToCanvasPosition(Offset localPosition) {
    try {
      // 获取当前的变换矩阵
      final Matrix4 transform = _transformationController.value;

      // 提取缩放和平移信息
      final double scaleX = transform.entry(0, 0); // X轴缩放
      final double scaleY = transform.entry(1, 1); // Y轴缩放
      final double translateX = transform.entry(0, 3); // X轴平移
      final double translateY = transform.entry(1, 3); // Y轴平移

      // 逆向变换：从视口坐标转换为画布坐标
      final double canvasX = (localPosition.dx - translateX) / scaleX;
      final double canvasY = (localPosition.dy - translateY) / scaleY;

      // 限制在画布边界内
      final clampedPosition = Offset(
        canvasX.clamp(0.0, kCanvasWidth),
        canvasY.clamp(0.0, kCanvasHeight),
      );

      debugPrint('坐标转换: 本地($localPosition) -> 画布($clampedPosition)');
      debugPrint('变换信息: 缩放($scaleX, $scaleY), 平移($translateX, $translateY)');

      return clampedPosition;
    } catch (e) {
      debugPrint('坐标转换失败: $e，使用原始坐标');
      // 如果转换失败，返回限制在画布范围内的原始坐标
      return Offset(
        localPosition.dx.clamp(0.0, kCanvasWidth),
        localPosition.dy.clamp(0.0, kCanvasHeight),
      );
    }
  }

  Widget _buildLayerImageWidget(MapLayer layer) {
    if (layer.imageData == null) return const SizedBox.shrink();

    // 获取有效透明度（预览值或实际值）
    final effectiveOpacity =
        widget.previewOpacityValues[layer.id] ?? layer.opacity; // 确定图片适应方式和缩放比例
    BoxFit imageFit;
    double scale = layer.imageScale; // 使用图层设置的缩放比例

    if (layer.imageFit != null) {
      // 使用图层设置的适应方式
      imageFit = layer.imageFit!;
    } else {
      // 默认使用 contain 模式
      imageFit = BoxFit.contain;
    }

    // 计算偏移位置
    // xOffset 和 yOffset 的范围是 -1.0 到 1.0，其中 0 表示居中
    final double maxOffsetX = kCanvasWidth * 0.3; // 允许的最大X偏移量（画布宽度的30%）
    final double maxOffsetY = kCanvasHeight * 0.3; // 允许的最大Y偏移量（画布高度的30%）
    final double actualOffsetX = layer.xOffset * maxOffsetX;
    final double actualOffsetY = layer.yOffset * maxOffsetY;

    // 获取图层的色彩滤镜设置（只获取用户手动设置的滤镜，不包含主题适配滤镜）
    final userFilterSettings = ColorFilterSessionManager().getUserLayerFilter(
      layer.id,
    );
    final colorFilter = userFilterSettings?.toColorFilter();

    Widget imageWidget = Image.memory(
      layer.imageData!,
      width: kCanvasWidth,
      height: kCanvasHeight,
      fit: imageFit,
      // opacity: 1.0, // 透明度已经通过Opacity widget控制
    );

    // 只有用户手动设置的滤镜才应用到背景图片，主题适配滤镜不影响背景图片
    if (colorFilter != null) {
      imageWidget = ColorFiltered(colorFilter: colorFilter, child: imageWidget);
    }

    return Positioned.fill(
      child: Opacity(
        opacity: layer.isVisible ? effectiveOpacity : 0.0,
        child: Transform.translate(
          offset: Offset(actualOffsetX, actualOffsetY),
          child: Transform.scale(scale: scale, child: imageWidget),
        ),
      ),
    );
  }

  Widget _buildLayerWidget(MapLayer layer) {
    // 获取有效透明度（预览值或实际值）
    final effectiveOpacity =
        widget.previewOpacityValues[layer.id] ?? layer.opacity;

    // 获取用户偏好设置中的 handleSize
    final userPreferences = Provider.of<UserPreferencesProvider>(
      context,
      listen: false,
    );
    final handleSize = userPreferences.tools.handleSize;

    return Positioned.fill(
      child: Opacity(
        opacity: layer.isVisible ? effectiveOpacity : 0.0,
        child: CustomPaint(
          size: const Size(kCanvasWidth, kCanvasHeight),
          painter: _LayerPainter(
            layer: layer,
            isEditMode: true,
            selectedElementId: widget.selectedElementId,
            handleSize: handleSize,
            imageCache: _imageCache, // 传递元素图片缓存
            imageBufferCachedImage: _imageBufferCachedImage, // 传递缓冲区图片
            currentImageBufferData: widget.imageBufferData,
            imageBufferFit: widget.imageBufferFit,
            context: context,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendWidget(LegendGroup legendGroup) {
    debugPrint('=== 构建图例组: ${legendGroup.name} ===');
    debugPrint('图例组可见性: ${legendGroup.isVisible}');
    debugPrint('图例项数量: ${legendGroup.legendItems.length}');

    if (!legendGroup.isVisible) {
      debugPrint('图例组不可见，返回空Widget');
      return const SizedBox.shrink();
    }

    if (legendGroup.legendItems.isEmpty) {
      debugPrint('图例组没有图例项');
      return const SizedBox.shrink();
    }

    for (int i = 0; i < legendGroup.legendItems.length; i++) {
      final item = legendGroup.legendItems[i];
      debugPrint(
        '图例项 $i: ${item.id}, 路径: ${item.legendPath}, 位置: (${item.position.dx}, ${item.position.dy})',
      );
    }

    return Positioned.fill(
      child: Opacity(
        opacity: legendGroup.opacity,
        child: Stack(
          children: legendGroup.legendItems
              .map((item) => _buildLegendSticker(item))
              .toList(),
        ),
      ),
    );
  }

  /// 构建便签组件
  Widget _buildStickyNoteWidget(StickyNote note) {
    if (!note.isVisible) return const SizedBox.shrink();

    // 获取有效透明度（预览值或实际值）
    final effectiveOpacity =
        widget.previewStickyNoteOpacityValues[note.id] ?? note.opacity;

    // 转换相对坐标到画布坐标
    final position = Offset(
      note.position.dx * kCanvasWidth,
      note.position.dy * kCanvasHeight,
    );
    final size = Size(
      note.size.width * kCanvasWidth,
      note.size.height * kCanvasHeight,
    ); // 如果便签被选中，使用选中状态的高度，否则使用默认高度
    final double titleBarHeight = (widget.selectedStickyNote?.id == note.id)
        ? 40.0
        : 36.0; // 标题栏高度：选中时34px，未选中时40px
    final effectiveHeight = note.isCollapsed ? titleBarHeight : size.height;

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: size.width,
      height: effectiveHeight,
      child: Opacity(
        opacity: effectiveOpacity,
        child: StickyNoteDisplay(
          note: note,
          isSelected: widget.selectedStickyNote?.id == note.id,
          isPreviewMode: widget.isPreviewMode,
          onNoteUpdated: widget.onStickyNoteUpdated,
          imageCache: _imageCache,
          imageBufferCachedImage: _imageBufferCachedImage,
          currentImageBufferData: widget.imageBufferData,
          imageBufferFit: widget.imageBufferFit,
        ),
      ),
    );
  }

  Widget _buildLegendSticker(LegendItem item) {
    debugPrint('--- 构建图例贴纸: ${item.id} ---');
    debugPrint('图例路径: ${item.legendPath}');
    debugPrint('图例位置: (${item.position.dx}, ${item.position.dy})');
    debugPrint('图例可见性: ${item.isVisible}');
    debugPrint('图例会话管理器是否存在: ${widget.legendSessionManager != null}');

    // 优先使用图例会话管理器
    if (widget.legendSessionManager != null) {
      debugPrint('使用图例会话管理器构建');
      return _buildLegendStickerFromSession(item);
    }

    debugPrint('回退到异步加载方式');
    // 回退到旧的异步加载方式（兼容性）
    return FutureBuilder<legend_db.LegendItem?>(
      future: _loadLegendFromPath(item.legendPath),
      builder: (context, snapshot) {
        debugPrint('FutureBuilder 状态: ${snapshot.connectionState}');
        debugPrint('FutureBuilder 数据: ${snapshot.data}');
        debugPrint('FutureBuilder 错误: ${snapshot.error}');

        // 使用默认的未知图例作为fallback
        final legend =
            snapshot.data ??
            legend_db.LegendItem(
              title: '未知图例',
              centerX: 0.5,
              centerY: 0.5,
              version: 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

        return _buildLegendStickerWidget(
          item,
          legend,
          snapshot.connectionState == ConnectionState.waiting,
        );
      },
    );
  }

  /// 使用图例会话管理器构建图例贴纸
  Widget _buildLegendStickerFromSession(LegendItem item) {
    return ListenableBuilder(
      listenable: widget.legendSessionManager!,
      builder: (context, child) {
        final legendData = widget.legendSessionManager!.getLegendData(
          item.legendPath,
        );
        final loadingState = widget.legendSessionManager!.getLoadingState(
          item.legendPath,
        );

        debugPrint('图例会话管理器状态:');
        debugPrint('  - 图例数据: ${legendData != null ? "已加载" : "未加载"}');
        debugPrint('  - 加载状态: $loadingState');

        if (legendData != null) {
          debugPrint('  - 使用已加载的图例数据');
          // 图例已加载
          return _buildLegendStickerWidget(item, legendData, false);
        } else {
          // 图例未加载或加载失败
          final isLoading = loadingState == LegendLoadingState.loading;
          debugPrint('  - 图例未加载，是否正在加载: $isLoading');

          final legend = legend_db.LegendItem(
            title: isLoading ? '加载中...' : '未知图例',
            centerX: 0.5,
            centerY: 0.5,
            version: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // 触发异步加载
          if (loadingState == LegendLoadingState.notLoaded) {
            Future.microtask(
              () => widget.legendSessionManager!.addLegendToSession(
                item.legendPath,
              ),
            );
          }

          return _buildLegendStickerWidget(item, legend, isLoading);
        }
      },
    );
  }

  /// 构建图例贴纸组件的通用方法
  Widget _buildLegendStickerWidget(
    LegendItem item,
    legend_db.LegendItem legend,
    bool isLoading,
  ) {
    debugPrint('*** 构建图例贴纸Widget ***');
    debugPrint('图例ID: ${item.id}');
    debugPrint('图例是否可见: ${item.isVisible}');
    debugPrint('图例数据有图片: ${legend.hasImageData}');
    debugPrint('是否正在加载: $isLoading');

    if (!item.isVisible) {
      debugPrint('图例不可见，返回空Widget');
      return const SizedBox.shrink();
    }

    if (!legend.hasImageData && !isLoading) {
      debugPrint('图例没有图片数据且不在加载中，返回空Widget');
      return const SizedBox.shrink();
    }

    // 转换相对坐标到画布坐标
    final canvasPosition = Offset(
      item.position.dx * kCanvasWidth,
      item.position.dy * kCanvasHeight,
    );

    debugPrint('画布位置: (${canvasPosition.dx}, ${canvasPosition.dy})');

    // 计算图例的中心点（基于图例的中心点坐标）
    final imageSize = 60.0 * item.size; // 基础大小60像素
    final centerOffset = Offset(
      imageSize * legend.centerX,
      imageSize * legend.centerY,
    );

    debugPrint(
      '图片大小: $imageSize, 中心偏移: (${centerOffset.dx}, ${centerOffset.dy})',
    );

    Widget stickerWidget = Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        border: widget.selectedElementId == item.id
            ? Border.all(color: Colors.blue, width: 2)
            : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          if (legend.hasImageData && !isLoading)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: legend.fileType == legend_db.LegendFileType.svg
                  ? Opacity(
                      opacity: item.opacity,
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: ScalableImageWidget.fromSISource(
                          si: ScalableImageSource.fromSvgHttpUrl(
                            Uri.dataFromBytes(
                              legend.imageData!,
                              mimeType: 'image/svg+xml',
                            ),
                          ),
                        ),
                      ),
                    )
                  : Image.memory(
                      legend.imageData!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                      opacity: AlwaysStoppedAnimation(item.opacity),
                    ),
            )
          else
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.help_outline,
                        size: imageSize * 0.3,
                        color: Colors.grey[600],
                      ),
              ),
            ),
        ],
      ),
    );

    return Positioned(
      left: canvasPosition.dx - centerOffset.dx,
      top: canvasPosition.dy - centerOffset.dy,
      child: GestureDetector(
        onPanStart: widget.isPreviewMode
            ? null
            : (details) => _onLegendDragStart(item, details),
        onPanUpdate: widget.isPreviewMode
            ? null
            : (details) => _onLegendDragUpdate(item, details),
        onPanEnd: widget.isPreviewMode
            ? null
            : (details) => _onLegendDragEnd(item, details),
        onTap: () => _onLegendTap(item),
        onDoubleTap: () => _onLegendDoubleTap(item),
        child: Transform.rotate(
          angle: item.rotation * (3.14159 / 180), // 转换为弧度
          child: Opacity(
            opacity: item.isVisible ? 1.0 : 0.3,
            child: stickerWidget,
          ),
        ),
      ),
    );
  }

  /// 从VFS路径载入图例数据（兼容性方法）
  Future<legend_db.LegendItem?> _loadLegendFromPath(String legendPath) async {
    if (legendPath.isEmpty || !legendPath.endsWith('.legend')) {
      return null;
    }

    try {
      final legendService = LegendVfsService();
      // 从VFS路径解析图例标题和文件夹路径
      final pathParts = legendPath.split('/');
      if (pathParts.isEmpty) return null;

      final fileName = pathParts.last;
      final title = fileName.replaceAll('.legend', '');
      final folderPath = pathParts.length > 1
          ? pathParts.sublist(0, pathParts.length - 1).join('/')
          : null;

      return await legendService.getLegend(title, folderPath);
    } catch (e) {
      debugPrint('载入图例失败: $legendPath, 错误: $e');
      return null;
    }
  }

  // 图例拖拽相关方法
  LegendItem? _draggingLegendItem;
  Offset? _dragStartOffset; // 记录拖拽开始时的偏移量

  // 元素交互手势处理方法  /// 处理元素交互的点击事件
  void _onElementInteractionTapDown(TapDownDetails details) {
    final canvasPosition = _getCanvasPosition(
      details.localPosition,
    ); // 优先检测便签点击
    final hitStickyNote = _getHitStickyNote(canvasPosition);
    if (hitStickyNote != null) {
      // 检查是否点击了便签的特定区域
      final stickyNoteHitResult = StickyNoteGestureHelper.getStickyNoteHitType(
        canvasPosition,
        hitStickyNote,
        const Size(kCanvasWidth, kCanvasHeight),
      ); // 如果点击了折叠按钮，直接处理折叠操作
      if (stickyNoteHitResult == StickyNoteHitType.collapseButton &&
          widget.onStickyNoteUpdated != null) {
        final updatedNote = hitStickyNote.copyWith(
          isCollapsed: !hitStickyNote.isCollapsed,
          updatedAt: DateTime.now(),
        );
        widget.onStickyNoteUpdated!(updatedNote);
        return;
      }

      // 处理便签点击选中逻辑
      if (widget.selectedStickyNote?.id != hitStickyNote.id) {
        // 选中便签
        widget.onStickyNoteSelected?.call(hitStickyNote);
      } else {
        // 如果点击的是已选中的便签，取消选中
        widget.onStickyNoteSelected?.call(null);
      }
      return;
    }

    // 检查是否有选区，如果有则清除选区
    if (_selectionRect != null) {
      clearSelection();
      return; // 清除选区后直接返回，不进行其他操作
    }

    // 检测图例点击
    final hitLegendItem = _getHitLegendItem(canvasPosition);
    if (hitLegendItem != null) {
      // 没有选区，并且点击了图例，处理图例点击事件
      if (_canSelectLegendItem(hitLegendItem)) {
        // 图例可选择，触发点击事件
        _onLegendTap(hitLegendItem);
      } else {
        // 图例不可选择，显示提示信息
        _showLegendSelectionNotAllowedMessage(hitLegendItem);
      }
      return;
    }
    final hitElementId = _getHitElement(canvasPosition);

    // 如果有选中的便签，且点击位置不在任何便签上，则取消选中便签
    if (widget.selectedStickyNote != null && hitStickyNote == null) {
      widget.onStickyNoteSelected?.call(null);
    }

    // 处理元素选中逻辑
    if (widget.selectedElementId != null) {
      // 如果当前有选中的元素
      if (hitElementId == null || hitElementId != widget.selectedElementId) {
        // 如果点击的是空白区域或者其他元素，取消当前元素的选中
        widget.onElementSelected.call(null);
      }
      // 如果点击的是当前选中的元素，保持选中状态（不做任何操作）
    }

    // 注意：我们不在这里选中新元素，只能通过Z层级检视器选中
  }

  /// 捕获画布区域为RGBA格式的像素数据
  /// 注意：返回的是RGBA格式的数据，不再进行手动转换
  Future<Uint8List?> captureCanvasAreaToRgbaUint8List(Rect area) async {
    // Ensure the context is mounted before proceeding
    if (!_canvasGlobalKey.currentContext!.mounted) {
      // print("Error: RepaintBoundary context not mounted.");
      return null;
    }
    try {
      RenderRepaintBoundary? boundary =
          _canvasGlobalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        // print("Error: RepaintBoundary not found.");
        return null;
      }

      // Capture the image at its native resolution (kCanvasWidth x kCanvasHeight)
      // pixelRatio: 1.0 ensures the image dimensions match kCanvasWidth/kCanvasHeight.
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);

      try {
        // Get pixel data in RGBA format
        final ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (byteData == null) {
          // print("Error: Failed to get ByteData from image.");
          return null;
        }

        final Uint8List sourcePixelsRgba = byteData.buffer.asUint8List();
        final int sourceImageWidth =
            image.width; // Should be kCanvasWidth.round()
        final int sourceImageHeight =
            image.height; // Should be kCanvasHeight.round()

        // Define canvas bounds as a Rect
        final Rect canvasBounds = Rect.fromLTWH(
          0,
          0,
          sourceImageWidth.toDouble(),
          sourceImageHeight.toDouble(),
        );

        // Find the intersection of the requested area and the canvas bounds
        // This gives the actual area to crop, fully within the canvas.
        final Rect intersectionArea = area.intersect(canvasBounds);

        if (intersectionArea.isEmpty) {
          return Uint8List(
            0,
          ); // Return empty list if no overlap or area is invalid
        }

        // Convert intersectionArea to integer coordinates for pixel access
        final int cropX = intersectionArea.left.round();
        final int cropY = intersectionArea.top.round();
        final int cropWidth = intersectionArea.width.round();
        final int cropHeight = intersectionArea.height.round();

        // Ensure calculated width/height are not negative or zero after rounding and intersection
        if (cropWidth <= 0 || cropHeight <= 0) {
          return Uint8List(0);
        }
        final Uint8List destPixelsRgba = Uint8List(
          cropWidth * cropHeight * 4,
        ); // 4 bytes per RGBA pixel

        for (int y = 0; y < cropHeight; ++y) {
          for (int x = 0; x < cropWidth; ++x) {
            // Source pixel coordinates in the full image
            final int currentSourceX = cropX + x;
            final int currentSourceY = cropY + y;

            // Index in the source RGBA buffer
            final int sourceIndex =
                (currentSourceY * sourceImageWidth + currentSourceX) * 4;

            // Safety check, though intersection should make this unnecessary if logic is sound
            if (sourceIndex + 3 < sourcePixelsRgba.length) {
              final int r = sourcePixelsRgba[sourceIndex];
              final int g = sourcePixelsRgba[sourceIndex + 1];
              final int b = sourcePixelsRgba[sourceIndex + 2];
              final int a = sourcePixelsRgba[sourceIndex + 3];

              // Index in the destination RGBA buffer (保持RGBA格式)
              final int destIndex = (y * cropWidth + x) * 4;
              destPixelsRgba[destIndex] = r; // Red
              destPixelsRgba[destIndex + 1] = g; // Green
              destPixelsRgba[destIndex + 2] = b; // Blue
              destPixelsRgba[destIndex + 3] = a; // Alpha
            } else {
              // Fallback for any unexpected out-of-bounds access
              final int destIndex = (y * cropWidth + x) * 4;
              destPixelsRgba[destIndex] = 0; // Transparent black
              destPixelsRgba[destIndex + 1] = 0;
              destPixelsRgba[destIndex + 2] = 0;
              destPixelsRgba[destIndex + 3] = 0;
            }
          }
        }
        return destPixelsRgba;
      } finally {
        image
            .dispose(); // IMPORTANT: Dispose the ui.Image to free up native resources
      }
    } catch (e) {
      // print("Exception in captureCanvasAreaToRgbaUint8List: $e");
      return null;
    }
  }

  /// Gets the color of a single pixel at the specified [point] on the canvas.
  ///
  /// The [point] is an Offset in canvas coordinates (0,0 to kCanvasWidth, kCanvasHeight).
  /// Returns a [Color] object (ARGB), or null/transparent if the point is outside
  /// bounds or an error occurs.
  /// 后续功能
  Future<Color?> getPixelColorAtCanvasPoint(Offset point) async {
    if (!_canvasGlobalKey.currentContext!.mounted) {
      // print("Error: RepaintBoundary context not mounted.");
      return null;
    }

    final int x = point.dx.round();
    final int y = point.dy.round();

    // Check if point is outside the logical canvas dimensions
    final int canvasIntWidth = kCanvasWidth.round();
    final int canvasIntHeight = kCanvasHeight.round();

    if (x < 0 || x >= canvasIntWidth || y < 0 || y >= canvasIntHeight) {
      // print("Point ($x, $y) is outside canvas bounds ($canvasIntWidth, $canvasIntHeight). Returning transparent.");
      return Colors.transparent; // Or null, depending on desired behavior
    }

    try {
      RenderRepaintBoundary? boundary =
          _canvasGlobalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);

      try {
        final ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (byteData == null) return null;

        final Uint8List pixelsRgba = byteData.buffer.asUint8List();
        final int imageWidth = image.width; // Should be canvasIntWidth

        // Defensive check, in case image dimensions differ unexpectedly
        if (x < 0 || x >= image.width || y < 0 || y >= image.height) {
          // print("Point ($x, $y) is outside actual image dimensions (${image.width}, ${image.height}). Returning transparent.");
          return Colors.transparent;
        }

        final int index = (y * imageWidth + x) * 4; // 4 bytes per pixel (RGBA)

        if (index + 3 < pixelsRgba.length) {
          final int r = pixelsRgba[index];
          final int g = pixelsRgba[index + 1];
          final int b = pixelsRgba[index + 2];
          final int a = pixelsRgba[index + 3];
          return Color.fromARGB(a, r, g, b);
        } else {
          // Should not happen if point validation is correct
          // print("Calculated index is out of bounds for pixel data. Returning transparent.");
          return Colors.transparent; // Or null
        }
      } finally {
        image.dispose(); // IMPORTANT: Dispose the ui.Image
      }
    } catch (e) {
      // print("Exception in getPixelColorAtCanvasPoint: $e");
      return null;
    }
  }

  /// 检测点击位置是否命中某个图例项
  LegendItem? _getHitLegendItem(Offset canvasPosition) {
    // 按照渲染顺序（从上到下）检查所有可见的图例组
    for (final legendGroup in widget.mapItem.legendGroups.reversed) {
      if (!legendGroup.isVisible) continue;

      // 检查图例组中的每个图例项（按照渲染顺序）
      for (final item in legendGroup.legendItems.reversed) {
        if (!item.isVisible) continue;

        // 尝试从VFS路径载入图例数据（使用同步缓存或默认图例）
        // 注意：这里为了保持同步性，我们使用一个简化的处理
        // 实际的图例数据将在_buildLegendSticker中异步载入
        final legend = legend_db.LegendItem(
          title: '图例',
          centerX: 0.5,
          centerY: 0.5,
          version: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imageData: Uint8List(0), // 假设有图像数据，实际载入在渲染时进行
        );

        // 转换相对坐标到画布坐标
        final canvasItemPosition = Offset(
          item.position.dx * kCanvasWidth,
          item.position.dy * kCanvasHeight,
        );

        // 计算图例的实际显示区域
        final imageSize = 60.0 * item.size;
        final centerOffset = Offset(
          imageSize * legend.centerX,
          imageSize * legend.centerY,
        );

        // 修复：计算图例的实际显示矩形
        // 图例的左上角位置 = 图例中心位置 - 中心偏移
        final topLeft = Offset(
          canvasItemPosition.dx - centerOffset.dx,
          canvasItemPosition.dy - centerOffset.dy,
        );

        // 创建完整的图例显示区域矩形
        final itemRect = Rect.fromLTWH(
          topLeft.dx,
          topLeft.dy,
          imageSize,
          imageSize,
        ); // 检查点击位置是否在图例项的显示区域内
        if (itemRect.contains(canvasPosition)) {
          return item;
        }
      }
    }
    return null;
  }

  /// 检测点击位置是否命中某个便签
  StickyNote? _getHitStickyNote(Offset canvasPosition) {
    // 按照Z值倒序检查所有可见的便签（优先检查上层便签）
    final sortedStickyNotes = List<StickyNote>.from(widget.mapItem.stickyNotes)
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));

    for (final note in sortedStickyNotes) {
      if (!note.isVisible) continue;

      // 转换相对坐标到画布坐标
      final notePosition = Offset(
        note.position.dx * kCanvasWidth,
        note.position.dy * kCanvasHeight,
      );
      final noteSize = Size(
        note.size.width * kCanvasWidth,
        note.size.height * kCanvasHeight,
      );

      // 创建便签的矩形区域
      final noteRect = Rect.fromLTWH(
        notePosition.dx,
        notePosition.dy,
        noteSize.width,
        noteSize.height,
      );

      // 检查点击位置是否在便签区域内
      if (noteRect.contains(canvasPosition)) {
        return note;
      }
    }
    return null;
  } // 便签拖拽状态

  StickyNoteDragState? _stickyNoteDragState;

  void _onElementInteractionPanStart(DragStartDetails details) {
    final canvasPosition = _getCanvasPosition(details.localPosition);

    // ---：优先检测便签交互 ---
    final hitStickyNote = _getHitStickyNote(canvasPosition);
    if (hitStickyNote != null) {
      // 检查是否点击了便签的标题栏或调整柄
      final stickyNoteHitResult = StickyNoteGestureHelper.getStickyNoteHitType(
        canvasPosition,
        hitStickyNote,
        const Size(kCanvasWidth, kCanvasHeight),
      );
      if (stickyNoteHitResult != null && widget.onStickyNoteUpdated != null) {
        // 处理便签特定区域的手势
        _stickyNoteDragState = StickyNoteGestureHelper.handleStickyNotePanStart(
          hitStickyNote,
          stickyNoteHitResult,
          details,
          _getCanvasPosition,
          widget.onStickyNoteUpdated!,
        );

        // 如果是折叠按钮，handleStickyNotePanStart会返回null并直接处理折叠
        // 这种情况下我们不需要启动拖拽，直接返回
        return;
      } // 如果点击了便签但不是特定区域，选中便签但不处理拖拽
      if (widget.selectedStickyNote?.id != hitStickyNote.id) {
        // 选中便签（通过回调通知上层）
        widget.onStickyNoteSelected?.call(hitStickyNote);
      } else {
        // 如果点击的是已选中的便签，取消选中
        widget.onStickyNoteSelected?.call(null);
      }
      return;
    } // ---：优先检测图例交互 ---
    final hitLegendItem = _getHitLegendItem(canvasPosition);
    if (hitLegendItem != null) {
      // 检查图例是否已选中，只有选中的图例才能拖动
      if (widget.selectedElementId == hitLegendItem.id) {
        // 如果点击了已选中的图例，启动拖拽
        _onLegendDragStart(hitLegendItem, details);
      }
      return;
    }

    final hitElementId = _getHitElement(canvasPosition);

    // --- 步骤 1: 优先处理已选中的元素 ---
    if (widget.selectedElementId != null) {
      final selectedElement = widget.selectedLayer?.elements
          .where((e) => e.id == widget.selectedElementId)
          .firstOrNull;

      if (selectedElement != null) {
        // 获取用户偏好设置中的控制柄大小
        final userPrefsProvider = Provider.of<UserPreferencesProvider>(
          context,
          listen: false,
        );
        final handleSize =
            userPrefsProvider.tools.handleSize; // 1a. 检查是否点击了选中元素的【调整大小控制柄】
        final resizeHandle = _elementInteractionManager.getHitResizeHandle(
          canvasPosition,
          selectedElement,
          handleSize: handleSize,
        );
        if (resizeHandle != null) {
          _elementInteractionManager.onResizeStart(
            widget.selectedElementId!,
            resizeHandle,
            details,
            widget.selectedLayer!,
            _getCanvasPosition,
          );
          return; // 开始调整大小，操作结束
        }

        // 1b. 如果不是控制柄，检查是否点击了选中元素的【主体区域】
        //     这里直接使用 _isPointInElement，它不考虑 zIndex，只判断点是否在该元素的几何形状内。
        if (_elementInteractionManager.isPointInElement(
          canvasPosition,
          selectedElement,
        )) {
          _elementInteractionManager.onElementDragStart(
            widget.selectedElementId!,
            details,
            widget.selectedLayer!,
            _getCanvasPosition,
          );
          return; // 开始拖动选中的元素，操作结束
        }
        // 如果点击的不是选中元素的控制柄，也不是其主体区域，则继续往下走，
        // 看看是否点击了其他元素或者空白区域。
      }
    }

    // --- 步骤 2: 如果没有与预选中的元素发生交互 (或最初就没有元素被选中) ---
    // --- 则进行常规的命中检测，找出视觉上最顶层的元素 ---
    // --- 这时调用你提供的 _getHitElement 函数是合适的 ---

    if (hitElementId != null) {
      // 如果命中了某个元素 (根据 zIndex)
      if (hitElementId != widget.selectedElementId) {
        // 并且这个元素不是当前已经选中的元素 (如果是，上面的逻辑应该已经处理了)
        // 这种情况通常是用户点击了一个新的、未选中的元素。
        // 你可以在这里处理选中新元素的操作。
        // 例如: widget.onSelectElement(hitElementIdFromTop);
        debugPrint(
          "Hit a new element by z-order: $hitElementId. Consider selecting it.",
        );
        _startSelectionDrag(canvasPosition);
        // 根据你的设计，也可以在这里直接开始拖动新选中的元素：
        // widget.onSelectElement(hitElementIdFromTop);
        // _onElementDragStart(hitElementIdFromTop, details);
      } else {
        // 这个分支理论上不应该经常被走到，因为如果 hitElementIdFromTop 是 selectedElementId，
        // 并且不是控制柄，那么上面的 _isPointInElement(canvasPosition, selectedElement) 应该返回 true 并已处理。        // 但如果因为某种原因（例如 _isPointInElement 的判断逻辑和元素实际绘制区域有细微差别）走到了这里，
        // 那么意味着用户确实点击了已选中的元素（且它是最顶层），可以开始拖动。
        _elementInteractionManager.onElementDragStart(
          widget.selectedElementId!,
          details,
          widget.selectedLayer!,
          _getCanvasPosition,
        );
        return;
      }
    } else {
      // 点击了空白区域
      // 取消选中便签
      if (widget.selectedStickyNote != null) {
        widget.onStickyNoteSelected?.call(null);
      }
      // 取消选中元素
      widget.onElementSelected(null);
      _startSelectionDrag(canvasPosition);
    }
  }

  /// 处理元素交互的拖拽更新事件
  void _onElementInteractionPanUpdate(DragUpdateDetails details) {
    if (_stickyNoteDragState != null) {
      // 正在拖拽便签
      StickyNoteGestureHelper.handleStickyNotePanUpdate(
        _stickyNoteDragState!,
        details,
        _getCanvasPosition,
        const Size(kCanvasWidth, kCanvasHeight),
      );
    } else if (_draggingLegendItem != null) {
      // 正在拖拽图例
      _onLegendDragUpdate(_draggingLegendItem!, details);
    } else if (_elementInteractionManager.isResizing) {
      // 正在调整大小
      _elementInteractionManager.onResizeUpdate(
        _elementInteractionManager.resizingElementId!,
        details,
        widget.selectedLayer!,
        _getCanvasPosition,
      );
    } else if (_elementInteractionManager.isDragging) {
      // 正在拖拽元素
      _elementInteractionManager.onElementDragUpdate(
        _elementInteractionManager.draggingElementId!,
        details,
        widget.selectedLayer!,
        _getCanvasPosition,
      );
    } else {
      // 更新选区
      _updateSelectionDrag(details);
    }
  }

  /// 处理元素交互的拖拽结束事件
  void _onElementInteractionPanEnd(DragEndDetails details) {
    if (_stickyNoteDragState != null) {
      // 结束拖拽便签
      StickyNoteGestureHelper.handleStickyNotePanEnd(
        _stickyNoteDragState!,
        details,
        _getCanvasPosition,
        const Size(kCanvasWidth, kCanvasHeight),
        widget.mapItem.stickyNotes,
        (reorderedNotes) {
          widget.onStickyNotesReordered?.call(reorderedNotes);
        },
      );
      _stickyNoteDragState = null;
    } else if (_draggingLegendItem != null) {
      // 结束拖拽图例
      final item = _draggingLegendItem!;
      _onLegendDragEnd(item, details);
    } else if (_elementInteractionManager.isResizing) {
      // 结束调整大小
      _elementInteractionManager.onResizeEnd(
        _elementInteractionManager.resizingElementId!,
        details,
      );
    } else if (_elementInteractionManager.isDragging) {
      // 结束拖拽元素
      _elementInteractionManager.onElementDragEnd(
        _elementInteractionManager.draggingElementId!,
        details,
      );
    } else {
      // 完成选区创建
      _endSelectionDrag();
    }
  }

  /// 处理右键拖动开始（macOS触摸板两指拖动）
  void _onElementInteractionSecondaryPanStart(DragStartDetails details) {
    // 右键拖动行为与左键拖动相同，但可以在这里添加特殊逻辑
    _onElementInteractionPanStart(details);
  }

  /// 处理右键拖动更新（macOS触摸板两指拖动）
  void _onElementInteractionSecondaryPanUpdate(DragUpdateDetails details) {
    // 右键拖动行为与左键拖动相同
    _onElementInteractionPanUpdate(details);
  }

  /// 处理右键拖动结束（macOS触摸板两指拖动）
  void _onElementInteractionSecondaryPanEnd(DragEndDetails details) {
    // 右键拖动行为与左键拖动相同
    _onElementInteractionPanEnd(details);
  }

  /// 处理触摸板两指拖动开始事件
  void _onTrackpadPanZoomStart(PointerPanZoomStartEvent event) {
    // 将触摸板事件转换为拖动开始事件
    final details = DragStartDetails(
      sourceTimeStamp: event.timeStamp,
      globalPosition: event.position,
      localPosition: event.localPosition,
    );
    // 触摸板两指拖动被视为右键拖动
    _onElementInteractionSecondaryPanStart(details);
  }

  /// 处理触摸板两指拖动更新事件
  void _onTrackpadPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    // 将触摸板事件转换为拖动更新事件
    final details = DragUpdateDetails(
      sourceTimeStamp: event.timeStamp,
      delta: event.panDelta,
      primaryDelta: event.panDelta.dx,
      globalPosition: event.position,
      localPosition: event.localPosition,
    );
    // 触摸板两指拖动被视为右键拖动
    _onElementInteractionSecondaryPanUpdate(details);
  }

  /// 处理触摸板两指拖动结束事件
  void _onTrackpadPanZoomEnd(PointerPanZoomEndEvent event) {
    // 将触摸板事件转换为拖动结束事件
    final details = DragEndDetails(primaryVelocity: 0.0);
    // 触摸板两指拖动被视为右键拖动
    _onElementInteractionSecondaryPanEnd(details);
  }

  // 开始选区拖动
  void _startSelectionDrag(Offset startPosition) {
    _selectionStartPosition = startPosition;
    _isCreatingSelection = true;

    // 初始化选区（一个很小的矩形）
    _selectionRect = Rect.fromPoints(startPosition, startPosition);
    _selectionNotifier.value = _selectionRect;
  }

  // 更新选区拖动
  void _updateSelectionDrag(DragUpdateDetails details) {
    if (!_isCreatingSelection || _selectionStartPosition == null) return;

    final currentPosition = _getCanvasPosition(details.localPosition);

    setState(() {
      _selectionRect = Rect.fromPoints(
        _selectionStartPosition!,
        currentPosition,
      );
    });
    _selectionNotifier.value = _selectionRect;
  }

  // 结束选区拖动
  void _endSelectionDrag() {
    _isCreatingSelection = false;
    _selectionStartPosition = null;

    // 检查选区大小，如果太小就清除
    if (_selectionRect != null) {
      final minSize = 1.0; // 最小选区大小
      if (_selectionRect!.width < minSize && _selectionRect!.height < minSize) {
        clearSelection();
      }
    }
  }

  void _onLegendDragStart(LegendItem item, DragStartDetails details) {
    // 在拖动前检查是否满足选中条件
    if (!_canSelectLegendItem(item)) {
      _showLegendSelectionNotAllowedMessage(item);
      return;
    }

    _draggingLegendItem = item;

    // 计算拖拽开始时的偏移量（点击位置相对于图例中心的偏移）
    final canvasPosition = _getCanvasPosition(details.localPosition);
    final itemCanvasPosition = Offset(
      item.position.dx * kCanvasWidth,
      item.position.dy * kCanvasHeight,
    );

    _dragStartOffset = Offset(
      canvasPosition.dx - itemCanvasPosition.dx,
      canvasPosition.dy - itemCanvasPosition.dy,
    );

    setState(() {
      // 触发重绘以显示拖拽状态
    });
  }

  void _onLegendDragUpdate(LegendItem item, DragUpdateDetails details) {
    if (_draggingLegendItem?.id != item.id || _dragStartOffset == null) return;

    // 获取当前拖拽位置（不限制在画布范围内，以支持正确的偏移计算）
    final canvasPosition = _getCanvasPosition(details.localPosition);
    final adjustedPosition = Offset(
      canvasPosition.dx - _dragStartOffset!.dx,
      canvasPosition.dy - _dragStartOffset!.dy,
    );

    // 转换为相对坐标
    final relativePosition = Offset(
      adjustedPosition.dx / kCanvasWidth,
      adjustedPosition.dy / kCanvasHeight,
    );

    // 在相对坐标系统中限制范围（0.0 到 1.0）
    final clampedPosition = Offset(
      relativePosition.dx.clamp(0.0, 1.0),
      relativePosition.dy.clamp(0.0, 1.0),
    );

    // 更新图例位置
    _updateLegendItemPosition(item, clampedPosition);
  }

  void _onLegendDragEnd(LegendItem item, DragEndDetails details) {
    _draggingLegendItem = null;
    _dragStartOffset = null; // 清理偏移量
    // 保存更改到撤销历史
    // 这里可以通过回调通知主页面保存状态
  }

  void _onLegendTap(LegendItem item) {
    // 在选中前检查是否满足条件
    if (!_canSelectLegendItem(item)) {
      _showLegendSelectionNotAllowedMessage(item);
      return;
    }

    // 选中图例项，高亮显示
    widget.onLegendItemSelected.call(item.id);

    // 如果图例项有URL链接
    if (item.url != null && item.url!.isNotEmpty) {
      // 新增：支持脚本绑定
      if (item.url!.startsWith('script://')) {
        // 解析脚本URL，支持带参数的格式：script://scriptId?param1=value1&param2=value2
        final scriptUrl = item.url!.substring('script://'.length);
        final questionMarkIndex = scriptUrl.indexOf('?');
        final scriptId = questionMarkIndex != -1
            ? scriptUrl.substring(0, questionMarkIndex)
            : scriptUrl;

        // 解析参数
        Map<String, dynamic> runtimeParameters = {};
        if (questionMarkIndex != -1 &&
            questionMarkIndex < scriptUrl.length - 1) {
          final paramString = scriptUrl.substring(questionMarkIndex + 1);
          final paramPairs = paramString.split('&');
          for (final pair in paramPairs) {
            final equalIndex = pair.indexOf('=');
            if (equalIndex != -1) {
              final key = Uri.decodeComponent(pair.substring(0, equalIndex));
              final value = Uri.decodeComponent(pair.substring(equalIndex + 1));
              runtimeParameters[key] = value;
            }
          }
        }

        // 查找脚本并执行
        if (widget.scriptManager != null) {
          final scripts = widget.scriptManager!.scripts;
          final script = scripts.where((s) => s.id == scriptId).isNotEmpty
              ? scripts.firstWhere((s) => s.id == scriptId)
              : null;
          if (script != null) {
            widget.scriptManager!
                .executeScript(script.id, runtimeParameters: runtimeParameters)
                .catchError((error) {
                  if (context.mounted) {
                    context.showErrorSnackBar('脚本执行失败: $error');
                  }
                });
          } else {
            if (context.mounted) {
              context.showErrorSnackBar('未找到绑定的脚本: $scriptId');
            }
          }
        } else {
          if (context.mounted) {
            context.showErrorSnackBar('脚本管理器未初始化，无法执行脚本');
          }
        }
        return;
      }
      _openLegendUrl(item.url!);
    }
  }

  void _onLegendDoubleTap(LegendItem item) {
    // 在双击前检查是否满足条件
    if (!_canSelectLegendItem(item)) {
      _showLegendSelectionNotAllowedMessage(item);
      return;
    }

    // 双击图例项，触发双击回调
    widget.onLegendItemDoubleClicked.call(item);
  }

  /// 判断是否可以选择图例项
  /// 灵活的选择条件：
  /// 1. 图例组可见
  /// 2. 如果有绑定图层被直接选中，允许选择
  /// 3. 如果没有绑定图层被直接选中，但选中的图层组包含绑定图层，允许选择
  /// 4. 如果没有选中任何图层或图层组，基于最高优先级图层组的绑定图层允许选择
  bool _canSelectLegendItem(LegendItem item) {
    // 查找包含此图例项的图例组
    LegendGroup? containingGroup;
    for (final legendGroup in widget.mapItem.legendGroups) {
      if (legendGroup.legendItems.any(
        (legendItem) => legendItem.id == item.id,
      )) {
        containingGroup = legendGroup;
        break;
      }
    }

    if (containingGroup == null) {
      return false; // 找不到图例组
    }

    // 检查图例组是否可见
    if (!containingGroup.isVisible) {
      return false;
    }

    // 获取绑定的图层
    final boundLayers = widget.mapItem.layers.where((layer) {
      return layer.legendGroupIds.contains(containingGroup!.id);
    }).toList();

    if (boundLayers.isEmpty) {
      return true; // 如果没有绑定图层，允许选择
    }

    // 条件2：检查绑定的图层中是否有被直接选中的
    if (widget.selectedLayer != null) {
      if (boundLayers.any((layer) => layer.id == widget.selectedLayer!.id)) {
        return true;
      }
    }

    // 条件3：检查选中的图层组是否包含绑定图层
    if (widget.selectedLayer != null || _getSelectedLayerGroup().isNotEmpty) {
      final selectedGroup = _getSelectedLayerGroup();
      if (selectedGroup.isNotEmpty) {
        // 检查选中的图层组中是否包含绑定图层
        final selectedGroupIds = selectedGroup.map((l) => l.id).toSet();
        final boundLayerIds = boundLayers.map((l) => l.id).toSet();
        if (selectedGroupIds.intersection(boundLayerIds).isNotEmpty) {
          return true;
        }
      }
    }

    // 条件4：如果没有选中任何图层或图层组，基于最高优先级图层的绑定图层允许选择
    if (widget.selectedLayer == null && _getSelectedLayerGroup().isEmpty) {
      final highestPriorityLayers = _getHighestPriorityLayers();
      if (highestPriorityLayers.isNotEmpty) {
        final highestPriorityIds = highestPriorityLayers
            .map((l) => l.id)
            .toSet();
        final boundLayerIds = boundLayers.map((l) => l.id).toSet();
        if (highestPriorityIds.intersection(boundLayerIds).isNotEmpty) {
          return true;
        }
      }
    }

    return false;
  }

  /// 获取选中的图层组
  List<MapLayer> _getSelectedLayerGroup() {
    // 由于MapCanvas没有直接访问图层组选择状态的接口，
    // 这里返回基于显示顺序推断的最高优先级图层
    return _getHighestPriorityLayers();
  }

  /// 获取最高优先级的图层组（基于显示顺序或其他逻辑）
  List<MapLayer> _getHighestPriorityLayers() {
    // 使用传入的显示顺序图层，如果没有则使用默认排序
    final layersToUse = widget.displayOrderLayers ?? widget.mapItem.layers;

    if (layersToUse.isEmpty) {
      return [];
    }

    // 如果有显示顺序列表，最后几个图层具有最高优先级（后绘制的在上层）
    if (widget.displayOrderLayers != null &&
        widget.displayOrderLayers!.isNotEmpty) {
      final priorityLayers = widget.displayOrderLayers!.reversed
          .where((layer) => layer.isVisible)
          .take(3)
          .toList();
      return priorityLayers;
    }

    // 否则按 order 字段排序，获取最高优先级的图层
    final sortedLayers = List<MapLayer>.from(layersToUse)
      ..sort((a, b) => b.order.compareTo(a.order)); // 降序排列，最高优先级在前

    // 返回前几个可见的图层作为最高优先级图层
    return sortedLayers.where((layer) => layer.isVisible).take(3).toList();
  }

  /// 显示图例选择受限的消息
  void _showLegendSelectionNotAllowedMessage(LegendItem item) {
    // 查找包含此图例项的图例组
    LegendGroup? containingGroup;
    for (final legendGroup in widget.mapItem.legendGroups) {
      if (legendGroup.legendItems.any(
        (legendItem) => legendItem.id == item.id,
      )) {
        containingGroup = legendGroup;
        break;
      }
    }

    if (containingGroup == null) return;

    String message;
    if (!containingGroup.isVisible) {
      message = '无法操作图例：图例组"${containingGroup.name}"当前不可见';
    } else {
      message = '无法操作图例：请先选择一个绑定了图例组"${containingGroup.name}"的图层';
    }

    // 使用 SnackBar 显示消息，因为在 Canvas 中显示对话框可能会有问题
    if (context.mounted) {
      context.showInfoSnackBar(message);
    }
  }

  /// 打开图例URL链接
  Future<void> _openLegendUrl(String url) async {
    try {
      if (url.startsWith('indexeddb://')) {
        // VFS协议链接，使用VFS文件打开服务
        await VfsFileOpenerService.openFile(context, url);
      } else if (url.startsWith('http://') || url.startsWith('https://')) {
        // 网络链接，使用系统默认浏览器
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showUrlErrorMessage('无法打开链接: $url');
        }
      } else {
        _showUrlErrorMessage('不支持的链接格式: $url');
      }
    } catch (e) {
      _showUrlErrorMessage('打开链接失败: $e');
    }
  }

  /// 显示URL错误消息
  void _showUrlErrorMessage(String message) {
    if (context.mounted) {
      context.showErrorSnackBar(message);
    }
  }

  void _updateLegendItemPosition(LegendItem item, Offset newPosition) {
    // 找到包含此图例项的图例组
    for (final legendGroup in widget.mapItem.legendGroups) {
      final itemIndex = legendGroup.legendItems.indexWhere(
        (li) => li.id == item.id,
      );
      if (itemIndex != -1) {
        final updatedItem = item.copyWith(position: newPosition);
        final updatedItems = List<LegendItem>.from(legendGroup.legendItems);
        updatedItems[itemIndex] = updatedItem;

        final updatedGroup = legendGroup.copyWith(
          legendItems: updatedItems,
          updatedAt: DateTime.now(),
        );

        widget.onLegendGroupUpdated(updatedGroup);
        break;
      }
    }
  }

  /// 更新便签透明度
  void _updateStickyNoteOpacity(String noteId, double opacity) {
    widget.onStickyNoteOpacityChanged?.call(noteId, opacity);
  }

  // 用于存储绘制时降低透明度的便签原始透明度
  final Map<String, double> _originalOpacityBeforeDrawing = {};

  void _onDrawingStart(DragStartDetails details) {
    final canvasPosition = _getCanvasPosition(details.localPosition);

    // 检查是否点击在便签内容区域
    bool isDrawingOnStickyNote = false;
    if (widget.selectedStickyNote != null &&
        widget.onStickyNoteUpdated != null) {
      final stickyNote = widget.selectedStickyNote!;
      final stickyNotePosition = Offset(
        stickyNote.position.dx * kCanvasWidth,
        stickyNote.position.dy * kCanvasHeight,
      );
      final stickyNoteSize = Size(
        stickyNote.size.width * kCanvasWidth,
        stickyNote.size.height * kCanvasHeight,
      );

      // 计算内容区域的边界（排除标题栏和padding）
      const double titleBarHeight = 36.0; // 标题栏固定高度
      const double contentPadding = 10.0; // 内容区域的 padding

      final contentAreaRect = Rect.fromLTWH(
        stickyNotePosition.dx + contentPadding,
        stickyNotePosition.dy + titleBarHeight + contentPadding,
        stickyNoteSize.width - (contentPadding * 2),
        stickyNoteSize.height - titleBarHeight - (contentPadding * 2),
      );

      if (contentAreaRect.contains(canvasPosition)) {
        isDrawingOnStickyNote = true; // Drawing on sticky note content area
        _drawingToolManager.onStickyNoteDrawingStart(
          details,
          stickyNote,
          _effectiveDrawingTool,
          _effectiveColor,
          _effectiveStrokeWidth,
          _effectiveDensity,
          _effectiveCurvature,
          _effectiveTriangleCut,
          widget.onStickyNoteUpdated!,
          imageBufferData: widget.imageBufferData, // 传递图片缓冲区数据
          imageBufferFit: widget.imageBufferFit, // 传递图片适应方式
        );
        return;
      }
    }

    // 如果没有在便签内容区域绘制，但有选中的图层，则可以在画布上绘制
    if (!isDrawingOnStickyNote && widget.selectedLayer != null) {
      _drawingToolManager.onDrawingStart(
        details,
        _effectiveDrawingTool,
        _effectiveColor,
        _effectiveStrokeWidth,
        _effectiveDensity,
        _effectiveCurvature,
        _effectiveTriangleCut,
      );
    }
  }

  void _onDrawingUpdate(DragUpdateDetails details) {
    final canvasPosition = _getCanvasPosition(details.localPosition);

    // Check if drawing on sticky note
    if (_drawingToolManager.currentDrawingStickyNote != null) {
      _drawingToolManager.onStickyNoteDrawingUpdate(
        details,
        _effectiveDrawingTool,
        _effectiveColor,
        _effectiveStrokeWidth,
        _effectiveDensity,
        _effectiveCurvature,
        _effectiveTriangleCut,
      );
    } else {
      // Normal layer drawing - 处理便签透明度调整
      _handleStickyNoteOpacityDuringDrawing(canvasPosition);

      _drawingToolManager.onDrawingUpdate(
        details,
        _effectiveDrawingTool,
        _effectiveColor,
        _effectiveStrokeWidth,
        _effectiveDensity,
        _effectiveCurvature,
        _effectiveTriangleCut,
      );
    }
  }

  /// 处理绘制过程中的便签透明度调整
  void _handleStickyNoteOpacityDuringDrawing(Offset canvasPosition) {
    if (!_drawingToolManager.isDrawing) return;

    // 检查当前位置是否在任何便签内部
    for (final note in widget.mapItem.stickyNotes) {
      if (!note.isVisible) continue;

      final notePosition = Offset(
        note.position.dx * kCanvasWidth,
        note.position.dy * kCanvasHeight,
      );
      final noteSize = Size(
        note.size.width * kCanvasWidth,
        note.size.height * kCanvasHeight,
      );

      final noteRect = Rect.fromLTWH(
        notePosition.dx,
        notePosition.dy,
        noteSize.width,
        noteSize.height,
      );

      if (noteRect.contains(canvasPosition)) {
        // 指针在便签内部，检查透明度是否需要调整
        final currentOpacity =
            widget.previewStickyNoteOpacityValues[note.id] ?? note.opacity;
        if (currentOpacity > 0.3) {
          // 保存原始透明度（如果还没有保存）
          if (!_originalOpacityBeforeDrawing.containsKey(note.id)) {
            _originalOpacityBeforeDrawing[note.id] = currentOpacity;
          }
          // 调整透明度到30%
          _updateStickyNoteOpacity(note.id, 0.3);
        }
      } else {
        // 指针不在便签内部，如果之前调整过透明度，恢复原始透明度
        if (_originalOpacityBeforeDrawing.containsKey(note.id)) {
          final originalOpacity = _originalOpacityBeforeDrawing[note.id]!;
          _updateStickyNoteOpacity(note.id, originalOpacity);
          _originalOpacityBeforeDrawing.remove(note.id);
        }
      }
    }
  }

  // 获取相对于画布的正确坐标
  Offset _getCanvasPosition(Offset localPosition) {
    // localPosition 已经是相对于画布容器的坐标
    // 对于绘制操作，需要限制在画布范围内
    // 对于拖拽操作，不应该限制以避免偏移量计算错误
    return localPosition;
  }

  void _onDrawingEnd(DragEndDetails details) {
    // 恢复所有因绘制而调整的便签透明度
    for (final entry in _originalOpacityBeforeDrawing.entries) {
      _updateStickyNoteOpacity(entry.key, entry.value);
    }
    _originalOpacityBeforeDrawing.clear();

    // Check if drawing on sticky note
    if (_drawingToolManager.currentDrawingStickyNote != null) {
      _drawingToolManager.onStickyNoteDrawingEnd(
        details,
        _effectiveDrawingTool,
        _effectiveColor,
        _effectiveStrokeWidth,
        _effectiveDensity,
        _effectiveCurvature,
        _effectiveTriangleCut,
        widget.onStickyNoteUpdated!,
        imageBufferData: widget.imageBufferData, // 传递图片缓冲区数据
        imageBufferFit: widget.imageBufferFit, // 传递图片适应方式
      );
    } else {
      // Normal layer drawing
      _drawingToolManager.onDrawingEnd(
        details,
        _effectiveDrawingTool,
        _effectiveColor,
        _effectiveStrokeWidth,
        _effectiveDensity,
        _effectiveCurvature,
        _effectiveTriangleCut,
        widget.selectedLayer,
        widget.imageBufferData,
        widget.imageBufferFit,
      );
    }
  }

  /// 构建按层级排序的所有元素（支持增量更新）
  List<Widget> _buildLayeredElements() {
    // debugPrint('=== 开始构建图层元素 (增量更新模式) ===');

    final List<_LayeredElement> allElements = [];

    // 使用传入的显示顺序图层，如果没有则使用默认排序
    final layersToRender = widget.displayOrderLayers ?? widget.mapItem.layers;
    final sortedLayers = List<MapLayer>.from(layersToRender);

    // 如果没有传入显示顺序，则按 order 排序
    if (widget.displayOrderLayers == null) {
      sortedLayers.sort((a, b) => a.order.compareTo(b.order));
      // debugPrint('使用默认图层排序（按 order 字段）');
    } else {
      // debugPrint('使用传入的显示顺序图层列表');
    } // 收集所有图层及其元素（按照排序后的顺序）- 支持增量更新
    for (int layerIndex = 0; layerIndex < sortedLayers.length; layerIndex++) {
      final layer = sortedLayers[layerIndex];
      if (!layer.isVisible) {
        debugPrint('跳过不可见图层: ${layer.name}');
        continue;
      }

      final isSelectedLayer = widget.selectedLayer?.id == layer.id;

      // debugPrint(
      //   '处理图层: ${layer.name}(order=${layer.order}), 索引=$layerIndex, 可见=${layer.isVisible}',
      // );
      // debugPrint('是否选中: $isSelectedLayer');

      // 关键修改：使用 layerIndex 作为渲染顺序，而不是 layer.order
      final renderOrder = layerIndex;

      // 增量更新：只处理脏图层或在全量构建模式下

      // 添加图层图片（如果有）
      if (layer.imageData != null) {
        // debugPrint(
        //   '添加图层图片元素 - renderOrder=$renderOrder (原order=${layer.order}), selected=$isSelectedLayer',
        // );
        allElements.add(
          _LayeredElement(
            order: renderOrder, // 使用在显示列表中的位置索引
            isSelected: isSelectedLayer,
            widget: _buildLayerImageWidget(layer),
          ),
        );
      }

      // 添加图层绘制元素
      // debugPrint(
      //   '添加图层绘制元素 - renderOrder=$renderOrder (原order=${layer.order}), selected=$isSelectedLayer',
      // );
      allElements.add(
        _LayeredElement(
          order: renderOrder, // 使用在显示列表中的位置索引
          isSelected: isSelectedLayer,
          widget: _buildLayerWidget(layer),
        ),
      );
    }
    // debugPrint('--- 处理图例组 (增量更新) ---');
    // 收集所有图例组 - 支持增量更新
    for (final legendGroup in widget.mapItem.legendGroups) {
      if (!legendGroup.isVisible) {
        debugPrint('跳过不可见图例组: ${legendGroup.name}');
        continue;
      }

      // 计算图例组的层级（基于绑定的最高图层在显示列表中的位置）
      int legendRenderOrder = -1;
      bool isLegendSelected = false;
      List<String> boundLayerNames = [];

      for (int i = 0; i < sortedLayers.length; i++) {
        final layer = sortedLayers[i];
        if (layer.legendGroupIds.contains(legendGroup.id)) {
          boundLayerNames.add('${layer.name}(${layer.order})');
          legendRenderOrder = math.max(legendRenderOrder, i); // 使用位置索引而不是order
          // 如果任何绑定的图层被选中，图例也被认为是选中的
          if (widget.selectedLayer?.id == layer.id) {
            isLegendSelected = true;
          }
        }
      }

      debugPrint('绑定的图层: $boundLayerNames');
      debugPrint('计算得到的 legendRenderOrder: $legendRenderOrder');
      debugPrint('是否选中: $isLegendSelected');

      // 如果图例组没有绑定到任何图层，使用默认位置
      if (legendRenderOrder == -1) {
        legendRenderOrder = 0;
        debugPrint('图例组没有绑定图层，使用默认 renderOrder: $legendRenderOrder');
      }

      debugPrint(
        '添加图例组元素 - renderOrder=$legendRenderOrder, selected=$isLegendSelected',
      );
      allElements.add(
        _LayeredElement(
          order: legendRenderOrder,
          isSelected: isLegendSelected,
          widget: _buildLegendWidget(legendGroup),
        ),
      );
    }
    // debugPrint('--- 处理便签 (增量更新) ---');
    // 收集所有便签（按zIndex排序）- 支持增量更新
    final sortedStickyNotes = List<StickyNote>.from(widget.mapItem.stickyNotes)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (int noteIndex = 0; noteIndex < sortedStickyNotes.length; noteIndex++) {
      final note = sortedStickyNotes[noteIndex];
      if (!note.isVisible) {
        debugPrint('跳过不可见便签: ${note.title}');
        continue;
      }

      final isSelectedNote = widget.selectedStickyNote?.id == note.id;

      debugPrint(
        '处理便签: ${note.title}(zIndex=${note.zIndex}), 索引=$noteIndex, 可见=${note.isVisible}',
      );
      debugPrint('是否选中: $isSelectedNote'); // 便签在图层和图例之上显示，使用非常高的渲染顺序，确保始终在最上层
      // 使用 1000000 + noteIndex 确保便签始终在所有其他元素之上
      final renderOrder = 1000000 + noteIndex;

      debugPrint(
        '添加便签元素 - renderOrder=$renderOrder (原zIndex=${note.zIndex}), selected=$isSelectedNote',
      );
      allElements.add(
        _LayeredElement(
          order: renderOrder,
          isSelected: isSelectedNote,
          widget: _buildStickyNoteWidget(note),
        ),
      );
    }
    // debugPrint('--- 排序前的元素列表 ---');
    // debugPrint('本次构建的组件数量: ${allElements.length}');
    // for (int i = 0; i < allElements.length; i++) {
    //   final element = allElements[i];
    //   final typeDescription =
    //       element.widget.runtimeType.toString().contains('LayerImageWidget')
    //       ? '图层图片'
    //       : element.widget.runtimeType.toString().contains('LayerWidget')
    //       ? '图层绘制'
    //       : element.widget.runtimeType.toString().contains('LegendWidget')
    //       ? '图例组'
    //       : element.widget.runtimeType.toString().contains('StickyNoteWidget')
    //       ? '便签'
    //       : '未知类型';
    //   debugPrint(
    //     '[$i] $typeDescription - renderOrder=${element.order}, selected=${element.isSelected}',
    //   );
    // } // 按 renderOrder 排序，但便签始终在最上层
    allElements.sort((a, b) {
      // 检查是否是便签元素
      final aIsStickyNote =
          a.widget.runtimeType.toString().contains('StickyNoteWidget') ||
          a.order >= 1000000;
      final bIsStickyNote =
          b.widget.runtimeType.toString().contains('StickyNoteWidget') ||
          b.order >= 1000000;

      // 便签始终在非便签元素之上
      if (aIsStickyNote && !bIsStickyNote) return 1;
      if (!aIsStickyNote && bIsStickyNote) return -1;

      // 如果都是便签，或都不是便签，则按选中状态和renderOrder排序
      if (a.isSelected && !b.isSelected) return 1;
      if (!a.isSelected && b.isSelected) return -1;
      return a.order.compareTo(b.order);
    });
    // debugPrint('--- 排序后的渲染顺序 (从底层到顶层) ---');
    // for (int i = 0; i < allElements.length; i++) {
    // final element = allElements[i];
    // final typeDescription =
    //     element.widget.runtimeType.toString().contains('LayerImageWidget')
    //     ? '图层图片'
    //     : element.widget.runtimeType.toString().contains('LayerWidget')
    //     ? '图层绘制'
    //     : element.widget.runtimeType.toString().contains('LegendWidget')
    //     ? '图例组'
    //     : element.widget.runtimeType.toString().contains('StickyNoteWidget')
    //     ? '便签'
    //     : '未知类型';
    // debugPrint(
    //   '渲染[$i] $typeDescription - renderOrder=${element.order}, selected=${element.isSelected}',
    // );
    // }

    // debugPrint('=== 图层元素构建完成 ===');
    return allElements.map((e) => e.widget).toList();
  }

  // 绘画元素选择和操作相关方法
  /// 检测点击位置是否命中某个绘画元素
  String? _getHitElement(Offset canvasPosition) {
    return _elementInteractionManager.getHitElement(
      canvasPosition,
      widget.selectedLayer,
    );
  }

  @override
  void didUpdateWidget(MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检查图片缓冲区是否发生变化
    if (widget.imageBufferData != oldWidget.imageBufferData) {
      _handleImageBufferChange();
    }

    // 检查图层元素是否有新的图片需要解码
    if (oldWidget.selectedLayer != widget.selectedLayer) {
      _preloadLayerImages();
    }

    //：检查是否是新地图或图层数据发生了变化，如果是则预加载所有图片
    if (oldWidget.mapItem != widget.mapItem) {
      // 清理所有图片缓存，因为地图数据已经完全改变
      _clearAllImageCache();
      _preloadAllLayerImages();
    } else {
      // 检查图层元素是否发生变化（撤销/重做等操作）
      _checkAndCleanOrphanedImageCache();
    }
  }

  /// 清理所有图片缓存
  void _clearAllImageCache() {
    // 释放所有缓存的图片资源
    for (final image in _imageCache.values) {
      image.dispose();
    }
    _imageCache.clear();
    _imageDecodingFutures.clear();

    debugPrint('已清理所有图片缓存');
  }

  /// 检查并清理孤立的图片缓存（元素已删除但缓存仍存在）
  void _checkAndCleanOrphanedImageCache() {
    if (widget.mapItem.layers.isEmpty) {
      _clearAllImageCache();
      return;
    }

    // 收集所有当前存在的图片元素ID
    final Set<String> currentElementIds = {};
    for (final layer in widget.mapItem.layers) {
      for (final element in layer.elements) {
        if (element.type == DrawingElementType.imageArea &&
            element.imageData != null) {
          currentElementIds.add(element.id);
        }
      }
    }

    // 找出需要清理的缓存项（元素已删除）
    final List<String> orphanedCacheKeys = [];
    for (final cacheKey in _imageCache.keys) {
      if (!currentElementIds.contains(cacheKey)) {
        orphanedCacheKeys.add(cacheKey);
      }
    }

    // 清理孤立的缓存项
    for (final key in orphanedCacheKeys) {
      final image = _imageCache.remove(key);
      image?.dispose();
      _imageDecodingFutures.remove(key);
    }

    if (orphanedCacheKeys.isNotEmpty) {
      debugPrint(
        '已清理 ${orphanedCacheKeys.length} 个孤立的图片缓存项: $orphanedCacheKeys',
      );

      // 触发重绘以反映缓存清理的结果
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 预加载图层中的图片元素
  Future<void> _preloadLayerImages() async {
    if (widget.selectedLayer == null) return;

    for (final element in widget.selectedLayer!.elements) {
      if (element.type == DrawingElementType.imageArea &&
          element.imageData != null) {
        await _getOrDecodeElementImage(element);
      }
    }
  }

  /// 预加载所有图层的图片元素
  /// 在地图初始化时调用，确保所有图片立即显示
  Future<void> _preloadAllLayerImages() async {
    for (final layer in widget.mapItem.layers) {
      for (final element in layer.elements) {
        if (element.type == DrawingElementType.imageArea &&
            element.imageData != null) {
          await _getOrDecodeElementImage(element);
        }
      }
    }
  }

  /// 获取或解码元素图片
  Future<ui.Image?> _getOrDecodeElementImage(MapDrawingElement element) async {
    final cacheKey = element.id;

    // 如果已经缓存，直接返回

    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }

    // 如果正在解码，返回正在进行的Future
    if (_imageDecodingFutures.containsKey(cacheKey)) {
      return _imageDecodingFutures[cacheKey];
    }

    // 开始新的解码过程
    if (element.imageData != null) {
      final decodingFuture = _decodeElementImage(element.imageData!, cacheKey);
      _imageDecodingFutures[cacheKey] = decodingFuture;
      return decodingFuture;
    }

    return null;
  }

  /// 解码元素图片
  Future<ui.Image?> _decodeElementImage(
    Uint8List imageData,
    String cacheKey,
  ) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();

      // 缓存解码结果
      _imageCache[cacheKey] = frame.image;
      _imageDecodingFutures.remove(cacheKey);

      // 触发重绘
      if (mounted) {
        setState(() {});
      }

      return frame.image;
    } catch (e) {
      debugPrint('Failed to decode image for element $cacheKey: $e');
      _imageDecodingFutures.remove(cacheKey);
      return null;
    }
  }

  /// 处理图片缓冲区变化
  void _handleImageBufferChange() {
    // 如果图片缓冲区清空了
    if (widget.imageBufferData == null) {
      _imageBufferCachedImage?.dispose();
      _imageBufferCachedImage = null;
      _lastImageBufferData = null;
      return;
    }

    // 如果图片数据没有变化，不需要重新解码
    if (widget.imageBufferData == _lastImageBufferData) {
      return;
    }
    _lastImageBufferData = widget.imageBufferData;

    // 开始异步解码新图片
    _decodeImageBuffer(widget.imageBufferData!);
  }

  /// 异步解码图片缓冲区
  Future<ui.Image?> _decodeImageBuffer(Uint8List imageData) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();

      // 释放旧的缓存图片
      _imageBufferCachedImage?.dispose();
      _imageBufferCachedImage = frame.image;

      // 触发重绘
      if (mounted) {
        setState(() {});
      }

      return frame.image;
    } catch (e) {
      debugPrint('Failed to decode image buffer: $e');
      return null;
    }
  }

  /// 处理文本工具点击
  void _handleTextToolTap(Offset canvasPosition) {
    // 首先检查是否点击在选中的便签内
    if (widget.selectedStickyNote != null) {
      // 检查是否在便签的内容区域内
      final hitStickyNote = _getHitStickyNote(canvasPosition);
      if (hitStickyNote != null &&
          hitStickyNote.id == widget.selectedStickyNote!.id) {
        // 在选中的便签内，检查是否在内容区域
        if (_isInStickyNoteContentArea(
          canvasPosition,
          widget.selectedStickyNote!,
        )) {
          // 在便签内容区域，创建便签文本元素
          _drawingToolManager.showStickyNoteTextInputDialog(
            canvasPosition,
            widget.selectedStickyNote!,
            _effectiveColor,
            _effectiveStrokeWidth,
            _effectiveDensity,
            _effectiveCurvature,
            widget.onStickyNoteUpdated!,
          );
          return;
        }
      }
    }

    // 如果不在便签内容区域，且有选中的图层，则在图层上创建文本
    if (widget.selectedLayer != null) {
      _drawingToolManager.showTextInputDialog(
        canvasPosition,
        widget.selectedLayer!,
        _effectiveColor,
        _effectiveStrokeWidth,
        _effectiveDensity,
        _effectiveCurvature,
      );
    }
  }

  /// 检查点击位置是否在便签的内容区域内
  bool _isInStickyNoteContentArea(Offset canvasPosition, StickyNote note) {
    // 转换便签的相对坐标到画布坐标
    final notePosition = Offset(
      note.position.dx * kCanvasWidth,
      note.position.dy * kCanvasHeight,
    );
    final noteSize = Size(
      note.size.width * kCanvasWidth,
      note.size.height * kCanvasHeight,
    );

    // 计算内容区域边界（排除标题栏和padding）
    const double titleBarHeight = 36.0; // 标题栏固定高度
    const double contentPadding = 10.0; // 内容区域的 padding

    final contentAreaRect = Rect.fromLTWH(
      notePosition.dx + contentPadding,
      notePosition.dy + titleBarHeight + contentPadding,
      noteSize.width - (contentPadding * 2),
      noteSize.height - titleBarHeight - (contentPadding * 2),
    );

    return contentAreaRect.contains(canvasPosition);
  }
}

/// 选区绘制器
class _SelectionPainter extends CustomPainter {
  final Rect? selectionRect;

  _SelectionPainter(this.selectionRect);
  @override
  void paint(Canvas canvas, Size size) {
    if (selectionRect == null) return;

    BackgroundRenderer.drawSelection(canvas, selectionRect!);
  }

  @override
  bool shouldRepaint(_SelectionPainter oldDelegate) {
    return oldDelegate.selectionRect != selectionRect;
  }
}

class _LayerPainter extends CustomPainter {
  final MapLayer layer;
  final bool isEditMode;
  final String? selectedElementId;
  final double? handleSize;
  final Map<String, ui.Image> imageCache; // 元素图片缓存
  final ui.Image? imageBufferCachedImage; // 图片缓冲区缓存
  final Uint8List? currentImageBufferData; // 当前图片缓冲区数据
  final BoxFit imageBufferFit; // 图片缓冲区适应方式
  final BuildContext? context; // 添加context用于主题适配

  _LayerPainter({
    required this.layer,
    required this.isEditMode,
    this.selectedElementId,
    this.handleSize,
    required this.imageCache,
    this.imageBufferCachedImage,
    this.currentImageBufferData,
    this.imageBufferFit = BoxFit.contain,
    this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 检查是否启用了画布主题适配
    bool shouldApplyThemeAdaptation = false;
    if (context != null) {
      final theme = Theme.of(context!);
      final isDarkMode = theme.brightness == Brightness.dark;

      try {
        final userPrefs = Provider.of<UserPreferencesProvider>(
          context!,
          listen: false,
        );
        final canvasThemeAdaptation = userPrefs.theme.canvasThemeAdaptation;
        shouldApplyThemeAdaptation = canvasThemeAdaptation && isDarkMode;

        // 调试信息
        // debugPrint('=== 画布主题适配调试 ===');
        // debugPrint('isDarkMode: $isDarkMode');
        // debugPrint('canvasThemeAdaptation: $canvasThemeAdaptation');
        // debugPrint('shouldApplyThemeAdaptation: $shouldApplyThemeAdaptation');
      } catch (e) {
        // 如果无法获取用户偏好，使用默认值
        debugPrint('获取用户偏好失败: $e');
        shouldApplyThemeAdaptation = false;
      }
    } else {
      debugPrint('context为null，无法获取主题信息');
    }

    // 根据主题适配状态设置或移除滤镜
    if (!ColorFilterSessionManager().isThemeAdaptationUserDisabled(layer.id)) {
      if (shouldApplyThemeAdaptation) {
        final themeAdaptationSettings = const ColorFilterSettings(
          type: ColorFilterType.brightness,
          intensity: 1.0,
          brightness: 0.5, // 提高亮度
        );

        // 始终设置主题适配滤镜（如果需要的话）
        ColorFilterSessionManager().setThemeAdaptationFilter(
          layer.id,
          themeAdaptationSettings,
        );
        debugPrint('为图层 ${layer.id} 设置主题适配滤镜');
      } else {
        // 如果主题适配被禁用，移除主题适配滤镜
        ColorFilterSessionManager().setThemeAdaptationFilter(layer.id, null);
        // debugPrint('移除图层 ${layer.id} 的主题适配滤镜');
      }
    }

    // 获取图层的色彩滤镜设置（包含主题适配和用户设置）
    final filterSettings = ColorFilterSessionManager().getLayerFilter(layer.id);
    final combinedColorFilter = filterSettings?.toColorFilter();

    // 调试信息
    // debugPrint('图层ID: ${layer.id}, 应用滤镜: ${combinedColorFilter != null}');

    // 按 z 值排序元素
    final sortedElements = List<MapDrawingElement>.from(layer.elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    // 找到所有橡皮擦元素
    final eraserElements = sortedElements
        .where((e) => e.type == DrawingElementType.eraser)
        .toList();

    // 图层元素统计
    final nonEraserCount = sortedElements
        .where((e) => e.type != DrawingElementType.eraser)
        .length;
    // debugPrint(
    //   // '图层 ${layer.id}: 总元素${sortedElements.length}, 非橡皮擦${nonEraserCount}',
    // );

    // 如果有色彩滤镜，对整个图层应用滤镜
    if (combinedColorFilter != null) {
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..colorFilter = combinedColorFilter,
      );
    }

    // 绘制所有常规元素
    for (final element in sortedElements) {
      if (element.type == DrawingElementType.eraser) {
        continue; // 橡皮擦本身不绘制
      }

      // 使用裁剪来实现选择性遮挡
      EraserRenderer.drawElementWithEraserMask(
        canvas,
        element,
        eraserElements,
        size,
        imageCache: imageCache,
        imageBufferCachedImage: imageBufferCachedImage,
        currentImageBufferData: currentImageBufferData,
        imageBufferFit: imageBufferFit,
      );
    }

    // 如果应用了色彩滤镜，恢复画布状态
    if (combinedColorFilter != null) {
      canvas.restore();
    }

    // 最后绘制选中元素的彩虹效果，确保它不受任何遮挡（不应用滤镜）
    if (selectedElementId != null) {
      final selectedElement = sortedElements
          .where((e) => e.id == selectedElementId)
          .firstOrNull;
      if (selectedElement != null) {
        HighlightRenderer.drawRainbowHighlight(canvas, selectedElement, size);
        HighlightRenderer.drawResizeHandles(
          canvas,
          selectedElement,
          size,
          handleSize: handleSize,
        );
      }
    }
  }

  /// 检查矩形是否与橡皮擦形状重叠
  /// 检查矩形是否与橡皮擦形状重叠
  // bool _isRectOverlappingEraserShape(
  //   Rect elementRect,
  //   Rect eraserRect,
  //   double curvature,
  // ) {
  //   // 检查矩形的角点和中点是否有任何一个在椭圆内  <--- 注意这里的注释
  //   final testPoints = [
  //     elementRect.topLeft,
  //     elementRect.topRight,
  //     elementRect.bottomLeft,
  //     elementRect.bottomRight,
  //     elementRect.center,
  //     Offset(elementRect.center.dx, elementRect.top), // 上中
  //     Offset(elementRect.center.dx, elementRect.bottom), // 下中
  //     Offset(elementRect.left, elementRect.center.dy), // 左中
  //     Offset(elementRect.right, elementRect.center.dy), // 右中
  //   ];

  //   for (final point in testPoints) {
  //     // 关键调用：这里使用了 _isPointInEraserShape
  //     if (_isPointInEraserShape(point, eraserRect, curvature)) {
  //       return true;
  //     }
  //   }

  //     // 如果没有点在椭圆内，还需要检查椭圆是否完全在矩形内 <--- 注意这里的注释
  //   // 这个检查的是 eraserRect (橡皮擦的包围盒) 是否在 elementRect 内部
  //   if (eraserRect.left >= elementRect.left &&
  //       eraserRect.right <= elementRect.right &&
  //       eraserRect.top >= elementRect.top &&
  //       eraserRect.bottom <= elementRect.bottom) {
  //     return true;
  //   }

  //   return false;
  // }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _CurrentDrawingPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final DrawingElementType elementType;
  final Color color;
  final double strokeWidth;
  final double density;
  final double curvature; // 曲率参数
  final TriangleCutType triangleCut; // 三角形切割类型
  final List<Offset>? freeDrawingPath; // 自由绘制路径
  final String? selectedElementId; // 当前选中的元素ID
  final StickyNote? targetStickyNote; // 目标便签

  _CurrentDrawingPainter({
    required this.start,
    required this.end,
    required this.elementType,
    required this.color,
    required this.strokeWidth,
    required this.density,
    required this.curvature,
    required this.triangleCut,
    this.freeDrawingPath,
    this.selectedElementId,
    this.targetStickyNote,
  });
  @override
  void paint(Canvas canvas, Size size) {
    if (targetStickyNote != null) {
      // Drawing on sticky note - transform coordinates
      _drawOnStickyNote(canvas, size);
    } else {
      // Normal canvas drawing
      PreviewRenderer.drawCurrentDrawing(
        canvas,
        size,
        start: start,
        end: end,
        elementType: elementType,
        color: color,
        strokeWidth: strokeWidth,
        density: density,
        curvature: curvature,
        triangleCut: triangleCut,
        freeDrawingPath: freeDrawingPath,
        selectedElementId: selectedElementId,
      );
    }
  }

  void _drawOnStickyNote(Canvas canvas, Size size) {
    final stickyNote = targetStickyNote!;

    // Calculate sticky note bounds in canvas coordinates
    final stickyNoteCanvasPosition = Offset(
      stickyNote.position.dx * size.width,
      stickyNote.position.dy * size.height,
    );
    final stickyNoteCanvasSize = Size(
      stickyNote.size.width * size.width,
      stickyNote.size.height * size.height,
    );
    // 计算标题栏高度（与 drawing_tool_manager.dart 中的一致）
    const double titleBarHeight = 36.0; // 标题栏固定高度
    const double contentPadding = 10.0; // 内容区域的 padding

    // 计算内容区域的实际位置和大小（排除标题栏）
    final contentAreaPosition = Offset(
      stickyNoteCanvasPosition.dx + contentPadding,
      stickyNoteCanvasPosition.dy + titleBarHeight + contentPadding,
    );
    final contentAreaSize = Size(
      stickyNoteCanvasSize.width - (contentPadding * 2),
      stickyNoteCanvasSize.height - titleBarHeight - (contentPadding * 2),
    );

    // Transform drawing coordinates from sticky note local space to canvas space
    late Offset canvasStart;
    late Offset canvasEnd;
    List<Offset>? canvasFreeDrawingPath;

    if (freeDrawingPath != null && freeDrawingPath!.isNotEmpty) {
      canvasFreeDrawingPath = freeDrawingPath!.map((localPoint) {
        return Offset(
          contentAreaPosition.dx + localPoint.dx * contentAreaSize.width,
          contentAreaPosition.dy + localPoint.dy * contentAreaSize.height,
        );
      }).toList();
      canvasStart = canvasFreeDrawingPath.first;
      canvasEnd = canvasFreeDrawingPath.last;
    } else {
      canvasStart = Offset(
        contentAreaPosition.dx + start.dx * contentAreaSize.width,
        contentAreaPosition.dy + start.dy * contentAreaSize.height,
      );
      canvasEnd = Offset(
        contentAreaPosition.dx + end.dx * contentAreaSize.width,
        contentAreaPosition.dy + end.dy * contentAreaSize.height,
      );
    }

    // Draw preview using transformed coordinates
    PreviewRenderer.drawCurrentDrawing(
      canvas,
      size,
      start: canvasStart,
      end: canvasEnd,
      elementType: elementType,
      color: color,
      strokeWidth: strokeWidth,
      density: density,
      curvature: curvature,
      triangleCut: triangleCut,
      freeDrawingPath: canvasFreeDrawingPath,
      selectedElementId: selectedElementId,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// 背景图案画笔，支持多种背景模式
class _BackgroundPatternPainter extends CustomPainter {
  final BackgroundPattern pattern;
  final BuildContext? context;

  _BackgroundPatternPainter(this.pattern, {this.context});

  @override
  void paint(Canvas canvas, Size size) {
    BackgroundRenderer.drawBackgroundPattern(
      canvas,
      size,
      pattern,
      context: context,
    );
  }

  @override
  bool shouldRepaint(_BackgroundPatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern;
  }
}
