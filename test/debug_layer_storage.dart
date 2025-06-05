import 'package:flutter_test/flutter_test.dart';
import 'package:r6box/services/vfs_map_storage/vfs_map_service_impl.dart';
import 'package:r6box/services/virtual_file_system/vfs_storage_service.dart';
import 'package:r6box/services/virtual_file_system/vfs_protocol.dart';
import 'package:r6box/models/map_layer.dart';
import 'package:r6box/models/map_drawing_element.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  group('调试图层存储路径', () {
    late VfsMapServiceImpl vfsMapService;
    late VfsStorageService storageService;
    const String testMapTitle = '测试地图';

    setUp(() async {
      storageService = VfsStorageService();
      vfsMapService = VfsMapServiceImpl(
        storageService: storageService,
        databaseName: 'r6box',
        mapsCollection: 'maps',
      );
    });

    test('验证路径构建逻辑', () {
      // 测试所有路径构建方法
      final mapPath = vfsMapService._getMapPath(testMapTitle);
      final layersPath = vfsMapService._getLayersPath(testMapTitle);
      final layerPath = vfsMapService._getLayerPath(testMapTitle, 'layer1');
      final configPath = vfsMapService._getLayerConfigPath(testMapTitle, 'layer1');
      final elementsPath = vfsMapService._getElementsPath(testMapTitle, 'layer1');
      final elementPath = vfsMapService._getElementPath(testMapTitle, 'layer1', 'element1');
      
      // 使用VfsProtocol构建完整路径
      final fullConfigPath = VfsProtocol.buildPath('r6box', 'maps', configPath);
      final fullElementPath = VfsProtocol.buildPath('r6box', 'maps', elementPath);

      print('=== 路径构建结果 ===');
      print('地图路径: $mapPath');
      print('图层目录路径: $layersPath');
      print('图层路径: $layerPath');
      print('图层配置路径: $configPath');
      print('元素目录路径: $elementsPath');
      print('元素路径: $elementPath');
      print('VFS完整配置路径: $fullConfigPath');
      print('VFS完整元素路径: $fullElementPath');

      // 验证路径格式正确
      expect(mapPath, '测试地图.mapdata');
      expect(layersPath, '测试地图.mapdata/data/default/layers');
      expect(configPath, '测试地图.mapdata/data/default/layers/layer1/config.json');
      expect(fullConfigPath, 'indexeddb://r6box/maps/测试地图.mapdata/data/default/layers/layer1/config.json');
    });

    test('创建并保存测试图层', () async {
      // 创建测试图层
      final testLayer = MapLayer(
        id: 'test_layer_1',
        name: '测试图层1',
        order: 0,
        opacity: 1.0,
        isVisible: true,
        elements: [
          MapDrawingElement(
            id: 'test_element_1',
            type: MapDrawingElementType.line,
            points: [
              const Offset(0.1, 0.1),
              const Offset(0.2, 0.2),
            ],
            color: const Color(0xFF000000),
            strokeWidth: 2.0,
            zIndex: 0,
          ),
        ],
        legendGroupIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('=== 保存图层到VFS ===');
      
      try {
        // 保存图层
        await vfsMapService.saveLayer(testMapTitle, testLayer);
        print('图层保存成功');

        // 验证存储的文件
        print('=== 验证存储文件 ===');
        
        // 检查图层配置文件
        final configPath = VfsProtocol.buildPath('r6box', 'maps', 
          vfsMapService._getLayerConfigPath(testMapTitle, testLayer.id));
        final configExists = await storageService.exists(configPath);
        print('图层配置文件存在: $configExists');
        print('配置文件路径: $configPath');
        
        if (configExists) {
          final configData = await storageService.readFile(configPath);
          if (configData != null) {
            final configJson = jsonDecode(utf8.decode(configData.data));
            print('配置内容: ${jsonEncode(configJson)}');
          }
        }

        // 检查元素文件
        final elementPath = VfsProtocol.buildPath('r6box', 'maps',
          vfsMapService._getElementPath(testMapTitle, testLayer.id, 'test_element_1'));
        final elementExists = await storageService.exists(elementPath);
        print('元素文件存在: $elementExists');
        print('元素文件路径: $elementPath');
        
        if (elementExists) {
          final elementData = await storageService.readFile(elementPath);
          if (elementData != null) {
            final elementJson = jsonDecode(utf8.decode(elementData.data));
            print('元素内容: ${jsonEncode(elementJson)}');
          }
        }

        // 尝试读取图层
        print('=== 读取图层验证 ===');
        final loadedLayer = await vfsMapService.getLayerById(testMapTitle, testLayer.id);
        print('图层读取成功: ${loadedLayer != null}');
        if (loadedLayer != null) {
          print('读取的图层名称: ${loadedLayer.name}');
          print('读取的元素数量: ${loadedLayer.elements.length}');
        }

      } catch (e, stackTrace) {
        print('保存图层失败: $e');
        print('堆栈跟踪: $stackTrace');
        rethrow;
      }
    });

    test('列出地图目录内容验证存储结构', () async {
      try {
        // 先保存一个图层以确保有内容
        final testLayer = MapLayer(
          id: 'debug_layer',
          name: '调试图层',
          order: 0,
          opacity: 1.0,
          isVisible: true,
          elements: [],
          legendGroupIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await vfsMapService.saveLayer(testMapTitle, testLayer);

        print('=== 列出VFS存储内容 ===');
        
        // 列出maps集合根目录
        final mapsRoot = VfsProtocol.buildPath('r6box', 'maps', '');
        final rootFiles = await storageService.listDirectory(mapsRoot);
        print('Maps根目录内容 ($mapsRoot):');
        for (final file in rootFiles) {
          print('  ${file.isDirectory ? '[DIR]' : '[FILE]'} ${file.name}');
        }

        // 列出地图目录
        final mapPath = VfsProtocol.buildPath('r6box', 'maps', 
          vfsMapService._getMapPath(testMapTitle));
        final mapExists = await storageService.exists(mapPath);
        print('地图目录存在: $mapExists ($mapPath)');
        
        if (mapExists) {
          final mapFiles = await storageService.listDirectory(mapPath);
          print('地图目录内容:');
          for (final file in mapFiles) {
            print('  ${file.isDirectory ? '[DIR]' : '[FILE]'} ${file.name}');
          }

          // 列出data目录
          final dataPath = VfsProtocol.buildPath('r6box', 'maps', 
            '${vfsMapService._getMapPath(testMapTitle)}/data');
          final dataExists = await storageService.exists(dataPath);
          print('Data目录存在: $dataExists ($dataPath)');
          
          if (dataExists) {
            final dataFiles = await storageService.listDirectory(dataPath);
            print('Data目录内容:');
            for (final file in dataFiles) {
              print('  ${file.isDirectory ? '[DIR]' : '[FILE]'} ${file.name}');
            }
          }

          // 列出layers目录
          final layersPath = VfsProtocol.buildPath('r6box', 'maps', 
            vfsMapService._getLayersPath(testMapTitle));
          final layersExists = await storageService.exists(layersPath);
          print('Layers目录存在: $layersExists ($layersPath)');
          
          if (layersExists) {
            final layerFiles = await storageService.listDirectory(layersPath);
            print('Layers目录内容:');
            for (final file in layerFiles) {
              print('  ${file.isDirectory ? '[DIR]' : '[FILE]'} ${file.name}');
            }
          }
        }

      } catch (e, stackTrace) {
        print('列出目录失败: $e');
        print('堆栈跟踪: $stackTrace');
        rethrow;
      }
    });
  });
}

// 辅助扩展方法来访问私有方法（仅用于测试）
extension VfsMapServiceTestAccess on VfsMapServiceImpl {
  String _getMapPath(String mapTitle) {
    final sanitizedTitle = mapTitle.replaceAll(RegExp(r'[^\w\s\u4e00-\u9fff]'), '_');
    return '$sanitizedTitle.mapdata';
  }
  
  String _getLayersPath(String mapTitle) => '${_getMapPath(mapTitle)}/data/default/layers';
  String _getLayerPath(String mapTitle, String layerId) => '${_getLayersPath(mapTitle)}/$layerId';
  String _getLayerConfigPath(String mapTitle, String layerId) => '${_getLayerPath(mapTitle, layerId)}/config.json';
  String _getElementsPath(String mapTitle, String layerId) => '${_getLayerPath(mapTitle, layerId)}/elements';
  String _getElementPath(String mapTitle, String layerId, String elementId) => '${_getElementsPath(mapTitle, layerId)}/$elementId.json';
}
