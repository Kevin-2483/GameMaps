import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import '../../../models/map_layer.dart';
import '../../../models/map_item.dart';
import '../../../models/legend_item.dart' as legend_db;
import '../../../services/legend_session_manager.dart';
import '../../../services/notification/notification_models.dart';
import '../../../services/notification/notification_service.dart';

/// 浮动图例dock栏组件
/// 显示当前选中图层组或整个地图使用的图例以及数量
class LegendDockBar extends StatefulWidget {
  final MapItem mapItem;
  final List<MapLayer>? selectedLayerGroup; // 当前选中的图层组
  final MapLayer? selectedLayer; // 当前选中的图层
  final bool isVisible; // 是否显示dock栏
  final LegendSessionManager? legendSessionManager; // 图例会话管理器
  final Function(String legendItemId)? onLegendItemSelected; // 图例项选中回调
  final VoidCallback? onToggleLegendGroupManagement; // 图例组管理抽屉开关回调
  final Function(LegendGroup legendGroup)? onLegendGroupSelected; // 图例组选择回调
  final LegendGroup? currentLegendGroupForManagement; // 当前打开的图例组管理抽屉
  final String? selectedElementId; // 当前选中的元素ID（用于同步画布选择状态）
  final Function(MapLayer layer)? onLayerSelected; // 图层选中回调
  final Function(List<MapLayer> layerGroup)? onLayerGroupSelected; // 图层组选中回调
  final VoidCallback? onSelectionCleared; // 清除选择回调
  final VoidCallback? onLayerSelectionCleared; // 清除图层选择回调
  final VoidCallback? onLayerGroupSelectionCleared; // 清除图层组选择回调

  const LegendDockBar({
    super.key,
    required this.mapItem,
    this.selectedLayerGroup,
    this.selectedLayer,
    this.isVisible = true,
    this.legendSessionManager,
    this.onLegendItemSelected,
    this.onToggleLegendGroupManagement,
    this.onLegendGroupSelected,
    this.currentLegendGroupForManagement,
    this.selectedElementId,
    this.onLayerSelected,
    this.onLayerGroupSelected,
    this.onSelectionCleared,
    this.onLayerSelectionCleared,
    this.onLayerGroupSelectionCleared,
  });

  @override
  State<LegendDockBar> createState() => _LegendDockBarState();
}

class _LegendDockBarState extends State<LegendDockBar> {
  late final LegendSessionManager _legendSessionManager;
  final ScrollController _scrollController = ScrollController(); // 滚动控制器
  Map<String, int> _legendCounts = {}; // 图例路径 -> 数量
  Map<String, legend_db.LegendItem?> _legendItems = {}; // 图例路径 -> 图例数据
  Map<String, int> _selectedIndices = {}; // 图例路径 -> 当前选中的索引
  bool _isLoading = false;
  bool _showLayerPopup = false; // 控制图层选择气泡的显示
  final GlobalKey _layerIconKey = GlobalKey(); // 用于定位气泡位置

  @override
  void initState() {
    super.initState();
    // 使用传入的图例会话管理器，如果没有则创建新实例
    _legendSessionManager =
        widget.legendSessionManager ?? LegendSessionManager();
    _updateLegendData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LegendDockBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当选中状态或地图数据发生变化时，更新图例数据
    if (oldWidget.selectedLayerGroup != widget.selectedLayerGroup ||
        oldWidget.selectedLayer != widget.selectedLayer ||
        oldWidget.mapItem != widget.mapItem) {
      _updateLegendData();
    }

    // 当画布选中的元素发生变化时，同步dock栏的选择状态
    if (oldWidget.selectedElementId != widget.selectedElementId) {
      _syncCanvasSelection();
    }
  }

  /// 更新图例数据
  Future<void> _updateLegendData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final legendCounts = <String, int>{};
      final legendItems = <String, legend_db.LegendItem?>{};

      // 获取需要统计的图例组
      List<LegendGroup> targetLegendGroups = _getTargetLegendGroups();

      // 检查是否有可用的图例组
      if (targetLegendGroups.isEmpty) {
        // 当统计范围是整个地图且没有图层绑定图例组时的特殊处理
        if (widget.selectedLayer == null &&
            (widget.selectedLayerGroup == null ||
                widget.selectedLayerGroup!.isEmpty)) {
          // 整个地图范围但没有可用的图例组，可能需要提示用户
        }
      }

      // 统计图例项数量
      for (final legendGroup in targetLegendGroups) {
        if (!legendGroup.isVisible) continue;

        for (final legendItem in legendGroup.legendItems) {
          if (!legendItem.isVisible) continue;

          final legendPath = legendItem.legendPath;
          legendCounts[legendPath] = (legendCounts[legendPath] ?? 0) + 1;

          // 从图例会话管理器获取图例数据
          if (!legendItems.containsKey(legendPath)) {
            try {
              // 首先尝试从会话中获取已加载的图例数据
              final sessionLegendData = _legendSessionManager.getLegendData(
                legendPath,
              );
              if (sessionLegendData != null) {
                legendItems[legendPath] = sessionLegendData;
              } else {
                // 如果会话中没有，异步加载图例数据
                _legendSessionManager.loadLegend(legendPath).then((loadedItem) {
                  if (mounted && loadedItem != null) {
                    setState(() {
                      _legendItems[legendPath] = loadedItem;
                    });
                  }
                });
                legendItems[legendPath] = null;
              }
            } catch (e) {
              debugPrint('加载图例数据失败: $legendPath, 错误: $e');
              legendItems[legendPath] = null;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _legendCounts = legendCounts;
          _legendItems = legendItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('更新图例数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 处理图例项点击事件
  void _handleLegendItemClick(String legendPath) {
    final totalCount = _legendCounts[legendPath] ?? 0;
    if (totalCount == 0) return;

    // 获取可选择的图例组和计算可选择的图例数量
    final selectionTargetGroups = _getTargetLegendGroups(forSelection: true);
    int selectableCount = 0;
    bool canSelect = false;

    // 计算可选择的图例数量并检查当前图例是否可选
    for (final legendGroup in selectionTargetGroups) {
      if (!legendGroup.isVisible) continue;
      for (final legendItem in legendGroup.legendItems) {
        if (!legendItem.isVisible) continue;
        if (legendItem.legendPath == legendPath) {
          selectableCount++;
          canSelect = true;
        }
      }
    }

    if (!canSelect) {
      // 图例被遮挡，显示提示
      if (widget.selectedLayer == null &&
          (widget.selectedLayerGroup == null ||
              widget.selectedLayerGroup!.isEmpty)) {
        // 整个地图范围
        _showLegendBlockedMessage('图例被遮挡');
      } else {
        // 图层或图层组范围
        _showLegendBlockedMessage('图例被遮挡');
      }
      return;
    }

    final currentIndex = _selectedIndices[legendPath];

    if (currentIndex == null) {
      // 未选中状态，清除其他选中项并选中第一个
      setState(() {
        _selectedIndices.clear(); // 清除所有其他选中项
        _selectedIndices[legendPath] = 0;
      });
      _selectLegendItemByIndex(legendPath, 0);
    } else if (currentIndex >= selectableCount - 1) {
      // 当前是可选择范围内的最后一个，检查是否还有其他被遮挡的图例
      if (selectableCount < totalCount) {
        // 还有被遮挡的图例，显示提示并取消选中
        if (widget.selectedLayer == null &&
            (widget.selectedLayerGroup == null ||
                widget.selectedLayerGroup!.isEmpty)) {
          _showLegendBlockedMessage('剩余图例被遮挡');
        } else {
          _showLegendBlockedMessage('剩余图例被遮挡');
        }
      }
      // 取消选中
      setState(() {
        _selectedIndices.remove(legendPath);
      });
      // 通知父组件取消选中
      widget.onLegendItemSelected?.call('');
    } else {
      // 选中下一个
      final nextIndex = currentIndex + 1;
      setState(() {
        _selectedIndices[legendPath] = nextIndex;
      });
      _selectLegendItemByIndex(legendPath, nextIndex);
    }
  }

  /// 显示图例被遮挡的提示消息
  void _showLegendBlockedMessage(String message) {
    // 使用通知服务显示警告信息
    context.showNotificationSnackBar(message, type: NotificationType.warning);
  }

  /// 获取目标图例组（根据统计范围）
  /// [forSelection] 为true时用于循环选择，为false时用于统计显示
  List<LegendGroup> _getTargetLegendGroups({bool forSelection = false}) {
    // 当统计范围是图层或图层组时
    if (widget.selectedLayer != null ||
        (widget.selectedLayerGroup != null &&
            widget.selectedLayerGroup!.isNotEmpty)) {
      final boundLegendGroupIds = <String>{};

      // 收集选中图层绑定的图例组ID
      if (widget.selectedLayer != null) {
        boundLegendGroupIds.addAll(widget.selectedLayer!.legendGroupIds);
      }

      // 收集选中图层组中所有图层绑定的图例组ID
      if (widget.selectedLayerGroup != null &&
          widget.selectedLayerGroup!.isNotEmpty) {
        for (final layer in widget.selectedLayerGroup!) {
          boundLegendGroupIds.addAll(layer.legendGroupIds);
        }
      }

      return widget.mapItem.legendGroups
          .where((group) => boundLegendGroupIds.contains(group.id))
          .toList();
    } else {
      // 当统计范围是整个地图时
      if (forSelection) {
        // 用于循环选择：只显示绑定在最上方图层的图例组
        final layers = widget.mapItem.layers;
        if (layers.isEmpty) return [];

        // 按order排序，找到最上方的图层
        final sortedLayers = List<MapLayer>.from(layers)
          ..sort((a, b) => b.order.compareTo(a.order));

        // 找到最上方的可见图层
        MapLayer? topmostLayer;
        for (final layer in sortedLayers) {
          if (layer.isVisible) {
            topmostLayer = layer;
            break;
          }
        }

        if (topmostLayer == null) {
          return [];
        }

        // 返回绑定在最上方图层的图例组
        return widget.mapItem.legendGroups
            .where((group) => topmostLayer!.legendGroupIds.contains(group.id))
            .toList();
      } else {
        // 用于统计显示：显示整个地图的所有图例组
        return widget.mapItem.legendGroups;
      }
    }
  }

  /// 根据索引选中图例项
  void _selectLegendItemByIndex(String legendPath, int index) {
    // 获取用于选择的图例组（应用范围限制）
    List<LegendGroup> targetLegendGroups = _getTargetLegendGroups(
      forSelection: true,
    );

    // 查找匹配的图例项
    int currentIndex = 0;
    for (final legendGroup in targetLegendGroups) {
      if (!legendGroup.isVisible) continue;

      for (final legendItem in legendGroup.legendItems) {
        if (!legendItem.isVisible) continue;

        if (legendItem.legendPath == legendPath) {
          if (currentIndex == index) {
            // 找到目标图例项，通知父组件
            widget.onLegendItemSelected?.call(legendItem.id);
            return;
          }
          currentIndex++;
        }
      }
    }
  }

  /// 同步画布选择状态到dock栏
  void _syncCanvasSelection() {
    if (widget.selectedElementId == null || widget.selectedElementId!.isEmpty) {
      // 画布没有选中任何元素，清除dock栏的选择状态
      setState(() {
        _selectedIndices.clear();
      });
      return;
    }

    // 查找选中的图例项对应的legendPath和索引
    final targetLegendGroups = _getTargetLegendGroups(forSelection: true);

    for (final legendGroup in targetLegendGroups) {
      if (!legendGroup.isVisible) continue;

      for (final legendItem in legendGroup.legendItems) {
        if (!legendItem.isVisible) continue;

        if (legendItem.id == widget.selectedElementId) {
          // 找到匹配的图例项，计算它在同legendPath中的索引
          final legendPath = legendItem.legendPath;
          int index = 0;

          // 重新遍历计算索引
          for (final group in targetLegendGroups) {
            if (!group.isVisible) continue;

            for (final item in group.legendItems) {
              if (!item.isVisible) continue;

              if (item.legendPath == legendPath) {
                if (item.id == widget.selectedElementId) {
                  // 找到目标项，更新选择状态
                  setState(() {
                    _selectedIndices.clear(); // 清除其他选中项
                    _selectedIndices[legendPath] = index;
                  });
                  // 滚动到选中的图例项
                  _scrollToSelectedLegendItem(legendPath);
                  return;
                }
                index++;
              }
            }
          }
        }
      }
    }

    // 如果没有找到匹配的图例项，清除选择状态
    setState(() {
      _selectedIndices.clear();
    });
  }

  /// 滚动到选中的图例项
  void _scrollToSelectedLegendItem(String selectedLegendPath) {
    if (!_scrollController.hasClients) {
      return;
    }

    // 获取所有可见的图例路径列表
    final visibleLegendPaths = _legendCounts.keys.toList();
    final selectedIndex = visibleLegendPaths.indexOf(selectedLegendPath);

    if (selectedIndex == -1) {
      return; // 没有找到选中的图例项
    }

    // 计算图例项的位置
    const itemWidth = 80.0; // 估算的图例项宽度（包括间距）
    const itemSpacing = 8.0; // 图例项之间的间距
    final itemPosition = selectedIndex * (itemWidth + itemSpacing);

    // 获取滚动视图的宽度
    final scrollViewWidth = _scrollController.position.viewportDimension;

    // 计算目标滚动位置（将选中项居中）
    final targetScrollOffset =
        itemPosition - (scrollViewWidth / 2) + (itemWidth / 2);

    // 确保滚动位置在有效范围内
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetScrollOffset.clamp(0.0, maxScrollExtent);

    // 平滑滚动到目标位置
    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 80),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoading
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : _legendCounts.isEmpty
          ? _buildNoLegendIndicator()
          : _buildLegendList(),
    );
  }

  /// 切换图层选择气泡的显示状态
  void _toggleLayerPopup() {
    if (_showLayerPopup) {
      // 如果菜单已显示，关闭它
      Navigator.of(context).pop();
      setState(() {
        _showLayerPopup = false;
      });
    } else {
      // 显示菜单
      setState(() {
        _showLayerPopup = true;
      });
      _showLayerMenu();
    }
  }

  /// 显示图层选择菜单
  void _showLayerMenu() {
    // 获取图标的位置
    final RenderBox? renderBox =
        _layerIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      if (mounted) {
        setState(() {
          _showLayerPopup = false;
        });
      }
      return;
    }

    final Offset iconPosition = renderBox.localToGlobal(Offset.zero);
    final Size iconSize = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            // 透明背景，点击关闭菜单
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            // 菜单内容
            _buildPositionedLayerMenu(dialogContext, iconPosition, iconSize),
          ],
        );
      },
    ).then((_) {
      // 对话框关闭时重置状态
      if (mounted) {
        setState(() {
          _showLayerPopup = false;
        });
      }
    });
  }

  /// 将图层分组为链接组
  List<List<MapLayer>> _groupLinkedLayers() {
    final groups = <List<MapLayer>>[];
    List<MapLayer> currentGroup = [];

    for (int i = 0; i < widget.mapItem.layers.length; i++) {
      final layer = widget.mapItem.layers[i];
      currentGroup.add(layer);

      // 如果当前图层不链接到下一个，或者是最后一个图层，结束当前组
      if (!layer.isLinkedToNext || i == widget.mapItem.layers.length - 1) {
        groups.add(List.from(currentGroup));
        currentGroup.clear();
      }
    }

    return groups;
  }

  /// 构建定位的图层菜单
  Widget _buildPositionedLayerMenu(
    BuildContext dialogContext,
    Offset iconPosition,
    Size iconSize,
  ) {
    // 计算气泡菜单的位置，确保在屏幕可见范围内
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final popupWidth = 200.0; // 气泡菜单宽度

    // 获取图层组
    final layerGroups = _groupLinkedLayers();

    // 动态计算菜单高度
    final itemHeight = 44.0; // 每个菜单项的高度
    final separatorHeight = 16.0; // 分隔线高度（包括margin）
    final padding = 24.0; // 容器内边距

    // 计算总菜单项数量（包括图层组标题和子图层）
    int totalMenuItems = 1; // 清除选择按钮
    for (final group in layerGroups) {
      if (group.length > 1) {
        // 多图层组：组标题 + 组内图层数量
        totalMenuItems += 1 + group.length;
      } else {
        // 单图层：只有一个项目
        totalMenuItems += 1;
      }
    }

    final separatorCount = layerGroups.isNotEmpty ? 1 : 0; // 分隔线数量
    final popupHeight =
        (totalMenuItems * itemHeight) +
        (separatorCount * separatorHeight) +
        padding;

    // 计算top位置，优先显示在图标上方
    double top;
    final spaceAbove = iconPosition.dy;
    final spaceBelow = screenHeight - (iconPosition.dy + iconSize.height);

    if (spaceAbove >= popupHeight + 20) {
      // 图标上方有足够空间，显示在上方
      top = iconPosition.dy - popupHeight - 10;
    } else if (spaceBelow >= popupHeight + 20) {
      // 图标下方有足够空间，显示在下方
      top = iconPosition.dy + iconSize.height + 10;
    } else {
      // 两边空间都不够，选择空间较大的一边，并调整到屏幕边界
      if (spaceAbove > spaceBelow) {
        // 上方空间较大，贴近屏幕顶部
        top = 10;
      } else {
        // 下方空间较大，贴近屏幕底部
        top = screenHeight - popupHeight - 10;
      }
    }

    // 计算left位置，以图标为中心，向左偏移半个菜单宽度
    double left = iconPosition.dx + (iconSize.width / 2) - (popupWidth / 2);

    // 确保不超出屏幕边界
    if (left + popupWidth > screenWidth) {
      left = screenWidth - popupWidth - 10;
    }
    if (left < 10) {
      left = 10;
    }

    return Positioned(
      top: top,
      left: left,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图层组选项
              ...layerGroups.asMap().entries.expand((entry) {
                final groupIndex = entry.key;
                final group = entry.value;
                final widgets = <Widget>[];

                if (group.length > 1) {
                  // 多图层组
                  final isGroupSelected =
                      widget.selectedLayerGroup != null &&
                      widget.selectedLayerGroup!.length == group.length &&
                      widget.selectedLayerGroup!.every(
                        (selectedLayer) => group.any(
                          (groupLayer) => groupLayer.id == selectedLayer.id,
                        ),
                      );

                  // 添加图层组标题
                  widgets.add(
                    _buildPopupMenuItem(
                      icon: Icons.layers,
                      title: '图层组 ${groupIndex + 1} (${group.length}层)',
                      isSelected: isGroupSelected,
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        if (isGroupSelected) {
                          // 如果已经选中，则清除图层组选择
                          widget.onLayerGroupSelectionCleared?.call();
                        } else {
                          // 如果未选中，则选择该图层组
                          widget.onLayerGroupSelected?.call(group);
                        }
                      },
                    ),
                  );

                  // 添加组内的图层（缩进显示）
                  for (final layer in group) {
                    final isLayerSelected =
                        widget.selectedLayer?.id == layer.id;
                    widgets.add(
                      _buildPopupMenuItem(
                        icon: Icons.layers_outlined,
                        title: layer.name,
                        isSelected: isLayerSelected,
                        isIndented: true,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          if (isLayerSelected) {
                            // 如果已经选中，则清除图层选择
                            widget.onLayerSelectionCleared?.call();
                          } else {
                            // 如果未选中，则选择该图层
                            widget.onLayerSelected?.call(layer);
                          }
                        },
                      ),
                    );
                  }
                } else {
                  // 单图层
                  final layer = group.first;
                  final isLayerSelected = widget.selectedLayer?.id == layer.id;
                  widgets.add(
                    _buildPopupMenuItem(
                      icon: Icons.layers_outlined,
                      title: layer.name,
                      isSelected: isLayerSelected,
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        if (isLayerSelected) {
                          // 如果已经选中，则清除图层选择
                          widget.onLayerSelectionCleared?.call();
                        } else {
                          // 如果未选中，则选择该图层
                          widget.onLayerSelected?.call(layer);
                        }
                      },
                    ),
                  );
                }

                return widgets;
              }),

              // 分隔线
              if (layerGroups.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  height: 1,
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),

              // 清除选择按钮
              _buildPopupMenuItem(
                icon: Icons.clear,
                title: '清除选择',
                isSelected: false,
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  // 调用清除选择回调
                  widget.onSelectionCleared?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建气泡菜单项
  Widget _buildPopupMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isIndented = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // 缩进空间
            if (isIndented) const SizedBox(width: 12),
            // 选中背景容器
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      icon,
                      size: isIndented ? 14 : 16,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : isIndented
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : isIndented
                              ? Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.8)
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: isIndented ? 13 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建无图例指示器
  Widget _buildNoLegendIndicator() {
    // 根据当前状态确定提示消息
    String message;
    IconData iconData;

    final displayTargetGroups = _getTargetLegendGroups(); // 用于显示的图例组
    final selectionTargetGroups = _getTargetLegendGroups(
      forSelection: true,
    ); // 用于选择的图例组

    if (widget.selectedLayer == null &&
        (widget.selectedLayerGroup == null ||
            widget.selectedLayerGroup!.isEmpty)) {
      // 整个地图范围
      if (displayTargetGroups.isEmpty) {
        message = '暂无图例';
        iconData = Icons.info_outline;
      } else if (selectionTargetGroups.isEmpty) {
        message = '无可用图例';
        iconData = Icons.warning_outlined;
      } else {
        message = '暂无图例';
        iconData = Icons.info_outline;
      }
    } else {
      // 图层或图层组范围
      if (displayTargetGroups.isEmpty) {
        message = '无绑定图例';
        iconData = Icons.info_outline;
      } else {
        message = '暂无图例';
        iconData = Icons.info_outline;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题图标
        GestureDetector(
          key: _layerIconKey,
          onTap: _toggleLayerPopup,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.selectedLayerGroup != null &&
                      widget.selectedLayerGroup!.isNotEmpty
                  ? Icons.layers
                  : Icons.map,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 状态图标
        Icon(
          iconData,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),

        // 提示文本
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),

        // 图例组管理按钮（常驻显示）
        if (widget.onToggleLegendGroupManagement != null) ...[
          const SizedBox(width: 8),
          _buildLegendGroupManagementButton(),
        ],
      ],
    );
  }

  /// 构建图例列表
  Widget _buildLegendList() {
    final legendEntries = _legendCounts.entries.toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题图标
        GestureDetector(
          key: _layerIconKey,
          onTap: _toggleLayerPopup,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.selectedLayerGroup != null &&
                      widget.selectedLayerGroup!.isNotEmpty
                  ? Icons.layers
                  : Icons.map,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 图例项列表
        Flexible(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...legendEntries.map((entry) {
                  return _buildLegendItem(entry.key, entry.value);
                }).toList(),
              ],
            ),
          ),
        ),

        // 图例组管理按钮（常驻显示，不滚动）
        if (widget.onToggleLegendGroupManagement != null) ...[
          const SizedBox(width: 8),
          _buildLegendGroupManagementButton(),
        ],
      ],
    );
  }

  /// 构建单个图例项
  Widget _buildLegendItem(String legendPath, int count) {
    final legendItem = _legendItems[legendPath];
    final currentIndex = _selectedIndices[legendPath];
    final isSelected = currentIndex != null;

    // 构建数量标签文本
    String countText;
    if (isSelected) {
      countText = '${currentIndex + 1}/$count';
    } else {
      countText = count.toString();
    }

    return Tooltip(
      message: isSelected
          ? '$legendPath\n当前选中: ${currentIndex + 1}/$count'
          : '$legendPath\n点击选择图例项',
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () => _handleLegendItemClick(legendPath),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图例图片
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: legendItem?.imageData != null
                      ? _buildLegendThumbnail(legendItem!, 28, 28)
                      : _buildPlaceholderIcon(),
                ),
              ),
              const SizedBox(width: 6),

              // 数量标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  countText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建占位符图标
  Widget _buildPlaceholderIcon() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Icon(
        Icons.image_outlined,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// 显示图例组选择菜单
  void _showLegendGroupMenu(BuildContext context, Offset position) {
    // 获取当前查看范围内的图例组列表（与左键逻辑保持一致）
    final targetLegendGroups = _getTargetLegendGroups();

    if (targetLegendGroups.isEmpty) {
      // 没有可用的图例组
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            // 透明背景，点击关闭菜单
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            // 菜单内容
            _buildPositionedLegendGroupMenu(
              dialogContext,
              position,
              targetLegendGroups,
            ),
          ],
        );
      },
    );
  }

  /// 构建定位的图例组菜单
  Widget _buildPositionedLegendGroupMenu(
    BuildContext dialogContext,
    Offset position,
    List<LegendGroup> targetLegendGroups,
  ) {
    // 计算气泡菜单的位置，确保在屏幕可见范围内
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final popupWidth = 170.0; // 图例组菜单宽度

    // 动态计算菜单高度
    final itemHeight = 44.0; // 每个菜单项的高度
    final padding = 48.0; // 容器内边距
    final popupHeight = (targetLegendGroups.length * itemHeight) + padding;

    // 计算top位置，优先显示在点击位置上方
    double top;
    final spaceAbove = position.dy;
    final spaceBelow = screenHeight - position.dy;

    if (spaceAbove >= popupHeight + 20) {
      // 上方有足够空间，显示在上方
      top = position.dy - popupHeight - 10;
    } else if (spaceBelow >= popupHeight + 20) {
      // 下方有足够空间，显示在下方
      top = position.dy + 10;
    } else {
      // 两边空间都不够，选择空间较大的一边
      if (spaceAbove > spaceBelow) {
        top = 10;
      } else {
        top = screenHeight - popupHeight - 10;
      }
    }

    // 计算left位置，以点击位置为中心，向左偏移半个菜单宽度
    double left = position.dx - (popupWidth / 2);

    // 确保不超出屏幕边界
    if (left + popupWidth > screenWidth) {
      left = screenWidth - popupWidth - 10;
    }
    if (left < 10) {
      left = 10;
    }

    return Positioned(
      top: top,
      left: left,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: BoxConstraints(maxWidth: popupWidth),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: targetLegendGroups.map((legendGroup) {
              return _buildLegendGroupMenuItem(
                legendGroup: legendGroup,
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  // 检查是否为当前打开的图例组
                  final isCurrentlyOpen =
                      widget.currentLegendGroupForManagement?.id ==
                      legendGroup.id;
                  if (isCurrentlyOpen) {
                    // 如果是当前打开的图例组，则关闭抽屉
                    widget.onToggleLegendGroupManagement?.call();
                  } else {
                    // 如果不是当前打开的图例组，则打开该图例组
                    widget.onLegendGroupSelected?.call(legendGroup);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// 构建图例组菜单项
  Widget _buildLegendGroupMenuItem({
    required LegendGroup legendGroup,
    required VoidCallback onTap,
  }) {
    // 检查是否为当前打开的图例组
    final isCurrentlyOpen =
        widget.currentLegendGroupForManagement?.id == legendGroup.id;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrentlyOpen
                      ? Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isCurrentlyOpen
                      ? Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      legendGroup.isVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 16,
                      color: legendGroup.isVisible
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        legendGroup.name.isNotEmpty
                            ? legendGroup.name
                            : '未命名图例组',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isCurrentlyOpen
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isCurrentlyOpen
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrentlyOpen
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${legendGroup.legendItems.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCurrentlyOpen
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图例组管理按钮
  Widget _buildLegendGroupManagementButton() {
    return Tooltip(
      message: '左键：打开图例组管理\n右键：选择图例组',
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: widget.onToggleLegendGroupManagement,
        onSecondaryTapDown: (details) {
          _showLegendGroupMenu(context, details.globalPosition);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.settings,
            size: 16,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  /// 构建图例缩略图组件
  Widget _buildLegendThumbnail(
    legend_db.LegendItem legend,
    double width,
    double height,
  ) {
    if (!legend.hasImageData) {
      return Icon(
        Icons.image,
        size: width * 0.6,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    // 检查是否为SVG格式
    if (legend.fileType == legend_db.LegendFileType.svg) {
      try {
        return ScalableImageWidget.fromSISource(
          si: ScalableImageSource.fromSvgHttpUrl(
            Uri.dataFromBytes(legend.imageData!, mimeType: 'image/svg+xml'),
          ),
          fit: BoxFit.cover,
        );
      } catch (e) {
        debugPrint('SVG图例缩略图加载失败: $e');
        return Icon(
          Icons.image_not_supported,
          size: width * 0.6,
          color: Theme.of(context).colorScheme.error,
        );
      }
    } else {
      // 普通图片格式
      return Image.memory(
        legend.imageData!,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            size: width * 0.6,
            color: Theme.of(context).colorScheme.error,
          );
        },
      );
    }
  }
}
