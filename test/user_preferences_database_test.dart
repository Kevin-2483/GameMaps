import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/services/user_preferences_database_service.dart';
import '../lib/models/user_preferences.dart';

/// 用户偏好设置数据库服务测试
void main() async {
  // 初始化SQLite FFI用于测试
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('UserPreferencesDatabaseService Tests', () {
    late UserPreferencesDatabaseService service;

    setUp(() async {
      service = UserPreferencesDatabaseService();
      // 每次测试前清理数据
      try {
        await service.clearAllData();
      } catch (e) {
        // 忽略清理错误（可能是第一次运行）
      }
    });

    tearDown(() async {
      await service.close();
    });

    test('应该能够保存和读取用户偏好设置', () async {
      // 创建测试用户偏好设置
      final preferences = UserPreferences.createDefault(
        userId: 'test_user_1',
        displayName: '测试用户',
      );

      // 保存偏好设置
      await service.savePreferences(preferences);

      // 读取偏好设置
      final retrievedPreferences = await service.getPreferences('test_user_1');

      expect(retrievedPreferences, isNotNull);
      expect(retrievedPreferences!.userId, equals('test_user_1'));
      expect(retrievedPreferences.displayName, equals('测试用户'));
    });

    test('应该能够管理当前用户', () async {
      // 创建两个测试用户
      final user1 = UserPreferences.createDefault(
        userId: 'user_1',
        displayName: '用户1',
      );
      final user2 = UserPreferences.createDefault(
        userId: 'user_2',
        displayName: '用户2',
      );

      // 保存用户
      await service.savePreferences(user1);
      await service.savePreferences(user2);

      // 设置当前用户
      await service.setCurrentUser('user_1');
      
      // 验证当前用户
      final currentUserId = await service.getCurrentUserId();
      expect(currentUserId, equals('user_1'));

      final currentPreferences = await service.getCurrentPreferences();
      expect(currentPreferences?.userId, equals('user_1'));
      expect(currentPreferences?.displayName, equals('用户1'));

      // 切换用户
      await service.setCurrentUser('user_2');
      final newCurrentUserId = await service.getCurrentUserId();
      expect(newCurrentUserId, equals('user_2'));
    });

    test('应该能够获取所有用户', () async {
      // 创建多个测试用户
      final users = [
        UserPreferences.createDefault(userId: 'user_1', displayName: '用户1'),
        UserPreferences.createDefault(userId: 'user_2', displayName: '用户2'),
        UserPreferences.createDefault(userId: 'user_3', displayName: '用户3'),
      ];

      // 保存所有用户
      for (final user in users) {
        await service.savePreferences(user);
      }

      // 获取所有用户
      final allUsers = await service.getAllUsers();
      expect(allUsers.length, equals(3));
      
      // 验证用户数据
      final userIds = allUsers.map((u) => u.userId).toSet();
      expect(userIds, contains('user_1'));
      expect(userIds, contains('user_2'));
      expect(userIds, contains('user_3'));
    });

    test('应该能够删除用户', () async {
      // 创建测试用户
      final user = UserPreferences.createDefault(
        userId: 'user_to_delete',
        displayName: '要删除的用户',
      );

      // 保存用户
      await service.savePreferences(user);

      // 验证用户存在
      final userExists = await service.userExists('user_to_delete');
      expect(userExists, isTrue);

      // 删除用户
      await service.deleteUser('user_to_delete');

      // 验证用户已删除
      final userExistsAfterDelete = await service.userExists('user_to_delete');
      expect(userExistsAfterDelete, isFalse);
    });

    test('应该能够更新用户偏好设置', () async {
      // 创建测试用户
      final originalPreferences = UserPreferences.createDefault(
        userId: 'update_test_user',
        displayName: '原始用户名',
      );

      // 保存原始偏好设置
      await service.savePreferences(originalPreferences);

      // 更新偏好设置
      final updatedPreferences = originalPreferences.copyWith(
        displayName: '更新后的用户名',
        locale: 'en_US',
      );

      await service.savePreferences(updatedPreferences);

      // 验证更新
      final retrievedPreferences = await service.getPreferences('update_test_user');
      expect(retrievedPreferences?.displayName, equals('更新后的用户名'));
      expect(retrievedPreferences?.locale, equals('en_US'));
    });

    test('应该能够获取存储统计信息', () async {
      // 创建测试用户
      final user = UserPreferences.createDefault(
        userId: 'stats_test_user',
        displayName: '统计测试用户',
      );

      await service.savePreferences(user);

      // 获取统计信息
      final stats = await service.getStorageStats();

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats['userCount'], isA<int>());
      expect(stats['databaseSize'], isA<int>());
      expect(stats['platform'], isA<String>());
    });
  });
}

/// 运行性能测试
Future<void> runPerformanceTests() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final service = UserPreferencesDatabaseService();
  
  try {
    await service.clearAllData();

    // 测试批量插入性能
    print('开始批量插入性能测试...');
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < 100; i++) {
      final user = UserPreferences.createDefault(
        userId: 'perf_user_$i',
        displayName: '性能测试用户 $i',
      );
      await service.savePreferences(user);
    }

    stopwatch.stop();
    print('插入100个用户耗时: ${stopwatch.elapsedMilliseconds}ms');

    // 测试查询性能
    stopwatch.reset();
    stopwatch.start();

    for (int i = 0; i < 100; i++) {
      await service.getPreferences('perf_user_$i');
    }

    stopwatch.stop();
    print('查询100个用户耗时: ${stopwatch.elapsedMilliseconds}ms');

    // 测试获取所有用户性能
    stopwatch.reset();
    stopwatch.start();

    final allUsers = await service.getAllUsers();

    stopwatch.stop();
    print('获取所有用户(${allUsers.length}个)耗时: ${stopwatch.elapsedMilliseconds}ms');

  } finally {
    await service.close();
  }
}

/// 主函数，用于直接运行测试
Future<void> runTestsDirectly() async {
  print('开始用户偏好设置数据库服务测试...');
  
  try {
    // 运行功能测试
    print('=== 功能测试 ===');
    main();
    
    // 运行性能测试
    print('\n=== 性能测试 ===');
    await runPerformanceTests();
    
    print('\n所有测试完成！');
  } catch (e) {
    print('测试过程中发生错误: $e');
  }
}
