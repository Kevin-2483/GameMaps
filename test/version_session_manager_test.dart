import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/version_session_manager.dart';
import '../lib/models/map_item.dart';
import '../lib/models/map_layer.dart';

void main() {
  group('VersionSessionManager Tests', () {
    late VersionSessionManager sessionManager;
    late MapItem testMapData;

    setUpAll(() {
      // 设置 SharedPreferences 的模拟实例
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      sessionManager = VersionSessionManager(
        mapTitle: 'TestMap',
        maxUndoHistory: 5,
      );

      // 创建测试地图数据
      testMapData = MapItem(
        id: 'test-map-1',
        title: 'TestMap',
        description: 'Test Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        layers: [
          MapLayer(
            id: 'layer-1',
            name: 'Test Layer 1',
            order: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            elements: [],
          ),
        ],
        legendGroups: [],
      );
    });

    test('初始化版本会话状态', () {
      const versionId = 'test-version-1';
      
      sessionManager.initializeVersionSession(versionId, testMapData);
      
      final sessionState = sessionManager.getSessionState(versionId);
      expect(sessionState, isNotNull);
      expect(sessionState!.versionId, equals(versionId));
      expect(sessionState.modifiedData, isNotNull);
      expect(sessionState.hasUnsavedChanges, isFalse);
      expect(sessionState.undoHistory, isEmpty);
      expect(sessionState.redoHistory, isEmpty);
    });

    test('更新版本数据', () {
      const versionId = 'test-version-1';
      sessionManager.initializeVersionSession(versionId, testMapData);
      
      // 创建修改后的地图数据
      final modifiedMapData = testMapData.copyWith(
        title: 'Modified TestMap',
        updatedAt: DateTime.now(),
      );
      
      sessionManager.updateVersionData(versionId, modifiedMapData, markAsChanged: true);
      
      final sessionState = sessionManager.getSessionState(versionId);
      expect(sessionState!.hasUnsavedChanges, isTrue);
      expect(sessionState.modifiedData!.title, equals('Modified TestMap'));
    });

    test('撤销重做功能', () {
      const versionId = 'test-version-1';
      sessionManager.initializeVersionSession(versionId, testMapData);
      
      // 添加到撤销历史
      final modifiedData1 = testMapData.copyWith(title: 'Version 1');
      final modifiedData2 = testMapData.copyWith(title: 'Version 2');
      
      sessionManager.addToUndoHistory(versionId, modifiedData1);
      sessionManager.addToUndoHistory(versionId, modifiedData2);
      
      // 更新当前数据
      final currentData = testMapData.copyWith(title: 'Current Version');
      sessionManager.updateVersionData(versionId, currentData);
      
      // 测试撤销
      final undoResult = sessionManager.undo(versionId);
      expect(undoResult, isNotNull);
      expect(undoResult!.title, equals('Version 2'));
      
      // 测试重做
      final redoResult = sessionManager.redo(versionId);
      expect(redoResult, isNotNull);
      expect(redoResult!.title, equals('Current Version'));
    });

    test('版本切换', () {
      const version1 = 'version-1';
      const version2 = 'version-2';
      
      // 初始化两个版本
      sessionManager.initializeVersionSession(version1, testMapData);
      sessionManager.initializeVersionSession(version2, testMapData.copyWith(title: 'Version 2'));
      
      // 切换到版本1
      sessionManager.switchToVersion(version1);
      expect(sessionManager.currentVersionId, equals(version1));
      
      // 切换到版本2
      sessionManager.switchToVersion(version2);
      expect(sessionManager.currentVersionId, equals(version2));
    });

    test('会话状态持久化', () async {
      const versionId = 'test-version-1';
      sessionManager.initializeVersionSession(versionId, testMapData);
      
      // 修改数据
      final modifiedData = testMapData.copyWith(title: 'Modified for Persistence Test');
      sessionManager.updateVersionData(versionId, modifiedData, markAsChanged: true);
      sessionManager.switchToVersion(versionId);
      
      // 保存到存储
      await sessionManager.saveToStorage();
      
      // 创建新的会话管理器实例
      final newSessionManager = VersionSessionManager(
        mapTitle: 'TestMap',
        maxUndoHistory: 5,
      );
      
      // 从存储加载
      await newSessionManager.loadFromStorage();
      
      // 验证数据是否正确加载
      expect(newSessionManager.currentVersionId, equals(versionId));
      final loadedState = newSessionManager.getSessionState(versionId);
      expect(loadedState, isNotNull);
      expect(loadedState!.modifiedData!.title, equals('Modified for Persistence Test'));
      expect(loadedState.hasUnsavedChanges, isTrue);
    });

    test('检查未保存更改', () {
      const version1 = 'version-1';
      const version2 = 'version-2';
      
      sessionManager.initializeVersionSession(version1, testMapData);
      sessionManager.initializeVersionSession(version2, testMapData);
      
      // 版本1没有更改
      expect(sessionManager.hasUnsavedChanges(version1), isFalse);
      
      // 版本2有更改
      sessionManager.updateVersionData(version2, testMapData, markAsChanged: true);
      expect(sessionManager.hasUnsavedChanges(version2), isTrue);
      
      // 检查是否有任何版本有未保存的更改
      expect(sessionManager.hasAnyUnsavedChanges, isTrue);
      
      // 标记版本2为已保存
      sessionManager.markVersionSaved(version2);
      expect(sessionManager.hasUnsavedChanges(version2), isFalse);
      expect(sessionManager.hasAnyUnsavedChanges, isFalse);
    });

    test('清理过期会话', () {
      const versionId = 'old-version';
      sessionManager.initializeVersionSession(versionId, testMapData);
      
      // 手动设置为过期（这里只是测试逻辑，实际中时间会自动管理）
      sessionManager.cleanupExpiredSessions(expireDays: 0);
      
      // 在实际使用中，过期的会话应该被清理
      // 这里我们验证清理方法不会报错
      expect(() => sessionManager.cleanupExpiredSessions(), returnsNormally);
    });

    test('会话摘要信息', () {
      const version1 = 'version-1';
      const version2 = 'version-2';
      
      sessionManager.initializeVersionSession(version1, testMapData);
      sessionManager.initializeVersionSession(version2, testMapData);
      sessionManager.updateVersionData(version2, testMapData, markAsChanged: true);
      sessionManager.switchToVersion(version1);
      
      final summary = sessionManager.getSessionSummary();
      expect(summary, contains('总版本: 2'));
      expect(summary, contains('未保存: 1'));
      expect(summary, contains('当前: $version1'));
    });
  });
}
