import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../lib/services/vfs_map_storage/vfs_map_service_impl.dart';
import '../lib/services/virtual_file_system/vfs_storage_service.dart';
import '../lib/services/virtual_file_system/vfs_database_initializer.dart';
import '../lib/models/map_item.dart';
import '../lib/models/map_version.dart';
import '../lib/models/map_layer.dart';
import '../lib/models/legend_group.dart';

/// 调试版本加载功能的测试脚本
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== 版本加载调试脚本 ===');
  
  try {
    // 初始化VFS系统
    print('初始化VFS系统...');
    final vfsInitializer = VfsDatabaseInitializer();
    await vfsInitializer.initializeApplicationVfs();
    
    final vfsMapService = VfsMapServiceImpl();
    final storageService = VfsStorageService();
    
    // 创建测试地图（如果不存在）
    const testMapTitle = 'TestMap';
    print('检查测试地图: $testMapTitle');
    
    try {
      await vfsMapService.getMapByTitle(testMapTitle);
      print('找到现有测试地图');
    } catch (e) {
      print('创建新的测试地图...');
      final testMap = MapItem(
        id: null,
        title: testMapTitle,
        imageData: null,
        version: 1,
        layers: [
          MapLayer(
            id: 'test_layer_1',
            name: '测试图层1',
            order: 0,
            visible: true,
            opacity: 1.0,
            elements: [],
            legendGroupIds: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        legendGroups: [
          LegendGroup(
            id: 'test_group_1',
            name: '测试图例组1',
            isVisible: true,
            opacity: 1.0,
            legendItems: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await vfsMapService.saveMap(testMap);
      print('测试地图创建完成');
    }
    
    // 创建多个测试版本
    print('\n=== 创建测试版本 ===');
    
    // 版本1
    const version1 = 'version_1703001000000'; // 2023-12-19 10:10:00
    final version1Exists = await vfsMapService.mapVersionExists(testMapTitle, version1);
    if (!version1Exists) {
      print('创建版本1: $version1');
      await vfsMapService.createMapVersion(testMapTitle, version1, 'default');
      
      // 为版本1添加特定的图层数据
      final version1Layer = MapLayer(
        id: 'version1_layer',
        name: '版本1专用图层',
        order: 1,
        visible: true,
        opacity: 0.8,
        elements: [],
        legendGroupIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await vfsMapService.saveLayer(testMapTitle, version1Layer, version1);
      print('版本1数据保存完成');
    } else {
      print('版本1已存在: $version1');
    }
    
    // 版本2
    const version2 = 'version_1703002000000'; // 2023-12-19 10:26:40
    final version2Exists = await vfsMapService.mapVersionExists(testMapTitle, version2);
    if (!version2Exists) {
      print('创建版本2: $version2');
      await vfsMapService.createMapVersion(testMapTitle, version2, 'default');
      
      // 为版本2添加特定的图例组数据
      final version2Group = LegendGroup(
        id: 'version2_group',
        name: '版本2专用图例组',
        isVisible: true,
        opacity: 0.9,
        legendItems: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await vfsMapService.saveLegendGroup(testMapTitle, version2Group, version2);
      print('版本2数据保存完成');
    } else {
      print('版本2已存在: $version2');
    }
    
    // 测试版本获取
    print('\n=== 测试版本获取 ===');
    final storedVersions = await vfsMapService.getMapVersions(testMapTitle);
    print('存储的版本列表: $storedVersions');
    
    if (storedVersions.isEmpty) {
      print('⚠️ 警告: 没有找到任何版本！');
      return;
    }
    
    // 测试版本管理器功能
    print('\n=== 测试版本管理器 ===');
    final versionManager = MapVersionManager(mapTitle: testMapTitle);
    
    // 初始化默认版本
    versionManager.initializeDefault();
    print('默认版本已初始化');
    
    // 模拟加载过程
    int loadedCount = 0;
    for (final versionId in storedVersions) {
      if (versionId == 'default') {
        continue; // 跳过默认版本
      }
      
      try {
        print('加载版本: $versionId');
        
        // 加载图层数据
        final layers = await vfsMapService.getMapLayers(testMapTitle, versionId);
        print('  - 图层数量: ${layers.length}');
        
        // 加载图例组数据
        final legendGroups = await vfsMapService.getMapLegendGroups(testMapTitle, versionId);
        print('  - 图例组数量: ${legendGroups.length}');
        
        // 构建版本的地图数据
        final baseMap = await vfsMapService.getMapByTitle(testMapTitle);
        final versionMapData = baseMap.copyWith(
          layers: layers,
          legendGroups: legendGroups,
          updatedAt: DateTime.now(),
        );
        
        // 创建版本并添加到版本管理器
        final displayName = _getVersionDisplayName(versionId);
        final version = versionManager.createVersionFromData(
          versionId,
          displayName,
          versionMapData,
        );
        
        print('  - 版本创建成功: ${version.name}');
        loadedCount++;
      } catch (e) {
        print('  - 加载版本失败: $e');
      }
    }
    
    print('\n=== 加载结果 ===');
    print('总存储版本数: ${storedVersions.length}');
    print('成功加载版本数: $loadedCount');
    print('版本管理器中的版本数: ${versionManager.versions.length}');
    
    // 列出所有版本
    for (final version in versionManager.versions) {
      print('- ${version.name} (ID: ${version.id})');
      if (version.mapData != null) {
        print('  图层: ${version.mapData!.layers.length}');
        print('  图例组: ${version.mapData!.legendGroups.length}');
      }
    }
    
    // 测试版本切换
    print('\n=== 测试版本切换 ===');
    for (final version in versionManager.versions) {
      if (version.id != 'default') {
        versionManager.switchToVersion(version.id);
        print('切换到版本: ${version.name}');
        final currentData = versionManager.getVersionData(version.id);
        if (currentData != null) {
          print('  当前版本数据: ${currentData.layers.length} 图层, ${currentData.legendGroups.length} 图例组');
        }
        break;
      }
    }
    
    print('\n✅ 版本加载测试完成');
    
  } catch (e, stackTrace) {
    print('❌ 测试失败: $e');
    print('堆栈跟踪: $stackTrace');
  }
}

/// 为版本ID生成友好的显示名称
String _getVersionDisplayName(String versionId) {
  if (versionId == 'default') {
    return '默认版本';
  }
  
  // 如果是时间戳格式的版本ID，尝试提取时间
  if (versionId.startsWith('version_')) {
    final timestampStr = versionId.replaceFirst('version_', '');
    final timestamp = int.tryParse(timestampStr);
    if (timestamp != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '版本 ${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
  
  // 默认使用版本ID作为名称
  return '版本 $versionId';
}
