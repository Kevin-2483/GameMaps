import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// 模拟的用户偏好设置类（简化版）
class MockUserPreferences {
  final String userId;
  final String displayName;
  final Map<String, dynamic> settings;
  final DateTime updatedAt;

  MockUserPreferences({
    required this.userId,
    required this.displayName,
    required this.settings,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'displayName': displayName,
    'settings': settings,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MockUserPreferences.fromJson(Map<String, dynamic> json) => 
    MockUserPreferences(
      userId: json['userId'],
      displayName: json['displayName'],
      settings: json['settings'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );

  static MockUserPreferences createMock(int index) {
    return MockUserPreferences(
      userId: 'user_$index',
      displayName: '用户$index',
      settings: {
        'theme': 'dark',
        'language': 'zh_CN',
        'notifications': true,
        'autoSave': false,
        'recentColors': List.generate(10, (i) => i * 1000000),
        'customData': List.generate(100, (i) => 'data_item_$i'),
      },
      updatedAt: DateTime.now(),
    );
  }
}

/// 性能基准测试
class UserPreferencesPerformanceBenchmark {
  static Future<void> main() async {
    print('=== 用户偏好设置存储性能对比测试 ===\n');

    // 初始化数据库工厂
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await _testSharedPreferencesPerformance();
    await _testDatabasePerformance();
    
    print('\n=== 测试完成 ===');
  }

  /// 测试 SharedPreferences 性能
  static Future<void> _testSharedPreferencesPerformance() async {
    print('📊 测试 SharedPreferences 性能...');
    
    final prefs = await SharedPreferences.getInstance();
    
    // 清理之前的测试数据
    final keys = prefs.getKeys().where((k) => k.startsWith('test_user_')).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }

    const userCount = 100;
    final stopwatch = Stopwatch();

    // 写入测试
    stopwatch.start();
    for (int i = 0; i < userCount; i++) {
      final user = MockUserPreferences.createMock(i);
      await prefs.setString('test_user_$i', jsonEncode(user.toJson()));
    }
    stopwatch.stop();
    final writeTime = stopwatch.elapsedMilliseconds;

    // 读取测试
    stopwatch.reset();
    stopwatch.start();
    final loadedUsers = <MockUserPreferences>[];
    for (int i = 0; i < userCount; i++) {
      final jsonStr = prefs.getString('test_user_$i');
      if (jsonStr != null) {
        final user = MockUserPreferences.fromJson(jsonDecode(jsonStr));
        loadedUsers.add(user);
      }
    }
    stopwatch.stop();
    final readTime = stopwatch.elapsedMilliseconds;

    // 更新测试
    stopwatch.reset();
    stopwatch.start();
    for (int i = 0; i < userCount; i++) {
      final user = loadedUsers[i];
      final updatedUser = MockUserPreferences(
        userId: user.userId,
        displayName: user.displayName + '_updated',
        settings: user.settings,
        updatedAt: DateTime.now(),
      );
      await prefs.setString('test_user_$i', jsonEncode(updatedUser.toJson()));
    }
    stopwatch.stop();
    final updateTime = stopwatch.elapsedMilliseconds;

    // 清理测试数据
    for (int i = 0; i < userCount; i++) {
      await prefs.remove('test_user_$i');
    }

    print('  ✅ SharedPreferences 结果:');
    print('    - 写入 $userCount 个用户: ${writeTime}ms');
    print('    - 读取 $userCount 个用户: ${readTime}ms');
    print('    - 更新 $userCount 个用户: ${updateTime}ms');
    print('    - 总时间: ${writeTime + readTime + updateTime}ms\n');
  }

  /// 测试数据库性能
  static Future<void> _testDatabasePerformance() async {
    print('🗄️ 测试 SQLite 数据库性能...');

    // 创建临时数据库
    final dbPath = 'test_performance.db';
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE test_users (
            user_id TEXT PRIMARY KEY,
            display_name TEXT NOT NULL,
            settings_json TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );

    const userCount = 100;
    final stopwatch = Stopwatch();

    try {
      // 写入测试
      stopwatch.start();
      await db.transaction((txn) async {
        for (int i = 0; i < userCount; i++) {
          final user = MockUserPreferences.createMock(i);
          await txn.insert('test_users', {
            'user_id': user.userId,
            'display_name': user.displayName,
            'settings_json': jsonEncode(user.settings),
            'updated_at': user.updatedAt.millisecondsSinceEpoch,
          });
        }
      });
      stopwatch.stop();
      final writeTime = stopwatch.elapsedMilliseconds;

      // 读取测试
      stopwatch.reset();
      stopwatch.start();
      final loadedUsers = <MockUserPreferences>[];
      final results = await db.query('test_users', orderBy: 'user_id');
      for (final row in results) {
        final user = MockUserPreferences(
          userId: row['user_id'] as String,
          displayName: row['display_name'] as String,
          settings: jsonDecode(row['settings_json'] as String),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
        );
        loadedUsers.add(user);
      }
      stopwatch.stop();
      final readTime = stopwatch.elapsedMilliseconds;

      // 更新测试
      stopwatch.reset();
      stopwatch.start();
      await db.transaction((txn) async {
        for (int i = 0; i < userCount; i++) {
          final user = loadedUsers[i];
          await txn.update(
            'test_users',
            {
              'display_name': user.displayName + '_updated',
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'user_id = ?',
            whereArgs: [user.userId],
          );
        }
      });
      stopwatch.stop();
      final updateTime = stopwatch.elapsedMilliseconds;

      print('  ✅ SQLite 数据库结果:');
      print('    - 写入 $userCount 个用户: ${writeTime}ms');
      print('    - 读取 $userCount 个用户: ${readTime}ms');
      print('    - 更新 $userCount 个用户: ${updateTime}ms');
      print('    - 总时间: ${writeTime + readTime + updateTime}ms');

    } finally {
      await db.close();
      // 清理测试数据库
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}

/// 运行性能测试
void main() async {
  await UserPreferencesPerformanceBenchmark.main();
}
