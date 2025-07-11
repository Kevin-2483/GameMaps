import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import '../../../models/map_layer.dart';
import '../../../models/map_item.dart';
import '../../../models/legend_item.dart' as legend_db;
import '../../../services/legend_cache_manager.dart';

/// 浮动图例dock栏组件
/// 显示当前选中图层组或整个地图使用的图例以及数量
class LegendDockBar extends StatefulWidget {
  final MapItem mapItem;
  final List<MapLayer>? selectedLayerGroup; // 当前选中的图层组
  final MapLayer? selectedLayer; // 当前选中的图层
  final bool isVisible; // 是否显示dock栏

  const LegendDockBar({
    super.key,
    required this.mapItem,
    this.selectedLayerGroup,
    this.selectedLayer,
    this.isVisible = true,
  });

  @override
  State<LegendDockBar> createState() => _LegendDockBarState();
}

class _LegendDockBarState extends State<LegendDockBar> {
  final LegendCacheManager _legendCacheManager = LegendCacheManager();
  Map<String, int> _legendCounts = {}; // 图例路径 -> 数量
  Map<String, legend_db.LegendItem?> _legendItems = {}; // 图例路径 -> 图例数据
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateLegendData();
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
      List<LegendGroup> targetLegendGroups;
      
      if (widget.selectedLayerGroup != null && widget.selectedLayerGroup!.isNotEmpty) {
        // 如果选中了图层组，获取图层组中所有图层绑定的图例组
        final boundLegendGroupIds = <String>{};
        
        for (final layer in widget.selectedLayerGroup!) {
          boundLegendGroupIds.addAll(layer.legendGroupIds);
        }
        
        targetLegendGroups = widget.mapItem.legendGroups
            .where((group) => boundLegendGroupIds.contains(group.id))
            .toList();
      } else {
        // 没有选中图层组，显示整个地图的图例
        targetLegendGroups = widget.mapItem.legendGroups;
      }

      // 统计图例项数量
      for (final legendGroup in targetLegendGroups) {
        if (!legendGroup.isVisible) continue;
        
        for (final legendItem in legendGroup.legendItems) {
          if (!legendItem.isVisible) continue;
          
          final legendPath = legendItem.legendPath;
          legendCounts[legendPath] = (legendCounts[legendPath] ?? 0) + 1;
          
          // 从缓存管理器获取图例数据（如果还没有加载）
          if (!legendItems.containsKey(legendPath)) {
            try {
              // 从缓存管理器获取图例数据
              final cachedLegends = _legendCacheManager.getAllCachedLegends();
              if (cachedLegends.contains(legendPath)) {
                final allCacheItems = _legendCacheManager.getAllCacheItems();
                final cachedItem = allCacheItems[legendPath];
                if (cachedItem != null && cachedItem.state == LegendLoadingState.loaded) {
                  legendItems[legendPath] = cachedItem.legendData;
                } else {
                  // 异步加载图例数据
                  _legendCacheManager.getLegendData(legendPath).then((loadedItem) {
                    if (mounted && loadedItem != null) {
                      setState(() {
                        _legendItems[legendPath] = loadedItem;
                      });
                    }
                  });
                  legendItems[legendPath] = null;
                }
              } else {
                // 异步加载图例数据
                _legendCacheManager.getLegendData(legendPath).then((loadedItem) {
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

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || _legendCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 600,
        maxHeight: 80,
      ),
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
          : _buildLegendList(),
    );
  }

  /// 构建图例列表
  Widget _buildLegendList() {
    final legendEntries = _legendCounts.entries.toList();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题图标
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.selectedLayerGroup != null && widget.selectedLayerGroup!.isNotEmpty
                ? Icons.layers
                : Icons.map,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        
        // 图例项列表
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: legendEntries.map((entry) {
                return _buildLegendItem(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建单个图例项
  Widget _buildLegendItem(String legendPath, int count) {
    final legendItem = _legendItems[legendPath];
    
    return Tooltip(
      message: legendPath,
      waitDuration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
                count.toString(),
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