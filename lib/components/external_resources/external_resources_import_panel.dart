import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/map_database_service.dart';
import '../../services/legend_database_service.dart';
import '../../models/map_item.dart';
import '../../models/map_layer.dart';
import '../../models/legend_item.dart' as legend_db;

/// 外部资源导入面板
class ExternalResourcesImportPanel extends StatefulWidget {
  const ExternalResourcesImportPanel({super.key});

  @override
  State<ExternalResourcesImportPanel> createState() => _ExternalResourcesImportPanelState();
}

class _ExternalResourcesImportPanelState extends State<ExternalResourcesImportPanel> {
  bool _isImporting = false;
  bool _isAnalyzing = false;
  String? _selectedFilePath;
  Map<String, dynamic>? _fileContent;
  ImportPreview? _preview;
  
  // 选择性导入设置
  bool _importMaps = true;
  bool _importLegends = true;
  bool _importLocalizations = true;
  
  // 详细数据
  List<ImportMapItem> _importMapItems = [];
  List<ImportLegendItem> _importLegendItems = [];
  Set<String> _selectedMapIds = {};
  Set<String> _selectedLegendIds = {};
  
  // 数据库服务
  final MapDatabaseService _mapService = MapDatabaseService();
  final LegendDatabaseService _legendService = LegendDatabaseService();  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 导入说明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '选择性导入',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '从JSON文件选择性导入地图、传奇和本地化数据。支持版本比较、冲突处理和重命名导入。',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 文件选择
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择文件',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedFilePath ?? '请选择JSON文件',                            style: TextStyle(
                              color: _selectedFilePath != null 
                                ? theme.textTheme.bodyMedium?.color 
                                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _selectFile,
                        icon: _isAnalyzing 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_open),
                        label: Text(_isAnalyzing ? '分析中...' : '选择文件'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 导入类型选择
          if (_preview != null && _preview!.hasAnyData) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '导入选项',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    CheckboxListTile(
                      title: Text('地图数据 (${_preview!.mapCount} 项)'),
                      subtitle: const Text('导入地图文件和图层数据'),
                      value: _importMaps && _preview!.hasMaps,
                      onChanged: _preview!.hasMaps ? (value) {
                        setState(() {
                          _importMaps = value ?? false;
                        });
                      } : null,
                    ),
                    
                    CheckboxListTile(
                      title: Text('传奇数据 (${_preview!.legendCount} 项)'),
                      subtitle: const Text('导入图例库数据'),
                      value: _importLegends && _preview!.hasLegends,
                      onChanged: _preview!.hasLegends ? (value) {
                        setState(() {
                          _importLegends = value ?? false;
                        });
                      } : null,
                    ),
                    
                    CheckboxListTile(
                      title: Text('本地化数据 (${_preview!.localizationCount} 项)'),
                      subtitle: const Text('导入多语言翻译数据'),
                      value: _importLocalizations && _preview!.hasLocalizations,
                      onChanged: _preview!.hasLocalizations ? (value) {
                        setState(() {
                          _importLocalizations = value ?? false;
                        });
                      } : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
            // 详细列表预览
          if (_preview != null && _importMaps && _importMapItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '地图数据详情',
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text('已选择 ${_selectedMapIds.length}/${_importMapItems.length}'),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_selectedMapIds.length == _importMapItems.length) {
                                _selectedMapIds.clear();
                              } else {
                                _selectedMapIds = _importMapItems.map((e) => e.id).toSet();
                              }
                            });
                          },
                          child: Text(_selectedMapIds.length == _importMapItems.length ? '全不选' : '全选'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        itemCount: _importMapItems.length,
                        itemBuilder: (context, index) {
                          return _buildMapItemTile(_importMapItems[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          if (_preview != null && _importLegends && _importLegendItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '传奇数据详情',
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text('已选择 ${_selectedLegendIds.length}/${_importLegendItems.length}'),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_selectedLegendIds.length == _importLegendItems.length) {
                                _selectedLegendIds.clear();
                              } else {
                                _selectedLegendIds = _importLegendItems.map((e) => e.id).toSet();
                              }
                            });
                          },
                          child: Text(_selectedLegendIds.length == _importLegendItems.length ? '全不选' : '全选'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        itemCount: _importLegendItems.length,
                        itemBuilder: (context, index) {
                          return _buildLegendItemTile(_importLegendItems[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // 导入按钮
          if (_preview != null && _canImport()) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canImport() ? _importDatabase : null,
                icon: _isImporting 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_download),
                label: Text(_isImporting ? '正在导入...' : '开始导入'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  bool _canImport() {
    return !_isImporting && 
           _preview != null && 
           _preview!.hasAnyData;
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path!;
        _isAnalyzing = true;
        _preview = null;
      });

      await _analyzeFile(_selectedFilePath!);
    }
  }
  Future<void> _analyzeFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final jsonData = jsonDecode(content) as Map<String, dynamic>;      // 创建详细的导入项目列表
      await _createDetailedImportItems(jsonData);

      setState(() {
        _fileContent = jsonData;
        _preview = ImportPreview.fromJson(jsonData);
        _isAnalyzing = false;
      });
      
      // 调试信息
      print('分析完成:');
      print('  地图项目数量: ${_importMapItems.length}');
      print('  图例项目数量: ${_importLegendItems.length}');
      print('  _importMaps: $_importMaps');
      print('  _importLegends: $_importLegends');
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _preview = null;
        _fileContent = null;
        _importMapItems.clear();
        _importLegendItems.clear();
        _selectedMapIds.clear();
        _selectedLegendIds.clear();
      });      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('文件分析失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _createDetailedImportItems(Map<String, dynamic> jsonData) async {
    final List<ImportMapItem> mapItems = [];
    final List<ImportLegendItem> legendItems = [];
    
    // 处理地图数据 - 支持嵌套格式
    if (jsonData.containsKey('maps')) {
      final mapsData = jsonData['maps'];
      List<dynamic>? maps;
      
      if (mapsData is List) {
        // 直接的数组格式
        maps = mapsData;
      } else if (mapsData is Map<String, dynamic> && mapsData.containsKey('data')) {
        // 嵌套格式：maps.data
        maps = mapsData['data'] as List<dynamic>?;
      }
      
      if (maps != null) {
        for (final mapData in maps) {
          if (mapData is Map<String, dynamic>) {
            final mapItem = await _createMapItem(mapData);
            if (mapItem != null) {
              mapItems.add(mapItem);
            }
          }
        }
      }
    }
    
    // 处理图例数据 - 支持嵌套格式
    if (jsonData.containsKey('legends')) {
      final legendsData = jsonData['legends'];
      List<dynamic>? legends;
      
      if (legendsData is List) {
        // 直接的数组格式
        legends = legendsData;
      } else if (legendsData is Map<String, dynamic> && legendsData.containsKey('data')) {
        // 嵌套格式：legends.data
        legends = legendsData['data'] as List<dynamic>?;
      }
      
      if (legends != null) {
        for (final legendData in legends) {
          if (legendData is Map<String, dynamic>) {
            final legendItem = await _createLegendItem(legendData);
            if (legendItem != null) {
              legendItems.add(legendItem);
            }
          }
        }
      }
    }    setState(() {
      _importMapItems = mapItems;
      _importLegendItems = legendItems;
      
      // 默认全选
      _selectedMapIds = Set.from(mapItems.map((item) => item.id));
      _selectedLegendIds = Set.from(legendItems.map((item) => item.id));
    });
    
    // 调试信息
    print('创建详细导入项目:');
    print('  创建的地图项目: ${mapItems.length}');
    print('  创建的图例项目: ${legendItems.length}');
    for (final item in mapItems) {
      print('    地图: ${item.title} (${item.conflictStatus})');
    }
    for (final item in legendItems) {
      print('    图例: ${item.title} (${item.conflictStatus})');
    }
  }
  Future<ImportMapItem?> _createMapItem(Map<String, dynamic> mapData) async {
    try {
      final String? title = mapData['title'] as String?;
      final dynamic versionData = mapData['version'];
      final String? description = mapData['description'] as String?;
      
      if (title == null) return null;
      
      // 处理版本数据：可能是String或int
      final int importVersion = _parseVersionToInt(versionData);
      
      // 检查本地是否存在同名地图
      final existingMaps = await _mapService.getAllMaps();
      final existingMap = existingMaps.where((m) => m.title == title).firstOrNull;
      
      ConflictStatus conflictStatus = ConflictStatus.noConflict;
      int? existingVersion;
      
      if (existingMap != null) {
        existingVersion = existingMap.version;
        
        if (existingVersion == importVersion) {
          conflictStatus = ConflictStatus.sameVersion;
        } else if (importVersion > existingVersion) {
          conflictStatus = ConflictStatus.newerVersion;
        } else {
          conflictStatus = ConflictStatus.olderVersion;
        }
      }
      
      return ImportMapItem(
        id: title, // 使用title作为ID
        title: title,
        version: importVersion,
        description: description ?? '',
        conflictStatus: conflictStatus,
        existingVersion: existingVersion,
        mapData: mapData,
        isSelected: true,
        importAction: ImportAction.replace,
      );
    } catch (e) {
      print('Error creating map item: $e');
      return null;
    }
  }
  Future<ImportLegendItem?> _createLegendItem(Map<String, dynamic> legendData) async {
    try {
      final String? title = legendData['title'] as String?;
      final dynamic versionData = legendData['version'];
      final String? description = legendData['description'] as String?;
      
      if (title == null) return null;
      
      // 处理版本数据：可能是String或int
      final int importVersion = _parseVersionToInt(versionData);
      
      // 检查本地是否存在同名图例
      final existingLegends = await _legendService.getAllLegends();
      final existingLegend = existingLegends.where((l) => l.title == title).firstOrNull;
      
      ConflictStatus conflictStatus = ConflictStatus.noConflict;
      int? existingVersion;
      
      if (existingLegend != null) {
        existingVersion = existingLegend.version;
        
        if (existingVersion == importVersion) {
          conflictStatus = ConflictStatus.sameVersion;
        } else if (importVersion > existingVersion) {
          conflictStatus = ConflictStatus.newerVersion;
        } else {
          conflictStatus = ConflictStatus.olderVersion;
        }
      }
      
      return ImportLegendItem(
        id: title, // 使用title作为ID
        title: title,
        version: importVersion,
        description: description ?? '',
        conflictStatus: conflictStatus,
        existingVersion: existingVersion,
        legendData: legendData,
        isSelected: true,
        importAction: ImportAction.replace,
      );
    } catch (e) {
      print('Error creating legend item: $e');
      return null;    }
  }

  /// 将版本数据解析为int类型
  int _parseVersionToInt(dynamic versionData) {
    if (versionData is int) {
      return versionData;
    } else if (versionData is String) {
      return int.tryParse(versionData) ?? 1;
    } else {
      return 1; // 默认版本
    }
  }

  Widget _buildMapItemTile(ImportMapItem item) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: _selectedMapIds.contains(item.id),
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              _selectedMapIds.add(item.id);
            } else {
              _selectedMapIds.remove(item.id);
            }
          });
        },
        title: Text(item.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: ${item.version}'),
            if (item.description.isNotEmpty)
              Text(item.description, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            _buildConflictStatus(item.conflictStatus, item.existingVersion),
          ],
        ),        secondary: _buildActionButton(item.conflictStatus, isMap: true, itemId: item.id),
      ),
    );
  }

  Widget _buildLegendItemTile(ImportLegendItem item) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: _selectedLegendIds.contains(item.id),
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              _selectedLegendIds.add(item.id);
            } else {
              _selectedLegendIds.remove(item.id);
            }
          });
        },
        title: Text(item.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: ${item.version}'),
            if (item.description.isNotEmpty)
              Text(item.description, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            _buildConflictStatus(item.conflictStatus, item.existingVersion),
          ],
        ),
        secondary: _buildActionButton(item.conflictStatus, isMap: false, itemId: item.id),
      ),
    );
  }
  Widget _buildConflictStatus(ConflictStatus status, int? existingVersion) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case ConflictStatus.noConflict:
        color = Colors.green;
        text = '新项目';
        icon = Icons.fiber_new;
        break;
      case ConflictStatus.sameVersion:
        color = Colors.blue;
        text = '相同版本 (v$existingVersion)';
        icon = Icons.sync;
        break;
      case ConflictStatus.newerVersion:
        color = Colors.orange;
        text = '更新版本 (本地: v$existingVersion)';
        icon = Icons.upgrade;
        break;
      case ConflictStatus.olderVersion:
        color = Colors.red;
        text = '较旧版本 (本地: v$existingVersion)';
        icon = Icons.warning;
        break;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  Widget _buildActionButton(ConflictStatus status, {required bool isMap, required String itemId}) {
    if (status == ConflictStatus.noConflict) {
      return const Icon(Icons.add, color: Colors.green);
    }
    
    return PopupMenuButton<ImportAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        _handleImportAction(action, isMap: isMap, itemId: itemId);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: ImportAction.replace,
          child: Row(
            children: [
              Icon(Icons.swap_horiz),
              SizedBox(width: 8),
              Text('替换'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: ImportAction.skip,
          child: Row(
            children: [
              Icon(Icons.skip_next),
              SizedBox(width: 8),
              Text('跳过'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: ImportAction.rename,
          child: Row(
            children: [
              Icon(Icons.drive_file_rename_outline),
              SizedBox(width: 8),
              Text('重命名导入'),
            ],
          ),
        ),
      ],
    );
  }
  Future<void> _importDatabase() async {
    if (!_canImport() || _fileContent == null) return;

    setState(() {
      _isImporting = true;
    });

    try {
      int importedCount = 0;
      
      // 导入选中的地图数据
      if (_importMaps && _selectedMapIds.isNotEmpty) {
        for (final mapItem in _importMapItems) {
          if (_selectedMapIds.contains(mapItem.id) && mapItem.importAction != ImportAction.skip) {
            await _importSingleMap(mapItem);
            importedCount++;
          }
        }
      }
      
      // 导入选中的图例数据
      if (_importLegends && _selectedLegendIds.isNotEmpty) {
        for (final legendItem in _importLegendItems) {
          if (_selectedLegendIds.contains(legendItem.id) && legendItem.importAction != ImportAction.skip) {
            await _importSingleLegend(legendItem);
            importedCount++;
          }
        }
      }
      
      // 导入本地化数据（如果选择）
      if (_importLocalizations && _fileContent!.containsKey('localizations')) {
        // TODO: 实现本地化数据导入
        // await _importLocalizations(_fileContent!['localizations']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入完成，共导入 $importedCount 个项目'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 清除状态
        setState(() {
          _selectedFilePath = null;
          _fileContent = null;
          _preview = null;
          _importMapItems.clear();
          _importLegendItems.clear();
          _selectedMapIds.clear();
          _selectedLegendIds.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  /// 导入单个地图项
  Future<void> _importSingleMap(ImportMapItem mapItem) async {
    try {
      // 如果有冲突且选择替换，先删除现有项目
      if (mapItem.conflictStatus != ConflictStatus.noConflict && 
          mapItem.importAction == ImportAction.replace) {
        final existingMaps = await _mapService.getAllMaps();
        final existingMap = existingMaps.where((m) => m.title == mapItem.title).firstOrNull;
        if (existingMap != null) {
          await _mapService.deleteMap(existingMap.id!);
        }
      }
      
      // 创建地图项
      final mapData = mapItem.mapData;
      
      // 处理图层数据
      final List<MapLayer> layers = [];
      if (mapData.containsKey('layers') && mapData['layers'] is List) {
        for (final layerData in mapData['layers']) {
          if (layerData is Map<String, dynamic>) {
            layers.add(MapLayer.fromJson(layerData));
          }
        }      }
      
      // 处理图例组数据
      final List<LegendGroup> legendGroups = [];
      if (mapData.containsKey('legendGroups') && mapData['legendGroups'] is List) {
        for (final groupData in mapData['legendGroups']) {
          if (groupData is Map<String, dynamic>) {
            legendGroups.add(LegendGroup.fromJson(groupData));
          }
        }
      }
      
      // 处理图像数据
      Uint8List? imageData;
      if (mapData.containsKey('imageData')) {
        final imageDataJson = mapData['imageData'];
        if (imageDataJson is String && imageDataJson.isNotEmpty) {
          try {
            imageData = base64Decode(imageDataJson);
          } catch (e) {
            print('Warning: Failed to decode imageData for map ${mapItem.title}: $e');
          }
        }
      }
      
      final newMap = MapItem(
        title: mapItem.title,
        imageData: imageData,
        version: mapItem.version,
        layers: layers,
        legendGroups: legendGroups,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _mapService.forceInsertMap(newMap);
    } catch (e) {
      print('Error importing map ${mapItem.title}: $e');
      rethrow;
    }
  }

  /// 导入单个图例项
  Future<void> _importSingleLegend(ImportLegendItem legendItem) async {
    try {
      // 如果有冲突且选择替换，先删除现有项目
      if (legendItem.conflictStatus != ConflictStatus.noConflict && 
          legendItem.importAction == ImportAction.replace) {
        final existingLegends = await _legendService.getAllLegends();
        final existingLegend = existingLegends.where((l) => l.title == legendItem.title).firstOrNull;
        if (existingLegend != null) {
          await _legendService.deleteLegend(existingLegend.id!);
        }
      }      // 创建图例项
      final legendData = legendItem.legendData;
      
      final newLegend = legend_db.LegendItem(
        title: legendItem.title,
        imageData: legendData['imageData'] as Uint8List?,
        centerX: (legendData['centerX'] as num?)?.toDouble() ?? 0.5,
        centerY: (legendData['centerY'] as num?)?.toDouble() ?? 0.5,
        version: legendItem.version,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _legendService.forceInsertLegend(newLegend);
    } catch (e) {
      print('Error importing legend ${legendItem.title}: $e');
      rethrow;
    }
  }

  /// 处理导入操作选择
  void _handleImportAction(ImportAction action, {required bool isMap, required String itemId}) {
    setState(() {
      if (isMap) {
        final itemIndex = _importMapItems.indexWhere((item) => item.id == itemId);
        if (itemIndex != -1) {
          final item = _importMapItems[itemIndex];
          if (action == ImportAction.rename) {
            _showRenameDialog(item.title, isMap: true, itemId: itemId);
          } else {
            // 更新操作类型，但保持其他属性不变
            _importMapItems[itemIndex] = ImportMapItem(
              id: item.id,
              title: item.title,
              version: item.version,
              description: item.description,
              conflictStatus: item.conflictStatus,
              existingVersion: item.existingVersion,
              mapData: item.mapData,
              isSelected: item.isSelected,
              importAction: action,
            );
          }
        }
      } else {
        final itemIndex = _importLegendItems.indexWhere((item) => item.id == itemId);
        if (itemIndex != -1) {
          final item = _importLegendItems[itemIndex];
          if (action == ImportAction.rename) {
            _showRenameDialog(item.title, isMap: false, itemId: itemId);
          } else {
            // 更新操作类型，但保持其他属性不变
            _importLegendItems[itemIndex] = ImportLegendItem(
              id: item.id,
              title: item.title,
              version: item.version,
              description: item.description,
              conflictStatus: item.conflictStatus,
              existingVersion: item.existingVersion,
              legendData: item.legendData,
              isSelected: item.isSelected,
              importAction: action,
            );
          }
        }
      }
    });
  }

  /// 显示重命名对话框
  void _showRenameDialog(String originalTitle, {required bool isMap, required String itemId}) {
    final TextEditingController controller = TextEditingController(text: '${originalTitle}_copy');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名导入'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('原名称: $originalTitle'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '新名称',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != originalTitle) {
                _applyRename(newTitle, isMap: isMap, itemId: itemId);
                Navigator.of(context).pop();
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 应用重命名
  void _applyRename(String newTitle, {required bool isMap, required String itemId}) {
    setState(() {
      if (isMap) {
        final itemIndex = _importMapItems.indexWhere((item) => item.id == itemId);
        if (itemIndex != -1) {
          final item = _importMapItems[itemIndex];
          // 创建新的数据副本，更新title
          final newMapData = Map<String, dynamic>.from(item.mapData);
          newMapData['title'] = newTitle;
          
          _importMapItems[itemIndex] = ImportMapItem(
            id: item.id,
            title: newTitle,
            version: item.version,
            description: item.description,
            conflictStatus: ConflictStatus.noConflict, // 重命名后无冲突
            existingVersion: null,
            mapData: newMapData,
            isSelected: item.isSelected,
            importAction: ImportAction.replace,
          );
        }
      } else {
        final itemIndex = _importLegendItems.indexWhere((item) => item.id == itemId);
        if (itemIndex != -1) {
          final item = _importLegendItems[itemIndex];
          // 创建新的数据副本，更新title
          final newLegendData = Map<String, dynamic>.from(item.legendData);
          newLegendData['title'] = newTitle;
          
          _importLegendItems[itemIndex] = ImportLegendItem(
            id: item.id,
            title: newTitle,
            version: item.version,
            description: item.description,
            conflictStatus: ConflictStatus.noConflict, // 重命名后无冲突
            existingVersion: null,
            legendData: newLegendData,
            isSelected: item.isSelected,
            importAction: ImportAction.replace,
          );
        }
      }
    });
  }
}

class ImportPreview {
  final int mapCount;
  final int legendCount;
  final int localizationCount;
  final bool hasMaps;
  final bool hasLegends;
  final bool hasLocalizations;

  ImportPreview({
    required this.mapCount,
    required this.legendCount,
    required this.localizationCount,
    required this.hasMaps,
    required this.hasLegends,
    required this.hasLocalizations,
  });

  bool get hasAnyData => hasMaps || hasLegends || hasLocalizations;
  factory ImportPreview.fromJson(Map<String, dynamic> json) {
    // 处理嵌套的数据结构
    List<dynamic>? maps;
    List<dynamic>? legends;
    Map<String, dynamic>? localizations;

    // 检查maps数据结构
    if (json.containsKey('maps')) {
      final mapsData = json['maps'];
      if (mapsData is List) {
        // 直接的数组格式
        maps = mapsData;
      } else if (mapsData is Map<String, dynamic> && mapsData.containsKey('data')) {
        // 嵌套格式：maps.data
        maps = mapsData['data'] as List<dynamic>?;
      }
    }

    // 检查legends数据结构
    if (json.containsKey('legends')) {
      final legendsData = json['legends'];
      if (legendsData is List) {
        // 直接的数组格式
        legends = legendsData;
      } else if (legendsData is Map<String, dynamic> && legendsData.containsKey('data')) {
        // 嵌套格式：legends.data
        legends = legendsData['data'] as List<dynamic>?;
      }
    }

    // 检查localizations数据结构
    if (json.containsKey('localizations')) {
      final localizationsData = json['localizations'];
      if (localizationsData is Map<String, dynamic>) {
        if (localizationsData.containsKey('maps')) {
          // 嵌套格式：localizations.maps
          final mapsData = localizationsData['maps'];
          if (mapsData is Map<String, dynamic>) {
            localizations = mapsData;
          }
        } else {
          // 直接格式
          localizations = localizationsData;
        }
      }
    }

    return ImportPreview(
      mapCount: maps?.length ?? 0,
      legendCount: legends?.length ?? 0,
      localizationCount: localizations?.keys.length ?? 0,
      hasMaps: maps != null && maps.isNotEmpty,
      hasLegends: legends != null && legends.isNotEmpty,
      hasLocalizations: localizations != null && localizations.isNotEmpty,
    );
  }
}

/// 导入地图项目
class ImportMapItem {
  final String id;
  final String title;
  final int version;
  final String description;
  final ConflictStatus conflictStatus;
  final int? existingVersion;
  final Map<String, dynamic> mapData;
  final bool isSelected;
  final ImportAction importAction;
  
  ImportMapItem({
    required this.id,
    required this.title,
    required this.version,
    required this.description,
    required this.conflictStatus,
    this.existingVersion,
    required this.mapData,
    required this.isSelected,
    required this.importAction,
  });
}

/// 导入图例项目
class ImportLegendItem {
  final String id;
  final String title;
  final int version;
  final String description;
  final ConflictStatus conflictStatus;
  final int? existingVersion;
  final Map<String, dynamic> legendData;
  final bool isSelected;
  final ImportAction importAction;
  
  ImportLegendItem({
    required this.id,
    required this.title,
    required this.version,
    required this.description,
    required this.conflictStatus,
    this.existingVersion,
    required this.legendData,
    required this.isSelected,
    required this.importAction,
  });
}

/// 冲突状态
enum ConflictStatus {
  noConflict,      // 无冲突，新条目
  sameVersion,     // 相同版本
  newerVersion,    // 导入版本更新
  olderVersion,    // 导入版本更旧
}

/// 导入操作类型
enum ImportAction {
  skip,           // 跳过
  replace,        // 替换
  rename,         // 重命名导入
}
