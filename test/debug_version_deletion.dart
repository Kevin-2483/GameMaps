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

/// 调试版本删除功能的测试脚本
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== 版本删除调试脚本 ===');
  
  try {
    // 初始化VFS系统
    print('初始化VFS系统...');
    final vfsInitializer = VfsDatabaseInitializer();
    await vfsInitializer.initializeApplicationVfs();
    
    final vfsMapService = VfsMapServiceImpl();
    
    // 创建测试地图
    const testMapTitle = 'TestMapForDeletion';
    
    print('\n=== 创建测试地图和版本 ===');
    
    // 创建基础地图
    final testMap = MapItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: testMapTitle,
      version: 1,
      layers: [
        MapLayer(
          id: 'default_layer',
          name: '默认图层',
          order: 1,
          visible: true,
          opacity: 1.0,
          elements: [],
          legendGroupIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      legendGroups: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // 保存基础地图
    await vfsMapService.saveMap(testMap);
    print('测试地图创建完成: $testMapTitle');
    
    // 创建版本管理器并添加测试版本
    final versionManager = MapVersionManager(mapTitle: testMapTitle);
    versionManager.initializeDefault();
    versionManager.updateVersionData('default', testMap);
    
    // 创建几个测试版本
    final version1 = versionManager.createVersion('测试版本1', testMap);
    final version2 = versionManager.createVersion('测试版本2', testMap);
    final version3 = versionManager.createVersion('测试版本3', testMap);
    
    print('创建了 ${versionManager.versions.length} 个版本:');
    for (final version in versionManager.versions) {
      print('  - ${version.name} (ID: ${version.id})');
    }
    
    // 保存版本数据到VFS
    print('\n=== 保存版本数据到VFS ===');
    for (final version in versionManager.versions) {
      if (version.id != 'default') {
        // 创建版本目录
        await vfsMapService.createMapVersion(testMapTitle, version.id, 'default');
        print('版本目录创建: ${version.id}');
        
        // 保存版本元数据
        await vfsMapService.saveVersionMetadata(
          testMapTitle, 
          version.id, 
          version.name,
          createdAt: version.createdAt,
          updatedAt: version.updatedAt,
        );
        print('版本元数据保存: ${version.name}');
      }
    }
    
    // 验证版本存在
    print('\n=== 验证版本存在性 ===');
    final storedVersions = await vfsMapService.getMapVersions(testMapTitle);
    print('VFS中存储的版本: $storedVersions');
    
    final versionNames = await vfsMapService.getAllVersionNames(testMapTitle);
    print('版本名称映射:');
    for (final entry in versionNames.entries) {
      print('  ${entry.key} -> ${entry.value}');
    }
    
    // 测试版本删除
    print('\n=== 测试版本删除 ===');
    
    // 删除version2
    final versionToDelete = version2.id;
    final versionNameToDelete = version2.name;
    
    print('准备删除版本: $versionNameToDelete (ID: $versionToDelete)');
    
    // 1. 检查版本是否存在
    final versionExists = await vfsMapService.mapVersionExists(testMapTitle, versionToDelete);
    print('删除前版本存在性检查: $versionExists');
    
    // 2. 执行删除
    print('执行VFS版本数据删除...');
    try {
      await vfsMapService.deleteMapVersion(testMapTitle, versionToDelete);
      print('✅ VFS版本数据删除成功');
    } catch (e) {
      print('❌ VFS版本数据删除失败: $e');
    }
    
    print('执行版本元数据删除...');
    try {
      await vfsMapService.deleteVersionMetadata(testMapTitle, versionToDelete);
      print('✅ 版本元数据删除成功');
    } catch (e) {
      print('❌ 版本元数据删除失败: $e');
    }
    
    print('执行内存版本删除...');
    final memoryDeleteResult = versionManager.deleteVersion(versionToDelete);
    print('内存版本删除结果: $memoryDeleteResult');
    
    // 3. 验证删除结果
    print('\n=== 验证删除结果 ===');
    
    // 检查VFS中是否还存在
    final versionExistsAfter = await vfsMapService.mapVersionExists(testMapTitle, versionToDelete);
    print('删除后VFS版本存在性: $versionExistsAfter');
    
    // 检查版本列表
    final storedVersionsAfter = await vfsMapService.getMapVersions(testMapTitle);
    print('删除后VFS版本列表: $storedVersionsAfter');
    
    // 检查元数据
    final versionNamesAfter = await vfsMapService.getAllVersionNames(testMapTitle);
    print('删除后版本名称映射:');
    for (final entry in versionNamesAfter.entries) {
      print('  ${entry.key} -> ${entry.value}');
    }
    
    // 检查内存中的版本
    print('删除后内存版本列表:');
    for (final version in versionManager.versions) {
      print('  - ${version.name} (ID: ${version.id})');
    }
    
    // 验证结果
    final deletionSuccess = !versionExistsAfter && 
                          !storedVersionsAfter.contains(versionToDelete) &&
                          !versionNamesAfter.containsKey(versionToDelete) &&
                          !versionManager.hasVersion(versionToDelete);
    
    print('\n=== 删除测试结果 ===');
    if (deletionSuccess) {
      print('✅ 版本删除测试PASSED - 版本已完全删除');
    } else {
      print('❌ 版本删除测试FAILED - 版本删除不完整');
      print('  VFS存在性: $versionExistsAfter');
      print('  VFS列表包含: ${storedVersionsAfter.contains(versionToDelete)}');
      print('  元数据包含: ${versionNamesAfter.containsKey(versionToDelete)}');
      print('  内存包含: ${versionManager.hasVersion(versionToDelete)}');
    }
    
    // 清理测试数据
    print('\n=== 清理测试数据 ===');
    try {
      await vfsMapService.deleteMap(testMapTitle);
      print('测试地图清理完成');
    } catch (e) {
      print('测试地图清理失败: $e');
    }
    
    print('\n✅ 版本删除测试完成');
    
  } catch (e, stackTrace) {
    print('❌ 测试失败: $e');
    print('堆栈跟踪: $stackTrace');
  }
}
