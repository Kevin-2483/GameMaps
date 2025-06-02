import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/web_database_importer.dart';

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
  @override
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
                        '导入说明',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '从JSON文件导入地图、传奇和本地化数据。支持导入R6Box导出的文件或兼容格式的数据文件。',
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
                            _selectedFilePath ?? '请选择JSON文件',
                            style: TextStyle(
                              color: _selectedFilePath != null 
                                ? theme.textTheme.bodyMedium?.color 
                                : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
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
          
          // 文件预览
          if (_preview != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文件预览',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildPreviewItem(
                      icon: Icons.map,
                      title: '地图数据',
                      count: _preview!.mapCount,
                      available: _preview!.hasMaps,
                    ),
                    
                    _buildPreviewItem(
                      icon: Icons.legend_toggle,
                      title: '传奇数据',
                      count: _preview!.legendCount,
                      available: _preview!.hasLegends,
                    ),
                    
                    _buildPreviewItem(
                      icon: Icons.language,
                      title: '本地化数据',
                      count: _preview!.localizationCount,
                      available: _preview!.hasLocalizations,
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // 导入选项
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
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '警告：导入操作将替换现有数据，建议先备份当前数据。',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // 导入按钮
          if (_preview != null && _preview!.hasAnyData) ...[
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
                label: Text(_isImporting ? '正在导入...' : '导入数据库'),
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

  Widget _buildPreviewItem({
    required IconData icon,
    required String title,
    required int count,
    required bool available,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: available ? theme.colorScheme.primary : theme.disabledColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: available ? null : theme.disabledColor,
              ),
            ),
          ),
          Text(
            available ? '$count 项' : '无数据',
            style: TextStyle(
              color: available ? theme.colorScheme.primary : theme.disabledColor,
              fontWeight: FontWeight.w500,
            ),
          ),
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
      final jsonData = jsonDecode(content) as Map<String, dynamic>;

      setState(() {
        _fileContent = jsonData;
        _preview = ImportPreview.fromJson(jsonData);
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _preview = null;
        _fileContent = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('文件分析失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importDatabase() async {
    if (!_canImport() || _fileContent == null) return;

    setState(() {
      _isImporting = true;
    });    try {
      await WebDatabaseImporter.importFromJson(_fileContent!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('数据库导入成功'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 清除状态
        setState(() {
          _selectedFilePath = null;
          _fileContent = null;
          _preview = null;
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
