import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import '../../components/layout/main_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../models/map_item.dart';
import '../../services/map_database_service.dart';
import '../../components/common/config_aware_widgets.dart';

class MapAtlasPage extends BasePage {
  const MapAtlasPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return const _MapAtlasContent();
  }
}

class _MapAtlasContent extends StatefulWidget {
  const _MapAtlasContent();

  @override
  State<_MapAtlasContent> createState() => _MapAtlasContentState();
}

class _MapAtlasContentState extends State<_MapAtlasContent> {
  final MapDatabaseService _databaseService = MapDatabaseService();
  List<MapItem> _maps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaps();
  }

  Future<void> _loadMaps() async {
    setState(() => _isLoading = true);    try {
      final maps = await _databaseService.getAllMaps();
      setState(() {
        _maps = maps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.loadMapsFailed(e.toString()));
      }
    }
  }
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _addMap() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final imageBytes = await file.readAsBytes();
      
      // 压缩图片
      final compressedImage = _compressImage(imageBytes);      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final mapInfo = await _showAddMapDialog(l10n);
        if (mapInfo != null && mapInfo['title']?.isNotEmpty == true) {
          try {
            final mapItem = MapItem(
              title: mapInfo['title'],
              imagePath: result.files.single.name,
              imageData: compressedImage,
              version: mapInfo['version'] ?? 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            await _databaseService.insertMap(mapItem);
            await _loadMaps();
            _showSuccessSnackBar(l10n.mapAddedSuccessfully);
          } catch (e) {
            _showErrorSnackBar(l10n.addMapFailed(e.toString()));
          }
        }
      }
    }
  }

  Uint8List _compressImage(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image != null) {
        // 调整图片大小，最大宽度800像素
        final resized = img.copyResize(image, width: 800);
        return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
      }
    } catch (e) {
      debugPrint('图片压缩失败: $e');
    }
    return imageBytes;
  }  Future<Map<String, dynamic>?> _showAddMapDialog(AppLocalizations l10n) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController versionController = TextEditingController(text: '1');
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.addMap),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: l10n.mapTitle,
                  hintText: l10n.enterMapTitle,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: versionController,
                decoration: const InputDecoration(
                  labelText: '地图版本',
                  hintText: '输入地图版本号',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text.trim();
                final version = int.tryParse(versionController.text) ?? 1;
                if (title.isNotEmpty) {
                  Navigator.of(context).pop({
                    'title': title,
                    'version': version,
                  });
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _deleteMap(MapItem map) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteMap),
          content: Text(l10n.confirmDeleteMap(map.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteMap(map.id!);
        await _loadMaps();
        _showSuccessSnackBar(l10n.mapDeletedSuccessfully);
      } catch (e) {
        _showErrorSnackBar(l10n.deleteMapFailed(e.toString()));
      }
    }
  }  Future<void> _exportDatabase() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // 显示版本选择对话框
      final exportVersion = await _showExportVersionDialog(l10n);
      if (exportVersion != null) {
        final path = await _databaseService.exportDatabase(customVersion: exportVersion);
        if (path != null) {
          _showSuccessSnackBar(l10n.exportSuccessful(path));
        }
      }
    } catch (e) {
      _showErrorSnackBar(l10n.exportFailed(e.toString()));
    }
  }

  Future<int?> _showExportVersionDialog(AppLocalizations l10n) async {
    final currentVersion = await _databaseService.getDatabaseVersion();
    final TextEditingController versionController = TextEditingController(
      text: currentVersion.toString(),
    );
    
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('设置导出版本'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('当前数据库版本: $currentVersion'),
              const SizedBox(height: 16),
              TextField(
                controller: versionController,
                decoration: const InputDecoration(
                  labelText: '导出版本号',
                  hintText: '输入要导出的版本号',
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 8),
              const Text(
                '提示：设置更高的版本号可用于更新外部资源',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final version = int.tryParse(versionController.text);
                if (version != null && version > 0) {
                  Navigator.of(context).pop(version);
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _importDatabase() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await _databaseService.importDatabaseDebug();
      if (success) {
        await _loadMaps();
        _showSuccessSnackBar(l10n.importSuccessful);
      }
    } catch (e) {
      _showErrorSnackBar(l10n.importFailed(e.toString()));
    }
  }

  Future<void> _updateExternalResources() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await _databaseService.updateExternalResources();
      if (success) {
        await _loadMaps();
        _showSuccessSnackBar(l10n.updateSuccessful);
      }
    } catch (e) {
      _showErrorSnackBar(l10n.updateFailed(e.toString()));
    }
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const cardWidth = 300.0; // 每个卡片的最小宽度
    return (screenWidth / cardWidth).floor().clamp(1, 6);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
      return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapAtlas),
        actions: [
          // 更新外部资源按钮（非调试模式）
          IconButton(
            onPressed: _updateExternalResources,
            icon: const Icon(Icons.cloud_download),
            tooltip: l10n.updateExternalResources,
          ),
          // 调试模式功能
          ConfigAwareAppBarAction(
            featureId: 'DebugMode',
            action: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'add':
                    _addMap();
                    break;
                  case 'import':
                    _importDatabase();
                    break;
                  case 'export':
                    _exportDatabase();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'add',
                  child: ListTile(
                    leading: const Icon(Icons.add),
                    title: Text(l10n.addMap),
                  ),
                ),
                PopupMenuItem(
                  value: 'import',
                  child: ListTile(
                    leading: const Icon(Icons.file_upload),
                    title: Text(l10n.importDatabase),
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: const Icon(Icons.file_download),
                    title: Text(l10n.exportDatabase),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _maps.isEmpty              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        l10n.mapAtlasEmpty,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text('点击右上角菜单添加地图'),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _calculateCrossAxisCount(context),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5, // 长方形卡片比例
                    ),
                    itemCount: _maps.length,
                    itemBuilder: (context, index) {
                      final map = _maps[index];
                      return _MapCard(
                        map: map,
                        onDelete: () => _deleteMap(map),
                        onTap: () {
                          // 暂时不实现点击事件
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final MapItem map;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _MapCard({
    required this.map,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // 左半部分：图片
            Expanded(
              flex: 1,
              child: AspectRatio(
                aspectRatio: 1,
                child: map.imageData != null
                    ? Image.memory(
                        map.imageData!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            // 右半部分：标题和操作
            Expanded(
              flex: 1,
              child: Container(
                height: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              map.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'v${map.version}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 调试模式下显示删除按钮
                      ConfigAwareWidget(
                        featureId: 'DebugMode',
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 20),
                            color: Colors.red,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
