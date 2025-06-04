import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/combined_database_exporter.dart';
import '../../models/map_item_summary.dart';
import '../../models/legend_item.dart';

/// 外部资源导出面板
class ExternalResourcesExportPanel extends StatefulWidget {
  const ExternalResourcesExportPanel({super.key});

  @override
  State<ExternalResourcesExportPanel> createState() =>
      _ExternalResourcesExportPanelState();
}

class _ExternalResourcesExportPanelState
    extends State<ExternalResourcesExportPanel> {
  bool _isExporting = false;
  bool _includeMaps = true;
  bool _includeLegends = true;
  bool _includeLocalizations = true;
  bool _enableSelectiveMaps = false;
  bool _enableSelectiveLegends = false;
  String? _exportPath;

  List<MapItemSummary> _availableMaps = [];
  List<LegendItem> _availableLegends = [];
  Set<int> _selectedMapIds = {};
  Set<int> _selectedLegendIds = {};
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableData();
  }

  Future<void> _loadAvailableData() async {
    setState(() => _isLoadingData = true);
    try {
      final exporter = CombinedDatabaseExporter();
      final maps = await exporter.getAvailableMaps();
      final legends = await exporter.getAvailableLegends();

      setState(() {
        _availableMaps = maps;
        _availableLegends = legends;
        _selectedMapIds = maps.map((m) => m.id).toSet();
        _selectedLegendIds = legends.map((l) => l.id!).toSet();
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载数据失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 导出说明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text('导出说明', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('将当前应用中的地图、传奇和本地化数据导出为JSON文件，可以用于备份或分享给其他用户。'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 导出选项
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('导出内容', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('地图数据'),
                    subtitle: _isLoadingData
                        ? const Text('加载中...')
                        : Text('包含${_availableMaps.length}个地图'),
                    value: _includeMaps,
                    onChanged: (value) {
                      setState(() {
                        _includeMaps = value ?? true;
                      });
                    },
                  ),

                  if (_includeMaps && !_isLoadingData) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 56.0, right: 16.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _enableSelectiveMaps,
                            onChanged: (value) {
                              setState(() {
                                _enableSelectiveMaps = value ?? false;
                                if (!_enableSelectiveMaps) {
                                  _selectedMapIds = _availableMaps
                                      .map((m) => m.id)
                                      .toSet();
                                }
                              });
                            },
                          ),
                          const Text('选择特定地图'),
                          const Spacer(),
                          if (_enableSelectiveMaps)
                            Text(
                              '已选择 ${_selectedMapIds.length}/${_availableMaps.length}',
                            ),
                        ],
                      ),
                    ),
                    if (_enableSelectiveMaps)
                      Container(
                        margin: const EdgeInsets.only(
                          left: 56.0,
                          right: 16.0,
                          bottom: 8.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedMapIds = _availableMaps
                                      .map((m) => m.id)
                                      .toSet();
                                });
                              },
                              child: const Text('全选'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedMapIds.clear();
                                });
                              },
                              child: const Text('全不选'),
                            ),
                          ],
                        ),
                      ),

                    if (_enableSelectiveMaps)
                      Container(
                        margin: const EdgeInsets.only(left: 56.0, right: 16.0),
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          itemCount: _availableMaps.length,
                          itemBuilder: (context, index) {
                            final map = _availableMaps[index];
                            return CheckboxListTile(
                              dense: true,
                              title: Text(map.title),
                              subtitle: Text('ID: ${map.id}'),
                              value: _selectedMapIds.contains(map.id),
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedMapIds.add(map.id);
                                  } else {
                                    _selectedMapIds.remove(map.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                  ],
                  CheckboxListTile(
                    title: const Text('传奇数据'),
                    subtitle: _isLoadingData
                        ? const Text('加载中...')
                        : Text('包含${_availableLegends.length}个传奇'),
                    value: _includeLegends,
                    onChanged: (value) {
                      setState(() {
                        _includeLegends = value ?? true;
                      });
                    },
                  ),

                  if (_includeLegends && !_isLoadingData) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 56.0, right: 16.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _enableSelectiveLegends,
                            onChanged: (value) {
                              setState(() {
                                _enableSelectiveLegends = value ?? false;
                                if (!_enableSelectiveLegends) {
                                  _selectedLegendIds = _availableLegends
                                      .where((l) => l.id != null)
                                      .map((l) => l.id!)
                                      .toSet();
                                }
                              });
                            },
                          ),
                          const Text('选择特定传奇'),
                          const Spacer(),
                          if (_enableSelectiveLegends)
                            Text(
                              '已选择 ${_selectedLegendIds.length}/${_availableLegends.length}',
                            ),
                        ],
                      ),
                    ),
                    if (_enableSelectiveLegends)
                      Container(
                        margin: const EdgeInsets.only(
                          left: 56.0,
                          right: 16.0,
                          bottom: 8.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLegendIds = _availableLegends
                                      .where((l) => l.id != null)
                                      .map((l) => l.id!)
                                      .toSet();
                                });
                              },
                              child: const Text('全选'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLegendIds.clear();
                                });
                              },
                              child: const Text('全不选'),
                            ),
                          ],
                        ),
                      ),

                    if (_enableSelectiveLegends)
                      Container(
                        margin: const EdgeInsets.only(left: 56.0, right: 16.0),
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          itemCount: _availableLegends.length,
                          itemBuilder: (context, index) {
                            final legend = _availableLegends[index];
                            if (legend.id == null)
                              return const SizedBox.shrink();
                            return CheckboxListTile(
                              dense: true,
                              title: Text(legend.title),
                              subtitle: Text('ID: ${legend.id}'),
                              value: _selectedLegendIds.contains(legend.id!),
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedLegendIds.add(legend.id!);
                                  } else {
                                    _selectedLegendIds.remove(legend.id!);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                  ],

                  CheckboxListTile(
                    title: const Text('本地化数据'),
                    subtitle: const Text('包含多语言翻译数据'),
                    value: _includeLocalizations,
                    onChanged: (value) {
                      setState(() {
                        _includeLocalizations = value ?? true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 导出路径选择
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('导出位置', style: theme.textTheme.titleMedium),
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
                            _exportPath ?? '请选择导出位置',
                            style: TextStyle(
                              color: _exportPath != null
                                  ? theme.textTheme.bodyMedium?.color
                                  : theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _selectExportPath,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('选择'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 导出按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _canExport() ? _exportDatabase : null,
              icon: _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_upload),
              label: Text(_isExporting ? '正在导出...' : '导出数据库'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canExport() {
    if (_isExporting || _exportPath == null) return false;

    bool hasValidContent = false;

    if (_includeMaps) {
      if (_enableSelectiveMaps) {
        hasValidContent |= _selectedMapIds.isNotEmpty;
      } else {
        hasValidContent |= _availableMaps.isNotEmpty;
      }
    }

    if (_includeLegends) {
      if (_enableSelectiveLegends) {
        hasValidContent |= _selectedLegendIds.isNotEmpty;
      } else {
        hasValidContent |= _availableLegends.isNotEmpty;
      }
    }

    if (_includeLocalizations) {
      hasValidContent = true;
    }

    return hasValidContent;
  }

  Future<void> _selectExportPath() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _exportPath = result;
      });
    }
  }

  Future<void> _exportDatabase() async {
    if (!_canExport()) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final exporter = CombinedDatabaseExporter();

      // 准备导出参数
      List<int>? selectedMapIds;
      List<int>? selectedLegendIds;

      if (_includeMaps && _enableSelectiveMaps) {
        selectedMapIds = _selectedMapIds.toList();
      }

      if (_includeLegends && _enableSelectiveLegends) {
        selectedLegendIds = _selectedLegendIds.toList();
      }

      final exportPath = await exporter.exportAllDatabases(
        includeMaps: _includeMaps,
        includeLegends: _includeLegends,
        includeLocalizations: _includeLocalizations,
        selectedMapIds: selectedMapIds,
        selectedLegendIds: selectedLegendIds,
      );

      if (exportPath != null && mounted) {
        String message = '数据库导出成功: $exportPath';

        // 添加导出统计信息
        List<String> stats = [];
        if (_includeMaps) {
          int mapCount = _enableSelectiveMaps
              ? _selectedMapIds.length
              : _availableMaps.length;
          stats.add('地图: $mapCount');
        }
        if (_includeLegends) {
          int legendCount = _enableSelectiveLegends
              ? _selectedLegendIds.length
              : _availableLegends.length;
          stats.add('传奇: $legendCount');
        }
        if (_includeLocalizations) {
          stats.add('本地化数据');
        }

        if (stats.isNotEmpty) {
          message += '\n导出内容: ${stats.join(', ')}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(label: '确定', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(label: '确定', onPressed: () {}),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
