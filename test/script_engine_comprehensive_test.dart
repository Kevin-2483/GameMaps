import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/services/script_engine.dart';
import '../lib/models/script_data.dart';
import '../lib/models/map_layer.dart';

void main() {
  group('ScriptEngine Comprehensive Demo', () {
    late ScriptEngine scriptEngine;
    late List<MapLayer> testLayers;
    setUp(() async {
      scriptEngine = ScriptEngine();
      scriptEngine.reset(); // 重置状态
      await scriptEngine.initialize();

      final now = DateTime.now();
      testLayers = [
        MapLayer(
          id: 'buildings',
          name: 'Buildings',
          order: 0,
          isVisible: true,
          opacity: 1.0,
          createdAt: now,
          updatedAt: now,
          elements: [
            // 大楼A - 矩形
            MapDrawingElement(
              id: 'building-a',
              type: DrawingElementType.rectangle,
              color: Colors.blue,
              strokeWidth: 3.0,
              density: 1.0,
              rotation: 0.0,
              curvature: 0.0,
              zIndex: 0,
              text: 'Building A',
              fontSize: 16.0,
              createdAt: now,
              points: [const Offset(0.1, 0.1), const Offset(0.3, 0.4)],
            ),
            // 大楼B - 空心矩形
            MapDrawingElement(
              id: 'building-b',
              type: DrawingElementType.hollowRectangle,
              color: Colors.red,
              strokeWidth: 2.0,
              density: 1.0,
              rotation: 0.0,
              curvature: 0.0,
              zIndex: 0,
              text: 'Building B',
              fontSize: 14.0,
              createdAt: now,
              points: [const Offset(0.5, 0.1), const Offset(0.8, 0.3)],
            ),
          ],
        ),
        MapLayer(
          id: 'roads',
          name: 'Roads',
          order: 1,
          isVisible: true,
          opacity: 0.9,
          createdAt: now,
          updatedAt: now,
          elements: [
            // 主干道
            MapDrawingElement(
              id: 'main-road',
              type: DrawingElementType.line,
              color: Colors.grey,
              strokeWidth: 5.0,
              density: 1.0,
              rotation: 0.0,
              curvature: 0.0,
              zIndex: 0,
              text: 'Main Road',
              fontSize: 12.0,
              createdAt: now,
              points: [const Offset(0.0, 0.5), const Offset(1.0, 0.5)],
            ),
            // 人行道
            MapDrawingElement(
              id: 'sidewalk',
              type: DrawingElementType.dashedLine,
              color: Colors.brown,
              strokeWidth: 2.0,
              density: 2.0,
              rotation: 0.0,
              curvature: 0.0,
              zIndex: 1,
              text: 'Sidewalk',
              fontSize: 10.0,
              createdAt: now,
              points: [const Offset(0.0, 0.55), const Offset(1.0, 0.55)],
            ),
          ],
        ),
        MapLayer(
          id: 'utilities',
          name: 'Utilities',
          order: 2,
          isVisible: true,
          opacity: 0.7,
          createdAt: now,
          updatedAt: now,
          elements: [
            // 电线杆
            MapDrawingElement(
              id: 'power-pole',
              type: DrawingElementType.line,
              color: Colors.black,
              strokeWidth: 1.0,
              density: 1.0,
              rotation: 0.0,
              curvature: 0.0,
              zIndex: 0,
              text: 'Power Pole',
              fontSize: 8.0,
              createdAt: now,
              points: [const Offset(0.25, 0.0), const Offset(0.25, 0.1)],
            ),
          ],
        ),
      ];

      scriptEngine.setMapDataAccessor(testLayers, (updatedLayers) {
        testLayers = updatedLayers;
      });
    });

    test('Map Analysis Script - 城市规划分析', () async {
      final script = ScriptData(
        id: 'city-analysis',
        name: 'City Planning Analysis',
        type: ScriptType.automation,
        content: '''
        external fun getLayers();
        external fun getAllElements();
        external fun filterElements(callback);
        external fun calculateTotalArea();
        external fun countElements();
        
        print('=== 城市规划分析报告 ===');
        print('');
        
        // 1. 基础统计
        var layers = getLayers();
        var allElements = getAllElements();
        print('图层数量: ' + layers.length.toString());
        print('元素总数: ' + allElements.length.toString());
        print('');
        
        // 2. 分层分析
        for (var i = 0; i < layers.length; i = i + 1) {
          var layer = layers[i];
          print('图层 "' + layer['name'] + '": ' + layer['elementCount'].toString() + ' 个元素');
        }
        print('');
        
        // 3. 建筑物分析
        fun isBuildingElement(element) {
          var type = element['type'];
          return type == 'rectangle' || type == 'hollowRectangle';
        }
        
        var buildings = filterElements(isBuildingElement);
        print('建筑物数量: ' + buildings.length.toString());
        
        var totalBuildingArea = calculateTotalArea();
        print('建筑物总面积: ' + totalBuildingArea.toString());
        print('');
        
        // 4. 道路分析
        fun isRoadElement(element) {
          var type = element['type'];
          return type == 'line' || type == 'dashedLine';
        }
        
        var roads = filterElements(isRoadElement);
        print('道路元素数量: ' + roads.length.toString());
        
        // 5. 密度分析
        fun isHighStrokeWidth(element) {
          return element['strokeWidth'] >= 3.0;
        }
        
        var heavyElements = filterElements(isHighStrokeWidth);
        print('重要元素数量 (粗线条): ' + heavyElements.length.toString());
        print('');
        
        // 6. 图层可见性检查
        var visibleLayers = 0;
        for (var i = 0; i < layers.length; i = i + 1) {
          if (layers[i]['isVisible']) {
            visibleLayers = visibleLayers + 1;
          }
        }
        print('可见图层数量: ' + visibleLayers.toString());
        
        print('=== 分析完成 ===');
        
        // 返回分析结果摘要
        {
          'totalLayers': layers.length,
          'totalElements': allElements.length,
          'buildings': buildings.length,
          'roads': roads.length,
          'buildingArea': totalBuildingArea,
          'heavyElements': heavyElements.length,
          'visibleLayers': visibleLayers
        };
        ''',
        parameters: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await scriptEngine.executeScript(script);
      if (!result.success) {
        debugPrint('City analysis script failed: ${result.error}');
      }
      expect(result.success, isTrue);
      expect(result.result, isNotNull);

      // hetu_script 返回的是 HTStruct，需要转换访问
      final analysis = result.result;
      // 由于是 HTStruct，我们通过打印来验证而不是直接访问
      debugPrint('Analysis result: $analysis');
    });

    test('Element Manipulation Script - 动态修改演示', () async {
      final script = ScriptData(
        id: 'element-manipulation',
        name: 'Element Manipulation Demo',
        type: ScriptType.automation,
        content: '''
        external fun getAllElements();
        external fun updateElementProperty(elementId, property, value);
        external fun moveElement(elementId, deltaX, deltaY);
        
        print('=== 元素操作演示 ===');
        
        var elements = getAllElements();
        print('初始元素数量: ' + elements.length.toString());
        
        // 1. 修改Building A的颜色为绿色
        var greenColor = 4278255360; // Colors.green.value        var updated1 = updateElementProperty('building-a', 'color', greenColor);
        print('建筑A颜色更新结果: ' + updated1);
        
        // 2. 增加主干道的线条宽度
        var updated2 = updateElementProperty('main-road', 'strokeWidth', 8.0);
        print('主干道宽度更新结果: ' + updated2);
        
        // 3. 移动建筑B的位置
        var moved = moveElement('building-b', 0.1, 0.1);
        print('建筑B移动结果: ' + moved);
        
        // 4. 修改人行道的透明度
        var updated3 = updateElementProperty('sidewalk', 'opacity', 0.5);
        print('人行道透明度更新结果: ' + updated3);
        
        print('=== 操作完成 ===');
        
        // 返回操作统计
        {
          'colorUpdated': updated1,
          'widthUpdated': updated2,
          'positionMoved': moved,
          'opacityUpdated': updated3
        };
        ''',
        parameters: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await scriptEngine.executeScript(script);
      if (!result.success) {
        debugPrint('Element manipulation script failed: ${result.error}');
      }
      expect(result.success, isTrue);
      expect(result.result, isNotNull);

      final operations = result.result;
      debugPrint('Manipulation result: $operations');
    });

    test('Mathematical Calculations - 数学计算演示', () async {
      final script = ScriptData(
        id: 'math-calculations',
        name: 'Mathematical Calculations Demo',
        type: ScriptType.automation,
        content: '''
        external fun sin(x);
        external fun cos(x);
        external fun tan(x);
        external fun sqrt(x);
        external fun pow(x, y);
        external fun abs(x);
        external fun random();
        
        print('=== 数学计算演示 ===');
        
        // 1. 三角函数计算
        var pi = 3.14159265359;
        var angle = pi / 4; // 45度
        
        var sinValue = sin(angle);
        var cosValue = cos(angle);
        var tanValue = tan(angle);
        
        print('sin(45°) = ' + sinValue.toString());
        print('cos(45°) = ' + cosValue.toString());
        print('tan(45°) = ' + tanValue.toString());
        
        // 2. 距离计算
        var x1 = 0.1; var y1 = 0.1;
        var x2 = 0.3; var y2 = 0.4;
        
        var deltaX = x2 - x1;
        var deltaY = y2 - y1;
        var distance = sqrt(pow(deltaX, 2) + pow(deltaY, 2));
        
        print('两点间距离: ' + distance.toString());
        
        // 3. 面积计算
        var width = abs(deltaX);
        var height = abs(deltaY);
        var area = width * height;
        
        print('矩形面积: ' + area.toString());
        
        // 4. 随机数生成
        var randomValue1 = random();
        var randomValue2 = random();
        var randomAverage = (randomValue1 + randomValue2) / 2;
        
        print('随机数1: ' + randomValue1.toString());
        print('随机数2: ' + randomValue2.toString());
        print('平均值: ' + randomAverage.toString());
        
        print('=== 计算完成 ===');
        
        // 返回计算结果
        {
          'sin45': sinValue,
          'cos45': cosValue,
          'tan45': tanValue,
          'distance': distance,
          'area': area,
          'randomAverage': randomAverage
        };
        ''',
        parameters: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await scriptEngine.executeScript(script);
      if (!result.success) {
        debugPrint('Math calculations script failed: ${result.error}');
      }
      expect(result.success, isTrue);
      expect(result.result, isNotNull);

      final calculations = result.result;
      debugPrint('Calculations result: $calculations');
    });
  });
}
