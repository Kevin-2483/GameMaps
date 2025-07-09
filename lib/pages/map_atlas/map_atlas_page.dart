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
import '../../models/map_directory_item.dart';
import '../../services/vfs_map_storage/vfs_map_service.dart';
import '../../services/vfs_map_storage/vfs_map_service_factory.dart';
import '../../services/virtual_file_system/vfs_storage_service.dart';
import '../../mixins/map_localization_mixin.dart';
// import '../../components/common/config_aware_widgets.dart';
import '../../config/config_manager.dart';
import '../map_editor/map_editor_page.dart';
import '../../utils/filename_sanitizer.dart';
import '../../components/common/draggable_title_bar.dart';
import '../../../services/notification/notification_service.dart';

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

class _MapAtlasContentState extends State<_MapAtlasContent>
    with MapLocalizationMixin {
  final VfsMapService _vfsMapService =
      VfsMapServiceFactory.createVfsMapService();
  final VfsStorageService _storageService = VfsStorageService();
  List<MapDirectoryItem> _items = [];
  bool _isLoading = true;
  Map<String, String> _localizedTitles = {};
  String _currentPath = ''; // 当前目录路径
  List<BreadcrumbItem> _breadcrumbs = [];

  @override
  void initState() {
    super.initState();
    _loadDirectoryContents();
  }

  Future<void> _loadDirectoryContents([String? folderPath]) async {
    setState(() => _isLoading = true);
    try {
      _currentPath = folderPath ?? '';
      _updateBreadcrumbs();

      final items = <MapDirectoryItem>[];

      // 获取文件夹列表
      final folders = await _vfsMapService.getFolders(
        _currentPath.isEmpty ? null : _currentPath,
      );
      for (final folderName in folders) {
        final fullPath = _currentPath.isEmpty
            ? folderName
            : '$_currentPath/$folderName';
        // 计算该文件夹中的地图数量（包括子文件夹）
        final mapCount = await _countMapsInFolder(fullPath);

        items.add(
          MapFolderItem(name: folderName, path: fullPath, mapCount: mapCount),
        );
      }

      // 获取当前目录下的地图
      final maps = await _vfsMapService.getAllMaps(
        _currentPath.isEmpty ? null : _currentPath,
      );

      for (final map in maps) {
        // 读取封面图片
        Uint8List? coverImage;
        try {
          final basePath = _currentPath.isEmpty ? '' : _currentPath + '/';
          final coverPath =
              'indexeddb://r6box/maps/${basePath}${FilenameSanitizer.sanitize(map.title)}.mapdata/cover.png';
          if (await _storageService.exists(coverPath)) {
            final coverFile = await _storageService.readFile(coverPath);
            coverImage = coverFile?.data;
          }
        } catch (e) {
          debugPrint('加载封面图片失败: $e');
        }

        final mapSummary = MapItemSummary(
          id: map.title.hashCode,
          title: map.title,
          imageData: coverImage,
          version: map.version,
          createdAt: map.createdAt,
          updatedAt: map.updatedAt,
        );

        items.add(
          MapFileItem(
            name: map.title,
            path: _currentPath,
            mapSummary: mapSummary,
          ),
        );
      }

      // 加载本地化标题
      if (mounted) {
        final mapTitles = items
            .whereType<MapFileItem>()
            .map((item) => item.mapSummary.title)
            .toList();
        final localizedTitles = await getLocalizedMapTitles(mapTitles, context);

        setState(() {
          _items = items;
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

  Future<int> _countMapsInFolder(String folderPath) async {
    try {
      // 递归计算文件夹中的地图数量
      final maps = await _vfsMapService.getAllMaps(folderPath);
      int count = maps.length;

      final subFolders = await _vfsMapService.getFolders(folderPath);
      for (final subFolder in subFolders) {
        final subFolderPath = '$folderPath/$subFolder';
        count += await _countMapsInFolder(subFolderPath);
      }

      return count;
    } catch (e) {
      return 0;
    }
  }

  void _updateBreadcrumbs() {
    _breadcrumbs = [const BreadcrumbItem(name: '首页', path: '')];

    if (_currentPath.isNotEmpty) {
      final parts = _currentPath.split('/');
      String currentPath = '';

      for (final part in parts) {
        currentPath = currentPath.isEmpty ? part : '$currentPath/$part';
        _breadcrumbs.add(BreadcrumbItem(name: part, path: currentPath));
      }
    }
  }

  void _showErrorSnackBar(String message) {
    context.showErrorSnackBar(message);
  }

  void _showSuccessSnackBar(String message) {
    context.showSuccessSnackBar(message);
  }

  Future<void> _addMap() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      final Uint8List imageBytes;
      if (kIsWeb) {
        // Web平台使用bytes
        imageBytes = result.files.single.bytes!;
      } else {
        // 桌面平台使用path
        final file = File(result.files.single.path!);
        imageBytes = await file.readAsBytes();
      }

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

            // 使用VFS直接保存地图
            await _vfsMapService.saveMap(
              mapItem,
              _currentPath.isEmpty ? null : _currentPath,
            );
            await _loadDirectoryContents(
              _currentPath.isEmpty ? null : _currentPath,
            );
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
        // 使用VFS直接删除整个地图目录
        await _vfsMapService.deleteMap(
          map.title,
          _currentPath.isEmpty ? null : _currentPath,
        );
        await _loadDirectoryContents(
          _currentPath.isEmpty ? null : _currentPath,
        );
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
        await _loadDirectoryContents(
          _currentPath.isEmpty ? null : _currentPath,
        ); // 重新加载以应用新的本地化
        _showSuccessSnackBar('本地化文件上传成功');
      } else {
        _showErrorSnackBar('本地化文件版本过低或取消上传');
      }
    } catch (e) {
      _showErrorSnackBar('上传本地化文件失败: ${e.toString()}');
    }
  }

  void _openMapEditor(String mapTitle) async {
    final isReadOnly = await ConfigManager.instance.isFeatureEnabled(
      'ReadOnlyMode',
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapEditorPage(
          mapTitle: mapTitle,
          folderPath: _currentPath.isEmpty ? null : _currentPath,
          isPreviewMode: isReadOnly, // 只读模式强制预览模式
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
      body: Column(
        children: [
          DraggableTitleBar(
            title: l10n.mapAtlas,
            icon: Icons.map,
            actions: [
              // 上传本地化文件按钮
              IconButton(
                onPressed: _uploadLocalizationFile,
                icon: const Icon(Icons.translate),
                tooltip: '上传本地化文件',
              ),
              // 功能菜单
              PopupMenuButton<String>(
                onSelected: (value) async {
                  final isReadOnly = await ConfigManager.instance
                      .isFeatureEnabled('ReadOnlyMode');
                  if (isReadOnly) {
                    // 只读模式显示提示
                    String operationName;
                    switch (value) {
                      case 'add':
                        operationName = '添加地图';
                        break;
                      case 'add_folder':
                        operationName = '创建文件夹';
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
                    case 'add_folder':
                      _showCreateFolderDialog();
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
                    value: 'add_folder',
                    child: const ListTile(
                      leading: Icon(Icons.create_new_folder),
                      title: Text('创建文件夹'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(context, l10n),
          ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // 面包屑导航
        if (_breadcrumbs.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _breadcrumbs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final breadcrumb = entry.value;
                        final isLast = index == _breadcrumbs.length - 1;

                        return Row(
                          children: [
                            if (index > 0)
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            InkWell(
                              onTap: isLast
                                  ? null
                                  : () => _loadDirectoryContents(
                                      breadcrumb.path.isEmpty
                                          ? null
                                          : breadcrumb.path,
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Text(
                                  breadcrumb.name,
                                  style: TextStyle(
                                    color: isLast
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Theme.of(context).colorScheme.primary,
                                    fontWeight: isLast
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        // 内容区域
        Expanded(
          child: _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentPath.isEmpty ? l10n.mapAtlasEmpty : '此文件夹为空',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击右上角菜单添加地图或创建文件夹',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
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
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];

                      if (item is MapFolderItem) {
                        return _FolderCard(
                          folder: item,
                          onTap: () => _loadDirectoryContents(item.path),
                          onDelete: () async {
                            final isReadOnly = await ConfigManager.instance
                                .isFeatureEnabled('ReadOnlyMode');
                            if (isReadOnly) {
                              WebReadOnlyDialog.show(context, '删除文件夹');
                            } else {
                              _deleteFolder(item);
                            }
                          },
                        );
                      } else if (item is MapFileItem) {
                        final map = item.mapSummary;
                        return _MapCard(
                          map: map,
                          localizedTitle:
                              _localizedTitles[map.title] ?? map.title,
                          onDelete: () async {
                            final isReadOnly = await ConfigManager.instance
                                .isFeatureEnabled('ReadOnlyMode');
                            if (isReadOnly) {
                              WebReadOnlyDialog.show(context, '删除地图');
                            } else {
                              _deleteMap(map);
                            }
                          },
                          onTap: () => _openMapEditor(map.title),
                        );
                      }

                      return const SizedBox(); // 不应该到达这里
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _showCreateFolderDialog() async {
    final TextEditingController folderNameController = TextEditingController();

    final folderName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('创建文件夹'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              labelText: '文件夹名称',
              hintText: '输入文件夹名称',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final name = folderNameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(name);
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );

    if (folderName != null && folderName.isNotEmpty) {
      try {
        final newFolderPath = _currentPath.isEmpty
            ? folderName
            : '$_currentPath/$folderName';
        await _vfsMapService.createFolder(newFolderPath);
        await _loadDirectoryContents(
          _currentPath.isEmpty ? null : _currentPath,
        );
        _showSuccessSnackBar('文件夹创建成功');
      } catch (e) {
        _showErrorSnackBar('创建文件夹失败: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteFolder(MapFolderItem folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除文件夹'),
          content: Text('确定要删除文件夹 "${folder.name}" 吗？这将删除文件夹内的所有地图和子文件夹。'),
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
        await _vfsMapService.deleteFolder(folder.path);
        await _loadDirectoryContents(
          _currentPath.isEmpty ? null : _currentPath,
        );
        _showSuccessSnackBar('文件夹删除成功');
      } catch (e) {
        _showErrorSnackBar('删除文件夹失败: ${e.toString()}');
      }
    }
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
                      // 删除按钮
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 20),
                          color: Colors.red,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
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

class _FolderCard extends StatelessWidget {
  final MapFolderItem folder;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FolderCard({
    required this.folder,
    required this.onTap,
    required this.onDelete,
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
            // 左半部分：文件夹图标
            Expanded(
              flex: 1,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.folder,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            // 右半部分：文件夹名称和信息
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
                              folder.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${folder.mapCount} 个地图',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      // 删除按钮
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 20),
                          color: Colors.red,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
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
