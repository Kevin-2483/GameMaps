import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import '../../../services/legend_cache_manager.dart';
import '../../../services/reactive_version/reactive_version_manager.dart';
import '../../../models/legend_item.dart' as legend_db;

/// 缓存图例展示组件
class CachedLegendsDisplay extends StatefulWidget {
  final Function(String)? onLegendSelected; // 图例选中回调
  final ReactiveVersionManager? versionManager; // 版本管理器
  final String? currentLegendGroupId; // 当前图例组ID
  final Function(String, Offset)? onLegendDragToCanvas; // 新增：拖拽到画布的回调
  final VoidCallback? onDragStart; // 新增：拖拽开始回调（用于关闭抽屉）
  final VoidCallback? onDragEnd; // 新增：拖拽结束回调（用于重新打开抽屉）

  const CachedLegendsDisplay({
    super.key,
    this.onLegendSelected,
    this.versionManager,
    this.currentLegendGroupId,
    this.onLegendDragToCanvas, // 新增参数
    this.onDragStart, // 新增参数
    this.onDragEnd, // 新增参数
  });

  @override
  State<CachedLegendsDisplay> createState() => _CachedLegendsDisplayState();
}

class _CachedLegendsDisplayState extends State<CachedLegendsDisplay> {
  final LegendCacheManager _cacheManager = LegendCacheManager();
  Map<String, List<String>> _ownSelectedLegends = {}; // 自己组选中的图例
  Map<String, List<String>> _otherSelectedLegends = {}; // 其他组选中的图例
  Map<String, List<String>> _unselectedLegends = {}; // 未选中但已加载的图例

  @override
  void initState() {
    super.initState();
    _cacheManager.addListener(_updateCachedLegends);
    widget.versionManager?.addListener(_updateCachedLegends);
    _updateCachedLegends();
  }

  @override
  void didUpdateWidget(CachedLegendsDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果版本管理器变化，需要重新监听
    if (widget.versionManager != oldWidget.versionManager) {
      oldWidget.versionManager?.removeListener(_updateCachedLegends);
      widget.versionManager?.addListener(_updateCachedLegends);
    }

    // 如果当前图例组ID变化，需要重新计算分类
    if (widget.currentLegendGroupId != oldWidget.currentLegendGroupId) {
      debugPrint(
        '[CachedLegendsDisplay] 图例组ID变化: ${oldWidget.currentLegendGroupId} -> ${widget.currentLegendGroupId}，刷新缓存显示',
      );
      _updateCachedLegends();
    }
  }

  @override
  void dispose() {
    _cacheManager.removeListener(_updateCachedLegends);
    widget.versionManager?.removeListener(_updateCachedLegends);
    super.dispose();
  }

  /// 更新缓存图例列表
  void _updateCachedLegends() {
    debugPrint(
      '[CachedLegendsDisplay] 开始更新缓存图例列表，当前图例组ID: ${widget.currentLegendGroupId}',
    );

    final cachedItems = _cacheManager.getAllCachedLegends();
    debugPrint('[CachedLegendsDisplay] 当前缓存图例数量: ${cachedItems.length}');

    final Map<String, List<String>> ownSelected = {};
    final Map<String, List<String>> otherSelected = {};
    final Map<String, List<String>> unselected = {};

    // 获取选中状态信息
    Set<String> ownSelectedPaths = {};
    Set<String> otherSelectedPaths = {};

    if (widget.versionManager != null && widget.currentLegendGroupId != null) {
      ownSelectedPaths = widget.versionManager!.getSelectedPaths(
        widget.currentLegendGroupId!,
      );
      final allSelectedPaths = widget.versionManager!.getAllSelectedPaths();
      otherSelectedPaths = Set<String>.from(allSelectedPaths)
        ..removeAll(ownSelectedPaths);

      debugPrint('[CachedLegendsDisplay] 自己组选中路径: $ownSelectedPaths');
      debugPrint('[CachedLegendsDisplay] 其他组选中路径: $otherSelectedPaths');
    }

    for (final legendPath in cachedItems) {
      // 从路径确定目录
      String directory = '';
      final lastSlashIndex = legendPath.lastIndexOf('/');
      if (lastSlashIndex != -1) {
        directory = legendPath.substring(0, lastSlashIndex);
      }
      final displayDirectory = directory.isEmpty ? '根目录' : directory;

      // 判断图例属于哪个分类
      bool isOwnSelected = false;
      bool isOtherSelected = false;

      // 检查图例路径是否属于选中的目录
      for (final selectedPath in ownSelectedPaths) {
        if (directory == selectedPath ||
            directory.startsWith('$selectedPath/')) {
          isOwnSelected = true;
          break;
        }
      }

      if (!isOwnSelected) {
        for (final selectedPath in otherSelectedPaths) {
          if (directory == selectedPath ||
              directory.startsWith('$selectedPath/')) {
            isOtherSelected = true;
            break;
          }
        }
      }

      // 分类存储
      Map<String, List<String>> targetMap;
      if (isOwnSelected) {
        targetMap = ownSelected;
      } else if (isOtherSelected) {
        targetMap = otherSelected;
      } else {
        targetMap = unselected;
      }

      if (!targetMap.containsKey(displayDirectory)) {
        targetMap[displayDirectory] = [];
      }
      targetMap[displayDirectory]!.add(legendPath);
    }

    setState(() {
      _ownSelectedLegends = ownSelected;
      _otherSelectedLegends = otherSelected;
      _unselectedLegends = unselected;
    });

    // 输出分类结果
    final totalOwnSelected = ownSelected.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final totalOtherSelected = otherSelected.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final totalUnselected = unselected.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    debugPrint(
      '[CachedLegendsDisplay] 缓存图例分类完成：自己组 $totalOwnSelected，其他组 $totalOtherSelected，未选中 $totalUnselected',
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalOwnSelected = _ownSelectedLegends.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final totalOtherSelected = _otherSelectedLegends.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final totalUnselected = _unselectedLegends.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );

    if (totalOwnSelected + totalOtherSelected + totalUnselected == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无缓存图例',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '选择VFS目录来加载图例到缓存',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        // 1. 自己组选中的图例（最上方，绿色主题）
        if (_ownSelectedLegends.isNotEmpty) ...[
          _buildCategoryHeader(
            '自己组选中',
            totalOwnSelected,
            Colors.green,
            Icons.check_circle,
          ),
          ..._ownSelectedLegends.entries.map(
            (entry) => _buildDirectorySection(
              entry.key,
              entry.value,
              Colors.green.shade50,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // 2. 其他组选中的图例（中间，橙色主题）
        if (_otherSelectedLegends.isNotEmpty) ...[
          _buildCategoryHeader(
            '其他组选中',
            totalOtherSelected,
            Colors.orange,
            Icons.group,
          ),
          ..._otherSelectedLegends.entries.map(
            (entry) => _buildDirectorySection(
              entry.key,
              entry.value,
              Colors.orange.shade50,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // 3. 未选中但已加载的图例（最下方，灰色主题）
        if (_unselectedLegends.isNotEmpty) ...[
          _buildCategoryHeader(
            '未选中但已加载',
            totalUnselected,
            Colors.grey,
            Icons.storage,
          ),
          ..._unselectedLegends.entries.map(
            (entry) => _buildDirectorySection(
              entry.key,
              entry.value,
              Colors.grey.shade50,
            ),
          ),
        ],
      ],
    );
  }

  /// 构建分类标题
  Widget _buildCategoryHeader(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$title ($count)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Expanded(child: Divider(indent: 8, color: color.withValues(alpha: 0.3))),
        ],
      ),
    );
  }

  /// 构建目录段落
  Widget _buildDirectorySection(
    String directory,
    List<String> legends, [
    Color? backgroundColor,
  ]) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: backgroundColor?.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.1 : 1.0,
      ),
      child: ExpansionTile(
        title: Text(
          directory,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${legends.length} 个图例',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        leading: Icon(
          Icons.folder,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: _buildLegendsGrid(legends),
          ),
        ],
      ),
    );
  }

  /// 构建图例网格
  Widget _buildLegendsGrid(List<String> legends) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据容器宽度动态计算列数
        // 抽屉宽度300-600，减去padding等，实际可用宽度约为280-580
        // 每个瓦片最小宽度约80，最大宽度约120
        final availableWidth = constraints.maxWidth;
        int crossAxisCount;
        
        if (availableWidth < 280) {
          crossAxisCount = 3; // 最少3列
        } else if (availableWidth < 360) {
          crossAxisCount = 3;
        } else if (availableWidth < 440) {
          crossAxisCount = 4;
        } else if (availableWidth < 520) {
          crossAxisCount = 5;
        } else {
          crossAxisCount = 6; // 最多6列
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1.0,
          ),
          itemCount: legends.length,
          itemBuilder: (context, index) {
            final legendPath = legends[index];
            return _buildLegendTile(legendPath);
          },
        );
      },
    );
  }

  /// 构建单个图例瓦片
  Widget _buildLegendTile(String legendPath) {
    return FutureBuilder<legend_db.LegendItem?>(
      future: _cacheManager.getLegendData(legendPath),
      builder: (context, snapshot) {
        final legend = snapshot.data;

        return Draggable<String>(
          data: legendPath,
          onDragStarted: () {
            debugPrint('开始拖拽图例: $legendPath');
            // 通知抽屉关闭
            widget.onDragStart?.call();
          },
          onDragEnd: (details) {
            debugPrint('结束拖拽图例: $legendPath, 是否被接受: ${details.wasAccepted}');
          },
          onDragCompleted: () {
            debugPrint('拖拽完成: $legendPath');
            widget.onDragEnd?.call();
          },
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.9),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: legend?.hasImageData == true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: _buildLegendThumbnail(legend!, 30, 30),
                          )
                        : Icon(
                            Icons.legend_toggle,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    legend?.title ?? _extractLegendName(legendPath),
                    style: TextStyle(
                      fontSize: 8,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          childWhenDragging: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.drag_indicator,
                    size: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '拖拽中...',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          child: InkWell(
            onTap: () => widget.onLegendSelected?.call(legendPath),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 图例预览图标 (增大尺寸)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: legend?.hasImageData == true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: _buildLegendThumbnail(legend!, 34, 34),
                          )
                        : Icon(
                            Icons.legend_toggle,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                  ),
                  const SizedBox(height: 4),
                  // 图例标题
                  Text(
                    legend?.title ?? _extractLegendName(legendPath),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  /// 从路径中提取图例名称
  String _extractLegendName(String legendPath) {
    final fileName = legendPath.split('/').last;
    return fileName.replaceAll('.legend', '');
  }
}
