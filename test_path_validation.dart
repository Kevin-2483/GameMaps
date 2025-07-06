import 'dart:io';

// 复制_isValidTargetPath方法进行测试
bool _isValidTargetPath(String path) {
  // 只允许 indexeddb://r6box/ 开头的绝对路径
  if (!path.startsWith('indexeddb://r6box/')) {
    print('❌ 路径不以 indexeddb://r6box/ 开头: $path');
    return false;
  }
  
  // 解析路径以验证数据库和集合
  final pathPart = path.substring('indexeddb://'.length);
  final segments = pathPart.split('/').where((s) => s.isNotEmpty).toList();
  
  print('🔍 路径段: $segments');
  
  // 路径必须至少包含数据库和集合
  if (segments.length < 2) {
    print('❌ 路径段数量不足 (<2): ${segments.length}');
    return false;
  }
  
  final database = segments[0];
  final collection = segments[1];
  
  print('🔍 数据库: $database, 集合: $collection');
  
  // 验证数据库名称必须是 r6box
  if (database != 'r6box') {
    print('❌ 数据库名称不是 r6box: $database');
    return false;
  }
  
  // 验证集合必须是已挂载的集合之一：fs, legends, maps
  const allowedCollections = ['fs', 'legends', 'maps'];
  if (!allowedCollections.contains(collection)) {
    print('❌ 集合不在允许列表中: $collection');
    return false;
  }
  
  // 不允许包含危险字符（排除协议部分的双斜杠）
  final pathWithoutScheme = path.substring('indexeddb://'.length);
  if (pathWithoutScheme.contains('..') || pathWithoutScheme.contains('//')) {
    print('❌ 包含危险字符 (..) 或双斜杠 (//): $pathWithoutScheme');
    return false;
  }
  
  print('✅ 路径合法: $path');
  return true;
}

void main() {
  print('=== 测试路径验证 ===\n');
  
  final testPaths = [
    'indexeddb://r6box/fs/assets/images/logo.png',
    'indexeddb://r6box/fs/assets/images/backgrounds/main_bg.jpg',
    'indexeddb://r6box/fs/configs/app_settings.json',
    'indexeddb://r6box/legends/data/r6_operators.json',
    'indexeddb://r6box/maps/assets/sounds/notification.mp3',
    'indexeddb://r6box/fs/docs/readme.txt',
  ];
  
  for (final path in testPaths) {
    print('测试路径: $path');
    final isValid = _isValidTargetPath(path);
    print('结果: ${isValid ? "合法" : "不合法"}\n');
  }
}