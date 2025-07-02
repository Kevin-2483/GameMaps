import 'package:flutter/material.dart';
import '../../../services/legend_cache_manager.dart';
import '../../../models/legend_item.dart' as legend_db;

/// 缓存图例展示组件
class CachedLegendsDisplay extends StatefulWidget {
  final Function(String)? onLegendSelected; // 图例选中回调

  const CachedLegendsDisplay({
    super.key,
    this.onLegendSelected,
  });

  @override
  State<CachedLegendsDisplay> createState() => _CachedLegendsDisplayState();
}

class _CachedLegendsDisplayState extends State<CachedLegendsDisplay> {
  final LegendCacheManager _cacheManager = LegendCacheManager();
  Map<String, List<String>> _groupedLegends = {};

  @override
  void initState() {
    super.initState();
    _cacheManager.addListener(_updateCachedLegends);
    _updateCachedLegends();
  }

  @override
  void dispose() {
    _cacheManager.removeListener(_updateCachedLegends);
    super.dispose();
  }

  /// 更新缓存图例列表
  void _updateCachedLegends() {
    final cachedItems = _cacheManager.getAllCachedLegends();
    final Map<String, List<String>> grouped = {};
    
    for (final legendPath in cachedItems) {
      // 提取目录路径
      String directory = '';
      final lastSlashIndex = legendPath.lastIndexOf('/');
      if (lastSlashIndex != -1) {
        directory = legendPath.substring(0, lastSlashIndex);
      }
      
      // 如果目录为空，使用"根目录"
      final displayDirectory = directory.isEmpty ? '根目录' : directory;
      
      if (!grouped.containsKey(displayDirectory)) {
        grouped[displayDirectory] = [];
      }
      grouped[displayDirectory]!.add(legendPath);
    }
    
    setState(() {
      _groupedLegends = grouped;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_groupedLegends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暂无缓存图例',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '选择VFS目录来加载图例到缓存',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _groupedLegends.keys.length,
      itemBuilder: (context, index) {
        final directory = _groupedLegends.keys.elementAt(index);
        final legends = _groupedLegends[directory]!;
        
        return _buildDirectorySection(directory, legends);
      },
    );
  }

  /// 构建目录段落
  Widget _buildDirectorySection(String directory, List<String> legends) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        title: Text(
          directory,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${legends.length} 个图例',
          style: const TextStyle(fontSize: 11),
        ),
        leading: const Icon(Icons.folder, size: 20),
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 每行4个图例
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
  }

  /// 构建单个图例瓦片
  Widget _buildLegendTile(String legendPath) {
    return FutureBuilder<legend_db.LegendItem?>(
      future: _cacheManager.getLegendData(legendPath),
      builder: (context, snapshot) {
        final legend = snapshot.data;
        
        return InkWell(
          onTap: () => widget.onLegendSelected?.call(legendPath),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图例预览图标 (小正方形)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: legend?.hasImageData == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Image.memory(
                            legend!.imageData!,
                            fit: BoxFit.cover,
                            width: 22,
                            height: 22,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                size: 12,
                                color: Colors.grey.shade600,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.legend_toggle,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                ),
                const SizedBox(height: 4),
                // 图例标题
                Text(
                  legend?.title ?? _extractLegendName(legendPath),
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 从路径中提取图例名称
  String _extractLegendName(String legendPath) {
    final fileName = legendPath.split('/').last;
    return fileName.replaceAll('.legend', '');
  }
}
