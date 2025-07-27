import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../../models/map_layer.dart';
import '../../../providers/user_preferences_provider.dart';
import '../../../components/color_picker_dialog.dart';
import '../../../utils/image_utils.dart';
import '../../../services/clipboard_service.dart';
import '../utils/drawing_utils.dart';
import 'popup_menu_utils.dart';

/// 绘制工具竖直dock栏组件
/// 显示绘制工具图标，放置在画布左侧边缘
class DrawingToolsDockBar extends StatefulWidget {
  final DrawingElementType? selectedTool;
  final bool isVisible; // 是否显示dock栏
  final Function(DrawingElementType?)? onToolSelected; // 工具选中回调
  final Function(DrawingElementType?)? onToolPreview; // 工具预览回调
  final Function(Color)? onColorPreview;
  final bool isEditMode; // 是否为编辑模式
  final bool shouldDisableDrawingTools; // 是否应该禁用绘制工具
  final VoidCallback? onToggleSidebar; // 切换侧边栏回调
  final Color selectedColor;
  final double selectedStrokeWidth;
  final double selectedDensity;
  final double selectedCurvature;
  final TriangleCutType selectedTriangleCut;
  final Function(Color)? onColorChanged;
  final Function(double)? onStrokeWidthChanged;
  final Function(double)? onDensityChanged;
  final Function(double)? onCurvatureChanged;
  final Function(TriangleCutType)? onTriangleCutChanged;

  // 图片缓冲区相关属性
  final Uint8List? imageBufferData;
  final BoxFit imageBufferFit;
  final Function(Uint8List)? onImageBufferUpdated;
  final Function(BoxFit)? onImageBufferFitChanged;
  final VoidCallback? onImageBufferCleared;

  const DrawingToolsDockBar({
    super.key,
    this.selectedTool,
    this.isVisible = true,
    this.onToolSelected,
    this.onToolPreview,
    this.onColorPreview,
    this.isEditMode = true,
    this.shouldDisableDrawingTools = false,
    this.onToggleSidebar,
    this.selectedColor = Colors.black,
    this.selectedStrokeWidth = 2.0,
    this.selectedDensity = 5.0,
    this.selectedCurvature = 0.0,
    this.selectedTriangleCut = TriangleCutType.none,
    this.onColorChanged,
    this.onStrokeWidthChanged,
    this.onDensityChanged,
    this.onCurvatureChanged,
    this.onTriangleCutChanged,
    // 图片缓冲区相关参数
    this.imageBufferData,
    this.imageBufferFit = BoxFit.contain,
    this.onImageBufferUpdated,
    this.onImageBufferFitChanged,
    this.onImageBufferCleared,
  });

  @override
  State<DrawingToolsDockBar> createState() => _DrawingToolsDockBarState();
}

class _DrawingToolsDockBarState extends State<DrawingToolsDockBar> {
  final ScrollController _scrollController = ScrollController();

  // 颜色相关状态
  Color _selectedColor = Colors.red; // 当前选中的颜色

  final GlobalKey _colorButtonKey = GlobalKey(); // 用于定位弹窗位置
  final Map<DrawingElementType, GlobalKey> _toolButtonKeys =
      {}; // 工具按钮的GlobalKey映射

  // 弹窗状态管理
  bool _isAnyPopupOpen = false; // 是否有弹窗打开
  DrawingElementType? _currentPopupTool; // 当前打开弹窗的工具
  bool _isColorPopupOpen = false; // 颜色弹窗是否打开

  // 绘制工具配置
  static const List<_DrawingToolConfig> _drawingTools = [
    _DrawingToolConfig(
      type: DrawingElementType.line,
      icon: Icons.remove,
      label: '直线',
      tooltip: '绘制直线',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.dashedLine,
      icon: Icons.more_horiz,
      label: '虚线',
      tooltip: '绘制虚线',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.arrow,
      icon: Icons.arrow_forward,
      label: '箭头',
      tooltip: '绘制箭头',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.rectangle,
      icon: Icons.rectangle,
      label: '矩形',
      tooltip: '绘制矩形',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.hollowRectangle,
      icon: Icons.rectangle_outlined,
      label: '空心矩形',
      tooltip: '绘制空心矩形',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.diagonalLines,
      // icon: Icons.line_style,
      icon: Icons.line_style,
      label: '斜线区域',
      tooltip: '绘制斜线区域',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.crossLines,
      icon: Icons.grid_3x3,
      label: '交叉线',
      tooltip: '绘制交叉线',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.dotGrid,
      icon: Icons.grid_on,
      label: '点阵',
      tooltip: '绘制点阵',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.freeDrawing,
      icon: Icons.gesture,
      label: '自由绘制',
      tooltip: '自由绘制',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.text,
      icon: Icons.text_fields,
      label: '文本',
      tooltip: '添加文本',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.eraser,
      icon: Icons.content_cut,
      label: '橡皮擦',
      tooltip: '擦除元素',
    ),
    _DrawingToolConfig(
      type: DrawingElementType.imageArea,
      icon: Icons.photo_size_select_actual,
      label: '图片区域',
      tooltip: '添加图片区域',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 使用传入的颜色值
    _selectedColor = widget.selectedColor;
  }

  @override
  void didUpdateWidget(DrawingToolsDockBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当属性值变化时更新本地状态
    if (oldWidget.selectedColor != widget.selectedColor) {
      setState(() {
        _selectedColor = widget.selectedColor;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 处理工具选择
  void _handleToolSelection(DrawingElementType? tool) {
    if (!widget.isEditMode) return;

    // 立即通知预览（如果提供了回调）
    widget.onToolPreview?.call(tool);

    // 立即提交工具选择更改
    widget.onToolSelected?.call(tool);
  }

  /// 获取工具属性弹窗高度
  double _getToolPopupHeight(DrawingElementType tool) {
    // 基础高度：标题
    double baseHeight = 50;

    // 检查是否有任何属性需要显示
    final hasStrokeWidth = _shouldShowStrokeWidth(tool);
    final hasDensity = _shouldShowDensity(tool);
    final hasCurvature = _shouldShowCurvature(tool);
    final hasTriangleCut = _shouldShowTriangleCut(tool);
    final hasImageAreaControls = _shouldShowImageAreaControls(tool);
    final hasAnyProperty =
        hasStrokeWidth ||
        hasDensity ||
        hasCurvature ||
        hasTriangleCut ||
        hasImageAreaControls;

    if (!hasAnyProperty) {
      // 如果没有任何属性，显示说明信息的高度
      baseHeight += 80; // 说明信息区域
    } else {
      // 根据工具类型添加额外高度
      if (hasStrokeWidth) {
        baseHeight += 100; // 线条粗细控制区域
      }

      if (hasDensity) {
        baseHeight += 100; // 密度控制区域
      }

      if (hasCurvature) {
        baseHeight += 100; // 弧度控制区域
      }

      if (hasTriangleCut) {
        baseHeight += 80; // 三角形切割控制区域（下拉框需要更多空间）
      }

      if (hasImageAreaControls) {
        baseHeight += 400; // 图片选区控件基础空间
        // 如果有图片数据，需要额外空间显示图片适应方式选择器
        if (widget.imageBufferData != null) {
          baseHeight += 100; // 图片适应方式选择器额外空间
        }
      }
    }

    return baseHeight;
  }

  /// 显示工具属性设置窗口
  void _showToolProperties(DrawingElementType tool, GlobalKey buttonKey) {
    if (!widget.isEditMode) return;

    // 如果当前工具的弹窗已经打开，则关闭它
    if (_currentPopupTool == tool && _isAnyPopupOpen) {
      _closeCurrentPopup();
      return;
    }

    // 如果有其他弹窗打开，先关闭
    if (_isAnyPopupOpen) {
      _closeCurrentPopup();
      // 等待一帧后再打开新弹窗，确保旧弹窗完全关闭
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showToolPropertiesInternal(tool, buttonKey);
      });
    } else {
      _showToolPropertiesInternal(tool, buttonKey);
    }
  }

  /// 内部方法：实际显示工具属性弹窗
  void _showToolPropertiesInternal(
    DrawingElementType tool,
    GlobalKey buttonKey,
  ) {
    setState(() {
      _isAnyPopupOpen = true;
      _currentPopupTool = tool;
      _isColorPopupOpen = false;
    });

    // 创建一个可以动态更新高度的弹窗
    _showDynamicHeightPopup(tool, buttonKey);
  }

  /// 显示可动态调整高度的弹窗
  void _showDynamicHeightPopup(DrawingElementType tool, GlobalKey buttonKey) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            // 获取锚点位置
            final RenderBox? renderBox =
                buttonKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox == null) {
              return const SizedBox.shrink();
            }

            final Offset anchorPosition = renderBox.localToGlobal(Offset.zero);
            final Size anchorSize = renderBox.size;
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;

            // 动态计算弹窗高度
            final popupHeight = _getToolPopupHeight(tool);
            final popupWidth = 280.0;

            // 计算弹窗位置
            double left = anchorPosition.dx + anchorSize.width + 10 + 16;
            double top = anchorPosition.dy - (popupHeight / 2);

            // 边界检查
            if (left + popupWidth > screenWidth) {
              left = anchorPosition.dx - popupWidth - 10 + 16;
            }
            if (left < 10) left = 10;
            if (top + popupHeight > screenHeight) {
              top = screenHeight - popupHeight - 10;
            }
            if (top < 10) top = 10;

            return Stack(
              children: [
                // 透明背景，点击关闭菜单
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // 弹窗内容
                Positioned(
                  top: top,
                  left: left,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: popupWidth,
                      height: popupHeight,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _buildToolPropertiesContent(
                          tool,
                          dialogContext,
                          setPopupState,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // 弹窗关闭时重置状态
      if (mounted) {
        setState(() {
          _isAnyPopupOpen = false;
          _currentPopupTool = null;
        });
      }
    });
  }

  /// 构建工具属性内容
  Widget _buildToolPropertiesContent(
    DrawingElementType tool,
    BuildContext dialogContext, [
    StateSetter? setPopupState,
  ]) {
    // 使用更敏感的key来强制重建StatefulBuilder，包含数据哈希值
    final imageDataHash = widget.imageBufferData?.hashCode ?? 0;
    final builderKey = ValueKey(
      '${tool.name}_${imageDataHash}_${widget.imageBufferFit.name}_${DateTime.now().millisecondsSinceEpoch}',
    );

    return StatefulBuilder(
      key: builderKey,
      builder: (context, setDialogState) {
        // 强制监听widget属性变化
        final currentImageData = widget.imageBufferData;
        final currentImageFit = widget.imageBufferFit;

        // 创建组合的状态更新函数
        void updateBothStates() {
          if (!mounted) return;

          // 立即更新 - 分别处理每个 setState 调用
          try {
            setDialogState(() {});
          } catch (e) {
            debugPrint('updateBothStates setDialogState immediate error: $e');
          }

          try {
            if (setPopupState != null) {
              setPopupState(() {});
            }
          } catch (e) {
            debugPrint('updateBothStates setPopupState immediate error: $e');
          }

          // 强制在下一帧再次更新，确保状态同步
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            try {
              setDialogState(() {});
            } catch (e) {
              debugPrint('updateBothStates setDialogState postFrame error: $e');
            }

            try {
              if (setPopupState != null) {
                setPopupState(() {});
              }
            } catch (e) {
              debugPrint('updateBothStates setPopupState postFrame error: $e');
            }
          });
        }

        // 检查是否有任何属性需要显示
        final hasStrokeWidth = _shouldShowStrokeWidth(tool);
        final hasDensity = _shouldShowDensity(tool);
        final hasCurvature = _shouldShowCurvature(tool);
        final hasTriangleCut = _shouldShowTriangleCut(tool);
        final hasImageAreaControls = _shouldShowImageAreaControls(tool);
        final hasAnyProperty =
            hasStrokeWidth ||
            hasDensity ||
            hasCurvature ||
            hasTriangleCut ||
            hasImageAreaControls;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '${_getToolDisplayName(tool)} 属性',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // 如果没有任何属性，显示说明
            if (!hasAnyProperty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '此工具无可配置属性',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 笔触宽度（只对需要的工具显示）
              if (hasStrokeWidth) _buildStrokeWidthSection(setDialogState),

              // 根据工具类型显示特定属性
              if (hasDensity) ...[
                const SizedBox(height: 16),
                _buildDensitySection(setDialogState),
              ],

              // 弧度控制（适用于箭头等工具）
              if (hasCurvature) ...[
                const SizedBox(height: 16),
                _buildCurvatureSection(setDialogState),
              ],

              // 三角形切割控制（适用于三角形工具）
              if (hasTriangleCut) ...[
                const SizedBox(height: 16),
                _buildTriangleCutSection(setDialogState),
              ],

              // 图片选区专用控件
              if (hasImageAreaControls) ...[
                const SizedBox(height: 16),
                _buildImageAreaControlsSection(updateBothStates),
              ],
            ],
          ],
        );
      },
    );
  }

  /// 获取工具显示名称
  String _getToolDisplayName(DrawingElementType tool) {
    final toolConfig = _drawingTools.firstWhere(
      (config) => config.type == tool,
      orElse: () => const _DrawingToolConfig(
        type: DrawingElementType.line,
        icon: Icons.help,
        label: '未知工具',
        tooltip: '未知工具',
      ),
    );
    return toolConfig.label;
  }

  /// 构建弧度控制区域
  Widget _buildCurvatureSection(StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '弧度: ${(widget.selectedCurvature * 100).round()}%',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: widget.selectedCurvature,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          onChanged: (value) {
            widget.onCurvatureChanged?.call(value);

            // 立即更新弹窗显示
            setDialogState(() {});

            // 等待父组件状态更新完成后再次更新弹窗
            Future.delayed(const Duration(milliseconds: 10), () {
              if (mounted) {
                setDialogState(() {});
              }
            });
          },
        ),
      ],
    );
  }

  /// 构建三角形切割控制区域
  Widget _buildTriangleCutSection(StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '切割类型',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButton<TriangleCutType>(
          value: widget.selectedTriangleCut,
          isExpanded: true,
          items: TriangleCutType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getTriangleCutDisplayName(type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onTriangleCutChanged?.call(value);

              // 立即更新弹窗显示
              setDialogState(() {});

              // 等待父组件状态更新完成后再次更新弹窗
              Future.delayed(const Duration(milliseconds: 10), () {
                if (mounted) {
                  setDialogState(() {});
                }
              });
            }
          },
        ),
      ],
    );
  }

  /// 获取三角形切割类型的显示名称
  String _getTriangleCutDisplayName(TriangleCutType type) {
    switch (type) {
      case TriangleCutType.none:
        return '无切割';
      case TriangleCutType.topLeft:
        return '左上切割';
      case TriangleCutType.topRight:
        return '右上切割';
      case TriangleCutType.bottomLeft:
        return '左下切割';
      case TriangleCutType.bottomRight:
        return '右下切割';
    }
  }

  /// 构建笔触宽度区域
  Widget _buildStrokeWidthSection(StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '笔触宽度: ${widget.selectedStrokeWidth.round()}px',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: widget.selectedStrokeWidth,
          min: 1.0,
          max: 50.0,
          divisions: 49,
          onChanged: (value) {
            widget.onStrokeWidthChanged?.call(value);

            // 立即更新弹窗显示
            setDialogState(() {});

            // 等待父组件状态更新完成后再次更新弹窗
            Future.delayed(const Duration(milliseconds: 10), () {
              if (mounted) {
                setDialogState(() {});
              }
            });
          },
        ),
      ],
    );
  }

  /// 构建密度区域
  Widget _buildDensitySection(StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '密度: ${widget.selectedDensity.toStringAsFixed(1)}x',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: widget.selectedDensity,
          min: 1.0,
          max: 8.0,
          divisions: 14,
          onChanged: (value) {
            widget.onDensityChanged?.call(value);

            // 立即更新弹窗显示
            setDialogState(() {});

            // 等待父组件状态更新完成后再次更新弹窗
            Future.delayed(const Duration(milliseconds: 10), () {
              if (mounted) {
                setDialogState(() {});
              }
            });
          },
        ),
      ],
    );
  }

  /// 判断是否显示密度控制
  bool _shouldShowDensity(DrawingElementType tool) {
    return tool == DrawingElementType.dashedLine ||
        tool == DrawingElementType.dotGrid ||
        tool == DrawingElementType.diagonalLines ||
        tool == DrawingElementType.crossLines;
  }

  /// 是否显示弧度控制
  bool _shouldShowCurvature(DrawingElementType tool) {
    return tool == DrawingElementType.rectangle ||
        tool == DrawingElementType.hollowRectangle ||
        tool == DrawingElementType.diagonalLines ||
        tool == DrawingElementType.crossLines ||
        tool == DrawingElementType.dotGrid ||
        tool == DrawingElementType.eraser;
  }

  /// 是否显示三角形切割控制
  bool _shouldShowTriangleCut(DrawingElementType tool) {
    return tool == DrawingElementType.rectangle ||
        tool == DrawingElementType.hollowRectangle ||
        tool == DrawingElementType.diagonalLines ||
        tool == DrawingElementType.crossLines ||
        tool == DrawingElementType.dotGrid ||
        tool == DrawingElementType.eraser;
  }

  /// 是否显示线条粗细控制（文本、橡皮擦、图片选区工具不需要）
  bool _shouldShowStrokeWidth(DrawingElementType tool) {
    return tool != DrawingElementType.text &&
        tool != DrawingElementType.eraser &&
        tool != DrawingElementType.imageArea;
  }

  /// 是否显示图片选区专用控件
  bool _shouldShowImageAreaControls(DrawingElementType tool) {
    return tool == DrawingElementType.imageArea;
  }

  /// 构建图片缓冲区显示组件（显示已上传的图片）
  Widget _buildImageBuffer([void Function()? updateBothStates]) {
    return Column(
      children: [
        // 图片预览
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              widget.imageBufferData!,
              fit: widget.imageBufferFit,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade400,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '图片显示失败',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 操作按钮
        Row(
          children: [
            // 重新上传按钮
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  if (updateBothStates != null) {
                    await _handleImageUpload(null, null);
                    updateBothStates();
                    // 额外延迟确保状态完全同步
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (mounted) {
                        try {
                          updateBothStates();
                        } catch (e) {
                          debugPrint('Delayed updateBothStates error: $e');
                        }
                      }
                    });
                  } else {
                    await _handleImageUpload();
                  }
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重新上传', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  foregroundColor: Colors.blue.shade600,
                  side: BorderSide(color: Colors.blue.shade300),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 清空缓冲区按钮
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  widget.onImageBufferCleared?.call();
                  // 更新弹窗显示 - 强制重建
                  if (updateBothStates != null) {
                    updateBothStates();
                    // 额外延迟确保状态更新
                    Future.delayed(const Duration(milliseconds: 50), () {
                      if (mounted) {
                        try {
                          updateBothStates();
                        } catch (e) {
                          debugPrint(
                            'Delayed clear updateBothStates error: $e',
                          );
                        }
                      }
                    });
                  }
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('清空', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade300),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建图片上传提示组件（缓冲区为空时显示）
  Widget _buildImageUploadPrompt([void Function()? updateBothStates]) {
    return Column(
      children: [
        // 上传提示区域
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: Theme.of(
                  context,
                ).iconTheme.color?.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              Text(
                '点击上传图片到缓冲区',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '支持 JPG、PNG、GIF 格式',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 上传按钮和剪贴板按钮
        Row(
          children: [
            // 上传图片按钮
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (updateBothStates != null) {
                    await _handleImageUpload(null, null);
                    updateBothStates();
                    // 额外延迟确保状态完全同步
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (mounted) {
                        try {
                          updateBothStates();
                        } catch (e) {
                          debugPrint(
                            'Delayed upload updateBothStates error: $e',
                          );
                        }
                      }
                    });
                  } else {
                    await _handleImageUpload();
                  }
                },
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('上传图片'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 剪贴板按钮
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (updateBothStates != null) {
                    await _handleClipboardPaste(null, null);
                    updateBothStates();
                    // 额外延迟确保状态完全同步
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (mounted) {
                        try {
                          updateBothStates();
                        } catch (e) {
                          debugPrint(
                            'Delayed clipboard updateBothStates error: $e',
                          );
                        }
                      }
                    });
                  } else {
                    await _handleClipboardPaste();
                  }
                },
                icon: const Icon(Icons.paste, size: 18),
                label: const Text('剪贴板'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建BoxFit选择器
  Widget _buildBoxFitSelector([void Function()? updateBothStates]) {
    final boxFitOptions = [
      BoxFit.contain,
      BoxFit.cover,
      BoxFit.fill,
      BoxFit.fitWidth,
      BoxFit.fitHeight,
      BoxFit.none,
      BoxFit.scaleDown,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: boxFitOptions.map((fit) {
        return _buildBoxFitButton(fit, updateBothStates);
      }).toList(),
    );
  }

  /// 构建单个BoxFit按钮
  Widget _buildBoxFitButton(BoxFit fit, [void Function()? updateBothStates]) {
    final isSelected = _getSelectedImageFit() == fit;

    return InkWell(
      onTap: () => _handleImageFitChange(fit, updateBothStates),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((0.1 * 255).toInt())
              : Colors.transparent,
        ),
        child: Text(
          getBoxFitDisplayName(fit),
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  /// 获取当前选中的图片适应方式
  BoxFit _getSelectedImageFit() {
    return widget.imageBufferFit;
  }

  /// 处理图片适应方式改变
  void _handleImageFitChange(BoxFit fit, [void Function()? updateBothStates]) {
    widget.onImageBufferFitChanged?.call(fit);

    // 触发弹窗状态更新
    if (updateBothStates != null) {
      // 等待父组件状态更新完成后再更新弹窗
      Future.delayed(const Duration(milliseconds: 10), () {
        if (mounted) {
          updateBothStates();
        }
      });
    }
  }

  /// 处理图片上传
  Future<void> _handleImageUpload([
    StateSetter? setDialogState,
    StateSetter? setPopupState,
  ]) async {
    try {
      final imageData = await ImageUtils.pickAndEncodeImage();
      if (imageData != null) {
        if (!ImageUtils.isValidImageData(imageData)) {
          throw Exception('无效的图片文件，请选择有效的图片');
        }

        // 先更新父组件状态
        widget.onImageBufferUpdated?.call(imageData);

        // 等待父组件状态更新完成
        await Future.delayed(const Duration(milliseconds: 10));

        // 更新弹窗显示 - 多次强制重建确保状态同步
        if (setDialogState != null && mounted) {
          // 立即更新
          try {
            setDialogState(() {});
            if (setPopupState != null) {
              setPopupState(() {});
            }
          } catch (e) {
            debugPrint('_handleImageUpload immediate setState error: $e');
          }

          // 在下一帧更新
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                setDialogState(() {});
                if (setPopupState != null) {
                  setPopupState(() {});
                }
              } catch (e) {
                debugPrint('_handleImageUpload postFrame setState error: $e');
              }
            }
          });

          // 额外延迟确保状态更新
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              try {
                setDialogState(() {});
                if (setPopupState != null) {
                  setPopupState(() {});
                }
              } catch (e) {
                debugPrint('_handleImageUpload delayed setState error: $e');
              }
            }
          });
        }
      }
    } catch (e) {
      // 错误处理可以在这里添加
      debugPrint('图片上传失败: $e');
    }
  }

  /// 处理剪贴板粘贴
  Future<void> _handleClipboardPaste([
    StateSetter? setDialogState,
    StateSetter? setPopupState,
  ]) async {
    try {
      // 使用ClipboardService读取剪贴板图片
      final imageData = await ClipboardService.readImageFromClipboard();
      if (imageData != null) {
        if (!ImageUtils.isValidImageData(imageData)) {
          throw Exception('剪贴板中的数据不是有效的图片文件');
        }

        // 先更新父组件状态
        widget.onImageBufferUpdated?.call(imageData);

        // 等待父组件状态更新完成
        await Future.delayed(const Duration(milliseconds: 10));

        // 更新弹窗显示 - 多次强制重建确保状态同步
        if (setDialogState != null && mounted) {
          // 立即更新
          try {
            setDialogState(() {});
            if (setPopupState != null) {
              setPopupState(() {});
            }
          } catch (e) {
            debugPrint('_handleClipboardPaste immediate setState error: $e');
          }

          // 在下一帧更新
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                setDialogState(() {});
                if (setPopupState != null) {
                  setPopupState(() {});
                }
              } catch (e) {
                debugPrint(
                  '_handleClipboardPaste postFrame setState error: $e',
                );
              }
            }
          });

          // 额外延迟确保状态更新
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              try {
                setDialogState(() {});
                if (setPopupState != null) {
                  setPopupState(() {});
                }
              } catch (e) {
                debugPrint('_handleClipboardPaste delayed setState error: $e');
              }
            }
          });
        }
      }
    } catch (e) {
      // 错误处理可以在这里添加
      debugPrint('从剪贴板粘贴图片失败: $e');
    }
  }

  /// 构建图片选区专用控件部分
  Widget _buildImageAreaControlsSection(void Function()? updateBothStates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片缓冲区
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade200, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue.shade50,
          ),
          child: Column(
            children: [
              // 缓冲区标题
              Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '图片缓冲区',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 缓冲区内容
              if (widget.imageBufferData != null)
                // 显示已上传的图片
                _buildImageBuffer(updateBothStates)
              else
                // 显示上传提示
                _buildImageUploadPrompt(updateBothStates),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // 图片适应方式选择
        if (widget.imageBufferData != null) ...[
          const Text(
            '图片适应方式',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildBoxFitSelector(updateBothStates),
        ],

        const SizedBox(height: 8),

        // 使用说明
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).iconTheme.color?.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '使用说明',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '1. 点击"上传图片"选择文件或"剪贴板"粘贴图片\n'
                '2. 在画布上拖拽创建选区\n'
                '3. 图片将自动适应选区大小\n'
                '4. 可通过Z层级检视器调整',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 700, // 设置最大高度
          maxWidth: 56,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: _buildToolsList(),
      ),
    );
  }

  /// 构建工具列表
  Widget _buildToolsList() {
    return IntrinsicHeight(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 固定的标题图标 - 可点击切换侧边栏
          _buildHeaderIcon(),

          // 只有在绘制工具未被禁用时才显示其他工具
          if (!widget.shouldDisableDrawingTools) ...[
            const SizedBox(height: 8),

            // 可滚动的工具按钮列表
            Flexible(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _drawingTools.map((toolConfig) {
                      return _buildToolItem(toolConfig);
                    }).toList(),
                  ),
                ),
              ),
            ),

            // 固定的调色盘按钮
            const SizedBox(height: 8),
            _buildColorPaletteButton(),
          ],
        ],
      ),
    );
  }

  /// 构建固定的标题图标
  Widget _buildHeaderIcon() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onToggleSidebar,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.build,
            size: 24,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  /// 构建单个工具项
  Widget _buildToolItem(_DrawingToolConfig toolConfig) {
    final isSelected = widget.selectedTool == toolConfig.type;
    final isEnabled = widget.isEditMode;
    final hasPopupOpen =
        _currentPopupTool == toolConfig.type && _isAnyPopupOpen;

    // 为每个工具创建唯一的 GlobalKey
    _toolButtonKeys[toolConfig.type] ??= GlobalKey();
    final buttonKey = _toolButtonKeys[toolConfig.type]!;

    return Tooltip(
      message: '${toolConfig.tooltip}\n右键查看属性',
      waitDuration: const Duration(milliseconds: 500),
      child: Container(
        key: buttonKey,
        margin: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: isEnabled
                ? () =>
                      _handleToolSelection(isSelected ? null : toolConfig.type)
                : null,
            onSecondaryTap: isEnabled
                ? () => _showToolProperties(toolConfig.type, buttonKey)
                : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : isEnabled
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Theme.of(context).colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasPopupOpen
                      ? Theme.of(context).colorScheme.secondary
                      : isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: hasPopupOpen ? 3 : 2,
                ),
                boxShadow: hasPopupOpen
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                toolConfig.icon,
                size: 24,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : isEnabled
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建调色盘按钮
  Widget _buildColorPaletteButton() {
    final isEnabled = widget.isEditMode;
    final hasColorPopupOpen = _isColorPopupOpen && _isAnyPopupOpen;

    // 计算图标颜色（与背景色相反）
    final backgroundColor = _selectedColor;
    final iconColor = _getContrastColor(backgroundColor);

    return Tooltip(
      message: '选择颜色',
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: _colorButtonKey,
          onTap: isEnabled ? _showColorMenu : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isEnabled
                  ? backgroundColor
                  : backgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasColorPopupOpen
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                width: hasColorPopupOpen ? 3 : 1,
              ),
              boxShadow: hasColorPopupOpen
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.palette,
              size: 24,
              color: isEnabled ? iconColor : iconColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  /// 获取与背景色对比的颜色
  Color _getContrastColor(Color backgroundColor) {
    // 计算亮度
    final luminance = backgroundColor.computeLuminance();
    // 如果背景色较亮，返回黑色；如果较暗，返回白色
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// 显示颜色选择菜单
  void _showColorMenu() {
    // 如果颜色弹窗已经打开，则关闭它
    if (_isColorPopupOpen && _isAnyPopupOpen) {
      _closeCurrentPopup();
      return;
    }

    // 如果有其他弹窗打开，先关闭
    if (_isAnyPopupOpen) {
      _closeCurrentPopup();
      // 等待一帧后再打开新弹窗，确保旧弹窗完全关闭
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showColorMenuInternal();
      });
    } else {
      _showColorMenuInternal();
    }
  }

  /// 内部方法：实际显示颜色选择弹窗
  void _showColorMenuInternal() {
    setState(() {
      _isAnyPopupOpen = true;
      _isColorPopupOpen = true;
      _currentPopupTool = null;
    });

    PopupMenuUtils.showPositionedPopup(
      context: context,
      anchorKey: _colorButtonKey,
      contentBuilder: _buildColorMenuContent,
      popupWidth: 160.0,
      popupHeight: 140.0,
      preferredSide: PopupSide.right,
    ).then((_) {
      // 对话框关闭时重置状态
      if (mounted) {
        setState(() {
          _isAnyPopupOpen = false;
          _isColorPopupOpen = false;
        });
      }
    });
  }

  /// 关闭当前打开的弹窗
  void _closeCurrentPopup() {
    if (_isAnyPopupOpen && mounted) {
      Navigator.of(
        context,
      ).popUntil((route) => route.isFirst || !route.willHandlePopInternally);
      setState(() {
        _isAnyPopupOpen = false;
        _currentPopupTool = null;
        _isColorPopupOpen = false;
      });
    }
  }

  /// 构建颜色菜单内容
  Widget _buildColorMenuContent(BuildContext dialogContext) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        final recentColorValues = userPrefs.tools.recentColors;
        final recentColors = recentColorValues
            .map((colorValue) => Color(colorValue))
            .toList();

        // 如果没有最近使用的颜色，显示默认颜色
        final colorsToShow = recentColors.isEmpty
            ? [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
              ]
            : recentColors;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '最近使用的颜色',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // 颜色网格
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...colorsToShow.take(5).map((color) {
                  return _buildColorItem(dialogContext, color);
                }).toList(),
                // 取色器按钮
                _buildColorPickerButton(dialogContext),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 构建单个颜色项
  Widget _buildColorItem(BuildContext dialogContext, Color color) {
    final isSelected = _selectedColor == color;

    return InkWell(
      onTap: () {
        Navigator.of(dialogContext).pop();
        _selectColor(color);
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isSelected
            ? Icon(Icons.check, size: 16, color: _getContrastColor(color))
            : null,
      ),
    );
  }

  /// 构建取色器按钮
  Widget _buildColorPickerButton(BuildContext dialogContext) {
    return InkWell(
      onTap: () async {
        Navigator.of(dialogContext).pop();
        final selectedColor = await ColorPicker.showColorPicker(
          context: context,
          initialColor: _selectedColor,
          title: '选择颜色',
          enableAlpha: false,
        );
        if (selectedColor != null) {
          _selectColor(selectedColor);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.colorize,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  /// 选择颜色
  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });

    // 调用颜色变化回调
    widget.onColorChanged?.call(color);
    widget.onColorPreview?.call(color);

    // 更新最近使用的颜色到用户偏好
    final userPrefs = context.read<UserPreferencesProvider>();
    userPrefs.addRecentColor(color.toARGB32()).catchError((e) {
      debugPrint('更新最近使用颜色失败: $e');
    });
  }
}

/// 绘制工具配置类
class _DrawingToolConfig {
  final DrawingElementType type;
  final IconData icon;
  final String label;
  final String tooltip;

  const _DrawingToolConfig({
    required this.type,
    required this.icon,
    required this.label,
    required this.tooltip,
  });
}
