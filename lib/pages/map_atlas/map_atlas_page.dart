import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import '../../components/layout/main_layout.dart';
import '../../components/layout/page_configuration.dart';
import '../../components/web/web_readonly_components.dart';
import '../../l10n/app_localizations.dart';
import '../../models/map_item.dart';
import '../../models/map_item_summary.dart';
import '../../services/map_database_service.dart';
import '../../mixins/map_localization_mixin.dart';
import '../../components/common/config_aware_widgets.dart';
import '../map_editor/map_editor_page.dart';

class MapAtlasPage extends BasePage {
  const MapAtlasPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return WebReadOnlyBanner(
      showBanner: kIsWeb,
      child: const _MapAtlasContent(),
    );
  }
}

class _MapAtlasContent extends StatefulWidget {
  const _MapAtlasContent();

  @override
  State<_MapAtlasContent> createState() => _MapAtlasContentState();
}

class _MapAtlasContentState extends State<_MapAtlasContent>
    with MapLocalizationMixin {
  final MapDatabaseService _databaseService = MapDatabaseService();
  List<MapItemSummary> _maps = [];
  bool _isLoading = true;
  Map<String, String> _localizedTitles = {};

  @override
  void initState() {
    super.initState();
    _loadMaps();
  }

  Future<void> _loadMaps() async {
    setState(() => _isLoading = true);
    try {
      final maps = await _databaseService.getAllMapsSummary();

      // 加载本地化标题
      if (mounted) {
        final titles = maps.map((map) => map.title).toList();
        final localizedTitles = await getLocalizedMapTitles(titles, context);

        setState(() {
          _maps = maps;
          _localizedTitles = localizedTitles;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.loadMapsFailed(e.toString()));
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      final compressedImage = _compressImage(imageBytes);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final mapInfo = await _showAddMapDialog(l10n);
        if (mapInfo != null && mapInfo['title']?.isNotEmpty == true) {
          try {
            final mapItem = MapItem(
              title: mapInfo['title'],
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
  }

  Future<Map<String, dynamic>?> _showAddMapDialog(AppLocalizations l10n) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController versionController = TextEditingController(
      text: '1',
    );

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
                  Navigator.of(
                    context,
                  ).pop({'title': title, 'version': version});
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMap(MapItemSummary map) async {
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
        await _databaseService.deleteMap(map.id);
        await _loadMaps();
        _showSuccessSnackBar(l10n.mapDeletedSuccessfully);
      } catch (e) {
        _showErrorSnackBar(l10n.deleteMapFailed(e.toString()));
      }
    }
  }

  Future<void> _uploadLocalizationFile() async {
    try {
      final success = await localizationService.importLocalizationFile();

      if (success) {
        await _loadMaps(); // 重新加载以应用新的本地化
        _showSuccessSnackBar('本地化文件上传成功');
      } else {
        _showErrorSnackBar('本地化文件版本过低或取消上传');
      }
    } catch (e) {
      _showErrorSnackBar('上传本地化文件失败: ${e.toString()}');
    }
  }

  void _openMapEditor(int mapId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfigAwareWidget(
          featureId: 'DebugMode',
          child: MapEditorPage(
            mapId: mapId,
            isPreviewMode: kIsWeb ? true : false, // Web平台强制预览模式
          ),
          fallback: MapEditorPage(
            mapId: mapId,
            isPreviewMode: true, // 非调试模式下只能预览
          ),
        ),
      ),
    );

    // 地图编辑器关闭后，强制重新检查页面配置
    if (mounted) {
      // 使用延迟确保页面已完全恢复
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // 发送页面配置通知以重新显示TrayNavigation
          PageConfigurationNotification(
            showTrayNavigation: true,
          ).dispatch(context);
        }
      });
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
          // 上传本地化文件按钮
          IconButton(
            onPressed: _uploadLocalizationFile,
            icon: const Icon(Icons.translate),
            tooltip: '上传本地化文件',
          ), // 调试模式功能
          ConfigAwareAppBarAction(
            featureId: 'DebugMode',
            action: PopupMenuButton<String>(
              onSelected: (value) {
                if (kIsWeb) {
                  // Web平台显示只读模式提示
                  String operationName;
                  switch (value) {
                    case 'add':
                      operationName = '添加地图';
                      break;
                    default:
                      operationName = '操作';
                  }
                  WebReadOnlyDialog.show(context, operationName);
                  return;
                }
                switch (value) {
                  case 'add':
                    _addMap();
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
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _maps.isEmpty
          ? Center(
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
                    localizedTitle: _localizedTitles[map.title] ?? map.title,
                    onDelete: () {
                      if (kIsWeb) {
                        WebReadOnlyDialog.show(context, '删除地图');
                      } else {
                        _deleteMap(map);
                      }
                    },
                    onTap: () => _openMapEditor(map.id),
                  );
                },
              ),
            ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final MapItemSummary map;
  final String localizedTitle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _MapCard({
    required this.map,
    required this.localizedTitle,
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
                    ? Image.memory(map.imageData!, fit: BoxFit.cover)
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
                              localizedTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'v${map.version}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
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
