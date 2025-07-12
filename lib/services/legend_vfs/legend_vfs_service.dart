import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../models/legend_item.dart';
import '../virtual_file_system/virtual_file_system.dart';
// import '../virtual_file_system/vfs_database_initializer.dart';

/// VFS图例元数据
class VfsLegendMeta {
  final int version;
  final Map<String, int> legendVersions;
  final DateTime lastUpdated;

  const VfsLegendMeta({
    required this.version,
    required this.legendVersions,
    required this.lastUpdated,
  });

  factory VfsLegendMeta.fromJson(Map<String, dynamic> json) {
    return VfsLegendMeta(
      version: json['version'] as int,
      legendVersions: Map<String, int>.from(json['legendVersions'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'legendVersions': legendVersions,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  VfsLegendMeta copyWith({
    int? version,
    Map<String, int>? legendVersions,
    DateTime? lastUpdated,
  }) {
    return VfsLegendMeta(
      version: version ?? this.version,
      legendVersions: legendVersions ?? Map.from(this.legendVersions),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// VFS图例数据
class VfsLegendData {
  final String title;
  final String imagePath;
  final String fileType; // 添加文件类型字段
  final double centerX;
  final double centerY;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VfsLegendData({
    required this.title,
    required this.imagePath,
    required this.fileType,
    required this.centerX,
    required this.centerY,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VfsLegendData.fromJson(Map<String, dynamic> json) {
    return VfsLegendData(
      title: json['title'] as String,
      imagePath: json['imagePath'] as String,
      fileType: json['fileType'] as String? ?? 'png', // 默认为png以兼容旧数据
      centerX: (json['centerX'] as num).toDouble(),
      centerY: (json['centerY'] as num).toDouble(),
      version: json['version'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imagePath': imagePath,
      'fileType': fileType,
      'centerX': centerX,
      'centerY': centerY,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// 基于VFS的图例存储服务
/// 将图例数据存储在VFS数据库结构中，数据库名为r6box，集合名为legends
/// 每个图例存储在一个名为"{title}.legend"的文件夹中
class LegendVfsService {
  static final LegendVfsService _instance = LegendVfsService._internal();
  factory LegendVfsService() => _instance;
  LegendVfsService._internal();
  final VirtualFileSystem _vfs = VirtualFileSystem();
  static const String _database = 'r6box';
  static const String _collection = 'legends';
  static const String _metaFile = 'indexeddb://r6box/legends/.meta.json';

  // 添加初始化状态标记，避免重复初始化
  // bool _isInitialized = false;

  /// 初始化VFS图例存储系统
  // Future<void> initialize() async {
  //   if (_isInitialized) {
  //     debugPrint('图例VFS系统已初始化，跳过重复初始化');
  //     return;
  //   }

  //   try {
  //     // 首先初始化VFS系统
  //     final vfsInitializer = VfsDatabaseInitializer();
  //     await vfsInitializer.initializeApplicationVfs();

  //     // 挂载legends集合到VFS系统
  //     if (!_vfs.isMounted(_database, _collection)) {
  //       _vfs.mount(_database, _collection);
  //       debugPrint('挂载legends集合到VFS系统: $_database/$_collection');
  //     }

  //     // 确保集合目录存在
  //     final collectionPath = 'indexeddb://$_database/$_collection';
  //     if (!await _vfs.exists(collectionPath)) {
  //       await _vfs.createDirectory(collectionPath);
  //     }

  //     // 确保元数据文件存在
  //     if (!await _vfs.exists(_metaFile)) {
  //       final defaultMeta = VfsLegendMeta(
  //         version: 1,
  //         legendVersions: {},
  //         lastUpdated: DateTime.now(),
  //       );
  //       await _saveMeta(defaultMeta);
  //     }

  //     _isInitialized = true;
  //     debugPrint('图例VFS系统初始化完成');
  //   } catch (e) {
  //     debugPrint('图例VFS系统初始化失败: $e');
  //     rethrow;
  //   }
  // }

  /// 构建图例文件夹路径
  String _buildLegendPath(String title, [String? folderPath]) {
    final sanitizedTitle = _sanitizeFileName(title);
    final pathPrefix = 'indexeddb://$_database/$_collection';

    if (folderPath != null && folderPath.isNotEmpty) {
      // 清理文件夹路径，移除前后斜杠
      final cleanFolderPath = folderPath.replaceAll(RegExp(r'^/+|/+$'), '');
      if (cleanFolderPath.isNotEmpty) {
        return '$pathPrefix/$cleanFolderPath/$sanitizedTitle.legend';
      }
    }

    return '$pathPrefix/$sanitizedTitle.legend';
  }

  /// 清理文件名，确保符合文件系统要求
  String _sanitizeFileName(String fileName) {
    // 替换不安全的字符
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// 反转文件名清理
  String _desanitizeFileName(String fileName) {
    // 这里可以实现更复杂的反转逻辑，目前简单返回
    return fileName.replaceAll('_', ' ').trim();
  }

  /// 获取元数据
  Future<VfsLegendMeta> _getMeta() async {
    try {
      if (await _vfs.exists(_metaFile)) {
        final metaJson = await _vfs.readJsonFile(_metaFile);
        if (metaJson != null) {
          return VfsLegendMeta.fromJson(metaJson);
        }
      }
    } catch (e) {
      debugPrint('读取图例元数据失败: $e');
    }

    // 返回默认元数据
    return VfsLegendMeta(
      version: 1,
      legendVersions: {},
      lastUpdated: DateTime.now(),
    );
  }

  /// 保存元数据
  Future<void> _saveMeta(VfsLegendMeta meta) async {
    await _vfs.writeJsonFile(_metaFile, meta.toJson());
  }

  /// 添加或更新图例
  Future<String> saveLegend(LegendItem legend, [String? folderPath]) async {
    final legendPath = _buildLegendPath(legend.title, folderPath);

    // 确保目录存在
    await _vfs.createDirectory(legendPath);

    // 根据文件类型确定文件扩展名和MIME类型
    String fileExtension;
    String mimeType;
    switch (legend.fileType) {
      case LegendFileType.svg:
        fileExtension = 'svg';
        mimeType = 'image/svg+xml';
        break;
      case LegendFileType.jpg:
      case LegendFileType.jpeg:
        fileExtension = 'jpg';
        mimeType = 'image/jpeg';
        break;
      case LegendFileType.png:
        fileExtension = 'png';
        mimeType = 'image/png';
        break;
    }

    // 保存图像数据
    String imagePath = 'image.$fileExtension';
    if (legend.imageData != null && legend.imageData!.isNotEmpty) {
      final imageFilePath = '$legendPath/$imagePath';
      await _vfs.writeBinaryFile(
        imageFilePath,
        legend.imageData!,
        mimeType: mimeType,
      );
    }

    // 保存JSON配置
    final legendData = VfsLegendData(
      title: legend.title,
      imagePath: imagePath,
      fileType: legend.fileType.name,
      centerX: legend.centerX,
      centerY: legend.centerY,
      version: legend.version,
      createdAt: legend.createdAt,
      updatedAt: DateTime.now(),
    );

    final jsonPath = '$legendPath/${_sanitizeFileName(legend.title)}.json';
    await _vfs.writeJsonFile(jsonPath, legendData.toJson());

    // 更新元数据
    final meta = await _getMeta();
    final updatedMeta = meta.copyWith(
      legendVersions: {...meta.legendVersions, legend.title: legend.version},
      lastUpdated: DateTime.now(),
    );
    await _saveMeta(updatedMeta);

    return legendPath;
  }

  /// 获取图例
  Future<LegendItem?> getLegend(String title, [String? folderPath]) async {
    // 首先尝试使用原始标题构建路径（不进行sanitize）
    final pathPrefix = 'indexeddb://$_database/$_collection';
    String legendPath;
    
    if (folderPath != null && folderPath.isNotEmpty) {
      final cleanFolderPath = folderPath.replaceAll(RegExp(r'^/+|/+$'), '');
      legendPath = cleanFolderPath.isNotEmpty 
          ? '$pathPrefix/$cleanFolderPath/$title.legend'
          : '$pathPrefix/$title.legend';
    } else {
      legendPath = '$pathPrefix/$title.legend';
    }
    
    debugPrint('获取图例: "$title", 尝试原始路径: $legendPath');

    try {
      // 首先检查使用原始标题的目录是否存在
      if (!await _vfs.exists(legendPath)) {
        debugPrint('原始路径不存在，尝试sanitized路径');
        // 如果不存在，尝试使用sanitized路径
        legendPath = _buildLegendPath(title, folderPath);
        debugPrint('尝试sanitized路径: $legendPath');
        
        if (!await _vfs.exists(legendPath)) {
          debugPrint('图例目录不存在: $legendPath');
          return null;
        }
      }

      // 读取JSON配置 - 首先尝试使用原始标题
      String jsonPath = '$legendPath/$title.json';
      debugPrint('查找JSON文件: $jsonPath (使用原始标题)');
      
      if (!await _vfs.exists(jsonPath)) {
        debugPrint('原始标题JSON文件不存在，尝试sanitized标题');
        // 如果原始标题的JSON不存在，尝试sanitized标题
        final sanitizedTitle = _sanitizeFileName(title);
        jsonPath = '$legendPath/$sanitizedTitle.json';
        debugPrint('查找JSON文件: $jsonPath (原标题: "$title" -> 清理后: "$sanitizedTitle")');
        
        if (!await _vfs.exists(jsonPath)) {
          debugPrint('JSON文件不存在: $jsonPath');
          return null;
        }
      }

      final legendJson = await _vfs.readJsonFile(jsonPath);
      if (legendJson == null) {
        return null;
      }

      final legendData = VfsLegendData.fromJson(legendJson);

      // 读取图像数据
      Uint8List? imageData;
      final imageFilePath = '$legendPath/${legendData.imagePath}';
      if (await _vfs.exists(imageFilePath)) {
        final content = await _vfs.readFile(imageFilePath);
        imageData = content?.data;
      }

      // 将字符串转换为LegendFileType枚举
      LegendFileType fileType;
      try {
        fileType = LegendFileType.values.firstWhere(
          (type) => type.name == legendData.fileType,
        );
      } catch (e) {
        // 如果找不到匹配的类型，默认为png
        fileType = LegendFileType.png;
      }

      return LegendItem(
        title: legendData.title,
        imageData: imageData,
        centerX: legendData.centerX,
        centerY: legendData.centerY,
        version: legendData.version,
        createdAt: legendData.createdAt,
        updatedAt: legendData.updatedAt,
        fileType: fileType,
      );
    } catch (e) {
      debugPrint('获取图例失败: $title, 错误: $e');
      return null;
    }
  }

  /// 获取指定文件夹下的所有图例标题
  Future<List<String>> getAllLegendTitles([String? folderPath]) async {
    try {
      final basePath = folderPath != null && folderPath.isNotEmpty
          ? 'indexeddb://$_database/$_collection/${folderPath.replaceAll(RegExp(r'^/+|/+$'), '')}'
          : 'indexeddb://$_database/$_collection';

      debugPrint('获取图例列表，路径: $basePath');
      final entries = await _vfs.listDirectory(basePath);
      debugPrint('VFS返回的条目数量: ${entries.length}');
      
      final legendEntries = entries.where((entry) => entry.isDirectory && entry.name.endsWith('.legend')).toList();
      debugPrint('找到的.legend文件夹: ${legendEntries.map((e) => e.name).toList()}');
      
      final titles = legendEntries
          .map((entry) => entry.name.replaceAll('.legend', ''))
          .map((name) {
            final desanitized = _desanitizeFileName(name);
            debugPrint('文件夹名称转换: "$name" -> "$desanitized"');
            return desanitized;
          })
          .toList();
      
      debugPrint('最终图例标题列表: $titles');
      return titles;
    } catch (e) {
      debugPrint('获取图例列表失败: $e');
      return [];
    }
  }

  /// 获取指定文件夹下的所有图例
  Future<List<LegendItem>> getAllLegends([String? folderPath]) async {
    final titles = await getAllLegendTitles(folderPath);
    final List<LegendItem> legends = [];

    for (final title in titles) {
      final legend = await getLegend(title, folderPath);
      if (legend != null) {
        legends.add(legend);
      }
    }

    return legends;
  }

  /// 获取指定文件夹中的所有图例文件
  Future<List<String>> getLegendsInFolder(String folderPath) async {
    try {
      final cleanFolderPath = folderPath.replaceAll(RegExp(r'^/+|/+$'), '');
      final fullPath = cleanFolderPath.isEmpty
          ? 'indexeddb://$_database/$_collection'
          : 'indexeddb://$_database/$_collection/$cleanFolderPath';

      final entries = await _vfs.listDirectory(fullPath);
      final legendFiles = <String>[];

      for (final entry in entries) {
        if (entry.isDirectory && entry.name.endsWith('.legend')) {
          legendFiles.add(entry.name);
        }
      }

      return legendFiles..sort();
    } catch (e) {
      debugPrint('获取文件夹中的图例失败: $folderPath, 错误: $e');
      return [];
    }
  }

  /// 删除图例
  Future<bool> deleteLegend(String title, [String? folderPath]) async {
    final legendPath = _buildLegendPath(title, folderPath);

    try {
      if (await _vfs.exists(legendPath)) {
        await _vfs.delete(legendPath, recursive: true);

        // 更新元数据
        final meta = await _getMeta();
        final updatedVersions = Map<String, int>.from(meta.legendVersions);
        updatedVersions.remove(title);

        final updatedMeta = meta.copyWith(
          legendVersions: updatedVersions,
          lastUpdated: DateTime.now(),
        );
        await _saveMeta(updatedMeta);

        return true;
      }
    } catch (e) {
      debugPrint('删除图例失败: $title, 错误: $e');
    }

    return false;
  }

  /// 检查图例是否存在
  Future<bool> exists(String title, [String? folderPath]) async {
    final legendPath = _buildLegendPath(title, folderPath);
    return await _vfs.exists(legendPath);
  }

  /// 清空所有图例
  Future<void> clearAllLegends() async {
    try {
      final titles = await getAllLegendTitles();
      for (final title in titles) {
        await deleteLegend(title);
      }

      // 重置元数据
      final meta = VfsLegendMeta(
        version: 1,
        legendVersions: {},
        lastUpdated: DateTime.now(),
      );
      await _saveMeta(meta);
    } catch (e) {
      debugPrint('清空图例失败: $e');
      rethrow;
    }
  }

  /// 获取存储信息
  Future<Map<String, dynamic>> getStorageInfo() async {
    final meta = await _getMeta();
    final titles = await getAllLegendTitles();

    return {
      'version': meta.version,
      'totalLegends': titles.length,
      'lastUpdated': meta.lastUpdated.toIso8601String(),
      'storageType': 'VFS',
      'database': _database,
      'collection': _collection,
    };
  }

  /// 获取所有文件夹
  Future<List<String>> getAllFolders() async {
    try {
      final basePath = 'indexeddb://$_database/$_collection';
      final entries = await _vfs.listDirectory(basePath);

      final folders = <String>[];

      for (final entry in entries) {
        if (entry.isDirectory && !entry.name.endsWith('.legend')) {
          folders.add(entry.name);
          // 递归获取子文件夹
          final subFolders = await _getSubFolders(entry.name);
          folders.addAll(subFolders);
        }
      }

      return folders..sort();
    } catch (e) {
      debugPrint('获取文件夹列表失败: $e');
      return [];
    }
  }

  /// 递归获取子文件夹
  Future<List<String>> _getSubFolders(String parentPath) async {
    try {
      final fullPath = 'indexeddb://$_database/$_collection/$parentPath';
      final entries = await _vfs.listDirectory(fullPath);

      final subFolders = <String>[];

      for (final entry in entries) {
        if (entry.isDirectory && !entry.name.endsWith('.legend')) {
          final subPath = '$parentPath/${entry.name}';
          subFolders.add(subPath);
          // 继续递归
          final subSubFolders = await _getSubFolders(subPath);
          subFolders.addAll(subSubFolders);
        }
      }

      return subFolders;
    } catch (e) {
      debugPrint('获取子文件夹失败: $parentPath, 错误: $e');
      return [];
    }
  }

  /// 创建文件夹
  Future<bool> createFolder(String folderPath) async {
    try {
      final fullPath =
          'indexeddb://$_database/$_collection/${folderPath.replaceAll(RegExp(r'^/+|/+$'), '')}';
      await _vfs.createDirectory(fullPath);
      return true;
    } catch (e) {
      debugPrint('创建文件夹失败: $folderPath, 错误: $e');
      return false;
    }
  }

  /// 删除文件夹（仅当文件夹为空时）
  Future<bool> deleteFolder(String folderPath) async {
    try {
      final fullPath =
          'indexeddb://$_database/$_collection/${folderPath.replaceAll(RegExp(r'^/+|/+$'), '')}';

      // 检查文件夹是否为空
      final entries = await _vfs.listDirectory(fullPath);
      if (entries.isNotEmpty) {
        debugPrint('文件夹不为空，无法删除: $folderPath');
        return false;
      }

      await _vfs.delete(fullPath);
      return true;
    } catch (e) {
      debugPrint('删除文件夹失败: $folderPath, 错误: $e');
      return false;
    }
  }
}
