import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:r6box/services/vfs_map_storage/vfs_map_service_factory.dart';
import 'package:r6box/services/vfs_map_storage/vfs_map_service.dart';
import 'package:r6box/services/vfs_map_storage/vfs_map_data_migrator.dart';
import 'package:r6box/services/virtual_file_system/vfs_storage_service.dart';
import 'package:r6box/models/map_item.dart';
import 'package:r6box/models/map_layer.dart';
import 'dart:typed_data';

void main() {
  // 初始化FFI数据库工厂用于测试
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  group('VFS Map Storage Tests', () {
    late VfsMapService vfsMapService;
    late VfsStorageService storageService;

    setUp(() {
      storageService = VfsStorageService();
      vfsMapService = VfsMapServiceFactory.createVfsMapService(
        storageService: storageService,
      );
    });

    test('创建和获取地图', () async {
      // 创建测试地图
      final testMap = MapItem(
        title: '测试地图',
        imageData: Uint8List.fromList([1, 2, 3, 4]),
        version: 1,
        layers: [],
        legendGroups: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 保存地图
      final mapId = await vfsMapService.saveMap(testMap);
      expect(mapId, isNotEmpty);

      // 获取地图
      final retrievedMap = await vfsMapService.getMapById(mapId);
      expect(retrievedMap, isNotNull);
      expect(retrievedMap!.title, equals('测试地图'));
      expect(retrievedMap.version, equals(1));
    });

    test('地图列表操作', () async {
      // 创建多个测试地图
      final maps = <MapItem>[];
      for (int i = 0; i < 3; i++) {
        final map = MapItem(
          title: '测试地图 $i',
          imageData: Uint8List.fromList([i, i + 1, i + 2]),
          version: 1,
          layers: [],
          legendGroups: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await vfsMapService.saveMap(map);
        maps.add(map);
      }

      // 获取所有地图
      final allMaps = await vfsMapService.getAllMaps();
      expect(allMaps.length, greaterThanOrEqualTo(3));
    });

    test('图层操作', () async {
      // 创建测试地图
      final testMap = MapItem(
        title: '图层测试地图',
        imageData: Uint8List.fromList([1, 2, 3]),
        version: 1,
        layers: [],
        legendGroups: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mapId = await vfsMapService.saveMap(testMap);

      // 创建测试图层
      final testLayer = MapLayer(
        id: 'layer1',
        name: '测试图层',
        order: 0,
        opacity: 1.0,
        isVisible: true,
        elements: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 保存图层
      await vfsMapService.saveLayer(mapId, testLayer);

      // 获取图层
      final retrievedLayer = await vfsMapService.getLayerById(mapId, 'layer1');
      expect(retrievedLayer, isNotNull);
      expect(retrievedLayer!.name, equals('测试图层'));
      expect(retrievedLayer.opacity, equals(1.0));

      // 获取地图的所有图层
      final layers = await vfsMapService.getMapLayers(mapId);
      expect(layers.length, equals(1));
      expect(layers.first.id, equals('layer1'));
    });

    test('资产管理', () async {
      // 创建测试资产
      final assetData = Uint8List.fromList([255, 216, 255, 224]); // JPEG头部
      
      // 保存资产
      final assetHash = await vfsMapService.saveAsset(assetData, 'image/jpeg');
      expect(assetHash, isNotEmpty);

      // 获取资产
      final retrievedAsset = await vfsMapService.getAsset(assetHash);
      expect(retrievedAsset, isNotNull);
      expect(retrievedAsset, equals(assetData));
    });

    test('地图存在性检查', () async {
      // 创建测试地图
      final testMap = MapItem(
        title: '存在性测试地图',
        imageData: Uint8List.fromList([1, 2, 3]),
        version: 1,
        layers: [],
        legendGroups: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mapId = await vfsMapService.saveMap(testMap);

      // 检查地图存在
      final exists = await vfsMapService.mapExists(mapId);
      expect(exists, isTrue);

      // 检查不存在的地图
      final notExists = await vfsMapService.mapExists('nonexistent');
      expect(notExists, isFalse);
    });

    test('地图统计信息', () async {
      // 创建包含图层的测试地图
      final testLayer = MapLayer(
        id: 'layer1',
        name: '统计测试图层',
        order: 0,
        opacity: 1.0,
        isVisible: true,
        elements: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final testMap = MapItem(
        title: '统计测试地图',
        imageData: Uint8List.fromList([1, 2, 3]),
        version: 1,
        layers: [testLayer],
        legendGroups: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mapId = await vfsMapService.saveMap(testMap);

      // 获取统计信息
      final stats = await vfsMapService.getMapStats(mapId);
      expect(stats['layerCount'], equals(1));
      expect(stats['elementCount'], equals(0));
      expect(stats['legendGroupCount'], equals(0));
      expect(stats['version'], equals(1));
    });

    test('本地化支持', () async {
      // 创建测试地图
      final testMap = MapItem(
        title: '本地化测试地图',
        imageData: Uint8List.fromList([1, 2, 3]),
        version: 1,
        layers: [],
        legendGroups: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mapId = await vfsMapService.saveMap(testMap);

      // 保存本地化数据
      final localizations = {
        'en': 'Localization Test Map',
        'zh': '本地化测试地图',
        'ja': 'ローカライゼーションテストマップ',
      };
      await vfsMapService.saveMapLocalizations(mapId, localizations);

      // 获取本地化数据
      final retrievedLocalizations = await vfsMapService.getMapLocalizations(mapId);
      expect(retrievedLocalizations['en'], equals('Localization Test Map'));
      expect(retrievedLocalizations['zh'], equals('本地化测试地图'));
      expect(retrievedLocalizations['ja'], equals('ローカライゼーションテストマップ'));
    });
  });

  group('VFS Map Database Adapter Tests', () {
    test('适配器兼容性测试', () async {
      // 创建适配器实例
      final adapter = VfsMapServiceFactory.createMapDatabaseService();

      // 创建测试地图
      final testMap = MapItem(
        title: '适配器测试地图',
        imageData: Uint8List.fromList([1, 2, 3]),
        version: 1,
        layers: [],
        legendGroups: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 通过适配器保存地图
      final legacyId = await adapter.insertMap(testMap);
      expect(legacyId, greaterThan(0));

      // 通过适配器获取地图
      final retrievedMap = await adapter.getMapById(legacyId);
      expect(retrievedMap, isNotNull);
      expect(retrievedMap!.title, equals('适配器测试地图'));
      expect(retrievedMap.id, equals(legacyId));

      // 获取所有地图
      final allMaps = await adapter.getAllMaps();
      expect(allMaps.any((map) => map.title == '适配器测试地图'), isTrue);

      // 获取地图摘要
      final summaries = await adapter.getAllMapsSummary();
      expect(summaries.any((summary) => summary.title == '适配器测试地图'), isTrue);
    });
  });

  group('VFS Map Data Migration Tests', () {
    test('数据迁移测试', () async {
      final storageService = VfsStorageService();
      final vfsMapService = VfsMapServiceFactory.createVfsMapService(
        storageService: storageService,
      );
      final migrator = VfsMapDataMigrator(vfsMapService, storageService);

      // 创建测试地图列表
      final testMaps = <MapItem>[];
      for (int i = 0; i < 3; i++) {
        final map = MapItem(
          title: '迁移测试地图 $i',
          imageData: Uint8List.fromList([i, i + 1, i + 2]),
          version: 1,
          layers: [],
          legendGroups: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        testMaps.add(map);
      }

      // 执行迁移
      final result = await migrator.migrateAllMaps(testMaps);
      expect(result.successCount, equals(3));
      expect(result.failureCount, equals(0));
      expect(result.hasFailures, isFalse);

      // 验证迁移结果
      final isValid = await migrator.verifyMigration(testMaps);
      expect(isValid, isTrue);
    });
  });
}
