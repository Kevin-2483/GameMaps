import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:r6box/models/map_item.dart';
import 'package:r6box/models/map_layer.dart';
import 'package:r6box/services/vfs_map_storage/vfs_map_service_impl.dart';
import 'package:r6box/services/virtual_file_system/vfs_storage_service.dart';
import 'package:r6box/services/virtual_file_system/vfs_protocol.dart';

/// 测试图层背景图像保存功能
void main() {
  // 初始化FFI数据库工厂用于测试
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  group('图层背景图像保存测试', () {
    late VfsMapServiceImpl vfsMapService;
    late VfsStorageService mockStorageService;

    setUp(() {
      // 使用模拟的存储服务进行测试
      mockStorageService = VfsStorageService();
      vfsMapService = VfsMapServiceImpl(
        storageService: mockStorageService,
        databaseName: 'test_r6box',
        mapsCollection: 'test_maps',
      );
    });

    test('保存和加载包含图像数据的绘制元素', () async {
      // 创建测试图像数据
      final testImageData = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG header
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 pixel
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
        0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, // IDAT chunk
        0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, // IEND chunk
        0x42, 0x60, 0x82
      ]);

      // 创建包含图像数据的绘制元素
      final imageElement = MapDrawingElement(
        id: 'test_image_element',
        type: DrawingElementType.imageArea,
        points: [
          const Offset(0.1, 0.1),
          const Offset(0.3, 0.3),
        ],
        color: const Color(0xFF000000),
        strokeWidth: 2.0,
        density: 3.0,
        rotation: 0.0,
        curvature: 0.0,
        triangleCut: TriangleCutType.none,
        zIndex: 0,
        imageData: testImageData,
        imageFit: BoxFit.contain,
        createdAt: DateTime.now(),
      );

      // 创建包含该元素的图层
      final testLayer = MapLayer(
        id: 'test_layer',
        name: '测试图层',
        order: 0,
        opacity: 1.0,
        isVisible: true,
        legendGroupIds: [],
        elements: [imageElement],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 创建测试地图
      final testMap = MapItem(
        id: 12345,
        title: '图像保存测试地图',
        imageData: Uint8List(0),
        version: 1,
        layers: [testLayer],
        legendGroups: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 保存地图
      final mapId = await vfsMapService.saveMap(testMap);
      expect(mapId, isNotEmpty);

      // 验证地图已保存
      final savedMap = await vfsMapService.getMapByTitle(testMap.title);
      expect(savedMap, isNotNull);
      expect(savedMap!.layers.length, equals(1));
      
      // 验证图层已保存
      final savedLayer = savedMap.layers.first;
      expect(savedLayer.elements.length, equals(1));
      
      // 验证绘制元素已保存，并且图像数据完整
      final savedElement = savedLayer.elements.first;
      expect(savedElement.id, equals('test_image_element'));
      expect(savedElement.type, equals(DrawingElementType.imageArea));
      expect(savedElement.imageData, isNotNull);
      expect(savedElement.imageData!.length, equals(testImageData.length));
      
      // 验证图像数据内容完全一致
      for (int i = 0; i < testImageData.length; i++) {
        expect(savedElement.imageData![i], equals(testImageData[i]),
            reason: '图像数据第 $i 字节不匹配');
      }

      print('✅ 图层背景图像保存和加载测试通过');
    });    test('验证相同图像数据的去重功能', () async {
      // 创建测试地图
      final testMap = MapItem(
        title: '去重测试地图',
        imageData: Uint8List.fromList([1, 2, 3]),
        version: 1,
        layers: [],
        legendGroups: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await vfsMapService.saveMap(testMap);
      
      // 创建两个相同的图像数据
      final imageData1 = Uint8List.fromList([1, 2, 3, 4, 5]);
      final imageData2 = Uint8List.fromList([1, 2, 3, 4, 5]); // 相同数据
      final imageData3 = Uint8List.fromList([1, 2, 3, 4, 6]); // 不同数据

      // 保存第一个图像
      final hash1 = await vfsMapService.saveAsset(testMap.title, imageData1, 'image/png');
      expect(hash1, isNotEmpty);

      // 保存相同的图像，应该返回相同的哈希
      final hash2 = await vfsMapService.saveAsset(testMap.title, imageData2, 'image/png');
      expect(hash2, equals(hash1), reason: '相同图像数据应该产生相同的哈希');

      // 保存不同的图像，应该返回不同的哈希
      final hash3 = await vfsMapService.saveAsset(testMap.title, imageData3, 'image/png');
      expect(hash3, isNot(equals(hash1)), reason: '不同图像数据应该产生不同的哈希');

      // 验证可以通过哈希获取回原始数据
      final retrievedData1 = await vfsMapService.getAsset(testMap.title, hash1);
      expect(retrievedData1, isNotNull);
      expect(retrievedData1!.length, equals(imageData1.length));
      
      final retrievedData3 = await vfsMapService.getAsset(testMap.title, hash3);
      expect(retrievedData3, isNotNull);
      expect(retrievedData3!.length, equals(imageData3.length));

      print('✅ 图像去重功能测试通过');
    });

    test('测试多个元素共享相同图像的情况', () async {
      // 创建相同的图像数据
      final sharedImageData = Uint8List.fromList([10, 20, 30, 40, 50]);

      // 创建两个使用相同图像的元素
      final element1 = MapDrawingElement(
        id: 'element_1',
        type: DrawingElementType.imageArea,
        points: [const Offset(0.1, 0.1), const Offset(0.3, 0.3)],
        color: const Color(0xFF000000),
        strokeWidth: 2.0,
        density: 3.0,
        rotation: 0.0,
        curvature: 0.0,
        triangleCut: TriangleCutType.none,
        zIndex: 0,
        imageData: sharedImageData,
        imageFit: BoxFit.contain,
        createdAt: DateTime.now(),
      );

      final element2 = MapDrawingElement(
        id: 'element_2',
        type: DrawingElementType.imageArea,
        points: [const Offset(0.5, 0.5), const Offset(0.7, 0.7)],
        color: const Color(0xFF000000),
        strokeWidth: 2.0,
        density: 3.0,
        rotation: 0.0,
        curvature: 0.0,
        triangleCut: TriangleCutType.none,
        zIndex: 1,
        imageData: sharedImageData,
        imageFit: BoxFit.cover,
        createdAt: DateTime.now(),
      );

      const mapTitle = '共享图像测试地图';
      const layerId = 'shared_image_layer';

      // 保存两个元素
      await vfsMapService.saveElement(mapTitle, layerId, element1);
      await vfsMapService.saveElement(mapTitle, layerId, element2);

      // 加载两个元素
      final loadedElement1 = await vfsMapService.getElementById(mapTitle, layerId, 'element_1');
      final loadedElement2 = await vfsMapService.getElementById(mapTitle, layerId, 'element_2');

      // 验证两个元素都正确加载
      expect(loadedElement1, isNotNull);
      expect(loadedElement2, isNotNull);

      // 验证图像数据都被正确保存和加载
      expect(loadedElement1!.imageData, isNotNull);
      expect(loadedElement2!.imageData, isNotNull);
      expect(loadedElement1.imageData!.length, equals(sharedImageData.length));
      expect(loadedElement2.imageData!.length, equals(sharedImageData.length));

      // 验证图像数据内容正确
      for (int i = 0; i < sharedImageData.length; i++) {
        expect(loadedElement1.imageData![i], equals(sharedImageData[i]));
        expect(loadedElement2.imageData![i], equals(sharedImageData[i]));
      }

      print('✅ 共享图像数据测试通过');
    });
  });
}
