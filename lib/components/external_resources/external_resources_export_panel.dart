import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/combined_database_exporter.dart';

/// 外部资源导出面板
class ExternalResourcesExportPanel extends StatefulWidget {
  const ExternalResourcesExportPanel({super.key});

  @override
  State<ExternalResourcesExportPanel> createState() => _ExternalResourcesExportPanelState();
}

class _ExternalResourcesExportPanelState extends State<ExternalResourcesExportPanel> {
  bool _isExporting = false;
  bool _includeMaps = true;
  bool _includeLegends = true;
  bool _includeLocalizations = true;
  String? _exportPath;
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
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '导出说明',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '将当前应用中的地图、传奇和本地化数据导出为JSON文件，可以用于备份或分享给其他用户。',
                  ),
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
                  Text(
                    '导出内容',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  CheckboxListTile(
                    title: const Text('地图数据'),
                    subtitle: const Text('包含所有地图信息和配置'),
                    value: _includeMaps,
                    onChanged: (value) {
                      setState(() {
                        _includeMaps = value ?? true;
                      });
                    },
                  ),
                  
                  CheckboxListTile(
                    title: const Text('传奇数据'),
                    subtitle: const Text('包含所有传奇项目和分类'),
                    value: _includeLegends,
                    onChanged: (value) {
                      setState(() {
                        _includeLegends = value ?? true;
                      });
                    },
                  ),
                  
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
                  Text(
                    '导出位置',
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
                            _exportPath ?? '请选择导出位置',
                            style: TextStyle(
                              color: _exportPath != null 
                                ? theme.textTheme.bodyMedium?.color 
                                : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
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
    return !_isExporting && 
           _exportPath != null && 
           (_includeMaps || _includeLegends || _includeLocalizations);
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
    });    try {
      final exporter = CombinedDatabaseExporter();
      
      final exportPath = await exporter.exportAllDatabases(
        includeLocalizations: _includeLocalizations,
      );

      if (exportPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('数据库导出成功: $exportPath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: '确定',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '确定',
              onPressed: () {},
            ),
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
