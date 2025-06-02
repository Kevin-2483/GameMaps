import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/map_database_service.dart';
import '../../services/legend_database_service.dart'; 
import '../../models/map_item.dart';
import '../../models/legend_item.dart';

/// 外部资源浏览面板
class ExternalResourcesBrowsePanel extends StatefulWidget {
  const ExternalResourcesBrowsePanel({super.key});

  @override
  State<ExternalResourcesBrowsePanel> createState() => _ExternalResourcesBrowsePanelState();
}

class _ExternalResourcesBrowsePanelState extends State<ExternalResourcesBrowsePanel>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<MapItem> _maps = [];
  List<LegendItem> _legends = [];
  List<String> _localizationLocales = [];
  // 服务实例
  final MapDatabaseService _mapService = MapDatabaseService();
  final LegendDatabaseService _legendService = LegendDatabaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // 工具栏
        Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.storage, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '数据库浏览',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isLoading ? null : _loadData,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                  tooltip: '刷新数据',
                ),
              ],
            ),
          ),
        ),

        // 标签页
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.map),
                      text: '地图 (${_maps.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.legend_toggle),
                      text: '传奇 (${_legends.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.language),
                      text: '本地化 (${_localizationLocales.length})',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMapsTab(),
                      _buildLegendsTab(),
                      _buildLocalizationsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildMapsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_maps.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无地图数据'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _maps.length,
      itemBuilder: (context, index) {
        final map = _maps[index];
        return _buildMapCard(map);
      },
    );
  }
  Widget _buildMapCard(MapItem map) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.map),
        title: Text(map.title),
        subtitle: Text('ID: ${map.id}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('标题', map.title),
                _buildInfoRow('ID', map.id?.toString() ?? '未知'),
                _buildInfoRow('版本', map.version.toString()),
                _buildInfoRow('图层数量', map.layers.length.toString()),
                _buildInfoRow('图例组数量', map.legendGroups.length.toString()),
                _buildInfoRow('创建时间', _formatDateTime(map.createdAt)),
                _buildInfoRow('更新时间', _formatDateTime(map.updatedAt)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _copyToClipboard(map.id?.toString() ?? ''),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('复制ID'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLegendsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_legends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.legend_toggle_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无传奇数据'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _legends.length,
      itemBuilder: (context, index) {
        final legend = _legends[index];
        return _buildLegendCard(legend);
      },
    );
  }

  Widget _buildLegendCard(LegendItem legend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.legend_toggle),
        title: Text(legend.title),
        subtitle: Text('ID: ${legend.id}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('标题', legend.title),
                _buildInfoRow('ID', legend.id?.toString() ?? '未知'),
                _buildInfoRow('中心点', '(${legend.centerX.toStringAsFixed(3)}, ${legend.centerY.toStringAsFixed(3)})'),
                _buildInfoRow('版本', legend.version.toString()),
                _buildInfoRow('创建时间', _formatDateTime(legend.createdAt)),
                _buildInfoRow('更新时间', _formatDateTime(legend.updatedAt)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _copyToClipboard(legend.id?.toString() ?? ''),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('复制ID'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLocalizationsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_localizationLocales.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无本地化数据'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _localizationLocales.length,
      itemBuilder: (context, index) {
        final locale = _localizationLocales[index];
        return _buildLocalizationCard(locale);
      },
    );
  }

  Widget _buildLocalizationCard(String locale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.language),
        title: Text('语言: $locale'),
        subtitle: const Text('本地化数据'),
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '语言代码: $locale',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () => _copyToClipboard(locale),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('复制语言代码'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('包含地图和界面本地化数据'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未知';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 加载地图数据
      _maps = await _mapService.getAllMaps();
      
      // 加载传奇数据
      _legends = await _legendService.getAllLegends();
      
      // 加载本地化数据 - 暂时使用硬编码的示例
      _localizationLocales = ['zh-CN', 'en-US', 'ja-JP'];

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载数据失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已复制到剪贴板: $text'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
