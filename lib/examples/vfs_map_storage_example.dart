import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/vfs_map_storage/vfs_map_service_factory.dart';
import '../services/map_database_service.dart';
import '../models/map_item.dart';

/// VFS地图存储使用示例
/// 演示如何从传统SQLite存储迁移到VFS存储
class VfsMapStorageExample extends StatefulWidget {
  const VfsMapStorageExample({Key? key}) : super(key: key);

  @override
  State<VfsMapStorageExample> createState() => _VfsMapStorageExampleState();
}

class _VfsMapStorageExampleState extends State<VfsMapStorageExample> {
  late MapDatabaseService _mapService;
  List<MapItem> _maps = [];
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    // 使用工厂创建地图服务（自动选择VFS或传统实现）
    _mapService = VfsMapServiceFactory.createMapDatabaseService();
    _loadMaps();
  }

  /// 加载地图列表
  Future<void> _loadMaps() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在加载地图...';
    });

    try {
      final maps = await _mapService.getAllMaps();
      setState(() {
        _maps = maps;
        _statusMessage = '成功加载 ${maps.length} 个地图';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '加载地图失败: $e';
        _isLoading = false;
      });
    }
  }

  /// 创建示例地图
  Future<void> _createSampleMap() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在创建示例地图...';
    });

    try {
      final sampleMap = MapItem(
        title: 'VFS示例地图 ${DateTime.now().millisecondsSinceEpoch}',
        imageData: _generateSampleImageData(),
        version: 1,
        layers: [], // 可以添加示例图层
        legendGroups: [], // 可以添加示例图例组
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mapId = await _mapService.insertMap(sampleMap);

      setState(() {
        _statusMessage = '成功创建示例地图 (ID: $mapId)';
        _isLoading = false;
      });

      // 重新加载地图列表
      await _loadMaps();
    } catch (e) {
      setState(() {
        _statusMessage = '创建示例地图失败: $e';
        _isLoading = false;
      });
    }
  }

  /// 删除地图
  Future<void> _deleteMap(MapItem map) async {
    if (map.id == null) return;

    final confirmed = await _showConfirmDialog('确认删除地图 "${map.title}"？');
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '正在删除地图...';
    });

    try {
      await _mapService.deleteMap(map.id!);

      setState(() {
        _statusMessage = '成功删除地图 "${map.title}"';
        _isLoading = false;
      });

      // 重新加载地图列表
      await _loadMaps();
    } catch (e) {
      setState(() {
        _statusMessage = '删除地图失败: $e';
        _isLoading = false;
      });
    }
  }

  /// 显示确认对话框
  Future<bool> _showConfirmDialog(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认操作'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 生成示例图像数据
  Uint8List _generateSampleImageData() {
    // 简单的占位图像数据
    return Uint8List.fromList(List.generate(100, (index) => index % 256));
  }

  /// 导出地图数据
  Future<void> _exportMaps() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在导出地图数据...';
    });

    try {
      final exportPath = await _mapService.exportDatabase();

      setState(() {
        _statusMessage = exportPath != null
            ? '成功导出地图数据到: $exportPath'
            : '导出操作被取消';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '导出地图数据失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VFS地图存储示例${VfsMapServiceFactory.isUsingVfsStorage ? ' (VFS模式)' : ' (传统模式)'}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMaps,
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportMaps,
            tooltip: '导出',
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态栏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '存储模式: ${VfsMapServiceFactory.isUsingVfsStorage ? 'VFS虚拟文件系统' : '传统SQLite数据库'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('状态: $_statusMessage'),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),

          // 地图列表
          Expanded(
            child: _maps.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('暂无地图数据', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _maps.length,
                    itemBuilder: (context, index) {
                      final map = _maps[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.map, color: Colors.blue),
                          ),
                          title: Text(map.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('版本: ${map.version}'),
                              Text(
                                '图层: ${map.layers.length} | 图例组: ${map.legendGroups.length}',
                              ),
                              Text('创建时间: ${_formatDateTime(map.createdAt)}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'delete':
                                  _deleteMap(map);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: Text('删除'),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // 可以添加地图详情页面导航
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('查看地图: ${map.title}')),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createSampleMap,
        tooltip: '创建示例地图',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _mapService.close();
    super.dispose();
  }
}
