import 'package:flutter/material.dart';
import '../lib/models/map_version.dart';
import '../lib/models/map_item.dart';

/// 测试版本命名功能
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 开始测试版本命名功能');
  
  try {
    // 创建版本管理器
    final versionManager = MapVersionManager(mapTitle: 'test_map');
    
    // 创建测试地图数据
    final testMapData = MapItem(
      id: null,
      title: 'Test Map',
      imageData: null,
      version: 1,
      layers: [],
      legendGroups: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // 测试正常版本名称
    print('\n=== 测试正常版本名称 ===');
    final version1 = versionManager.createVersion('我的第一个版本', testMapData);
    print('版本名称: "${version1.name}"');
    print('版本ID（文件夹名）: "${version1.id}"');
    
    // 测试包含特殊字符的版本名称
    print('\n=== 测试特殊字符版本名称 ===');
    final version2 = versionManager.createVersion('版本 2.0: 新功能 & 修复 <测试>', testMapData);
    print('版本名称: "${version2.name}"');
    print('版本ID（文件夹名）: "${version2.id}"');
    
    // 测试重复名称
    print('\n=== 测试重复名称 ===');
    final version3 = versionManager.createVersion('我的第一个版本', testMapData);
    print('版本名称: "${version3.name}"');
    print('版本ID（文件夹名）: "${version3.id}"');
    
    // 测试空白名称
    print('\n=== 测试空白名称 ===');
    final version4 = versionManager.createVersion('   ', testMapData);
    print('版本名称: "${version4.name}"');
    print('版本ID（文件夹名）: "${version4.id}"');
    
    // 测试长名称
    print('\n=== 测试长名称 ===');
    final longName = '这是一个非常长的版本名称，包含了很多字符，用来测试长度限制功能是否正常工作，应该会被截断';
    final version5 = versionManager.createVersion(longName, testMapData);
    print('版本名称: "${version5.name}"');
    print('版本ID（文件夹名）: "${version5.id}"');
    print('ID长度: ${version5.id.length}');
    
    // 显示所有版本
    print('\n=== 所有创建的版本 ===');
    for (final version in versionManager.versions) {
      print('- "${version.name}" → 文件夹: "${version.id}"');
    }
    
    print('\n✅ 版本命名功能测试完成！');
    print('现在版本文件夹使用的是清理后的版本名称，而不是时间戳格式。');
    
  } catch (e, stackTrace) {
    print('❌ 测试失败: $e');
    print('堆栈跟踪: $stackTrace');
  }
}
