import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:lpinyin/lpinyin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../services/virtual_file_system/vfs_service_provider.dart';
import '../../mixins/map_localization_mixin.dart';
// import '../../components/common/config_aware_widgets.dart';
import '../../config/config_manager.dart';
import '../map_editor/map_editor_page.dart';
import '../../components/common/draggable_title_bar.dart';
import '../../../services/notification/notification_service.dart';
import '../../collaboration/mixins/auto_presence_mixin.dart'; // 导入在线状态管理混入
import '../../collaboration/models/user_presence.dart'; // 导入用户状态枚举
import '../../collaboration/blocs/presence/presence_event.dart'; // 导入状态事件
import '../../collaboration/blocs/presence/presence_bloc.dart'; // 导入状态管理
import '../../collaboration/blocs/presence/presence_state.dart'; // 导入状态定义
import '../../collaboration/services/websocket/websocket_client_manager.dart'; // 导入WebSocket客户端管理器

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
    with MapLocalizationMixin, AutoPresenceMixin {
  final VfsMapService _vfsMapService =
      VfsMapServiceFactory.createVfsMapService();
  final VfsStorageService _storageService = VfsStorageService();
  final VfsServiceProvider _vfsServiceProvider = VfsServiceProvider();
  List<MapDirectoryItem> _items = [];
  List<MapDirectoryItem> _filteredItems = []; // 筛选后的项目
  bool _isLoading = true;
  Map<String, String> _localizedTitles = {};
  String _currentPath = ''; // 当前目录路径
  List<BreadcrumbItem> _breadcrumbs = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 缓存的客户端信息
  String? _cachedClientId;
  String? _cachedClientName;

  // 实现AutoPresenceMixin的抽象方法
  @override
  String getCurrentClientId() {
    return _cachedClientId ?? 'unknown_client';
  }

  @override
  String getCurrentUserName() {
    return _cachedClientName ?? '未知客户端';
  }

  /// 异步获取并缓存客户端信息
  Future<void> _loadClientInfo() async {
    try {
      final manager = WebSocketClientManager();
      final activeConfig = await manager.getActiveConfig();
      if (activeConfig != null) {
        setState(() {
          _cachedClientId = activeConfig.clientId;
          _cachedClientName = activeConfig.displayName;
        });
        if (kDebugMode) {
          debugPrint(
            '客户端信息已加载: ID=${activeConfig.clientId}, Name=${activeConfig.displayName}',
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint('未找到活跃的客户端配置');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('获取客户端信息失败: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDirectoryContents();
    _searchController.addListener(_onSearchChanged);
    // 先异步加载客户端信息，然后初始化在线状态管理
    _initializeWithClientInfo();
  }

  /// 先加载客户端信息，然后初始化协作
  Future<void> _initializeWithClientInfo() async {
    await _loadClientInfo();
    initializeCollaboration();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    // 清理在线状态管理资源
    disposeCollaboration();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _applyFilter().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// 构建在线用户部分
  Widget _buildOnlineUsersSection(BuildContext context) {
    if (!isCollaborationInitialized) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '在线用户',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            alignment: Alignment.center,
            child: Text(
              '协作服务未初始化',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    return BlocBuilder<PresenceBloc, PresenceState>(
      bloc: presenceBloc,
      builder: (context, state) {
        if (state is! PresenceLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '在线用户',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }

        final onlineUsers = state.allUsers;
        if (onlineUsers.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '在线用户',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 100,
                alignment: Alignment.center,
                child: Text(
                  '暂无在线用户',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '在线用户 (${onlineUsers.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _calculateCrossAxisCount(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, // 方形卡片
              ),
              itemCount: onlineUsers.length,
              itemBuilder: (context, index) {
                final user = onlineUsers[index];
                final isCurrentUser =
                    user.clientId == state.currentUser.clientId;
                return Card(
                  elevation: isCurrentUser ? 4 : 2,
                  color: isCurrentUser
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildUserAvatar(user, isCurrentUser, context),
                        const SizedBox(height: 8),
                        Text(
                          isCurrentUser
                              ? '${user.displayName ?? user.userName} (我)'
                              : (user.displayName ?? user.userName),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: isCurrentUser
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCurrentUser
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer
                                    : null,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              context,
                              user.status,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(user.status),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: _getStatusColor(context, user.status),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// 构建活跃地图部分
  Widget _buildActiveMapsSection(BuildContext context) {
    if (!isCollaborationInitialized) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '活跃地图',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            alignment: Alignment.center,
            child: Text(
              '协作服务未初始化',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    return BlocBuilder<PresenceBloc, PresenceState>(
      bloc: presenceBloc,
      builder: (context, state) {
        if (state is! PresenceLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '活跃地图',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }

        // 按地图ID分组用户
        final mapGroups = <String, List<UserPresence>>{};
        for (final user in state.allUsers) {
          if (user.currentMapId != null && user.currentMapId!.isNotEmpty) {
            mapGroups.putIfAbsent(user.currentMapId!, () => []).add(user);
          }
        }

        if (mapGroups.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '活跃地图',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 100,
                alignment: Alignment.center,
                child: Text(
                  '暂无活跃地图',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '活跃地图 (${mapGroups.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _calculateCrossAxisCount(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 1.1, // 3:2比例 + 标题空间
              ),
              itemCount: mapGroups.length,
              itemBuilder: (context, index) {
                final mapId = mapGroups.keys.elementAt(index);
                final users = mapGroups[mapId]!;
                final firstUser = users.first;
                final mapTitle = firstUser.currentMapTitle ?? mapId;
                final mapCover = firstUser.currentMapCoverBase64;

                return Card(
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      // 可以添加点击进入地图的功能
                      context.showInfoSnackBar('进入活跃地图: $mapTitle');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 地图封面和标题
                        AspectRatio(
                          aspectRatio: 3 / 2,
                          child: mapCover != null && mapCover.isNotEmpty
                              ? Image.memory(
                                  mapCover.startsWith('data:') ||
                                          mapCover.contains('base64,')
                                      ? base64Decode(mapCover.split(',').last)
                                      : base64Decode(mapCover),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mapTitle,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              ...users.map((user) {
                                final isCurrentUser =
                                    user.clientId == state.currentUser.clientId;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _getStatusColor(
                                            context,
                                            user.status,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          isCurrentUser
                                              ? '${user.userName} (我)'
                                              : user.userName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: isCurrentUser
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        _getStatusText(user.status),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: _getStatusColor(
                                                context,
                                                user.status,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(BuildContext context, UserActivityStatus status) {
    switch (status) {
      case UserActivityStatus.editing:
        return Colors.red;
      case UserActivityStatus.viewing:
        return Colors.blue;
      case UserActivityStatus.idle:
        return Colors.green;
      case UserActivityStatus.offline:
        return Colors.grey;
    }
  }

  /// 获取状态文本
  String _getStatusText(UserActivityStatus status) {
    switch (status) {
      case UserActivityStatus.editing:
        return '编辑中';
      case UserActivityStatus.viewing:
        return '查看中';
      case UserActivityStatus.idle:
        return '在线';
      case UserActivityStatus.offline:
        return '离线';
    }
  }

  /// 构建用户头像
  Widget _buildUserAvatar(
    UserPresence user,
    bool isCurrentUser,
    BuildContext context,
  ) {
    final size = 32.0;
    final statusColor = isCurrentUser
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : _getStatusColor(context, user.status);

    // 如果有头像数据
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      try {
        // 检查是否为base64编码的图片
        if (user.avatar!.startsWith('data:image/') ||
            (user.avatar!.length > 100 && !user.avatar!.startsWith('http'))) {
          // base64图片
          final base64String = user.avatar!.startsWith('data:image/')
              ? user.avatar!.split(',')[1]
              : user.avatar!;
          final imageBytes = base64Decode(base64String);
          return CircleAvatar(
            radius: size / 2,
            backgroundImage: MemoryImage(imageBytes),
            backgroundColor: statusColor,
            onBackgroundImageError: (exception, stackTrace) {
              // 如果图片加载失败，显示默认头像
            },
            child: null,
          );
        } else if (user.avatar!.startsWith('http')) {
          // 网络图片
          return CircleAvatar(
            radius: size / 2,
            backgroundImage: NetworkImage(user.avatar!),
            backgroundColor: statusColor,
            onBackgroundImageError: (exception, stackTrace) {
              // 如果图片加载失败，显示默认头像
            },
            child: null,
          );
        }
      } catch (e) {
        // 如果解析失败，显示默认头像
      }
    }

    // 默认头像：显示用户名首字母
    final displayName = user.displayName ?? user.userName;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: statusColor,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 应用搜索筛选
  Future<void> _applyFilter() async {
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_items);
      return;
    }

    try {
      // 使用VFS搜索功能搜索子目录
      final pattern = '*$_searchQuery*';
      final searchResults = await _vfsServiceProvider.searchFiles(
        'maps', // collection
        pattern,
        caseSensitive: false,
        includeDirectories: true,
        maxResults: 1000,
      );

      // 过滤搜索结果，只包含.mapdata之前的路径
      final filteredResults = searchResults.where((file) {
        final relativePath = file.path.replaceFirst(
          'indexeddb://r6box/maps/',
          '',
        );

        // 只搜索.mapdata路径之前的内容
        if (relativePath.contains('.mapdata/')) {
          return false;
        }

        // 确保在当前路径下或其子目录中
        if (_currentPath.isNotEmpty) {
          final expectedPrefix = _currentPath.endsWith('/')
              ? _currentPath
              : '$_currentPath/';
          if (!relativePath.startsWith(expectedPrefix) &&
              relativePath != _currentPath.replaceAll('/', '')) {
            return false;
          }
        }

        return true;
      }).toList();

      // 将VFS搜索结果转换为MapDirectoryItem
      final searchItems = <MapDirectoryItem>[];
      for (final file in filteredResults) {
        final relativePath = file.path.replaceFirst(
          'indexeddb://r6box/maps/',
          '',
        );

        debugPrint(
          'DEBUG: Processing file - name: ${file.name}, path: ${file.path}, relativePath: $relativePath',
        );

        if (file.isDirectory && file.name.endsWith('.mapdata')) {
          // .mapdata目录 - 这是地图文件
          final mapName = file.name.replaceAll('.mapdata', '');

          // 使用新的getMapSummaryByPath方法加载地图摘要
          try {
            final realSummary = await _vfsMapService.getMapSummaryByPath(
              relativePath,
            );

            if (realSummary != null) {
              searchItems.add(
                MapFileItem(
                  name: mapName,
                  path: relativePath, // relativePath已经包含完整路径包括.mapdata
                  mapSummary: realSummary,
                ),
              );
            } else {
              // 如果无法加载真实摘要，创建基本的MapItemSummary
              final mapSummary = MapItemSummary(
                id: mapName.hashCode,
                title: mapName,
                version: 1,
                createdAt: file.createdAt,
                updatedAt: file.modifiedAt,
              );
              searchItems.add(
                MapFileItem(
                  name: mapName,
                  path: relativePath, // relativePath已经包含完整路径包括.mapdata
                  mapSummary: mapSummary,
                ),
              );
            }
          } catch (e) {
            debugPrint('加载地图摘要失败: $e');
            // 创建基本的MapItemSummary作为回退
            final mapSummary = MapItemSummary(
              id: mapName.hashCode,
              title: mapName,
              version: 1,
              createdAt: file.createdAt,
              updatedAt: file.modifiedAt,
            );
            searchItems.add(
              MapFileItem(
                name: mapName,
                path: relativePath, // relativePath已经包含完整路径包括.mapdata
                mapSummary: mapSummary,
              ),
            );
          }
        } else if (file.isDirectory) {
          // 普通文件夹项
          searchItems.add(
            MapFolderItem(
              name: file.name,
              path: relativePath,
              mapCount: 0, // 搜索结果中暂时设为0，实际计数需要额外查询
            ),
          );
        }
      }

      // 只显示搜索结果，不与当前目录内容合并
      _filteredItems = searchItems;
    } catch (e) {
      // 如果VFS搜索失败，回退到本地筛选
      _filteredItems = _items.where((item) {
        final name = item.name.toLowerCase();
        final query = _searchQuery.toLowerCase();
        final pinyin = PinyinHelper.getPinyinE(item.name).toLowerCase();
        return name.contains(query) || pinyin.contains(query);
      }).toList();
    }
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

      // 获取当前目录下的地图摘要
      final mapSummaries = await _vfsMapService.getAllMapsSummary(
        _currentPath.isEmpty ? null : _currentPath,
      );

      for (final mapSummary in mapSummaries) {
        // 构建完整的地图路径，包含.mapdata
        final mapPath = _currentPath.isEmpty
            ? '${mapSummary.title}.mapdata'
            : '$_currentPath/${mapSummary.title}.mapdata';
        items.add(
          MapFileItem(
            name: mapSummary.title,
            path: mapPath, // 使用包含.mapdata的完整路径
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

        // 应用当前筛选
        await _applyFilter();
        if (mounted) {
          setState(() {});
        }
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
      // 递归计算文件夹中的地图数量 - 使用轻量级方法只检查.mapdata目录
      int count = await _vfsMapService.getMapCount(folderPath);

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

      // 确定文件类型
      final fileName = result.files.single.name.toLowerCase();
      final isPng = fileName.endsWith('.png');
      final isSvg = fileName.endsWith('.svg');

      // 处理图片 - PNG和SVG保持原始文件，只压缩JPG/JPEG
      final processedImage = (isPng || isSvg)
          ? imageBytes
          : _compressImage(imageBytes);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final mapInfo = await _showAddMapDialog(l10n);
        if (mapInfo != null && mapInfo['title']?.isNotEmpty == true) {
          try {
            final mapTitle = mapInfo['title'] as String;

            // 检查地图是否已存在
            final existingMap = await _vfsMapService.getMapByTitle(
              mapTitle,
              _currentPath.isEmpty ? null : _currentPath,
            );

            if (existingMap != null) {
              // 显示覆盖确认对话框
              final shouldOverwrite = await _showOverwriteConfirmDialog(
                l10n,
                mapTitle,
              );
              if (shouldOverwrite != true) {
                return; // 用户取消覆盖
              }
            }

            final mapItem = MapItem(
              title: mapTitle,
              imageData: processedImage,
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
        // 使用PNG编码以保持透明通道支持
        return Uint8List.fromList(img.encodePng(resized));
      }
    } catch (e) {
      debugPrint('图片压缩失败: $e');
    }
    return imageBytes;
  }

  Future<bool?> _showOverwriteConfirmDialog(
    AppLocalizations l10n,
    String mapTitle,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('地图已存在'),
          content: Text('地图 "$mapTitle" 已存在，是否要覆盖现有地图？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('覆盖'),
            ),
          ],
        );
      },
    );
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

    // 构建绝对路径
    String absoluteMapPath;
    if (_currentPath.isEmpty) {
      absoluteMapPath = 'indexeddb://r6box/maps/$mapTitle.mapdata/';
    } else {
      absoluteMapPath =
          'indexeddb://r6box/maps/$_currentPath/$mapTitle.mapdata/';
    }

    // 获取地图摘要信息用于在线状态更新
    MapItemSummary? mapSummary;
    try {
      final summaries = await _vfsMapService.getAllMapsSummary(
        _currentPath.isEmpty ? null : _currentPath,
      );
      mapSummary = summaries.firstWhere((summary) => summary.title == mapTitle);
    } catch (e) {
      debugPrint('获取地图摘要失败: $e');
    }

    // 更新在线状态为viewing
    if (mapSummary != null) {
      presenceBloc.add(
        UpdateCurrentUserStatus(
          status: UserActivityStatus.viewing,
          metadata: {
            'mapId': mapSummary.id.toString(),
            'mapTitle': mapSummary.title,
            'mapCover': mapSummary.imageData,
          },
        ),
      );
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapEditorPage(
          mapTitle: mapTitle,
          folderPath: _currentPath.isEmpty ? null : _currentPath,
          absoluteMapPath: absoluteMapPath, // 传递绝对路径
          isPreviewMode: isReadOnly, // 只读模式强制预览模式
        ),
      ),
    );

    // 退出编辑器后的状态清理由AutoPresenceManager自动处理

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

  void _openMapEditorWithPath(String mapTitle, String itemPath) async {
    debugPrint(
      'DEBUG: _openMapEditorWithPath called with mapTitle: $mapTitle, itemPath: $itemPath',
    );

    final isReadOnly = await ConfigManager.instance.isFeatureEnabled(
      'ReadOnlyMode',
    );

    // itemPath是从搜索结果来的，格式是完整的相对路径，包含.mapdata
    // 例如: "排名战地图/杜耶托夫斯基咖啡馆.mapdata"
    String absoluteMapPath;
    String? folderPath;

    // 构建绝对路径，确保以/结尾
    absoluteMapPath = 'indexeddb://r6box/maps/$itemPath/';

    // 从itemPath中提取folderPath
    if (itemPath.contains('/')) {
      // 有文件夹路径，提取除了最后的.mapdata文件名部分
      final lastSlashIndex = itemPath.lastIndexOf('/');
      folderPath = itemPath.substring(0, lastSlashIndex);
    } else {
      // 根目录下的地图
      folderPath = null;
    }

    // 获取地图摘要信息用于在线状态更新
    MapItemSummary? mapSummary;
    try {
      mapSummary = await _vfsMapService.getMapSummaryByPath(itemPath);
    } catch (e) {
      debugPrint('获取地图摘要失败: $e');
    }

    // 更新在线状态为viewing
    if (mapSummary != null) {
      presenceBloc.add(
        UpdateCurrentUserStatus(
          status: UserActivityStatus.viewing,
          metadata: {
            'mapId': mapSummary.id.toString(),
            'mapTitle': mapSummary.title,
            'mapCover': mapSummary.imageData,
          },
        ),
      );
    }

    debugPrint(
      'DEBUG: Passing to MapEditorPage - mapTitle: $mapTitle, folderPath: $folderPath, absoluteMapPath: $absoluteMapPath',
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapEditorPage(
          mapTitle: mapTitle,
          folderPath: folderPath,
          absoluteMapPath: absoluteMapPath,
          isPreviewMode: isReadOnly,
        ),
      ),
    );

    // 退出编辑器后的状态清理由AutoPresenceManager自动处理

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
    const cardWidth = 200.0; // 每个卡片的最小宽度（适应新的4:3垂直布局）
    return (screenWidth / cardWidth).floor().clamp(2, 8);
  }

  /// 获取排序键，中文转拼音，符号和无法转换的字符排在最前
  String _getSortKey(String name) {
    if (name.isEmpty) return '';

    final firstChar = name[0];

    // 检查是否为中文字符
    if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(firstChar)) {
      final pinyin = PinyinHelper.getPinyinE(firstChar);
      return pinyin.isNotEmpty ? pinyin.toLowerCase() : '~$name';
    }

    // 检查是否为英文字母
    if (RegExp(r'[a-zA-Z]').hasMatch(firstChar)) {
      return firstChar.toLowerCase();
    }

    // 符号和其他字符排在最前面
    return '~$name';
  }

  /// 对项目列表进行排序
  List<MapDirectoryItem> _sortItems(List<MapDirectoryItem> items) {
    final folders = items.whereType<MapFolderItem>().toList();
    final maps = items.whereType<MapFileItem>().toList();

    // 分别对文件夹和地图进行排序
    folders.sort((a, b) => _getSortKey(a.name).compareTo(_getSortKey(b.name)));
    maps.sort((a, b) => _getSortKey(a.name).compareTo(_getSortKey(b.name)));

    // 文件夹在前，地图在后
    return [...folders, ...maps];
  }

  /// 构建分组内容
  Widget _buildGroupedContent(BuildContext context) {
    final sortedItems = _sortItems(_filteredItems);
    final folders = sortedItems.whereType<MapFolderItem>().toList();
    final maps = sortedItems.whereType<MapFileItem>().toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文件夹部分
          if (folders.isNotEmpty) ...[
            Text(
              '文件夹',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildGridSection(context, folders),
          ],

          // 分割线
          if (folders.isNotEmpty && maps.isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(color: Theme.of(context).colorScheme.outline, thickness: 1),
            const SizedBox(height: 24),
          ],

          // 地图部分
          if (maps.isNotEmpty) ...[
            Text(
              '地图',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildGridSection(context, maps),
          ],

          // 分割线
          const SizedBox(height: 24),
          Divider(color: Theme.of(context).colorScheme.outline, thickness: 1),
          const SizedBox(height: 24),

          // 在线用户部分
          _buildOnlineUsersSection(context),

          // 分割线
          const SizedBox(height: 24),
          Divider(color: Theme.of(context).colorScheme.outline, thickness: 1),
          const SizedBox(height: 24),

          // 活跃地图部分
          _buildActiveMapsSection(context),
        ],
      ),
    );
  }

  /// 构建网格部分
  Widget _buildGridSection(BuildContext context, List<MapDirectoryItem> items) {
    final crossAxisCount = _calculateCrossAxisCount(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 1.1, // 3:2比例 + 标题空间
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(context, items[index]);
      },
    );
  }

  /// 构建单个项目卡片
  Widget _buildItemCard(BuildContext context, MapDirectoryItem item) {
    if (item is MapFolderItem) {
      return _FolderCard(
        folder: item,
        onTap: () => _loadDirectoryContents(item.path),
        onDelete: item.mapCount == 0
            ? () async {
                final isReadOnly = await ConfigManager.instance
                    .isFeatureEnabled('ReadOnlyMode');
                if (isReadOnly) {
                  WebReadOnlyDialog.show(context, '删除文件夹');
                } else {
                  _deleteFolder(item);
                }
              }
            : null,
        onRename: () async {
          final isReadOnly = await ConfigManager.instance.isFeatureEnabled(
            'ReadOnlyMode',
          );
          if (isReadOnly) {
            WebReadOnlyDialog.show(context, '重命名文件夹');
          } else {
            _showRenameFolderDialog(item);
          }
        },
      );
    } else if (item is MapFileItem) {
      final map = item.mapSummary;
      return _MapCard(
        map: map,
        localizedTitle: _localizedTitles[map.title] ?? map.title,
        onDelete: () async {
          final isReadOnly = await ConfigManager.instance.isFeatureEnabled(
            'ReadOnlyMode',
          );
          if (isReadOnly) {
            WebReadOnlyDialog.show(context, '删除地图');
          } else {
            _deleteMap(map);
          }
        },
        onTap: () {
          // 对于搜索结果中的地图，需要特殊处理路径
          if (item is MapFileItem) {
            debugPrint(
              'DEBUG: Opening map with title: ${item.mapSummary.title}, path: ${item.path}',
            );
            _openMapEditorWithPath(item.mapSummary.title, item.path);
          } else {
            debugPrint('DEBUG: Opening map with title: ${map.title}');
            _openMapEditor(map.title);
          }
        },
        onRename: () async {
          final isReadOnly = await ConfigManager.instance.isFeatureEnabled(
            'ReadOnlyMode',
          );
          if (isReadOnly) {
            WebReadOnlyDialog.show(context, '重命名地图');
          } else {
            _showRenameMapDialog(map.title);
          }
        },
        onUpdateCover: () async {
          final isReadOnly = await ConfigManager.instance.isFeatureEnabled(
            'ReadOnlyMode',
          );
          if (isReadOnly) {
            WebReadOnlyDialog.show(context, '更换封面');
          } else {
            _showUpdateCoverDialog(map.title);
          }
        },
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          DraggableTitleBar(
            icon: Icons.map,
            titleWidget: Row(
              children: [
                Text(
                  l10n.mapAtlas,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  height: 36,
                  width: 200,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索地图和文件夹...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Spacer(),
              ],
            ),
            actions: [
              // 上传本地化文件按钮
              // IconButton(
              //   onPressed: _uploadLocalizationFile,
              //   icon: const Icon(Icons.translate),
              //   tooltip: '上传本地化文件',
              // ),
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
                    case 'root':
                      _loadDirectoryContents(null);
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
                  const PopupMenuItem(
                    value: 'root',
                    child: ListTile(
                      leading: Icon(Icons.home),
                      title: Text('回到根目录'),
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 空状态提示
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentPath.isEmpty
                                  ? l10n.mapAtlasEmpty
                                  : '此文件夹为空',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '点击右上角菜单添加地图或创建文件夹',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 分割线
                      const SizedBox(height: 32),
                      Divider(
                        color: Theme.of(context).colorScheme.outline,
                        thickness: 1,
                      ),
                      const SizedBox(height: 24),

                      // 在线用户部分
                      _buildOnlineUsersSection(context),

                      // 分割线
                      const SizedBox(height: 24),
                      Divider(
                        color: Theme.of(context).colorScheme.outline,
                        thickness: 1,
                      ),
                      const SizedBox(height: 24),

                      // 活跃地图部分
                      _buildActiveMapsSection(context),
                    ],
                  ),
                )
              : _filteredItems.isEmpty && _searchQuery.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '未找到匹配的结果',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '尝试使用不同的关键词搜索',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildGroupedContent(context),
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

  Future<void> _showRenameFolderDialog(MapFolderItem folder) async {
    final controller = TextEditingController(text: folder.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名文件夹'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '新文件夹名称',
            border: OutlineInputBorder(),
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
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != folder.name) {
                Navigator.of(context).pop(newName);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        // 构建新的路径
        final parentPath = folder.path.contains('/')
            ? folder.path.substring(0, folder.path.lastIndexOf('/'))
            : '';
        final newPath = parentPath.isEmpty ? result : '$parentPath/$result';

        await _vfsMapService.renameFolder(folder.path, newPath);
        _showSuccessSnackBar('文件夹重命名成功');
        await _loadDirectoryContents(
          _currentPath.isEmpty ? null : _currentPath,
        );
      } catch (e) {
        _showErrorSnackBar('重命名失败: ${e.toString()}');
      }
    }
  }

  Future<void> _showRenameMapDialog(String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名地图'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '新地图名称',
            border: OutlineInputBorder(),
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
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != currentTitle) {
                Navigator.of(context).pop(newTitle);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _vfsMapService.renameMap(
          currentTitle,
          result,
          _currentPath.isEmpty ? null : _currentPath,
        );
        _showSuccessSnackBar('地图重命名成功');
        await _loadDirectoryContents(
          _currentPath.isEmpty ? null : _currentPath,
        );
      } catch (e) {
        _showErrorSnackBar('重命名失败: ${e.toString()}');
      }
    }
  }

  Future<void> _showUpdateCoverDialog(String mapTitle) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final Uint8List imageBytes;
        if (kIsWeb) {
          imageBytes = result.files.single.bytes!;
        } else {
          final file = File(result.files.single.path!);
          imageBytes = await file.readAsBytes();
        }

        // 压缩图片
        final compressedImage = _compressImage(imageBytes);

        await _vfsMapService.updateMapCover(
          mapTitle,
          compressedImage,
          _currentPath.isEmpty ? null : _currentPath,
        );

        _showSuccessSnackBar('地图封面更新成功');
        await _loadDirectoryContents(
          _currentPath.isEmpty ? null : _currentPath,
        );
      }
    } catch (e) {
      _showErrorSnackBar('更新封面失败: ${e.toString()}');
    }
  }
}

class _MapCard extends StatelessWidget {
  final MapItemSummary map;
  final String localizedTitle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onUpdateCover;

  const _MapCard({
    required this.map,
    required this.localizedTitle,
    required this.onDelete,
    required this.onTap,
    this.onRename,
    this.onUpdateCover,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片卡片 - 4:3比例
        Expanded(
          child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              onSecondaryTapDown: (details) {
                if (onRename != null ||
                    onUpdateCover != null ||
                    onDelete != null) {
                  _showMapContextMenu(context, details.globalPosition);
                }
              },
              child: AspectRatio(
                aspectRatio: 3 / 2, // 3:2比例
                child: map.imageData != null
                    ? Image.memory(map.imageData!, fit: BoxFit.cover)
                    : Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
          ),
        ),
        // 标题显示在卡片外下方
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'v${map.version}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMapContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        if (onRename != null)
          PopupMenuItem(
            value: 'rename',
            child: const Row(
              children: [
                Icon(Icons.edit, size: 16),
                SizedBox(width: 8),
                Text('重命名'),
              ],
            ),
          ),
        if (onUpdateCover != null)
          PopupMenuItem(
            value: 'update_cover',
            child: const Row(
              children: [
                Icon(Icons.image, size: 16),
                SizedBox(width: 8),
                Text('更换封面'),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: const Row(
              children: [
                Icon(Icons.delete, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('删除', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    ).then((value) {
      switch (value) {
        case 'rename':
          onRename?.call();
          break;
        case 'update_cover':
          onUpdateCover?.call();
          break;
        case 'delete':
          onDelete?.call();
          break;
      }
    });
  }
}

class _FolderCard extends StatelessWidget {
  final MapFolderItem folder;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  const _FolderCard({
    required this.folder,
    required this.onTap,
    this.onDelete,
    this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 文件夹图标 - 无背景，直接放大图标
        Expanded(
          child: InkWell(
            onTap: onTap,
            onSecondaryTapDown: (onDelete != null || onRename != null)
                ? (details) {
                    _showFolderContextMenu(context, details.globalPosition);
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 3 / 2, // 3:2比例
              child: Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: Icon(
                  Icons.folder,
                  size: 120, // 放大图标到和卡片等宽
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        // 标题显示在图标下方
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                folder.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                '${folder.mapCount} 个地图',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFolderContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        if (onRename != null)
          PopupMenuItem(
            value: 'rename',
            child: const Row(
              children: [
                Icon(Icons.edit, size: 16),
                SizedBox(width: 8),
                Text('重命名'),
              ],
            ),
          ),
        // 只有空文件夹才显示删除选项
        if (folder.mapCount == 0 && onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: const Row(
              children: [
                Icon(Icons.delete, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('删除', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    ).then((value) {
      switch (value) {
        case 'rename':
          onRename?.call();
          break;
        case 'delete':
          onDelete?.call();
          break;
      }
    });
  }
}
