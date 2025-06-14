import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/services/script_engine.dart';
import '../lib/models/script_data.dart';
import '../lib/models/map_layer.dart';

void main() {
  group('ScriptEngine Advanced Tests', () {
    late ScriptEngine scriptEngine;
    late List<MapLayer> testLayers;

    setUp(() async {
      scriptEngine = ScriptEngine();
      await scriptEngine.initialize();
      
      final now = DateTime.now();
      testLayers = [
        MapLayer(
          id: 'layer-1',
          name: 'Shapes Layer',
          order: 0,
          isVisible: true,
          opacity: 1.0,
          createdAt: now,
          updatedAt: now,
          elements: [
            MapDrawingElement(
              id: 'rect-1',
              type: DrawingElementType.rectangle,
              color: Colors.red,
              strokeWidth: 2.0,
              density: 1.0,
              rotation: 0.0,
              curvature: 0.0,
              zIndex: 0,
              text: '',
              fontSize: 14.0,
              createdAt: now,
              points: [const Offset(0, 0), const Offset(100, 100)],
            ),            MapDrawingElement(
              id: 'line-1',
              type: DrawingElementType.line,
              color: Colors.blue,
              strokeWidth: 3.0,
              density: 1.0,
              rotation: 0.0,
              curvature: 0.0,
              zIndex: 1,
              text: '',
              fontSize: 14.0,
              createdAt: now,
              points: [const Offset(200, 200), const Offset(250, 250)],
            ),
          ],
        ),
        MapLayer(
          id: 'layer-2',
          name: 'Text Layer',
          order: 1,
          isVisible: true,
          opacity: 0.8,
          createdAt: now,
          updatedAt: now,
          elements: [
            MapDrawingElement(
              id: 'line-1',
              type: DrawingElementType.line,
              color: Colors.green,
              strokeWidth: 1.0,
              density: 1.0,
              rotation: 0.0,
              curvature: 0.0,
              zIndex: 0,
              text: '',
              fontSize: 14.0,
              createdAt: now,
              points: [const Offset(0, 0), const Offset(50, 50)],
            ),
          ],
        ),
      ];

      scriptEngine.setMapDataAccessor(testLayers, (updatedLayers) {
        testLayers = updatedLayers;
      });
    });

    test('Should count elements by type', () async {
      final script = ScriptData(
        id: 'count-test',
        name: 'Count Test',
        type: ScriptType.automation,
        content: '''
        external fun countElements();
        
        var totalCount = countElements();
        var rectangleCount = countElements('rectangle');
        var circleCount = countElements('line');
        var lineCount = countElements('line');
        
        print('Total: ' + totalCount.toString());
        print('Rectangles: ' + rectangleCount.toString());
        print('Lines: ' + circleCount.toString());
        print('Lines: ' + lineCount.toString());
        ''',
        parameters: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await scriptEngine.executeScript(script);
      expect(result.success, isTrue);
    });

    test('Should filter elements by stroke width', () async {
      final script = ScriptData(
        id: 'filter-test',
        name: 'Filter Test',
        type: ScriptType.automation,
        content: '''        external fun filterElements(callback);
        
        fun thickStrokeFilter(element) {
          return element['strokeWidth'] > 2.0;
        }
        
        var thickElements = filterElements(thickStrokeFilter);
        print('Found thick stroke elements: ' + thickElements.length.toString());
        
        thickElements.length;
        ''',
        parameters: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );      final result = await scriptEngine.executeScript(script);
      if (!result.success) {
        debugPrint('Filter test script execution failed: ${result.error}');
      }
      expect(result.success, isTrue);
      expect(result.result, equals(1)); // 只有蓝色线条的strokeWidth是3.0
    });

    test('Should access all elements across layers', () async {
      final script = ScriptData(
        id: 'all-elements-test',
        name: 'All Elements Test',
        type: ScriptType.automation,        content: '''
        external fun getAllElements();
        
        var allElements = getAllElements();
        print('Total elements across all layers: ' + allElements.length.toString());
        
        for (var i = 0; i < allElements.length; i = i + 1) {
          var element = allElements[i];          print('Element ' + i.toString() + ': ' + element['type'] + ' in layer ' + element['layerId']);
        }
        
        allElements.length;
        ''',
        parameters: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );      final result = await scriptEngine.executeScript(script);
      if (!result.success) {
        debugPrint('All elements test script execution failed: ${result.error}');
      }
      expect(result.success, isTrue);
      expect(result.result, equals(3)); // 总共3个元素
    });

    test('Should calculate area for rectangles', () async {
      final script = ScriptData(
        id: 'area-test',
        name: 'Area Test',
        type: ScriptType.automation,
        content: '''        external fun calculateTotalArea();
        
        var totalArea = calculateTotalArea();
        print('Total rectangle area: ' + totalArea.toString());
        
        totalArea;
        ''',
        parameters: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );      final result = await scriptEngine.executeScript(script);
      if (!result.success) {
        debugPrint('Area test script execution failed: ${result.error}');
      }
      expect(result.success, isTrue);
      expect(result.result, equals(10000.0)); // 100 * 100 = 10000
    });

    test('Should use math functions', () async {
      final script = ScriptData(
        id: 'math-test',
        name: 'Math Test',
        type: ScriptType.automation,
        content: '''        external fun sin(x);
        external fun cos(x);
        external fun pow(x, y);
        external fun sqrt(x);
        
        var pi = 3.14159;
        var sinValue = sin(pi / 2);
        var cosValue = cos(0);
        var powerValue = pow(2, 3);
        var sqrtValue = sqrt(16);
        
        print('sin(π/2) = ' + sinValue.toString());
        print('cos(0) = ' + cosValue.toString());print('2^3 = ' + powerValue.toString());
        print('√16 = ' + sqrtValue.toString());
        
        [sinValue, cosValue, powerValue, sqrtValue];
        ''',
        parameters: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );      final result = await scriptEngine.executeScript(script);
      if (!result.success) {
        debugPrint('Math test script execution failed: ${result.error}');
      }
      expect(result.success, isTrue);
      expect(result.result, isA<List>());
      
      final results = result.result as List;
      expect(results[0], closeTo(1.0, 0.001)); // sin(π/2) ≈ 1
      expect(results[1], closeTo(1.0, 0.001)); // cos(0) = 1
      expect(results[2], equals(8.0)); // 2^3 = 8
      expect(results[3], equals(4.0)); // √16 = 4
    });

    test('Should access layer by ID', () async {
      final script = ScriptData(
        id: 'layer-access-test',
        name: 'Layer Access Test',
        type: ScriptType.automation,
        content: '''        external fun getLayerById(id);
        
        var layer1 = getLayerById('layer-1');
        var layer2 = getLayerById('layer-2');
          print('Layer 1: ' + layer1['name'] + ' has ' + layer1['elementCount'].toString() + ' elements');
        print('Layer 2: ' + layer2['name'] + ' has ' + layer2['elementCount'].toString() + ' elements');
        
        layer1['elementCount'] + layer2['elementCount'];
        ''',
        parameters: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );      final result = await scriptEngine.executeScript(script);
      if (!result.success) {
        debugPrint('Layer access test script execution failed: ${result.error}');
      }
      expect(result.success, isTrue);
      expect(result.result, equals(3)); // 2 + 1 = 3
    });
  });
}
