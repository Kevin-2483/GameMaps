/// 响应式版本管理系统集成测试
/// 验证版本管理器的核心功能

import 'package:flutter_test/flutter_test.dart';
import 'package:r6box/services/reactive_version_manager.dart';
import 'package:r6box/models/map_item.dart';
import 'package:r6box/models/map_layer.dart';

void main() {
  group('响应式版本管理系统测试', () {
    late ReactiveVersionManager versionManager;

    setUp(() {
      versionManager = ReactiveVersionManager(mapTitle: 'Test Map');
    });

    tearDown(() {
      versionManager.dispose();
    });

    test('应该能够初始化默认版本', () {
      // 创建测试地图数据
      final mapItem = MapItem(
        id: 'test_map',
        title: 'Test Map',
        layers: [],
        legendGroups: [],
        stickyNotes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 初始化默认版本
      final defaultVersion = versionManager.initializeVersion(
        'default',
        versionName: '默认版本',
        initialData: mapItem,
      );

      // 验证版本创建
      expect(defaultVersion.versionId, 'default');
      expect(defaultVersion.versionName, '默认版本');
      expect(defaultVersion.sessionData, isNotNull);
      expect(versionManager.currentVersionId, 'default');
      expect(versionManager.allVersionStates.length, 1);
    });

    test('应该能够创建新版本', () {
      // 先初始化默认版本
      final mapItem = MapItem(
        id: 'test_map',
        title: 'Test Map',
        layers: [],
        legendGroups: [],
        stickyNotes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      versionManager.initializeVersion(
        'default',
        versionName: '默认版本',
        initialData: mapItem,
      );

      // 创建新版本
      final newVersion = versionManager.createVersion(
        'version_1',
        versionName: '测试版本',
        sourceVersionId: 'default',
      );

      // 验证新版本
      expect(newVersion.versionId, 'version_1');
      expect(newVersion.versionName, '测试版本');
      expect(versionManager.allVersionStates.length, 2);
    });

    test('应该能够切换版本', () {
      // 初始化两个版本
      final mapItem = MapItem(
        id: 'test_map',
        title: 'Test Map',
        layers: [],
        legendGroups: [],
        stickyNotes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      versionManager.initializeVersion(
        'default',
        versionName: '默认版本',
        initialData: mapItem,
      );

      versionManager.createVersion(
        'version_1',
        versionName: '测试版本',
        sourceVersionId: 'default',
      );

      // 切换到新版本
      versionManager.switchToVersion('version_1');

      // 验证当前版本
      expect(versionManager.currentVersionId, 'version_1');
    });

    test('应该能够删除版本', () {
      // 初始化两个版本
      final mapItem = MapItem(
        id: 'test_map',
        title: 'Test Map',
        layers: [],
        legendGroups: [],
        stickyNotes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      versionManager.initializeVersion(
        'default',
        versionName: '默认版本',
        initialData: mapItem,
      );

      versionManager.createVersion(
        'version_1',
        versionName: '测试版本',
        sourceVersionId: 'default',
      );

      expect(versionManager.allVersionStates.length, 2);

      // 删除版本
      versionManager.deleteVersion('version_1');

      // 验证版本已删除
      expect(versionManager.allVersionStates.length, 1);
      expect(versionManager.versionExists('version_1'), false);
    });

    test('应该能够检测未保存的更改', () {
      // 初始化版本
      final mapItem = MapItem(
        id: 'test_map',
        title: 'Test Map',
        layers: [],
        legendGroups: [],
        stickyNotes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      versionManager.initializeVersion(
        'default',
        versionName: '默认版本',
        initialData: mapItem,
      );

      // 初始状态应该没有未保存的更改
      expect(versionManager.hasUnsavedChanges('default'), false);
      expect(versionManager.hasAnyUnsavedChanges, false);

      // 修改数据
      final updatedMapItem = mapItem.copyWith(
        layers: [
          MapLayer(
            id: 'test_layer',
            name: 'Test Layer',
            opacity: 1.0,
            isVisible: true,
            elements: [],
            legendGroupIds: [],
          ),
        ],
      );

      versionManager.updateVersionData(
        'default',
        updatedMapItem,
        markAsChanged: true,
      );

      // 应该检测到未保存的更改
      expect(versionManager.hasUnsavedChanges('default'), true);
      expect(versionManager.hasAnyUnsavedChanges, true);

      // 标记为已保存
      versionManager.markVersionSaved('default');

      // 应该没有未保存的更改
      expect(versionManager.hasUnsavedChanges('default'), false);
      expect(versionManager.hasAnyUnsavedChanges, false);
    });

    test('应该能够获取版本状态信息', () {
      // 初始化版本
      final mapItem = MapItem(
        id: 'test_map',
        title: 'Test Map',
        layers: [],
        legendGroups: [],
        stickyNotes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      versionManager.initializeVersion(
        'default',
        versionName: '默认版本',
        initialData: mapItem,
      );

      // 获取调试信息
      final debugInfo = versionManager.getDebugInfo();

      expect(debugInfo['mapTitle'], 'Test Map');
      expect(debugInfo['currentVersionId'], 'default');
      expect(debugInfo['totalVersions'], 1);
      expect(debugInfo['versionStates'], isNotNull);
    });

    test('版本适配器应该正常工作', () {
      // 验证适配器的基本功能
      expect(versionAdapter.versionManager, versionManager);
      expect(versionAdapter.mapDataBloc, mockMapDataBloc);

      // 获取适配器状态
      final status = versionAdapter.getAdapterStatus();
      expect(status['isUpdating'], false);
      expect(status['versionManagerInfo'], isNotNull);
    });
  });

  group('版本数据验证', () {
    late ReactiveVersionManager versionManager;

    setUp(() {
      versionManager = ReactiveVersionManager(mapTitle: 'Validation Test');
    });

    tearDown(() {
      versionManager.dispose();
    });

    test('应该验证版本状态完整性', () {
      // 初始化版本
      final mapItem = MapItem(
        id: 'test_map',
        title: 'Validation Test',
        layers: [],
        legendGroups: [],
        stickyNotes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      versionManager.initializeVersion(
        'default',
        versionName: '默认版本',
        initialData: mapItem,
      );

      // 验证状态
      expect(versionManager.validateVersionStates(), true);
    });

    test('应该能够处理无效版本ID', () {
      // 尝试访问不存在的版本
      expect(versionManager.getVersionState('invalid_version'), isNull);
      expect(versionManager.getVersionSessionData('invalid_version'), isNull);
      expect(versionManager.versionExists('invalid_version'), false);
    });

    test('应该能够清理会话状态', () {
      // 初始化版本
      final mapItem = MapItem(
        id: 'test_map',
        title: 'Validation Test',
        layers: [],
        legendGroups: [],
        stickyNotes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      versionManager.initializeVersion(
        'default',
        versionName: '默认版本',
        initialData: mapItem,
      );

      expect(versionManager.allVersionStates.length, 1);

      // 清理所有会话状态
      versionManager.clearAllSessions();

      expect(versionManager.allVersionStates.length, 0);
      expect(versionManager.currentVersionId, isNull);
    });
  });
}
